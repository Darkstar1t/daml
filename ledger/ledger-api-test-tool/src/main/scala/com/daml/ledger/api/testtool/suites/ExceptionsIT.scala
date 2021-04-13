// Copyright (c) 2021 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
// SPDX-License-Identifier: Apache-2.0

package com.daml.ledger.api.testtool.suites

import com.daml.ledger.api.testtool.infrastructure.Allocation._
import com.daml.ledger.api.testtool.infrastructure.Assertions._
import com.daml.ledger.api.testtool.infrastructure.LedgerTestSuite
import com.daml.ledger.api.testtool.infrastructure.TransactionHelpers._
import com.daml.ledger.api.testtool.infrastructure.Synchronize.synchronize
import com.daml.ledger.test.semantic.Exceptions.{Divulger, ExceptionTester, Fetcher, WithKey}
import io.grpc.Status

final class ExceptionsIT extends LedgerTestSuite {
  test(
    "ExUncaught",
    "Uncaught exception returns INVALID_ARGUMENT",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      failure <- ledger.exercise(party, t.exerciseThrowUncaught(_)).mustFail("unhandled exception")
    } yield {
      assertGrpcError(failure, Status.Code.INVALID_ARGUMENT, "unhandled exception")
    }
  })

  test(
    "ExCaught",
    "Exceptions can be caught",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      tree <- ledger.exercise(party, t.exerciseThrowCaught(_))
    } yield {
      assertLength(s"1 successful exercise", 1, exercisedEvents(tree))
      ()
    }
  })

  test(
    "ExCaughtNested",
    "Exceptions can be caught when thrown from a nested try block",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      tree <- ledger.exercise(party, t.exerciseNestedCatch(_))
    } yield {
      assertLength(s"1 successful exercise", 1, exercisedEvents(tree))
      ()
    }
  })

  test(
    "ExRollbackActiveFetch",
    "Rollback node depends on activeness of contract in a fetch",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      tFetch <- ledger.create(party, ExceptionTester(party))
      // TODO Currently fails with missing input state for key contract_id.
      _ <- ledger.exercise(party, t.exerciseRollbackFetch(_, tFetch))
      _ <- ledger.exercise(party, t.exerciseArchive(_))
      // This is what should actually fail
      failure <- ledger
        .exercise(party, t.exerciseRollbackFetch(_, tFetch))
        .mustFail("contract is archived")
    } yield {
      assertGrpcError(failure, Status.Code.ABORTED, "Contract could not be found")
    }
  })

  test(
    "ExRollbackActiveExerciseConsuming",
    "Rollback node depends on activeness of contract in a consuming exercise",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      tExercise <- ledger.create(party, ExceptionTester(party))
      // TODO Currently fails with missing input state for key contract_id.
      _ <- ledger.exercise(party, t.exerciseRollbackConsuming(_, tExercise))
      _ <- ledger.exercise(party, t.exerciseArchive(_))
      // This is what should actually fail
      failure <- ledger
        .exercise(party, t.exerciseRollbackConsuming(_, tExercise))
        .mustFail("contract is archived")
    } yield {
      assertGrpcError(failure, Status.Code.ABORTED, "Contract could not be found")
    }
  })

  test(
    "ExRollbackActiveExerciseNonConsuming",
    "Rollback node depends on activeness of contract in a non-consuming exercise",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      tExercise <- ledger.create(party, ExceptionTester(party))
      // TODO Currently fails with missing input state for key contract_id.
      _ <- ledger.exercise(party, t.exerciseRollbackNonConsuming(_, tExercise))
      _ <- ledger.exercise(party, t.exerciseArchive(_))
      // This is what should actually fail
      failure <- ledger
        .exercise(party, t.exerciseRollbackNonConsuming(_, tExercise))
        .mustFail("contract is archived")
    } yield {
      assertGrpcError(failure, Status.Code.ABORTED, "Contract could not be found")
    }
  })

  test(
    "ExRollbackDuplicateKeyCreated",
    "Rollback fails once contract with same key is created",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      _ <- ledger.exercise(party, t.exerciseDuplicateKey(_))
      _ <- ledger.create(party, WithKey(party))
      // TODO this currently succeeds
      failure <- ledger.exercise(party, t.exerciseDuplicateKey(_)).mustFail("duplicate key")
    } yield {
      assertGrpcError(failure, Status.Code.ABORTED, "duplicate key")
    }
  })

  test(
    "ExRollbackDuplicateKeyArchived",
    "Rollback succeeds once contract with same key is archived",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      withKey <- ledger.create(party, WithKey(party))
      failure <- ledger.exercise(party, t.exerciseDuplicateKey(_)).mustFail("duplicate key")
      // TODO this currently succeeds
      _ = assertGrpcError(failure, Status.Code.ABORTED, "duplicate key")
      _ <- ledger.exercise(party, withKey.exerciseArchive(_))
      _ <- ledger.exercise(party, t.exerciseDuplicateKey(_))
    } yield ()
  })

  test(
    "ExRollbackHidden",
    "Create and exercise in rollback node is not exposed on ledger API",
    allocate(SingleParty),
  )(implicit ec => { case Participants(Participant(ledger, party)) =>
    for {
      t <- ledger.create(party, ExceptionTester(party))
      tree <- ledger.exercise(party, t.exerciseRollbackCreate(_))
    } yield {
      // Create node should not be included
      assertLength(s"no creates", 0, createdEvents(tree))
      // Only the root exercise should be included not the one in the rollback node.
      val exercise = assertSingleton(s"1 exercise", exercisedEvents(tree))
      assert(exercise.choice == "RollbackCreate", "Choice name mismatch")
      ()
    }
  })

  test(
    "ExRollbackDivulge",
    "Fetch in rollback divulges",
    allocate(SingleParty, SingleParty),
  )(implicit ec => {
    case Participants(Participant(aLedger, aParty), Participant(bLedger, bParty)) =>
      for {
        divulger <- aLedger.create(aParty, Divulger(aParty, bParty))
        fetcher <- bLedger.create(bParty, Fetcher(bParty, aParty))
        t <- bLedger.create(bParty, WithKey(bParty))
        _ <- synchronize(aLedger, bLedger)
        fetchFailure <- aLedger
          .exercise(aParty, fetcher.exerciseFetch(_, t))
          .mustFail("contract could not be found")
        _ = assertGrpcError(fetchFailure, Status.Code.ABORTED, "Contract could not be found")
        // TODO This currently fails with missing input state for key contract_id.
        _ <- bLedger.exercise(bParty, divulger.exerciseDivulge(_, t))
        _ <- synchronize(aLedger, bLedger)
        _ <- aLedger
          .exercise(aParty, fetcher.exerciseFetch(_, t))
          .mustFail("contract could not be found")
      } yield ()
  })
}

// Copyright (c) 2021 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
// SPDX-License-Identifier: Apache-2.0

package com.daml.platform.store.dao

import java.time.Instant

import anorm.{Row, RowParser, SimpleSql, SqlParser, SqlStringInterpolation, ~}
import com.daml.ledger.ApplicationId
import com.daml.ledger.api.v1.command_completion_service.CompletionStreamResponse
import com.daml.ledger.api.v1.completion.Completion
import com.daml.ledger.participant.state.v1.{Offset, RejectionReason, SubmitterInfo, TransactionId}
import com.daml.lf.data.Ref
import com.daml.platform.store.CompletionFromTransaction.toApiCheckpoint
import com.daml.platform.store.Conversions._
import com.daml.platform.store.dao.events.SqlFunctions
import com.google.rpc.status.Status

private[platform] object CommandCompletionsTable {

  import SqlParser.{int, str}

  private val sharedColumns: RowParser[Offset ~ Instant ~ String] =
    offset("completion_offset") ~ instant("record_time") ~ str("command_id")

  private val acceptedCommandParser: RowParser[CompletionStreamResponse] =
    sharedColumns ~ str("transaction_id") map {
      case offset ~ recordTime ~ commandId ~ transactionId =>
        CompletionStreamResponse(
          checkpoint = toApiCheckpoint(recordTime, offset),
          completions = Seq(Completion(commandId, Some(Status()), transactionId)),
        )
    }

  private val rejectedCommandParser: RowParser[CompletionStreamResponse] =
    sharedColumns ~ int("status_code") ~ str("status_message") map {
      case offset ~ recordTime ~ commandId ~ statusCode ~ statusMessage =>
        CompletionStreamResponse(
          checkpoint = toApiCheckpoint(recordTime, offset),
          completions = Seq(Completion(commandId, Some(Status(statusCode, statusMessage)))),
        )
    }

  val parser: RowParser[CompletionStreamResponse] = acceptedCommandParser | rejectedCommandParser

  val offsetParser: RowParser[Offset] = offset("completion_offset")

  def prepareGet(
      startExclusive: Offset,
      endInclusive: Offset,
      applicationId: ApplicationId,
      parties: Set[Ref.Party],
      sqlFunctions: SqlFunctions,
  ): SimpleSql[Row] = {
    val submittersInPartiesClause =
      sqlFunctions.arrayIntersectionWhereClause("submitters", parties)
    SQL"select completion_offset, record_time, command_id, transaction_id, status_code, status_message from participant_command_completions where completion_offset > $startExclusive and completion_offset <= $endInclusive and application_id = $applicationId and #$submittersInPartiesClause order by completion_offset asc"
  }

  def prepareCompletionInsert(
      submitterInfo: SubmitterInfo,
      offset: Offset,
      transactionId: TransactionId,
      recordTime: Instant,
  ): SimpleSql[Row] =
    SQL"insert into participant_command_completions(completion_offset, record_time, application_id, submitters, command_id, transaction_id) values ($offset, $recordTime, ${submitterInfo.applicationId}, ${submitterInfo.actAs
      .toArray[String]}, ${submitterInfo.commandId}, $transactionId)"

  def prepareRejectionInsert(
      submitterInfo: SubmitterInfo,
      offset: Offset,
      recordTime: Instant,
      reason: RejectionReason,
  ): SimpleSql[Row] =
    SQL"insert into participant_command_completions(completion_offset, record_time, application_id, submitters, command_id, status_code, status_message) values ($offset, $recordTime, ${submitterInfo.applicationId}, ${submitterInfo.actAs
      .toArray[String]}, ${submitterInfo.commandId}, ${reason.value()}, ${reason.description})"

  def prepareCompletionsDelete(endInclusive: Offset): SimpleSql[Row] =
    SQL"delete from participant_command_completions where completion_offset <= $endInclusive"

  def prepareGetOffsetFromTime(pruneUpToInclusive: Instant): SimpleSql[Row] =
    SQL"""select max(completion_offset) from participant_command_completions where completion_offset < (
            select min(completion_offset) from participant_command_completions where record_time > ${pruneUpToInclusive})"""

}

// Copyright (c) 2021 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
// SPDX-License-Identifier: Apache-2.0

package com.daml.platform.store.appendonlydao

import java.sql.Connection

import anorm.SqlParser.{byteArray, long}
import anorm.{Row, RowParser, SimpleSql, SqlStringInterpolation, ~}
import com.daml.ledger.api.domain.{LedgerId, ParticipantId}
import com.daml.ledger.participant.state.v1.{Configuration, Offset}
import com.daml.platform.store.Conversions.{ledgerString, offset, participantId}
import com.daml.scalautil.Statement.discard

private[appendonlydao] object ParametersTable {

  object EventSequentialId {

    /** The BeforeBegin value is established based on the assumption that the event sequential id column
      * is of type BIGSERIAL
      */
    val BeforeBegin = 0L
  }

  private val TableName: String = "parameters"
  private val LedgerIdColumnName: String = "ledger_id"
  private val ParticipantIdColumnName: String = "participant_id"
  private val LedgerEndColumnName: String = "ledger_end"
  private val LedgerEndSequentialIdColumnName: String = "ledger_end_sequential_id"
  private val ConfigurationColumnName: String = "configuration"

  private val LedgerIdParser: RowParser[LedgerId] =
    ledgerString(LedgerIdColumnName).map(LedgerId(_))

  private val ParticipantIdParser: RowParser[Option[ParticipantId]] =
    participantId(ParticipantIdColumnName).map(ParticipantId(_)).?

  private val LedgerEndParser: RowParser[Option[Offset]] =
    offset(LedgerEndColumnName).?

  private val LedgerEndOrBeforeBeginParser: RowParser[Offset] =
    LedgerEndParser.map(_.getOrElse(Offset.beforeBegin))

  private val LedgerEndParserAndSequentialIdParser =
    long(LedgerEndSequentialIdColumnName).?.map(_.getOrElse(EventSequentialId.BeforeBegin))

  private val ConfigurationParser: RowParser[Option[Configuration]] =
    byteArray(ConfigurationColumnName).? map (_.flatMap(Configuration.decode(_).toOption))

  private val LedgerEndAndConfigurationParser: RowParser[Option[(Offset, Configuration)]] =
    LedgerEndParser ~ ConfigurationParser map { case ledgerEnd ~ configuration =>
      for {
        e <- ledgerEnd
        c <- configuration
      } yield (e, c)
    }

  private val SelectLedgerEnd: SimpleSql[Row] = SQL"select #$LedgerEndColumnName from #$TableName"

  private val SelectLedgerEndAndSequentialId =
    SQL"select #$LedgerEndSequentialIdColumnName from #$TableName"

  def getLedgerId(connection: Connection): Option[LedgerId] =
    SQL"select #$LedgerIdColumnName from #$TableName".as(LedgerIdParser.singleOpt)(connection)

  def setLedgerId(ledgerId: String)(connection: Connection): Unit =
    discard(
      SQL"insert into #$TableName(#$LedgerIdColumnName) values($ledgerId)".execute()(connection)
    )

  def getParticipantId(connection: Connection): Option[ParticipantId] =
    SQL"select #$ParticipantIdColumnName from #$TableName".as(ParticipantIdParser.single)(
      connection
    )

  def setParticipantId(participantId: String)(connection: Connection): Unit =
    discard(
      SQL"update #$TableName set #$ParticipantIdColumnName = $participantId".execute()(
        connection
      )
    )

  def getLedgerEnd(connection: Connection): Offset =
    SelectLedgerEnd.as(LedgerEndOrBeforeBeginParser.single)(connection)

  def getLedgerEndSequentialId(connection: Connection): Long =
    SelectLedgerEndAndSequentialId.as(LedgerEndParserAndSequentialIdParser.single)(connection)

  def getInitialLedgerEnd(connection: Connection): Option[Offset] =
    SelectLedgerEnd.as(LedgerEndParser.single)(connection)

  def getLedgerEndAndConfiguration(connection: Connection): Option[(Offset, Configuration)] =
    SQL"select #$LedgerEndColumnName, #$ConfigurationColumnName from #$TableName".as(
      LedgerEndAndConfigurationParser.single
    )(connection)
}

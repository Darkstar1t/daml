package com.daml.platform.store.dao

import org.scalatest.flatspec.AsyncFlatSpec
import org.scalatest.matchers.should.Matchers

class JdbLedgerDaoOracleDatabaseSpec
  extends AsyncFlatSpec
    with Matchers
    with JdbcLedgerDaoSuite
    with JdbcLedgerDaoBackendOracle
    with JdbcLedgerDaoPackagesSpec
//    with JdbcLedgerDaoActiveContractsSpec
//    with JdbcLedgerDaoCompletionsSpec
//    with JdbcLedgerDaoConfigurationSpec
//    with JdbcLedgerDaoContractsSpec
//    with JdbcLedgerDaoDivulgenceSpec
//    with JdbcLedgerDaoPartiesSpec
//    with JdbcLedgerDaoTransactionsSpec
//    with JdbcLedgerDaoTransactionTreesSpec
//    with JdbcLedgerDaoTransactionsWriterSpec
    with JdbcAtomicTransactionInsertion
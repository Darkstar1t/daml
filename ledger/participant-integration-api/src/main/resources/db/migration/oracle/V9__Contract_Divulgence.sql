-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

---------------------------------------------------------------------------------------------------
-- V9: Contract divulgence
--
-- This schema version builds on V2 and V8 by modifying the contract_divulgences.contract_id foreign key
-- to point to contract_data.id (rather than contracts.id previously). Because there is no way to alter a foreign key
-- constraint or to drop and add an unnamed constraint, the script rebuilds the contract_divulgences table.

-- dropped by V30__

-- CREATE TABLE contract_divulgences
-- (
--     contract_id    NVARCHAR2(1000) not null,
--     -- The party to which the given contract was divulged
--     party          NVARCHAR2(1000) not null,
--     -- The offset at which the contract was divulged to the given party
--     ledger_offset  NUMBER          not null,
--     -- The transaction ID at which the contract was divulged to the given party
--     transaction_id NVARCHAR2(1000) not null,
--
--     CONSTRAINT contract_divulgences_contract_key foreign key (contract_id) references contract_data (id), -- refer to contract_data instead, the reason for this script
--     CONSTRAINT contract_divulgences_offset_key foreign key (ledger_offset) references ledger_entries (ledger_offset),
--     CONSTRAINT contract_divulgences_transaction_key foreign key (transaction_id) references ledger_entries (transaction_id),
--     CONSTRAINT contract_divulgences_idx UNIQUE (contract_id, party)
-- );

-- INSERT INTO contract_divulgences (contract_id, party, ledger_offset, transaction_id)
-- SELECT contract_id, party, ledger_offset, transaction_id
-- FROM contract_divulgences_old;

-- Specify CASCADE CONSTRAINTS to drop all referential integrity constraints that refer to primary and unique keys
-- in the dropped table. If you omit this clause, and such referential integrity constraints exist, then the database
-- returns an error and does not drop the table.
-- DROP TABLE contract_divulgences_old CASCADE CONSTRAINTS;

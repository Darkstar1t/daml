-- Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

---------------------------------------------------------------------------------------------------
-- V2: Contract divulgence
--
-- This schema version adds a table for tracking contract divulgence.
-- This is required for making sure contracts can only be fetched by parties that see the contract.
---------------------------------------------------------------------------------------------------


-- CREATE TABLE contract_divulgences_old
-- (
--     contract_id    NVARCHAR2(1000) references contracts (id)                  not null,
--     -- The party to which the given contract was divulged
--     party          NVARCHAR2(1000)                                            not null,
--     -- The offset at which the contract was divulged to the given party
--     ledger_offset  NUMBER references ledger_entries (ledger_offset)           not null,
--     -- The transaction ID at which the contract was divulged to the given party
--     transaction_id NVARCHAR2(1000) references ledger_entries (transaction_id) not null,
--
--     CONSTRAINT contract_divulgences_idx_old UNIQUE (contract_id, party)
-- );


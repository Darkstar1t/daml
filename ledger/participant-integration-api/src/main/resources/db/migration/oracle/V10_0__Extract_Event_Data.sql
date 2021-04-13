-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

---------------------------------------------------------------------------------------------------
-- V10.0: Extract event data
--
-- This schema version adds the tables contract_signatories and contract_observers, and the column contracts_create_event_id
-- to store event related data so that it can be easily retrieved later.

-- dropped by V30__

-- ALTER TABLE contracts
--     ADD create_event_id NVARCHAR2(1000);

-- dropped by V30__

-- CREATE TABLE contract_signatories
-- (
--     contract_id NVARCHAR2(1000) references contracts (id) not null,
--     signatory   NVARCHAR2(1000)                           not null
-- );
-- CREATE UNIQUE INDEX contract_signatories_idx
--     ON contract_signatories (contract_id, signatory);


-- dropped by V30__

-- CREATE TABLE contract_observers
-- (
--     contract_id NVARCHAR2(1000) references contracts (id) not null,
--     observer    NVARCHAR2(1000)                           not null
-- );
-- CREATE UNIQUE INDEX contract_observer_idx
--     ON contract_observers (contract_id, observer);

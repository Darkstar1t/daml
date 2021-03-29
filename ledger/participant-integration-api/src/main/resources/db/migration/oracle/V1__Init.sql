-- Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

-- Stores the history of the ledger -- mostly transactions. This table
-- is immutable in the sense that rows can never be modified, only
-- added.

-- subsequently dropped by V30__

-- custom array of varchar2 type used by several columns across tables
-- declaring upfront so this type is defined globally
create type VARCHAR_ARRAY as VARRAY (100) of VARCHAR2(1000);
/
CREATE TABLE parameters
-- this table is meant to have a single row storing all the parameters we have
(
    -- the generated or configured id identifying the ledger
    ledger_id                          NVARCHAR2(1000) not null,
    -- stores the head offset, meant to change with every new ledger entry
    ledger_end                         NUMBER          null,
    participant_id                     NVARCHAR2(1000),
    participant_pruned_up_to_inclusive BLOB,
    external_ledger_end                NVARCHAR2(1000),
    configuration                      BLOB
);

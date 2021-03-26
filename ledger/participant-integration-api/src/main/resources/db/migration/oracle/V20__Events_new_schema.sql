-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

create table participant_events
(
    event_id                 NVARCHAR2(1000) primary key not null,
    event_offset             NUMBER                      not null,
    contract_id              NVARCHAR2(1000)             not null,
    transaction_id           NVARCHAR2(1000)             not null,
    ledger_effective_time    TIMESTAMP                   not null,
    template_id              NVARCHAR2(1000)             not null,
    node_index               INTEGER                     not null, -- post-traversal order of an event within a transaction

    -- these fields can be null if the transaction originated in another participant
    command_id               NVARCHAR2(1000),
    workflow_id              NVARCHAR2(1000),                      -- null unless provided by a Ledger API call
    application_id           NVARCHAR2(1000),
    submitters               VARCHAR_ARRAY,

    -- non-null iff this event is a create
    create_argument          BLOB,
    create_signatories       VARCHAR_ARRAY,
    create_observers         VARCHAR_ARRAY,
    create_agreement_text    NVARCHAR2(1000),                      -- null if agreement text is not provided
    create_consumed_at       BLOB,                                 -- null if the contract created by this event is active
    create_key_value         BLOB,                                 -- null if the contract created by this event has no key

    -- non-null iff this event is an exercise
    exercise_consuming       NUMBER(1, 0),
    exercise_choice          NVARCHAR2(1000),
    exercise_argument        BLOB,
    exercise_result          BLOB,
    exercise_actors          VARCHAR_ARRAY,
    exercise_child_event_ids VARCHAR_ARRAY,                        -- event identifiers of consequences of this exercise

    flat_event_witnesses     VARCHAR_ARRAY               not null,
    tree_event_witnesses     VARCHAR_ARRAY               not null,

    -- cannot have index on binary field, adding hashed textual value to index on
    event_sequential_id      BLOB,
    event_sequential_id_hash VARCHAR2(4000)
);

-- support ordering by offset and transaction, ready for serving via the Ledger API
-- create index participant_events_offset_txn_node_idx on participant_events (event_offset, transaction_id, node_index);

-- support looking up a create event by the identifier of the contract it created, so that
-- consuming exercise events can use it to set the value of create_consumed_at
create index participant_events_contract_idx on participant_events (contract_id);

-- support requests of transactions by transaction_id
create index participant_events_transaction_idx on participant_events (ORA_HASH(transaction_id));

-- support filtering by template
create index participant_events_template_ids on participant_events (template_id);

-- 4. create a new index involving event_sequential_id
create index participant_events_event_sequential_id on participant_events (ORA_HASH(event_sequential_id));

-- 5. we need this index to convert event_offset to event_sequential_id
create index participant_events_event_offset on participant_events (event_offset);

-- TODO BH -- cannot create index on custom VARRAY fields
-- https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-INDEX.html#GUID-1F89BBC0-825F-4215-AF71-7588E31D8BFE
-- create index participant_events_flat_event_witnesses_idx on participant_events (flat_event_witnesses);
-- create index participant_events_tree_event_witnesses_idx on participant_events (tree_event_witnesses);

-- subset of witnesses to see the visibility in the flat transaction stream
-- create table participant_event_flat_transaction_witnesses
-- (
--     event_id      NVARCHAR2(1000) not null,
--     event_witness NVARCHAR2(1000) not null,
--
--     primary key (event_id, event_witness),
--     foreign key (event_id) references participant_events (event_id)
-- );
-- create index participant_event_flat_transaction_witnesses_event_idx on participant_event_flat_transaction_witnesses (event_id); -- join with events
-- create index participant_event_flat_transaction_witnesses_witness_idx on participant_event_flat_transaction_witnesses (event_witness);
-- filter by party

-- complement to participant_event_flat_transaction_witnesses to include
-- the visibility of events in the transaction trees stream
-- create table participant_event_witnesses_complement
-- (
--     event_id      NVARCHAR2(1000) not null,
--     event_witness NVARCHAR2(1000) not null,
--
--     foreign key (event_id) references participant_events (event_id)
-- );
-- create index participant_event_witnesses_complement_event_idx on participant_event_witnesses_complement (event_id); -- join with events
-- create index participant_event_witnesses_complement_witness_idx on participant_event_witnesses_complement (event_witness); -- filter by party

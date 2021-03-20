-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0


create type VARCHAR_ARRAY AS VARRAY(100) OF VARCHAR(1000);
/
-- contains all events for all transactions
create table participant_events
(
    event_id NVARCHAR2(1000) primary key not null,
    event_offset NUMBER not null,
    contract_id NVARCHAR2(1000) not null,
    transaction_id NVARCHAR2(1000) not null,
    ledger_effective_time timestamp not null,
    template_package_id NVARCHAR2(1000) not null,
    template_name NVARCHAR2(1000) not null,
    node_index int not null,                 -- post-traversal order of an event within a transaction
    is_root NUMBER(1,0) not null,

    -- these fields can be null if the transaction originated in another participant
    command_id NVARCHAR2(1000),
    workflow_id NVARCHAR2(1000),                     -- null unless provided by a Ledger API call
    application_id NVARCHAR2(1000),
    submitter NVARCHAR2(1000),

    -- non-null iff this event is a create
    create_argument BLOB,
    create_signatories NVARCHAR2(1000) array,
    create_observers NVARCHAR2(1000) array,
    create_agreement_text NVARCHAR2(1000),           -- null if agreement text is not provided
    create_consumed_at NVARCHAR2(1000),              -- null if the contract created by this event is active
    create_key_value BLOB,                  -- null if the contract created by this event has no key

    -- non-null iff this event is an exercise
    exercise_consuming boolean,
    exercise_choice NVARCHAR2(1000),
    exercise_argument BLOB,
    exercise_result BLOB,
    exercise_actors NVARCHAR2(1000)_ARRAY,
    exercise_child_event_ids NVARCHAR2(1000)_ARRAY   -- event identifiers of consequences of this exercise
);

-- support ordering by offset and transaction, ready for serving via the Ledger API
create index on participant_events(event_offset, transaction_id, node_index);

-- support looking up a create event by the identifier of the contract it created, so that
-- consuming exercise events can use it to set the value of create_consumed_at
create index on participant_events(contract_id);

-- support requests of transactions by transaction_id
create index on participant_events(transaction_id);

-- support filtering by template
create index on participant_events(template_name);

-- subset of witnesses to see the visibility in the flat transaction stream
create table participant_event_flat_transaction_witnesses
(
    event_id NVARCHAR2(1000) not null,
    event_witness NVARCHAR2(1000) not null,

    foreign key (event_id) references participant_events(event_id)
);
create index on participant_event_flat_transaction_witnesses(event_id);      -- join with events
create index on participant_event_flat_transaction_witnesses(event_witness); -- filter by party

-- complement to participant_event_flat_transaction_witnesses to include
-- the visibility of events in the transaction trees stream
create table participant_event_witnesses_complement
(
    event_id NVARCHAR2(1000) not null,
    event_witness NVARCHAR2(1000) not null,

    foreign key (event_id) references participant_events(event_id)
);
create index on participant_event_witnesses_complement(event_id);      -- join with events
create index on participant_event_witnesses_complement(event_witness); -- filter by party

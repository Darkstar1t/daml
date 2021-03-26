-- Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

-- Stores the history of the ledger -- mostly transactions. This table
-- is immutable in the sense that rows can never be modified, only
-- added.

-- dropped by V30__

-- CREATE TABLE ledger_entries
-- (
--     -- Every entry is indexed by a monotonically growing integer. That is,
--     -- new rows can only have a ledger_offet which is greater than the
--     -- larger ledger_offset in ledger_entries. However, note that there
--     -- might be gaps in the series formed by all the ledger_offsets in the
--     -- table.
--     ledger_offset         NUMBER primary key       not null,
--     -- one of 'transaction', 'rejection', or 'checkpoint' -- also see
--     -- check_entry below. note that we _could_ store the different entries
--     -- in different tables, but as of now we deem more convient having a
--     -- single table even if it imposes the constraint below, since this
--     -- table represents a single unified stream of events and partitioning
--     -- it across tables would be more inconvient. We might revise this in
--     -- the future.
--     typ                   NVARCHAR2(1000)          not null,
--     -- see ledger API definition for more infos on some of these these fields
--     transaction_id        NVARCHAR2(1000) unique,
--     command_id            NVARCHAR2(1000),
--     application_id        NVARCHAR2(1000),
--     submitter             NVARCHAR2(1000),
--     workflow_id           NVARCHAR2(1000),
--     effective_at          TIMESTAMP WITH TIME ZONE,
--     recorded_at           TIMESTAMP WITH TIME ZONE not null,
--     -- The transaction is stored using the .proto definition in
--     -- `daml-lf/transaction/src/main/protobuf/com/digitalasset/daml/lf/transaction.proto`, and
--     -- encoded using
--     -- `daml-lf/transaction/src/main/protobuf/com/digitalasset/daml/lf/transaction.proto`.
--     transaction           BLOB,
--     rejection_type        NVARCHAR2(1000),
--     rejection_description NVARCHAR2(1000),
--
--     -- note that this is not supposed to be a complete check, for example we do not check
--     -- that fields that are not supposed to be present are indeed null.
--     constraint check_entry
--         check (
--                 (typ = 'transaction' and transaction_id is not null and effective_at is not null and
--                  transaction is not null and (
--                          (submitter is null and application_id is null and command_id is null) or
--                          (submitter is not null and application_id is not null and command_id is not null)
--                      )) or
--                 (typ = 'rejection' and command_id is not null and application_id is not null and
--                  submitter is not null and
--                  rejection_type is not null and rejection_description is not null)
--             )
-- );
--
-- -- This embodies the deduplication in the Ledger API.
-- CREATE UNIQUE INDEX idx_transactions_deduplication
--     ON ledger_entries (command_id, application_id);

-- dropped by V30__

-- CREATE TABLE disclosures
-- (
--     transaction_id NVARCHAR2(1000) references ledger_entries (transaction_id) not null,
--     event_id       NVARCHAR2(1000)                                            not null,
--     party          NVARCHAR2(1000)                                            not null
-- );

-- Note that technically this information is all present in `ledger_entries`,
-- but we store it in this form since it would not be viable to traverse
-- the entries every time we need to gain information as a contract. It's essentially
-- a materialized view of the contracts state.

-- deleted by V30__

-- CREATE TABLE contracts
-- (
--     id             NVARCHAR2(1000) primary key                                not null,
--     -- this is the transaction id that _originated_ the contract.
--     transaction_id NVARCHAR2(1000) references ledger_entries (transaction_id) not null,
--     -- this is the workflow id of the transaction above. note that this is
--     -- a denormalization -- we could simply look up in the transaction table.
--     -- we cache it here since we do not want to risk impacting performance
--     -- by looking it up in `ledger_entries`, however we should verify this
--     -- claim.
--     workflow_id    NVARCHAR2(1000),
--     -- This tuple is currently included in `contract`, since we encode
--     -- the full value including all the identifiers. However we plan to
--     -- move to a more compact representation that would need a pointer to
--     -- the "top level" value type, and therefore we store the identifier
--     -- here separately.
--     package_id     NVARCHAR2(1000)                                            not null,
--     -- using the QualifiedName#toString format
--     name           NVARCHAR2(1000)                                            not null,
--     -- this is denormalized much like `transaction_id` -- see comment above.
--     create_offset  NUMBER                                                     not null,
--     -- this on the other hand _cannot_ be easily found out by looking into
--     -- `ledger_entries` -- you'd have to traverse from `create_offset` which
--     -- would be prohibitively expensive.
--     archive_offset NUMBER,
--     -- only present in contracts for templates that have a contract key definition.
--     -- encoded using the definition in
--     -- `daml-lf/transaction/src/main/protobuf/com/digitalasset/daml/lf/value.proto`.
--     key            BLOB,
--
--     CONSTRAINT contracts_create_offset_fkey foreign key (create_offset) references ledger_entries (ledger_offset),
--     CONSTRAINT contracts_archive_offset_fkey foreign key (archive_offset) references ledger_entries (ledger_offset)
--
-- );

-- These two indices below could be a source performance bottleneck. Every additional index slows
-- down insertion. The contracts table will grow endlessly and the sole purpose of these indices is
-- to make ACS queries performant, while sacrificing insertion speed.
-- CREATE INDEX idx_contract_create_offset
--     ON contracts (create_offset);
-- CREATE INDEX idx_contract_archive_offset
--     ON contracts (archive_offset);

-- TODO what's the difference between this and `diclosures`? If we can rely on `event_id`
-- being the `contract_id`, isn't `disclosures` enough?

-- dropped by V30__

-- CREATE TABLE contract_witnesses
-- (
--     contract_id NVARCHAR2(1000) references contracts (id) not null,
--     witness     NVARCHAR2(1000)                           not null
-- );
-- CREATE UNIQUE INDEX contract_witnesses_idx
--     ON contract_witnesses (contract_id, witness);

-- dropped by V30_
-- CREATE TABLE contract_key_maintainers
-- (
--     contract_id NVARCHAR2(1000) references contracts (id) not null,
--     maintainer  NVARCHAR2(1000)                           not null
-- );
--
-- CREATE UNIQUE INDEX contract_key_maintainers_idx
--     ON contract_key_maintainers (contract_id, maintainer);


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

-- table to store a mapping from (template_id, contract value) to contract_id
-- contract values are binary blobs of unbounded size, the table therefore only stores a hash of the value
-- and relies for the hash to be collision free

-- dropped by V30__

-- CREATE TABLE contract_keys
-- (
--     package_id  NVARCHAR2(1000)                           not null,
--     -- using the QualifiedName#toString format
--     name        NVARCHAR2(1000)                           not null,
--     -- stable SHA256 of the protobuf serialized key value, produced using
--     -- `KeyHasher.scala`.
--     value_hash  NVARCHAR2(1000)                           not null,
--     contract_id NVARCHAR2(1000) references contracts (id) not null,
--     PRIMARY KEY (package_id, name, value_hash)
-- );

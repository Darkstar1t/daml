-- Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

---------------------------------------------------------------------------------------------------
-- V13: party_entries
--
-- This schema version adds a table for tracking party allocation submissions
---------------------------------------------------------------------------------------------------

CREATE TABLE party_entries
(
    -- The ledger end at the time when the party allocation was added
    ledger_offset    BLOB primary key not null,
    recorded_at      timestamp        not null, --with timezone
    -- SubmissionId for the party allocation
    submission_id    NVARCHAR2(1000),
    -- participant id that initiated the allocation request
    -- may be null for implicit party that has not yet been allocated
    participant_id   NVARCHAR2(1000),
    -- party
    party            NVARCHAR2(1000),
    -- displayName
    display_name     NVARCHAR2(1000),
    -- The type of entry, 'accept' or 'reject'
    typ              NVARCHAR2(1000)  not null,
    -- If the type is 'reject', then the rejection reason is set.
    -- Rejection reason is a human-readable description why the change was rejected.
    rejection_reason NVARCHAR2(1000),
    -- true if the party was added on participantId node that owns the party
    is_local         NUMBER(1, 0),

    constraint check_party_entry_type
        check (
                (typ = 'accept' and rejection_reason is null and party is not null) or
                (typ = 'reject' and rejection_reason is not null)
            )
);

-- Index for retrieving the party allocation entry by submission id per participant
CREATE UNIQUE INDEX idx_party_entries
    ON party_entries (submission_id)
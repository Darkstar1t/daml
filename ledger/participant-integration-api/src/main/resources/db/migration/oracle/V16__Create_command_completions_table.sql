-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

CREATE TABLE participant_command_completions
(
    completion_offset NUMBER    not null,
    record_time       timestamp not null,

    application_id    NVARCHAR2(1000), -- null for checkpoints
    submitting_party  NVARCHAR2(1000), -- null for checkpoints
    command_id        NVARCHAR2(1000), -- null for checkpoints

    transaction_id    NVARCHAR2(1000), -- null if the command was rejected and checkpoints
    status_code       integer,         -- null for successful command and checkpoints
    status_message    NVARCHAR2(1000)  -- null for successful command and checkpoints
);

CREATE INDEX ON participant_command_completions(completion_offset, application_id, submitting_party);

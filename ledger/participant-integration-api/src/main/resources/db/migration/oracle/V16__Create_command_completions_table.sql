-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

CREATE TABLE participant_command_completions
(
    completion_offset NUMBER          not null,
    record_time       TIMESTAMP       not null,

    application_id    NVARCHAR2(1000) not null, -- null for checkpoints
    submitters        VARCHAR_ARRAY   not null, -- null for checkpoints
    command_id        NVARCHAR2(1000) not null, -- null for checkpoints

    transaction_id    NVARCHAR2(1000),          -- null if the command was rejected and checkpoints
    status_code       INTEGER,                  -- null for successful command and checkpoints
    status_message    NVARCHAR2(1000)           -- null for successful command and checkpoints
);

-- TODO BH: submitters cannot be part of the array because it is a custom user-defined type
CREATE INDEX participant_command_completions_idx ON participant_command_completions (completion_offset, application_id);

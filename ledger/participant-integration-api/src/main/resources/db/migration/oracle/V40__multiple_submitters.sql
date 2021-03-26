-- Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

-- V20__
-- alter table participant_events
--     modify submitter VARCHAR_ARRAY;
-- alter table participant_events
--     rename column submitter to submitters;

-- V16__
-- alter table participant_command_completions
--     modify submitting_party VARCHAR_ARRAY;
-- alter table participant_command_completions
--     rename column submitting_party to submitters;

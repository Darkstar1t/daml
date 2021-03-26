-- Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

---------------------------------------------------------------------------------------------------
-- V30: Drop old schema
--
-- Also removes checkpoints as part of the data migration, if there are any still lingering around.
--
---------------------------------------------------------------------------------------------------

-- drop table contracts cascade constraints;
-- drop table contract_data cascade constraints;
-- drop table contract_divulgences cascade constraints;
-- drop table contract_keys cascade constraints;
-- drop table contract_key_maintainers cascade constraints;
-- drop table contract_observers cascade constraints;
-- drop table contract_signatories cascade constraints;
-- drop table contract_witnesses cascade constraints;
-- drop table disclosures cascade constraints;
-- drop table ledger_entries cascade constraints;

-- delete from participant_command_completions where application_id is null and submitting_party is null;

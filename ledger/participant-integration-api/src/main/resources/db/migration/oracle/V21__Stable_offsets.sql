-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

---------------------------------------------------------------------------------------------------
-- V21: Stable Offsets
--
-- Stable offsets are stored as BLOB and can be sorted lexicographically.
---------------------------------------------------------------------------------------------------

ALTER TABLE parameters MODIFY ledger_end NULL;

ALTER TABLE contract_divulgences
    DROP CONSTRAINT contract_divulgences_offset_key;
ALTER TABLE contracts
    DROP CONSTRAINT contracts_create_offset_fkey;
ALTER TABLE contracts
    DROP CONSTRAINT contracts_archive_offset_fkey;

-- blob is problematic for ledger_offset because this is a primary key for many tables
-- update CONFIGURATION_ENTRIES SET
--                                  LEDGER_OFFSET = REPLACE(LEDGER_OFFSET, decode(lpad(rawtohex(ledger_offset), 16, '0'), 'hex'));
-- ALTER TABLE configuration_entries MODIFY ledger_offset BLOB;
-- ALTER TABLE contract_divulgences MODIFY ledger_offset BLOB;
-- ALTER TABLE contracts MODIFY create_offset BLOB;
-- ALTER TABLE contracts MODIFY archive_offset BLOB;
-- ALTER TABLE ledger_entries MODIFY ledger_offset BLOB;
-- ALTER TABLE packages MODIFY ledger_offset BLOB;
-- ALTER TABLE package_entries MODIFY ledger_offset BLOB;
-- ALTER TABLE parameters MODIFY ledger_end BLOB;
-- ALTER TABLE participant_command_completions MODIFY completion_offset BLOB;
-- ALTER TABLE participant_events MODIFY event_offset BLOB;
-- ALTER TABLE parties MODIFY ledger_offset BLOB;
-- ALTER TABLE party_entries MODIFY ledger_offset BLOB;

ALTER TABLE contract_divulgences
    add foreign key (ledger_offset) references ledger_entries (ledger_offset);
ALTER TABLE contracts
    add foreign key (create_offset) references ledger_entries (ledger_offset);
ALTER TABLE contracts
    add foreign key (archive_offset) references ledger_entries (ledger_offset);

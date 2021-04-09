-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

---------------------------------------------------------------------------------------------------
-- V30: Package Entries Hex column
--
-- For cross database compatibility, store hex version of Stable offsets
-- which can be used as primary key and can be sorted lexicographically.
---------------------------------------------------------------------------------------------------

ALTER TABLE package_entries DROP CONSTRAINT package_entries_pkey;
ALTER TABLE package_entries ADD COLUMN ledger_offset_hex varchar;
UPDATE package_entries set ledger_offset_hex = encode(ledger_offset, 'hex');
ALTER TABLE package_entries ALTER COLUMN ledger_offset_hex SET not null;
ALTER TABLE package_entries
    ADD CONSTRAINT package_entries_pk PRIMARY KEY (ledger_offset_hex);

ALTER TABLE party_entries DROP CONSTRAINT party_entries_pkey;
ALTER TABLE party_entries ADD COLUMN ledger_offset_hex varchar;
UPDATE party_entries set ledger_offset_hex = encode(ledger_offset, 'hex');
ALTER TABLE party_entries ALTER COLUMN ledger_offset_hex SET not null;
ALTER TABLE party_entries
    ADD CONSTRAINT party_entries_pk PRIMARY KEY (ledger_offset_hex);

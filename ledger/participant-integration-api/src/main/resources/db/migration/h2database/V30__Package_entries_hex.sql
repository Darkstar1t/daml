-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

---------------------------------------------------------------------------------------------------
-- V30: Package Entries Hex column
--
-- For cross database compatibility, store hex version of Stable offsets
-- which can be used as primary key and can be sorted lexicographically.
---------------------------------------------------------------------------------------------------

ALTER TABLE package_entries ADD COLUMN ledger_offset_hex varchar;
-- ALTER TABLE party_entries ADD COLUMN ledger_offset_hex TYPE BINARY;
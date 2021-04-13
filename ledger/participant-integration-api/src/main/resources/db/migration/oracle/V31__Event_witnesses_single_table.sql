-- Copyright (c) 2019 The DAML Authors. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

-- create table participant_event_transaction_tree_witnesses
-- (
--     event_id NVARCHAR2(1000) not null,
--     event_witness NVARCHAR2(1000) not null,
--
--     primary key (event_id, event_witness),
--     foreign key (event_id) references participant_events(event_id)
-- );

-- insert into participant_event_transaction_tree_witnesses
--     select event_id, event_witness from participant_event_flat_transaction_witnesses
--     union
--     select event_id, event_witness from participant_event_witnesses_complement;

-- drop index participant_event_flat_transaction_witnesses_event_id_idx;
-- drop index participant_event_flat_transaction_witnesses_event_witness_idx;

-- alter table participant_event_flat_transaction_witnesses add primary key (event_id, event_witness);

-- dropped in V20__Events_new_schema.sql
-- drop table participant_event_witnesses_complement cascade constraints;
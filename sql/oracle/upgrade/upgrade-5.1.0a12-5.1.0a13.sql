prompt Ignore nonexistent constraint error...
alter table fs_rss_subscrs drop constraint fs_rss_subscrs_fk;
prompt Okay, stop ignoring errors below here.

alter table fs_rss_subscrs add constraint fs_rss_subscrs_fk
                              foreign key (subscr_id)
                              references rss_gen_subscrs (subscr_id)
                              on delete cascade;

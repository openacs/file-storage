-- @author Andrew Grumet (aegrumet@alum.mit.edu)
-- @creation-date 7 Dec 2004

-- RSS feeds are assigned on a per-folder basis.  fs_rss_subscrs is an
-- extension table for rss_gen_subscrs, storing additional parameters
-- governing how the RSS feed for each folder will be generated.
create table fs_rss_subscrs (
    subscr_id                     integer
                                  constraint fs_rss_subscrs_pk
                                  primary key
                                  constraint fs_rss_subscrs_fk
                                  references rss_gen_subscrs(subscr_id)
                                  on delete cascade,
    folder_id                     integer
                                  constraint fs_rss_subscrs_fldr_nn
                                  not null
                                  constraint fs_rss_subscrs_fldr_fk
                                  references cr_folders(folder_id),
    -- To be displayed next to the XML button on the folder view page.
    short_name                    varchar(80)
                                  constraint fs_rss_subscrs_short_nn
                                  not null,
    feed_title                    varchar(200)
                                  constraint fs_rss_subscrs_title_nn
                                  not null,
    max_items                     integer default 15
                                  constraint fs_rss_subscrs_mx_nn
                                  not null,
    descend_p                     char(1) default 't'
                                  constraint fs_rss_subscrs_desc_nn
                                  not null
                                  constraint fs_rss_subscrs_desc_ck
                                  check (descend_p in ('t','f')),
    include_revisions_p           char(1) default 'f'
                                  constraint fs_rss_subscrs_incl_nn
                                  not null
                                  constraint fs_rss_subscrs_incl_ck
                                  check (include_revisions_p in ('t','f')),
    -- Add an enclosure if the filename matches one of these patterns.
    -- Leave empty for no enclosures, set to * for all files.
    enclosure_match_patterns      varchar(200)
);

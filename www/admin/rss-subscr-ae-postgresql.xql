<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="create_subscr">
    <querytext>
        declare
          v_subscr_id integer;
        begin

          v_subscr_id := rss_gen_subscr__new (
            null,                         -- p_subscr_id
            acs_sc_impl__get_id('RssGenerationSubscriber','fs_rss'),
                                          -- p_impl_id  
            null,                         -- p_summary_context_id
            86400,                        -- p_timeout
            null,                         -- p_lastbuild
            'rss_gen_subscr',             -- object_type
            now(),                        -- creation_date
            :user_id,                     -- p_creation_user
            :peeraddr,                    -- p_creation_ip
            :folder_id                    -- p_context_id
          );

          insert into fs_rss_subscrs (subscr_id,folder_id,short_name,
            feed_title,max_items,descend_p,include_revisions_p,
            enclosure_match_patterns)
          values (v_subscr_id,:folder_id,:short_name,:feed_title,:max_items,
            :descend_p,:include_revisions_p,:enclosure_match_patterns);

          return v_subscr_id;

        end;
    </querytext>
  </fullquery>

</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="create_subscr">
    <querytext>
        begin

          :1 := rss_gen_subscr.new (
            p_subscr_id => null,
            p_impl_id => :fs_rss_impl_id,
            p_summary_context_id => null,
            p_timeout => 86400,
            p_lastbuild => sysdate,
            p_context_id => :folder_id,
            p_creation_user => :user_id,
            p_creation_ip => :peeraddr
          );

          insert into fs_rss_subscrs (subscr_id,folder_id,short_name,
            feed_title,max_items,descend_p,include_revisions_p,
            enclosure_match_patterns)
          values (:1,:folder_id,:short_name,:feed_title,:max_items,
            :descend_p,:include_revisions_p,:enclosure_match_patterns);

        end;
    </querytext>
  </fullquery>

</queryset>

<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="delete_subscr">
    <querytext>
      begin	
        delete from fs_rss_subscrs where subscr_id = :subscr_id;
        return rss_gen_subscr__delete(:subscr_id);
      end;
    </querytext>
  </fullquery>

</queryset>

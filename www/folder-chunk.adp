<if @categories_p@><if @category_links@><p>#file-storage.Categories#: @category_links;noquote@</p></if></if>

<listtemplate name="contents"></listtemplate>

  <if @content_size_total@ gt 0>
    <p>
      <a href="@compressed_url@" title="#file-storage.lt_Download_an_archive_o#">
        #file-storage.lt_Download_an_archive_o#
      </a>
      <br>
      <small><i>#file-storage.this_may_take_a_while#</i></small>
    </p>
  </if>

<if @feeds:rowcount@ not nil and @feeds:rowcount@ gt 0>
<multiple name="feeds">
<a href="rss/@feeds.subscr_id@/rss.xml"><img src="/resources/acs-subsite/xml.gif" width="36" height="14" style="border: 0;"></a> <a href="rss/@feeds.subscr_id@/rss.xml">@feeds.short_name@</a><br>
</multiple>
</if>

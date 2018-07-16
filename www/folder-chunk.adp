<if @categories_p;literal@ true>
  <if @category_links@ ne "">
    <p>#file-storage.Categories#: @category_links;noquote@</p>
  </if>
</if>

<listtemplate name="contents_@folder_id;literal@"></listtemplate>

<if @content_size_total@ gt 0>
  <p>
    <a href="@compressed_url@" title="#file-storage.lt_Download_an_archive_o#">
      #file-storage.lt_Download_an_archive_o#
    </a>
    <br>
    <em>#file-storage.this_may_take_a_while#</em>
  </p>
</if>

<if @feeds:rowcount@ not nil and @feeds:rowcount@ gt 0>
  <ul>
    <multiple name="feeds">
      <li><a href="rss/@feeds.subscr_id@/rss.xml"><img src="/resources/acs-subsite/xml.gif" width="36" height="14" alt="RSS feed" style="border: 0; padding: 0px 5px;">@feeds.short_name@</a></li>
    </multiple>
  </ul>
</if>

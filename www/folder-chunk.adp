<listtemplate name="contents"></listtemplate>

  <if @content_size_total@ gt 0>
    <p>
      <a href="@fs_url@download-archive/index?object_id=@folder_id@">
        #file-storage.lt_Download_an_archive_o#
      </a>
      <br>
      <small><i>#file-storage.this_may_take_a_while#</i></small>
    </p>
  </if>
</if>


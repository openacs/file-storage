<if @contents:rowcount@ gt 0>
  <table width="85%" cellpadding="5" cellspacing="5">
    <tr>
      <td>&nbsp;</td>
      <td>Name</td>
      <td>Action</td>
      <td>Size</td>
      <td>Type</td>
      <td>Last Modified</td>
    </tr>
<multiple name="contents">
    <tr>
<if @contents.type@ eq "Folder">
      <td><img src="graphics/folder.gif"></td>
      <td>
        <a href="index?folder_id=@contents.object_id@&n_past_days=@n_past_days@">@contents.name@</a>
<if @contents.new_p@ and @contents.content_size@ gt 0>(&nbsp;new&nbsp;)</if>
      </td>
      <td>&nbsp;</td>
      <td>
        @contents.content_size@ item<if @contents.content_size@ ne 1>s</if>
      </td>
      <td>@contents.type@</td>
      <td>@contents.last_modified@</td>
</if>
<else>
<if @contents.type@ eq "URL">
      <td><img src="graphics/file.gif"></td>
      <td>
      <a href="url-goto?url_id=@contents.object_id@">@contents.name@</a>
<if @contents.new_p@>(&nbsp;new&nbsp;)</if>
      </td>
      <td>
        <small>[
<if @contents.write_p@ or @contents.admin_p@>
          <a href="simple-edit?object_id=@contents.object_id@">
            edit
          </a>
</if>
<if @contents.delete_p@ or @contents.admin_p@>
          |
          <a href="simple-delete?folder_id=@folder_id@&object_id=@contents.object_id@">
            delete
          </a>
</if>
          ]</small>
      </td>
      <td>&nbsp;</td>
      <td>@contents.type@</td>
      <td>@contents.last_modified@</td>
</if>
<else>
      <td><img src="graphics/file.gif"></td>
      <td>
        <a href="download/index?version_id=@contents.live_revision@">
          @contents.name@
        </a>
<if @contents.new_p@>
        (&nbsp;new&nbsp;)
</if>
      </td>
      <td>
        <small>[
          <a href="file?file_id=@contents.object_id@">
            view details
          </a>
        ]</small>
      </td>
      <td>@contents.content_size@ byte<if @contents.content_size@ ne 1>s</if></td>
      <td>@contents.type@</td>
      <td>@contents.last_modified@</td>
</else>
</else>
    </tr>
</multiple>
  </table>
</if>
<else>
  <p><blockquote><i>Folder @folder_name@ is empty</i></blockquote></p>
</else>

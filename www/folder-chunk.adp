<if @contents:rowcount@ gt 0>
  <table width="85%" class="table-display" cellpadding="5" cellspacing="0">
    <tr class="table-header">
      <td>&nbsp;</td>
      <td>#file-storage.Name#</td>
      <td>#file-storage.Action#</td>
      <td>#file-storage.Size#</td>
      <td>#file-storage.Type#</td>
      <td>#file-storage.Last_Modified#</td>
    </tr>
<multiple name="contents">
<if @contents.rownum@ odd>
    <tr class="odd">
</if>
<else>
    <tr class="even">
</else>
<if @contents.type@ eq "folder">
      <td><a href="@fs_url@index?folder_id=@contents.object_id@&n_past_days=@n_past_days@"><img src="graphics/folder.gif" border=0 alt="#file-storage.folder#"></a></td>
      <td>
        <a href="@fs_url@index?folder_id=@contents.object_id@&n_past_days=@n_past_days@"><%= [lang::util::localize @contents.name@] %></a>
<if @contents.new_p@ and @contents.content_size@ gt 0><font color="red">#file-storage.new#</font></if>
      </td>
      <td>&nbsp;</td>
      <td>
        @contents.content_size_pretty@ <if @contents.content_size@ ne 1>#file-storage.items#</if><else>#file-storage.item#</else>
      </td>
      <td>#file-storage.folder#</td>
      <td>@contents.last_modified@</td>
</if>
<else>
<if @contents.type@ eq "url">
      <td><a href="@fs_url@url-goto?url_id=@contents.object_id@"><img src="graphics/file.gif" alt="#file-storage.file#" border=0></a></td>
      <td>
      <a href="@fs_url@url-goto?url_id=@contents.object_id@">@contents.name@</a>
<if @contents.new_p@><font color="red">#file-storage.new#</font></if>
      </td>
      <td>
        <small>
<if @contents.write_p@ or @contents.admin_p@>
          [<a href="@fs_url@simple-edit?object_id=@contents.object_id@">
            #file-storage.edit#
          </a>
</if>
<if @contents.delete_p@ or @contents.admin_p@>
          |
          <a href="@fs_url@simple-delete?folder_id=@folder_id@&object_id=@contents.object_id@">
            #file-storage.delete#
          </a>
</if>
<if @contents.write_p@ or @contents.delete_p@ or @contents.admin_p@>
           ]
</if>
        </small>
      </td>
      <td>&nbsp;</td>
      <td>@contents.type@ </td>
      <td>@contents.last_modified@</td>
</if>
<else>
      <td><a href="@fs_url@download/@contents.file_upload_name@?version_id=@contents.live_revision@"><img src="graphics/file.gif" alt="#file-storage.file#" border="0"></a></td>
      <td>
        <a href="@fs_url@download/@contents.file_upload_name@?version_id=@contents.live_revision@">
          @contents.name@
        </a>
<if @contents.new_p@>
        <font color="red">#file-storage.new#</font>
</if>
      </td>
      <td>
        <small>[
          <a href="@fs_url@file?file_id=@contents.object_id@">
            #file-storage.view_details#
          </a>
        ]</small>
      </td>
      <td>@contents.content_size_pretty@ byte<if @contents.content_size@ ne 1>s</if></td>
      <td>@contents.type@</td>
      <td>@contents.last_modified@</td>
</else>
</else>
    </tr>
    </multiple>
  </table>
</if>
<else>
  <p><blockquote><i>#file-storage.lt_Folder_folder_name_is#</i></blockquote></p>
</else>

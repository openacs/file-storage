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
        <a href="index?folder_id=@contents.file_id@">@contents.name@</a>
<if @contents.new_p@>( new )</if>
      </td>
      <td>&nbsp;</td>
      <td>
        @contents.content_size@ item<if @contents.content_size@ ne 1>s</if>
      </td>
      <td>Folder</td>
      <td>@contents.last_modified@</td>
</if>
<else>
      <td><img src="graphics/file.gif"></td>
      <td>
      <if @contents.versioned_p@ eq t><a href="file?file_id=@contents.file_id@">@contents.name@</a></if><else>@contents.name@</else>
<if @contents.new_p@>( new )</if>
      </td>
      <td>
        [<small><if @contents.url_p@ eq t><a href=url-goto?url_id=@contents.file_id@>go to</a><if @contents.write_p@ eq 1>&nbsp;|&nbsp;<a href="simple-edit?object_id=@contents.file_id@">edit</a></if></if><else><a href="download/index?version_id=@contents.live_revision@">download</a></else><if @contents.delete_p@ eq 1 or @contents.admin_p@ eq 1>&nbsp;|&nbsp;<a href="<if @contents.versioned_p@ eq t>file-delete?file_id=@contents.file_id@</if><else>simple-delete?folder_id=@folder_id@&object_id=@contents.file_id@</else>">delete</a></if>]</td>
      <td>@contents.content_size@ byte<if @contents.content_size@ ne 1>s</if></td>
      <td>@contents.type@</td>
      <td>@contents.last_modified@</td>
</else>
  </tr>
</multiple>
  </table>
</if>
<else>
  <p><blockquote><i>Folder @folder_name@ is empty</i></blockquote></p>
</else>

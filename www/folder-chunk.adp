<if @contents:rowcount@ gt 0>
  <table width="85%" cellpadding="5" cellspacing="5">
    <tr>
      <td>&nbsp;</td>
      <td>Name</td>
      <td>Action</td>
      <td>Size (bytes)</td>
      <td>Type</td>
      <td>Last Modified</td>
    </tr>
<multiple name="contents">
    <tr>
<if @contents.type@ eq "Folder">
      <td><img src="graphics/folder.gif"></td>
      <td><a href="index?folder_id=@contents.file_id@">@contents.name@</a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>Folder</td>
      <td>&nbsp;</td>
</if>
<else>
      <td><img src="graphics/file.gif"></td>
      <td><a href="file?file_id=@contents.file_id@">@contents.name@</a></td>
      <td><a href="download/index?version_id=@contents.live_revision@">(download)</a></td>
      <td>@contents.content_size@</td>
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

<master src="fs_master">
<property name="title">@folder_name@</property>
<property name="header">@folder_name@</property>
<property name="context_bar">@context_bar@</property>

<ul>
<if @write_p@ eq 1>
  <li><a href="file-add?folder_id=@folder_id@">Upload a file</a>
  <li><a href="folder-create?parent_id=@folder_id@">Create a new
  folder</a>
</if>
<p>
<if @admin_p@ eq 1>
  <li><a href="/permissions/one?object_id=@folder_id@">Modify
  permissions on this folder</a>
</if>
<p>
<if @delete_p@ eq 1 and @nonroot_folder_p@ ne 0  and @file:rowcount@ eq 0>
  <li><a href="folder-delete?folder_id=@folder_id@">Delete this folder</a>
</if>
</ul>

<form method=POST action="search">
Search file names for
<input type=text size=30 name=query>
</form>

<table border=1 cellpadding=2 cellspacing=2>
 <tr>
  <td bgcolor=#cccccc>Name</td>
  <td bgcolor=#cccccc>Action</td>
  <td bgcolor=#cccccc>Size (bytes)</td>
  <td bgcolor=#cccccc>Type</td>
  <td bgcolor=#cccccc>Modified</td>
 </tr>

<multiple name="file">
 <tr>
  <if @file.type@ eq "Folder">
   <td><img src="graphics/folder.gif"><a href="?folder_id=@file.file_id@">@file.name@</a></td>
   <td>&nbsp;</td>
   <td>&nbsp;</td>
   <td>File Folder</td>
   <td>&nbsp;</td>
  </if><else>
   <td><img src="graphics/file.gif"><a href="file?file_id=@file.file_id@">@file.name@</a></td>
   <td><a href="download/@file.path@?version_id=@file.live_revision@">(download)</a></td>
   <td align=right>@file.content_size@</td>
   <td>@file.type@</td>
   <td>@file.last_modified@</td>
  </else>
 </tr>
</multiple>

<if @file:rowcount@ eq 0>
 <tr>
  <td colspan=5><i>There are no items in this folder</i></td>
 </tr>
</if>
</table>

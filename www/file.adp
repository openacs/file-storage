<master src="fs_master">
<property name="title">@title@</property>
<property name="header">@title@</property>
<property name="context_bar">@context_bar@</property>

<ul>
  <li>Title: @title@ <if @write_p@ eq "t">(<a href="file-edit?file_id=@file_id@">edit</a>)</if>
  <li>Owner: @owner@
<p>
  <li>Actions: 
  <if @show_all_versions_p@ eq "t">
    <a href="file?file_id=@file_id@&show_all_versions_p=f">show only
    live version</a>
  </if>
  <else>
    <a href="file?file_id=@file_id@&show_all_versions_p=t">show all
    versions</a>
  </else>
  <if @write_p@ eq "t">
  | <a href="version-add?file_id=@file_id@">Upload a new version</a>
  </if>
  | <a href="file-copy?file_id=@file_id@">Copy</a>
  <if @write_p@ eq "t">
  | <a href="file-move?file_id=@file_id@">Move</a>
  </if>
  <if @admin_p@ eq "t">
  | <a href="/permissions/one?object_id=@file_id@">Modify permissions
  on this file</a>
  </if>
  <if @delete_p@ eq "t">
  | <a href="file-delete?file_id=@file_id@">Delete this file (including all versions)</a>
  </if>
</ul>

<table border=1 cellspacing=2 cellpadding=2>
 <tr>
  <td colspan=7><if @show_all_versions_p@ eq "t">All Versions of "@title@"</if>
   <else>Live version of "@title@"</else>.</td>
 </tr>
 <tr>
  <td>Version filename</td>
  <td>Author</td>
  <td>Size (bytes)</td>
  <td>Type</td>
  <td>Modified</td>
  <td>Version Notes</td>
  <td>Actions</td>
 </tr>

<multiple name=version>
 <tr>
  <td><img src="graphics/file.gif"><a href="download/@version.file_path@?version_id=@version.version_id@">@version.title@</a></td>
  <td>@version.author@</td>
  <td align=right>@version.content_size@</td>
  <td>@version.type@</td>
  <td>@version.last_modified@</td>
  <td>@version.description@</td>
  <td>&nbsp;<if @version.delete_p@ eq "t">
      <a href="version-delete?version_id=@version.version_id@">delete</a> 
       <if @version.admin_p@ eq "t">|</if>
      </if>
      <if @version.admin_p@ eq "t">
      <a
      href="/permissions/one?object_id=@version.version_id@">administrate
      permissions</a>
      </if>
  </td>
 </tr>
</multiple>

<if @version:rowcount@ eq 0>
 <tr>
  <td colspan=7><i>There are no versions of this file availible to you</i></td>
 </tr>
</if>
</table>

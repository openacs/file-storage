<master src="fs_master">
<property name="title">@folder_name@</property>
<property name="header">@folder_name@</property>
<property name="context_bar">@context_bar@</property>

<table>
<if @write_p@ true>
  <tr>
    <td width="5%"><li></td>
    <td>
      <a href="file-add?folder_id=@folder_id@">Upload a file</a>
      &nbsp;&nbsp;|&nbsp;&nbsp;
      <a href="simple-add?folder_id=@folder_id@">Create a URL</a>
    </td>
  </tr>
  <tr>
    <td><li></td>
    <td><a href="folder-create?parent_id=@folder_id@">Create a new folder</a></td>
  </tr>
</if>
<if @admin_p@ true and @show_administer_permissions_link_p@ true>
  <tr><td colspan="2"><br></td></tr>
  <tr>
    <td><li></td>
    <td>
      <a href="/permissions/one?object_id=@folder_id@">
        Modify permissions on this folder
      </a>
    </td>
  </tr>
</if>
<if @delete_p@ true and @root_folder_p@ false and @n_contents@ eq 0>
  <tr><td colspan="2"><br></td></tr>
  <tr>
    <td><li></td>
    <td>
      <a href="folder-delete?folder_id=@folder_id@">Delete this folder</a>
    </td>
  </tr>
</if>
<if @n_contents@ gt 0>
  <tr><td colspan="2"><br></td></tr>
  <tr>
    <td><li></td>
    <td>
      <a href="download-archive/index?object_id=@folder_id@">
        Download an archive of the contents of this folder
      </a>
      <br>
      <small><i><strong>Note:</strong> This may take a while, please be patient.</i></small>
    </td>
  </tr>
</if>
  <tr><td colspan="2"><br></td></tr>
  <tr>
    <td><li></td>
    <td>
<formtemplate id="n_past_days_form">
      Show files modified in the past <formwidget id="n_past_days"> days as new.
</formtemplate>
    </td>
  </tr>
</table>

<form method="post" action="search">
  Search file names for
  <input type="text" size="30" name="query">
</form>

<include src="folder-chunk" folder_id=@folder_id@ viewing_user_id=@user_id@ n_past_days=@n_past_days@>

<master>
<property name="title">@folder_name@</property>
<property name="header">@folder_name@</property>
<property name="context">@context@</property>

<table width="100%">
<if @write_p@ true>
  <tr>
    <td colspan=2>
      <a href="file-add?folder_id=@folder_id@">Upload a file</a>
      &nbsp;&nbsp;|&nbsp;&nbsp;
      <a href="simple-add?folder_id=@folder_id@">Create a URL</a>
      &nbsp;&nbsp;|&nbsp;&nbsp;
	<a href="folder-create?parent_id=@folder_id@">Create a new folder</a>
<if @admin_p@ true and @root_folder_p@ false>
      &nbsp;&nbsp;|&nbsp;&nbsp;
      <a href="folder-edit?folder_id=@folder_id@">Rename this folder</a>
</if>
<if @delete_p@ true and @root_folder_p@ false and @n_contents@ eq 0>
      &nbsp;&nbsp;|&nbsp;&nbsp;
      <a href="folder-delete?folder_id=@folder_id@">Delete this folder</a>
</if>
</td><td>
<formtemplate id="n_past_days_form">
      Show files modified in the past <formwidget id="n_past_days"> days as new.
</formtemplate>

</td></tr>
<if @admin_p@ true and @show_administer_permissions_link_p@ true>
  <tr><td colspan="2"><br></td></tr>
  <tr>
    <td colspan=2>
      <a href="/permissions/one?object_id=@folder_id@">
        Modify permissions on this folder
      </a>
    </td>
  </tr>
</if>
</if>
  <tr><td colspan="2"><br></td></tr>
  <tr>
    <td>
    </td>
  </tr>
</table>


<include src="folder-chunk" folder_id=@folder_id@ viewing_user_id=@user_id@ n_past_days=@n_past_days@>




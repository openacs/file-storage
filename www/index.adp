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
<if @delete_p@ eq 1 and @nonroot_folder_p@ ne 0 and @n_contents@ eq 0>
  <li><a href="folder-delete?folder_id=@folder_id@">Delete this folder</a>
</if>
</ul>

<form method=POST action="search">
Search file names for
<input type=text size=30 name=query>
</form>

<include src="folder-chunk" folder_id=@folder_id@ viewing_user_id=@user_id@></include>

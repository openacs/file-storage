<master src="fs_master">
<property name="title">Delete @folder_name@</property>
<property name="context_bar">@context_bar@</property>

<if @blocked_p@ eq "t">

<p>This folder contains items that you do not have permission to
delete, therefore you cannot delete it.

</if>
<else>

<form method=POST action=folder-delete>
<input type=hidden name=folder_id value=@folder_id@>
<input type=hidden name=confirmed_p value="t">

<p>Are you sure you want to delete the folder "@folder_name@" and all
the items it contains?  This action cannot be reversed.

<p>
<center>
<input type=submit value="Yes, Delete It">
</center>

</form>

</else>
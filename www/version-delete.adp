<master src="fs_master">
<property name="title">Delete @version_name@</property>
<property name="context_bar">@context_bar@</property>

<form method=POST action=version-delete>
<input type=hidden name=version_id value=@version_id@>
<input type=hidden name=confirmed_p value="t">

<p>Are you sure that you want to delete this version "@version_name@" of "@title@"?
This action cannot be reversed.
<p>
<center>
<input type=submit value="Yes, Delete It">
</center>

</form>




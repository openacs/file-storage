<master src="master">
<property name="title">Delete @title@</property>
<property name="context">@context@</property>

<if @blocked_p@ eq "t">

<p>This file has versions that you do not have permission to delete,
so you cannot delete the file.

</if>
<else>

<form method=POST action=file-delete>
<input type=hidden name=file_id value=@file_id@>
<input type=hidden name=confirmed_p value="t">

<p>Are you sure you want to delete the file "@title@" and all of
its versions?  This action cannot be reversed.

<p>
<center>
<input type=submit value="Yes, Delete It">
</center>
</form>

</else>

<master src="master">
<property name="title">Rename @title@</property>
<property name="header">Rename @title@</property>
<property name="context">@context@</property>

<form method=POST action=file-edit-2.tcl>
<input type=hidden name="file_id" value="@file_id@">

<p>Please enter the new name for this file:

<p><input type=text name="title" value="@title@" size=30>

<p><input type=submit value="Change Name">

</form>

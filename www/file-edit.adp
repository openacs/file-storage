<master>
<property name="title">Rename @title;noquote@</property>
<property name="header">Rename @title;noquote@</property>
<property name="context">@context;noquote@</property>

<form method=POST action=file-edit-2.tcl>
<input type=hidden name="file_id" value="@file_id@">

<p>#file-storage.lt_Please_enter_the_new_#

<p><input type=text name="title" value="@title@" size=30>

<p><input type=submit value="#file-storage.Change_Name#">

</form>



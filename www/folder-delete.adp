<master>
<property name="title">Delete @folder_name;noquote@</property>
<property name="context">@context;noquote@</property>

<if @blocked_p@ eq "t">

<p>#file-storage.lt_This_folder_contains_#

</if>
<else>

<form method=POST action=folder-delete>
<input type=hidden name=folder_id value=@folder_id@>
<input type=hidden name=confirmed_p value="t">

<p>#file-storage.lt_delete_folder#

<p>
<center>
<input type=submit value="#file-storage.Yes_Delete_It#">
</center>

</form>

</else>


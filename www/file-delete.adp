<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @blocked_p@ eq "t">

<p>#file-storage.lt_This_file_has_version#

</if>
<else>

<form method=POST action=file-delete>
<input type=hidden name=file_id value=@file_id@>
<input type=hidden name=confirmed_p value="t">

<p>#file-storage.lt_delete_file#

<p>
<center>
<input type=submit value="#file-storage.Yes_Delete_It#">
</center>
</form>

</else>

<master>
<property name="title">Delete @version_name@</property>
<property name="context">@context@</property>

<form method=POST action=version-delete>
<input type=hidden name=version_id value=@version_id@>
<input type=hidden name=confirmed_p value="t">

<p>#file-storage.lt_Are_you_sure_that_you#
<p>
<center>
<input type=submit value="#file-storage.Yes_Delete_It#">
</center>

</form>

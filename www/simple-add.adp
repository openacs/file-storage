<master src="fs_master">
<property name="title">Create @pretty_name@</property>
<property name="context_bar">@context_bar@</property>

<form method=POST action="simple-add-2">
<input type=hidden name="folder_id" value="@folder_id@">
<input type=hidden name="type" value="@type@">

<table border=0>

<tr>
<td align=right>Title : </td>
<td><input type=text name=name size=40></tr>
</tr>

<tr>
<td align=right> URL: </td>
<td><input size=50 name=url></td>
</tr>

<tr>
<td valign=top align=right> Description: </td>
<td colspan=2><textarea rows=5 cols=50 name=description wrap=soft></textarea></td>
</tr>

<tr>
<td></td>
<td><input type=submit value="Create">
</td>
</tr>

</table>
</form>

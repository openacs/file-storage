<master>
<property name="title">Edit @pretty_name@</property>
<property name="context">@context@</property>

<form method=POST action="simple-edit-2">
<input type=hidden name="object_id" value="@object_id@">

<table border=0>

<tr>
<td align=right>Title : </td>
<td><input type=text name=name size=40 value="@name@"></tr>
</tr>

<tr>
<td align=right> URL: </td>
<td><input size=50 name=url value="@url@"></td>
</tr>

<tr>
<td valign=top align=right> Description: </td>
<td colspan=2><textarea rows=5 cols=50 name=description wrap=soft>@description@</textarea></td>
</tr>

<tr>
<td></td>
<td><input type=submit value="Edit">
</td>
</tr>

</table>
</form>

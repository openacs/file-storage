<master src="master">
<property name="title">Create @pretty_name@</property>
<property name="context">@context@</property>

<form method=POST action="simple-add-2">
<input type=hidden name="folder_id" value="@folder_id@">
<input type=hidden name="type" value="@type@">

<table border=0>

<tr>
<td align=right> Title: </td>
  <if @lock_title_p@ eq 0>
    <td><input size=30 name=title value=@title@></td>
  </if>
  <else>
     <td>@title@</td>
     <input type=hidden name=title value=@title@>
  </else>
</tr>

<tr>
<td align=right> URL: </td>
<td><input size=50 name=url value="http://"></td>
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

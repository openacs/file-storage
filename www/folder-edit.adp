<master>
<property name="title">Edit Folder</property>
<property name="context">@context_bar@</property>


<form method=POST action=folder-edit-2>
<input type=hidden name=folder_id value="@folder_id@">

<table>
 <tr>
  <td align=right>Folder Name:</td>
  <td><input type=text name=folder_name value="@folder_name@" size=20></td>
 </tr>
 <tr>
  <td>&nbsp;</td>
  <td><input type=submit value="Save"></td>
 </tr>
</table>

</form>
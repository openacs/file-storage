<master>
<property name="title">#file-storage.Edit_Folder#</property>
<property name="context">@context_bar;noquote@</property>


<form method=POST action=folder-edit-2>
<input type=hidden name=folder_id value="@folder_id@">

<table>
 <tr>
  <td align=right>#file-storage.Folder_Name#</td>
  <td><input type=text name=folder_name value="@folder_name@" size=20></td>
 </tr>
 <tr>
  <td>&nbsp;</td>
  <td><input type=submit value="#file-storage.Save#"></td>
 </tr>
</table>

</form>


<master>
<property name="title">#file-storage.Create_New_Folder#</property>
<property name="context">@context@</property>


<form method=POST action=folder-create-2>
<input type=hidden name=parent_id value="@parent_id@">

<table>
 <tr>
  <td align=right>#file-storage.Folder_Name#</td>
  <td><input type=text name=folder_name size=20></td>
 </tr>
 <tr>
  <td>&nbsp;</td>
  <td><input type=submit value="#file-storage.Create#"></td>
 </tr>
</table>

</form>


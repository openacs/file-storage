<master src="fs_master">
<property name="title">Upload New File</property>
<property name="context_bar">@context_bar@</property>

<form enctype=multipart/form-data method=POST action="file-add-2">
<input type=hidden name="folder_id" value="@folder_id@">

<table border=0>

<tr>
<td align=right>Version filename : </td>
<td><input type=file name=upload_file size=20></tr>
</tr>

<tr>
<td>&nbsp;</td>
<td><font size=-1>Use the "Browse..." button to locate your file, 
    then click "Open". </font></td>
</tr>

<tr>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>

<tr>
<td align=right> Title: </td>
<td><input size=30 name=title></td>
</tr>

<tr>
<td valign=top align=right> Description: </td>
<td colspan=2><textarea rows=5 cols=50 name=description wrap=physical></textarea></td>
</tr>

<tr>
<td></td>
<td><input type=submit value="Submit and Upload">
</td>
</tr>

</table>
</form>

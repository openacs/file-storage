<master src="fs_master">
<property name="title">Upload New Version of @title@</property>
<property name="context_bar">@context_bar@</property>

<form enctype=multipart/form-data method=POST action=version-add-2>
<input type=hidden name=file_id value="@file_id@">
<input type=hidden name="title" value="@title@">
<table border=0>

<tr>
<td align=right>Version filename:</td>
<td><input type=file name=upload_file size=20></td>
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
<td valign=top align=right> Version Notes: </td>
<td colspan=2><textarea rows=5 cols=50 name=description wrap=physical></textarea></td>
</tr>

<tr>
<td></td>
<td><input type=submit value="Update">
</td>
</tr>

</table>
</form>

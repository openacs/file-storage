<master>
<property name="title">Upload New Version of @title;noquote@</property>
<property name="context">@context;noquote@</property>

<form enctype=multipart/form-data method=POST action=version-add-2>
<input type=hidden name=file_id value="@file_id@">
<input type=hidden name="title" value="@title@">
<table border=0>

<tr>
<td align=right>#file-storage.Version_filename_1#</td>
<td><input type=file name=upload_file size=20></td>
</tr>

<tr>
<td>&nbsp;</td>
<td><font size=-1>#file-storage.lt_Use_the_Browse_button# </font></td>
</tr>

<tr>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>

<tr>
<td valign=top align=right> #file-storage.Version_Notes_1# </td>
<td colspan=2><textarea rows=5 cols=50 name=description wrap=physical></textarea></td>
</tr>

<tr>
<td></td>
<td><input type=submit value="#file-storage.Update#">
</td>
</tr>

</table>
</form>

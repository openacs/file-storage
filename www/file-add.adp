<master>
<property name="title">#file-storage.Upload_New_File#</property>
<property name="context">@context@</property>

<form enctype=multipart/form-data method=POST action="file-add-2">
<input type=hidden name="folder_id" value="@folder_id@">

<table border=0>

<tr>
<td align=right>#file-storage.Version_filename_# </td>
<td><input type=file name=upload_file size=20></tr>
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
<td align=right> #file-storage.Title# </td>
  <if @lock_title_p@ eq 0>
    <td><input size=30 name=title value=@title@></td>
  </if>
  <else>
      <input type=hidden name=title value=@title@>
      <td>@title@</td>
  </else>
</tr>

<tr>
<td valign=top align=right> #file-storage.Description# </td>
<td colspan=2><textarea rows=5 cols=50 name=description wrap=physical></textarea></td>
</tr>

<tr>
<td></td>
<td><input type=submit value="#file-storage.Upload#">
</td>
</tr>

</table>
</form>

<master>
<property name="title">#file-storage.Copy#</property>
<property name="context">@context;noquote@</property>

<P>#file-storage.lt_Select_the_folder_tha#

<form method=GET action="file-copy-2">
<input type=hidden name=file_id value="@file_id@">

<include src="folder-list" file_id="">
<p>
<input type=submit value="#file-storage.Copy#">
</form>




<master>
<property name="title">#file-storage.Move#</property>
<property name="context">@context;noquote@</property>

<P>#file-storage.lt_Select_the_folder_tha_1#

<form method=GET action="file-move-2">
<input type=hidden name=file_id value="@file_id@">

<include src="folder-list" file_id="@file_id;noquote@">
<p>
<input type=submit value="#file-storage.Move#">
</form>




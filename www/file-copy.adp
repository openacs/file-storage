<master src="fs_master">
<property name="title">Copy</property>
<property name="context_bar">@context_bar@</property>

<P>Select the folder that you would like to copy "@file_name@" to

<form method=GET action="file-copy-2">
<input type=hidden name=file_id value="@file_id@">

<include src="folder_list" file_id="">
<p>
<input type=submit value="Copy">
</form>

<master>
<property name="title">#file-storage.Move#</property>
<property name="context">@context@</property>

<P>Select the folder that you would like to move "@file_name@" under

<form method=GET action="file-move-2">
<input type=hidden name=file_id value="@file_id@">

<include src="folder-list" file_id="@file_id@">
<p>
<input type=submit value="#file-storage.Move#">
</form>



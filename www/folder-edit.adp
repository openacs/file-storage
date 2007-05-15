<master>
<property name="title">#file-storage.Edit_Folder#</property>
<property name="context">@context_bar;noquote@</property>

<h1>#file-storage.Edit_Folder#</h1>

<form method=POST action=folder-edit-2 class="margin-form">
<input type=hidden name=folder_id value="@folder_id@">
<fieldset>

<div class="form-item-wrapper">
	<div class="form-label">
		<label for="folder_name">
			#file-storage.Folder_Name#
		</label>
	</div>
	
	<div class="form-widget">                  
		<input type=text name=folder_name id=folder_name value="@folder_name@" size=30>
	</div>
</div>

<div class="form-button">
	  <input type=submit value="#file-storage.Save#">
</div>
</fieldset>

</form>


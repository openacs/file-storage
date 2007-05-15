<master>
<property name="title">@folder_name@</property>
<property name="header">@folder_name@</property>
<property name="context">@context;noquote@</property>
<property name="displayed_object_id">@folder_id;noquote@</property>

<if @up_url@ not nil or  @project_url@ not nil>
	<div class="list-button-bar-top">

		<if @up_url@ not nil>
			<a href="@up_url@" class="button">#file-storage.index_page_navigate_up_folder#</a>
		</if>

		<if @project_url@ not nil>
			<a href="@project_url@">#file-storage.back_to_project#: @project_name@</a>
		</if>

	</div>
</if>
<include src="folder-chunk" folder_id="@folder_id@"
    n_past_days="@n_past_days@" allow_bulk_actions="1" return_url="@return_url@">


<p>@notification_chunk;noquote@</p>

<if @webdav_url@ not nil>
    <p>#file-storage.Folder_available_via_WebDAV_at#</p>
</if>

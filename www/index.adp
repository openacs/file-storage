<master>
<property name="title">@folder_name@</property>
<property name="header">@folder_name@</property>
<property name="context">@context;noquote@</property>
<if @up_url@ not nil>
    <p><a href="@up_url@" class="button">#file-storage.index_page_navigate_up_folder#</a></p>
</if>

<include src="folder-chunk" folder_id="@folder_id@"
    n_past_days="@n_past_days@" allow_bulk_actions="1" >

<if @webdav_url@ not nil>
      <p>#file-storage.Folder_available_via_WebDAV_at#</p>
</if>

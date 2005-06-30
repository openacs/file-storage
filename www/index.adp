<master>
<property name="title">@folder_name@</property>
<property name="header">@folder_name@</property>
<property name="context">@context;noquote@</property>
<property name="displayed_object_id">@folder_id;noquote@</property>

<if @up_url@ not nil>
    <p><a href="@up_url@" class="button">#file-storage.index_page_navigate_up_folder#</a></p>
</if>

<include src="folder-chunk" folder_id="@folder_id@"
    n_past_days="@n_past_days@" allow_bulk_actions="1" >


<p>@notification_chunk;noquote@</p>

<if @webdav_url@ not nil>
    <% regsub -all {/\$} $webdav_url {/\\$} webdav_url %>  
    <p>#file-storage.Folder_available_via_WebDAV_at#</p>
</if>

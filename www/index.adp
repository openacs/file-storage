<master>
<property name="title">@folder_name;noquote@</property>
<property name="header">@folder_name;noquote@</property>
<property name="context">@context;noquote@</property>
<if @up_url@ not nil>
    <a href="@up_url@">#file-storage.index_page_navigate_up_folder#</a>
</if>

<include src="folder-chunk" folder_id=@folder_id;noquote@ n_past_days=@n_past_days@>

<if @webdav_url@ not nil>
      <p>#file-storage.Folder_available_via_WebDAV_at# @webdav_url@</p>
</if>
      
<master>
<property name="title">@folder_name;noquote@</property>
<property name="header">@folder_name;noquote@</property>
<property name="context">@context;noquote@</property>
<if @up_url@ not nil>
    <a href="@up_url@">#file-storage.index_page_navigate_up_folder#</a>
</if>

<include src="folder-chunk" folder_id=@folder_id;noquote@ viewing_user_id=@user_id;noquote@ n_past_days=@n_past_days;noquote@>


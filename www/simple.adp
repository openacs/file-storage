<master>
<property name="doc(title)">@title;literal@</property>
<property name="header">@title;literal@</property>
<property name="context">@context;literal@</property>
<property name="displayed_object_id">@object_id;literal@</property>

<p><a href="@url@">@url@</a></p>
<p>@description@</p>
<if @categories_p;literal@ true><if @category_links;literal@ ne ""><p>#file-storage.Categories#: @category_links;noquote@</p></if></if>
<if @edit_p;literal@ true>
<p><a href="simple-edit?object_id=@object_id@" class="button">#acs-kernel.common_edit#</a>
<a href="simple-delete?object_id=@object_id@&amp;folder_id=@folder_id@" class="button">#acs-kernel.common_delete#</a>
</p>
</if>
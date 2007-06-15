<master>
<property name="title">@title;noquote@</property>
<property name="header">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="displayed_object_id">@object_id;noquote@</property>

<p><a href="@url@">@url@</a></p>
<p>@description@</p>
<if @categories_p@><if @category_links@><p>#file-storage.Categories#: @category_links;noquote@</p></if></if>
<if @edit_p@ true>
<p><a href="simple-edit?object_id=@object_id@" class="button">#acs-kernel.common_edit#</a>
<a href="simple-delete?object_id=@object_id@&amp;folder_id=@folder_id@" class="button">#acs-kernel.common_delete#</a>
</p>
</if>
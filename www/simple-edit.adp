<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<if @mode@ eq "display">
  <p>
    <a href="simple-delete?object_id=@object_id@&folder_id=@folder_id@" class="button">Delete URL</a>
</p>
</if>
  <formtemplate id="simple-edit"></formtemplate>
<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context;literal@</property>

<if @blocked_p;literal@ true">

<p>#file-storage.lt_This_folder_contains_#

</if>
<else>
<formtemplate id="folder-delete"></formtemplate>
</else>


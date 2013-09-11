<master>
<property name="doc(title)">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @blocked_p@ eq "t">

<p>#file-storage.lt_This_folder_contains_#

</if>
<else>
<formtemplate id="folder-delete"></formtemplate>
</else>


<master>
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>

<if @blocked_p@ eq "t">

<p>#file-storage.lt_This_file_has_version#

</if>
<else>
<formtemplate id="file-delete"></formtemplate>
</else>

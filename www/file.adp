<master>
<property name="title">@title;noquote@</property>
<property name="header">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<ul>
  <li>#file-storage.file_page_file_title_label# <if @write_p@ true>(<a href="file-edit?file_id=@file_id@">#file-storage.edit#</a>)</if>
  <li>#file-storage.file_page_owner_label#
<p>
  <li>#file-storage.Actions# 
  <if @show_all_versions_p@ true>
    <a href="file?file_id=@file_id@&show_all_versions_p=f">#file-storage.lt_show_only_live_versio#</a>
  </if>
  <else>
    <a href="file?file_id=@file_id@&show_all_versions_p=t">#file-storage.show_all_versions#</a>
  </else>
  <if @write_p@ true>
    | <a href="version-add?file_id=@file_id@">#file-storage.Upload_a_new_version#</a>
  </if>
    | <a href="file-copy?file_id=@file_id@">#file-storage.Copy#</a>
  <if @write_p@ true>
    | <a href="file-move?file_id=@file_id@">#file-storage.Move#</a>
  </if>
  <if @admin_p@ true and @show_administer_permissions_link_p@ true>
    | <a href="/permissions/one?object_id=@file_id@">#file-storage.lt_Modify_permissions_on#</a>
  </if>
  <if @delete_p@ true>
    | <a href="file-delete?file_id=@file_id@">#file-storage.lt_Delete_this_file_incl#</a>
  </if>
 <if @gc_comments@ not nil>
 <li>#file-storage.lt_Comments_on_this_file#
 <ul>
 @gc_comments;noquote@
 </ul>
 </if>
 <if @gc_link@ not nil>
   <p><li>@gc_link;noquote@
 </if>
</ul>

#file-storage.back_to_folder_view#
<p>
<table border=1 cellspacing=2 cellpadding=2>
  <tr>
    <td colspan=7>
      <if @show_all_versions_p@ true>#file-storage.lt_All_Versions_of_title#</if>
      <else>#file-storage.lt_Live_version_of_title#</else>.
    </td>
  </tr>
  <tr>
    <td>#file-storage.Version_filename#</td>
    <td>#file-storage.Author#</td>
    <td>#file-storage.Size_bytes#</td>
    <td>#file-storage.Type#</td>
    <td>#file-storage.Modified#</td>
    <td>#file-storage.Version_Notes#</td>
    <td>#file-storage.Actions_1#</td>
  </tr>

<multiple name=version>
  <tr>
    <td>
      <a href="download/@version.title@?version_id=@version.version_id@"><img src="/resources/file-storage/file.gif" border="0"></a>
      <if @version.rownum@ eq 1>
        <a href="view/@file_url;noquote@">@version.title@</a>
      </if>
      <else>
        <a href="download/@version.title@?version_id=@version.version_id@">@version.title@</a>
      </else>
    </td>
    <td>@version.author@</td>
    <td align=right>@version.content_size_pretty@</td>
    <td>@version.type@</td>
    <td>@version.last_modified_pretty@</td>
    <td>@version.description@&nbsp;</td>
    <td>
      &nbsp;<if @version.delete_p@ true>
      <a href="version-delete?version_id=@version.version_id@">#file-storage.delete#</a> 
        <if @version.admin_p@ true and @show_administer_permissions_link_p@ true>|</if>
      </if>
      <if @version.admin_p@ true and @show_administer_permissions_link_p@ true>
        <a href="/permissions/one?object_id=@version.version_id@">#file-storage.lt_administer_permission#</a>
      </if>
    </td>
  </tr>
</multiple>

<if @version:rowcount@ eq 0>
  <tr>
    <td colspan=7><i>#file-storage.lt_There_are_no_versions#</i></td>
  </tr>
</if>
</table>




<master>
<property name="title">@folder_name@</property>
<property name="header">@folder_name@</property>
<property name="context">@context;noquote@</property>


<table width="100%" border="0">
  <if @write_p@ true>
    <tr>
      <td colspan=2>
        <a href="file-add?folder_id=@folder_id@">#file-storage.Upload_a_file#</a>
        &nbsp;|&nbsp;
        <a href="simple-add?folder_id=@folder_id@">#file-storage.Create_a_URL#</a>
      </td>
      <td align="right">
        <formtemplate id="n_past_days_form">
           #file-storage.lt_Show_files_modified_i# <formwidget id="n_past_days"> #file-storage.days_as_new#
        </formtemplate>
      </td>
    </tr>
    <tr>
      <td colspan="3">
        <a href="folder-create?parent_id=@folder_id@">#file-storage.Create_a_new_folder#</a>

        <if @admin_p@ true and @root_folder_p@ false>
          &nbsp;|&nbsp;
          <a href="folder-edit?folder_id=@folder_id@">#file-storage.Rename_this_folder#</a>
        </if>
        
        <if @delete_p@ true and @root_folder_p@ false and @n_contents@ eq 0>
          &nbsp;|&nbsp;
          <a href="folder-delete?folder_id=@folder_id@">#file-storage.Delete_this_folder#</a>
        </if>

        <if @admin_p@ true and @show_administer_permissions_link_p@ true>
          &nbsp;|&nbsp;
          <a href="/permissions/one?object_id=@folder_id@">#file-storage.lt_Modify_permissions_on_1#</a>
        </if>

        <if @up_url@ not nil>
          &nbsp;|&nbsp;
          <a href="@up_url@">#file-storage.index_page_navigate_up_folder#</a>
        </if>
  
      </td>
    </tr>
  </if>
  <tr><td colspan="2"><br></td></tr>
</table>


<include src="folder-chunk" folder_id=@folder_id@ viewing_user_id=@user_id@ n_past_days=@n_past_days@>


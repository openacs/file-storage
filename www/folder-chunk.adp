<if @contents:rowcount@ gt 0>
  <table class="table-display" cellpadding="5" cellspacing="0">
    <tr class="table-header">
      <td>&nbsp;</td>
      <th>#file-storage.Name#</th>
      <th>#file-storage.Action#</th>
      <th>#file-storage.Size#</th>
      <th>#file-storage.Type#</th>
      <th>#file-storage.Last_Modified#</th>
    </tr>
    <multiple name="contents">
      <if @contents.rownum@ odd>
	<tr class="odd">
      </if>
      <else>
	<tr class="even">
      </else>
      <if @contents.type@ eq "folder">
	<td><a href="@fs_url@index?folder_id=@contents.object_id@&n_past_days=@n_past_days@"><img src="@fs_url@graphics/folder.gif" border=0 alt="#file-storage.folder#"></a></td>
	<td>
	  <a href="@fs_url@index?folder_id=@contents.object_id@&n_past_days=@n_past_days@">@contents.name@</a>
          <if @contents.new_p@ and @contents.content_size@ gt 0><font color="red">#file-storage.new#</font></if>
	</td>
	<td>&nbsp;</td>
	<td align="right">
	  @contents.content_size_pretty@ <if @contents.content_size@ ne 1>#file-storage.items#</if><else>#file-storage.item#</else>
	</td>
	<td>@contents.type@</td>
	<td>@contents.last_modified_pretty@</td>
      </if>
      <else>
	<if @contents.type@ eq "url">
	  <td><a href="@fs_url@url-goto?url_id=@contents.object_id@"><img src="@fs_url@graphics/file.gif" alt="#file-storage.file#" border=0></a></td>
	  <td>
	    <a href="@fs_url@url-goto?url_id=@contents.object_id@">@contents.name@</a>
            <if @contents.new_p@><font color="red">#file-storage.new#</font></if>
	  </td>
	  <td>
	    <small>
	      <if @contents.write_p@>
		[ <a href="@fs_url@simple-edit?object_id=@contents.object_id@">#file-storage.edit#</a>
	      </if>
	      <if @contents.delete_p@>
		|
		<a href="@fs_url@simple-delete?folder_id=@folder_id@&object_id=@contents.object_id@">#file-storage.delete#</a>
	      </if>
	      <if @contents.write_p@ or @contents.delete_p@>
              ]
	      </if>
	    </small>
	  </td>
	  <td>&nbsp;</td>
	  <td>@contents.type@</td>
	  <td>@contents.last_modified_pretty@</td>
	</if>
	<else>
	  <td><a href="@fs_url@download/@contents.file_upload_name@?version_id=@contents.live_revision@"><img src="@fs_url@graphics/file.gif" alt="#file-storage.file#" border="0"></a></td>
	  <td>
	    <a href="@fs_url@view/@contents.file_url@">
	      @contents.name@
	    </a>
	    <if @contents.new_p@>
              <font color="red">#file-storage.new#</font>
	    </if>
	  </td>
	  <td>
	    <small><a href="@fs_url@file?file_id=@contents.object_id@">#file-storage.view_details#</a></small>
	  </td>
          <td align="right">@contents.content_size_pretty@ byte<if @contents.content_size@ ne 1>s</if></td>
	  <td>@contents.type@</td>
	  <td>@contents.last_modified_pretty@</td>
	</else>
      </else>
    </tr>
    </multiple>
  </table>

  <if @content_size_total@ gt 0>
    <p>
      <a href="@fs_url@download-archive/index?object_id=@folder_id@">
        Download an archive of the contents of this folder
      </a>
      <br>
      <small><i><strong>Note:</strong> This may take a while, please be patient.</i></small>
    </p>
  </if>
</if>
<else>
  <p><blockquote><i>#file-storage.lt_Folder_folder_name_is#</i></blockquote></p>
</else>

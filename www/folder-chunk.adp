<if @contents:rowcount@ gt 0>
  <table class="table-display" cellpadding="5" cellspacing="0">
    <tr class="table-header">
      <td>&nbsp;</td>
      <td>Name</td>
      <td>Action</td>
      <td>Size</td>
      <td>Type</td>
      <td>Last Modified</td>
    </tr>
    <multiple name="contents">
      <if @contents.rownum@ odd>
	<tr class="odd">
      </if>
      <else>
	<tr class="even">
      </else>
      <if @contents.type@ eq "folder">
	<td><a href="@fs_url@index?folder_id=@contents.object_id@&n_past_days=@n_past_days@"><img src="@fs_url@graphics/folder.gif" border=0 alt="folder"></a></td>
	<td>
	  <a href="@fs_url@index?folder_id=@contents.object_id@&n_past_days=@n_past_days@">@contents.name@</a>
	  <if @contents.new_p@ and @contents.content_size@ gt 0><img src="@fs_url@graphics/new.gif" alt="new"></if>
	</td>
	<td>&nbsp;</td>
	<td align="right">
	  @contents.content_size@ item<if @contents.content_size@ ne 1>s</if>
	</td>
	<td>@contents.type@</td>
	<td>@contents.last_modified@</td>
      </if>
      <else>
	<if @contents.type@ eq "url">
	  <td><a href="@fs_url@url-goto?url_id=@contents.object_id@"><img src="@fs_url@graphics/file.gif" alt="file" border=0></a></td>
	  <td>
	    <a href="@fs_url@url-goto?url_id=@contents.object_id@">@contents.name@</a>
	    <if @contents.new_p@><img src="@fs_url@graphics/new.gif" alt="new"></if>
	  </td>
	  <td>
	    <small>
	      <if @contents.write_p@>
		[<a href="@fs_url@simple-edit?object_id=@contents.object_id@">
		  edit
		</a>
	      </if>
	      <if @contents.delete_p@>
		|
		<a href="@fs_url@simple-delete?folder_id=@folder_id@&object_id=@contents.object_id@">
		  delete
		</a>
	      </if>
	      <if @contents.write_p@ or @contents.delete_p@>
	      ]
	      </if>
	    </small>
	  </td>
	  <td>&nbsp;</td>
	  <td>@contents.type@</td>
	  <td>@contents.last_modified@</td>
	</if>
	<else>
	  <td><a href="@fs_url@download/@contents.file_upload_name@?version_id=@contents.live_revision@"><img src="@fs_url@graphics/file.gif" alt="file" border="0"></a></td>
	  <td>
	    <a href="@fs_url@download/@contents.file_upload_name@?version_id=@contents.live_revision@">
	      @contents.name@
	    </a>
	    <if @contents.new_p@>
	      <img src="@fs_url@graphics/new.gif" alt="new">
	    </if>
	  </td>
	  <td>
	    <small><a href="@fs_url@file?file_id=@contents.object_id@">view details</a></small>
	  </td>
          <td align="right">@contents.content_size@ byte<if @contents.content_size@ ne 1>s</if></td>
	  <td>@contents.type@</td>
	  <td>@contents.last_modified@</td>
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
  <p><blockquote><i>Folder @folder_name@ is empty</i></blockquote></p>
</else>

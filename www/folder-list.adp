<if @folder:rowcount@ gt 8>
<select name="parent_id" size=8>
</if><else>
<select name="parent_id" size=@folder:rowcount@>
</else>
<multiple name="folder">
<option value="@folder.new_parent@">@folder.spaces@ @folder.label@</option>
</multiple>
</select>



<if @permission_p@ true>
<if @contents:rowcount@ gt 0>
<multiple name="contents">
<if @contents.type@ ne "folder">
<a href="@contents.file_url@">@contents.title@</a> <if @admin_p@ true><a href="@contents.properties_url@">#acs-kernel.common_Edit#</a></if><br>
</if>
</multiple>
</if></if>

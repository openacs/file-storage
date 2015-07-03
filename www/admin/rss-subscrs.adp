<master>
<property name="doc(title)">Configure RSS for @folder_name@</property>
<property name="header">Configure RSS for @folder_name@</property>
<property name="context">@context;literal@</property>

<if @rebuild_short_name@ not nil>
<p>*Rebuilt feed: @rebuild_short_name@</p>
</if>

<p>Configuring RSS for <a href="../?folder_id=@folder_id@">@folder_name@</a></p>

<p><a href="rss-subscr-ae?folder_id=@folder_id@">Create a new RSS feed</a> for this folder.</p>

<if @subscrs:rowcount@ gt 0>
<h4>Edit an existing feed</h4>
</if>

<listtemplate name="subscrs"></listtemplate>

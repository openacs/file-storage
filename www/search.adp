<master src="fs_master">
<property name="title">Search Results</property>
<property name="context_bar">@context_bar@</property>

<if @results:rowcount@ eq 0>
<p>Your search on "@query@" did not return any results.
</if>
<else>
<p>Your search on "@query@" returned the following files:

<ul>
<multiple name="results">
<li><a href="file?file_id=@results.file_id@">@results.title@</a>
</multiple>
</ul>
</else>

<form method=POST action=search>
Search again:
<input type=text size=30 name=query>
</form>


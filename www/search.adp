<master>
<property name="title">#file-storage.Search_Results#</property>
<property name="context">@context;noquote@</property>

<if @results:rowcount@ eq 0>
<p>#file-storage.lt_Your_search_on_query_#
</if>
<else>
<p>#file-storage.lt_Your_search_on_query__1#

<ul>
<multiple name="results">
<li><a href="file?file_id=@results.file_id@">@results.title@</a>
</multiple>
</ul>
</else>

<form method=POST action=search>
#file-storage.Search_again#
<input type=text size=30 name=query>
</form>





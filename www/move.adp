<master>
  <property name="doc(title)">@title@</property>
  <property name="context">@context@</property>

 <h1>@title;noquote@</h1>
 <if @allowed_count@ gt 0>
	<p>
		<if @allowed_count@ eq @total_count@>
	    	#file-storage.lt_Moving_allowed_count_#
		</if>
		<else>
			#file-storage.lt_not_allowed_count_ite#
		</else>
	</p>
  
 <if @show_items@ eq 1>
  <listtemplate name="move_objects"></listtemplate>
 </if>

  <listtemplate name="folder_tree"></listtemplate>
 </if>
  <else>#file-storage.lt_No_valid_items_to_be_#</else>

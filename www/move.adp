<master>
  <property name="title">@title@</property>
  <property name="context">@context@</property>
 <if @allowed_count@ gt 0>
  <if @allowed_count@ eq @total_count@>
    Moving @allowed_count@ items.
  </if><else>@not_allowed_count@ items can not be moved</else>
  
 <if @show_items@ eq 1>
  <listtemplate name="move_objects"></listtemplate>
 </if>

  <p>#file-storage.lt_Select_the_folder_tha_1#</p>
  <listtemplate name="folder_tree"></listtemplate>
 </if>
  <else>No valid items to be moved.</else>
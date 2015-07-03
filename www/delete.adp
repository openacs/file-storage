<master>
<property name="doc(title)">@title;literal@</property>
<property name="context">context</property>

<h1>@title;noquote@</h1>

 <if @allowed_count@ gt 0>
      
  <if @not_allowed_count@ gt 0>@not_allowed_count@ items can not be deleted.</if>
  <listtemplate name="delete_list"></listtemplate>

  <formtemplate id="delete_confirm"></formtemplate>
</if>
  <else>
      No valid items to be deleted
    </else>
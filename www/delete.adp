<master>
<property name="title">@title@</property>
<property name="context">context</property>

 <if @allowed_count@ gt 0>
      
  <if @not_allowed_count@ gt 0>@not_allowed_count@ items can not be deleted.</if>
  <listtemplate name="delete_list"></listtemplate>

  <formtemplate id="delete_confirm"></formtemplate>
</if>
  <else>
      No valid items to be deleted
    </else>
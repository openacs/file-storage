<master>
<property name="title">@folder_name;noquote@</property>
<property name="header">@folder_name;noquote@</property>
<property name="context">@context;noquote@</property>

<table>
  <tr>
    <td><li></td>
    <td>
      <if @recurse_p@ true>I</if><else>#file-storage.Not_i#</else>#file-storage.lt_ncluding_items_from_s# 
      ( 
<if @recurse_p@ true>
      <a href="?folder_id=@folder_id@&recurse_p=0&n_past_days=@n_past_days@&orderby=@orderby@">#file-storage.exclude#</a>
</if>
<else>
      <a href="?folder_id=@folder_id@&recurse_p=1&n_past_days=@n_past_days@&orderby=@orderby@">#file-storage.include#</a>
</else>
      )
    </td>
  </tr>
  <tr>
    <td><li></td>
    <td>
<formtemplate id="n_past_days_form">
      #file-storage.lt_Showing_files_modifie# <formwidget id="n_past_days"> #file-storage.day#<if @n_past_days@ ne 1>s</if>.
</formtemplate>
    </td>
  </tr>
</table>

<br>

@table@



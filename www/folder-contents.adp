<master>
<property name="title">@folder_name@</property>
<property name="header">@folder_name@</property>
<property name="context">@context@</property>

<table>
  <tr>
    <td><li></td>
    <td>
      <if @recurse_p@ true>Including</if><else>Not including</else> items from subfolders
      ( 
<if @recurse_p@ true>
      <a href="?folder_id=@folder_id@&recurse_p=0&n_past_days=@n_past_days@&orderby=@orderby@">exclude</a>
</if>
<else>
      <a href="?folder_id=@folder_id@&recurse_p=1&n_past_days=@n_past_days@&orderby=@orderby@">include</a>
</else>
      )
    </td>
  </tr>
  <tr>
    <td><li></td>
    <td>
<formtemplate id="n_past_days_form">
      Showing files modified within the past <formwidget id="n_past_days"> day<if @n_past_days@ ne 1>s</if>.
</formtemplate>
    </td>
  </tr>
</table>

<br>

@table@

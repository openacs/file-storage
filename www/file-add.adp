<master>
<property name="title">#file-storage.Upload_New_File#</property>
<property name="context">@context;noquote@</property>

<h1>#file-storage.Upload_New_File#</h1>

<if @unpack_available_p@ true>
  <script language="JavaScript">
      function UnpackChanged(elm) {
        var form_name = "file-add";

        if (elm == null) return;
        if (document.forms == null) return;
        if (document.forms[form_name] == null) return;

        if (elm.checked == true) {
            document.forms[form_name].elements["title"].disabled = true;   
	     document.getElementById('fs_title_msg').innerHTML= 'The title you entered will not be used if you upload multiple files at once';

         } else {
            document.forms[form_name].elements["title"].disabled = false;
	     document.getElementById('fs_title_msg').innerHTML= '';
        }
    }
  </script>
</if>

<p>
  @instructions;noquote@
</p>

<formtemplate id="file-add"></formtemplate>

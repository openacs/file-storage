<master>
<property name="title">#file-storage.Upload_New_File#</property>
<property name="context">@context;noquote@</property>

<if @unpack_available_p@ true>
  <script language="JavaScript">
      function UnpackChanged(elm) {
        var form_name = "file-add";

        if (elm == null) return;
        if (document.forms == null) return;
        if (document.forms[form_name] == null) return;

        if (elm.checked == true) {
            document.forms[form_name].elements["title"].disabled = true;
            document.forms[form_name].elements["title"].value = "";
        } else {
            document.forms[form_name].elements["title"].disabled = false;
        }
    }
  </script>
</if>



<formtemplate id="file-add"></formtemplate>

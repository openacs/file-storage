ad_page_contract {

    This page allows a file storage admin to change the 
    upload size.

    @author Tracy Adams (teadams@mit.edu)
    @creation-date  2004-07-07
    @cvs-id $Id$

} {
    {return_url ""}
} 

set max_size [ns_config "ns/server/[ns_info server]/module/nssock" maxinput]
if { [string equal $max_size ""] } {
    set max_size 0
}

set title "#file-storage.Configure_File_Upload_Limit#"
set context [list $title]

set upload_limit [parameter::get -parameter "MaximumFileSize"]

ad_form -name upload_limit_size -export folder_id -form {
    {new_size:integer(text) {label "#file-storage.Upload_Limit# $max_size"} {value $upload_limit} {html { maxlength 8}}}
    {return_url:text(hidden) {value $return_url}}
    {submit:text(submit) {label "[_ file-storage.Change_upload_limit]"}}
} -validate {
 {new_size
    { $new_size <= $max_size }
         "#file-storage.Upload_limit_error# $max_size #file-storage.Upload_limit_error_2#  "}

} -on_submit {
    parameter::set_value  -parameter "MaximumFileSize" -value $new_size
    if {![empty_string_p $return_url]} {
	ns_returnredirect $return_url
    }
}











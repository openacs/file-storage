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

set title "Configure File Upload Limit"
set context [list "Configure File Upload Limit"]

set upload_limit [parameter::get -parameter "MaximumFileSize"]

ad_form -name upload_limit_size -export folder_id -form {
    {new_size:integer(text) {label "Upload Limit (bytes) $max_size"} {value $upload_limit} {html { maxlength 8}}}
    {return_url:text(hidden) {value $return_url}}
    {submit:text(submit) {label "Change upload limit"}}
} -validate {
 {new_size
    { $new_size <= $max_size }
         "Upload limit must be less than $max_size bytes"}

} -on_submit {
    parameter::set_value  -parameter "MaximumFileSize" -value $new_size
    if {![empty_string_p $return_url]} {
	ns_returnredirect $return_url
    }
}











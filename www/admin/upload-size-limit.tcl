ad_page_contract {

    This page allows a file storage admin to change the 
    upload size.

    @author Tracy Adams (teadams@mit.edu)
    @creation-date  2004-07-07
    @cvs-id $Id$

} {
    {return_url:localurl ""}
} 

set title "#file-storage.Configure_File_Upload_Limit#"
set context [list $title]

# Get the webserver maximum file upload value.

# Set a conservative default value of 2GB if the maximum upload value is not
# found in the webserver config.
set driver [expr {[ns_conn isconnected] ?
                  [ns_conn driver] :
                  [lindex [ns_driver names] 0]}]
set section [ns_driversection -driver $driver]
set max_size [ns_config $section maxinput 2147483648]


set upload_limit [fs::max_upload_size]

ad_form -name upload_limit_size -export folder_id -form {
    {new_size:integer(number) {label "#file-storage.Upload_Limit# $max_size"} {value $upload_limit} {html { min 0 max $max_size }}}
    {return_url:text(hidden) {value $return_url}}
    {submit:text(submit) {label "[_ file-storage.Change_upload_limit]"}}
} -validate {
 {new_size
    { $max_size == 0 || $new_size <= $max_size }
         "#file-storage.Upload_limit_error# $max_size #file-storage.Upload_limit_error_2#  "}

} -on_submit {
    parameter::set_value  -parameter "MaximumFileSize" -value $new_size
    if {$return_url ne ""} {
	ad_returnredirect $return_url
        ad_script_abort
    }
}











# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

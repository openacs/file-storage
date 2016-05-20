ad_page_contract {
    Confirm upload in delivery folder by redirect in callback

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2006-05-15
} {
    folder_id:naturalnum,notnull
    cancel_url
    return_url:localurl
}

set package_id [ad_conn package_id]
callback fs::before_file_new -package_id $package_id -folder_id $folder_id -cancel_url $cancel_url -return_url $return_url

ad_returnredirect $return_url
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

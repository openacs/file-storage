ad_library {
    @author Al-Faisal El-Dajani (faisal.dajani@gmail.com)
    @creation-date 2005-10-25
}

namespace eval fs::torrent {}

ad_proc -deprecated fs::torrent::get_hashsum {
    {-filename:required}
} {
    Get hashsum for the file using SHA1 hashsum technique.

    DEPRECATED: NaviServer can now perform such a digest in a oneliner
    that won't require slurping the file first.

    @see ns_md

    @author Al-Faisal El-Dajani (faisal.dajani@gmail.com)
    @creation-date 2005-10-25
    @param filename Name of file to get hashsum for. Must be in absolute path format.
    @return Hashsum of file in hexa.
} {
    set file_stream [open $filename r]
    set file_contents [read $file_stream]
    close $file_stream
    return [ns_sha1 $file_contents]
}
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

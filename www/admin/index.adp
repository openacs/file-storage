<master>
  <property name="title">@title@</property>
  <property name="context">@context@</property>

  <if @fs_folders:rowcount@ gt 0>
  <multiple name="fs_folders">
    @fs_folders.label@ : @fs_folders.url@ <if @fs_folders.dav_enabled_p@
    eq 0><a
    href="/file-storage-dav/admin/dav-enable?package_id=@fs_folders.package_id@">Enable</a></if><else><a
    href="/file-storage-dav/admin/dav-disable?package_id=@fs_folders.package_id@">Disable</else><br />
  </multiple>
  </if>
  <else>
    No file storage folders exist
  </else>
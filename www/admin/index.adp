<master>
  <property name="title">@title@</property>
  <property name="context">@context@</property>

  <if @dav_installed_p@ eq 1>
    <p>WedDAV support is installed.</p>
    <if @dav_enabled_p@ eq 1>
      <p>@package_name@ is WebDAV enabled. <a
    href="dav-disable">Disable WebDAV support</a>.</p>
    </if>
    <else>
      <p>@package_name@ is not WebDAV enabled. You may <a
      href="dav-enable">enable WedDAV support</a> for @package_name@.</p>
    </else>
  </if>

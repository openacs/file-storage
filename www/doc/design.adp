
<property name="context">{/doc/file-storage {File Storage}} {File Storage Design Document}</property>
<property name="doc(title)">File Storage Design Document</property>
<master>
<h2>File Storage Design Document</h2>

by <a href="mailto:kevin\@arsdigita.com">Kevin Scaldeferri</a>
,
modified by <a href="mailto:jowellsabino\@netscape.net">Jowell S.
Sabino</a>
 for OpenACS.
<h3>I. Essentials</h3>
<ul>
<li>User directory: <a href="/file-storage/">/file-storage/</a>
</li><li>Tcl procedures: <a href="/api-doc/procs-file-view?path=tcl%2ffile%2dstorage%2ddefs%2etcl">/tcl/file-storage-defs.tcl</a>
</li><li>Requirements document: <a href="requirements">/doc/requirements/file-storage.html</a>
</li><li>Data model: <a href="/doc/sql/display-sql?url=file-storage-create.sql&amp;package_key=file-storage">
file-storage-create.sql</a>
</li>
</ul>
<h3>II. Introduction</h3>
<p>We have our own file-storage application because we want all
users to be able to collaboratively maintain a set of documents.
Specifically, users can save their files to our server so that they
may:</p>
<ul>
<li>Organize files in a hierarchical directory structure</li><li>Upload using Web forms, using the file-upload feature of Web
browsers (potentially SSL-encrypted)</li><li>Grab files that are served bit-for-bit by the server, without
any risk that a cracker-uploaded file will be executed as code</li><li>Retrieve historical versions of a file</li>
</ul>
<p>We want something that is relatively secure, and can be extended
and maintained by any ArsDigita programmer, <em>i.e.</em>,
something that requires only AOLserver Tcl and Oracle skills.</p>
<p>In ACS 4, File Storage can be implemented on top of the Content
Repository. Thus, there is no data model associated with File
Storage. It is only a UI and a small set of Tcl and PL/SQL library
procedures. The actual storage and versioning is relegated to the
Content Repository.</p>
<h3>III. Historical Considerations</h3>
<p>File Storage was created to provide a mechanism for
non-technical users to collaborate on a wide range of documents,
with minimum sysadmin overhead. Specifically, it allowed clients to
exchange design documents (often MS Word, Adobe PDF, or other
proprietary desktop file formats) that changed frequently without
having to get bogged down by sifting through multiple versions.</p>
<h3>IV. Competitive Analysis</h3>
<p>Why is a file-storage application useful?</p>
<p>If you simply give everyone FTP access to a Web-accessible
directory, you are running some big security risks. FTP is insecure
and passwords are transmitted in the clear. A cracker might sniff a
password, upload Perl scripts or ADP pages, then grab those URLs
from a Web browser. The cracker is now executing arbitrary code on
your server with all the privileges that you&#39;ve given your Web
server.</p>
<p>The File Storage application is not a web-based file system, and
can not be fairly compared against such systems. The role of File
Storage is to provide a simple web location where users can share a
versioned document. It does not allow much functionality with
respect to aggregate file administration (ex. selecting all files
of a given type, or searching through specified file types).</p>
<h3>V. Design Tradeoffs</h3>
<h4>Folder Permissions</h4>
<p>Previous versions of File Storage have not included folder
permissions. (However they did have a concept of private group
trees.) The reasons for this were to simplify the code and the user
experience. However, this system actually caused some confusion
(<em>e.g.</em>, explicitly granting permission to an outsider on a
file in a group&#39;s private tree did not actually give that
person access to the file) and was not as flexible as people
desired. The ACS 4 version includes folder read, write and delete
permissions.</p>
<p>Note that this can create some funny results. For example, a
user might have write permission on a folder, but not on some of
its parent folders. This can cause the select box provided for
moving and copying files to look odd or misleading.</p>
<h4>Deletion of Files</h4>
<p>Previous versions of File Storage allowed only administrators to
actually delete content (although users could mark content as
"deleted" using a toggle in the data model, deleted_p.)
However, the proper use of versioning should allow users to avoid
accidentally losing their files. So, in this version, if a person
asks to delete a version or a file, we really delete it.</p>
<h4>Use of Content Repository</h4>
<p>Basing this system on the Content Repository provides a wealth
of useful functionality for File Storage with no additional
development costs. However, it may also constrain the system
somewhat.</p>
<p>The Content Repository&#39;s datamodel has been extended to
include an attribute to store the filesize. Unfortunately, the
Content Repository does not automatically do this, since files may
be stored on the filesystem (the Content Repository thus serving as
a catalog to keep track of file location and some metadata, but not
the filesize). The filesize is therefore calculated whenever a file
is inserted in the Content Repository by the external program (the
webserver&#39;s database driver) doing the insertion into the
database..</p>
<p>The content_revision is subtyped as a
"file-storage-item" to allow site-wide search to
distinguish file storage objects in its search results. This
feature is not implemented yet, however.</p>
<h4>Permissions Design</h4>
<p>Permissions were chosen to make as much use as possible of the
predefined privileges while keeping the connotative value of each
privilege clear. The permissions scheme is vaguely modeled off Unix
file permissions, with somewhat less overloading. In particular, we
define a delete privilege rather than overloading the write
permission. Also, execute privileges have no meaning in this
context.</p>
<table width="100%" border="2">
<tr>
<td></td><th bgcolor="#CCCCCC">Folder</th><th bgcolor="#CCCCCC">File</th><th bgcolor="#CCCCCC">Version</th>
</tr><tr>
<td align="right" bgcolor="#CCCCCC">read</td><td align="center">view and enter folder</td><td align="center">view file information</td><td align="center">view and download version</td>
</tr><tr>
<td align="right" bgcolor="#CCCCCC">write</td><td align="center">add new files / folders</td><td align="center">upload new versions</td><td align="center">-----</td>
</tr><tr>
<td align="right" bgcolor="#CCCCCC">delete</td><td align="center">delete folder</td><td align="center">delete file</td><td align="center">delete version</td>
</tr><tr>
<td align="right" bgcolor="#CCCCCC">admin</td><td colspan="3" align="center">modify permission grants and read,
write and delete privileges</td>
</tr>
</table>
<p>Some notes: the admin privilege implies the read, write and
delete privileges. It may be the case that a user has delete
permission on a folder or file, but not on some of its child items.
This will block attempts to delete the parent item. Finally, the
write permission does not have any meaning for versions.</p>
<h3>VI. API</h3>
<p>For the most part, File Storage will provide wrappers to the
Content Repository APIs.</p>
<h4>PL/SQL API</h4>
<p>File Storage provides public PL/SQL APIs either as wrappers to
the Content Repository API, or more involved functions that calls
multiple Content Repository PL/SQP functions. One reason for doing
this is to abstract from the Content Repository datamodel and
naming conventions, due to the different way File Storage labels
its objects.</p>
<p>The main objects of File Storage are "folders" and
"files". A "folder" is analogous to a
subdirectory in the Unix/Windows-world filesystem. Folder objects
are stored as Content Repostory folders, thus folders are stored
"as is" in the Content Repository.</p>
<p>"Files", however, can cause some confusion when stored
in the Content Repository. A "file" in File Storage
consists of meta-data, and possibly multiple versions of the
file&#39;s contents. The main meta-data of a "file" is
its "title", which is stored in the Content
Repository&#39;s "name" attribute of the cr_items table.
The "title" of a file should be unique within a
subdirectory, although a directory may contain a file and a folder
with the same "title".</p>
<p>Each version of a file is stored as a revision in cr_revisions
table of Content Repository. The Content Repository also allows
some meta-data about a version to be stored in this table, and
indeed File Storage uses attributes of the cr_revisions table are
used. However, this is where the confusion is created. The name of
the filename uploaded from the client&#39;s computer, as a version
of the file, is stored in the "title" attribute of
cr_revisions. Note that "title" is also used as the
(unique within a folder) identifier of the file stored in cr_items.
Thus, wrappers to the Content Repository API makes sure that the
naming convention is corect: cr_items.name attribute stores the
title of a file and all its versions, while the cr_revisions.title
attribute stores the filename of the version uploaded into the
Content Repository.</p>
<p>Meta-data about a version of a file stored in Content Repository
are the size of the version (stored in cr_revisions.content_length)
and version notes (stored in cr_revisions.description).</p>
<p>There are two internal PL/SQL functions that do not call the
Content Repository API, however: <code>get_root_folder</code> and
<code>new_root_folder</code>, defined in the <a href="/api-doc/plsql-subprogram-one?type=PACKAGE&amp;name=FILE%5fSTORAGE">
file_storage PL/SQL package</a>
</p>
<h4>Tcl API</h4>
<table width="100%"><tr><td bgcolor="#E4E4E4">
<h3><a href="/api-doc/proc-view?proc=children%5fhave%5fpermission%5fp">children_have_permission_p</a></h3><pre>
children_have_permission_p [ -user_id <em>user_id</em> ] <em>item_id</em><em>privilege</em>
</pre><blockquote>This procedure, given a content item and a privilege,
checks to see if there are any children of the item on which the
user does not have that privilege.
<dl>
<dt><strong>Switches:</strong></dt><dd>
<strong>-user_id</strong> (optional)<br>
</dd><dt><strong>Parameters:</strong></dt><dd>
<strong>item_id</strong><br><strong>privilege</strong><br>
</dd>
</dl>
</blockquote>
</td></tr></table>
<table width="100%"><tr><td bgcolor="#E4E4E4">
<h3><a href="/api-doc/proc-view?proc=fs%5fcontext%5fbar%5flist">fs_context_bar_list</a></h3><pre>
fs_context_bar_list [ -final <em>final</em> ] <em>item_id</em>
</pre><blockquote>Constructs the list to be fed to ad_context_bar
appropriate for item_id. If -final is specified, that string will
be the last item in the context bar. Otherwise, the name
corresponding to item_id will be used.
<dl>
<dt><strong>Switches:</strong></dt><dd>
<strong>-final</strong> (optional)<br>
</dd><dt><strong>Parameters:</strong></dt><dd>
<strong>item_id</strong><br>
</dd>
</dl>
</blockquote>
</td></tr></table>
<table width="100%"><tr><td bgcolor="#E4E4E4">
<h3><a href="/api-doc/proc-view?proc=fs%5ffile%5fdownloader">fs_file_downloader</a></h3><pre>
fs_file_downloader <em>conn</em><em>key</em>
</pre><blockquote>Sends the requested file to the user. Note that the
path has the original file name, so the browser will have a
sensible name if you save the file. Version downloads are supported
by looking for the form variable version_id. We don&#39;t actually
check that the version_id matches the path, we just serve it up.
<dl>
<dt><strong>Parameters:</strong></dt><dd>
<strong>conn</strong><br><strong>key</strong><br>
</dd>
</dl>
</blockquote>
</td></tr></table>
<table width="100%"><tr><td bgcolor="#E4E4E4">
<h3><a href="/api-doc/proc-view?proc=fs%5ffile%5fp">fs_file_p</a></h3><pre>
fs_file_p <em>file_id</em>
</pre><blockquote>Returns 1 if the file_id corresponds to a file in the
file-storage system. Returns 0 otherwise.
<dl>
<dt><strong>Parameters:</strong></dt><dd>
<strong>file_id</strong><br>
</dd>
</dl>
</blockquote>
</td></tr></table>
<table width="100%"><tr><td bgcolor="#E4E4E4">
<h3><a href="/api-doc/proc-view?proc=fs%5ffolder%5fp">fs_folder_p</a></h3><pre>
fs_folder_p <em>folder_id</em>
</pre><blockquote>Returns 1 if the folder_id corresponds to a folder in
the file-storage system. Returns 0 otherwise.
<dl>
<dt><strong>Parameters:</strong></dt><dd>
<strong>folder_id</strong><br>
</dd>
</dl>
</blockquote>
</td></tr></table>
<table width="100%"><tr><td bgcolor="#E4E4E4">
<h3><a href="/api-doc/proc-view?proc=fs%5fget%5ffolder%5fname">fs_get_folder_name</a></h3><pre>
fs_get_folder_name <em>folder_id</em>
</pre><blockquote>Returns the name of a folder.
<dl>
<dt><strong>Parameters:</strong></dt><dd>
<strong>folder_id</strong><br>
</dd>
</dl>
</blockquote>
</td></tr></table>
<table width="100%"><tr><td bgcolor="#E4E4E4">
<h3><a href="/api-doc/proc-view?proc=fs%5froot%5ffolder">fs_root_folder</a></h3><pre>
fs_root_folder [ -package_id <em>package_id</em> ]
</pre><blockquote>Returns the root folder for the file storage system.
<dl>
<dt><strong>Switches:</strong></dt><dd>
<strong>-package_id</strong> (optional)<br>
</dd>
</dl>
</blockquote>
</td></tr></table>
<table width="100%"><tr><td bgcolor="#E4E4E4">
<h3><a href="/api-doc/proc-view?proc=fs%5fversion%5fp">fs_version_p</a></h3><pre>
fs_version_p <em>version_id</em>
</pre><blockquote>Returns 1 if the version_id corresponds to a version in
the file-storage system. Returns 0 otherwise.
<dl>
<dt><strong>Parameters:</strong></dt><dd>
<strong>version_id</strong><br>
</dd>
</dl>
</blockquote>
</td></tr></table>
<h3>VII. Data Model Discussion</h3>
<p>File Storage uses only the Content Repository data model. There
is one additional table, <code>fs_root_folders</code>, which maps
between package instances and the corresponding root folders in the
Content Repository.</p>
<p>Inserting a row into the table fs_root_folders occurs the first
time the package instance is visited. The reason is that there is
no facility in APM to insert a row in the database every time a
package instance is created (technically, there is no "on
insert" trigger imposed by APM on Content Repository, since
they are separate packages even though they are both part of the
core). The solution to this deficiency is a bit hack-ish, but seems
to be the only solution available (unless APM allows trigger
functions to be registered, to be caled at package instance
creation). Whenever the package instance is first visited, it calls
a PL/SQL function that calculated the "root folder" of
the File Storage. If this function detects that there is no
"root folder" yet for this instance (as would be the case
when the instance is first visited), it inserts the package id and
a unique folder_id into the fs_root_folder table to serve as the
root folder identifier. It also inserts meta-data information about
this folder in cr_items table. Finally, it returns the newly
created folder identifier as the root folder for this package
instance. Subsequent visits to the package instance will detect the
root folder, and will then return the root folder identifier.</p>
<p>There is an "on delete cascade" constraint imposed on
the package_id attribute of fs_root_folders. The reason for this is
that whenever the package instance is deleted by the site
administrator, it automatically deletes the mapping between APM and
the Content Repository (i.e, the package identifier and the root
folder identified), and presumably the particular instance of File
Storage. Unfortunately this has an undesirable effect. There is no
corresponding "on delete cascade" on the Content
Repository objects so that deleting the root folder will cause
deletion of everything under the root folder. Left on its own, the
"on delete cascade" on the package identifier attribute
of fs_root_folders will cause all objects belonging to the instance
of File Storage deleted to be orphaned in the database, since the
root folder is the crucial link from which all content is
referenced!</p>
<p>The solution is (hopefully) more elegant: an "before on
delete" trigger that first cleans up all contents under the
root folder identifier before the root folder identifier is deleted
by APM. This trigger walks through all the contents of the instance
of File Storage, and starts deleting from the "leaves" or
end nodes of the file tree up to the root folder. Later
improvements in Content Repository will allow archiving of the
contents instaed of actually deleting them from the database.</p>
<h3>VIII. User Interface</h3>
<p>The user interface attempts to replicate the file system
metaphors familiar to most computer users, with folders containing
files. Adding files and folders are hyperlinked options, and a web
form is used to handle the search function. Files and folders are
presented with size, type, and modification date, alongside
hyperlinks to the appropriate actions for a given file. Admin
functions will be presented alongside the normal user action when
appropriate.</p>
<h3>IX. Configuration/Parameters</h3>
<p>There are two configuration parameters in this version of File
Storage. The first parameter <em>MaximumFileSize</em> is the
maximum size of uploaded files, which should be self-explanatory.
The other parameter is a flag that indicates to the package whether
files are stored in the database or in the webserver&#39;s
filesystem. This second parameter <em>StoreFilesInDatabaseP</em>
uses the new capability in Content Repository to use the Content
Repository as a mere catalog to store file information while the
actual file contents are stored in the webserver&#39;s filesystem.
Note that when files are stored in the filesystem, backups of the
database will only store the catalog, but not the contents. Thus,
it is important for the site administrator to store the entire
directory containing the Content Repository files (in particular,
<em>pageroot</em>/content-repository-content-files) when storing
files in the fiesystem.</p>
<p>When a file is stored in the Content Repository, it first
queries the parameter <em>StoreFilesInDatabaseP</em> to determine
how the new file will be stored. Thus, it is important that this
parameter should be changed only at package instance creation, or
before any operation that uploads a file into Content Repository.
Otherwise, the package instance will have files of different
storage types, depending on the value of the parameter at the time
the file is uploaded. Although all functionality provided by File
Storage will continue to work (copy, move, delete, etc.), backing
up the contents will be more complicated if the parameter is
changed.</p>
<p>All of the other parameters in previous versions have been made
obsolete by ACS 4 features like site-nodes and templating.</p>
<h3>X. Future Improvements/Areas of Likely Change</h3>
<ul>
<li>Allow people to comment on files (and versions and
folders?)</li><li>Implement searching on content (waiting for
site-wide-search)</li><li>Allow users to toggle folders open and closed
(javascript?)</li><li>Email alerts on folders/files (waiting for general alerts)</li><li>Allow people to change the name of files or folders</li><li>Right now, the newest revision is always live. We should
provide an option to choose the live revision.</li><li>You cannot copy folders at the moment. This is because it is
not required functionality and it is moderately hard. However,
people would probably like to have it.</li><li>Sorting. This is straightforward for the version without
expandable folders. It is more challenging once you can expand
folders.</li><li>We currently have a fairly hackish way of creating root folders
for new package instances. This was necessitated because there is
no mechanism in the current version of the ACS to specify code that
should be executed on package instantiation. In the future (4.1?),
this will change to something more tasteful.</li><li>Currently you have to restart the server to register the proc
that actually serves the files after you create a new site-node.
This is similar to the previous issue and will probably be dealt
with similarly.</li><li>We automatically add MIME types to <code>cr_mime_types</code>
if they aren&#39;t there already. However, we don&#39;t currently
have a way of entering the description at the same time, so we have
to display "application/msword" instead of "MS Word
Document", for example. We could use a method of determining
the canonical long form of a MIME type.</li>
</ul>
<h3>XI. Authors</h3>
<ul><li>System creator:<br>
</li></ul>
<blockquote>3.x : <a href="mailto:dh\@caltech.edu">David Hill</a>
and <a href="http://aure.com/">Aurelius Prochazka</a><br>
4.x : <a href="mailto:kevin\@arsdigita.com">Kevin
Scaldeferri</a>
</blockquote>
<ul><li>System owner</li></ul>
<blockquote><a href="mailto:kevin\@arsdigita.com">Kevin
Scaldeferri</a></blockquote>
<ul><li>Documentation author</li></ul>
<blockquote><a href="mailto:kevin\@arsdigita.com">Kevin
Scaldeferri</a></blockquote>
<h3>XII. Revision History</h3>
<table cellpadding="2" cellspacing="2" width="90%" bgcolor="#EFEFEF">
<tr bgcolor="#E0E0E0">
<th width="10%">Document Revision #</th><th width="50%">Action Taken, Notes</th><th>When?</th><th>By Whom?</th>
</tr><tr>
<td>0.1</td><td>Creation</td><td>11/6/2000</td><td>Kevin Scaldeferri</td>
</tr><tr>
<td>0.2</td><td>Revisions and Additions after Implementation</td><td>11/15/2000</td><td>Kevin Scaldeferri</td>
</tr><tr>
<td>0.2</td><td>Revised after review by Josh</td><td>11/16/2000</td><td>Kevin Scaldeferri, Josh Finkler</td>
</tr>
</table>
<hr>
<a href="mailto:kevin\@arsdigita.com">kevin\@arsdigita.com</a>

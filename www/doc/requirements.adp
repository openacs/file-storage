
<property name="context">{/doc/file-storage {File Storage}} {File-Storage Application Requirements}</property>
<property name="doc(title)">File-Storage Application Requirements</property>
<master>
<h2>File-Storage Application Requirements</h2>

by <a href="mailto:kevin\@arsdigita.com">Kevin Scaldeferri</a>
<h3>I. Introduction</h3>
<p>This document describes the requirements for ACS File-Storage
application. The file-storage application allows individuals to
place their files on a publicly accessible web site and share them
with other members of that web community or with the public at
large.</p>
<h3>II. Vision Statement</h3>
<p>The goal of a Web community is to facilitate the sharing of
information. This information can come in a variety of forms: text,
images, executable files, and web pages. The file storage
application should provide a convenient way for users to share
information in any of these formats. Users should be able to
determine which individuals or groups should be allowed to read
particular items and who should be allowed to upload new
versions.</p>
<p>Since information is only useful if you can find what you&#39;re
looking for, files in the file storage system should be searchable,
both from within the application and through any site-wide search
facilities.</p>
<h3>III. System/Application Overview</h3>
<p>The File-Storage application will consist primarily of a user
interface that allows individuals to manage their file-storage
folder(s) and to see other people&#39;s publicly accessible
files.</p>
<h3>IV. Use Case and User Scenarios</h3>
<h4>Using File-Storage to Run a Project</h4>
<p>In the course of her job at Acme Publishing Company,
<strong>Ursula User</strong> is working with people from several
different offices with whom she needs to exchange pictures and
Excel spreadsheets detailing cost estimates, and collaboratively
write contracts using Word. At any time, she and the other people
she works with need to be able to find the current copy of each of
these documents - and be able to look at older versions if need be
to track the evolution of the project. If the project is large,
Ursula will also need to be able to find all the documents
pertaining to a particular issue - so she will need a full-text
search feature.</p>
<p>For each project, Ursula makes a folder on the file-storage
system and gives read, write, and edit permission to the group of
people she is working with for that project. Then she makes
subfolders for each of the tasks for that project and asks
appropriate team members to start uploading versions of the
documents as soon as they have completed drafts. She downloads the
documents, edits them, adds comments to them, etc. Then she uploads
her new version to the same folder. She and the other members of
her team go back and forth with this until they have a version with
which they are satisfied. Occasionally, Ursula wants to ask someone
outside the group their opinion so she gives them read access to
just one version of a file so that they can download it and take a
look. Sometimes production tasks change; if so, Ursula can
rearrange the project&#39;s sub-folder hierarchy to make it more
closely reflect the new organizational scheme. When a project is
completed, if Ursula is considerate of the maintainers of the site
and of other users, she will clean-up after herself, downloading
the canonical version of all the documents to her local machine and
deleting the files from the server.</p>
<h4>Administer File-Storage</h4>
<p>
<strong>Annie Admin</strong> primarily has the job of
periodically cleaning up after users. If disk space is tight on the
server, she may want to look for files that haven&#39;t been
accessed in a long time and either encourage the owners of those
files to delete anything they don&#39;t need on the server anymore
or delete files herself if the user can&#39;t be contacted or is
unresponsive. Depending on the precise permissions implementation,
Annie may occasionally need to intercede when the owner of a file
accidentally revokes their own permission to access the file.</p>
<h3>V. Related Links</h3>
<ul>
<li><a href="design">Design Document</a></li><li><a href="index">System Overview Document</a></li>
</ul>
<h3>VI.A. Requirements: Data Model</h3>
<p><strong>10 The Data Model</strong></p>
<p>
<strong>10.1</strong> each file should have a unique
identifier</p>
<p>
<strong>10.2</strong> each version of a file should have a
unique identifier</p>
<p>
<strong>10.3</strong> each file should have an associated
owner</p>
<p>
<strong>10.4</strong> each version should have an associated
owner</p>
<p>
<strong>10.5</strong> files will be organized in a hierarchical
set of folders</p>
<p>
<strong>10.6</strong> each version of each file will have
individual read, write, delete, comment, and administer permissions
associated with it</p>
<h3>VI.B. Requirements: Administrator Interface</h3>
<p><strong>20 Administrator Interface</strong></p>
<p>
<strong>20.1</strong> the administrator should be able to view
all files in the file-storage system</p>
<p>
<strong>20.2</strong> the administrator should be able to edit,
delete, or alter permissions for any file belonging to any user</p>
<h3>VI.C. Requirements: User Interface</h3>
<p><strong>30 User Interface</strong></p>
<p>
<strong>30.1</strong> a user should be able to create folders
and subfolders in which he can place his files</p>
<p>
<strong>30.2</strong> a user should be able to add new files and
new versions of files</p>
<p>
<strong>30.3</strong> a user should be able to move files to
different folders or sub-folders</p>
<p>
<strong>30.4</strong> a user should be able to delete folders
and individual files</p>
<p>
<strong>30.5</strong> a user should be able to specify
permissions for any user or group on any folder, file, or
version.</p>
<p>
<strong>30.6</strong> a user should be able to download any
version which is accessible to him</p>
<p>
<strong>30.7</strong> a user should be able to view and/or edit
other user&#39;s files if the user has been granted individual or
group permission with access to the files</p>
<p>
<strong>30.8</strong> a user should be able to search the text
of the documents stored in the file-storage system (requires
full-text search capability from the database - in the case of
Oracle, requires InterMedia)</p>
<h3>VII. Revision History</h3>
<table cellpadding="2" cellspacing="2" width="90%" bgcolor="#EFEFEF">
<tr bgcolor="#E0E0E0">
<th width="10%">Document Revision #</th><th width="50%">Action Taken, Notes</th><th>When?</th><th>By Whom?</th>
</tr><tr>
<td>0.1</td><td>Creation</td><td>1 October 2000</td><td>Cynthia Kiser</td>
</tr><tr>
<td>0.2</td><td>Revision for ACS 4</td><td>3 November 2000</td><td>Kevin Scaldeferri</td>
</tr><tr>
<td>0.3</td><td>Revised based on review by Josh Finkler</td><td>6 November 2000</td><td>Kevin Scaldeferri, Josh Finkler</td>
</tr>
</table>
<hr>
<address><a href="mailto:kevin\@arsdigita.com">kevin\@arsdigita.com</a></address>

Last Modified: $&zwnj;Id: requirements.html,v 1.3.10.1 2016/07/16
17:36:38 gustafn Exp $

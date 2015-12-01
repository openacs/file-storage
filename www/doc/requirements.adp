
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
<p>Since information is only useful if you can find what you're
looking for, files in the file storage system should be searchable,
both from within the application and through any site-wide search
facilities.</p>
<h3>III. System/Application Overview</h3>
<p>The File-Storage application will consist primarily of a user
interface that allows individuals to manage their file-storage
folder(s) and to see other people's publicly accessible files.</p>
<h3>IV. Use Case and User Scenarios</h3>
<h4>Using File-Storage to Run a Project</h4>
<p>In the course of her job at Acme Publishing Company, <b>Ursula
User</b> is working with people from several different offices with
whom she needs to exchange pictures and Excel spreadsheets
detailing cost estimates, and collaboratively write contracts using
Word. At any time, she and the other people she works with need to
be able to find the current copy of each of these documents - and
be able to look at older versions if need be to track the evolution
of the project. If the project is large, Ursula will also need to
be able to find all the documents pertaining to a particular issue
- so she will need a full-text search feature.</p>
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
rearrange the project's sub-folder hierarchy to make it more
closely reflect the new organizational scheme. When a project is
completed, if Ursula is considerate of the maintainers of the site
and of other users, she will clean-up after herself, downloading
the canonical version of all the documents to her local machine and
deleting the files from the server.</p>
<h4>Administer File-Storage</h4>
<p>
<b>Annie Admin</b> primarily has the job of periodically
cleaning up after users. If disk space is tight on the server, she
may want to look for files that haven't been accessed in a long
time and either encourage the owners of those files to delete
anything they don't need on the server anymore or delete files
herself if the user can't be contacted or is unresponsive.
Depending on the precise permissions implementation, Annie may
occasionally need to intercede when the owner of a file
accidentally revokes their own permission to access the file.</p>
<h3>V. Related Links</h3>
<ul>
<li><a href="design">Design Document</a></li><li><a href="index">System Overview Document</a></li>
</ul>
<h3>VI.A. Requirements: Data Model</h3>
<p><b>10 The Data Model</b></p>
<p>
<b>10.1</b> each file should have a unique identifier</p>
<p>
<b>10.2</b> each version of a file should have a unique
identifier</p>
<p>
<b>10.3</b> each file should have an associated owner</p>
<p>
<b>10.4</b> each version should have an associated owner</p>
<p>
<b>10.5</b> files will be organized in a hierarchical set of
folders</p>
<p>
<b>10.6</b> each version of each file will have individual read,
write, delete, comment, and administer permissions associated with
it</p>
<h3>VI.B. Requirements: Administrator Interface</h3>
<p><b>20 Administrator Interface</b></p>
<p>
<b>20.1</b> the administrator should be able to view all files
in the file-storage system</p>
<p>
<b>20.2</b> the administrator should be able to edit, delete, or
alter permissions for any file belonging to any user</p>
<h3>VI.C. Requirements: User Interface</h3>
<p><b>30 User Interface</b></p>
<p>
<b>30.1</b> a user should be able to create folders and
subfolders in which he can place his files</p>
<p>
<b>30.2</b> a user should be able to add new files and new
versions of files</p>
<p>
<b>30.3</b> a user should be able to move files to different
folders or sub-folders</p>
<p>
<b>30.4</b> a user should be able to delete folders and
individual files</p>
<p>
<b>30.5</b> a user should be able to specify permissions for any
user or group on any folder, file, or version.</p>
<p>
<b>30.6</b> a user should be able to download any version which
is accessible to him</p>
<p>
<b>30.7</b> a user should be able to view and/or edit other
user's files if the user has been granted individual or group
permission with access to the files</p>
<p>
<b>30.8</b> a user should be able to search the text of the
documents stored in the file-storage system (requires full-text
search capability from the database - in the case of Oracle,
requires InterMedia)</p>
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

Last Modified: $&zwnj;Id: requirements.html,v 1.3 2005/05/26 08:28:46
maltes Exp $

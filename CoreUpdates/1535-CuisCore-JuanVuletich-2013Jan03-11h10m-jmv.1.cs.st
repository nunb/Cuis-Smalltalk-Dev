'From Cuis 4.1 of 12 December 2012 [latest update: #1532] on 3 January 2013 at 11:15:03 am'!

!ContentPack commentStamp: 'jmv 1/3/2013 11:14' prior: 0!
ContentPack lets you read in and write out the (supported files in the) contents of a directory on your file system. It also allows you to trivially create "messenger" subclasses that capture the information containted in these directory trees, including any implicit communication that's there in the structure of the directory hierarchy itself, which are captured in your changes file. You can then file out a change set that contains a representation of the (supported file/object types and directory structurein) the stuff on your disk, or in your image. This subclass is a dummy which ContentPack compiles methods into containing base 64 encoded data. You can load this into another image, as long as that image has ContentPack loaded. The filed in class can then recreate the ContentPack on the other end with the media files and structure intact.

The current implementation is based on #storeString, but the plan is to change that to SmartRefStream in the long run to support serializing things like morphs.

ContentPack instances hang onto the actual tree of media objects. It has a nice simple EDSL that just interprets an array of strings from beginning to end as a "path" to a file (really a series of dictionary lookups to a Smalltalk object, wherin the dictionaries mirror the structure of what was on the disk, sans unsupported files.) This mechanism will likely change a little bit at some point, 

ContentPack came into the world a little faster than I expected, as I ended up using it to send some icons back in time to fix the Cuis update stream without having to sort my changes all over again. As such it had some unusual design pressures... it had to be able to carry information in and out of both the change set stream and the filesystem, as well as function in a slightly earlier (unreleased) version of Cuis than it was written in, and not break anything on it's way back up through the build to head.

The code, in particular the way things are named, has not settled yet, and that's why this comment contains no code examples. Use with care and read the code first, for now.

Currently, .bmp import and .png import are implemented, and both can be exported. Anything you can import, you can also shuffle into a change set. Plans are in the works to support audio, change sets, and text files. I'll support video if someone has a good importer, exporter, and player under the MIT license that'll work under Cuis. 

Currently, objects are serialized into single methods, which works for small icons, but likely doesn't work well (if at all) for larger files. My intent is to add some behavior that breaks up large objects into smaller chunks so that this becomes a non-issue. I'll likely get to that when I've removed most of the repetitive subtle variations of the same recursive tree walking visitor-trick from the code, and renamed everything. I think in essence this class is slightly smaller than it is as represented currently.

Hopefully I will be able to explain all of this better once I've clarified the code a bit so that I can show off some examples.

	- cbr

-----------------------------------
Alternative description (need to merge both!!)

Forms (and potentially other media types) can exist in three forms:

1) As external files, such as jpg, png, etc. This is the representation we need to use external tools (such as image processing apps, cameras, scanners, web, etc) to work on them.
2) As methods. Non human readable, base-64 encoded binary data. We need this to be able to include such stuff in the update stream, or in packages. After we update an image, we usually delete these methods, just keeping 3).
3) Live objects in the image, for example, stored in class variables. This is to make use of them in Cuis.

Most of the time, we use 3). But we need 2) for the update stream. We also need 1) sometimes to work on them. ContentPack supports the conversion between these 3 formats. The implementation is quite simple. What is really great is that Casey realized we need some tool to move comfortably between these 3 representations. And he also implemented it.

Please grab http://www.jvuletich.org/Cuis/CuisUpdatesUpTo1511.zip and take a look at updates 966, 967 and 968.  

	- jmv!


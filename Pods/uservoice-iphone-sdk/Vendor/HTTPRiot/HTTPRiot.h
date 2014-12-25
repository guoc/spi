/*
 * Copyright (c) 2009 Justin Palmer <encytemedia@gmail.com>, All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *   Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 *   Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 *   Neither the name of the author nor the names of its contributors may be used
 *   to endorse or promote products derived from this software without specific
 *   prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*/

/**
@mainpage HTTPRiot - A simple HTTP REST Library

@image html httpriot.png

@li <a href="http://labratrevenge.com/httpriot">HTTPRiot homepage</a>
@li <a href="https://github.com/Caged/httpriot/tree/master">Source Code</a>
@li <a href="http://twitter.com/Caged">Twitter</a>

HTTPRiot is a simple REST library designed to make interacting with REST services 
much easier.  It supports GET, POST, PUSH and DELETE requests and HTTP Basic Authentication.
HTTPRiot was inspired by John Nunemaker's excellent 
<a href="http://github.com/jnunemaker/httparty/tree/master">httparty</a> Ruby library.

<div id="guides">
    <span class="ttl">Related Guides</span>
     <ul>
        <li>@subpage iphone-setup</li>
        <li>@subpage cocoa-setup</li> 
    </ul>
</div>

<h3>Some Examples</h3>

<h4>Send a GET request</h4>
@code
[HRRestModel getPath:@"/person.json" withOptions:nil object:nil];
@endcode

<h4>Send a POST request with JSON body data</h4>
@code
NSDictionary *opts = [NSDictionary dictionaroyWithObject:[person JSONRepresentation] forKey:@"body"];
[HRRestModel postPath:@"/person" withOptions:opts object:nil];
@endcode

<h4>Send a PUT request</h4>
@code
NSDictionary *opts = [NSDictionary dictionaroyWithObject:[updatedPerson JSONRepresentation] forKey:@"body"];
[HRRestModel putPath:@"/person" withOptions:opts object:nil];
@endcode

<h4>Send a DELETE request</h4>
@code
[HRRestModel deletePath:@"/person/1" withOptions:nil object:nil];
@endcode

<h3>Subclassing HRRestModel</h3>
Although you can use HTTPRiot straight out of the box by itself, this approach has some pitfals.
Every request will share the same configuation options. By subclassing HRRestModel you can have 
per-class configuation options meaning that all requests generating from your subclass share a 
local set of configuation options and will not affect other requests not originating from your subclass.

@include Tweet.m

@page iphone-setup Using the HTTPRiot Framework in your iPhone Applications

HTTPRiot comes with a simple SDK package that makes it very easy to get up and running quickly 
on the iphone.  You'll need to put this SDK package somewhere where it won't get deleted and you 
can share it with all your iPhone projects.

<p><strong>NOTE:  Make sure you select "All Configurations" in the Build tab before changing any settings.</strong></p>

-# Move the httpriot-* directory to <strong><tt>~/Library/SDKs</tt></strong>.  You might need to create this directory.
   It's not mandatory that it lives in this location, but it's a good idea that you put it somewhere 
   where it can be shared.
-# Create a new project or open an existing project in XCode.  Select your application's target and 
   press<strong class="key"> ⌘i</strong> to bring up the properties window.  Set the <strong><tt>Additional SDKs</tt></strong>
   property to <strong><tt>~/Library/SDKs/httpriot-0.4.0/\$(PLATFORM_NAME)\$(IPHONEOS_DEPLOYMENT_TARGET).sdk</tt></strong>
   @image html additional-sdks.png
-# Set the <strong><tt>Other Linker Flags</tt></strong> to <tt>-lhttpriot -lxml2 -ObjC -all_load</tt></strong> 
   @image html other-linker-flags.png
*/
//-# Set <strong><tt>Header Search Paths</tt></strong> to <strong><tt>/usr/include/libxml2/**</tt></strong>
//-# Use <strong><tt>\#include <HTTPRiot/HTTPRiot.h></tt></strong> in one of your application's files. 
//   That's it!  Now you're ready to use HTTPRiot!
/*
@page cocoa-setup Using the HTTPRiot Framework in your Desktop Applications

-# Right click Other Frameworks in XCode and select <tt>Add &rarr; Existing Frameworks</tt>.  Select 
   the <strong><tt>HTTPRiot.framework</tt></strong> and press <tt>Add</tt>. @image html httpriot-framework.png
-# Include the framework <strong><tt>\#include <HTTPRiot/HTTPRiot.h></tt></strong> in your project.  That's it!

<h3>Embedding HTTPRiot.framework in your application</h3>
If you want to distribute HTTPRiot.framework with your application you'll need to do another step.

-# Right click your target name and select <tt>"Add > New Build Phase > New Copy Files Build Phase"</tt>.
   Set <tt>Frameworks</tt> as the destination path in the popup. @image html copy-files.png
-# Drag the HTTPRiot.framework file to this new phase.
*/

#import <Foundation/Foundation.h>
#import "HROperationQueue.h"
#import "HRRequestOperation.h"
#import "HRRestModel.h"
#import "HRResponseDelegate.h"

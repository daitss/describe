Format Description Service
==========================
* Format identification via TNA DROID software.
* Using the identification result, find appropriate JHOVE validator.  
* Format validation and characterization using JHOVE
* Transform the result of format characterization into standard schema such as TextMD, DocMD, MIX and AES
* Transform the format description result into PREMIS schema

Quickstart
----------
	%ruby describe.rb
	
	To test the installation, 
	%rake spec
	%cucumber feature/*

Requirements
------------
* ruby (tested on 1.8.6 and 1.8.7)
* java (tested on 1.5 and 1.6)
* cucumber (gem)
* libxml-ruby (gem)
* ruby-xslt (gem)
* rjb (gem. Please make sure JAVA_HOME is set when installing rjb, see http://rjb.rubyforge.org/ for detail)
* rspec (gem)
* log4r (gem)
* sinatra (gem) - a minimal web application framework.  It will work with any web server such as mongrel, thin, etc.

License
-------
GNU General Public License

Directory Structure
-------------------
* config: configuration files, including a copy of DROID signature file, jhove config file 
  and configuration to lookup associated validator on a given PUID.
* feature: cucumber feature files
* files: contain test files for test harness. These files are for testing only and can be deleted after deployment.
* jars: contain required java jars for droid and jhove.
* lib: ruby source code
* public: files for public access including jQuery and a sample text file for testing http url.
* spec: rspec files
* views: erb templates
* xsl: stylesheets for schema transformation

Usage
-----
* Use http GET method with a location parameter pointing to the FILE url of the intended file.  
  For example, if using curl
  curl http://localhost:4567/describe?location=file///Users/Desktop/describe/files/etd.pdf

* Use http GET method with a location parameter pointing to the http url of the intended resource.
  For example, if using curl
  curl http://localhost:4567/describe?location=http://localhost:4567/test.txt

* Use the associated form to upload a file to the description service via HTTP POST method.

Documentation
-------------
[development wiki](http://wiki.github.com/cchou/describe)

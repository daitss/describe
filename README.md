Format Description Service
==========================
* Format identification via TNA DROID software.
* Using the identification result, find appropriate JHOVE validator.  
* Format validation and characterization using JHOVE
* Transform the result of format characterization into standard schema such as TextMD, DocMD, MIX and AES
* Transform the format description result into PREMIS schema

Quickstart
----------
	1. Retrieve a copy of the description service.  You can either create a local git clone of the description service, ex.
	%git clone git://github.com/daitss/describe.git
	or download a copy from the download page.
	
	2. Install all the required gems according to the Gemfile in this project
	% bundle install
	
	3. Test the installation via the test harness. The provided test harness will retrieve test files from http://www.fcla.edu/daitss-test/files/.  
	   Please make sure the internet is connected when running the test harness.
	
	%bundle exec cucumber feature/*
	
	4. Run the description srvice with thin (use "thin --help" to get additional information on using thin)
	%thin start 
	
Requirements
------------
* ruby (tested on 1.8.6 and 1.8.7)
* java (tested on 1.5 and 1.6)
* bundler (gem, http://gembundler.com/)
* cucumber (gem, http://cukes.info/)
* libxml-ruby (gem)
* ruby-xslt (gem)
* rjb (gem. Please make sure JAVA_HOME is set when installing rjb, see http://rjb.rubyforge.org/ for detail.  
  On OSX, the JAVA_HOME should be set to "/Library/Java/Home")
* rspec (gem)
* log4r (gem)
* sinatra (gem) - a minimal web application framework.  It will work with any web server such as mongrel, thin, etc.

License
-------
GNU General Public License

Directory Structure
-------------------
* config: configuration files, including a copy of DROID signature file, JHOVE config file, 
  configuration to lookup associated validator on a given PUID, format tree and FDA format collection.
* features: cucumber feature files. 
* jars: contain required java jars for DROID and JHOVE.
* lib: ruby source code
* public: files for public access including jQuery and a sample text file for testing http url.
* spec: rspec files
* views: erb templates
* xsl: stylesheets for schema transformation

Usage
-----
* Use http GET method with a location parameter pointing to the FILE url of the intended file.  
  For example, if using curl
  curl http://localhost:3000/describe?location=file///Users/Desktop/describe/files/etd.pdf

* Use http GET method with a location parameter pointing to the http url of the intended resource.
  For example, if using curl
  curl http://localhost:3000/describe?location=http://www.fcla.edu/daitss-test/files/00004.txt

* Use the browser to submit a file to the description service via HTTP POST method.  Alternatively, the 
  HTTP POST method can also be used with curl, for example,
  curl -F "document=@files/00001.pdf" -F "extension=pdf" http://localhost:4567/description

Documentation
-------------
[development wiki](http://wiki.github.com/daitss/describe/)

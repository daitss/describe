Description Service
==========================
* Format identification via TNA DROID software.
* Using the identification result, find appropriate JHOVE validator.  
* Format validation and characterization using JHOVE
* Transform the result of format characterization into standard schema such as TextMD, DocMD, MIX and AES
* Transform the format description result into PREMIS schema
 
Current Production Code
-----------------------
* Release 2.4.1, https://github.com/daitss/describe/releases/tag/v2.4.1

Requirements
------------
* ruby (tested on 1.8.6 and 1.8.7) - Please use ruby1.8.7 branch
* ruby 1.9.3
* java (tested on 1.5, 1.6, 1.7)
* ruby-devel, rubygems, git and g++
* zlib, libxml2-devel and libxslt-devel development libraries
* bundler gem (http://gembundler.com/)
* cucumber gem (http://cukes.info/)
* rjb gem (Please make sure JAVA_HOME is set when installing rjb, see http://rjb.rubyforge.org/ for detail.  
  On OSX, the JAVA_HOME should be set to "/Library/Java/Home")
* sinatra gem - a minimal web application framework.  It will work with any web server such as mongrel, thin, etc.

Quickstart
----------
	1. Retrieve a copy of the description service.  You can either create a local git clone of the description service, ex.
	% git clone git://github.com/daitss/describe.git
	or download a copy from the download page.
	
	2. Install all the required gems according to the Gemfile in this project
	% bundle install
	
	3. Add lib/ path to RUBYLIB environment variable
	% export RUBYLIB=lib:$RUBYLIB
	
	4. Test the installation via the test harness. The provided test harness will retrieve test files from http://www.fcla.edu/daitss-test/files/.  
	   Please make sure the internet is connected when running the test harness.
	
	% bundle exec cucumber feature/*
	
	5. Run the description srvice with thin (use "thin --help" to get additional information on using thin). Please
	   make sure the DAITSS_CONFIG variable and the VIRTUAL_HOSTNAME environement variables are set, see daitss-config.examle.yml
	   for details.
	% bundle exec thin start 

License
-------
GNU General Public License

Directory Structure
-------------------
* config: directory containing configuration files for setting up the description service including 
  1. a copy of DROID signature file (DROID_SignatureFile.xml),
  2. JHOVE config file (jhove.conf)
  3. settings for the description service (describe.yml)
  4. supported format validators (validators.xml)
  5. configuration to lookup associated validator on a given format identifier (PUID) (format2validator.xml)
  6. A format tree specifying formats from general to the most specific, used for identifying the most specific format (format_tree.xml)
  7. A lookup table to look up the format identifier given a format description returned from the validator.  For example,
     DROID would return a list of formats for a TIFF file (fmt/7 - fmt/10 for TIFF 3.0 - TIFF 6.0), after format validation through JHOVE,
     JHOVE would return the the version of the TIFF file, ex TIFF 6.0.  The description service would then map TIFF 6.0
     back to fmt/10 and record only the fmt/10 (TIFF 6.0) on the format section of its premis output.
  8. A collection of FDA format registry which assign a temporary format identifier for those formats not yet
     supported in PRONOM (FDA_FormatRegistry.xml)
* features: cucumber feature files. 
* jars: contain required java jars for DROID and JHOVE.
* lib: ruby source code
* public: files for public access including jQuery and a sample text file for testing http url.
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

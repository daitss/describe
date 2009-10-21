Format Description Service
==========================
* Format identification via TNA DROID software.
* Using the identification result, find appropriate JHOVE validator.  
* Format validation and characterization using JHOVE
* Transform the result of format characterization into standard schema such as TextMD, DocMD, MIX and AES
* Transform the format description result into PREMIS schema

Quickstart
----------
ruby describe.rb
To test the installation, run "rake spec" and "cucumber feature/*".

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
* Use  http GET method with a location parameter, pointing to the FILE url of a pdf file.  
  For example, use
  "curl http://localhost:3002/describe?location=file///Users/Desktop/describe/files/etd.pdf"
   if using curl.

* Use  http GET method with a location parameter, pointing to the http url of a text file.  
  For example, use
  "curl http://localhost:3002/describe?location=http://localhost:4567/test.txt" if using curl

* Use the associated form to use http POST method to upload a file to the description service 
  using the HTTP POST method.

Format Identification, Validation and Characterization
------------------------------------------------------------------------
* The format identification is performed via Droid.  Based on the format signatures 
  exhibited in the specified url (file or http), Droid will return the PUIDs matching the 
  format signatures in the file(URL).
  > If there is no PUID returned from Droid => return the general metadata including file size and 
  > checksum, with the format name set to 'unknown" 
  >
  > If droid returns one or more PUIDs, find the validator(s) associated with each PUID.
  >
  > If there is no defined validator for any PUID, return the PUID with general metadata
  >
  > If there is only one validator for all of the PUIDs, => proceed to format validation and characterization.
  >
  > If there are multiple validators, retrieve a prioritized list of validators using an evaluator.
  > and validate the file with each validator (in B) until it is determined to be valid and well-formed 
  > by a validator or the service exhausts all applicable validators.

* The description service implements to the format validation and characterization process via JHOVE validators.  
  The validator should return the validation result, anomalies and all technical metadata extracted from the file (URL). 
  > If the required metadata is missing (for example, missing MIX or AES.  This indicates the possibility of  bugs 
  >
  > in the validator), log an internal service message for developers. 

* Transform extracted technical metadata, anomaly and associated format information into a PREMIS document.

* How the evaluator works:  Given a list of validators, return a prioritized list of validators.  Each validator will be 
 assigned a priority value.  A higher value indicates higher priority.  For example, UTF8 validator will 
 have priority value 1 whereas ASCII validator will have priority 2.  If a file matches the signatures for 
 both ASCII and UTF8, the evaluator will return the both UTF8 and ASCII validators but with ASCII having 
 higher priority in the list.


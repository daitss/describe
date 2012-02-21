Feature: retrieve the description on a tiff resource
Scenario: TIFF 4.0
	Given a TIFF 4.0 file
 	When describing the file
	Then I should receive fmt/353 on the format id
	And the status should be ok
	And mix should exist
	
Scenario: TIFF 5.0
	Given a TIFF 5.0 file
 	When describing the file
	Then I should receive fmt/353 on the format id
	And the status should be ok
	And mix should exist
	
Scenario: TIFF 6.0
	Given a TIFF 6.0 file
 	When describing the file
	Then I should receive fmt/353 on the format id
	And the status should be ok
	And mix should exist
	
Scenario: GeoTiff
	Given a GeoTiff file
	When describing the file
	Then I should receive GeoTIFF on the format
	And the status should be ok
	And mix should exist

Scenario: TIFF with flash, meteringMode and exposureBiasValue metadata
	Given a TIFF file with flash, meteringMode and exposureBiasValue metadata
 	When describing the file
	Then the status should be ok
	And mix should exist
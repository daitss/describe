Feature: retrieve the description on a tiff resource
Scenario: TIFF 4.0
	Given a TIFF 4.0 file
 	When describing the file
	Then I should receive fmt/8 on the format id
	And the status should be ok
	And mix should exist
	
Scenario: TIFF 5.0
	Given a TIFF 5.0 file
 	When describing the file
	Then I should receive fmt/9 on the format id
	And the status should be ok
	And mix should exist
	
Scenario: TIFF 6.0
	Given a TIFF 6.0 file
 	When describing the file
	Then I should receive fmt/10 on the format id
	And the status should be ok
	And mix should exist
	
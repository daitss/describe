Feature: retrieve the description on an unsupported resources
	Scenario: format of the resource cannot be identified
		Given a file with unknown format 
		When describing the file
		Then I should receive unknown on the format name
		And the status should be ok
		And the general metadata should exist
		
		
	Scenario: format of the resource can be identified but not be validated or extracted.
		Given a file whose format is power point
		When describing the file
		Then I should receive Microsoft Powerpoint Presentation on the format name
		And the status should be ok
		And the general metadata should exist
		
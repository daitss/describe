Feature: retrieve the description on an unsupported resource
	Scenario: format of the resource cannot be identified
		Given a file with unknown format 
		When describing the file
		Then I should receive Unknown on the format name
		And the status should be ok
		And the general metadata should exist
		
		
	Scenario: format of the resource can be identified but not be validated or extracted.
		Given a file whose format is power point
		When describing the file
		Then I should receive Microsoft Powerpoint Presentation on the format name
		And the status should be ok
		And the general metadata should exist
		
	Scenario: resource can be identified as multiple formats but can not be validated or extracted.
		Given PENDING a file whose format is mpeg
		When describing the file
		Then I should receive fmt/425 on the format id		
		And the status should be ok
		And the general metadata should exist
		
	Scenario: resource can be identified as multiple formats with versions but can not be validated or extracted.
		Given a file whose format is mdb
		When describing the file
		Then I should receive Microsoft Access Database on the format name
		And the status should be ok
		And the general metadata should exist
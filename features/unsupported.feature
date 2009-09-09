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
		
	Scenario: resource can be identified as multiple formats but can not be validated or extracted.
		Given a file whose format is mpeg
		When describing the file
		Then I should receive MPEG-1 Video Format, MPEG-2 Video Format on the format name
		And the status should be ok
		And the general metadata should exist
		
		Scenario: resource can be identified as multiple formats with versions but can not be validated or extracted.
			Given a file whose format is mdb
			When describing the file
			Then I should receive Microsoft Access Database 2.0, Microsoft Access Database 95, Microsoft Access Database 97, Microsoft Access Database 2002 on the format name
			And the status should be ok
			And the general metadata should exist
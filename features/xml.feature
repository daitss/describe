Feature: retrieve the description on a XML resource
Scenario: describe an xml file with double quote signature
	Given a double-quoted xml file
	When describing the file
	Then I should receive XML on the format name
	And the status should be ok
	And textmd should exist
	
Scenario: describe an xml file with single quote signature
	Given a single-quoted xml file
	When describing the file
	Then I should receive XML on the format name
	And the status should be ok
	And textmd should exist
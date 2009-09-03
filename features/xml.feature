Feature: retrieve the description on a XML resource
Scenario: describe an xml file
	Given a xml file
	When describing the file
	Then I should receive XML on the format name
	And the status should be ok
	And textmd should exist
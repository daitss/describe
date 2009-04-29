Feature: retrieve the description on an empty resource
	Scenario: empty file
		Given an empty file
		When describing the file
		Then I should receive N/A on the format name
		And the status should be ok

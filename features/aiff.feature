Feature: retrieve the description on an aiff resource
Scenario: aiff
	Given an aiff file
	When describing the file
	Then I should receive Audio Interchange File Format on the format
	And the status should be ok
	And aes should exist

Scenario: compressed aiff (aifc)
	Given an aifc file
	When describing the file
	Then I should receive Audio Interchange File Format (compressed) on the format
	And the status should be ok
	And aes should exist
	
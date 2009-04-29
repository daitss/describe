Feature: retrieve the description on an aiff resource
Scenario: aiff
	Given an aiff file
	When describing the file
	Then I should receive x-fmt/135 on the format id
	And the status should be ok
	And aes should exist

Scenario: compressed aiff (aifc)
	Given an aifc file
	When describing the file
	Then I should receive x-fmt/136 on the format id
	And the status should be ok
	And aes should exist
	
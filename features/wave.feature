Feature: retrieve the description on an wave resource
Scenario: wave
	Given a wave file
	When describing the file
	Then I should receive fmt/6 on the format id
	And the status should be ok
	And aes should exist
	
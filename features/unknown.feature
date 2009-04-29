Feature: retrieve the description on an unsupported resource
	Scenario: unsupported resource
		Given a file whose format is currently unsupported
		When describing the file
		Then I should receive unknown on the format name
		And the status should be ok
		And the general metadata should exist
		
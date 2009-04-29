Feature: describe an encrypted resource
	Scenario: encrypted PDF 
		Given an password-protected PDF file
		When describing the file
		Then I should receive inhibitor whose type is 'password protected'
		And the status should be ok


Feature: retrieve the description on a PDF resource
	Scenario: PDF 1.3
		Given a PDF 1.3 file
		When describing the file
		Then I should receive fmt/17 on the format id
		And the status should be ok
		And the docmd should exist
		
	Scenario: PDF 1.4
		Given a PDF 1.4 file
		When describing the file
		Then I should receive fmt/18 on the format id
		And the status should be ok
		And the docmd should exist

	Scenario: PDF 1.5
		Given a PDF 1.5 file
		When describing the file
		Then I should receive fmt/19 on the format id
		And the status should be ok
		And the docmd should exist
		
	Scenario: PDF 1.6
		Given a PDF 1.6 file
		When describing the file
		Then I should receive fmt/20 on the format id
		And the status should be ok
		And the docmd should exist
				
	Scenario: PDF 1.7
		Given a PDF 1.7 file
		When describing the file
		Then I should receive 1.7 on the format version
		And the status should be ok
		And the docmd should exist
				
	Scenario: PDF/A-1b
		Given a PDF/A conformed file
		When describing the file
		Then I should receive PDF/A-1b on the format profile
		And the status should be ok
		And the docmd should exist		
	
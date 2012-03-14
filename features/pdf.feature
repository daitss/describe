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
	    And I should receive fmt/276 on the format id
		And the status should be ok
		And the docmd should exist
				
	Scenario: PDF/A-1b
		Given a PDF/A conformed file
		When describing the file
		Then I should receive Acrobat PDF/A - Portable Document Format on the format
		And the status should be ok
		And the docmd should exist		
	
	Scenario: PDF with multiple images
		Given a PDF embedded with multiple images
		When describing the file
		Then I should receive 19 bitstreams
		And the status should be ok
		And the docmd should exist
		
	Scenario: PDF with embedded language metadata
		Given a PDF with embedded language metadata
		When describing the file
		Then I should have EN on the language element
		And the status should be ok
		And the docmd should exist
		
	Scenario: Tagged PDF
		Given a tagged PDF file
		When describing the file
		Then I should have isTagged on the feature element
		And the status should be ok
		And the docmd should exist

	Scenario: Annotated PDF
		Given a PDF with annotations
		When describing the file
		Then I should have hasAnnotations on the feature element
		And the status should be ok
		And the docmd should exist
		
	Scenario: PDF with CreatingApplication but not CreateDate
		Given a PDF with CreatingApplication but not CreateDate
		When describing the file
		Then the status should be ok
		And the docmd should exist					

	Scenario: PDF with bad Encoding property in its font dictionary
		Given a PDF with bad Encoding property in its font dictionary
		When describing the file
		Then the status should be ok
		And the docmd should exist					
	
	Scenario: non-wellformed PDF
		Given a non-wellformed PDF 
		When describing the file
		Then the status should be ok
		And I should receive eventDetail equal to 'Not well-formed'
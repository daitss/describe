Feature: retrieve metadata relating to creating application 
Scenario: retrieve application metadata on a tiff
	Given tiff with application metadata
	When  describing the file
	Then I should receive creating application in premis
	And the status should be ok
	
Scenario: retrieve application metadata on a pdf
	Given pdf with application metadata
	When  describing the file
	Then I should receive creating application in premis
	And the status should be ok
	
Feature: retrieve the description on an image resource
  Scenario: jpeg
  	Given a jpeg file
  	When describing the file
  	Then I should receive fmt/43 on the format id
  	And the status should be ok
  	And mix should exist

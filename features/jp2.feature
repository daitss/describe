Feature: retrieve the description on an image resource
  Scenario: jp2
  	Given a jp2
  	When describing the file
  	Then I should receive x-fmt/392 on the format id
  	And the status should be ok
  	And mix should exist
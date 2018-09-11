Feature: retrieve the description on an image resource
  Scenario: jpeg
  	Given a jpeg file
  	When describing the file
  	Then I should receive fmt/43 on the format id
  	And the status should be ok
  	And mix should exist

  Scenario: jpeg from ufdc
  	Given a jpeg file from ufdc
  	When describing the file
  	Then I should receive fmt/43 on the format id
  	And the status should be ok
  	And mix should exist

  Scenario: jpeg ith ExposureBiasValue metadata
    Given a jpeg file with ExposureBiasValue metadata
    When describing the file
    Then I should receive fmt/43 on the format id
    And the status should be ok
    And mix should exist

  Scenario: jpeg ith brightnessValue metadata
    Given a jpeg file with brightnessValue metadata
    When describing the file
    Then I should receive fmt/43 on the format id
    And the status should be ok
    And mix should exist    
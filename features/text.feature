Feature: retrieve the description on a resource associated with multiple identifiers (multiple validators)
Scenario: describe an ascii file
	Given an ascii file
	When describing the file
	Then I should receive ASCII on the format name
	And the status should be ok
	# And textmd should exist

Scenario: describe an utf-8 file
  Given an utf-8 file
  When describing the file
  Then I should receive UTF-8 on the format name
  And the status should be ok
  And textmd should exist

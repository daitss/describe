Feature: retrieve the description on a resource associated with multiple identifiers (multiple validators)
Scenario: describe an ascii file
	Given an ascii file
	When describing the file
	Then I should receive Plain Text File on the format name
	And I should receive x-fmt/111 on the format id
	And the status should be ok
	# And textmd should exist

Scenario: describe an utf-8 file
  Given an utf-8 file
  When describing the file
  Then I should receive Unicode Text File on the format name
  And I should receive x-fmt/16 on the format id
  And the status should be ok
  And textmd should exist

Scenario: describe a bad text file with disallowed character
  Given a bad text file with disallowed character
  When describing the file
  Then I should receive Unicode Text File on the format name
  And I should receive eventDetail equal to 'Not well-formed'
  And the status should be ok

@javascript
Feature: Edit records concurrently
  As a user of the system
  I want to be informed when other users access or change the same data I am working on
  So that the information I key-in can be stored correctly

  Background:
    * I am logged into the system as an admin
    * Someone else is logged into the system

  Scenario: Update need record concurrently
    Given a resident with a need exists
    And I have assigned the need to me
    And the need has status 'to do'
    When I change someone else's need status to 'complete'
    Then I see my need change was unsuccessful

  Scenario: Update resident record concurrently
    Given a resident
    When I change someone a resident's name concurrently
    Then I see my resident change was unsuccessful

  Scenario: Update resident triage record concurrently
    Given I am on a call with a resident
    And I am conducting a triage of the residents needs
    When someone else updates the resident's name
    And I edit the total number of people to "99"
    And I save the edit resident form
    Then I see my resident change was unsuccessful

  Scenario: Inform users in real time of concurrent changes
    Given I am on a call with a resident
    And I am conducting a triage of the residents needs
    When someone else updates the resident's name
    Then I am informed another user has changed the record
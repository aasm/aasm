# CHANGELOG

## Unreleased

 * added autocreation of constants for each state ([@jherdman](https://github.com/jherdman))

## 3.0.16

 * added autocreation of state scopes for Mongoid (thanks to [@jonnyshields](https://github.com/johnnyshields))

## 3.0.15

 * added support for localized state names (on a class level, like Record.aasm.states.map(&:localized_name))

## 3.0.14

 * supporting event inspection for to-states transitions (`Event#transitions_to_state?`)

## 3.0.13

 * supporting *ActiveRecord* transactions when firing an event

## 3.0.12

 * `aasm_from_states_for_state` now supports to filter for specific transition

## 3.0.11

 * added class method `aasm_from_states_for_state` to retrieve all from states (regarding transitions) for a given state

## 3.0.10

 * added support for transitions from all other states (thanks to *Stefan 'swrobel' Wrobel*)

## 3.0.9

 * guard checks (e.g. `may_edit?`) now support guard parameters as well

## 3.0.8

 * fixed issue with generating docs using yard

## 3.0.7

 * removed deprecation warning when localizing aasm state names (look at https://github.com/rubyist/aasm/issues/38 for details)

## 3.0.6

 * bugfix: if configured to skip validation the code does not validate anymore

## 3.0.5

 * bugfix: get rid of error with old rubygems versions

## 3.0.4

 * bugfix: Subclasses of aasm-enabled classes don't lose settings anymore (thanks to codez)

## 3.0.3

 * bugfix: ActiveRecord scopes are generated when using the new DSL

## 3.0.2

 * ActiveRecord persistence can ignore validation when trying to save invalid models

## 3.0.1

 * added support for Mongoid (Thanks, Michał Taberski)

## 3.0.0

 * switched documentation to the new DSL
 * whiny transactions: by default, raise an exception if an event transition is not possible
 * you may disable whiny transactions

## 2.4.0

 * supporting new DSL (which is much shorter)

## 2.3.1

 * bugfix: avoid naming conflict with i18n

## 2.3.0

 * supporting i18n
 * supporting regular expressions for hash values and strings


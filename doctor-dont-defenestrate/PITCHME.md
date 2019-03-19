@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south-west]
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a>
@snapend

@snap[north]
![Summit Logo](doctor-dont-defenestrate/assets/images/summit_logo.png)
@snapend

# Doctor, Don't Defenestrate!

_What to do with Legacy Code_

Note:

- Hi, I'm Mike Lombardi! I'm a software engineer at Puppet
- I've spent a lot of time managing legacy code, making legacy code, and triaging it, both as an IT Pro and a developer.
- Sometimes, I'm tempted to just throw it all out the window and start over.

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

## The Value of Legacy Code

> All legacy code was written to solve a particular problem in a given context.

Note:

- Legacy code is a mark of success
- The only orgs without legacy code are those writing their first lines
- Best practices update over time
- Legacy code contains lessons about our systems

+++?image=doctor-dont-defenestrate/assets/images/harlie-raethel-516092-unsplash.jpg

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[north-east]
## Triage
@snapend

Note:

- What's triage? It's a workflow tool used by medical pros to decide the order of treatment for large numbers of casualties/sick.
- Not just about ordering, but also what to do:
  - whether or not you can safely come back around for future aid, or whether it's even advisable to treat them
  - Hard tradeoffs.

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

### Three Categories

- **Dependable:** Relatively safe without intervention
- **Defenestrate:** Unsalvageable with intervention
- **Doctor:** Safe with prioritized intervention

Note:

- The French initially triaged their battle casualties (late 18th century) into three groups: immediate, urgent, non-urgent for prioritization.
- We're using a similar three-group sorting
- This are rough groups, not perfect

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

### How to Assess

@ul

- How many things does this do?
- How many systems does this touch?
- How valuable is this?
- How impactful is this?
- How many people understand this?

@ulend

Note:

- We're looking to build up an idea of risk to value to maintainability comparison so we can decide whether or not to intervene and how much.
- This is something we dial in on over time as we triage more scripts.

+++?image=doctor-dont-defenestrate/assets/images/laurent-perren-743458-unsplash.jpg&position=left&size=75% auto&color=black

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[north-east span-100]
### When to Defenestrate
@snapend

@snap[east]

@ul

- Does lots of things
- Touches lots of systems
- Low Value
- High impact on failure
- Few people understand

@ulend

@snapend

Note:

- It's okay to want to throw some of our code out the window.
- When we decide to defenestrate, sometimes we don't need to replace it. The value proposition has faded or the tool was only rarely used, or another tool can be easily used to replace it.
- When we do have to replace it we can try to use something like the Strangler Vine Pattern, coined by Martin Fowler.
  - Replace pieces and components over time, taking away more functionality and introducing more safety/features.
  - When we think about building new things, we should try to design them such that they can be strangled in the future.

+++?image=doctor-dont-defenestrate/assets/images/jc-gellidon-1386351-unsplash.png&position=left&size=50% auto&color=black

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[east]
### When to Doctor

@ul

- Does a few things
- Touches some systems
- Medium-high Value
- Medium-high impact

@ulend
@snapend

Note:

- Deciding when to doctor is a similarly nebulous decision.
- Not every tool needs to be doctored as fully.

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

### Tradeoffs, not Checklists

Note:

- The ongoing theme is that triaging will always struggle for prioritization.
- Prioritization can take time, but it's best to _do_ something rather than over-analyze
- This does NOT mean "don't ticket problems/improvements"
- It means to use your judgement when triaging your tech debt.

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

## Approach

@ol

- Make sense of the code.
- Document for future users
- Characterize current behavior
- Minimal refactor.
- Iterative improvement.

@olend

Note:

- Now, checklists aside, there's a few standardish steps we can take to doctor gnarly legacy code.
- These are the sections we're going to go through today.

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

### The Code of Legend

@code[powershell code-blend code-max code-wrap](doctor-dont-defenestrate/assets/code/01-initial/Update-InactiveOrStaleADAccounts.ps1)

Note:

- This is a real (scrubbed) script for use in a real production environment sent to me by an anyonymous community member.
- Just looking this file over though, it can be pretty confusing to understand what's happening.
- So, let's go to step one and try to make sense of things.

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

## 1. Making Sense of the Code

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Making Sense of the Code
@snapend

### Inline Commenting

@ul

- Document what we've discovered
- Clarify for future maintainer
- Better to be thorough for now

@ulend

Note:

- Inline comments are added to the script file.
- Let's look at a few:

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Making Sense of the Code
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/02-inline-comments/Update-InactiveOrStaleADAccounts.ps1)

@[9-19, zoom-13]
@[33-35, zoom-13]
@[47-57, zoom-12]

Note:

So, I looked through this and found out that the script does a few things:

> It looks for user/computer accounts which are inactive and tries to disable them, it looks for stale user/computer accounts and tries to delete them, and it produces CSV logs for us to use in reports.

1. A long note to explain what's up with the dot sourcing and what the imported functions do.
   - This reduces the nead to read either of those files to grok this controller
2. The script has a commented out line because to delete a stale user account, you need to uncomment the line.
   - This was intended as a safety mechanism.
3. This time, the whatif is *un*commented, you need to enable it. The result is not perfect

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

## Document for Future Users

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Document for Future Users
@snapend

@snap[north span-100]
## Reference Documentation
@snapend
@snap[west text-13 span-60]

<ul>
<li>Synopsis / Description</li>
<li>Parameters</li>
<li>Input/Output</li>
<ul>
@snapend
@snap[east text-13 span-60]
<ul>
<li>Examples</li>
<li>Notes</li>
<li>README</li>
</ul>
@snapend

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Document for Future Users
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/03-reference-documentation/Update-InactiveOrStaleADAccounts.ps1)

@[2-3, zoom-15](Synopsis)
@[4-14, zoom-13](Description)
@[29-36, zoom-14](Parameter)
@[42-49, zoom-14](Inputs & Outputs)
@[65-74, zoom-13](Examples)
@[75-81, zoom-13](Notes for Maintainers)
@[82-94, zoom-12](Todo List)
@[97-102, zoom-13](Links to Supporting Documentation)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Document for Future Users
@snapend

## README

Note:

- Overview
- First Use
- Getting help
- Installing
- TODO

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Document for Future Users
@snapend

@code[markdown code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/04-readme/README.md)

@[1-5, zoom-13](Overview - First 30 Seconds)
@[126-136, zoom-12](TODO - Checkable List)

Note:

- The important things to cover are the first 30 seconds info and the to-do list - you've seen most of the rest.

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[span-100]
### Characterize Current Behavior
@snapend

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Characterize Current Behavior
@snapend

### Characterization Tests

@ul

- Describe _current_ behavior, not _intended_ behavior.
- "What" not "How"
- Prepare for Refactoring
- Convert to behavioral tests

@ulend

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Characterize Current Behavior
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/05-characterization-tests/Update-InactiveOrStaleADAccounts.Tests.ps1)

@[1-4, zoom-12](Setup For Ongoing)
@[7, zoom-18](Description for our test suite)
@[8, zoom-18](First context we're concerned with)
@[9, zoom-16](Mocking Get-Content)
@[10-19, zoom-15](Mocking Get-AgedAccounts)
@[30-33, zoom-15](Mocking AD commands)
@[34, zoom-15](Making sure we don't write to disk)
@[35, zoom-15](Sub-context by behavior)
@[62-68, zoom-13](Verify _current_ behavior)
@[99, zoom-18](Verifying behavior when passed a parameter)
@[121-124, zoom-15](Had to specify parameters for mock assertions)
@[143, zoom-18](Overriding default parameter)

+++?image=doctor-dont-defenestrate/assets/images/initial-tests.PNG&size=auto 80%

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Characterize Current Behavior
@snapend

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

## Refactoring

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring
@snapend

### Refactoring for Clarity

Note:

- We first refactor to make it easier to understand what's happening
- We're not seeking to change _behavior_, only to make it more clear
- This will help future maintainers, including us!

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Clarity
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/refactor-clarity-dot-sourcing-1.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Clarity
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/refactor-clarity-dot-sourcing-2.ps1)

Note:

- Here we reorganize things into begin/process/end blocks
- We also use $PSScriptRoot to stop requiring running from a specific directory

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Clarity
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/refactor-clarity-queries-1.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Clarity
@snapend

@code[powershell code-blend code-max code-wrap zoom-11](doctor-dont-defenestrate/assets/code/snippets/refactor-clarity-queries-2.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Clarity
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/refactor-clarity-queries-3.ps1)

Note:

- We rename the variables to something useful
- Splatting stuff

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Clarity
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/snippets/refactor-clarity-action-1.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Clarity
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/snippets/refactor-clarity-action-2.ps1)

@[1-8, zoom-13]
@[12, zoom-15]
@[13-22, zoom-13]
@[22-33, zoom-12]

Note:

- First, we prepare for splatting our Add-Member command - reduce code sprawl and make the logic easier to follow.
- Rename the loop to something less ambiguous - be explicit about what we're going to try to do.
- Inherit the hash table we set up earlier, update it for the disable action, use it for the exception list.
- Disable the account, save the results, write them to the accounts information.
- This is all functionally identical for the delete call.

+++?image=doctor-dont-defenestrate/assets/images/initial-tests.PNG&size=auto 80%

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Clarity
@snapend

Note:

- Run our tests between each set of refactor changes

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Maintainability
@snapend

### Refactoring for Maintainability

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Maintainability
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/snippets/refactor-maintenance-logic-1.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Maintainability
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/snippets/refactor-maintenance-logic-2.ps1)

Note:

- We unify the logic, managing both actions with one foreach loop

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Maintainability
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/snippets/refactor-maintenance-logic-3.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Maintainability
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/snippets/refactor-maintenance-logic-4.ps1)

Note:

- Disable-specific actions live here instead of at the top of the loop
- Delete is functionally the same

+++?image=doctor-dont-defenestrate/assets/images/initial-tests.PNG&size=auto 80%

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Refactoring: Maintainability
@snapend

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

## Iterative improvement

Note:

- Now that we've got things cleaned up a bit, time to drive Value

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement
@snapend

### Adding WhatIf Support

Note:

- We'll start with fixing WhatIf, add safety
- Reduce need to touch script to change behavior

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: WhatIf
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/improve-whatif-params-before.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: WhatIf
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/improve-whatif-params-after.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: WhatIf
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/improve-whatif-action-before.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: WhatIf
@snapend

@code[powershell code-blend code-max code-wrap zoom-14](doctor-dont-defenestrate/assets/code/snippets/improve-whatif-action-after.ps1)

Note:

- Remove warnings and commented line

+++?image=doctor-dont-defenestrate/assets/images/initial-tests.PNG&size=auto 80%

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: WhatIf
@snapend

Note:

- Rerun tests!

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement
@snapend

### Handle Deleting Users

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: Deleting Users
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/improve-delete-params-before.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: Deleting Users
@snapend

@code[powershell code-blend code-max code-wrap zoom-12](doctor-dont-defenestrate/assets/code/snippets/improve-delete-params-after.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: Deleting Users
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/snippets/improve-delete-query-before.ps1)

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: Deleting Users
@snapend

@code[powershell code-blend code-max code-wrap zoom-5](doctor-dont-defenestrate/assets/code/snippets/improve-delete-query-after.ps1)

+++?image=doctor-dont-defenestrate/assets/images/handle-users-tests.PNG&size=100% auto

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement: Deleting Users
@snapend

Note:

- We had to add a new test to verify that when this switch is specified - and ONLY then - the script will try to delete user accounts which have been inactive for too long.

+++?image=doctor-dont-defenestrate/assets/images/ng-15320-unsplash.jpg&size=contain

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

@snap[south text-05 span-100]
Iterative Improvement
@snapend

Note:

- And once you've got this in place you can go and go and go.
- Remember, tradeoffs! Not everything should be fixed now, not every improvement is worth the time.
- But you'll always have the option to come back.

---?image=doctor-dont-defenestrate/assets/images/james-hammond-347179-unsplash.jpg&size=70% auto&color=black

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

Note:

- The elephant in the room
- If this is so simple, why don't we do it?
- Simple doesn't mean easy or low effort
- Tradeoffs and tech debt
- Making Work/Value Visible

+++

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

## @fa[infinity fa-5x]

Note:

- Virtuous Cycles
- Slow is smooth, smooth is fast, fast is safe
- Iterative, not incremental
- Tradeoffs

---

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend

## Resources

- [Strangler Vine Pattern](https://www.martinfowler.com/bliki/StranglerApplication.html)
- [Working Effectively with Legacy Code](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)
- [Beyond Pester 101](https://glennsarti.github.io/presentation/powershell-asia2018-pester/)

@snap[south-west]
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a>
@snapend

@snap[south-east text-05 span-100]
@color[gold](@barbariankb)
@snapend
# Hand2Hand Development Report

Welcome to the documentation pages of Hand2Hand!

This Software Development Report, tailored for LEIC-ES-2024-25, provides comprehensive details about Hand2Hand, from high-level vision to low-level implementation decisions. It’s organised by the following activities. 

* [Business modeling](#Business-Modelling) 
  * [Product Vision](#Product-Vision)
  * [Features and Assumptions](#Features-and-Assumptions)
  * [Elevator Pitch](#Elevator-pitch)
* [Requirements](#Requirements)
  * [User stories](#User-stories)
  * [Domain model](#Domain-model)
* [Architecture and Design](#Architecture-And-Design)
  * [Logical architecture](#Logical-Architecture)
  * [Physical architecture](#Physical-Architecture)
  * [Vertical prototype](#Vertical-Prototype)
* [Project management](#Project-Management)
  * [Sprint 0](#Sprint-0)
  * [Sprint 1](#Sprint-1)
  * [Sprint 2](#Sprint-2)
  * [Sprint 3](#Sprint-3)
  * [Sprint 4](#Sprint-4)
  * [Final Release](#Final-Release)

Contributions are expected to be made exclusively by the initial team, but we may open them to the community, after the course, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us!

Thank you!

* [Ana Catarina Monteiro de Sousa](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202306419)    - up202306419@edu.fe.up.pt
* [Beatriz de Sousa Bastos](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202303793)           - up202303793@edu.fe.up.pt
* [Guilherme Duarte Almeida Santos](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202304836)   - up202304836@edu.fe.up.pt
* [Matilde Araújo Cardoso da Fonseca](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202306990) - up202306990@edu.fe.up.pt
* [Matilde de Sá Nogueira de Sousa](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202305502)   - up202305502@edu.fe.up.pt

---
## Business Modelling

Business modeling in software development involves defining the product's vision, understanding market needs, aligning features with user expectations, and setting the groundwork for strategic planning and execution.

### Product Vision

<!-- 
Start by defining a clear and concise vision for your app, to help members of the team, contributors, and users into focusing their often disparate views into a concise, visual, and short textual form. 

The vision should provide a "high concept" of the product for marketers, developers, and managers.

A product vision describes the essential of the product and sets the direction to where a product is headed, and what the product will deliver in the future. 

**We favor a catchy and concise statement, ideally one sentence.**

We suggest you use the product vision template described in the following link:
* [How To Create A Convincing Product Vision To Guide Your Team, by uxstudioteam.com](https://uxstudioteam.com/ux-blog/product-vision/)

To learn more about how to write a good product vision, please see:
* [Vision, by scrumbook.org](http://scrumbook.org/value-stream/vision.html)
* [Product Management: Product Vision, by ProductPlan](https://www.productplan.com/glossary/product-vision/)
* [How to write a vision, by dummies.com](https://www.dummies.com/business/marketing/branding/how-to-write-vision-and-mission-statements-for-your-brand/)
* [20 Inspiring Vision Statement Examples (2019 Updated), by lifehack.org](https://www.lifehack.org/articles/work/20-sample-vision-statement-for-the-new-startup.html)
-->


### Features and Assumptions
<!-- 
Indicate an  initial/tentative list of high-level features - high-level capabilities or desired services of the system that are necessary to deliver benefits to the users.
 - Feature XPTO - a few words to briefly describe the feature
 - Feature ABCD - ...
...

Optionally, indicate an initial/tentative list of assumptions that you are doing about the app and dependencies of the app to other systems.
-->

### Elevator Pitch
<!-- 
Draft a small text to help you quickly introduce and describe your product in a short time (lift travel time ~90 seconds) and a few words (~800 characters), a technique usually known as elevator pitch.

Take a look at the following links to learn some techniques:
* [Crafting an Elevator Pitch](https://www.mindtools.com/pages/article/elevator-pitch.htm)
* [The Best Elevator Pitch Examples, Templates, and Tactics - A Guide to Writing an Unforgettable Elevator Speech, by strategypeak.com](https://strategypeak.com/elevator-pitch-examples/)
* [Top 7 Killer Elevator Pitch Examples, by toggl.com](https://blog.toggl.com/elevator-pitch-examples/)
-->

## Requirements

### User Stories

1 - As a user I can add food items to my donate list. (Must have this feature)<br/>
2 - As a user I can take food items off my donate list. (Must have this feature)<br/>
3 - As a user I can accept a donation of a neighbor. (Must have this feature)<br/>
4 - As a user I can send a trade offer. (Must have this feature)<br/>
5 - As a user I can accept/decline a trade offer. (Must have this feature)<br/>
6 - As a user I want to be able to change neighborhood. (Should have this feature)<br/>
7 - As a donner I want to receive a notification every time someone requests one of my items. (Should have this feature)<br/>
8 - As a user I want to be able to see the listed items in my neighbourhood. (Should have this feature)<br/>
9 - As a user I want to be able to filter the items by category. (Should have this feature)<br/>

**User interface mockups**.
After the user story text, you should add a draft of the corresponding user interfaces, a simple mockup or draft, if applicable.

**Acceptance tests**.
1.
Scenario: Successfully adding a food item 
Given I am a logged-in user on the "Add Item" page
When I enter the food item´s name, description, category, and expiration date
And I click "Submit"
Then the item should appear in my donate list and in the browsing page.

Scenario: Attempt to add a food item with missing required fields
Given I am a logged- in user on the "Add Item" page
When I leave the name or expiration date blank
And I click "Submit"
Then I should see an error message indicating required fields are missing

2.
Scenario: Successfully removing a food item
Given I have at least one item in my donate list
When I select an item and click "Remove"
Then the item should no longer appear in my donate list and the browsing page

Scenario: Removing a food item that has already been requested
Given I have a food item in my donate list that has a pending request
When I try to remove it
Then I should see a warning message asking for confirmation
And If I confirm, the item should be removed 
And the request should be canceled
And the system should notify the other user

3.
Scenario: Successfully accepting a donation
Given I am on the "Browse Items" page
And a donation item is available
When I click "Request Item"
Then the donor should receive a notification of my request

Scenario: Attempting to request an already claimed item
Given another user has already claimed an item
When I try to request it
Then I should see a message saying "This item is no longer available"

4.
Scenario: Successfully sending a trade offer
Given I am on the "Browse Items" page
When I click "Propose Exchange" on an available exchangeable item
And I select one of my own listed items for the trade
And I click "Submit Offer"
Then the donor should receive a notification of my trade proposal

Scenario: Attempting to send a trade offer without an available item
Given I have no items listed for donation
When I try to propose a trade
Then I should see a message saying "You need to list an item first"

5.
Scenario: Successfully accepting a trade offer
Given I have received a trade offer notification
When I open the trade request
And I click "Accept Offer"
Then a confirmation message should appear
And the system should notify the other user

Scenario: Declining a trade offer
Given I have received a trade offer
When I click "Decline Offer"
Then the sender should receive a notification that the offer has been rejected
And I should see an option to "Make a New Offer" or "Cancel"
When I choose "Make a new Offer"
Then I should be able to select items from my items list
When I choose "Cancel"
Then the trade request should be permanently declined

6.
Scenario: Successfully changing neighborhood
Given I am on my profile settings page
When I change my home location
And I click "Save Changes"
Then my browsing and item listing should be available for the updated location´s neighborhood

Scenario: Attempting to change to an invalid location
Given I am on my profile settings page
When I enter an invalid address
And I click "Save Changes"
Then I should see an error message indicating the address is invalid

7.
Scenario: Successfully receiving a request notification
Given I have an item listed on the browsing page
And a user sends a request for it
Then I should receive a notification that my item has been requested

Scenario: Receiving multiple request for the same item
Given I have an item listed on the browsing page
And multiple users request it at the same time
Then I should receive a separate notification for each request



**Value and effort**.
We made a scale with the MoSCoW method's categories. 
1 - Won't have this feature
2 - Could have this feature
3 - Should have this feature
4 - Must have this feature

### Domain model

<!-- 
To better understand the context of the software system, it is useful to have a simple UML class diagram with all and only the key concepts (names, attributes) and relationships involved of the problem domain addressed by your app. 
Also provide a short textual description of each concept (domain class). 

Example:
 <p align="center" justify="center">
  <img src="https://github.com/FEUP-LEIC-ES-2022-23/templates/blob/main/images/DomainModel.png"/>
</p>
-->


## Architecture and Design
<!--
The architecture of a software system encompasses the set of key decisions about its organization. 

A well written architecture document is brief and reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the components of the project and their interrelations. You should describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.
-->


### Logical architecture
<!--
The purpose of this subsection is to document the high-level logical structure of the code (Logical View), using a UML diagram with logical packages, without the worry of allocating to components, processes or machines.

It can be beneficial to present the system in a horizontal decomposition, defining layers and implementation concepts, such as the user interface, business logic and concepts.

Example of _UML package diagram_ showing a _logical view_ of the Eletronic Ticketing System (to be accompanied by a short description of each package):

![LogicalView](https://user-images.githubusercontent.com/9655877/160585416-b1278ad7-18d7-463c-b8c6-afa4f7ac7639.png)
-->


### Physical architecture
<!--
The goal of this subsection is to document the high-level physical structure of the software system (machines, connections, software components installed, and their dependencies) using UML deployment diagrams (Deployment View) or component diagrams (Implementation View), separate or integrated, showing the physical structure of the system.

It should describe also the technologies considered and justify the selections made. Examples of technologies relevant for ESOF are, for example, frameworks for mobile applications (such as Flutter).

Example of _UML deployment diagram_ showing a _deployment view_ of the Eletronic Ticketing System (please notice that, instead of software components, one should represent their physical/executable manifestations for deployment, called artifacts in UML; the diagram should be accompanied by a short description of each node and artifact):

![DeploymentView](https://user-images.githubusercontent.com/9655877/160592491-20e85af9-0758-4e1e-a704-0db1be3ee65d.png)
-->


### Vertical prototype
<!--
To help on validating all the architectural, design and technological decisions made, we usually implement a vertical prototype, a thin vertical slice of the system integrating as much technologies we can.

In this subsection please describe which feature, or part of it, you have implemented, and how, together with a snapshot of the user interface, if applicable.

At this phase, instead of a complete user story, you can simply implement a small part of a feature that demonstrates thay you can use the technology, for example, show a screen with the app credits (name and authors).
-->

## Project management
<!--
Software project management is the art and science of planning and leading software projects, in which software projects are planned, implemented, monitored and controlled.

In the context of ESOF, we recommend each team to adopt a set of project management practices and tools capable of registering tasks, assigning tasks to team members, adding estimations to tasks, monitor tasks progress, and therefore being able to track their projects.

Common practices of managing agile software development with Scrum are: backlog management, release management, estimation, Sprint planning, Sprint development, acceptance tests, and Sprint retrospectives.

You can find below information and references related with the project management: 

* Backlog management: Product backlog and Sprint backlog in a [Github Projects board](https://github.com/orgs/FEUP-LEIC-ES-2023-24/projects/64);
* Release management: [v0](#), v1, v2, v3, ...;
* Sprint planning and retrospectives: 
  * plans: screenshots of Github Projects board at begin and end of each Sprint;
  * retrospectives: meeting notes in a document in the repository, addressing the following questions:
    * Did well: things we did well and should continue;
    * Do differently: things we should do differently and how;
    * Puzzles: things we don’t know yet if they are right or wrong… 
    * list of a few improvements to implement next Sprint;

-->

### Sprint 0

### Sprint 1

### Sprint 2

### Sprint 3

### Sprint 4

### Final Release



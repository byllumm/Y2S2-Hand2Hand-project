# Hand2Hand Development Report

Welcome to the documentation pages of Hand2Hand!

This Software Development Report, tailored for LEIC-ES-2024-25, provides comprehensive details about Hand2Hand, from high-level vision to low-level implementation decisions. It’s organised by the following activities.

- [Business modeling](#Business-Modelling)
  - [Product Vision](#Product-Vision)
  - [Features and Assumptions](#Features-and-Assumptions)
  - [Elevator Pitch](#Elevator-pitch)
- [Requirements](#Requirements)
  - [User stories](#User-stories)
  - [Domain model](#Domain-model)
- [Architecture and Design](#Architecture-And-Design)
  - [Logical architecture](#Logical-Architecture)
  - [Physical architecture](#Physical-Architecture)
  - [Vertical prototype](#Vertical-Prototype)
- [Project management](#Project-Management)
  - [Sprint 0](#Sprint-0)
  - [Sprint 1](#Sprint-1)
  - [Sprint 2](#Sprint-2)
  - [Sprint 3](#Sprint-3)
  - [Sprint 4](#Sprint-4)
  - [Final Release](#Final-Release)

Contributions are expected to be made exclusively by the initial team, but we may open them to the community, after the course, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us!

Thank you!

- [Ana Catarina Monteiro de Sousa](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202306419) - up202306419@edu.fe.up.pt
- [Beatriz de Sousa Bastos](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202303793) - up202303793@edu.fe.up.pt
- [Guilherme Duarte Almeida Santos](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202304836) - up202304836@edu.fe.up.pt
- [Matilde Araújo Cardoso da Fonseca](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202306990) - up202306990@edu.fe.up.pt
- [Matilde de Sá Nogueira de Sousa](https://sigarra.up.pt/feup/pt/fest_geral.cursos_list?pv_num_unico=202305502) - up202305502@edu.fe.up.pt

---

## Business Modelling

### Product Vision

For environmentally-conscious communities, who want to reduce food waste and share surplus food, Hand2Hand is a neighborhood-sharing app that enables easy donating, exchanging, and selling of food items. Unlike traditional food banks or marketplaces, our app offers a hyper-local, real-time solution tailored for neighbors to connect effortlessly.

### Features and Assumptions

- **Food Listing and Browsing**: Users can list surplus food items that will be found on nearby users´ explorer page;
- **Request and Approval System**: Users can request food items which sends a notification to the item´s owner for approval;
- **Donation, Exchange, and Selling Options**: Users can choose whether they want to donate, exchange and/or sell food items based on their preferences;
- **Geolocation-Based Filtering**: Listings are displayed based on user´s location to ensure hyper-local exchange;
- **Push Notifications and Alerts**: Real-time notifications for new listings, request approvals, and messages;
- **Chat & Communication**: In-app messaging to coordinate exchanges without needing external contact methods;

### Elevator Pitch

Hand2Hand brings neighbors together to combat food waste. Users can easily donate, exchange or sell the forgotten food in the back of their cabinets within their local community.

With just a few taps, people can share what they don´t need and help others nearby. More than just reducing waste, Hand2Hand fosters connections and strengthens neighborhoods - because **food should bring people together, not go to waste**.

## Requirements

### User Stories & Widget Tests

**1.**

As a user I can add food items to my donate list. (Must have this feature)<br/>

Scenario: Successfully adding a food item <br/>
Given I am a logged-in user on the "Add Item" page <br/>
When I enter the food item´s name, description, category, and expiration date <br/>
And I click "Submit" <br/>
Then the item should appear in my donate list and in the browsing page. <br/>

Scenario: Attempt to add a food item with missing required fields <br/>
Given I am a logged- in user on the "Add Item" page <br/>
When I leave the name or expiration date blank <br/>
And I click "Submit" <br/>
Then I should see an error message indicating required fields are missing <br/>

**2.**

As a user I can take food items off my donate list. (Must have this feature)<br/>

Scenario: Successfully removing a food item <br/>
Given I have at least one item in my donate list <br/>
When I select an item and click "Remove" <br/>
Then the item should no longer appear in my donate list and the browsing page <br/>

Scenario: Removing a food item that has already been requested <br/>
Given I have a food item in my donate list that has a pending request <br/>
When I try to remove it <br/>
Then I should see a warning message asking for confirmation <br/>
And If I confirm, the item should be removed <br/>
And the request should be canceled <br/>
And the system should notify the other user <br/>

**3.**

As a user I can accept a donation of a neighbor. (Must have this feature)<br/>

Scenario: Successfully accepting a donation <br/>
Given I am on the "Browse Items" page <br/>
And a donation item is available <br/>
When I click "Request Item" <br/>
Then the donor should receive a notification of my request <br/>

Scenario: Attempting to request an already claimed item <br/>
Given another user has already claimed an item <br/>
When I try to request it <br/>
Then I should see a message saying "This item is no longer available" <br/>

**4.**

As a user I can send a trade offer. (Must have this feature)<br/>

Scenario: Successfully sending a trade offer <br/>
Given I am on the "Browse Items" page <br/>
When I click "Propose Exchange" on an available exchangeable item <br/>
And I select one of my own listed items for the trade <br/>
And I click "Submit Offer" <br/>
Then the donor should receive a notification of my trade proposal <br/>

Scenario: Attempting to send a trade offer without an available item <br/>
Given I have no items listed for donation <br/>
When I try to propose a trade <br/>
Then I should see a message saying "You need to list an item first" <br/>

**5.**

As a user I can accept/decline a trade offer. (Must have this feature)<br/>

Scenario: Successfully accepting a trade offer <br/>
Given I have received a trade offer notification <br/>
When I open the trade request <br/>
And I click "Accept Offer" <br/>
Then a confirmation message should appear <br/>
And the system should notify the other user <br/>

Scenario: Declining a trade offer <br/>
Given I have received a trade offer <br/>
When I click "Decline Offer" <br/>
Then the sender should receive a notification that the offer has been rejected <br/>
And I should see an option to "Make a New Offer" or "Cancel" <br/>
When I choose "Make a new Offer" <br/>
Then I should be able to select items from my items list <br/>
When I choose "Cancel" <br/>
Then the trade request should be permanently declined <br/>

**6.**

As a user I want to be able to change neighborhood. (Should have this feature)<br/>

Scenario: Successfully changing neighborhood <br/>
Given I am on my profile settings page <br/>
When I change my home location <br/>
And I click "Save Changes" <br/>
Then my browsing and item listing should be available for the updated location´s neighborhood <br/>

Scenario: Attempting to change to an invalid location <br/>
Given I am on my profile settings page <br/>
When I enter an invalid address <br/>
And I click "Save Changes" <br/>
Then I should see an error message indicating the address is invalid <br/>

**7.**

As a doner I want to receive a notification every time someone requests one of my items. (Should have this feature)<br/>

Scenario: Successfully receiving a request notification <br/>
Given I have an item listed on the browsing page <br/>
And a user sends a request for it <br/>
Then I should receive a notification that my item has been requested <br/>

Scenario: Receiving multiple request for the same item <br/>
Given I have an item listed on the browsing page <br/>
And multiple users request it at the same time <br/>
Then I should receive a separate notification for each request <br/>

**8.**
As a user I want to be able to see the listed items in my neighbourhood. (Must have this feature) <br/>

Scenario: Seeing the listed items in my neighborhood <br/>
Given I am on the "Browse Items" page <br/>
When opening or refreshing this page <br/>
Then I should see a grid featuring the listed items in my neighborhood <br/>

Scenario: No items available <br/>
Given I am on a neighborhood with no available items <br/>
When opening or refreshing the "Browse Items" page <br/>
Then a message appears saying "No items available nearby"<br/>

**9.**
As a user I want to be able to filter the items by category. (Should have this feature) <br/>

Scenario: Using filters by a specific category <br/>
When searching for items in the "Browse Items" page and selecting a specific category like Bakery <br/>
Then the list updates to only show the items that belong to that category <br/>

Scenario: Reseting the filters <br/>
When removing all the filters <br/>
Then the "Browsing Items" page should show all the items again <br/>

**Value and effort**.

We made a scale with the MoSCoW method's categories. <br/>

1 - Won't have this feature <br/>
2 - Could have this feature <br/>
3 - Should have this feature <br/>
4 - Must have this feature <br/>

### Domain model

<p align="center" justify="center">
 <img src="https://github.com/user-attachments/assets/9c13b033-bab2-4d43-9cfe-1749bd26f731"/>
</p>

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

<p align="center" justify="center">
 <img src="https://github.com/user-attachments/assets/17e405ff-76d1-455c-9150-eb3e40671af4"/>
</p>

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

# 🏨 Hotel-Mangement-System

### Important Links
[Final Script](https://github.com/JasonDoesCode/Hotel-Mangement-System/blob/main/Procedures.sql) | [ERD](https://github.com/JasonDoesCode/Hotel-Mangement-System/blob/main/Project%20ERD.png)

### Socials:
[LinkedIn](https://www.linkedin.com/in/imjasonleo/) | [Github](https://github.com/JasonDoesCode) | [Twitter](https://twitter.com/JasonDoesCode)

## Project Description
The team was charged with creating a database for U Hotels, a faux hotel chain that required a database to manage their various chains, customers, rooms, and customers. The database would at minimum need to store information on its customers (name, address, phone, credit card, etc.), the hotels that belong to the U.Hotels chain and their relevant info (address, phone, rooms), and finally be able to make reservations at any given hotel, but in a manner that would not allow for a room to be double booked for the same duration.

## Important Assumptions

1. The rates of each hotel room fluctuate according to peak season or off-season. Use the rate in the table provided for each room depending on the season.
    
    
    | Month | Room Rate |
    | --- | --- |
    | Sep - Apr | $100 (single), $200 (double), $500 (suite), $1000 (conf. room) |
    | May - Aug | $300 (single), $500 (double), $900 (suite), $5000 (conf. room) |
2. You should make reservations for consecutive days for a specific Room type.
3. Guests can check-in with or without reservations.
4. If a reservation is made 2 months in advance or more, the customer gets a 10% discount on the rate. Otherwise, the customer has to pay full rate.
5. Room types: single room 1-bed, double-room 2-beds, suites, conference rooms
6. Guests pay their bill (invoice) when they check-out.
7. A guest can reserve and stay in multiple rooms at the same time (e.g. a large family) and must pay for all reserved rooms.
8. The services that are offered by all U.HOTELS are the same. They include:
    1. Restaurant services (assume $20 per person per meal)
    2. Pay-per-view movies (assume $5 per movie)
    3. Laundry services (assume $10 per time – regardless of number of items)
9. Guests can check out earlier (before the last day they reserved a room) or later (they can stay longer if there is room availability)

Guests cannot reserve rooms that span across months with different rates. You do not have to implement this, but do not enter reservations for such cases.

## Work Delegation

Following these important assumptions for the management system, each member within the group was assigned with the creation of 4 different procedures that would carry out an important aspect of the management system. Each task includes the relevant input for the procedures, and a description of the output.

**Member 1:**

1. Add a new hotel: Create a new hotel with appropriate information about the hotel as input parameters, including name, street, city, state, phone, etc. For simplicity, each newly created hotel must have 50 single rooms, 20 double, 5 suites, and 2 conference rooms.
2. Find a hotel: Provide as input the address of the hotel and return its hotel ID
3. Sell existing hotel: Sell a hotel by providing its hotel ID. Mark it as sold, do not delete the record, and print all sold hotel information. Show hotel ID, location, etc.
4. Report Hotels In State: Given a state, display name, address, phone number, and number of available rooms along with room type of each hotel in that particular state.

**Member 2:**

1. Make a reservation: Input parameters: Hotel ID, guest’s name, start date, end date, room type, date of reservation, etc. Output: reservation ID (this is called confirmation code in real-life). NOTE: Only one guest per reservation. However, the same guest can make multiple reservations. Also, make sure that there is availability of that room type before a reservation is made.
2. Find a reservation: Input is guest’s name and date, and hotel ID. Output is reservation ID
3. Cancel a reservation: Input the reservationID and mark the reservation as cancelled (do NOT delete it)
4. ShowCancelations: Print all canceled reservations in the hotel management system. Show reservation ID, hotel name, location, guest name, room type, dates

**Member 3:**

1. Change a reservationDate: Input the reservation ID and change reservation start and end date, if there is availability in the same room type for the new date interval
2. Show single hotel reservations: Given a hotel ID, show all reservations for that hotel
3. Show single guest reservations: Given a guest name, find all reservations under that name
4. Monthly Income Report: Calculate and display total income from all sources of all hotels. Totals must be printed by month, and for each month by room type, service type. If there is no income in a month, do not display this month. Include discounts.

**Member 4:**

1. Add a service to a reservation: Input: ReservationID, specific service. Add the service to the reservation for a particular date. Multiple services are allowed on a reservation for the same date.
2. Reservation Services Report: Input the reservation ID and display all services on this reservation. Print “no services for this reservation” if none exists.
3. Show Specific Service Report: Input the service name, and display information on all reservations that have this service in all hotels
4. Total Services Income Report: Given a hotelID, calculate and display income from all services in all reservations in that hotel.

**Member 5:**

1. Add room to hotel: Given a hotel ID add a specific type of room to it with an input number of instances. For example, add 10 double rooms, or add 2 suites
2. Show available rooms by type: Given a hotel ID, display the count of all available rooms by room type.
3. Checkout Report: Input: ReservationID Output:
    - Guest name
    - Room number, rate per day and possibly multiple rooms (if someone reserved several rooms)
    - Services rendered per date, type, and amount
    - Discounts applied (if any)
    - Total amount to be paid
4. Income by State Report: Input is state. Print total income from all sources of all hotels by room type and service type in the given state. Include discounts.

## Entity Relation Diagram (ERD)

The team conducted a brainstorming meeting after understanding their various tasks to create a high-level schema for the database or our ERD. As shown by the graphic below, this served to outline the columns that would exists in each table, their data types, and any foreign key relationships between tables.\
![ProjectERD](https://user-images.githubusercontent.com/25627129/213726975-51d45b9b-c604-42c6-8924-17cd87e8617b.png)

### Table Creation

Each team member was responsible for creating a table, with two members responsible for creating reservations table. The following are screenshots of the tables after creation.

**Customers**\
![image](https://user-images.githubusercontent.com/25627129/213727563-7bfd6afe-9000-4b8a-89f6-b29b7d05eed8.png)

**Hotels**\
![image](https://user-images.githubusercontent.com/25627129/213727631-d2d71692-e8a9-4585-a1c5-a0412c177be9.png)

**Reservations**\
![image](https://user-images.githubusercontent.com/25627129/213727680-a160684d-980d-4e47-a65b-46ac92b6328b.png)

**Rooms**\
![image](https://user-images.githubusercontent.com/25627129/213727718-b80cbaeb-74ef-4fbc-9cd0-16abb3250160.png)


### Weekly Standups
Each team member worked independently on their tasks and created substitute inputs for any procedures that had dependent inputs. During the weekly standup we concentrated on the progress we had made for upcoming deliverable. In the final weeks of the project, these sessions proved to be extremely useful as the group had to implement all the code together and these sessions served to communicate any issues that arose from the implementation of another members code.

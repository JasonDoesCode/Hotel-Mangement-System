SET SERVEROUTPUT ON;

--Drop Tables (will report errors if tables do not already exist)
DROP TABLE Reservations;
DROP TABLE Rooms;
DROP TABLE Hotels;
DROP TABLE Customers;

--Drop sequences for primary keys (will report errors if sequences do not already exist)
DROP SEQUENCE Customers_PK;
DROP SEQUENCE Reservations_PK;
DROP SEQUENCE Rooms_PK;
DROP SEQUENCE Hotels_PK;

--Standard Table Creation
CREATE TABLE Customers (
    customer_id int PRIMARY KEY,
    customer_name varchar(255),
    phone_number varchar(255),
    creditcard_number varchar(255),
    customer_state varchar(255),
    city varchar(255),
    street varchar(255),
    street_number varchar(255)
);

CREATE TABLE Reservations (
    reservation_id int PRIMARY KEY,
    booking_date date,
    check_in_date date,
    check_out_date date,
    room_id int,
    customer_id int,
    meal_count int,
    laundry_count int,
    movies_count int,
    is_cancelled int
);

CREATE TABLE Rooms (
    room_id int PRIMARY KEY,
    room_type varchar(255),
    hotel_id int,
    room_number varchar(255)
);

CREATE TABLE Hotels (
    hotel_id int PRIMARY KEY,
    hotel_name varchar(255),
    hotel_state varchar(255),
    city varchar(255),
    street varchar(255),
    street_number varchar(255),
    phone_number varchar(255),
    is_sold int
);

--Creating Relationships via Foreign Keys
ALTER TABLE Reservations
ADD CONSTRAINT FK_ReservationsCustomers
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id);

ALTER TABLE Reservations
ADD CONSTRAINT FK_ReservationsRooms
FOREIGN KEY (room_id) REFERENCES Rooms(room_id);

ALTER TABLE Rooms
ADD CONSTRAINT FK_RoomsHotels
FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id);

--Creating Sequences for Primary Keys
CREATE SEQUENCE Customers_PK
start with 1
increment by 1;

CREATE SEQUENCE Reservations_PK
start with 1
increment by 1;

CREATE SEQUENCE Rooms_PK
start with 1
increment by 1;

CREATE SEQUENCE Hotels_PK
start with 1
increment by 1;

--Insert Statements for Customers
INSERT INTO Customers 
values(customers_pk.nextval, 'John Smith', '202-555-0343', '4492921774917797', 'MD', 'Baltimore', 'Swan Dr.', '1001');

INSERT INTO Customers 
values(customers_pk.nextval, 'Arnold Patterson', '202-555-0384', '4532654681608389', 'MD', 'Baltimore', 'Auburn Row', '2001');

INSERT INTO Customers 
values(customers_pk.nextval, 'Mary Wise', '202-555-0203', '4532846482052870', 'MD', 'Baltimore', 'Garnet Route', '3001');

INSERT INTO Customers 
values(customers_pk.nextval, 'Samira Kay', '202-555-0044', '4556985024665970', 'MD', 'Baltimore', 'Cedar Passage', '4001');

INSERT INTO Customers 
values(customers_pk.nextval, 'Zahraa Rojas', '202-555-0259', '4929899256223970', 'MD', 'Baltimore', 'Ashland Street', '5001');

--Insert Statements for Hotels
INSERT INTO Hotels
values (hotels_pk.nextval, 'H1', 'MD', 'Annapolis', 'Fox Avenue', '1001', '410-555-0714', 1);

INSERT INTO Hotels
values (hotels_pk.nextval, 'H2', 'CA', 'San Francisco', 'Prince Row', '2001', '415-555-0245', 0);

INSERT INTO Hotels
values (hotels_pk.nextval, 'H3', 'MD', 'Baltimore', 'Oak Row', '3001', '410-555-0352', 0);

INSERT INTO Hotels
values (hotels_pk.nextval, 'H4', 'SC', 'Hilton Head Island', 'Beach Route', '4001', '803-555-0875', 0);

INSERT INTO Hotels
values (hotels_pk.nextval, 'H5', 'NY', 'New York', 'Hazelnut Street', '5001', '201-555-0026', 0);

--Insert statements for Rooms
INSERT INTO Rooms
values (rooms_pk.nextval, 'Single', 1, '101');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Double', 1, '102');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Suite', 1, '103');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Conference', 1, '104');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Single', 2, '101');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Double', 2, '102');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Suite', 2, '103');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Conference', 2, '104');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Single', 3, '101');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Double', 3, '102');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Suite', 3, '103');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Conference', 3, '104');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Single', 4, '101');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Double', 4, '102');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Suite', 4, '103');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Conference', 4, '104');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Double', 4, '105');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Single', 5, '101');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Double', 5, '102');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Suite', 5, '103');

INSERT INTO Rooms
values (rooms_pk.nextval, 'Conference', 5, '104');

--Insert statements for Reservations 
INSERT INTO Reservations
values (reservations_pk.nextval, TO_DATE('2021-02-13','YYYY-MM-DD'), TO_DATE('2021-02-15','YYYY-MM-DD'), 
TO_DATE('2021-02-19','YYYY-MM-DD'), 1, 1, 0, 1, 0, 0);

INSERT INTO Reservations
values (reservations_pk.nextval, TO_DATE('2021-02-13','YYYY-MM-DD'), TO_DATE('2021-02-15','YYYY-MM-DD'), 
TO_DATE('2021-02-19','YYYY-MM-DD'), 6, 2, 1, 0, 0, 0);

INSERT INTO Reservations
values (reservations_pk.nextval, TO_DATE('2021-02-13','YYYY-MM-DD'), TO_DATE('2021-02-15','YYYY-MM-DD'), 
TO_DATE('2021-02-19','YYYY-MM-DD'), 11, 3, 0, 0, 1, 0);

INSERT INTO Reservations
values (reservations_pk.nextval, TO_DATE('2021-06-10','YYYY-MM-DD'), TO_DATE('2021-06-14','YYYY-MM-DD'), 
TO_DATE('2021-06-18','YYYY-MM-DD'), 16, 4, 2, 0, 0, 0);

INSERT INTO Reservations
values (reservations_pk.nextval, TO_DATE('2021-06-10','YYYY-MM-DD'), TO_DATE('2021-06-14','YYYY-MM-DD'), 
TO_DATE('2021-06-18','YYYY-MM-DD'), 17, 5, 1, 1, 0, 0);

/*
SELECT * FROM Customers;
SELECT * FROM Hotels;
SELECT * FROM Reservations;
SELECT * FROM Rooms;
*/


SET SERVEROUTPUT ON;

/*
PROC TOC
--sam
showHotelReservations
showCustomerReservations
changeReservationDate
createIncomeReport

--Jason
findCustomer
findHotel
findRoom
makeReservation
findReservation (procedure)
find_reservation (function)
cancelReservation
showCancellations

--Susmitha
Add_a_hotel
Create_Room (ONLY FOR HOTEL CREATION)
Find_a_hotel (function, returns HID from street address)
Display_hotel (display procedure for above function)
Report_hotels_new
sell_hotel

--Morgan

--Grace
total_service_report
addService
getReservationServices

*/
-----------------LOOKUP FUNCTIONS AND DEPENDENCIES-----------------------------
CREATE OR REPLACE FUNCTION findCustomer (cusName in varchar) RETURN INTEGER
IS

cusID reservations.customer_id%type;

BEGIN
    SELECT customer_id into cusID
    FROM customers
    WHERE customer_name = cusName;
    
    RETURN cusID;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        cusID := 0;
        RETURN cusID;
        DBMS_OUTPUT.PUT_LINE('Customer was not Found'); -- Prints an error message if Reservation was not found
END;
/
CREATE OR REPLACE FUNCTION findHotel (hotelName in varchar) RETURN INTEGER
IS

hotelid hotels.hotel_id%type;

BEGIN
    SELECT hotel_id into hotelid
    FROM hotels
    WHERE hotels.hotel_name = hotelName;
    
    RETURN hotelid;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        hotelid := 0;
        RETURN hotelid;
END;
/
CREATE OR REPLACE FUNCTION findRoom(hotel_requested IN varchar, type_requested IN varchar, check_in_requested IN date)
    RETURN INTEGER
IS

openRoomNum INTEGER := 0; -- Stores room number of an avaliable room
openRoom INTEGER := 0; -- Stores the room ID of an avaliable room

hotel_match INTEGER := findHotel(hotel_requested);
hotel_status_check INTEGER;

--Fill cursor with all rooms from a specfic hotel of a specfic room type
CURSOR roomFinder
IS
    SELECT *
    FROM rooms
    LEFT JOIN reservations
    ON rooms.room_id = reservations.room_id
    WHERE rooms.hotel_id = hotel_match
    AND rooms.room_type = type_requested;
    
roomFinderRow roomFinder%rowtype;

hotel_sold EXCEPTION;

BEGIN

    SELECT is_sold INTO hotel_status_check
    FROM hotels
    WHERE hotel_id = hotel_match;
    
    IF hotel_status_check = 1 THEN
        raise hotel_sold;
    END IF;

    --Loop through every row in the cursor to find an avaliable room
    FOR roomFinderRow in roomFinder
        LOOP
            IF roomFinderRow.reservation_id IS NULL OR roomFinderRow.check_out_date < check_in_requested THEN
                openRoomNum := roomFinderRow.room_number;
                EXIT;
            END IF;
        END LOOP;
   
   --If a suituable room is found then the ID is searched for based on the hotel's ID and Room num
   IF openRoomNum != 0 THEN 
        SELECT room_id INTO openRoom
        FROM rooms
        WHERE hotel_id = hotel_match
        AND room_number = openRoomNum;
    END IF;
    
    --Returns a 0 if the Room is not found
    RETURN openRoom;
    
    --If a matching room ID is not found for the roomnum an error is thrown
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('No room matching the criteria was found.');
        WHEN hotel_sold THEN
            RETURN -1;
END;
/
CREATE OR REPLACE FUNCTION find_Reservation (cusName in varchar, resDate in date, hotelName in varchar) RETURN INTEGER
IS 

--Create variables to hold ids found based on inputted information
cusID customers.customer_id%type := findCustomer(cusName);
hotelID hotels.hotel_id%type := findHotel(hotelName);

requestRes reservations.reservation_id%type;

--Cursor that stores all avaliable reservations joined with all the rooms each reservation belongs to
CURSOR resFinder
IS
    SELECT *
    FROM reservations
    LEFT JOIN rooms
    ON reservations.room_id = rooms.room_id;

resFinderRow resFinder%rowtype;

--declaring expections for case when functions do not find an ID being searched for
no_customer_found EXCEPTION;
no_hotel_found EXCEPTION;

BEGIN
    -- Raise expections if ID values are not returned
    IF cusID = 0 THEN
        RAISE no_customer_found;
    END IF;
    
    IF hotelID = 0 THEN
        RAISE no_hotel_found;
    END IF;
    
    --DBMS_OUTPUT.PUT_LINE('Reservations belonging to: ' || cusName);
    
    --loop through the cursor to find all matching reservations based on input criteria
    FOR resFinderRow in resFinder
        LOOP
            IF resFinderRow.customer_id = cusID AND resFinderRow.hotel_id = hotelid AND resFinderRow.booking_date = resDate THEN
                requestRes := resFinderRow.reservation_id;
            END IF;
        END LOOP;
    RETURN requestRes;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No Reservation was found'); -- Prints an error message if Reservation was not found
    WHEN no_customer_found THEN
        DBMS_OUTPUT.PUT_LINE('No Customer was found');
    WHEN no_hotel_found THEN
        DBMS_OUTPUT.PUT_LINE('No Hotel was found');
END;
/

CREATE OR REPLACE PROCEDURE displayNames (memberNum IN VARCHAR)
IS

BEGIN

    DBMS_OUTPUT.PUT_LINE('Below is the work of member '|| memberNum);

END;
/

---------------------------------MEMBER 1 CODE---------------------------------

--PROCEDURE to create a rooms
--Inputs hotel_id, p_room_type
CREATE OR REPLACE PROCEDURE Create_Room(hotel_id IN integer)
IS
 hotel number;
BEGIN
	SELECT max(hotel_id) INTO hotel FROM HOTELS;
--Loop to insert values based on the type of the room when single
	--if(p_room_type = 'single') THEN
	  FOR i IN 1..50
	  LOOP
        INSERT INTO rooms values(rooms_pk.nextval,'single', hotel_id,i);
	  END LOOP;
	--END if;

--Loop to insert values based on the type of the room when double 
	--if(p_room_type = 'double') THEN
	  FOR i IN 51..70
	  LOOP
         INSERT INTO rooms values(rooms_pk.nextval,'double', hotel_id,i);
	  END LOOP;
	--END if;

--Loop to insert values based on the type of the room when suite
	--if(p_room_type = 'suite') THEN
	  FOR i IN 71..75
	  LOOP
        INSERT INTO rooms values(rooms_pk.nextval,'suite', hotel_id,i);
	  END LOOP;
	--END if;

--Loop to insert values based on the type of the room when conference
	--if(p_room_type = 'conference') THEN
	  FOR i IN 76..77
	  LOOP
        INSERT INTO rooms values(rooms_pk.nextval,'conference', hotel_id,i);
	  END LOOP;
	--END if;

--Exceptions when room type is not found
	EXCEPTION 
        WHEN no_data_found THEN 
        dbms_output.put_line('Entered type room not found!'); 
END;
/

--PROCEDURE to add a hotel
--Inputs: p_hotel_state, p_city, p_street, p_street_number, p_phone_number
CREATE OR REPLACE PROCEDURE Add_a_Hotel(
          p_hotel_name IN varchar,
          p_hotel_state IN varchar,
          p_city  IN varchar,
          p_street  IN varchar,
          p_street_number  IN varchar,
          p_phone_number  IN varchar
          )
IS
HID_L int;
BEGIN
    HID_L := hotels_pk.nextval;
    DBMS_OUTPUT.PUT_LINE('Creating Hotel ' || p_hotel_name || ' with ID: ' || HID_L);
	INSERT INTO HOTELS VALUES        (
	HID_L,p_hotel_name,p_hotel_state,p_city,p_street,p_street_number,p_phone_number,0);
 	Create_Room(HID_L);
        EXCEPTION 
        WHEN no_data_found THEN 
        dbms_output.put_line('No such hotel!');
END;
/

--FUNCTION to Find a hotel id
--Inputs: Street name
CREATE OR REPLACE FUNCTION Find_a_hotel(hotelName IN varchar) RETURN integer
IS
findhotel_id integer;
BEGIN
	SELECT hotel_id INTO findhotel_id
	FROM hotels
	WHERE hotel_name=hotelName;
	RETURN findhotel_id;
        DBMS_OUTPUT.PUT_LINE('HOTEL_ID = '|| findhotel_id);

	EXCEPTION 
        WHEN no_data_found THEN 
        dbms_output.put_line('No such hotel found');
END;
/

--Procedure to display hotel id
--Inputs: street name
CREATE OR REPLACE PROCEDURE Display_hotel(hotelName IN varchar)
IS
findhotel_id integer;
hotel integer;
BEGIN
	hotel := Find_a_hotel(hotelName);
    	DBMS_OUTPUT.PUT_LINE('HOTEL_ID = '|| hotel);

	EXCEPTION 
        WHEN no_data_found THEN 
        dbms_output.put_line('No such hotel to display!');
END;
/

--Procedure to report hotels in the state
--Inputs: State Name
CREATE OR REPLACE PROCEDURE Report_hotels_new(state_requested IN varchar2) 
IS
single_room integer:=0;
double_room integer:=0;
suite_room  integer:=0;
conference_room integer:=0;
cursor c1 is SELECT * from hotels inner join rooms on hotels.hotel_id=rooms.hotel_id where hotels.hotel_state=state_requested;
row_finder c1%rowtype;
BEGIN
for row_finder in c1
loop
--if condition to find type of room
if(row_finder.room_type='single') then
single_room:= single_room+1;
elsif(row_finder.room_type='double') then
double_room:=double_room+1;
elsif(row_finder.room_type='suite') then
suite_room:=suite_room+1;
else 
conference_room:=conference_room+1;
end if;
end loop;
--loop to display the hotels data from the requested state
for i in
(SELECT 
Hotel_id, HOTEL_STATE ,CITY ,STREET ,STREET_NUMBER ,PHONE_NUMBER,IS_SOLD 
FROM HOTELS
WHERE hotels.hotel_state = state_requested)
loop
dbms_output.put_line(i.hotel_id||','||i.hotel_state||','||i.city||','||i.street_number||','||i.phone_number||','||i.is_sold);

END loop;
dbms_output.put_line('single room='|| single_room);
dbms_output.put_line('double room='|| double_room);
dbms_output.put_line('suite room='|| suite_room);
dbms_output.put_line('conference room='|| conference_room);
    EXCEPTION 
    WHEN no_data_found THEN 
    dbms_output.put_line('No such hotel!'); 
END;
/

--Procedure to sell hotel
--Inputs: Hotel_id
CREATE OR REPLACE PROCEDURE sell_hotel(hotelName IN varchar)
IS
hotelID int;
BEGIN
hotelID := findHotel(hotelName);

UPDATE hotels
set is_sold=1
where hotel_id=hotelid;

dbms_output.put_line('Hotel Sold!');
EXCEPTION 
    WHEN no_data_found THEN 
    dbms_output.put_line('No such hotel!'); 
END;
/




------------------------MEMBER 2 CODE----------------------------------------------

CREATE OR REPLACE PROCEDURE MakeReservation (hotel_requested IN varchar, cus_name IN varchar, type_requested IN varchar, start_date IN date, end_date IN date, book_date IN date)
IS

customer_match INTEGER := findCustomer(cus_name); -- Variable used to store the customer id
room_match INTEGER := findRoom(hotel_requested, type_requested, start_date); -- Variable used to store an avaliable room

resKey INTEGER := reservations_pk.nextval;

no_room_found EXCEPTION;
hotel_sold EXCEPTION;

BEGIN
    
    IF room_match = 0 THEN -- If the findRoom function returns 0, no room was found
        RAISE no_room_found; 
    END IF;
    
    IF room_match = -1 THEN -- If the findRoom function returns 0, no room was found
        RAISE hotel_sold; 
    END IF;
    
    INSERT INTO Reservations
    values (resKey, book_date, start_date, end_date, room_match, customer_match, 0, 0, 0, 0); -- Insert new reservation into the table
    
    --Print values of reservation as confirmation
    DBMS_OUTPUT.PUT_LINE('New Reservation created for '|| cus_name);
    DBMS_OUTPUT.PUT_LINE('Customer ID: '|| customer_match);
    DBMS_OUTPUT.PUT_LINE('Room ID: '|| room_match);
    DBMS_OUTPUT.PUT_LINE('Reservation ID: '|| resKey);
    
EXCEPTION
    WHEN no_room_found THEN
        DBMS_OUTPUT.PUT_LINE('No room matching that criteria was found.'); -- Prints an error message when room was not found
    WHEN hotel_sold THEN
        DBMS_OUTPUT.PUT_LINE('This reservation cannot be created due to the requested Hotel being sold. Sorry for the inconvenience.');
END;
/


CREATE OR REPLACE PROCEDURE findReservation (cusName in varchar, resDate in date, hotelName in varchar)
IS 

--Create variables to hold ids found based on inputted information
cusID customers.customer_id%type := findCustomer(cusName);
hotelID hotels.hotel_id%type := findHotel(hotelName);

requestRes reservations.reservation_id%type;

--Cursor that stores all avaliable reservations joined with all the rooms each reservation belongs to
CURSOR resFinder
IS
    SELECT *
    FROM reservations
    LEFT JOIN rooms
    ON reservations.room_id = rooms.room_id;

resFinderRow resFinder%rowtype;

--declaring expections for case when functions do not find an ID being searched for
no_customer_found EXCEPTION;
no_hotel_found EXCEPTION;

BEGIN
    -- Raise expections if ID values are not returned
    IF cusID = 0 THEN
        RAISE no_customer_found;
    END IF;
    
    IF hotelID = 0 THEN
        RAISE no_hotel_found;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Reservations belonging to: ' || cusName);
    
    --loop through the cursor to find all matching reservations based on input criteria
    FOR resFinderRow in resFinder
        LOOP
            IF resFinderRow.customer_id = cusID AND resFinderRow.hotel_id = hotelid AND resFinderRow.booking_date = resDate THEN
                requestRes := resFinderRow.reservation_id;
                DBMS_OUTPUT.PUT_LINE('Customer ID: '|| cusID);
                DBMS_OUTPUT.PUT_LINE('Booking Date: '|| resDate);
                DBMS_OUTPUT.PUT_LINE('Reservation ID: '|| requestRes);
            END IF;
        END LOOP;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No Reservation was found'); -- Prints an error message if Reservation was not found
    WHEN no_customer_found THEN
        DBMS_OUTPUT.PUT_LINE('No Customer was found');
    WHEN no_hotel_found THEN
        DBMS_OUTPUT.PUT_LINE('No Hotel was found');
END;
/


CREATE OR REPLACE PROCEDURE cancelReservation (cusName in varchar, resDate in date, hotelName in varchar)
IS

res_to_cancel INTEGER := find_Reservation(cusName, resDate, hotelName);

BEGIN
    --Updates a int is_cancelled column in the reservations table where the ID matches. 0 = not cancelled, 1 = cancelled.
    UPDATE reservations
    SET is_cancelled = 1
    WHERE reservation_id = res_to_cancel;
    
    --Prints a confirmation message after the reservation is cancelled
    DBMS_OUTPUT.PUT_LINE('Reservation ID: ' || res_to_cancel || ' has been cancelled');
    
    --If a matching reservation is not found an error is thrown and printed to alert the user.
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('No reservation matching the provided ID was found.');
END;
/
CREATE OR REPLACE PROCEDURE ShowCancelations
IS

hotelLocation hotels.city%type;
guestName customers.customer_name%type;

runCounter integer;

CURSOR cancelFinder
IS
    SELECT *
    FROM reservations
    LEFT JOIN rooms
    ON reservations.room_id = rooms.room_id;

cancelFinderRow cancelFinder%rowtype;

no_cancels EXCEPTION;
    
BEGIN
    
    FOR resFinderRow in cancelFinder
        LOOP
            IF resFinderRow.is_cancelled = 1 THEN
                
                SELECT city INTO hotelLocation
                FROM hotels
                WHERE hotel_id = resFinderRow.hotel_id;
                
                SELECT customer_name INTO guestName
                FROM customers
                WHERE customer_id = resFinderRow.customer_id;
                
                runCounter := runCounter + 1;
                
                DBMS_OUTPUT.PUT_LINE('Reservation ID: '|| resFinderRow.customer_id);
                DBMS_OUTPUT.PUT_LINE('Customer Name: ' || guestName);
                DBMS_OUTPUT.PUT_LINE('Hotel Location: ' || hotelLocation);
                DBMS_OUTPUT.PUT_LINE('Room Type: '|| resFinderRow.room_type);
                DBMS_OUTPUT.PUT_LINE('Check In Date: '|| resFinderRow.check_in_date);
                DBMS_OUTPUT.PUT_LINE('Check Out Date: '|| resFinderRow.check_out_date);
                DBMS_OUTPUT.PUT_LINE('Booking Date: '|| resFinderRow.booking_date);
                DBMS_OUTPUT.PUT_LINE('');
            END IF;
        END LOOP;
    
    IF runCounter = 0 THEN
        RAISE no_cancels;
    END IF;
    
    EXCEPTION
    WHEN no_cancels THEN
        DBMS_OUTPUT.PUT_LINE('Database contains no cancelled reservations');
END;
/

---------------------MEMBER 3 CODE---------------------------------------
--Given the hotel ID, return all reservations at that hotel
create or replace procedure showHotelReservations(hName_L in varchar)
IS
HID_L integer;
CURSOR HC1 IS SELECT R.reservation_ID 
    FROM Reservations R, Rooms RM
    WHERE R.Room_ID = RM.Room_ID
    AND RM.Hotel_ID = HID_L;
    R_ID Reservations.reservation_ID%type;
    
    
BEGIN
    HID_L := findHotel(hName_L);
    dbms_output.put_line('Reservations at Hotel ' || HID_L || ':');
    open HC1;
    loop
        fetch HC1 into R_ID;
        exit when HC1%NOTFOUND;
        dbms_output.put_line('Reservation ID: ' ||R_ID);
    END LOOP;
    close HC1;
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Hotel with this ID does not exist');
END;
/
--Given guest name, return all reservations under their name
create or replace procedure showCustomerReservations(custName in varchar)
IS
CURSOR HC2 IS SELECT R.reservation_ID 
    FROM Reservations R, Customers C
    WHERE R.customer_ID = C.customer_ID
    AND c.customer_name = custName;
    R_ID Reservations.reservation_ID%type;
BEGIN
    dbms_output.put_line('Reservations under guest ' || custName || ':');
    open HC2;
    loop
        fetch HC2 into R_ID;
        exit when HC2%NOTFOUND;
        dbms_output.put_line('Reservation ID: ' || R_ID);
    END LOOP;
    close HC2;
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Customer with this name does not exist');
END;
/
--Given a Res ID and desired new dates, amend the dates of a reservation.
--If no rooms of the same type at the same hotel are available, reject.
create or replace procedure changeReservationDate(custName in varchar, desiredType in varchar, hotel in varchar, bookDate in date, startDate in date, endDate in date)
IS
resID integer;
--Cursor HC3: Given the hotel and room type, fetch all rooms
CURSOR HC3 (HID integer, rType varchar) IS SELECT RM.Room_ID
FROM Rooms RM
WHERE RM.Hotel_ID = HID
AND RM.Room_type = rType;

--Cursor HC4: Given the room ID, fetch all reservations for the room ordered by start date
CURSOR HC4 (roomID integer) IS SELECT *
FROM Reservations R
WHERE R.room_ID = roomID
AND NOT R.reservation_id = resID
ORDER BY R.check_in_date;

wrkRoom Rooms.Room_ID%TYPE; --what HC3 fetches to
wrkRes Reservations%ROWTYPE; --what HC4 fetches to
whatHotel Rooms.hotel_ID%TYPE; --Hotel the reservation must be at
whatType Rooms.room_type%TYPE; --room type the reservation must be
conflictFound boolean := FALSE;
reservationFound boolean := FALSE;

BEGIN

resID := find_Reservation(custName, bookDate, hotel);
dbms_output.put_line('resID: ' || resID);
--get hotel ID and room type of existing reservation
SELECT RM.hotel_ID, RM.room_type
INTO whatHotel, whatType
FROM Rooms RM, Reservations R
WHERE RM.room_ID = R.room_ID
AND R.reservation_ID = resID;

open HC3(whatHotel, desiredType);
LOOP --iterate throuth all rooms of the same type in the hotel
    conflictFound := FALSE;
    fetch HC3 into wrkRoom;
    EXIT WHEN HC3%NOTFOUND;
    open HC4(wrkRoom);
    LOOP --iterate through all reservations on that room and check for availability
        fetch HC4 into wrkRes;
        EXIT WHEN HC4%NOTFOUND;
        --compare dates to see if new reservation overlaps with existing reservations
        IF(NOT(wrkRes.check_out_date < startDate OR endDate < wrkRes.check_in_date))
            THEN
            conflictFound := TRUE;
            EXIT;
        END IF;
    END LOOP;
    --If all reservations have been checked for this room and no conflicts, update.
    IF(HC4%NOTFOUND AND conflictFound = FALSE) THEN
        dbms_output.put_line('A room is available, updating reservation!');
        reservationFound := TRUE;
        
        UPDATE Reservations
        SET 
        check_in_date = startDate,
        check_out_date = endDate,
        room_ID = wrkRoom
        WHERE reservation_ID = resID;
        
        EXIT;
    END IF;
    close HC4;
END LOOP;
close HC3;
IF(reservationFound = FALSE) THEN
    dbms_output.put_line('No availability for selected visit');
END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Reservation with this ID does not exist');
END;
/


--Procedure 4: monthly income report
create or replace procedure createIncomeReport
IS
cursor HC5 (month number) is select R.reservation_id, R.booking_date,
R.check_in_date, R.check_out_date, RM.room_type, R.meal_count,
R.laundry_count, R.movies_count
from reservations R, rooms RM
where to_char(R.check_out_date, 'MM') = month
and R.room_id = RM.room_id;

resID reservations.reservation_id%TYPE;
bookDate reservations.booking_date%TYPE;
inDate reservations.check_in_date%TYPE;
outDate reservations.check_out_date%TYPE;
rmType rooms.room_type%TYPE;
mealCt reservations.meal_count%TYPE;
ldCt reservations.laundry_count%TYPE;
mvCt reservations.movies_count%TYPE;

numOfNights number;

singleIncome number := 0;
dblIncome number := 0;
suiteIncome number := 0;
confIncome number := 0;
mealIncome number := 0;
laundryIncome number := 0;
movieIncome number := 0;
monthlyIncome number := 0;

wrkMonth number := 1;
BEGIN
LOOP -- iterate through each month and total revenue
    exit when wrkMonth > 12;
    OPEN HC5(wrkMonth);
    LOOP --tally revenue for the month
        fetch HC5 into resID, bookDate, inDate, outDate, rmType, mealCt, ldCt, mvCt;
        --dbms_output.put_line('reservation is ' || resID);
        --calculate reservation cost
        numOfNights := outDate - inDate;
        --rates!
        exit when HC5%NOTFOUND;
        IF(wrkMonth < 5 OR wrkMonth >8) THEN -- when rates are low
            CASE
                WHEN rmType = 'single' THEN singleIncome := singleIncome + (100 * numOfNights);
                WHEN rmType = 'double' THEN dblIncome := dblIncome + (200 * numOfNights);
                WHEN rmType = 'suite' THEN suiteIncome := suiteIncome + (500 * numOfNights);
                WHEN rmType = 'conference' THEN confIncome := confIncome + (1000 * numOfNights);
                ELSE dbms_output.put_line('----------------------');
            END CASE;
        ELSE --when rates are high
            CASE
                WHEN rmType = 'single' THEN singleIncome := singleIncome + (300 * numOfNights);
                WHEN rmType = 'double' THEN dblIncome := dblIncome + (500 * numOfNights);
                WHEN rmType = 'suite' THEN suiteIncome := suiteIncome + (900 * numOfNights);
                WHEN rmType = 'conference' THEN confIncome := confIncome + (5000 * numOfNights);
                ELSE dbms_output.put_line('----------------------');
            END CASE;
        END IF;
        --apply early booking discount
        IF(inDate - bookDate > 60) THEN
            singleIncome := singleIncome * 0.9;
            dblIncome := dblIncome * 0.9;
            suiteIncome := suiteIncome * 0.9;
            confIncome := confIncome * 0.9;
        END IF;
        --augment service tallies
        mealIncome := mealIncome + mealCt * 20;
        laundryIncome := laundryIncome + ldCt * 10;
        movieIncome := movieIncome + mvCt * 5;
        --exit when HC5%NOTFOUND;
    END LOOP;
    CLOSE HC5;
    --calculate monthly income
    monthlyIncome := singleIncome + dblIncome + suiteIncome + confIncome
    + mealIncome + laundryIncome + movieIncome;
    IF(monthlyIncome > 0) THEN --OUTPUT
    dbms_output.put_line('Month ' || wrkMonth || ' Income: $' || monthlyIncome);
    dbms_output.put_line('Single Rooms: $' || singleIncome);
    dbms_output.put_line('Double Rooms: $' || dblIncome);
    dbms_output.put_line('Suites: $' || suiteIncome);
    dbms_output.put_line('Conference Rooms: $' || confIncome);
    
    dbms_output.put_line('Meals: $' || mealIncome);
    dbms_output.put_line('Laundry: $' || laundryIncome);
    dbms_output.put_line('Movies: $' || movieIncome);
    
    dbms_output.put_line('----------------');
    END IF;
    wrkMonth := wrkMonth + 1;
    --flush variables to track the next month
    mealCt := 0;
    ldCt:=0;
    mvCt:=0;
    
    resID := 0;
    rmType := '';
    
    mealIncome :=0;
    laundryIncome :=0;
    movieIncome :=0;
    singleIncome := 0;
    dblIncome :=0;
    suiteIncome :=0;
    confIncome :=0;
    monthlyIncome := 0;
END LOOP;
END;
/





-------------------------------MEMBER 4 CODE---------------------------------------

--PROC 16 general service report
create or replace procedure total_service_report (hotelName in varchar)
is
hotel int;
Teal int;
rice int;
wash int;
film int;
begin
hotel := findhotel(hotelName);
select hotels, meal_cost * 20, laundry_cost * 10, movies_cost * 5
into teal, rice, wash, film
from (
select h.hotel_id as hotels, sum(meal_count) as meal_cost, sum(laundry_count) as laundry_cost, sum(movies_count) as movies_cost
from reservations r inner join rooms s on r.room_id = s.room_id inner join hotels h on h.hotel_id = s.hotel_id
where h.hotel_id = hotel
group by h.hotel_id);
dbms_output.put_line('Meal Income: ' || rice);
dbms_output.put_line('Laundry Income: ' || wash);
dbms_output.put_line('Movie Income: ' || film);
end;
/

--PROC 13 add service to reservation
Create or replace Procedure addService(custName in varchar,resv_date IN DATE,hotelName in varchar, Service_name IN VARCHAR2)
AS
Resv_id int;
Begin
    Resv_id := find_reservation(custName, resv_date, hotelName);
    
    IF Service_name = 'Meals' then
    
        Update Reservations set Meal_count = Meal_count + 1 where reservation_id=resv_id;
        
    End If;
    
    IF Service_name='Laundry' then
    
        Update Reservations set Laundry_count=Laundry_count + 1 where reservation_id=resv_id;
        
    End If;
    
    IF Service_name='Movie' then
    
        Update Reservations set Movies_count= Movies_count + 1 where reservation_id=resv_id;
    End If;
    dbms_output.put_line('Service Added');
End;
/

--PROC 14 - input resID, output services on this reservation
create or replace procedure getReservationServices (custName in varchar,resv_date IN DATE,hotelName in varchar)
IS
resID_L int;
meal_count_L int;
laundry_count_L int;
movie_count_L int;
BEGIN
resID_L := find_reservation(custName, resv_date, hotelName);

dbms_output.put_line('Reservation Service Report For ResID: ' ||resID_L);

select meal_count into meal_count_L from reservations where reservation_ID = resID_L;
dbms_output.put_line('Meals: ' || meal_count_L);

select laundry_count into laundry_count_L from reservations where reservation_ID = resID_L;
dbms_output.put_line('Laundry: ' || laundry_count_L);

select movies_count into movie_count_L from reservations where reservation_ID = resID_L;
dbms_output.put_line('Movies: ' || movie_count_L);

END;
/

--PROC 15 - given a service, display all reservations that have this service
create or replace procedure getReservationsWithService(service in varchar)
IS
RID_L int;
cursor gc1_meals is select reservation_ID from reservations where meal_count != 0;
cursor gc1_laundry is select reservation_ID from reservations where laundry_count != 0;
cursor gc1_movies is select reservation_ID from reservations where movies_count != 0;
BEGIN
IF service = 'Meals' then
    open gc1_meals;
    LOOP
        
        FETCH gc1_meals into RID_L;
        EXIT WHEN gc1_meals%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Reservations with meal services: ' || RID_L);

    END LOOP;
    close gc1_meals;
End If;
IF service = 'Laundry' then
    open gc1_laundry;
    LOOP
        
        FETCH gc1_laundry into RID_L;
        EXIT WHEN gc1_laundry%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Reservations with laundry services: ' || RID_L);

    END LOOP;
    close gc1_laundry;
End If;
IF service = 'Movies' then
    open gc1_movies;
    LOOP
        
        FETCH gc1_movies into RID_L;
        EXIT WHEN gc1_movies%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Reservations with movie services: ' || RID_L);

    END LOOP;
    close gc1_movies;
End If;
END;
/

CREATE OR REPLACE PROCEDURE addMoreService (custName in varchar,resv_date IN DATE,hotelName in varchar, Service_name IN VARCHAR2)
IS

customerid INTEGER := findCustomer(custName);

startDate reservations.check_in_date%type;
endDate reservations.check_out_date%type;

daysBetween INTEGER := 0;
daysCounter INTEGER := 0;

BEGIN
    SELECT check_in_date into startDate
    FROM reservations
    WHERE customer_id = customerid AND booking_date = resv_date;
    
    --DBMS_OUTPUT.PUT_LINE(startDate);

    SELECT check_out_date into endDate
    FROM reservations
    WHERE customer_id = customerid AND booking_date = resv_date;

    --DBMS_OUTPUT.PUT_LINE(endDate);
    
    daysBetween := endDate - startDate;
    
    --DBMS_OUTPUT.PUT_LINE(daysBetween);
    
    IF Service_name = 'Meals' then
    
        Update Reservations set Meal_count = Meal_count + daysBetween where reservation_id=customerid;
        
    End If;
    
    IF Service_name='Laundry' then
    
        Update Reservations set Laundry_count=Laundry_count + daysBetween where reservation_id=customerid;
        
    End If;
    
    IF Service_name='Movie' then
    
        Update Reservations set Movies_count= Movies_count + daysBetween where reservation_id=customerid;
    End If;
    dbms_output.put_line('Services Added');
END;
/



------------------------------MEMBER 5 CODE--------------------------------------
--add room to hotel
create or replace procedure addHotelRooms(hotelName in varchar, roomType in varchar, instances in int)
IS
hotelID int;
roomID int;
roomNum int;
BEGIN
hotelID := findHotel(hotelName);
dbms_output.put_line('Adding Rooms...');
FOR i in 1 .. instances
    LOOP
        roomID := rooms_pk.nextval;
        roomNum := TO_NUMBER(hotelID || roomID);
        INSERT INTO rooms values (roomID, roomType, hotelID, roomNum);
END LOOP;

END;
/

--show available rooms by type
create or replace procedure showAvailableRooms(hotelName varchar)
IS
hotelID int;
singleCount int := 0;
doubleCount int := 0;
suiteCount int := 0;
conferenceCount int := 0;

cursor MC1 (hotelID INT) IS SELECT RM.room_id, RM.room_type
FROM reservations RES
RIGHT JOIN rooms RM ON RES.room_ID = RM.room_ID
WHERE RM.hotel_ID = hotelID AND
(SYSDATE NOT BETWEEN RES.check_in_date AND RES.check_out_date
OR RES.reservation_ID IS NULL);

roomID_L rooms.room_ID%TYPE;
roomType_L rooms.room_type%TYPE;
BEGIN
hotelID := findHotel(hotelName);

open MC1(hotelID);
LOOP
    fetch MC1 INTO roomID_L, roomType_L;
    exit when MC1%NOTFOUND;
    case roomType_L
        when 'single' then
        singleCount := singleCount + 1;
        when 'double' then
        doubleCount := doubleCount + 1;
        when 'suite' then
        suiteCount := suiteCount + 1;
        when 'conference' then
        conferenceCount := conferenceCount + 1;
        
    END CASE;
END LOOP;
close MC1;

dbms_output.put_line('Rooms in '|| hotelName);
dbms_output.put_line('Single Rooms: ' || singleCount);
dbms_output.put_line('Double Rooms: ' || doubleCount);
dbms_output.put_line('Suite Rooms: ' || suiteCount);
dbms_output.put_line('Conference Rooms: ' || conferenceCount);


END;
/



--checkout report
create or replace procedure createCheckoutReport(resID in int)
IS

/*
cursor MC2 (resID in int) is select R.reservation_id, R.booking_date,
R.check_in_date, R.check_out_date, RM.room_type, R.meal_count,
R.laundry_count, R.movies_count
from reservations R, rooms RM
where R.reservation_ID = resID
and R.room_id = RM.room_id;
*/
numOfNights number;

bookDate reservations.booking_date%TYPE;
inDate reservations.check_in_date%TYPE;
outDate reservations.check_out_date%TYPE;
rmType rooms.room_type%TYPE;
mealCt reservations.meal_count%TYPE;
ldCt reservations.laundry_count%TYPE;
mvCt reservations.movies_count%TYPE;

singleIncome number := 0;
dblIncome number := 0;
suiteIncome number := 0;
confIncome number := 0;
mealIncome number := 0;
laundryIncome number := 0;
movieIncome number := 0;

totalCost number := 0;
roomCost number := 0;
BEGIN

SELECT R.booking_date,
R.check_in_date, R.check_out_date, RM.room_type, R.meal_count,
R.laundry_count, R.movies_count
INTO bookDate, inDate, outDate, rmType, mealCt, ldCt, mvCt
FROM reservations R, rooms RM
WHERE R.reservation_ID = resID
AND R.room_id = RM.room_id;

numOfNights := outDate - inDate;

IF(TO_CHAR(bookDate, 'MM') < 5 OR TO_CHAR(bookDate, 'MM') >8) THEN -- when rates are low
            CASE
                WHEN rmType = 'single' THEN singleIncome := singleIncome + (100 * numOfNights);
                WHEN rmType = 'double' THEN dblIncome := dblIncome + (200 * numOfNights);
                WHEN rmType = 'suite' THEN suiteIncome := suiteIncome + (500 * numOfNights);
                WHEN rmType = 'conference' THEN confIncome := confIncome + (1000 * numOfNights);
                ELSE dbms_output.put_line('----------------------');
            END CASE;
        ELSE --when rates are high
            CASE
                WHEN rmType = 'single' THEN singleIncome := singleIncome + (300 * numOfNights);
                WHEN rmType = 'double' THEN dblIncome := dblIncome + (500 * numOfNights);
                WHEN rmType = 'suite' THEN suiteIncome := suiteIncome + (900 * numOfNights);
                WHEN rmType = 'conference' THEN confIncome := confIncome + (5000 * numOfNights);
                ELSE dbms_output.put_line('----------------------');
            END CASE;
END IF;
--apply early booking discount
IF(inDate - bookDate > 60) THEN
    singleIncome := singleIncome * 0.9;
    dblIncome := dblIncome * 0.9;
    suiteIncome := suiteIncome * 0.9;
    confIncome := confIncome * 0.9;
END IF;
--augment service tallies
mealIncome := mealCt * 20;
laundryIncome := ldCt * 10;
movieIncome := mvCt * 5;

totalCost := singleIncome + dblIncome + suiteIncome + confIncome
    + mealIncome + laundryIncome + movieIncome;

roomCost := singleIncome + dblIncome + suiteIncome + confIncome;

dbms_output.put_line('Total: $' || totalCost);
dbms_output.put_line('Room Rate: $' || roomCost);
dbms_output.put_line('Meals: $' || mealIncome);
dbms_output.put_line('Laundry: $' || laundryIncome);
dbms_output.put_line('Movies: $' || movieIncome);
END;
/
--checkout report driver - input is a customer, execute createCheckoutReport for each reservation they have
create or replace procedure createCustomerCheckoutReport (custName in varchar)
IS
resID int;
custID int;
cursor MC4 (custID int) IS SELECT reservation_ID
FROM reservations
WHERE customer_ID = custID;
BEGIN
--find customer ID from name
custID := findCustomer(custName);
--loop through all reservations and call the creation procedure
open MC4(custID);
LOOP
    fetch MC4 into resID;
    exit when MC4%NOTFOUND;
    dbms_output.put_line('Checkout Report for Reservation ' || resID);
    createCheckoutReport(resID);
END LOOP;
close MC4;
END;
/



--income by state - print total income from all sources of all hotels 
--in the state, print by room type and service type. Include discounts.
create or replace procedure createStateIncomeReport(state in varchar)
IS
cursor MC3 (state varchar) is select R.reservation_id, R.booking_date,
R.check_in_date, R.check_out_date, RM.room_type, R.meal_count,
R.laundry_count, R.movies_count
from reservations R, rooms RM, hotels H
where R.room_id = RM.room_id
and RM.hotel_ID = H.hotel_ID
and H.hotel_state = state;

resID reservations.reservation_id%TYPE;
bookDate reservations.booking_date%TYPE;
inDate reservations.check_in_date%TYPE;
outDate reservations.check_out_date%TYPE;
rmType rooms.room_type%TYPE;
mealCt reservations.meal_count%TYPE;
ldCt reservations.laundry_count%TYPE;
mvCt reservations.movies_count%TYPE;

numOfNights number;

singleIncome number := 0;
dblIncome number := 0;
suiteIncome number := 0;
confIncome number := 0;
mealIncome number := 0;
laundryIncome number := 0;
movieIncome number := 0;
stateIncome number := 0;

BEGIN

OPEN MC3(state);
    LOOP --tally revenue
        fetch MC3 into resID, bookDate, inDate, outDate, rmType, mealCt, ldCt, mvCt;
        --dbms_output.put_line('reservation is ' || resID);
        --calculate reservation cost
        numOfNights := outDate - inDate;
        --rates!
        exit when MC3%NOTFOUND;
        IF(TO_CHAR(bookDate, 'MM') < 5 OR TO_CHAR(bookDate, 'MM') >8) THEN -- when rates are low
            CASE
                WHEN rmType = 'single' THEN singleIncome := singleIncome + (100 * numOfNights);
                WHEN rmType = 'double' THEN dblIncome := dblIncome + (200 * numOfNights);
                WHEN rmType = 'suite' THEN suiteIncome := suiteIncome + (500 * numOfNights);
                WHEN rmType = 'conference' THEN confIncome := confIncome + (1000 * numOfNights);
                ELSE dbms_output.put_line('----------------------');
            END CASE;
        ELSE --when rates are high
            CASE
                WHEN rmType = 'single' THEN singleIncome := singleIncome + (300 * numOfNights);
                WHEN rmType = 'double' THEN dblIncome := dblIncome + (500 * numOfNights);
                WHEN rmType = 'suite' THEN suiteIncome := suiteIncome + (900 * numOfNights);
                WHEN rmType = 'conference' THEN confIncome := confIncome + (5000 * numOfNights);
                ELSE dbms_output.put_line('----------------------');
            END CASE;
        END IF;
        --apply early booking discount
        IF(inDate - bookDate > 60) THEN
            singleIncome := singleIncome * 0.9;
            dblIncome := dblIncome * 0.9;
            suiteIncome := suiteIncome * 0.9;
            confIncome := confIncome * 0.9;
        END IF;
        --augment service tallies
        mealIncome := mealIncome + mealCt * 20;
        laundryIncome := laundryIncome + ldCt * 10;
        movieIncome := movieIncome + mvCt * 5;
        --exit when MC3%NOTFOUND;
    END LOOP;
    CLOSE MC3;
    --calculate monthly income
    stateIncome := singleIncome + dblIncome + suiteIncome + confIncome
    + mealIncome + laundryIncome + movieIncome;
    dbms_output.put_line('Total income for '|| state);
    dbms_output.put_line('Total income for this state: $' || stateIncome);
    dbms_output.put_line('Single Rooms: $' || singleIncome);
    dbms_output.put_line('Double Rooms: $' || dblIncome);
    dbms_output.put_line('Suites: $' || suiteIncome);
    dbms_output.put_line('Conference Rooms: $' || confIncome);
    
    dbms_output.put_line('Meals: $' || mealIncome);
    dbms_output.put_line('Laundry: $' || laundryIncome);
    dbms_output.put_line('Movies: $' || movieIncome);
    
END;
/
---------------------------- EXEC STATEMENTS -----------------------------------------------

-----BEGIN TEST DEMO
--Member 1
exec displayNames('1');

exec add_a_hotel('H1', 'NY', 'NYC', '5th Avenue', '1000', '212-555-4093');
exec add_a_hotel('H2', 'MD', 'Baltimore', '4th Avenue', '1000', '212-555-4093');
exec add_a_hotel('H3', 'CA', 'San Francisco', '3rd Avenue', '1000', '212-555-4093');
exec add_a_hotel('H4', 'MD', 'Annapolis', '2nd Avenue', '1000', '212-555-4093');
exec add_a_hotel('H5', 'MD', 'Baltimore', '1st Avenue', '1000', '212-555-4093');

exec display_hotel('H3');
exec display_hotel('H2');

exec sell_hotel('H1');

exec report_hotels_new('MD');

--Member 2
exec displayNames('2');

EXEC MakeReservation ('H2', 'John Smith', 'suite', TO_DATE('2021-08-01','YYYY-MM-DD'), TO_DATE('2021-08-10','YYYY-MM-DD'), TO_DATE('2021-04-25','YYYY-MM-DD'));

EXEC MakeReservation ('H1', 'John Smith', 'double', TO_DATE('2021-08-01','YYYY-MM-DD'), TO_DATE('2021-08-10','YYYY-MM-DD'), TO_DATE('2021-04-25','YYYY-MM-DD'));

EXEC MakeReservation ('H4', 'Arnold Patterson', 'conference', TO_DATE('2021-05-01','YYYY-MM-DD'), TO_DATE('2021-05-05','YYYY-MM-DD'), TO_DATE('2021-04-25','YYYY-MM-DD'));

EXEC MakeReservation ('H4', 'Arnold Patterson', 'double', TO_DATE('2021-06-10','YYYY-MM-DD'), TO_DATE('2021-06-15','YYYY-MM-DD'), TO_DATE('2021-05-25','YYYY-MM-DD'));

EXEC FindReservation ('Arnold Patterson', TO_DATE('2021-05-25','YYYY-MM-DD'), 'H4');

EXEC MakeReservation ('H4', 'Mary Wise', 'single', TO_DATE('2021-05-10','YYYY-MM-DD'), TO_DATE('2021-05-15','YYYY-MM-DD'), TO_DATE('2021-04-28','YYYY-MM-DD'));

EXEC MakeReservation ('H4', 'Mary Wise', 'double', TO_DATE('2021-05-01','YYYY-MM-DD'), TO_DATE('2021-05-05','YYYY-MM-DD'), TO_DATE('2021-04-25','YYYY-MM-DD'));

EXEC CancelReservation ('Arnold Patterson', TO_DATE('2021-05-25','YYYY-MM-DD'), 'H4');

EXEC CancelReservation ('John Smith', TO_DATE('2021-04-25','YYYY-MM-DD'), 'H2');

EXEC ShowCancelations;

--Member 3
exec displayNames('3');

exec changeReservationDate('Arnold Patterson', 'conference', 'H4', TO_DATE('2021-04-25','YYYY-MM-DD'),TO_DATE('2021-06-01','YYYY-MM-DD'),TO_DATE('2021-06-05','YYYY-MM-DD'));

exec changeReservationDate('Mary Wise', 'single', 'H4', TO_DATE('2021-04-25','YYYY-MM-DD'),TO_DATE('2021-05-01','YYYY-MM-DD'),TO_DATE('2021-05-05','YYYY-MM-DD'));

exec showHotelReservations('H4');

exec showCustomerReservations('Mary Wise');

exec createIncomeReport();
--Member 4
exec displayNames('4');
--(custName in varchar,resv_date IN DATE,hotelName in varchar, Service_name IN VARCHAR2)
exec addMoreService ('Mary Wise', TO_DATE('2021-04-28','YYYY-MM-DD'), 'H4', 'Meals');

exec addMoreService ('Mary Wise', TO_DATE('2021-04-25','YYYY-MM-DD'), 'H4', 'Meals');

exec addService ('Mary Wise', TO_DATE('2021-04-25','YYYY-MM-DD'), 'H4', 'Movie');

exec addService ('Mary Wise', TO_DATE('2021-04-25','YYYY-MM-DD'), 'H4', 'Laundry');

exec getReservationServices ('Mary Wise' , TO_DATE('2021-04-25','YYYY-MM-DD'), 'H4');

exec getReservationsWithService('Meals');

exec total_service_report ('H4');

--Member 5 Tasks
exec displayNames('3');
--add 10 conference rooms to H4
exec addHotelRooms('H4','conference',10);

--show available rooms by type in H4
exec showAvailableRooms('H4');

--show invoice of all reservations by Mary Wise
exec createCustomerCheckoutReport('Mary Wise');

--Show income report for MD
exec createStateIncomeReport('MD');





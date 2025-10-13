--MISSING VALUE PERCENTAGE PER COLUMN
USE BOOKINGS_PROJECT
SELECT
(COUNT(*)- COUNT(Date))*100/COUNT(*) AS MV_DATE,
(COUNT(*)- COUNT(Time))*100/COUNT(*) AS MV_TIME,
(COUNT(*)- COUNT(Booking_ID))*100/COUNT(*) AS BOOKING_ID,
(COUNT(*)- COUNT(Booking_Status))*100/COUNT(*) AS MV_BOOKING_STATUS,
(COUNT(*)- COUNT(Customer_ID))*100/COUNT(*) AS MV_CUSTOMER_ID,
(COUNT(*)- COUNT(Vehicle_Type))*100/COUNT(*) AS MV_VEHICLE_TYPE,
(COUNT(*)- COUNT(Pickup_Location))*100/COUNT(*) AS MV_PICKUP_LOCATION,
(COUNT(*)- COUNT(Drop_Location))*100/COUNT(*) AS MV_DROP_LOCATION,
(COUNT(*)- COUNT(Avg_VTAT))*100/COUNT(*) AS MV_AVG_VTAT,
(COUNT(*)- COUNT(Cancelled_Rides_by_Customer))*100/COUNT(*) AS MV_CANCELLED_BY_CUSTOMER,
(COUNT(*)- COUNT(Reason_for_cancelling_by_Customer))*100/COUNT(*) AS MV_CANCEL_REASON_CUSTOMER,
(COUNT(*)- COUNT(Cancelled_Rides_by_Driver))*100/COUNT(*) AS MV_CANCELLED_BY_DRIVER,
(COUNT(*)- COUNT(Driver_Cancellation_Reason))*100/COUNT(*) AS MV_CANCEL_REASON_DRIVER,
(COUNT(*)- COUNT(Incomplete_Rides))*100/COUNT(*) AS MV_INCOMPLETE_RIDES,
(COUNT(*)- COUNT(Incomplete_Rides_Reason))*100/COUNT(*) AS MV_INCOMPLETE_RIDES_REASON,
(COUNT(*)- COUNT(Booking_Value))*100/COUNT(*) AS MV_BOOKINGS_VALUE,
(COUNT(*)- COUNT(Ride_Distance))*100/COUNT(*) AS MV_RIDE_DISTANCE,
(COUNT(*)- COUNT(Driver_Ratings))*100/COUNT(*) AS MV_DRIVER_RATINGS,
(COUNT(*)- COUNT(Customer_Rating))*100/COUNT(*) AS MV_CUSTOMER_RATING,
(COUNT(*)- COUNT(Payment_Method))*100/COUNT(*) AS MV_PAYMENT_METHOD
FROM BOOKINGS_RAW;
--Row count before cleaning
SELECT * FROM BOOKINGS_RAW;
--ROW_COUNT=150 000 ROWS
-----------------------------------------------------------
--CREATING THE BOOKINGS COLUMN WITH ONLY VALID ROW DATA
SELECT 
    [Date], [Time], [Booking_ID], [Booking_Status], [Customer_ID], [Vehicle_Type], 
    [Pickup_Location], [Drop_Location], [AVG_VTAT], [Avg_CTAT], 
    [Cancelled_Rides_by_Customer], [Reason_for_cancelling_by_Customer], 
    [Cancelled_Rides_by_Driver], [Driver_Cancellation_Reason], 
    [Incomplete_Rides], [Incomplete_Rides_Reason], [Booking_Value], 
    [Ride_Distance], [Driver_Ratings], [Customer_Rating], [Payment_Method]
INTO BOOKINGS_PROJECT.dbo.BOOKINGS
FROM BOOKINGS_PROJECT.dbo.BOOKINGS_RAW
WHERE 
    [Date] IS NOT NULL 
    AND [Time] IS NOT NULL 
    AND [Booking_ID] IS NOT NULL 
    AND [Booking_Status] IS NOT NULL 
    AND [Customer_ID] IS NOT NULL 
    AND [Vehicle_Type] IS NOT NULL 
    AND [Pickup_Location] IS NOT NULL 
    AND [Drop_Location] IS NOT NULL 
    AND[Booking_Value] IS NOT NULL 
    AND [Ride_Distance] IS NOT NULL AND [Payment_Method] IS NOT NULL;
--ROW COUNT AFTER CLEANING
SELECT * FROM BOOKINGS
-- ROW COUNT= 102 000
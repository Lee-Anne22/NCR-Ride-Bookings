USE BOOKINGS_PROJECT
--OPERATIONAL PERFORMANCE: FIND COMPLETION RATE FOR VEHICLE TYPES AND RANK THEM
ALTER TABLE BOOKINGS 
DROP [Completion_Rate] ;
--  Compute completion rate per Vehicle_Type
SELECT 
    Vehicle_Type,
    COUNT(CASE WHEN Booking_Status = 'Completed' THEN 1 END) * 1.0 /
    NULLIF(COUNT(CASE WHEN Booking_Status IN ('Completed', 'Cancelled', 'Incomplete') THEN 1 END), 0) AS Completion_Rate,
    RANK() OVER (
        ORDER BY 
            COUNT(CASE WHEN Booking_Status = 'Completed' THEN 1 END) * 1.0 /
            NULLIF(COUNT(CASE WHEN Booking_Status IN ('Completed', 'Cancelled', 'Incomplete') THEN 1 END), 0) DESC
    ) AS Completion_Rank
FROM 
    Bookings
GROUP BY 
    Vehicle_Type;
--ROUTE PROFITABILITY:IDENTIFY TOP 10 ROUTES VIA BOOKING VALUE
SELECT TOP 10
    Route,
    COUNT(*) AS Ride_Count,  -- Calculates number of rides per route
    SUM(Booking_Value) AS Total_Booking_Value,
    ROUND(AVG(Booking_Value),2) AS Avg_Booking_Value
FROM 
    BOOKINGS
GROUP BY 
    Route
ORDER BY 
    SUM(Booking_Value) DESC;
--CANCELLATION FORENSICS
--TOP 5 CANCELLATION REASONS BY CUSTOMER
SELECT TOP 5
    ISNULL(NULLIF(LTRIM(RTRIM([Reason_for_cancelling_by_Customer])), ''), 'Unspecified') AS Cancel_Reason,
    COUNT(*) AS Reason_Count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS Percentage
FROM 
    BOOKINGS
WHERE 
    [Cancelled_Rides_by_Customer] > 0
GROUP BY 
    ISNULL(NULLIF(LTRIM(RTRIM([Reason_for_cancelling_by_Customer])), ''), 'Unspecified')
ORDER BY 
    Reason_Count DESC;
 --TOP 5 CANCELLATION REASONS BY Driver
 SELECT TOP 5
    ISNULL(NULLIF(LTRIM(RTRIM([Driver_Cancellation_Reason])), ''), 'Unspecified') AS Cancel_Reason,
    COUNT(*) AS Reason_Count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS Percentage
FROM 
    BOOKINGS
WHERE 
    [Cancelled_Rides_by_Driver] > 0
GROUP BY 
    ISNULL(NULLIF(LTRIM(RTRIM([Driver_Cancellation_Reason])), ''), 'Unspecified')
ORDER BY 
    Reason_Count DESC;
-- SERVICE LEVELS: AVG VTAT AND AVG CTAT BY HOUR OF DAY + LIST 3 BUSIEST HOURS
SELECT TOP 3
    DATEPART(HOUR, CAST([Time] AS TIME)) AS Hour_Of_Day,
    COUNT(*) AS Ride_Count,
    ROUND(AVG([AVG_VTAT]), 2) AS Avg_VTAT,
    ROUND(AVG([Avg_CTAT]), 2) AS Avg_CTAT
FROM 
    BOOKINGS
WHERE 
    [Booking_Status] = 'Completed'
GROUP BY 
    DATEPART(HOUR, CAST([Time] AS TIME))
ORDER BY 
    Ride_Count DESC;
--CUSTOMER COHORTS AND CHURN: DEFINE COHORTS VIA FIRST BOOKING MONTH,
---SIZE AND RETENTION INTO COMING MONTH
---LIST CUSTOMERS WHO BOOKED 2023 BUT HAD 0 BOOKINGS IN 2024
SELECT [Customer_ID]
FROM BOOKINGS
WHERE YEAR([Date]) = 2023
EXCEPT
SELECT [Customer_ID]
FROM BOOKINGS
WHERE YEAR([Date]) = 2024;


USE BOOKINGS_PROJECT
--DISTRIBUTION ANALYSIS: FOR FARE DISTRIBUTION
SELECT 
    -- Bucketed fare ranges
    CASE 
        WHEN [BOOKING_VALUE] < 100 THEN '<100'
        WHEN [BOOKING_VALUE] BETWEEN 100 AND 199.99 THEN '100-199.99'
        WHEN [BOOKING_VALUE] BETWEEN 200 AND 299.99 THEN '200-299.99'
        WHEN [BOOKING_VALUE] BETWEEN 300 AND 399.99 THEN '300-399.99'
        WHEN [BOOKING_VALUE] BETWEEN 400 AND 499.99 THEN '400-499.99'
        WHEN [BOOKING_VALUE] BETWEEN 500 AND 599.99 THEN '500-599.99'
        ELSE '>=600'
    END AS FARE_DISTRIBUTION_BUCKET,

    -- Count of bookings in each bucket
    COUNT(*) AS FARE_DISTRIBUTION_Count,

    -- Percentage of total bookings AND ROUNDED TO NEAREST 2 DECIMALS
    ROUND(CAST(COUNT(*) AS DECIMAL(10, 2)) * 100.0 / SUM(COUNT(*)) OVER (),2) AS Percentage
FROM BOOKINGS
GROUP BY 
    CASE 
        WHEN [BOOKING_VALUE] < 100 THEN '<100'
        WHEN [BOOKING_VALUE] BETWEEN 100 AND 199.99 THEN '100-199.99'
        WHEN [BOOKING_VALUE] BETWEEN 200 AND 299.99 THEN '200-299.99'
        WHEN [BOOKING_VALUE] BETWEEN 300 AND 399.99 THEN '300-399.99'
        WHEN [BOOKING_VALUE] BETWEEN 400 AND 499.99 THEN '400-499.99'
        WHEN [BOOKING_VALUE] BETWEEN 500 AND 599.99 THEN '500-599.99'
        ELSE '>=600'
    END;

--CATEGORICAL ANALYSIS: TOP 10 VEHICLE TYPES BY NUMBER OF BOOKING STATUS
WITH BookingCounts AS (
    SELECT 
    VEHICLE_TYPE,
    COUNT(BOOKING_STATUS) AS NUMBER_OF_BOOKINGS
    FROM BOOKINGS
    GROUP BY VEHICLE_TYPE
),
TotalBookings AS (
    SELECT SUM(NUMBER_OF_BOOKINGS) AS TOTAL_BOOKINGS
    FROM BookingCounts
)
SELECT 
    bc.VEHICLE_TYPE,
    bc.NUMBER_OF_BOOKINGS,
    ROUND(
        CAST(bc.NUMBER_OF_BOOKINGS AS DECIMAL(10, 2)) 
        / tb.TOTAL_BOOKINGS * 100, 
        2
    ) AS PercentageWithinCategory
FROM BookingCounts bc
CROSS JOIN TotalBookings tb
ORDER BY bc.NUMBER_OF_BOOKINGS DESC;
--RELATIONSHIP ANALYSIS: RIDE DISTANCE VS BOOKING VALUE VIA PEARSON CORRELATION
SELECT
    COUNT(*) AS N,
    SUM(ride_distance) AS SUM_X,
    SUM(booking_value) AS SUM_Y,
    SUM(ride_distance * booking_value) AS SUM_XY,
    SUM(ride_distance * ride_distance) AS SUM_X_SQUARED,
    SUM(booking_value * booking_value) AS SUM_Y_SQUARED,
    
    -- Pearson correlation coefficient
    (
        (COUNT(*) * SUM(ride_distance * booking_value) - SUM(ride_distance) * SUM(booking_value)) /
        SQRT(
            (COUNT(*) * SUM(ride_distance * ride_distance) - POWER(SUM(ride_distance), 2)) *
            (COUNT(*) * SUM(booking_value * booking_value) - POWER(SUM(booking_value), 2))
        )
    ) AS correlation_coefficient
FROM
    BOOKINGS;
--COMPARATIVE ANALYSIS: INSIGHT INTO BOOKING VALUES BASED ON PAYMENT METHOD
WITH RankedPayments AS (
    SELECT
        Payment_Method_Norm,
        booking_value,
        NTILE(4) OVER (PARTITION BY Payment_Method_Norm ORDER BY booking_value) AS quartile
    FROM
        BOOKINGS
),
QuartileStats AS (
    SELECT
        Payment_Method_Norm,
        MIN(booking_value) AS Min_Value,
        MAX(booking_value) AS Max_Value,
        -- Approximate quartiles
        MAX(CASE WHEN quartile = 1 THEN booking_value END) AS Q1,
        MAX(CASE WHEN quartile = 2 THEN booking_value END) AS Q2_Median,
        MAX(CASE WHEN quartile = 3 THEN booking_value END) AS Q3
    FROM
        RankedPayments
    GROUP BY
        Payment_Method_Norm
)
SELECT *
FROM QuartileStats
ORDER BY Payment_Method_Norm;
-- 1.1  Overall on-time delivery rate

SELECT
    COUNT(*)                                                              AS total_delivered_orders,
    SUM(CASE WHEN actual_delivery_time_min <= estimated_delivery_time_min
             THEN 1 ELSE 0 END)                                          AS on_time_orders,
    ROUND(100.0 * SUM(CASE WHEN actual_delivery_time_min <= estimated_delivery_time_min
             THEN 1 ELSE 0 END) / COUNT(*), 2)                           AS pct_on_time,
    ROUND(100.0 * SUM(CASE WHEN actual_delivery_time_min > estimated_delivery_time_min
             THEN 1 ELSE 0 END) / COUNT(*), 2)                           AS pct_late
FROM delivery;

 
-- 1.2  Is on-time performance improving or getting worse over time?

SELECT
    DATE_FORMAT(o.order_datetime, '%Y-%m')                               AS order_month,
    COUNT(*)                                                              AS total_orders,
    ROUND(100.0 * SUM(CASE WHEN d.actual_delivery_time_min <= d.estimated_delivery_time_min
             THEN 1 ELSE 0 END) / COUNT(*), 2)                           AS pct_on_time
FROM delivery d
JOIN orders o ON o.order_id = d.order_id
GROUP BY order_month
ORDER BY order_month;

-- 1.3  Which restaurants cause the most delays?

SELECT
    r.restaurant_id, r.restaurant_name, r.city, r.cuisine,
    COUNT(*)                                                              AS delivered_orders,
    ROUND(AVG(d.actual_delivery_time_min - d.estimated_delivery_time_min), 1) AS avg_delay_min,
    ROUND(100.0 * SUM(CASE WHEN d.actual_delivery_time_min > d.estimated_delivery_time_min
             THEN 1 ELSE 0 END) / COUNT(*), 2)                           AS pct_late
FROM delivery d
JOIN orders o ON o.order_id = d.order_id
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine
HAVING COUNT(*) >= 20
ORDER BY pct_late DESC
LIMIT 15;

-- 1.4  When is the business busiest? (hour of day)

SELECT
    HOUR(order_datetime)                                                  AS order_hour,
    COUNT(*)                                                              AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;
 
 
-- 1.5  Busiest day of the week
SELECT
    DAYNAME(order_datetime)                                               AS day_of_week,
    COUNT(*)                                                              AS total_orders
FROM orders
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');  

 
-- 1.5  Busiest day of the week
SELECT
    DAYNAME(order_datetime)                                               AS day_of_week,
    COUNT(*)                                                              AS total_orders
FROM orders
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

 
-- 1.6  Which cities (areas) have operational problems?

WITH city_cancel AS (
    SELECT
        r.city,
        COUNT(*)                                                          AS total_orders,
        SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)    AS cancelled_orders
    FROM orders o
    JOIN restaurants r ON r.restaurant_id = o.restaurant_id
    GROUP BY r.city
),
city_late AS (
    SELECT
        r.city,
        ROUND(100.0 * SUM(CASE WHEN d.actual_delivery_time_min > d.estimated_delivery_time_min
                 THEN 1 ELSE 0 END) / COUNT(*), 2)                       AS pct_late
    FROM delivery d
    JOIN orders o ON o.order_id = d.order_id
    JOIN restaurants r ON r.restaurant_id = o.restaurant_id
    GROUP BY r.city
)
SELECT
    cc.city,
    cc.total_orders,
    ROUND(100.0 * cc.cancelled_orders / cc.total_orders, 2)               AS pct_cancelled,
    cl.pct_late
FROM city_cancel cc
JOIN city_late cl ON cl.city = cc.city
ORDER BY cl.pct_late DESC;

-- =====================================================================
-- SECTION 2: CUSTOMERS
-- "Who are repeat customers? How often do they order? What's the AOV?
--  Which segments order most?"
-- =====================================================================
 
-- 2.1  Repeat vs one-time customers

WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE WHEN order_count = 1 THEN 'One-time' ELSE 'Repeat' END          AS customer_segment,
    COUNT(*)                                                              AS num_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)                    AS pct_of_customers
FROM customer_orders
GROUP BY customer_segment;

-- 2.2  How frequently do repeat customers order? (avg days between orders)

WITH ordered AS (
    SELECT
        customer_id,
        order_datetime,
        LAG(order_datetime) OVER (PARTITION BY customer_id ORDER BY order_datetime) AS prev_order
    FROM orders
    WHERE order_status <> 'Cancelled'
)
SELECT
    ROUND(AVG(DATEDIFF(order_datetime, prev_order)), 1)                   AS avg_days_between_orders
FROM ordered
WHERE prev_order IS NOT NULL;

-- 2.3  Average order value: repeat vs one-time customers

WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE WHEN co.order_count = 1 THEN 'One-time' ELSE 'Repeat' END        AS customer_segment,
    COUNT(*)                                                              AS total_orders,
    ROUND(AVG(o.order_amount), 2)                                         AS avg_order_value
FROM orders o
JOIN customer_orders co ON co.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY customer_segment;

-- 2.4  Which customer segments (city x loyalty tier) order the most?
SELECT
    c.city,
    c.customer_type,
    COUNT(*)                                                              AS total_orders,
    ROUND(SUM(o.order_amount), 2)                                         AS total_revenue,
    ROUND(AVG(o.order_amount), 2)                                         AS avg_order_value
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city, c.customer_type
ORDER BY total_revenue DESC;

-- =====================================================================
-- SECTION 3: RESTAURANTS
-- "Most orders? High cancellation rates? Good delivery performance?"
-- =====================================================================
 
-- 3.1  Restaurants by order volume
SELECT
    r.restaurant_name, r.city, r.cuisine,
    COUNT(*)                                                              AS total_orders
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine
ORDER BY total_orders DESC
LIMIT 15;
 
-- 3.2  Restaurants with high cancellation rates

WITH rest_cancel AS (
    SELECT
        r.restaurant_id, r.restaurant_name, r.city,
        COUNT(*)                                                          AS total_orders,
        SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)    AS cancelled_orders,
        ROUND(100.0 * SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)
              / COUNT(*), 2)                                             AS pct_cancelled
    FROM orders o
    JOIN restaurants r ON r.restaurant_id = o.restaurant_id
    GROUP BY r.restaurant_id, r.restaurant_name, r.city
    HAVING COUNT(*) >= 30
)
SELECT
    *,
    RANK() OVER (ORDER BY pct_cancelled DESC)                             AS cancellation_rank
FROM rest_cancel
ORDER BY pct_cancelled DESC
LIMIT 15;

-- 3.3  Restaurants with the best delivery performance
SELECT
    r.restaurant_id, r.restaurant_name, r.city,
    COUNT(*)                                                              AS delivered_orders,
    ROUND(AVG(d.actual_delivery_time_min), 1)                             AS avg_delivery_min,
    ROUND(100.0 * SUM(CASE WHEN d.actual_delivery_time_min <= d.estimated_delivery_time_min
             THEN 1 ELSE 0 END) / COUNT(*), 2)                           AS pct_on_time
FROM delivery d
JOIN orders o ON o.order_id = d.order_id
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city
HAVING COUNT(*) >= 20
ORDER BY pct_on_time DESC
LIMIT 15;


-- =====================================================================
-- SECTION 4: MANAGEMENT SCORECARD
-- "Where are we losing operational efficiency, and which restaurant/
--  customer patterns should we pay attention to?"

-- =====================================================================
 
WITH rest_stats AS (
    SELECT
        r.restaurant_id, r.restaurant_name, r.city, r.cuisine,
        COUNT(*)                                                          AS total_orders,
        SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)    AS cancelled_orders,
        SUM(o.order_amount)                                               AS total_revenue
    FROM orders o
    JOIN restaurants r ON r.restaurant_id = o.restaurant_id
    GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine
),
rest_delivery AS (
    SELECT
        o.restaurant_id,
        ROUND(100.0 * SUM(CASE WHEN d.actual_delivery_time_min > d.estimated_delivery_time_min
                 THEN 1 ELSE 0 END) / COUNT(*), 2)                       AS pct_late
    FROM delivery d
    JOIN orders o ON o.order_id = d.order_id
    GROUP BY o.restaurant_id
),
overall_avg AS (
    SELECT AVG(pct_late) AS avg_pct_late FROM rest_delivery
)
SELECT
    rs.restaurant_name, rs.city, rs.cuisine,
    rs.total_orders,
    ROUND(100.0 * rs.cancelled_orders / rs.total_orders, 2)               AS pct_cancelled,
    rd.pct_late,
    ROUND(rs.total_revenue, 2)                                            AS total_revenue,
    CASE
        WHEN rd.pct_late > oa.avg_pct_late * 1.3
             AND 100.0 * rs.cancelled_orders / rs.total_orders > 15       THEN 'High Risk'
        WHEN rd.pct_late > oa.avg_pct_late * 1.3
             OR 100.0 * rs.cancelled_orders / rs.total_orders > 15        THEN 'Watch'
        ELSE 'Healthy'
    END                                                                    AS risk_flag
FROM rest_stats rs
JOIN rest_delivery rd ON rd.restaurant_id = rs.restaurant_id
CROSS JOIN overall_avg oa
WHERE rs.total_orders >= 20
ORDER BY risk_flag, rd.pct_late DESC;

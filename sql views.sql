-- SQL Views 
-- SQL views are virtual tables created from the result of a SELECT query. They don't store data themselves but
-- provide a way to simplify complex queries, enhance security, and present data in a more organized manner.
-- What are SQL Views?
-- A view is essentially a saved query that appears as a table. When you query a view, the database engine 
-- executes the underlying SELECT statement and returns the results as if they came from a regular table.
Types of Views
Simple Views: Based on a single table with no complex operations

Can often be updated (INSERT, UPDATE, DELETE)
Straightforward column selections and basic WHERE clauses

Complex Views: Involve multiple tables, aggregations, or complex operations

Usually read-only
Include JOINs, GROUP BY, subqueries, or calculated fields

Benefits of Using Views
Views provide data abstraction by hiding complex query logic from end users. They enhance security through
column and row-level access control, showing only what users need to see. Views also promote code 
reusability since commonly used query patterns can be encapsulated and reused across applications.

Limitations
Views can introduce performance overhead since the underlying query executes each time the view is 
accessed. Many views are read-only, especially complex ones with aggregations or multiple table joins. 
Additionally, views create dependencies on underlying tables, so schema changes can break existing views.

Best Practices
Use descriptive names that clearly indicate the view's purpose. Keep views simple when possible to 
maintain performance and updateability. Document complex views thoroughly, and consider using materialized
views for frequently accessed, computationally expensive queries.

1. Data Security and Access Control
Imagine you have an employee table with sensitive information:

-- Original table with sensitive data
CREATE TABLE employees (
    emp_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    salary DECIMAL(10,2),
    ssn VARCHAR(11),
    department VARCHAR(50),
    hire_date DATE,
    performance_rating INT
);

-- Create a view for HR department (full access)
CREATE VIEW hr_employee_view AS
SELECT emp_id, name, email, salary, department, hire_date, performance_rating
FROM employees;

-- Create a view for general staff directory (limited access)
CREATE VIEW staff_directory AS
SELECT emp_id, name, email, department
FROM employees
WHERE department != 'Executive';
This way, different user groups see only what they're authorized to access.

2. Simplifying Complex Joins
Let's say you're running an e-commerce site with multiple related tables:

-- Instead of writing this complex query repeatedly:
SELECT 
    o.order_id,
    c.customer_name,
    c.email,
    p.product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) as line_total,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Create a view:
CREATE VIEW order_details AS
SELECT 
    o.order_id,
    c.customer_name,
    c.email,
    p.product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) as line_total,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Now anyone can simply query:
SELECT * FROM order_details WHERE order_date >= '2024-01-01';

3. Business Logic Encapsulation
Views can encapsulate business rules and calculations:

-- Customer classification based on purchase history
CREATE VIEW customer_segments AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    CASE 
        WHEN SUM(o.total_amount) >= 10000 THEN 'VIP'
        WHEN SUM(o.total_amount) >= 5000 THEN 'Gold'
        WHEN SUM(o.total_amount) >= 1000 THEN 'Silver'
        ELSE 'Bronze'
    END as customer_tier,
    AVG(o.total_amount) as avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.email;

4. Reporting and Analytics
Views are excellent for creating standardized reports

-- Monthly sales summary
CREATE VIEW monthly_sales_report AS
SELECT 
    YEAR(order_date) as year,
    MONTH(order_date) as month,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    MAX(total_amount) as largest_order
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date);

-- Product performance view
CREATE VIEW product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COUNT(oi.order_id) as times_ordered,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.price) as total_revenue,
    AVG(oi.price) as avg_selling_price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category;

5. Data Transformation and Formatting
Views can present data in different formats:
-- Format data for external API or reporting
CREATE VIEW customer_export_format AS
SELECT 
    customer_id as id,
    UPPER(customer_name) as name,
    email,
    CONCAT('+1-', phone) as formatted_phone,
    DATE_FORMAT(registration_date, '%Y-%m-%d') as reg_date,
    CASE 
        WHEN status = 'A' THEN 'Active'
        WHEN status = 'I' THEN 'Inactive'
        WHEN status = 'S' THEN 'Suspended'
    END as status_description
FROM customers;

6. Creating Mock Data Interfaces
During development, views can simulate complex data structures:
-- Simulate a dashboard summary without building complex logic in application
CREATE VIEW dashboard_summary AS
SELECT 
    (SELECT COUNT(*) FROM orders WHERE DATE(order_date) = CURDATE()) as today_orders,
    (SELECT COUNT(*) FROM customers WHERE DATE(registration_date) = CURDATE()) as new_customers_today,
    (SELECT SUM(total_amount) FROM orders WHERE MONTH(order_date) = MONTH(CURDATE())) as monthly_revenue,
    (SELECT COUNT(*) FROM products WHERE stock_quantity < 10) as low_stock_items;

Real-World Scenario: E-learning Platform
Let's build a complete example for an e-learning platform:
-- Student progress tracking view
CREATE VIEW student_progress AS
SELECT 
    s.student_id,
    s.student_name,
    s.email,
    c.course_name,
    COUNT(DISTINCT l.lesson_id) as total_lessons,
    COUNT(DISTINCT sp.lesson_id) as completed_lessons,
    ROUND((COUNT(DISTINCT sp.lesson_id) / COUNT(DISTINCT l.lesson_id)) * 100, 2) as completion_percentage,
    AVG(sp.score) as average_score,
    MAX(sp.completion_date) as last_activity
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN lessons l ON c.course_id = l.course_id
LEFT JOIN student_progress sp ON s.student_id = sp.student_id AND l.lesson_id = sp.lesson_id
GROUP BY s.student_id, s.student_name, s.email, c.course_name;


-- Type of views
While views are broadly categorised as simple or complex ,we  can also categorise them as:
LOOKUP VIEW(Primarily used to fetch statis or reference data.for example ,providing a list of country names and 
their estimared population GDP)
JOIN VIEW(Combines data from multiple tables into one dataset,useful for repreenting relationships between tables
 without requirong complex joins)
AGGREGATING VIEW(Used to display summarixzed or aggregated data.often involves GROUP BY clauses and aggregated 
functions like SUM,AVG ,COUNT etc.)


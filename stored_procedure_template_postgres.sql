--Postgres Examples

-- Create the procedure, in this example add_new_employee():
CREATE OR REPLACE PROCEDURE add_new_employee(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_department_id INT,
    p_salary NUMERIC
)
LANGUAGE plpgsql
AS $$ --PostgreSQL uses $$ to enclose the string body of the procedure so you don't have to escape single quotes inside your SQL code.
  BEGIN
      INSERT INTO employees (first_name, last_name, department_id, salary, hire_date)
      VALUES (p_first_name, p_last_name, p_department_id, p_salary, CURRENT_DATE);
  END;
$$;

-- Call the procedure add_new_employee() with args:
CALL add_new_employee('John', 'Doe', 4, 100000.00);

/* PostgreSQL procedures don't use a RETURN statement like functions do. 
Instead, if you want to pass a value back to the application, you use INOUT parameters. */

CREATE OR REPLACE PROCEDURE transfer_funds(
    sender_id INT,
    receiver_id INT,
    amount NUMERIC,
    INOUT new_sender_balance NUMERIC -- Returns this value back to the caller
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Deduct money from sender
    UPDATE accounts 
    SET balance = balance - amount 
    WHERE account_id = sender_id;

    -- Add money to receiver
    UPDATE accounts 
    SET balance = balance + amount 
    WHERE account_id = receiver_id;

    -- Retrieve the updated balance to return via the INOUT parameter
    SELECT balance INTO new_sender_balance 
    FROM accounts 
    WHERE account_id = sender_id;
END;
$$;

--Call the prodecure:
CALL transfer_funds(101, 102, 500.00, 0.00);

/* 
Advanced Example with Transaction Control
Because PostgreSQL procedures support transactions, you can bundle multiple operations together and manually commit them, or roll them back if an error occurs.
Scenario: Processing a batch of order payments. If a specific order is invalid, skip it without losing the work done on the valid orders.
*/
CREATE OR REPLACE PROCEDURE process_batch_orders()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    -- Loop through a temporary queue of pending orders
    FOR r IN SELECT order_id, total_amount FROM pending_orders LOOP
        BEGIN
            -- 1. Deduct inventory, update status, etc.
            UPDATE orders SET status = 'Processed' WHERE order_id = r.order_id;
            
            -- 2. Commit this specific order permanently to the DB
            COMMIT; 
            
        EXCEPTION WHEN OTHERS THEN
            -- If this single order fails, undo ONLY this order's changes
            RAISE NOTICE 'Failed to process order ID % due to an error.', r.order_id;
            ROLLBACK; 
        END;
    END LOOP;
END;
$$;

-- Calling the procedure:
CALL process_batch_orders();

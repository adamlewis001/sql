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

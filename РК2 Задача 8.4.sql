CREATE OR REPLACE FUNCTION update_stock3(
    product_id INT,
    operation VARCHAR,
    qty INT
)
RETURNS BOOLEAN -- Указываем возврат булевого значения для подтверждения успеха
LANGUAGE plpgsql
AS $$
DECLARE
    current_quantity INT;
BEGIN
    -- Получить текущее количество товара
    SELECT p.quantity INTO current_quantity 
    FROM products p
    WHERE p.id = product_id;

    -- Проверить, существует ли товар
    IF current_quantity IS NULL THEN
        RAISE EXCEPTION 'Товар не найден';
    END IF;

    -- Обработка операции ADD
    IF operation = 'ADD' THEN
        UPDATE products
        SET quantity = products.quantity + qty
        WHERE id = product_id;
		--SIGNAL SET MESSAGE_TEXT = 'Значение товара ' + product_id + 'было увеличено на ' + qty

    -- Обработка операции REMOVE
    ELSIF operation = 'REMOVE' THEN
        IF current_quantity < qty THEN
            RAISE EXCEPTION 'Недостаточно товара на складе';
        END IF;

        UPDATE products
        SET quantity = products.quantity - qty
        WHERE id = product_id;
		--SIGNAL SET MESSAGE_TEXT = 'Значение товара ' + product_id + 'было уменьшено на ' + qty

    ELSE
        RAISE EXCEPTION 'Неверный тип операции';
    END IF;

    -- Запись операции в журнал
    INSERT INTO operations_log (product_id, operation, quantity)
    VALUES (product_id, operation, qty);

    -- Успешное завершение
    RETURN TRUE;
END;
$$;
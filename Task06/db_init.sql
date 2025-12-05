PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS order_service;
DROP TABLE IF EXISTS "order";
DROP TABLE IF EXISTS appointment_service;
DROP TABLE IF EXISTS appointment;
DROP TABLE IF EXISTS employee_schedule;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS service;
DROP TABLE IF EXISTS employee;

CREATE TABLE employee (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    hire_date TEXT NOT NULL,
    dismissal_date TEXT,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    percent_rate REAL NOT NULL CHECK (percent_rate >= 0 AND percent_rate <= 1),
    note TEXT
);

CREATE TABLE client (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    note TEXT
);

CREATE TABLE car (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    plate_number TEXT NOT NULL,
    prod_year INTEGER,
    vin TEXT,
    note TEXT,
    FOREIGN KEY (client_id) REFERENCES client(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    UNIQUE (plate_number)
);

CREATE TABLE service (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    duration_min INTEGER NOT NULL CHECK (duration_min > 0),
    price REAL NOT NULL CHECK (price >= 0),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    note TEXT,
    UNIQUE (name)
);

CREATE TABLE employee_schedule (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    work_date TEXT NOT NULL,
    time_from TEXT NOT NULL,
    time_to TEXT NOT NULL,
    note TEXT,
    FOREIGN KEY (employee_id) REFERENCES employee(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE appointment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    car_id INTEGER,
    master_id INTEGER NOT NULL,
    start_datetime TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'cancelled', 'done')),
    note TEXT,
    FOREIGN KEY (client_id) REFERENCES client(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (car_id) REFERENCES car(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (master_id) REFERENCES employee(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE appointment_service (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    planned_price REAL NOT NULL CHECK (planned_price >= 0),
    planned_duration_min INTEGER NOT NULL CHECK (planned_duration_min > 0),
    FOREIGN KEY (appointment_id) REFERENCES appointment(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES service(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE "order" (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    car_id INTEGER,
    master_id INTEGER NOT NULL,
    appointment_id INTEGER,
    start_datetime TEXT NOT NULL,
    end_datetime TEXT,
    status TEXT NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'done', 'cancelled')),
    total_amount REAL NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    note TEXT,
    FOREIGN KEY (client_id) REFERENCES client(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (car_id) REFERENCES car(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (master_id) REFERENCES employee(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (appointment_id) REFERENCES appointment(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE order_service (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    master_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price REAL NOT NULL CHECK (price >= 0),
    duration_min INTEGER NOT NULL CHECK (duration_min > 0),
    discount_value REAL NOT NULL DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES "order"(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES service(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (master_id) REFERENCES employee(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_employee_active ON employee(is_active);
CREATE INDEX idx_employee_name ON employee(full_name);
CREATE INDEX idx_client_name ON client(full_name);
CREATE INDEX idx_car_client ON car(client_id);
CREATE INDEX idx_service_active ON service(is_active);
CREATE INDEX idx_schedule_employee_date ON employee_schedule(employee_id, work_date);
CREATE INDEX idx_appointment_master_dt ON appointment(master_id, start_datetime);
CREATE INDEX idx_order_master_dt ON "order"(master_id, start_datetime);
CREATE INDEX idx_order_service_master ON order_service(master_id);

INSERT INTO employee (full_name, phone, email, hire_date, dismissal_date, is_active, percent_rate, note) VALUES
    ('Иванов Иван Иванович', '+7-900-000-00-01', 'ivanov@example.com', '2022-01-10', NULL, 1, 0.30, 'Специалист по двигателям'),
    ('Петров Петр Петрович', '+7-900-000-00-02', 'petrov@example.com', '2021-05-15', NULL, 1, 0.25, 'Слесарь-универсал'),
    ('Сидоров Сергей Сергеевич', '+7-900-000-00-03', 'sidorov@example.com', '2020-03-01', '2024-02-01', 0, 0.28, 'Уволен, подвеска'),
    ('Кузнецов Константин', '+7-900-000-00-04', 'kuznetsov@example.com', '2019-09-20', '2023-12-31', 0, 0.32, 'Уволен, электрика');

INSERT INTO client (full_name, phone, email, note) VALUES
    ('ООО "АвтоТранс"', '+7-900-111-11-11', 'autotrans@example.com', 'Юрлицо, парк грузовиков'),
    ('ИП Смирнова Анна', '+7-900-222-22-22', 'smirnova@example.com', 'Регулярный клиент'),
    ('Иванов Иван', '+7-900-333-33-33', NULL, 'Частный клиент'),
    ('ПАО "ТехноСнаб"', '+7-900-444-44-44', 'texnosnab@example.com', 'Сервисный контракт');

INSERT INTO car (client_id, brand, model, plate_number, prod_year, vin, note) VALUES
    (1, 'MAN', 'TGX', 'А001AA777', 2018, 'WMA06XZZ8JP000001', 'Грузовой тягач'),
    (1, 'Mercedes', 'Actros', 'А002AA777', 2019, 'WDB9634031L000002', 'Грузовой тягач'),
    (2, 'Toyota', 'Camry', 'О123ОО199', 2020, 'JTNBF3HK803000003', 'Личный автомобиль'),
    (2, 'Kia', 'Rio', 'К456КК750', 2017, 'KNADC51DXH5000004', 'Личный автомобиль мужа'),
    (3, 'Lada', 'Vesta', 'М789ММ799', 2019, 'XTA218000K5000005', 'Частный клиент'),
    (4, 'GAZ', 'Gazelle', 'В321ВВ750', 2016, 'X9632043000000006', 'Служебный автомобиль');

INSERT INTO service (name, duration_min, price, is_active, note) VALUES
    ('Замена моторного масла', 60, 3000.00, 1, 'С заменой фильтра'),
    ('Диагностика ходовой части', 90, 4500.00, 1, 'Полная диагностика подвески'),
    ('Компьютерная диагностика', 45, 2500.00, 1, 'Считывание и расшифровка ошибок'),
    ('Замена тормозных колодок (ось)', 80, 4000.00, 1, 'Передняя или задняя ось'),
    ('Регулировка света фар', 30, 1500.00, 1, 'Легковой автомобиль'),
    ('Шиномонтаж (комплект)', 90, 5000.00, 1, 'Переобувка 4 колес');

INSERT INTO employee_schedule (employee_id, work_date, time_from, time_to, note) VALUES
    (1, '2024-03-01', '09:00', '18:00', 'Обычный день'),
    (1, '2024-03-02', '09:00', '18:00', 'Обычный день'),
    (2, '2024-03-01', '10:00', '19:00', 'Смещение графика'),
    (2, '2024-03-03', '10:00', '19:00', 'Выходной за переработку'),
    (3, '2024-01-15', '09:00', '18:00', 'Перед увольнением'),
    (4, '2023-12-20', '09:00', '18:00', 'Последняя смена');

INSERT INTO appointment (client_id, car_id, master_id, start_datetime, status, note) VALUES
    (2, 3, 1, '2024-03-01 10:00', 'done', 'Плановая замена масла и диагностика'),
    (1, 1, 2, '2024-03-01 11:30', 'done', 'Диагностика и возможный ремонт ходовой'),
    (3, 5, 1, '2024-03-02 09:30', 'cancelled', 'Клиент не смог приехать'),
    (4, 6, 2, '2024-03-03 14:00', 'planned', 'Подготовка к техосмотру');

INSERT INTO appointment_service (appointment_id, service_id, quantity, planned_price, planned_duration_min) VALUES
    (1, 1, 1, 3000.00, 60),
    (1, 3, 1, 2500.00, 45),
    (2, 2, 1, 4500.00, 90),
    (3, 4, 1, 4000.00, 80),
    (4, 5, 1, 1500.00, 30);

INSERT INTO "order" (client_id, car_id, master_id, appointment_id, start_datetime, end_datetime, status, total_amount, note) VALUES
    (2, 3, 1, 1, '2024-03-01 10:05', '2024-03-01 11:20', 'done', 5500.00, 'Все по плану'),
    (1, 1, 2, 2, '2024-03-01 11:40', '2024-03-01 13:30', 'done', 9000.00, 'Дополнительно заменили колодки'),
    (3, 5, 1, NULL, '2024-03-02 10:15', '2024-03-02 11:00', 'done', 1500.00, 'Регулировка света фар'),
    (4, 6, 2, 4, '2024-03-03 14:05', NULL, 'in_progress', 0.00, 'Работы ведутся');

INSERT INTO order_service (order_id, service_id, master_id, quantity, price, duration_min, discount_value) VALUES
    (1, 1, 1, 1, 3000.00, 60, 0.00),
    (1, 3, 1, 1, 2500.00, 45, 0.00),
    (2, 2, 2, 1, 4500.00, 90, 0.00),
    (2, 4, 3, 1, 4500.00, 80, 0.00),
    (3, 5, 1, 1, 1500.00, 30, 200.00),
    (4, 3, 2, 1, 2500.00, 45, 0.00);

COMMIT;
PRAGMA foreign_keys = ON;
-- ЗАДАНИЕ №1
CREATE DATABASE BicycleRental;
GO

USE BicycleRental;
GO
-- 1. Создание таблиц
create table [Bicycle]
(
   [Id] int IDENTITY(1,1) not null,
   [Brand] varchar(50)  not null,
   [RentPrice] int not null, -- цена аренды
   primary key(Id)
)

create table [Client]
(
   [Id] int IDENTITY(1,1) not null,
   [Name] varchar(10) not null,
   [Passport] varchar(50) not null,
   [Phone number] varchar(50) not null,
   [Country] varchar(50) not null,
   primary key(Id)
)

create table [Staff]
(
   [Id] int IDENTITY(1,1) not null,
   [Name] varchar(10) not null, -- имя сотрудника
   [Passport] varchar(50) not null,
   [Date] date not null, -- дата начала работы
   primary key(Id)
)

create table [Detail] -- запчасти велосипеда
(
   [Id] int IDENTITY(1,1) not null,
   [Brand] varchar(50)  not null,
   [Type] varchar(50) not null, -- тип детали (цепь, звезда, etc.)
   [Name] varchar(50) not null, -- название детали
   [Price] int not null,
   primary key(Id) 

)
create table [DetailForBicycle] -- список деталей подходящих к велосипедам
(
   [BicycleId] int not null,
   [DetailId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
)
create table [ServiceBook] -- сервисное обслуживание велосипедов
(
   [BicycleId] int not null,
   [DetailId] int not null,
   [Date] date not null,
   [Price] int not null, -- цена работы
   [StaffId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
)
create table [RentBook] -- аренда велосипеда клиентом
(
   [Id] int IDENTITY(1,1) not null,
   [Date] date not null, -- дата аренды
   [Time] int not null, -- время аренды в часах
   [Paid] bit not null, -- 1 оплатил; 0 не оплатил 
   [BicycleId] int not null,
   [ClientId] int not null,
   [StaffId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([ClientId]) REFERENCES [Client] ([Id])
) 
-- 2. Улучшения таблиц  
-- Улучшения таблицы Client
-- Увеличиваем поле Name с 10 до 50 символов для полных имен
ALTER TABLE [Client] ALTER COLUMN [Name] varchar(50) not null;

-- Добавляем поле email для связи с клиентами
ALTER TABLE [Client] ADD [Email] varchar(100) NULL;

-- Проверяем формат номера телефона
ALTER TABLE [Client] ADD CONSTRAINT CHK_Client_Phone CHECK ([Phone number] LIKE '+%');
GO

-- Улучшения таблицы Staff
-- Переименовываем Date в StartDate для ясности
EXEC sp_rename 'Staff.Date', 'StartDate', 'COLUMN';

-- Увеличиваем поле Name для ФИО сотрудников
ALTER TABLE [Staff] ALTER COLUMN [Name] varchar(50) not null;
GO

-- Улучшения таблицы Bicycle
-- Добавляем статус активности велосипеда
ALTER TABLE [Bicycle] ADD [IsActive] bit NOT NULL DEFAULT 1;

-- Проверяем что цена аренды положительная
ALTER TABLE [Bicycle] ADD CONSTRAINT CHK_RentPrice_Positive CHECK ([RentPrice] > 0);
GO

-- Улучшения таблицы RentBook
-- Время аренды должно быть больше 0
ALTER TABLE [RentBook] ADD CONSTRAINT CHK_RentTime_Positive CHECK ([Time] > 0);

-- Индекс для поиска по дате аренды
CREATE INDEX IX_RentBook_Date ON [RentBook] ([Date]);

-- Индекс для связей с клиентами
CREATE INDEX IX_RentBook_ClientId ON [RentBook] ([ClientId]);
GO

-- Улучшения таблицы ServiceBook
-- Индекс для фильтрации по дате сервиса
CREATE INDEX IX_ServiceBook_Date ON [ServiceBook] ([Date]);
GO
-- Вставка тестовых данных в таблицу Bicycle
INSERT INTO [Bicycle] ([Brand], [RentPrice], [IsActive])
VALUES 
('Trek', 200, 1),
('Giant', 150, 1),
('Specialized', 250, 1),
('Cube', 180, 1),
('Scott', 220, 1);
GO
-- Смотрим добавленные велосипеды
SELECT * FROM [Bicycle];
GO
-- Добавляем сотрудников
INSERT INTO [Staff] ([Name], [Passport], [StartDate])
VALUES
('Алексей', 'MN123789', '2020-01-15'),
('Екатерина', 'OP456123', '2021-03-20'),
('Дмитрий', 'QR789456', '2022-11-10');
GO

SELECT * FROM Staff; -- Проверяем
GO

-- Добавляем клиентов
INSERT INTO [Client] ([Name], [Passport], [Phone number], [Country], [Email])
VALUES
('Иван Петров', 'AB123456', '+79161234567', 'Россия', 'ivan@mail.ru'),
('Мария Сидорова', 'CD654321', '+79167654321', 'Россия', 'maria@yandex.ru');
GO

SELECT * FROM Client; -- Проверяем
GO
-- Добавляем запчасти для велосипедов
INSERT INTO [Detail] ([Brand], [Type], [Name], [Price])
VALUES
('Shimano', 'Цепь', 'CN-HG601', 1200),
('Shimano', 'Тормозные колодки', 'BR-M575', 800),
('SRAM', 'Кассета', 'PG-1130', 2500),
('Continental', 'Покрышка', 'Grand Prix 5000', 1800);
GO

SELECT * FROM Detail; -- Проверяем
GO
-- Указываем какие детали подходят к каким велосипедам
INSERT INTO [DetailForBicycle] ([BicycleId], [DetailId])
VALUES
(1, 1), (1, 2), (1, 4),  -- Trek подходят детали 1,2,4
(2, 1), (2, 3),           -- Giant подходят детали 1,3
(3, 2), (3, 4);           -- Specialized подходят детали 2,4
GO

SELECT * FROM DetailForBicycle; -- Проверяем
GO
-- Добавляем записи о ремонте велосипедов
INSERT INTO [ServiceBook] ([BicycleId], [DetailId], [Date], [Price], [StaffId])
VALUES
(1, 1, '2024-01-15', 500, 1),   -- Алексей поменял цепь на Trek
(2, 3, '2024-01-20', 700, 2),   -- Екатерина поменяла кассету на Giant
(3, 4, '2024-02-01', 400, 1);   -- Алексей поменял покрышку на Specialized
GO

SELECT * FROM ServiceBook; -- Проверяем
GO
-- Добавляем записи об аренде
INSERT INTO [RentBook] ([Date], [Time], [Paid], [BicycleId], [ClientId], [StaffId])
VALUES
('2024-01-10', 3, 1, 1, 1, 1),   -- Иван арендовал Trek на 3 часа (оплатил)
('2024-01-12', 5, 1, 2, 2, 2),   -- Мария арендовала Giant на 5 часов (оплатила)
('2024-01-15', 2, 0, 3, 1, 1);   -- Иван арендовал Specialized на 2 часа (не оплатил)
GO

SELECT * FROM RentBook; -- Проверяем
GO
-- Общая проверка всех таблиц
SELECT 'Bicycle' as TableName, COUNT(*) as RecordCount FROM Bicycle
UNION ALL
SELECT 'Client', COUNT(*) FROM Client
UNION ALL  
SELECT 'Staff', COUNT(*) FROM Staff
UNION ALL
SELECT 'Detail', COUNT(*) FROM Detail
UNION ALL
SELECT 'DetailForBicycle', COUNT(*) FROM DetailForBicycle
UNION ALL
SELECT 'ServiceBook', COUNT(*) FROM ServiceBook
UNION ALL
SELECT 'RentBook', COUNT(*) FROM RentBook;
GO
-- 3. Аналитические запросы
-- 1. Статистика по велосипедам: аренды, доход, обслуживание
SELECT 
    b.Id,
    b.Brand,
    COUNT(rb.Id) AS TotalRents,
    SUM(CASE WHEN rb.Paid = 1 THEN rb.Time ELSE 0 END) AS PaidHours,
    SUM(CASE WHEN rb.Paid = 1 THEN b.RentPrice * rb.Time ELSE 0 END) AS TotalRevenue,
    (SELECT COUNT(*) FROM ServiceBook WHERE BicycleId = b.Id) AS ServiceCount
FROM Bicycle b
LEFT JOIN RentBook rb ON b.Id = rb.BicycleId
WHERE b.IsActive = 1
GROUP BY b.Id, b.Brand
ORDER BY TotalRevenue DESC;
GO

-- 2. Сотрудники: количество операций и доход
SELECT 
    s.Id,
    s.Name,
    (SELECT COUNT(*) FROM RentBook WHERE StaffId = s.Id) AS ProcessedRents,
    (SELECT COUNT(*) FROM ServiceBook WHERE StaffId = s.Id) AS CompletedServices,
    ISNULL((
        SELECT SUM(b.RentPrice * rb.Time) 
        FROM RentBook rb 
        JOIN Bicycle b ON rb.BicycleId = b.Id 
        WHERE rb.StaffId = s.Id AND rb.Paid = 1
    ), 0) AS RentRevenue
FROM Staff s
ORDER BY RentRevenue DESC;
GO

-- 3. Клиенты: активность и платежи
SELECT 
    c.Name,
    c.Country,
    COUNT(rb.Id) AS TotalRents,
    SUM(rb.Time) AS TotalHours,
    SUM(CASE WHEN rb.Paid = 1 THEN b.RentPrice * rb.Time ELSE 0 END) AS TotalPaid,
    CAST(SUM(CASE WHEN rb.Paid = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(rb.Id) AS DECIMAL(5,1)) AS PaymentRate
FROM Client c
JOIN RentBook rb ON c.Id = rb.ClientId
JOIN Bicycle b ON rb.BicycleId = b.Id
GROUP BY c.Id, c.Name, c.Country
ORDER BY TotalPaid DESC;
GO

-- 4. Сервис: статистика по деталям
SELECT 
    d.Type,
    d.Name,
    COUNT(sb.DetailId) AS TimesUsed,
    SUM(sb.Price) AS TotalServiceCost,
    AVG(sb.Price) AS AvgServicePrice
FROM Detail d
JOIN ServiceBook sb ON d.Id = sb.DetailId
GROUP BY d.Type, d.Name
ORDER BY TimesUsed DESC;
GO

-- 5. Динамика бизнеса по месяцам
SELECT 
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    COUNT(*) AS TotalRents,
    SUM(Time) AS TotalHours,
    SUM(CASE WHEN Paid = 1 THEN Time * (SELECT RentPrice FROM Bicycle WHERE Id = BicycleId) ELSE 0 END) AS MonthlyRevenue,
    COUNT(DISTINCT ClientId) AS UniqueClients
FROM RentBook
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year DESC, Month DESC;
GO
-- ЗАДАНИЕ №2
-- Создаем витрину данных для премий
CREATE TABLE StaffBonusMart
(
    Id int IDENTITY(1,1) PRIMARY KEY,
    Year int NOT NULL,
    Month int NOT NULL,
    StaffId int NOT NULL,
    StaffName varchar(50) NOT NULL,
    ExperienceBonusPercent decimal(5,2) NOT NULL,
    TotalRentRevenue decimal(10,2) NOT NULL,
    TotalServiceRevenue decimal(10,2) NOT NULL,
    BonusAmount decimal(10,2) NOT NULL,
    
    CONSTRAINT FK_StaffBonusMart_Staff FOREIGN KEY (StaffId) REFERENCES Staff(Id),
    CONSTRAINT CHK_StaffBonusMart_Month CHECK (Month BETWEEN 1 AND 12)
);
GO

CREATE INDEX IX_StaffBonusMart_Period ON StaffBonusMart (Year, Month);
CREATE INDEX IX_StaffBonusMart_Staff ON StaffBonusMart (StaffId);
GO

CREATE VIEW vw_StaffBonus AS
SELECT 
    Year,
    Month,
    StaffId,
    StaffName,
    ExperienceBonusPercent,
    TotalRentRevenue,
    TotalServiceRevenue,
    BonusAmount
FROM StaffBonusMart;
GO

-- Проверяем что таблица создалась
SELECT * FROM StaffBonusMart;
GO

CREATE PROCEDURE LoadStaffBonusMart
    @Year int = NULL,
    @Month int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year IS NULL 
        SET @Year = YEAR(GETDATE());
    IF @Month IS NULL 
        SET @Month = MONTH(GETDATE());

    DELETE FROM StaffBonusMart 
    WHERE Year = @Year AND Month = @Month;

    INSERT INTO StaffBonusMart (Year, Month, StaffId, StaffName, ExperienceBonusPercent,
                              TotalRentRevenue, TotalServiceRevenue, BonusAmount)
    SELECT 
        @Year,
        @Month,
        s.Id,
        s.Name,
        CASE 
            WHEN DATEDIFF(MONTH, s.StartDate, GETDATE()) < 12 THEN 5.0
            WHEN DATEDIFF(MONTH, s.StartDate, GETDATE()) < 24 THEN 10.0
            ELSE 15.0
        END,
        ISNULL((
            SELECT SUM(b.RentPrice * rb.Time)
            FROM RentBook rb
            JOIN Bicycle b ON rb.BicycleId = b.Id
            WHERE rb.StaffId = s.Id 
                AND YEAR(rb.Date) = @Year 
                AND MONTH(rb.Date) = @Month
                AND rb.Paid = 1
        ), 0),
        ISNULL((
            SELECT SUM(Price)
            FROM ServiceBook 
            WHERE StaffId = s.Id 
                AND YEAR(Date) = @Year 
                AND MONTH(Date) = @Month
        ), 0),
        (ISNULL((
            SELECT SUM(b.RentPrice * rb.Time) * 0.3
            FROM RentBook rb
            JOIN Bicycle b ON rb.BicycleId = b.Id
            WHERE rb.StaffId = s.Id 
                AND YEAR(rb.Date) = @Year 
                AND MONTH(rb.Date) = @Month
                AND rb.Paid = 1
        ), 0) + ISNULL((
            SELECT SUM(Price) * 0.8
            FROM ServiceBook 
            WHERE StaffId = s.Id 
                AND YEAR(Date) = @Year 
                AND MONTH(Date) = @Month
        ), 0)) * 
        CASE 
            WHEN DATEDIFF(MONTH, s.StartDate, GETDATE()) < 12 THEN 0.05
            WHEN DATEDIFF(MONTH, s.StartDate, GETDATE()) < 24 THEN 0.10
            ELSE 0.15
        END
    FROM Staff s
    WHERE s.Id IN (
        SELECT StaffId FROM RentBook 
        WHERE YEAR(Date) = @Year AND MONTH(Date) = @Month
        UNION
        SELECT StaffId FROM ServiceBook 
        WHERE YEAR(Date) = @Year AND MONTH(Date) = @Month
    );

END;
GO

-- Тестируем процедуру для января 2024
EXEC LoadStaffBonusMart @Year = 2024, @Month = 1;
GO

-- Смотрим результаты в витрине
SELECT * FROM StaffBonusMart ORDER BY BonusAmount DESC;
GO
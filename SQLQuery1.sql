USE [dashboardlink]
GO
/****** Object:  StoredProcedure [dbo].[RemainedTarget]    Script Date: 2/26/2024 2:13:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[RemainedTarget]
as 
Begin 
with a as (select 
YearMonth
,DateInvoice
,sum(cast(quantity as float)) as quantity
,Zone
,Brand
,Category
from openquery([DASH],'select * from data_37')
group by YearMonth,Zone,DateInvoice,Brand,Category)
, b as(select 
DateInvoice
,YearMonth
,SUM(case when Zone in (N'Center~Offline',N'Center~Online',N'East',N'South',N'West / B2B') then quantity else 0 end) AS total
,sum(case when Zone = N'B2C' then quantity else 0 end) as 'B2C'
,sum(case when Zone = N'Center~Offline' then quantity else 0 end) as 'Center~Offline'
,sum(case when Zone = N'Center~Online' then quantity else 0 end) as 'Center~Online'
,sum(case when Zone = N'Credit Sales' then quantity else 0 end) as 'Credit Sales'
,sum(case when Zone = N'East' then quantity else 0 end) as 'East'
,sum(case when Zone = N'South' then quantity else 0 end) as 'South'
,sum(case when Zone = N'West / B2B' then quantity else 0 end) as 'West / B2B'
,sum(case when Zone = N'Other' then quantity else 0 end) as 'Other'
from a
where Category ='Mobile' and Brand = 'HONOR'
group by DateInvoice,YearMonth)
,m as (
SELECT [GregorianDateShort]
,[GregorianDate]
,[GregorianYear]
,[GregorianMonth]
,[GregorianMonthName]
,left([GregorianDate] ,7) as 'GregorianYearMonth'
,[ThisYear]
,[ThisMonth]
,[ThisDay]
,[UntilToday]
,[Holiday]
,case when [Holiday] = 0 then 1 else 0 end as 'WorkingDay'
,[MediaWeek]
FROM [media].[dbo].[mDate]
where [GregorianYear] in (2024) 
), 
w as (select sum(WorkingDay) as 'WorkingDay',GregorianDate
from m
group by GregorianDate)
, p as
(select *
from [media].[dbo].[Daily_Target])
, s as (
SELECT 
        ROW_NUMBER() OVER (ORDER BY m.GregorianDate) AS RowNum,
        m.GregorianDate,
        m.GregorianYear,
        m.GregorianYearMonth,
        m.GregorianMonth,
        m.GregorianMonthName,
        m.Holiday,
        m.WorkingDay,
        m.UntilToday,
        ISNULL(m.MediaWeek, 0) AS MediaWeek,
        ISNULL(p.DailyCenterOnline, 0) AS [Target-CenterOnline],
        ISNULL(b.[Center~Online], 0) AS [Achieved-CenterOnline],
        ISNULL(p.DailyCenterOffline, 0) AS [Target-CenterOffline],
        ISNULL(b.[Center~Offline], 0) AS [Achieved-Centeroffline],
        ISNULL(p.DailySouth, 0) AS [Target-South],
        ISNULL(b.South, 0) AS [Achieved-South],
        ISNULL(p.DailyWest, 0) AS [Target-West],
        ISNULL(b.[West / B2B], 0) AS [Achieved-West],
        ISNULL(p.DailyEast, 0) AS [Target-East],
        ISNULL(b.East, 0) AS [Achieved-East],
        m.ThisDay,
        ISNULL(b.total, 0) AS total
    FROM 
        m
    LEFT JOIN 
        b ON b.DateInvoice COLLATE DATABASE_DEFAULT = m.GregorianDate
    LEFT JOIN 
        p ON p.GregorianDate COLLATE DATABASE_DEFAULT = m.GregorianDate
    WHERE  
       m.GregorianDate >= '2024/02/20' )
select 
* 
,SUM(ISNULL([Achieved-CenterOnline], 0))OVER (ORDER BY RowNum) AS [Total-CenterOnline]
,SUM(ISNULL([Achieved-Centeroffline], 0))OVER (ORDER BY RowNum) AS [Total-CenterOffline]
,SUM(ISNULL([Achieved-South], 0))OVER (ORDER BY RowNum) AS [Total-South]
,SUM(ISNULL([Achieved-West], 0))OVER (ORDER BY RowNum) AS [Total-West]
,SUM(ISNULL([Achieved-East], 0))OVER (ORDER BY RowNum) AS [Total-East]
,ISNULL([Target-CenterOnline], 0) - SUM(ISNULL([Achieved-CenterOnline], 0)) OVER (ORDER BY RowNum) AS [CenterOnline_remaining]
,ISNULL([Target-CenterOffline], 0) - SUM(ISNULL([Achieved-Centeroffline], 0)) OVER (ORDER BY RowNum) AS [CenterOffline_remaining] 
,ISNULL([Target-South], 0) - SUM(ISNULL([Achieved-South], 0)) OVER (ORDER BY RowNum) AS [South_remaining]
,ISNULL([Target-West], 0) -SUM( ISNULL([Achieved-West], 0)) OVER (ORDER BY RowNum) AS [West_remaining]
,ISNULL([Target-East], 0) - SUM(ISNULL([Achieved-East], 0)) OVER (ORDER BY RowNum) AS [East_remaining]
from s  
end
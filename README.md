# DailyTarget
let's break down the SQL code step by step to understand what it does:

    Common Table Expressions (CTEs):
        The SQL script defines several CTEs (a, b, m, w, p, s) using the WITH clause.
        Each CTE prepares or aggregates data from different tables or sources.

    CTE a:
        It aggregates data from an external source [DASH] by selecting columns YearMonth, DateInvoice, quantity, Zone, Brand, and Category from the table data_37.
        The data is grouped by YearMonth, Zone, DateInvoice, Brand, and Category, and the quantity column is summed up.

    CTE b:
        It further aggregates data from CTE based on specific conditions such as Brand being 'HONOR' and Category being 'Mobile'.
        It calculates various sums based on the Zone column values.

    CTE m:
        It retrieves data from the [media].[dbo].[mDate] table, selecting various date-related columns and applying some transformations.
        The data is filtered based on the GregorianYear being 2024.

    CTE w:
        It aggregates working days from CTE m by summing up the WorkingDay column, grouped by GregorianDate.

    CTE p:
        It retrieves daily targets from the [media].[dbo].[Daily_Target] table.

    CTE s:
        It joins CTEs m, b, and p to calculate achieved and target values.
        It includes various columns from CTE m, and achieved and target values from CTEs b and p.
        The data is filtered based on the GregorianDate being greater than or equal to '2024/02/20'.

    Final Query:
        The final SELECT statement selects all columns from CTE s.
        It calculates additional columns such as cumulative totals and remaining targets using window functions (SUM() over the RowNum column).
        The results are presented as the final output.

In summary, the SQL code prepares and aggregates data from multiple sources, calculates achieved and target values, and presents the results with additional calculations for tracking progress and remaining targets.


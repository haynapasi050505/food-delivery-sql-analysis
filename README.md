# 🍔 Food Delivery Operations & Customer Behavior Analysis

End-to-end data analysis project: **SQL** for data cleaning and analysis, **Excel** for the final interactive dashboard.



---

## 📌 Project Overview

A food delivery platform needs to understand how reliable its deliveries are, where orders are being lost, when demand peaks, and how loyal its customers are.

This project answers those questions by cleaning and analysing the delivery database in SQL, then presenting the results as a one-page Excel dashboard of KPIs, pivot tables and charts.

## 🎯 Business Questions

1. What share of deliveries are on time vs. late, and is it improving?
2. Which restaurants cause the most late deliveries and cancellations?
3. What are the peak demand hours and days?
4. How loyal are customers, and how often do they reorder?

## 🛠️ Tools & Skills

| Area | Details |
|---|---|
| Data cleaning & analysis | SQL (JOINs, CTEs, window functions, aggregations) |
| Dashboarding | Excel (Pivot Tables, Pivot Charts, KPI cards) |
| Data | Orders, Customers, Restaurants, Delivery tables |

## 🔄 Workflow

1. **Clean and prepare** the data in SQL (nulls, duplicates, data types, derived fields such as delivery status and order hour).
2. **Analyse** with ~20 SQL queries, one per business question.
3. **Export** each query result to its own Excel sheet.
4. **Build pivot tables and charts** from those sheets.
5. **Combine** everything into a single dashboard with a KPI row.

## 📊 Dashboard Contents

- **KPI row:** Delivered Orders, On-Time Orders, On-Time %, Late %, Repeat Customers %, Avg Days Between Orders
- **On-Time vs Late Deliveries** (donut chart)
- **On-Time % by Month** (trend line)
- **Late % by Restaurant**
- **Cancellation % by Restaurant**
- **Hourly Order Distribution** (peak demand windows)
- **Daily Order Volume Distribution** (day of week)

## 🔍 Key Findings

### KPIs

| Metric | Value |
|---|---|
| Delivered orders | 7,402 |
| On-time orders | 5,453 |
| On-time delivery % | **73.67%** |
| Late delivery % | **26.33%** |
| Repeat customers % | **58.00%** |
| Avg days between orders | **34.3** |

### Insights

1. **About 1 in 4 deliveries is late.** On-time % has stayed flat at roughly 70–80% since the first month, so this is a structural issue rather than a seasonal one.
2. **Lateness is concentrated in specific restaurants.** Late % ranges from near 0% to 85%+. A few restaurants account for a large share of late deliveries, while many are under 20%.
3. **Cancellations are concentrated in five restaurants.** Dave Fast Kitchen (~45.8%), Kapoor Chinese Kitchen (~45.1%), Lali Mexican House (~41.1%), Choudhury Continental Bistro (~38.9%) and Chaudhry Fast Kitchen (~31.4%) cancel at 2–3 times the rate of the rest (~13–20%).
4. **Demand is driven by time of day, not day of week.** There is a lunch peak around 12–13h (~800 orders) and a larger dinner peak around 19–20h (~950 orders). Daily volume is nearly flat, from ~1,223 (Monday) to ~1,300 (Saturday).
5. **Retention is good, but frequency is low.** 58% of customers are repeat customers, yet the average gap between orders is 34 days.

## 💡 Recommendations

- **Audit the worst restaurants** for late deliveries and cancellations. Identify the root cause (prep time, rider assignment or stock-outs) and apply penalties or delisting where needed.
- **Add rider capacity and incentives** during the lunch (12–14h) and dinner (19–21h) windows.
- **Run frequency campaigns** (reminders, loyalty rewards, subscriptions) to shorten the 34-day reorder gap.
- **Use offers in quiet slots** (early mornings, Mondays) to even out demand.

## 📁 Repository Structure

```
├── README.md
├── sql/
│   ├── data_cleaning.sql
│   └── analysis_queries.sql
├── excel/
│   └── food_delivery_dashboard.xlsx
└── images/
    └── dashboard.png
```

## ▶️ How to Use

1. Run the scripts in `sql/` on the food delivery database to reproduce the cleaned data and query results.
2. Open `excel/food_delivery_dashboard.xlsx` to explore the dashboard. Each sheet holds one query result, and the dashboard sheet combines the charts.

## 👩‍💻 Author

**Neha**, Data Analyst
[LinkedIn](https://linkedin.com/in/neha-pasi) · [GitHub](https://github.com/haynapasi050505)

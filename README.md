# Telecom Customer Database Management System

A COMPLETE industry-style full-stack project suitable for 3rd year ECE (Telecommunication specialization) students preparing for Cognizant, TCS, Infosys, Accenture, Capgemini, and campus placements.

---

## 1. Project Overview
The **Telecom Customer Database Management System** is a robust, web-based platform simulating a real-world telecommunication operator's internal dashboard (similar to Jio, Airtel, or Vi). It enables network administrators to efficiently manage customers, SIM cards, recharge plans, billing, and network towers.

## 2. Objectives
- To digitize and streamline telecom customer management.
- To provide a centralized platform for monitoring network towers and regions.
- To manage prepaid and postpaid billing operations seamlessly.
- To demonstrate advanced database management and full-stack web development skills.

## 3. Scope
The system covers the operational aspects of a telecom provider, focusing on the administrative side. It handles CRUD (Create, Read, Update, Delete) operations for customers and SIM cards, tracks recharge history and data usage, and monitors tower statuses across different regions.

## 4. Features List
- **Authentication**: Secure admin login and session management.
- **Customer Management**: View and manage customer profiles, active/inactive statuses.
- **SIM Card Management**: Track prepaid/postpaid and 4G/5G SIM allocations.
- **Billing & Payments**: Generate and view postpaid bills with GST calculations.
- **Network Monitoring**: Region-wise tower status tracking (Active, Maintenance, Down).
- **Dashboard Analytics**: Visual representation of revenue and user distribution using Chart.js.

## 5. ER Diagram Explanation
The database follows a normalized relational structure:
- **Customers** have a one-to-many relationship with **SIM Cards**.
- **Regions** have a one-to-many relationship with **Towers**.
- **SIM Cards** link to **Recharges**, **Call Records**, **Data Usage**, and **Bills** (One-to-Many).
- **Bills** link to **Payments** (One-to-One / One-to-Many).
*Refer to the `database.sql` for the exact schema, constraints, and foreign keys.*

## 6. Database Schema
Key Tables: `admins`, `regions`, `towers`, `customers`, `sim_cards`, `recharge_plans`, `recharges`, `call_records`, `data_usage`, `bills`, `payments`. 
*Features robust foreign key constraints (`ON DELETE CASCADE`, `ON DELETE SET NULL`) ensuring referential integrity.*

## 7. Full SQL Code
The complete database generation script, including table creations, sample data insertion, complex views, stored procedures, and triggers, is provided in `database.sql`.

## 8. Backend Flask Code
Developed using Python and Flask. Handles routing, MySQL database connections using `PyMySQL`, session management, and rendering Jinja2 templates. Located in `app.py`.

## 9. Frontend HTML/CSS/JS Code
Built using HTML5, CSS3, and Bootstrap 5. It features a responsive sidebar layout, dynamic data rendering, and Chart.js integration. Files are located in the `templates/` and `static/` folders.

## 10. API Documentation
- `GET /login`: Renders login page.
- `POST /login`: Authenticates admin credentials.
- `GET /logout`: Clears session.
- `GET /dashboard`: Fetches aggregate metrics and renders dashboard.
- `GET /customers`: Fetches customer details via SQL View and renders the table.
- `GET /towers`: Fetches tower and region data.
- `GET /billing`: Fetches postpaid bills.

## 11. Folder Structure
```text
telecom-management-system/
│
├── app.py
├── database.sql
├── requirements.txt
├── README.md
├── static/
│   ├── css/
│   │   └── style.css
├── templates/
│   ├── base.html
│   ├── login.html
│   ├── dashboard.html
│   ├── customers.html
│   ├── towers.html
│   └── billing.html
```

## 12. Installation & Setup Guide
1. **Clone the repository:**
   ```bash
   git clone https://github.com/monishav24/sql-project.git
   cd sql-project
   ```
2. **Database Setup:**
   - Open MySQL Workbench / XAMPP.
   - Import and execute `database.sql` to create the schema and insert sample data.
3. **Backend Setup:**
   - Create a virtual environment: `python -m venv venv`
   - Activate it: `venv\Scripts\activate` (Windows)
   - Install dependencies: `pip install -r requirements.txt`
   - Update your MySQL password in `app.py` (`DB_PASSWORD`).
4. **Run the App:**
   - `python app.py`
   - Open `http://localhost:5000` in your browser. (Demo Login: `admin` / `admin123`)

## 13. requirements.txt
Contains required Python packages: `Flask`, `PyMySQL`, `Werkzeug`, etc.

## 14. Mini Project Report
**(Abstract):** The Telecom Customer Database Management System aims to automate the operational workflows of a telecommunication company. By utilizing Python Flask and MySQL, the system achieves a normalized database structure capable of handling complex queries, transactions, and real-time network monitoring.

## 15. System Architecture
Client (Browser) -> Frontend (HTML/Bootstrap) -> Backend (Flask/Python) -> Database (MySQL).
Follows a standard Monolithic MVC (Model-View-Controller) architecture pattern.

## 16. Module Explanations
- **Auth Module**: Secures the platform restricting unauthorized access.
- **Customer Module**: Aggregates data from `customers` and `sim_cards` tables using Views.
- **Tower Module**: Monitors infrastructure health using JOIN operations.

## 17. Conclusion
This project successfully demonstrates the integration of a relational database with a modern web frontend. It highlights practical database concepts like normalization, triggers, stored procedures, and views, making it an excellent showcase of enterprise-level CRUD operations.

## 18. Future Enhancements
- Integration of a payment gateway (e.g., Razorpay/Stripe).
- Real-time tower pinging using IoT sensors.
- Customer self-service portal.
- Exporting reports to PDF/Excel.

## 19. Viva Questions with Answers
**Q: What is normalization and how did you use it?**
A: Normalization reduces data redundancy. I split data into `customers` and `sim_cards` so a user can have multiple SIMs without repeating personal details.

**Q: Explain the use of Triggers in your project.**
A: I used a trigger `AfterSimDeactivation` to automatically change a customer's status to 'Inactive' if all their associated SIM cards are deactivated.

**Q: Why Flask over Django?**
A: Flask is a micro-framework that is lightweight and perfect for understanding core routing and database integration without heavy boilerplate code.

## 20. Interview Questions with Answers
**Q: How did you handle relational data in the UI?**
A: I used SQL `LEFT JOIN` and `CREATE VIEW` to combine data from `towers` and `regions`, and passed the unified data to Jinja2 templates for rendering.

**Q: What happens if a region is deleted?**
A: I used `ON DELETE SET NULL` on the `towers` table so the tower records are preserved even if the region is removed.

## 21. Resume Project Description
**Telecom Customer Database Management System (Python, Flask, MySQL, Bootstrap)**
- Developed a full-stack telecom admin portal simulating internal operations of an ISP.
- Designed a normalized MySQL database featuring 10+ tables, complex joins, views, and automated triggers.
- Implemented an interactive dashboard using Chart.js to visualize revenue and active network towers.
- Achieved a 100% responsive UI using Bootstrap 5 and Jinja2 templating.

## 22. GitHub & LinkedIn Description
🚀 Just completed my full-stack Telecom Database Management System! Built using Python Flask, MySQL, and Bootstrap. Explored advanced SQL concepts like Triggers, Stored Procedures, and Views to manage customers, billing, and network infrastructure. Check out the repo! #Python #Flask #MySQL #WebDevelopment

## 23. Pitch Scripts
**1-Minute:** "Hi, I developed a Telecom Management System using Flask and MySQL. It simulates a telecom operator's dashboard where admins can track customers, manage SIM cards, and monitor region-wise network towers. The core focus was implementing advanced database features like triggers for automation and stored procedures for postpaid billing generation."

**3-Minute:** Start with the problem (telecom operators handle massive relational data). Explain your solution (a centralized web app). Discuss the Tech Stack (Flask + MySQL). Highlight the Database Architecture (normalized tables, 1-to-many relationships). Explain a specific technical challenge (using Views to simplify complex UI queries). Conclude with the result (a practical, industry-ready CRUD application).

## 24. Step-by-Step Local Deployment Guide
*(Covered in Section 12)*

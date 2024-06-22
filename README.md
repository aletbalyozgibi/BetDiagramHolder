# SQL Query For Betting Site Customer Habits Database
This repository contains MS SQL scripts for managing a betting site's customer database. It includes advanced queries, functions, procedures, and triggers for efficient data management.
@auth pauBahis
    
------Contents :

Tables:


    Customers: Stores customer information.

    Bets: Stores betting information.

Functions:

    fn_DailyTotalBets: Calculates the total bet amount for a given date.

    fn_CustomerTotalWinnings: Calculates a customer's total winnings.

Procedures:

    sp_AddBet: Adds a new bet and checks the daily betting limit.

Triggers:

    trg_UpdateCustomerWinnings: Updates customer winnings when bet outcomes change.

Queries:

    Retrieves a summary of bets and winnings for the last 30 days.

Notes to be READED !!!

    This is a sample database structure and should be thoroughly tested before use in a real system.
    Business rules like the daily betting limit are defined in the sp_AddBet procedure and can be customized as needed.
    Use triggers and procedures carefully as they may impact performance.


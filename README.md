# 🧹 Data Cleaning in SQL — Layoffs Dataset

This project demonstrates data cleaning techniques using MySQL on a real-world dataset about tech industry layoffs. The goal is to transform raw, messy data into a clean and analysis-ready format.

---

## 📁 File

| File | Description |
|------|-------------|
| `cleaning_layoffs.sql` | Full SQL script for cleaning the layoffs dataset |

---

## 📊 Dataset

The dataset contains information about company layoffs, including:

- Company name and location
- Industry and stage
- Total employees laid off and percentage
- Date of layoffs
- Funds raised (in millions)
- Country

> The raw data is loaded into a table called `layoffs`. All cleaning is performed on staging tables to preserve the original data.

---

## 🔧 What the Script Does

The cleaning process follows four main steps:

### 1. Remove Duplicates
- A staging table (`layoffs_staging`) is created as a copy of the original.
- Duplicates are identified using `ROW_NUMBER()` with `PARTITION BY` across all relevant columns.
- Since deleting directly from a CTE is not supported in MySQL, a second staging table (`layoffs_staging2`) is created with a `row_num` column to enable deletion.

### 2. Standardize the Data
- **Company:** Leading/trailing whitespace removed using `TRIM()`.
- **Industry:** Inconsistent values like `"Crypto"` and `"Cryptocurrency"` are unified under `"Crypto"`.
- **Location:** Encoding issues fixed (e.g., `"Dusseldorf"`, `"Malmö"`).
- **Country:** Trailing punctuation removed from `"United States."`.
- **Date:** Converted from `TEXT` to proper `DATE` type using `STR_TO_DATE()` and `ALTER TABLE`.

### 3. Handle Null and Blank Values
- Blank strings in the `industry` column are converted to `NULL` for consistency.
- Missing `industry` values are filled in using a **self-join** — if another row for the same company has a known industry, it is used to populate the null.
- Rows where both `total_laid_off` and `percentage_laid_off` are `NULL` are removed, as they provide no useful information.

### 4. Remove Irrelevant Columns
- The helper column `row_num` (added for duplicate removal) is dropped after it is no longer needed.

---

## 🚀 How to Use

1. **Clone this repository**
```bash
   git clone https://github.com/your-username/your-repo-name.git
```

2. **Import the raw dataset** into your MySQL database as a table named `layoffs`.

3. **Run the script** in your MySQL client (e.g., MySQL Workbench, DBeaver, or CLI):
```bash
   mysql -u your_username -p your_database < cleaning_layoffs.sql
```

4. The cleaned data will be available in the `layoffs_staging2` table.

---

## 🛠️ Prerequisites

- MySQL 8.0 or higher
- A MySQL client (e.g., MySQL Workbench, DBeaver, or terminal)
- The raw `layoffs` table loaded into your database

---

## 📝 Notes

- The original `layoffs` table is never modified — all changes are made on staging copies.
- Bally's Interactive could not have its `industry` populated because it has only one record in the dataset, so the self-join approach had no match to draw from.
- `total_laid_off` and `percentage_laid_off` nulls could not be filled without knowing the total headcount before layoffs.

---

## 🙋 Author

**Your Name**
[GitHub](https://github.com/farwahasnain) · [LinkedIn](https://www.linkedin.com/in/farwah-hasnain/)

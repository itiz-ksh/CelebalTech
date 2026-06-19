# Backpack Dataset Cleaning and Basic Data Analysis

## Overview

This project demonstrates the basic data preprocessing techniques performed on a backpack product dataset using the **Pandas** library in Python. The objective was to inspect the dataset, clean unnecessary data, perform simple filtering and selection operations, and save the cleaned dataset for future analysis.

---

## Prerequisites

* Python 3
* Virtual Environment (venv)
* Pandas

### Create and Activate Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
```

### Install Required Library

```bash
pip install pandas
```

---

## Dataset Loading

The dataset was loaded into a Pandas DataFrame.

```python
backPackData = pd.read_csv("path/archive/backpacks.csv")
```

---

## Data Exploration

Several commands were executed to understand the structure of the dataset before cleaning.

### View Sample Records

```python
backPackData.head()
backPackData.tail()
```

**Purpose**

* View the first few rows.
* View the last few rows.
* Verify that the dataset loaded correctly.

---

### Check Dataset Shape

```python
backPackData.shape
```

**Purpose**

* Determine the total number of rows and columns.

---

### View Column Names

```python
backPackData.columns
```

**Purpose**

* Identify all available features in the dataset.

---

### Check Data Types

```python
backPackData.dtypes
```

**Purpose**

* Verify the datatype of every column.
* Ensure numerical columns are suitable for calculations.

---

## Missing Value Analysis

```python
backPackData.isnull()
backPackData.isnull().sum()
backPackData.isnull().sum().sum()
```

**Purpose**

* Identify missing values.
* Count missing values per column.
* Calculate the total number of missing values in the dataset.

---

## Data Cleaning

### Remove Duplicate Records

```python
backPackData.drop_duplicates(subset=["product_id"], inplace=True)
```

**Reason**

Each product should appear only once. Duplicate product IDs can lead to incorrect analysis and inaccurate statistics.

---

### Remove `what_customers_said`

```python
backPackData = backPackData.drop("what_customers_said", axis=1)
```

**Reason**

This column contained mostly missing values and did not contribute significantly to the analysis.

---

### Remove `seller_information`

```python
backPackData = backPackData.drop("seller_information", axis=1)
```

**Reason**

This column was almost entirely empty (null values), making it unnecessary for further processing.

---

## Basic Data Operations

### Filter Products with Rating Greater Than 4

```python
highRating = backPackData[backPackData["rating"] > 4]
```

**Purpose**

Retrieve only highly rated products.

---

### Select Specific Columns

```python
selected = backPackData[
    [
        "product_id",
        "title",
        "rating",
        "final_price",
        "category"
    ]
]
```

**Purpose**

Display only the important columns required for analysis.

---

### Filter and Select Together

```python
result = backPackData.loc[
    backPackData["rating"] >= 4.5,
    ["title", "rating", "final_price"]
]
```

**Purpose**

Retrieve products with ratings of **4.5 or higher** while displaying only relevant information.

---

## Save the Cleaned Dataset

```python
backPackData.to_csv("cleanedbackPack.csv", index=False)
```

## Output

The final cleaned dataset is saved as:

```
cleanedbackPack.csv
```
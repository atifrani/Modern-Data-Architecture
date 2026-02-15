import pandas as pd
import numpy as np

np.random.seed(42)

n = 1000

data = pd.DataFrame({
    "customer_id": range(1, n+1),
    "age": np.random.randint(18, 65, n),
    "tenure_months": np.random.randint(1, 60, n),
    "monthly_spend": np.random.randint(20, 300, n),
    "num_logins_last_month": np.random.randint(1, 40, n),
    "support_tickets": np.random.randint(0, 5, n),
})

# Logique simple pour générer churn
data["churn"] = np.where(
    (data["tenure_months"] < 6) & 
    (data["num_logins_last_month"] < 8) | 
    (data["support_tickets"] >= 3),
    1,
    0
)

data.to_csv("customers_1000.csv", index=False)

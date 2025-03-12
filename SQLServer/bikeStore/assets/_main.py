#Python script with CSV cleaning for INSERT format 
import pandas as pd
import os
import regex

#Function to use in the product_name column in order to erase the model number
def replace(text: str) -> str:
    return regex.sub(r" - \d{4}((\/\d{4}){1,2})?$", "", text)

orig_dir: str = "assets\originalsCSV"
pd_dir: str = "assets\pandasCSV"

#Loop to clean data in original csv files
for file in os.listdir(orig_dir):    
    #Exclude stocks because it is built from the FK of other tables and does not have a PK
    if file == "stocks.csv":
        continue
        
    #Read default csv
    csv: pd.DataFrame = pd.read_csv(os.path.join(orig_dir, file))
    
    if file == "products.csv":
        csv['product_name'] = csv['product_name'].apply(replace)
        
    #Delete column in position 0 (it contains PK) in each csv file 
    csv.drop(columns=csv.columns[0], inplace=True)
    #Create a new name in singular and Title case
    new_name = file.split(".")[0]
    new_name = new_name[0: len(new_name)-1].title()
    #Export to new folder
    csv.to_csv(os.path.join(pd_dir, f"{new_name}.csv"), index=False)

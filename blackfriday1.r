setwd("D:/1.DATA/r/black-friday")

dataset= read.csv("BlackFriday.csv", header = TRUE)
library(tidyverse)
library(scales)
library(arules)
library(gridExtra)
library(dplyr)
library(ggplot2)

summary(dataset)

head(dataset)

dataset_gender = dataset %>%
  select (User_ID,Age, Gender ) %>%
  group_by(User_ID) %>%
  arrange(User_ID) %>%
  distinct()  

head(dataset_gender)

summary(dataset_gender$Gender)
options(scipen=10000)   # To remove scientific numbering

genderDist  = ggplot(data = dataset_gender) +
  geom_bar(mapping = aes(x = Gender, y = ..count.., fill = Gender)) +
  labs(title = 'Gender of Customers') + 
  scale_fill_brewer(palette = 5)
print(genderDist)

total_purchase_user = dataset %>%
  select(User_ID, Gender, Purchase) %>%
  group_by(User_ID) %>%
  arrange(User_ID) %>%
  summarise(Total_Purchase = sum(Purchase))

user_gender = dataset %>%
  select(User_ID, Gender) %>%
  group_by(User_ID) %>%
  arrange(User_ID) %>%
  distinct()

head(user_gender)
head(total_purchase_user)
user_purchase_gender = full_join(total_purchase_user, user_gender, by = "User_ID")
head(user_purchase_gender)

average_spending_gender = user_purchase_gender %>%
  group_by(Gender) %>%
  summarize(Purchase = sum(as.numeric(Total_Purchase)), 
            Count = n(), 
            Average = Purchase/Count)
head(average_spending_gender)



top_sellers = dataset %>%
  count(Product_ID, sort = TRUE)

top_5 = head(top_sellers, 5)

top_5

best_seller = dataset[dataset$Product_ID == 'P00265242', ]

head(best_seller)

genderDist_bs  = ggplot(data = best_seller) +
  geom_bar(mapping = aes(x = Gender, y = ..count.., fill = Gender)) +
  labs(title = 'Gender of Customers (Best Seller)') +
  scale_fill_brewer(palette = 'PuBuGn')
print(genderDist_bs)

genderDist_bs_prop = ggplot(data = best_seller) + 
  geom_bar(fill = 'lightblue', mapping = aes(x = Gender, y = ..prop.., group = 1, fill = Gender)) +
  labs(title = 'Gender of Customers (Best Seller - Proportion)') +
  theme(plot.title = element_text(size=9.5))
print(genderDist_bs_prop)

genderDist_prop = ggplot(data = dataset_gender) + 
  geom_bar(fill = "lightblue4", mapping = aes(x = Gender, y = ..prop.., group = 1)) +
  labs(title = 'Gender of Customers (Total Proportion)') +
  theme(plot.title = element_text(size=9.5)) 

grid.arrange(genderDist_prop, genderDist_bs_prop, ncol=2)

##AGE
customers_age = dataset %>%
  select(User_ID, Age) %>%
  distinct() %>%
  count(Age)
customers_age

customers_age_vis = ggplot(data = customers_age) + 
  geom_bar(color = 'black', stat = 'identity', mapping = aes(x = Age, y = n, fill = Age)) +
  labs(title = 'Age of Customers') +
  theme(axis.text.x = element_text(size = 10)) +
  scale_fill_brewer(palette = 'Blues') +
  theme(legend.position="none")
print(customers_age_vis)

ageDist_bs  = ggplot(data = best_seller) +
  geom_bar(color = 'black', mapping = aes(x = Age, y = ..count.., fill = Age)) +
  labs(title = 'Age of Customers (Best Seller)') +
  theme(axis.text.x = element_text(size = 10)) +
  scale_fill_brewer(palette = 'GnBu') + 
  theme(legend.position="none")
print(ageDist_bs)

grid.arrange(customers_age_vis, ageDist_bs, ncol=2)

##CITY
customers_location =  dataset %>%
  select(User_ID, City_Category) %>%
  distinct()
head(customers_location)
customers_location_vis = ggplot(data = customers_location) +
  geom_bar(color = 'white', mapping = aes(x = City_Category, y = ..count.., fill = City_Category)) +
  labs(title = 'Location of Customers') + 
  scale_fill_brewer(palette = "Dark2") + 
  theme(legend.position="none")
print(customers_location_vis)

purchases_city = dataset %>%
  group_by(City_Category) %>%
  summarise(Purchases = sum(Purchase))

purchases_city_1000s = purchases_city %>%
  mutate(purchasesThousands = purchases_city$Purchases / 1000)

purchases_city_1000s
purchaseCity_vis = ggplot(data = purchases_city_1000s, aes(x = City_Category, y = purchasesThousands, fill = City_Category)) +
  geom_bar(color = 'white', stat = 'identity') +
  labs(title = 'Total Customer Purchase Amount (by City)', y = '($000s)', x = 'City Category') +
  scale_fill_brewer(palette = "Dark2") + 
  theme(legend.position="none", plot.title = element_text(size = 9))
print(purchaseCity_vis)

grid.arrange(customers_location_vis, purchaseCity_vis, ncol=2)

customers = dataset %>%
  group_by(User_ID) %>%
  count(User_ID)
head(customers)

customers_City =  dataset %>%
  select(User_ID, City_Category) %>%
  group_by(User_ID) %>%
  distinct() %>%
  ungroup() %>%
  left_join(customers, customers_City, by = 'User_ID') 
head(customers_City)

city_purchases_count = customers_City %>%
  select(City_Category, n) %>%
  group_by(City_Category) %>%
  summarise(CountOfPurchases = sum(n))
city_purchases_count

city_count_purchases_vis = ggplot(data = city_purchases_count, aes(x = City_Category, y = CountOfPurchases, fill = City_Category)) +
  geom_bar(color = 'white', stat = 'identity') +
  labs(title = 'Total Purchase Count (by City)', y = 'Count', x = 'City Category') +
  scale_fill_brewer(palette = "Dark2") +
  theme(legend.position="none", plot.title = element_text(size = 9))
print(city_count_purchases_vis)

grid.arrange(purchaseCity_vis, city_count_purchases_vis, ncol = 2)

head(best_seller)

best_seller_city = best_seller %>%
  select(User_ID, City_Category) %>%
  distinct() %>%
  count(City_Category)
best_seller_city

best_seller_city_vis = ggplot(data = best_seller_city, aes(x = City_Category, y = n, fill = City_Category)) +
  geom_bar(color = 'white', stat = 'identity') +
  labs(title = 'Best Seller Purchase Count (by City)', y = 'Count', x = 'City Category') +
  scale_fill_brewer(palette = "Blues") +
  theme(legend.position="none", plot.title = element_text(size = 9))
grid.arrange(city_count_purchases_vis,best_seller_city_vis, ncol = 2)

customers_stay = dataset %>%
  select(User_ID, City_Category, Stay_In_Current_City_Years) %>%
  group_by(User_ID) %>%
  distinct()
head(customers_stay)

residence = customers_stay %>%
  group_by(City_Category) %>%
  tally()
head(residence)

customers_stay_vis = ggplot(data = customers_stay, aes(x = Stay_In_Current_City_Years, y = ..count.., fill = Stay_In_Current_City_Years)) +
  geom_bar(stat = 'count') +
  scale_fill_brewer(palette = 15) +
  labs(title = 'Customers Stay in Current City', y = 'Count', x = 'Stay in Current City', fill = 'Number of Years in Current City')
print(customers_stay_vis)

stay_cities = customers_stay %>%
  group_by(City_Category, Stay_In_Current_City_Years) %>%
  tally() %>%
  mutate(Percentage = (n/sum(n))*100)
head(stay_cities)

ggplot(data = stay_cities, aes(x = City_Category, y = n, fill = Stay_In_Current_City_Years)) + 
  geom_bar(stat = "identity", color = 'white') + 
  scale_fill_brewer(palette = 2) + 
  labs(title = "City Category + Stay in Current City", 
       y = "Total Count (Years)", 
       x = "City", 
       fill = "Stay Years")

##PURCHASE

customers_total_purchase_amount = dataset %>%
  group_by(User_ID) %>%
  summarise(Purchase_Amount = sum(Purchase))

head(customers_total_purchase_amount)

customers_total_purchase_amount = arrange(customers_total_purchase_amount, desc((Purchase_Amount)))

head(customers_total_purchase_amount)

summary(customers_total_purchase_amount)

ggplot(customers_total_purchase_amount, aes(Purchase_Amount)) +
  geom_density(adjust = 1) +
  geom_vline(aes(xintercept=median(Purchase_Amount)),
             color="blue", linetype="dashed", size=1) +
  geom_vline(aes(xintercept=mean(Purchase_Amount)),
             color="red", linetype="dashed", size=1) +
  geom_text(aes(x=mean(Purchase_Amount), label=round(mean(Purchase_Amount)), y=1.2e-06), color = 'red', angle=360,
            size=4, vjust=3, hjust=-.1) +
  geom_text(aes(x=median(Purchase_Amount), label=round(median(Purchase_Amount)), y=1.2e-06), color = 'blue', angle=360,
            size=4, vjust=0, hjust=-.1) +
  scale_x_continuous(name="Purchase Amount", limits=c(0, 7500000), breaks = seq(0,7500000, by = 1000000), expand = c(0,0)) +
  scale_y_continuous(name="Density", limits=c(0, .00000125), labels = scientific, expand = c(0,0))

##MARITAL
dataset_maritalStatus = dataset %>%
  select(User_ID, Marital_Status) %>%
  group_by(User_ID) %>%
  distinct()

head(dataset_maritalStatus)

dataset_maritalStatus$Marital_Status = as.character(dataset_maritalStatus$Marital_Status)
typeof(dataset_maritalStatus$Marital_Status)

marital_vis = ggplot(data = dataset_maritalStatus) +
  geom_bar(mapping = aes(x = Marital_Status, y = ..count.., fill = Marital_Status)) +
  labs(title = 'Marital Status') +
  scale_fill_brewer(palette = 'Pastel2')
print(marital_vis)

dataset_maritalStatus = dataset_maritalStatus %>%
  full_join(customers_stay, by = 'User_ID') 
head(dataset_maritalStatus)

maritalStatus_cities = dataset_maritalStatus %>%
  group_by(City_Category, Marital_Status) %>%
  tally()
head(maritalStatus_cities)

ggplot(data = maritalStatus_cities, aes(x = City_Category, y = n, fill = Marital_Status)) + 
  geom_bar(stat = "identity", color = 'black') + 
  scale_fill_brewer(palette = 2) + 
  labs(title = "City + Marital Status", 
       y = "Total Count (Shoppers)", 
       x = "City", 
       fill = "Marital Status")

Users_Age = dataset %>%
  select(User_ID, Age) %>%
  distinct()
head(Users_Age)
dataset_maritalStatus = dataset_maritalStatus %>%
  full_join(Users_Age, by = 'User_ID')
head(dataset_maritalStatus)
City_A = dataset_maritalStatus %>%
  filter(City_Category == 'A')
City_B = dataset_maritalStatus %>%
  filter(City_Category == 'B')
City_C = dataset_maritalStatus %>%
  filter(City_Category == 'C')
head(City_A)
head(City_B)
head(City_C)

City_A_stay_vis = ggplot(data = City_A, aes(x = Age, y = ..count.., fill = Age)) + 
  geom_bar(stat = 'count') +
  scale_fill_brewer(palette = 8) +
  theme(legend.position="none", axis.text = element_text(size = 6)) +
  labs(title = 'City A', y = 'Count', x = 'Age', fill = 'Age')
City_B_stay_vis = ggplot(data = City_B, aes(x = Age, y = ..count.., fill = Age)) +
  geom_bar(stat = 'count') +
  scale_fill_brewer(palette = 9) +
  theme(legend.position="none", axis.text = element_text(size = 6)) +
  labs(title = 'City B', y = 'Count', x = 'Age', fill = 'Age')
City_C_stay_vis = ggplot(data = City_C, aes(x = Age, y = ..count.., fill = Age)) +
  geom_bar(stat = 'count') +
  scale_fill_brewer(palette = 11) +
  theme(legend.position="none", axis.text = element_text(size = 6)) +
  labs(title = 'City C', y = 'Count', x = 'Age', fill = 'Age')

grid.arrange(City_A_stay_vis, City_B_stay_vis, City_C_stay_vis, ncol = 3)

top_shoppers = dataset %>%
  count(User_ID, sort = TRUE)

head(top_shoppers)
top_shoppers =  top_shoppers %>%
  select(User_ID, n) %>%
  left_join(customers_total_purchase_amount, Purchase_Amount, by = 'User_ID')

head(top_shoppers)
top_shoppers = mutate(top_shoppers,
                      Average_Purchase_Amount = Purchase_Amount/n)

head(top_shoppers)
top_shoppers_averagePurchase = top_shoppers %>%
  arrange(desc(Average_Purchase_Amount))

head(top_shoppers_averagePurchase)

##OCCUPATION
customers_Occupation =  dataset %>%
  select(User_ID, Occupation) %>%
  group_by(User_ID) %>%
  distinct() %>%
  left_join(customers_total_purchase_amount, Occupation, by = 'User_ID')

head(customers_Occupation)

totalPurchases_Occupation = customers_Occupation %>%
  group_by(Occupation) %>%
  summarise(Purchase_Amount = sum(Purchase_Amount)) %>%
  arrange(desc(Purchase_Amount))

totalPurchases_Occupation$Occupation = as.character(totalPurchases_Occupation$Occupation)
typeof(totalPurchases_Occupation$Occupation)

head(totalPurchases_Occupation)

occupation = ggplot(data = totalPurchases_Occupation) +
  geom_bar(mapping = aes(x = reorder(Occupation, -Purchase_Amount), y = Purchase_Amount, fill = Occupation), stat = 'identity') +
  scale_x_discrete(name="Occupation", breaks = seq(0,20, by = 1), expand = c(0,0)) +
  scale_y_continuous(name="Purchase Amount ($)", expand = c(0,0), limits = c(0, 750000000)) +
  labs(title = 'Total Purchase Amount by Occupation') + 
  theme(legend.position="none")
print(occupation)

library(arules)
library(arulesViz)
library(tidyverse)
# Data Preprocessing
# Getting the dataset into the correct format
customers_products = dataset %>%
  select(User_ID, Product_ID) %>%   # Selecting the columns we will need
  group_by(User_ID) %>%             # Grouping by "User_ID"          
  arrange(User_ID) %>%              # Arranging by "User_ID" 
  mutate(id = row_number()) %>%     # Defining a key column for each "Product_ID" and its corresponding "User_ID" (Must do this for spread() to work properly)
  spread(User_ID, Product_ID) %>%   # Converting our dataset from tall to wide format, and grouping "Product_IDs" to their corresponding "User_ID"
  t()                               # Transposing the dataset from columns of "User_ID" to rows of "User_ID"

# Now we can remove the Id row we created earlier for spread() to work correctly.
customers_products = customers_products[-1,]
write.csv(customers_products, file = 'customers_products.csv')

customersProducts = read.transactions('customers_products.csv', sep = ',', rm.duplicates = TRUE) # remove duplicates with rm.duplicates

summary(customersProducts)
itemFrequencyPlot(customersProducts, topN = 25)    # topN is limiting to the top 50 products
rules = apriori(data = customersProducts,
                parameter = list(support = 0.008, confidence = 0.80, maxtime = 0)) # maxtime = 0 will allow our algorithim to run until completion with no time limit
inspect(sort(rules, by = 'lift'))
plot(rules, method = 'graph')

rules = apriori(data = customersProducts,
                parameter = list(support = 0.008, confidence = 0.75, maxtime = 0))

inspect(head(sort(rules, by = 'lift'))) # limiting to the top 6 rules

plot(rules, method = 'graph', max = 25)
plot(rules, method = 'grouped', max = 25)


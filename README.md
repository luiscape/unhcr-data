UNHCR Data
==========

Organizing data from UNHCR into HDX Repo (data.hdx.rwlabs.org).


UNHCR uses a classification system based on 5 categories:

- Asylum seekers
- Others of concern
- Refugees
- Returned IDPs
- Returned refugees
- Stateless

All are considered `people of concern` by UNHCR.

UNHCR assigns every people of concern to a country pair:

- Country / territory of residence
- Origin / Returned from


Problem
-------
Each indicator in the HDX database is country-based. The six "indicators" used by UNHCR (taken from their classification system above) are based in **country pairs** not single countries.

In order for the data to be added to our system we have to create a single indicator per country.


Solution
--------

First, one of the most important figures to have globally is the simple sum of all those classes. Here we are creating the `Number of People of Concern` indicator and adding to HDX:

`Number of People of Concern` = `Asylum seekers` + `Others of concern` + `Refugees` + `Returned IDPs` + `Returned refugees` + `Stateless`

That basic indicator is divided in two:

- `Number of People of Concern` from **origin**
- `Number of People of Concern` in **residence country**

Those indicators are divided per year.



The six classes used by UNHCR are distributed in the following way:

[class_distribution.png]

Based on the frequency a class is assigned to a group of people, two seem to be the most important: `Asylum seekers` and `Refugees`. We should start from those two groups.




Analyzing the classes above we can see that XX of them could be assiged to a single country without problems:

- Asylum seekers `->` Country / territory of residence
- Refugees `->` Origin / Returned from



- Returned IDPs `->` Origin / Returned from
- Returned refugees `->` Country / territory of residence
- Stateless `->` Origin / Returned from

- Others of concern `->` Origin / Returned from




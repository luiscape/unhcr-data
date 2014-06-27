UNHCR Data
==========

All observations from 'Various' will not be included in the database at this point. (Nor observations from the "country" Bonaire, Sint Eustatius and Saba).

Also, Yugoslavia was added under the code 'YUG'.


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



Codebook 
--------

Here are a few note from http://popstats.unhcr.org/ about how UNHCR classifies data: 

- **Refugees** include individuals recognised under the 1951 Convention relating to the Status of Refugees; its 1967 Protocol; the 1969 OAU Convention Governing the Specific Aspects of Refugee Problems in Africa; those recognised in accordance with the UNHCR Statute; individuals granted complementary forms of protection; or those enjoying temporary protection. The refugee population also includes people in a refugee-like situation.
- **Asylum-seekers** are individuals who have sought international protection and whose claims for refugee status have not yet been determined, irrespective of when they may have been lodged.
Returned refugees are former refugees who have returned to their country of origin spontaneously or in an organised fashion but are yet to be fully integrated. Such return would normally only take place in conditions of safety and dignity.
- **Internally displaced persons (IDPs)** are people or groups of individuals who have been forced to leave their homes or places of habitual residence, in particular as a result of, or in order to avoid the effects of armed conflict, situations of generalised violence, violations of human rights, or natural or man-made disasters, and who have not crossed an international border. For the purposes of UNHCR's statistics, this population only includes conflict-generated IDPs to whom the Office extends protection and/or assistance. The IDP population also includes people in an IDP-like situation.
**Returned IDPs** refer to those IDPs who were beneficiaries of UNHCR's protection and assistance activities and who returned to their areas of origin or habitual residence during the year.
- **Stateless persons** are defined under international law as persons who are not considered as nationals by any State under the operation of its law. In other words, they do not possess the nationality of any State. UNHCR statistics refer to persons who fall under the agency’s statelessness mandate because they are stateless according to this international definition, but data from some countries may also include persons with undetermined nationality.
- **Others of concern** refers to individuals who do not necessarily fall directly into any of the groups above, but to whom UNHCR extends its protection and/or assistance services, based on humanitarian or other special grounds.


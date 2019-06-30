## Code to prepare `ansur` dataset.

# Load packages -----------------------------------------------------------

library("here")
library("usethis")
library("readr")
library("dplyr")


# Load data ---------------------------------------------------------------

# The original raw files are in "inst/extdata/".
# That's probably the best place for them in case
# anyone wants to access them.

male_data_set_path <- here("inst", "extdata", "ANSUR_II_MALE_Public.csv")
female_data_set_path <- here("inst", "extdata", "ANSUR_II_FEMALE_Public.csv")

female_dataset <- read_csv(female_data_set_path)

# To merge the male and female data sets, we need
# the variable that identifies the subject in each one to have
# the same name. In the male data, it is `subjectid`.
# In the female, it is `SubjectId`. We will change the name
# in the male data set.
male_dataset <- read_csv(male_data_set_path) %>%
  rename(SubjectId = subjectid)


# Process data ------------------------------------------------------------

# We'll select gender, height, weight, race, and handedness data.

# # The `stature` and `weightkg` give height and weight in mm and (presumably)
# kg x 10, respectively. Why they use kg x 10 is not clear, especially given
# that the variable is `weightkg`. However, it is the only plausible
# explanation (e.g. the average male is not 855kg and the average female is not
# 677kg, but average weights of 85.5kg and 67.7kg, respectively, make sense.


ansur <- bind_rows(male_dataset, female_dataset) %>%
  bind_rows(male_dataset, female_dataset) %>%
  mutate(height = stature/10,   # `stature` is in mm
         weight = weightkg/10,
         gender = recode(Gender, Male = 'male', Female = 'female'),
         race = case_when(
           DODRace == 1 ~ 'white',
           DODRace == 2 ~ 'black',
           DODRace == 3 ~ 'hispanic',
           DODRace == 4 ~ 'asian',
           DODRace == 5 ~ 'native_american',
           DODRace == 6 ~ 'pacific_islander',
           DODRace == 8 ~ 'other',
           TRUE ~ 'NA'),
         handedness = case_when(
           WritingPreference == 'Right hand' ~ 'right',
           WritingPreference == 'Left hand' ~ 'left',
           WritingPreference == 'Either hand (No preference)' ~ 'either'
         )
  ) %>%
  select(subjectid = SubjectId,
         gender,
         height,
         weight,
         handedness,
         age = Age,
         race)


# Add to data/ ------------------------------------------------------------

use_data(ansur, overwrite = TRUE)

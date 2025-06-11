first30 <- HrSHLD_dery_df %>% select(year, hurricane, first_hurr_year, group) %>% 
  slice_head(n = 30)

select_df <- HrSHLD_dery_df %>% select(county_fips, year, tot_hurr, group_SHLD)



sample_both <- HrSHLD_dery_df %>% filter(county_fips %in% c(1001, 1005, 13031)) %>% 
  select(county_fips, FIPS_5, year, hurricane, any_hurrDMG_SHLD, group_SHLD, post_treat_SHLD, time_to_treat_SHLD, ever_treated_SHLD, treatment_post_SHLD)


sample_both <- df %>% filter(county_fips %in% c(1001, 1005, 13031)) %>% 
  select(county_fips, FIPS_5, year, hurricane, any_hurrDMG_SHLD, group_SHLD, group_Dery, post_treat_SHLD, time_to_treat_SHLD, ever_treated_SHLD, treatment_post_SHLD)


# Count counties with Deryugina hurricane after 2002
df %>% summarize(max_year = max(year, na.rm = TRUE))

df %>% summarize(max_year = max(year, na.rm = TRUE))

county_count <- df %>%
  # Filter rows where year is greater than 2002 and hurricane is 1
  filter(year > 2002 & hurricane == 1) %>%
  # Group by county (FIPS_5)
  group_by(FIPS_5) %>%
  # Summarize to check if there is at least one occurrence of a hurricane
  summarize(has_hurricane = any(hurricane == 1)) %>%
  # Filter out counties that do not have any hurricane
  filter(has_hurricane == TRUE) %>%
  # Count the number of unique counties
  summarise(county_count = n())

print(county_count)

# Count counties with SHELDUS hurricane after 2002
county_count <- df %>%
  # Filter rows where year is greater than 2002 and hurricane is 1
  filter(year > 2002 & any_hurrDMG_SHLD == 1) %>%
  # Group by county (FIPS_5)
  group_by(FIPS_5) %>%
  # Summarize to check if there is at least one occurrence of a hurricane
  summarize(has_hurricane = any(hurricane == 1)) %>%
  # Filter out counties that do not have any hurricane
  filter(has_hurricane == TRUE) %>%
  # Count the number of unique counties
  summarise(county_count = n())

print(county_count)

# Group counts
df %>%
  count(group_SHLD, name = "county_count")

# 1979 exploration

SH_79 <- df %>%
  filter(group_SHLD == 1979 & year == 1979)

write_csv(SH_79, here("data/data_check/SHELD-Dery_1979.csv"))

work with dependencies:
- [x] Update the lookup module to check TSCPriceFetcher.dataSource and call appropriate data addon API
- [x] Create adapter functions to normalize differences between full/lite data addon APIs
- [x] Handle data format differences (array vs single number) in lookup module
- [x] Add feature detection for conditional UI elements based on available data source
- [x] Remove hardcoded TSCPriceNameData.lua dependency once external data sources work
- [x] Add fallback handling for when data addon exists but returns null/empty for specific items
- [x] Test all scenarios: full data, lite data, and no data

# TODO

- [ ] Get tooltip working for weapons and armor
- [ ] Get tooltip working in shop interface
- [ ] Get tooltip working in mail attachments
- [ ] Get tooltip working in trade windows
- [ ] Get tooltip working in crafting result tooltips
- [ ] Get tooltip working in guild store listings
    - [ ] Set average price as default value in guild store when listing
- [ ] Get tooltip working in loot windows
- [ ] Get tooltip working in craft bag
    - [ ] Investigate if there is a tooltip in the craft bag and if it can be hooked


- [ ] Add user feedback for "no price data" (e.g., subtle line, optional hiding in settings)
- [x] Add advanced filtering options
    - [x] Hide price for bound or non-tradable items

# Refactor

- [x] refactor the data file to use ids for items with single ids
- [x] refactor the data file to use names for items with multiple ids
- [x] refactor the lookup to try by id first, then fall back to name

## Nice to have

- [ ] Add settings menu (LibAddonMenu-2.0) for toggling features, icon size, debug, etc.
- [ ] Add price trends (min/max/average, last updated date)
# Known Bugs

## Item Lookup Issues

- [x] Some items do not return price data even though they exist in the data table (lowercased).
    - [x] Debug log says `'rough maple^ns'`
    - [x] Debug log says `'rawhide scraps^p'`

---

**Notes:**
- The item name suffix issue (e.g., `^ns`, `^p`) was caused by ESO API grammatical suffixes.  
- This is now fixed by stripping the suffix before lookup.
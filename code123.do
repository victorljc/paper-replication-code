********************************************************************************
*                                                                              *
*   Green Finance and the Embodied-Carbon Paradox                              *
*                          *
*                                                                              *
*   Last updated: MAY 2026                                                *
*                                                                              *
*   VARIABLE NAMING CONVENTION                                                 *
*   ─────────────────────────────────────────────────────────────────────────   *
*   Dependent variables                                                        *
*     carb_dir     Direct carbon intensity growth        (was: speedz)         *
*     carb_lc      Lifecycle carbon intensity growth     (was: speedq_raw)     *
*     carb_lc_w    Lifecycle, winsorised 3-97%           (was: speedq)         *
*                                                                              *
*   Core explanatory variable                                                  *
*     fin_green    Green finance composite index (PCA)   (was: xpca)           *
*                                                                              *
*   Alternative explanatory variable                                           *
*     fin_cred     Green credit ratio                    (was: credit)         *
*                                                                              *
*   Control variables                                                          *
*     econ_gdp     Per capita GDP                        (was: gdp)            *
*     econ_pop     Population                            (was: people)         *
*     econ_fdi     Foreign direct investment              (was: fdi)            *
*     reg_env      Environmental regulatory investment   (was: environment)    *
*     reg_str      Legal/regulatory stringency           (was: famo)           *
*                                                                              *
*   Channel / mechanism variables                                              *
*     ener_therm   Log thermal utilisation hours         (was: ln_coal)        *
*     ener_rnw     Renewable electricity share           (was: lvdian)         *
*     ratiohour    Green dispatch ratio                  (unchanged)           *
*                                                                              *
*   Moderation variable                                                        *
*     dig_econ     Digital economy index                 (was: digital)        *
*                                                                              *
********************************************************************************


* ============================================================
* 0. SETUP: Load data, rename variables, define globals
* ============================================================
clear all
set more off
capture log close
log using "analysis123.smcl", replace smcl

use merged_2017_1985.dta, clear
xtset id year

* --- Rename to publication convention ---
rename speedz       carb_dir
rename speedq_raw   carb_lc
rename speedq       carb_lc_w
rename xpca         fin_green
rename credit       fin_cred
rename gdp          econ_gdp
rename people       econ_pop
rename fdi          econ_fdi
rename environment  reg_env
rename famo         reg_str
rename lvdian       ener_rnw

* --- Generate derived variables ---
gen ener_therm = ln(火电厂利用小时)
label var ener_therm "Log thermal utilisation hours"

* --- Label all variables ---
label var carb_dir   "Direct carbon intensity growth"
label var carb_lc    "Lifecycle carbon intensity growth"
label var carb_lc_w  "Lifecycle carbon intensity growth (winsorised)"
label var fin_green  "Green finance composite index"
label var fin_cred   "Green credit ratio"
label var econ_gdp   "Per capita GDP"
label var econ_pop   "Population"
label var econ_fdi   "Foreign direct investment"
label var reg_env    "Environmental regulatory investment"
label var reg_str    "Regulatory stringency"
label var ener_rnw   "Renewable electricity share"

* --- Define control set ---
global controls "econ_gdp econ_pop econ_fdi reg_env reg_str"

save analysis_renamed.dta, replace


* ============================================================
* 1. BASELINE REGRESSIONS (Table 1 & Figure 1 Panel a)
* ============================================================

display _n "═══════════════════════════════════════"
display    " SECTION 1: BASELINE REGRESSIONS"
display    "═══════════════════════════════════════"

* ─── 1a. Lifecycle carbon intensity (carb_lc) ───

est clear

* (1) RE: fin_green only
xtreg carb_lc fin_green, re vce(cluster id)
est store lc_1
estadd local ProvFE "No"
estadd local YearFE "No"
estadd local Controls "No"

* (2) Province + Year FE, no controls
xtreg carb_lc fin_green i.year, fe vce(cluster id)
est store lc_2
estadd local ProvFE "Yes"
estadd local YearFE "Yes"
estadd local Controls "No"

* (3) Province FE + controls, no year FE
xtreg carb_lc fin_green $controls, fe vce(cluster id)
est store lc_3
estadd local ProvFE "Yes"
estadd local YearFE "No"
estadd local Controls "Yes"

* (4) Full model (BASELINE): two-way FE + controls
xtreg carb_lc fin_green $controls i.year, fe vce(cluster id)
est store lc_4
estadd local ProvFE "Yes"
estadd local YearFE "Yes"
estadd local Controls "Yes"

esttab lc_1 lc_2 lc_3 lc_4 using "Table1_carb_lc.rtf", replace ///
    b(%9.4f) se(%9.4f) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(fin_green) ///
    stats(N r2_within ProvFE YearFE Controls, ///
          labels("Observations" "Within R²" "Province FE" "Year FE" "Controls")) ///
    title("Table 1a. Green finance → lifecycle carbon intensity growth (carb_lc)")

* ─── 1b. Direct carbon intensity (carb_dir) ───

est clear

* (1) RE: fin_green only
xtreg carb_dir fin_green, re vce(cluster id)
est store dir_1
estadd local ProvFE "No"
estadd local YearFE "No"
estadd local Controls "No"

* (2) Province + Year FE, no controls
xtreg carb_dir fin_green i.year, fe vce(cluster id)
est store dir_2
estadd local ProvFE "Yes"
estadd local YearFE "Yes"
estadd local Controls "No"

* (3) Province FE + controls, no year FE
xtreg carb_dir fin_green $controls, fe vce(cluster id)
est store dir_3
estadd local ProvFE "Yes"
estadd local YearFE "No"
estadd local Controls "Yes"

* (4) Full model: two-way FE + controls
xtreg carb_dir fin_green $controls i.year, fe vce(cluster id)
est store dir_4
estadd local ProvFE "Yes"
estadd local YearFE "Yes"
estadd local Controls "Yes"

esttab dir_1 dir_2 dir_3 dir_4 using "Table1_carb_dir.rtf", replace ///
    b(%9.4f) se(%9.4f) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(fin_green) ///
    stats(N r2_within ProvFE YearFE Controls, ///
          labels("Observations" "Within R²" "Province FE" "Year FE" "Controls")) ///
    title("Table 1b. Green finance → direct carbon intensity growth (carb_dir)")


* ============================================================

* ============================================================
* 2. ROBUSTNESS TESTS (paired: lifecycle vs direct)

* ============================================================
* 2. ROBUSTNESS TESTS (Table 2)
* ============================================================

display _n "═══════════════════════════════════════"
display    " SECTION 2: ROBUSTNESS TESTS"
display    "═══════════════════════════════════════"


* ───  Exclude municipalities ───

preserve
drop if is_municipality == 1

xtreg carb_lc fin_green $controls i.year, fe
est store rob_nomuni_lc

xtreg carb_dir fin_green $controls i.year, fe
est store rob_nomuni_dir

restore

* ─── Oster bounds (selection on unobservables) ───

* Unrestricted model (no controls, province + year FE)
reg carb_lc fin_green i.year i.id
* Restricted model (with controls)
reg carb_lc fin_green $controls i.year i.id
* Oster test: Rmax = 0.5, delta = 1
psacalc beta fin_green, rmax(0.5) delta(1)



* ─── Jackknife: leave-one-province-out (Figure 1 Panel b) ───

levelsof id, local(ids)
foreach i of local ids {
    quietly reghdfe carb_lc fin_green $controls if id != `i', absorb(id year)
    estimates store jk_lc_`i'
}

esttab jk_lc_*, keep(fin_green) se star(* 0.10 ** 0.05 *** 0.01) ///
    title("Jackknife: carb_lc (leave-one-province-out)") b(%9.4f) se(%9.4f)

* ─── 2e. Instrumental variable: Bartik-style IV ───
* IV = ln(per-capita postal offices 1984) × national green finance trend

* ─── 2e. Bartik / shift-share IV ───
capture drop iv_bartik
gen iv_bartik = ln_post_1984 * shift_xpca
label var iv_bartik "IV: ln(postal 1984) × national GF trend"



ivreghdfe carb_lc ///
    (fin_green = iv_bartik) $controls, ///
    absorb(id year) ///
    cluster(id) ///
    first ffirst

estadd scalar KPF = e(widstat)
est store iv_lc
	
	
	
	// Kleibergen-Paap 一
	
ivreghdfe carb_dir ///
    (fin_green = iv_bartik) $controls, ///
    absorb(id year) ///
    cluster(id) ///
    first ffirst

estadd scalar KPF = e(widstat)
est store iv_dir	
	

* ─── 2f. System GMM ───

xtdpdsys carb_lc_w fin_green econ_gdp econ_pop econ_fdi reg_env reg_str, ///
    lags(1) twostep vce(robust)
est store gmm_lc
estat sargan
estat abond




* ============================================================
* 3. HETEROGENEITY ANALYSIS (Table 3)
* ============================================================

display _n "═══════════════════════════════════════"
display    " SECTION 3: HETEROGENEITY ANALYSIS"
display    "═══════════════════════════════════════"

* ─── 3a. By renewable energy endowment ───

bysort year: egen med_ener_rnw = median(ener_rnw)
gen high_renewable = (ener_rnw >= med_ener_rnw)

xtreg carb_dir fin_green $controls i.year if high_renewable == 1, fe
est store het_dir_hirnw
xtreg carb_dir fin_green $controls i.year if high_renewable == 0, fe
est store het_dir_lornw
xtreg carb_lc fin_green $controls i.year if high_renewable == 1, fe
est store het_lc_hirnw
xtreg carb_lc fin_green $controls i.year if high_renewable == 0, fe
est store het_lc_lornw

esttab het_dir_hirnw het_dir_lornw het_lc_hirnw het_lc_lornw, ///
    mtitle("carb_dir Hi-Rnw" "carb_dir Lo-Rnw" "carb_lc Hi-Rnw" "carb_lc Lo-Rnw") ///
    keep(fin_green) b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Table 3a. Heterogeneity by renewable energy endowment")

* ─── 3b. By region (East vs Central-West) ───

gen east = ///
    inlist(地区, "北京","天津","河北","上海","江苏","浙江") | ///
    inlist(地区, "福建","山东","广东","海南","辽宁")

xtreg carb_dir fin_green $controls i.year if east == 1, fe
est store het_dir_east
xtreg carb_dir fin_green $controls i.year if east == 0, fe
est store het_dir_west
xtreg carb_lc fin_green $controls i.year if east == 1, fe
est store het_lc_east
xtreg carb_lc fin_green $controls i.year if east == 0, fe
est store het_lc_west

esttab het_dir_east het_dir_west het_lc_east het_lc_west, ///
    mtitle("carb_dir East" "carb_dir C-W" "carb_lc East" "carb_lc C-W") ///
    keep(fin_green) b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Table 3b. Heterogeneity by region")

* ─── 3c. By economic development (GDP) ───

bysort year: egen med_gdp = median(econ_gdp)
gen high_gdp = (econ_gdp >= med_gdp)

xtreg carb_dir fin_green $controls i.year if high_gdp == 1, fe
est store het_dir_higdp
xtreg carb_dir fin_green $controls i.year if high_gdp == 0, fe
est store het_dir_logdp
xtreg carb_lc fin_green $controls i.year if high_gdp == 1, fe
est store het_lc_higdp
xtreg carb_lc fin_green $controls i.year if high_gdp == 0, fe
est store het_lc_logdp

esttab het_dir_higdp het_dir_logdp het_lc_higdp het_lc_logdp, ///
    mtitle("carb_dir Hi-GDP" "carb_dir Lo-GDP" "carb_lc Hi-GDP" "carb_lc Lo-GDP") ///
    keep(fin_green) b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Table 3c. Heterogeneity by economic development")


* ============================================================
* 4. MECHANISM IDENTIFICATION: Control-and-Exclusion
*    (Table 4 & Figure 2)
* ============================================================

display _n "═══════════════════════════════════════"
display    " SECTION 4: MECHANISM IDENTIFICATION"
display    "═══════════════════════════════════════"

* ─── Channel A: Thermal utilisation hours (ener_therm) ───

* Step 1: fin_green → ener_therm
xtreg ener_therm fin_green $controls i.year, fe
est store mechA_s1

* Step 2: fin_green → carb_dir | ener_therm
xtreg carb_dir fin_green ener_therm $controls i.year, fe
est store mechA_s2

* Step 3: fin_green → carb_lc | ener_therm
xtreg carb_lc fin_green ener_therm $controls i.year, fe
est store mechA_s3

esttab mechA_s1 mechA_s2 mechA_s3, ///
    mtitle("fin_green→therm" "carb_dir(+therm)" "carb_lc(+therm)") ///
    keep(fin_green ener_therm) b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Table 4a. Channel A: thermal utilisation hours")

* ─── Channel B: Renewable electricity share (ener_rnw) ───

* Step 1: fin_green → ener_rnw
xtreg ener_rnw fin_green $controls i.year, fe
est store mechB_s1

* Step 2: fin_green → carb_dir | ener_rnw
xtreg carb_dir fin_green ener_rnw $controls i.year, fe
est store mechB_s2

* Step 3: fin_green → carb_lc | ener_rnw
xtreg carb_lc fin_green ener_rnw $controls i.year, fe
est store mechB_s3

esttab mechB_s1 mechB_s2 mechB_s3, ///
    mtitle("fin_green→rnw" "carb_dir(+rnw)" "carb_lc(+rnw)") ///
    keep(fin_green ener_rnw) b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Table 4b. Channel B: renewable electricity share")

* ─── Channel C: Green dispatch ratio (ratiohour) ───

winsor2 ratiohour, cuts(3 97) replace

* Step 1: fin_green → ratiohour
xtreg ratiohour fin_green $controls i.year, fe
est store mechC_s1

* Step 2: fin_green → carb_dir | ratiohour
xtreg carb_dir fin_green ratiohour $controls i.year, fe
est store mechC_s2

* Step 3: fin_green → carb_lc | ratiohour
xtreg carb_lc fin_green ratiohour $controls i.year, fe
est store mechC_s3

esttab mechC_s1 mechC_s2 mechC_s3, ///
    mtitle("fin_green→dispatch" "carb_dir(+disp)" "carb_lc(+disp)") ///
    keep(fin_green ratiohour) b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Table 4c. Channel C: green dispatch ratio")
translate "analysis123.smcl" "analysis12345.pdf", replace

* ============================================================
* 5. SPATIAL DURBIN MODEL (Table 5 & Figure 3)
* ============================================================

display _n "═══════════════════════════════════════"
display    " SECTION 5: SPATIAL DURBIN MODEL"
display    "═══════════════════════════════════════"

* ─── 5a. Construct spatial weight matrix ───
* Source: w2023.dta (30×30 interprovincial electricity transmission)
* Procedure: symmetrise W_sym = W + W', then row-standardise

preserve
use "w2023.dta", clear
mata: W = st_data(., .)
mata: W_sym = W + W'
mata: rsum = rowsum(W_sym)
mata: W_std = W_sym :/ rsum
mata: st_matrix("W_final", W_std)
restore

* ─── 5b. Prepare data for xsmle ───

* Generate lagged dependent variable (xsmle requires explicit lag)
xtset id year
gen lag_carb_lc_w = L.carb_lc_w
label var lag_carb_lc_w "Lagged carb_lc (winsorised)"

* Interpolate any missing values for balanced panel
foreach var in carb_lc_w lag_carb_lc_w fin_green econ_gdp econ_fdi {
    bysort id: ipolate `var' year, gen(i_`var') epolate
    replace `var' = i_`var' if missing(`var')
    drop i_`var'
}

* ─── 5c. Dynamic SDM estimation ───
* - lag_carb_lc_w: controls for inertia (dynamic)
* - durbin(fin_green): spatial lag of core variable only
* - W_final: symmetrised electricity transmission matrix

xsmle carb_lc_w lag_carb_lc_w fin_green econ_gdp econ_fdi, ///
    wmat(W_final) model(sdm) durbin(fin_green) fe type(ind) nolog effects

* ─── 5d. LeSage–Pace effects decomposition ───

display _n "─── LeSage–Pace Effects Decomposition ───"
display "Direct effect (fin_green):    " _b[LR_Direct:fin_green]
display "Indirect effect (spillover):  " _b[LR_Indirect:fin_green]
display "Total effect:                 " _b[LR_Total:fin_green]
display "ρ (spatial autocorrelation):  " _b[Spatial:rho]
display ""
display "Baseline FE estimate:          0.0349"
display "Total / Baseline ratio:        " %4.2f _b[LR_Total:fin_green] / 0.0349
display "→ Spatial amplification:       " %4.1f ((_b[LR_Total:fin_green]/0.0349) - 1)*100 "%"


* ============================================================
* 6. DIGITAL ECONOMY MODERATION (Table 6)
* ============================================================

display _n "═══════════════════════════════════════"
display    " SECTION 6: DIGITAL ECONOMY MODERATION"
display    "═══════════════════════════════════════"

* ─── 6a. Construct digital economy index ───

gen ln_ai       = ln(人工智能企业数 + 1)
gen ln_ecom     = ln(有电子商务交易的企业数 + 1)
gen ln_exchange = ln(数据交易所数量 + 1)
gen ln_mobile   = ln(移动用户数万户 + 1)

foreach var in ln_ai ln_ecom ln_exchange ln_mobile {
    egen std_`var' = std(`var')
}

egen dig_econ = rowmean(std_ln_ai std_ln_ecom std_ln_exchange std_ln_mobile)
label var dig_econ "Digital economy index"

* ─── 6b. Interaction model ───

gen fin_X_dig = fin_green * dig_econ
label var fin_X_dig "fin_green × dig_econ"

* Direct carbon
xtreg carb_dir fin_green dig_econ fin_X_dig $controls i.year, fe
est store mod_dir_dig

* Lifecycle carbon
xtreg carb_lc fin_green dig_econ fin_X_dig $controls i.year, fe
est store mod_lc_dig

esttab mod_dir_dig mod_lc_dig, ///
    mtitle("carb_dir" "carb_lc") ///
    keep(fin_green dig_econ fin_X_dig) ///
    b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Table 6. Digital economy moderation")


* ============================================================
* 7. DYNAMIC EFFECTS & CARBON PAYBACK (Table 7 & Figure 5)
* ============================================================

display _n "═══════════════════════════════════════"
display    " SECTION 7: CARBON PAYBACK PERIOD"
display    "═══════════════════════════════════════"

* ─── 7a. Generate lagged fin_green ───

gen L1_fin_green = L.fin_green
gen L2_fin_green = L2.fin_green
label var L1_fin_green "fin_green, one-year lag"
label var L2_fin_green "fin_green, two-year lag"

* ─── 7b. One-lag model ───

* Direct carbon
xtreg carb_dir fin_green L1_fin_green $controls i.year, fe
est store dyn_dir_1lag

* Lifecycle carbon
xtreg carb_lc fin_green L1_fin_green $controls i.year, fe
est store dyn_lc_1lag

* Cumulative effect test (one year)
lincom fin_green + L1_fin_green

* ─── 7c. Two-lag model ───

* Direct carbon
xtreg carb_dir fin_green L1_fin_green L2_fin_green $controls i.year, fe
est store dyn_dir_2lag

* Lifecycle carbon
xtreg carb_lc fin_green L1_fin_green L2_fin_green $controls i.year, fe
est store dyn_lc_2lag

* ─── 7d. Carbon payback analysis (lincom tests) ───

display _n "─── Carbon Payback Period Analysis ───"

* Re-estimate lifecycle 2-lag model for lincom
xtreg carb_lc fin_green L1_fin_green L2_fin_green $controls i.year, fe

display "Contemporaneous β₀:  " %9.4f _b[fin_green]     " (SE " %7.4f _se[fin_green] ")"
display "One-year lag β₁:     " %9.4f _b[L1_fin_green]  " (SE " %7.4f _se[L1_fin_green] ")"
display "Two-year lag β₂:     " %9.4f _b[L2_fin_green]  " (SE " %7.4f _se[L2_fin_green] ")"

display _n "Cumulative effect through one year (β₀ + β₁):"
lincom fin_green + L1_fin_green

display _n "Cumulative effect through two years (β₀ + β₁ + β₂):"
lincom fin_green + L1_fin_green + L2_fin_green

display _n "→ If cumulative ≈ 0 and p ≈ 1, carbon payback ≈ 2 years"

* ─── 7e. Export dynamic results ───

esttab dyn_dir_1lag dyn_lc_1lag dyn_dir_2lag dyn_lc_2lag, ///
    mtitle("carb_dir 1-lag" "carb_lc 1-lag" "carb_dir 2-lag" "carb_lc 2-lag") ///
    keep(fin_green L1_fin_green L2_fin_green) ///
    b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Table 7. Dynamic effects and carbon payback period")


* ============================================================
* END
* ============================================================

log close

display _n "═══════════════════════════════════════════════════"
display    " All sections complete. Tables exported to .rtf"
display    "═══════════════════════════════════════════════════"

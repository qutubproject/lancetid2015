** Master file for results replication.
** Please note that tables will be produced in "raw" form and require manual recombination and/or formatting to match the finished tables.

* Indicate the location of the Public Release folder: only this line should need to be edited by the user.

	cd "/Users/bbdaniels/GitHub/lancetid2015/"

* Load adofiles

	* These files are created by the authors for the purposes of this study and are not publicly available for general use.
	* These files are not guaranteed to produce appropriate statistics other than those contained in this replication file.

		qui do "adofiles/labelcollapse.ado"
		qui do "adofiles/freeshape.ado"
		qui do "adofiles/betterbar.ado"
		qui do "adofiles/chartable.ado"
	
	* In addition, this dofile relies on two other publicly available STATA extensions: 
		* firthlogit, in package firthlogit from http://fmwww.bc.edu/RePEc/bocode/f
		* estadd, in package st0085_2 from http://www.stata-journal.com/software/sj14-2
		* xml_tab, in package dm0037 from http://www.stata-journal.com/software/sj8-3
	
	version 13
	
************
** Tables **
************

* Table 1. Standardized patient (SP) cases and expected correct case management

	* Table 1 is not a statistical table.
	
* Table 2. Main outcomes of interactions with standardized patients
	
	use "data/sp_data.dta", clear
	
		cap mat drop results
	
		local binaries correct cxr sputum dstgx sp_drugs_tb s5_referral s4_tr11 ///
			sp_drugs_antibio sp_drugs_antibio_unlab sp_drugs_quin sp_drugs_ster
			
		qui foreach var of varlist duration sp_checklist_items essential total_price price_total_usd ///
				correct cxr sputum dstgx sp_drugs_tb s5_referral s4_tr11 ///
				n_labs sp_polypharmacy sp_drugs_antibio sp_drugs_antibio_unlab sp_drugs_quin sp_drugs_ster {
			
			cap mat drop var
			foreach caselogic in ==1 ==2 ==3 ==4 !=. {
			
				if regexm("`binaries'","`var'") count if `var'  == 1 & sp_case `caselogic'
				if regexm("`binaries'","`var'") local n = `r(N)'
					else local n = .
			
				sum `var' if sp_case `caselogic'
					if regexm("`binaries'","`var'") local mean = 100 * `r(mean)'
						else local mean = `r(mean)'
			
				if regexm("`binaries'","`var'") ci `var' if sp_case `caselogic', b wilson
					else ci `var' if sp_case `caselogic'
					
					local lower = `r(lb)'
						if regexm("`binaries'","`var'") local lower = 100 * `lower'
					local upper = `r(ub)'
						if regexm("`binaries'","`var'") local upper = 100 * `upper'
					
				mat var = nullmat(var) , [`n',`mean',`lower',`upper']
				
				}
				
			mat results = nullmat(results) \ var
			
			}
			
		local columns `" "Number" "Percentage or Mean" "Lower 95% CI" "Upper 95% CI" "'
		
		#delimit ;
		local rows `" 
			"Time with provider (min)" 
			"Number of questions and examinations" 
			"% of essential history checklist asked by provider"
			"Cost of consultation and medicines combined (Indian rupees)"
			"Cost of consultation and medicines combined (US dollars)"
			"Correctly managed the case"
			"Ordered a chest radiograph"
			"Ordered a sputum test"
			"Ordered drug susceptibility test or Xpert MTB/RIF (GeneXpert)"
			"Started patient on treatment for tuberculosis"
			"Referred the case"
			"Asked patient to return"
			"Number of laboratory tests done"
			"Number of medicines given or prescribed"
			"Gave any labelled antibiotic"
			"Gave any antibiotic"
			"Gave any fluoroquinolone"
			"Gave any steroid"
			"' ;
		#delimit cr
			
		xml_tab ///
			results ///
			using "outputs/tables.xls" ///
			, replace ///
			title("Table 2. Main outcomes of interactions with standardized patients") sheet("Table 2") ///
			rnames(`rows') ///
			showeq ceq("SP1" "SP1" "SP1" "SP1" "SP2" "SP2" "SP2" "SP2" "SP3" "SP3" "SP3" "SP3" "SP4" "SP4" "SP4" "SP4" "All" "All" "All" "All") /// 
			cnames(`columns' `columns' `columns' `columns' `columns' ) ///
			lines(COL_NAMES 3 LAST_ROW 3)  format((SCLB0) (SCCB0 NCRR2))
			
* Table 3. Know-do gap: vignettes versus interactions with standardised patient 1 among the same providers

	use "data/sp1_vignette_data.dta", clear
	cap mat drop results
	
	local binaries ///
		diagnosis antibiotics r ///
		e7 e9 e7_and_e9 e7_or_e9 e2 e3 e6 e10 e13 e14 e15 e16 e17 ///
		h1 h2 h3 h4 h5 h7 h11 h12 h17 ///
		
	foreach var of varlist ///
		diagnosis polypharmacy antibiotics r ///
		e7 e9 e7_and_e9 e7_or_e9 e2 e3 e6 e10 e13 e14 e15 e16 e17 ///
		h1 h2 h3 h4 h5 h7 h11 h12 h17 ///
		{
		
		if regexm("`binaries'","`var'") count if `var'  == 1 & type == 1
			else sum `var' if type == 1
		if regexm("`binaries'","`var'") local a = `r(N)'
			else local a = `r(mean)'
			
		sum `var' if type == 1
		if regexm("`binaries'","`var'") local b = 100 * `r(mean)'
			else local b = `r(sd)'
			
		if regexm("`binaries'","`var'") count if `var'  == 1 & type == 2
			else sum `var' if type == 2
		if regexm("`binaries'","`var'") local c = `r(N)'
			else local c = `r(mean)'
			
		sum `var' if type == 2
		if regexm("`binaries'","`var'") local d = 100 * `r(mean)'
			else local d = `r(sd)'
			
		reg `var' 2.type
			mat reg = r(table)
			matlist reg
			local e = reg[1,1]
				if regexm("`binaries'","`var'") local e = 100 * `e'
			local f = reg[5,1]
				if regexm("`binaries'","`var'") local f = 100 * `f'
			local g = reg[6,1]
				if regexm("`binaries'","`var'") local g = 100 * `g'
			local h = reg[4,1]
	
		cap logit `var' 2.type , or
			mat reg = r(table)
			matlist reg
			if regexm("`binaries'","`var'") local i = reg[1,1]
				else local i = .
			if regexm("`binaries'","`var'") local j = reg[5,1]
				else local j = .
			if regexm("`binaries'","`var'") local k = reg[6,1]
				else local k = .
			if regexm("`binaries'","`var'") local l = reg[4,1]
				else local l = .
				
			mat results = nullmat(results) \ [`a',`b',`c',`d',`e',`f',`g',`h',`i',`j',`k',`l']
			
		}
		
		local columns `" "Vignettes" "Percent/SD"  "SPs" "Percent/SD" "Difference" "Lower 95% CI" "Upper 95% CI" "P Value" "Odds Ratio" "Lower 95% CI" "Upper 95% CI" "P Value" "'
		
		#delimit ;
		local rows `" 
			"Mentioned tuberculosis"
			"Medicines given or prescribed"
			"Gave any antibiotic"
			"Referred the case"
			"Chest radiograph"
			"Sputum acid-fact bacillus test"
			"Radiograph and sputum test"
			"Radiograph or sputum test"
			"Auscultation"
			"Temperature"
			"Weight"
			"Xpert MTB/RIF (GeneXpert)"
			"HIV test"
			"Diabetes test"
			"Tuberculosis Gold test"
			"Tuberculosis ELISA test"
			"Mantoux test"
			"Duration of cough"
			"Produced sputum"
			"Past tuberculosis"
			"Family tuberculosis"
			"Blood in sputum"
			"Fever duration"
			"Loss of appetite"
			"Weight loss"
			"Taken any medicine"
			"' ;
		#delimit cr
		
		* NOTE: Cell 17J is "1" and must be manually replaced with "." due to automatic logit calculations
		
		xml_tab ///
			results ///
			using "outputs/tables.xls" ///
			, append ///
			title("Table 3. Know-do gap: vignettes versus interactions with standardised patient 1 among the same providers") sheet("Table 3") ///
			rnames(`rows') ///
			cnames(`columns') ///
			lines(COL_NAMES 3 LAST_ROW 3)  format((SCLB0) (SCCB0 NCRR2))
		
			
* Table S1. Impact of provider qualifications, provider characteristics, and SP characteristics on main standardized patient outcomes

	use "data/sp_data.dta", clear

	* Sample Restriction Logic
	
		global cxr "& sp_case <3"
		global sputum "& sp_case <3"
		global sp_drugs_tb "& sp_case >2"
		
	* Regressions

		qui foreach var of varlist correct cxr sputum s5_referral sp_drugs_tb sp_drugs_antibio sp_drugs_quin {
			preserve
			keep if 1 $`var'
			
				xi: firthlogit `var' q_mbbs pro_age pro_male patients_waiting_in sp_male sp_height sp_weight sp_age i.sp_case , or
				est sto `var'
				local lab : var label `var'
				local theCols `"`theCols' "`lab'""'
				
				sum `var'
					local mu = `r(mean)'
					estadd scalar mean = `mu' : `var'
					
				local outlist "`outlist' `var'(, or) "
					
			restore	
			}
			
	* Output
	
		xml_tab `outlist' using "outputs/tables.xls", append below p note("note: p-values reported in parentheses under odds ratios.") ///
			lines(COL_NAMES 3 LAST_ROW 3) format((SCLB0) (SCCB0 NCRR2)) cnames(`theCols') c("Constant") stats(N mean) ///
			title("Table S1. Impact of provider qualifications, provider characteristics, and SP characteristics on main standardized patient outcomes") sheet("Table S1")  ///
			keep(q_mbbs pro_age pro_male patients_waiting_in sp_male sp_height sp_weight sp_age) drop (o.*)

*************
** Figures **
*************
	
* Figure 1. Proportion of providers who completed history and physical examinations for SP1 cases (N=75 interactions)

	use "data/sp_data.dta", clear
		
	betterbar ///
		( sp1_h1 sp1_h2 sp1_h3 sp1_h4 sp1_h5 sp1_h7 sp1_h8 sp1_h9 sp1_h10 sp1_h11 sp1_h12 sp1_h13 sp1_h14 sp1_h15 sp1_h16 sp1_h17 sp1_h18 sp1_h19 sp1_h20 sp1_h21 ) ///
		( sp1_e1 sp1_e2 sp1_e3 sp1_e5 sp1_e6 ) ///
		, d(1) xlab(0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%") barl(mean) barlook(1 fc(black) lc(black))
		
		graph save   "outputs/Figure_1.gph" , replace
		graph export "outputs/Figure_1.eps" , replace
		graph export "outputs/Figure_1.png" , width(4000) replace
	
* Figure 2. Impact of provider qualifications on main standardized patient outcomes

	use "data/sp_data.dta", clear
	
	* Sample Restriction Logic
	
		global cxr "& sp_case <3"
		global sputum "& sp_case <3"
		global sp_drugs_tb "& sp_case >2"
		
	* Output
	
		chartable correct cxr sputum s5_referral sp_drugs_tb sp_drugs_antibio sp_drugs_quin ///
		using "outputs/Figure_2.xlsx" ///
		, 	c(xi: firthlogit) rhs(q_mbbs pro_age pro_male patients_waiting_in i.sp_id) or p globalif
			
		graph save   "outputs/Figure_2.gph" , replace
		graph export "outputs/Figure_2.eps" , replace
		graph export "outputs/Figure_2.png" , width(4000) replace
	
* Figure S1. Major outcomes, stratified by standardized patient case

	use "data/sp_data.dta", clear
	
	* Collapse and Reshape Data
			
		labelcollapse essential correct cxr sputum dstgx s5_referral sp_drugs_tb sp_drugs_antibio sp_drugs_quin, by(sp_case)
		freeshape essential correct cxr sputum dstgx s5_referral sp_drugs_tb sp_drugs_antibio sp_drugs_quin, i(sp_case) j(var)
	
		local x = 1
		gen order = 0
		qui foreach name in essential correct cxr sputum dstgx s5_referral sp_drugs_tb sp_drugs_antibio sp_drugs_quin {
			replace order = `x' if var_name == "`name'"
			local ++x
			}
			
	* Output

		graph dot var_value , asy over(sp_case) over(var_label, sort(order)) linegap(20) graphregion(color(white)) xsize(7) legend(region(lc(none) fc(none))) ///
			yscale(noline) ytit("") ylab(0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%") ///
			linetype(line) lines( lp(.) lc(gs11)) legend(pos(5) ring(0) c(1)  region(lc(white) fc(white))) ///
			marker(1, m(O) mlcolor(black)) ///
			marker(2, m(O) mlcolor(black)) ///
			marker(3, m(O) mlcolor(black)) ///
			marker(4, m(O) mlcolor(black)) 
			
		graph save   "outputs/Figure_S1.gph" , replace
		graph export "outputs/Figure_S1.eps" , replace
		graph export "outputs/Figure_S1.png" , width(4000) replace
		
* Figure S2-S5. Case Management for SP1-SP4

	* Figures S2-S5 are not generated automatically.
			
* Have a lovely day!

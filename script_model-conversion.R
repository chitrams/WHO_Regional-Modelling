require(nlme) | require(lme4)

# Model 1 ####
#   proc mixed data=work.testb method=reml covtest empirical;
#   title 'Stunting, Repeated, Centered year, weights, linear - Compund symmetry';
#   class unsubregio ctryname yearcen1;
#
#   model lgstic_wa= unsubregio yearcen*unsubregio /noint solution outpm=estlgst;
#   repeated yearcen1/type=cs subject=ctryname;
#   weight popweigh;
#   run;

m1.1 <- lme(WH_2 ~ UNSUBREGIO + CTRYNAME + YEAR1 - 1,
            correlation = corCompSymm(form = ~ YEAR1 | CTRYNAME),
            na.action = na.exclude, data = dat.afr, method = "REML")

# Model 2 ####
#   proc mixed data=work.testb method=reml covtest empirical;
#   title 'Stunting, Repeated, Centered year, weights, linear';
#   class unsubregio ctryname yearcen1;
#   
#   model lgstic_wa=unsubregio yearcen*unsubregio /noint solution outpm=estlgst;
#   repeated yearcen1/type=ar(1) subject=ctryname;
#   weight popweigh;
#   run;

m1.2 <- lme(WH_2 ~ UNSUBREGIO + YEAR1 + C)

# Model 3 ####
#   proc mixed data=work.testb method=reml covtest empirical;
#   title 'Stunting, Repeated, Centered year, weights, linear - Unstructure with random int and slope';
#   class unsubregio ctryname yearcen1;
#   
#   model lgstic_wa= unsubregio yearcen*unsubregio /noint solution outpm=estlgst;
#   random intercept yearcen/type=un subject=ctryname;
#   weight popweigh;
#   run;

# Model 4 ####
#   proc mixed data=work.testb method=reml covtest empirical;
#   title 'Stunting, Repeated, Centered year, weights, linear';
#   class unsubregio ctryname yearcen1;
#   
#   model lgstic_wa= unsubregio yearcen*unsubregio /noint solution outpm=estlgst;
#   random intercept/type=un subject=ctryname;
#   weight popweigh;
#   run;
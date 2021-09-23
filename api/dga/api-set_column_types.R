set_colum_types <- function(full_data){
  vFactors <- c('Merk','OlieSoort','MarkerKleur')
  
  ### Three step merge from here: (1) Index column (=UN), (2) One-hot encoded factors (3) Remaing numeric variables
  mFactors <- full_data[ , which(names(full_data) %in% vFactors)]
  # Make each character column a factor per column (else the data will summarize all columns together)
  for (k in 1:NCOL(mFactors)){
    if (k == 1){
      mOh <- mltools::one_hot(data.table::data.table(factor(mFactors[,k])))
    }else{
      mOh <- cbind(mOh,mltools::one_hot(data.table::data.table(factor(mFactors[,k]))))
    }
  }
  mNumeric <- full_data[ , -which(names(full_data) %in% vFactors)]
  mDf_xgboost <- cbind(mNumeric,as.matrix(mOh))
  return(mDf_xgboost)
}
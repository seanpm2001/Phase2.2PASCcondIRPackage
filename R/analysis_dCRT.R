#' @import data.table
#' @import dplyr
#' @import caret
#' @import glmnet
#' @import metafor
#' @import poolr
#' @import e1071
#' @import gbm
#' @import nnet

analysis_dCRT = function(summary.dcrt,
                         tt,
                         aa,
                         cc,
                         post.period,
                         comorbid,
                         siteid,
                         hosp,
                         code.kp,
                         res.out.90.final,
                         res.out.180.final,
                         res.conf.final){
  res=NULL
  if(post.period==90){
    res.out.final=res.out.90.final
  }else if(post.period==180){
    res.out.final=res.out.180.final
  }

  if(aa==1){
    summary.tmp=dplyr::filter(summary.dcrt,
                       age>18,
                       age<=49,
                       period==tt,
                       hospital_flag==hosp)
    age="18to49"
  }else if(aa==2){
    summary.tmp=filter(summary.dcrt,
                       age>49,
                       age<=69,
                       period==tt,
                       hospital_flag==hosp)
    age="49to69"
  } else{
    summary.tmp=filter(summary.dcrt,
                       age>69,
                       period==tt,
                       hospital_flag==hosp)
    age="69plus"
  }
  summary.tmp=as.matrix(summary.tmp)
  rownames(summary.tmp)=summary.tmp[,"patient_num"]

  # select comorbid combo
  pat1=tryCatch(rownames(res.conf.final)[res.conf.final[,colnames(comorbid)[1]]==comorbid[cc,1]],error=function(e){NA})
  pat2=tryCatch(rownames(res.conf.final)[res.conf.final[,colnames(comorbid)[2]]==comorbid[cc,2]],error=function(e){NA})
  pat3=tryCatch(rownames(res.conf.final)[res.conf.final[,colnames(comorbid)[3]]==comorbid[cc,3]],error=function(e){NA})

  if(sum(is.na(pat1))>0 | sum(is.na(pat2))>0  | sum(is.na(pat3))>0 ){
    return(NULL)
  }else{

  list.pat=Filter(Negate(anyNA),list(pat1,pat2,pat3))
  pat.keep=as.character(intersect(Reduce(intersect, list.pat),summary.tmp[,"patient_num"]))
  pat.keep=as.character(intersect(pat.keep,rownames(res.out.final)))
  pat.keep=as.character(intersect(pat.keep,rownames(res.conf.final)))

  #print(paste0("strata_size: ",length(pat.keep)))

  if(length(pat.keep)>100 & (0.02*length(pat.keep)<=sum(as.numeric(summary.tmp[pat.keep,"exposure"])))){

    print(paste0("strata_size: ",length(pat.keep)))

    summary.tmp=summary.tmp[pat.keep,]
    res.out.tmp=res.out.final[pat.keep,]
    res.conf.tmp=res.conf.final[pat.keep,]

    X = (res.conf.tmp)
    Z = as.matrix(res.out.tmp)

    prev_Z=apply(Z,MARGIN = 2,mean)
    index.keep.Z = names(prev_Z)[prev_Z>0.01]
    index.keep.Z=index.keep.Z[index.keep.Z %in% code.kp]

    prev_X <- colMeans(ifelse(X > 0, 1, 0))
    index.keep.X <- which(prev_X > 0.025)
    X <- X[,index.keep.X]
    X=as.matrix(X)

    for(zz in 1:length(index.keep.Z)){

      tryCatch({
        index = index.keep.Z[zz]
        index = as.character(index)
        phe.trunct=strsplit(index,"[.]")[[1]][1]

        if(sum(grepl(phe.trunct,colnames(X)))>0){
          phe.trunct=which(grepl(phe.trunct,colnames(X)))
          if(length(phe.trunct)>1){
            poo=rowSums(X[,phe.trunct])
            keep.id=rownames(X)[poo==0]
            }else{
          keep.id=rownames(X)[X[,phe.trunct]==0]
            }
          X.tmp=X[keep.id,]
          A = as.numeric(summary.tmp[keep.id,"exposure"])
          names(A)=keep.id
          Z.tmp=Z[keep.id,]
        }else{
          X.tmp=X
          A=as.numeric(summary.tmp[,"exposure"])
          names(A)=summary.tmp[,"patient_num"]
          Z.tmp=Z
        }

        ## Third filtering: down-sample Y=0 (1:10)
        id.1 = rownames(Z.tmp)[Z.tmp[,index]==1]
        set.seed(2022)
        id.2 = sample(rownames(Z.tmp)[Z.tmp[,index]==0],min(length(id.1)*10,nrow(Z.tmp)-length(id.1)))
        X.tmp=X.tmp[c(id.1,id.2),]
        Z.tmp=Z.tmp[c(id.1,id.2),]
        A=A[c(id.1,id.2)]

        tryCatch({
          # Fit conditional model for A (getting COVID-19):
          # X baseline covariates
          Cond_A <- fit_cond_Z(X.tmp, A)
          d0CRT_result <- dCRT(A = Z.tmp[,index], Z = A, X = X.tmp, mean_Z = Cond_A, model = 'Binomial_lasso',
                               k = 0, M = 7500,
                               RF.num.trees = c(100,30), MC_free = F, Gen_Z = example_Gen_Z)

          res=rbind.data.frame(res,
                               cbind.data.frame("siteid"=siteid,
                                                "method"="dCRT",
                                                "phecode"=index,
                                                "age"=age,
                                                "period"=tt,
                                                "post_period"=post.period,
                                                "hospital_flag"=hosp,
                                                "comorbid"=paste0("T2D_",comorbid[cc,1],"_obesity_",comorbid[cc,2],"_hyp_",comorbid[cc,3]),
                                                "model"="Binomial_lasso",
                                                "k"=0,
                                                "pval"=d0CRT_result$pvl,
                                                "n"=nrow(Z.tmp)))
        },error=function(e){NA})
      },error=function(e){NA})
    }
    return(res)
  }else{return(NULL)} # if statement

}

} # end of function










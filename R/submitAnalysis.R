#' Submits the results of the analytic workflow for the PASC project
#'
#' @keywords 4CE
#' @export

submitAnalysis <- function ()
{
  # workDirectory = FourCePhase2.2Data::getContainerScratchDirectory()
  # projectOutputFiles = list.files(getProjectOutputDirectory(),
  #                                 full.names = TRUE)
  # if (length(projectOutputFiles) == 0) {
  #   stop("There are no files present in ", getProjectOutputDirectory())
  # }
  # fileNameParse = lapply(X = projectOutputFiles, FUN = function(fname) {
  #   return(strsplit(x = fname, split = .Platform$file.sep,
  #                   fixed = TRUE)[[1]])
  # })
  # outputFileNames = unlist(lapply(X = fileNameParse, FUN = function(v) {
  #   return(v[length(v)])
  # }))
  # siteIds = unlist(lapply(X = strsplit(outputFileNames, split = "_"),
  #                         FUN = function(v) {
  #                           return(v[1])
  #                         }))
  # if (length(unique(siteIds)) == 0) {
  #   stop("The output files are improperly named.")
  # }
  # if (length(unique(siteIds)) > 1) {
  #   stop("There are output files for multiple sites in ",
  #        getProjectOutputDirectory())
  # }
  # siteId = unique(siteIds)
  # originalDirectory = getwd()
  # credentials = FourCePhase2.2Utilities::getGitCredentials(protocol = "https",
  #                                                          host = "github.com")
  # if (is.na(credentials[1])) {
  #   stop("There was a problem retrieving the GitHub user credentials.")
  # }
  # dataRepositoryUrl = getPublicSummaryRepositoryUrl()
  # repositoryName = gsub(x = gsub(x = dataRepositoryUrl, pattern = "https://github.com/covidclinical/",
  #                                fixed = TRUE, replacement = ""), pattern = ".git", fixed = TRUE,
  #                       replacement = "")
  # localRepositoryDirectory = file.path(workDirectory, repositoryName)
  # system(paste0("git clone ", dataRepositoryUrl, " ", localRepositoryDirectory))
  # setwd(localRepositoryDirectory)
  # branchName = paste0("topic-", siteId)
  # branches = system(paste0("git branch -a"), intern = TRUE)
  # branchIx = grep(branches, pattern = paste0("origin/", branchName),
  #                 fixed = TRUE)
  # if (length(branchIx) == 1) {
  #   system(paste0("git checkout ", branchName))
  # }
  # else {
  #   system(paste0("git branch ", branchName))
  #   system(paste0("git checkout ", branchName))
  #   system(paste0("git push --set-upstream origin ", branchName))
  # }
  # for (i in 1:length(projectOutputFiles)) {
  #   system(paste0("cp ", projectOutputFiles[i], " ./", outputFileNames[i]))
  #   system(paste0("git add ", outputFileNames[i]))
  # }
  # system(paste0("git -c user.email=\"4CE@i2b2transmart.org\" -c user.name=\"4CE Consortium\" commit -m \"added ",
  #               siteId, " result files \""))
  # system(paste0("git push"))
  # setwd(originalDirectory)
}

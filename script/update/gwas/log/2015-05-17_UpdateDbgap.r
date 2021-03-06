library(devtools);
install_github("zhezhangsh/rchive");
library(rchive);

cat('Downloading dbGaP analyses\n');
meta<-DownloadDbGap();
cat('Retrieve dbGaP p values\n');
RetrieveDbGapStat(rownames(meta), meta[,'study'], stat.name='p value');
cat('Summarize dbGaP metadata\n');
SummarizeDbGap(meta);

cat('Update log\n');
UpdateLog(meta, paste(Sys.getenv("RCHIVE_HOME"), 'data/gwas/public/dbgap', sep='/'));

tm<-strsplit(as.character(Sys.time()), ' ')[[1]][1];
fn0<-paste(RCHIVE_HOME, 'source/update/gwas/UpdateDbgap.r', sep='/');
fn1<-paste(RCHIVE_HOME, '/source/update/gwas/log/', tm, '_UpdateDbgap.r' , sep='');
file.copy(fn0, fn1)

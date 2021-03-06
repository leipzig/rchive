library(devtools);
install_github("zhezhangsh/rchive");
library(rchive);

##################################################################################################################################
path<-paste(Sys.getenv("RCHIVE_HOME"), 'data/gene/public/gtf/r', sep='/');
path.chr<-paste(Sys.getenv("RCHIVE_HOME"), 'data/assembly/public/chromosome/r/', sep='/');

options(stringsAsFactors=FALSE);

# Genome and version
if (exists('genome')) rm(genome);
#genome.version<-'human_GRCh37';
#chromosome.version<-'GRCh37.p13';
#library(BSgenome.Hsapiens.UCSC.hg19);
genome.version<-'human_GRCh38';
chromosome.version<-'GRCh38.p2';
library(BSgenome.Hsapiens.NCBI.GRCh38);
genome<-Hsapiens;

# previous processed chromosome to chromosome mapping and chromosome sets of the same assebly
chr2chr<-readRDS(paste(path.chr, 'human_chromosome_mapping_indexed.rds', sep='/'));
chr.set<-readRDS(paste(path.chr, 'human_chromosome_sets.rds', sep='/'));
chr.set<-names(chr.set[[chromosome.version]]);

seqnames(genome)<-MapChromosome(seqnames(genome), chr.set, chr2chr);
##################################################################################################################################

# previously processed transcript to intron mapping
fn<-dir(path);
fn<-fn[grep('_tx2ex.rds$', fn)];
fn<-fn[grep(genome.version, fn)];
src.nm<-sub('_tx2ex.rds', '', sub(paste(genome.version, '_', sep=''), '', fn));
fn<-paste(path, fn, sep='/');

# transcript to intron mapping
mp<-lapply(fn, readRDS);
names(mp)<-src.nm;
mp<-mp[!is.na(mp) & !is.null(mp)];
mp<-mp[sapply(mp, function(mp) !is.null(mp[[3]]))]
#tx2in<-lapply(mp, function(mp) mp$transcript2intron);
#tx2in<-tx2in[!is.null(tx2in)];
tx2in<-lapply(mp, function(mp) { print(length(mp[[3]]));
  t2i<-mp$transcript2intron;
  names(t2i)<-mp[[1]][names(t2i)]$transcript_id;
  tx.id<-rep(names(t2i), elementLengths(t2i));
  t2i<-unlist(t2i);
  t2i$tx_id<-tx.id;
  #seqlevels(t2i); 
  RenameSeqlevels(t2i, chr.set, chr2chr);
});

introns<-CombineIntron(tx2in, genome);
saveRDS(introns, file=paste(path, '/', genome.version, '_all_introns.rds', sep=''));

##############################################################################################################
tm<-strsplit(as.character(Sys.time()), ' ')[[1]][1];
fn0<-paste(Sys.getenv("RCHIVE_HOME"), 'source/update/gene/UpdateIntron.r', sep='/');
fn1<-paste(Sys.getenv("RCHIVE_HOME"), '/source/update/gene/log/', tm, '_', '_UpdateIntron_', genome.version, '.r' , sep='');
file.copy(fn0, fn1)


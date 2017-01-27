import BIDMat.{CMat,CSMat,DMat,Dict,IDict,FMat,FND,GDMat,GMat,GIMat,GSDMat,GSMat,HMat,Image,IMat,Mat,SMat,SBMat,SDMat}
import BIDMat.MatFunctions._
import BIDMat.SciFunctions._
import BIDMat.Solvers._
import BIDMat.JPlotting._
import BIDMach.Learner
import BIDMach.models.{FM,GLM,KMeans,KMeansw,ICA,LDA,LDAgibbs,NMF,RandomForest,SFA}
import BIDMach.datasources.{MatSource,FileSource,SFileSource}
import BIDMach.mixins.{CosineSim,Perplexity,Top,L1Regularizer,L2Regularizer}
import BIDMach.updaters.{ADAGrad,Batch,BatchNorm,IncMult,IncNorm,Telescoping}
import BIDMach.causal.{IPTW}

Mat.checkMKL
Mat.checkCUDA
Mat.setInline
if (Mat.hasCUDA > 0) GPUmem

var dir = "../data/rcv1/"
tic
val train = loadSMat(dir+"docs.smat.lz4")
val cats = loadFMat(dir+"cats.fmat.lz4")
val test = loadSMat(dir+"testdocs.smat.lz4")
val tcats = loadFMat(dir+"testcats.fmat.lz4")
toc

//var dir = "../data/m10-flights
//tic
//val train = loadSMat(dir+"train.smat.lz4")
//val tcats = loadFMat(dir+"test.fmat.lz4")
//toc

val (mm, opts) = GLM.learner(train, cats, GLM.logistic)

opts.lrate=0.3f

opts.npasses=0
//opts.npasses=2
mm.train

val (pp, popts) = GLM.predictor(mm.model, test)
tic
pp.predict
toc

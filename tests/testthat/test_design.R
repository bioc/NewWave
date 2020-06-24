context("Test newModel class and methods.")
set.seed(1234)


test_that("newFit works with genewise dispersion", {
  bio <- gl(2, 3)
  counts <- matrix(rpois(60, lambda=5), nrow=10, ncol=6)
  m <- newFit(counts, X=model.matrix(~bio), commondispersion = TRUE)
  m <- newFit(counts, X=model.matrix(~bio), commondispersion = FALSE)
  m <- newFit(counts, X=model.matrix(~bio), verbose = TRUE)
})

test_that("newFit stops if one gene has only 0 counts", {
  counts <- matrix(rpois(60, lambda=5), nrow=10, ncol=6)
  counts <- rbind(counts, rep(0, ncol(counts)))
  expect_error(newFit(counts), "only 0 counts")
})

test_that("newFit stops if one sample has only 0 counts", {
  counts <- matrix(rpois(60, lambda=5), nrow=10, ncol=6)
  counts <- cbind(counts, rep(0, nrow(counts)))
  expect_error(newFit(counts), "only 0 counts")
})

test_that("newFit works without X and V", {
  counts <- matrix(rpois(60, lambda=5), nrow=10, ncol=6)
  m1 <- newFit(counts, X = matrix(0, ncol=1, nrow=ncol(counts)))
  m2 <- newFit(counts, V = matrix(0, ncol=1, nrow=nrow(counts)))
  m3 <- newFit(counts, X = matrix(0, ncol=1, nrow=ncol(counts)),
                V = matrix(0, ncol=1, nrow=nrow(counts)))
  
  expect_equal(sum(as.vector(m1@beta)), 0)
  expect_equal(sum(as.vector(m2@gamma)), 0)
  expect_equal(sum(as.vector(m3@beta)), 0)
  expect_equal(sum(as.vector(m3@gamma)), 0)
  
})

test_that("newFit gives the same results with matrix and SE", {
  counts <- matrix(rpois(60, lambda=5), nrow=10, ncol=6)
  se <- SummarizedExperiment(counts)
  
  m1 <- newFit(counts)
  m2 <- newFit(se)
  expect_equal(m1, m2)
})

test_that("newFit gives the same results with matrix and formula", {
  counts <- matrix(rpois(60, lambda=5), nrow=10, ncol=6)
  bio <- gl(2, 3)
  gcc <- rnorm(10)
  se <- SummarizedExperiment(counts, colData=data.frame(Bio=bio),
                             rowData=data.frame(GCC=gcc))
  
  m1 <- newFit(se, X = model.matrix(~bio))
  m2 <- newFit(se, X = "~Bio")
  expect_equivalent(m1, m2)
  
  m3 <- newFit(se, V = model.matrix(~gcc))
  m4 <- newFit(se, V = "~GCC")
  expect_equivalent(m3, m4)
  
  # misstyping
  expect_error(newFit(se, V = "~gc"), "V must be a matrix or a formula")
  
  # colData / rowData missmatch
  expect_error(newFit(se, V = "~BIO"), "V must be a matrix or a formula")
  
})

test_that("zinbFit works with K=0", {
  counts <- matrix(rpois(60, lambda=5), nrow=10, ncol=6)
  m <- newFit(counts, K = 0)
  expect_equal(dim(getW(m)), c(nSamples(m), nFactors(m)))
})

test_that("zinbSim works", {
  a <- newmodel(n=5, J=10)
  sim <- newSim(a)
  
  expect_true(all(.is_wholenumber(sim$counts)))
  expect_true(all(.is_wholenumber(sim$dataNB)))
  expect_true(all(.is_wholenumber(sim$dataDropouts)))
})

test_that("getMu and getPi have the right dimensions", {
  bio <- gl(2, 3)
  counts <- matrix(rpois(60, lambda=5), nrow=10, ncol=6)
  m <- newFit(counts, X=model.matrix(~bio), commondispersion = TRUE)
  
  expect_equal(dim(getMu(m)), c(nSamples(m), nFeatures(m)))
  expect_equal(dim(getLogMu(m)), c(nSamples(m), nFeatures(m)))
  expect_equal(dim(getW(m)), c(nSamples(m), nFactors(m)))
  expect_equal(length(getTheta(m)), nFeatures(m))
  expect_equal(length(getZeta(m)), nFeatures(m))
})

test_that("Initialization works", {
  
  ## no arguments specified
  newmodel()
  
  ## specify W
  mat <- matrix(rnorm(10), ncol=2)
  m <- newmodel(W = mat)
  expect_equal(nSamples(m), nrow(mat))
  
  ## specify X
  m <- newmodel(X = mat)
  expect_equal(nSamples(m), nrow(mat))
  
  ## specify V
  m <- newmodel(V = mat)
  expect_equal(nFeatures(m), nrow(mat))
  
  
  ## specify empty X
  m <- newmodel(X = matrix(0, ncol=0, nrow=10))
  expect_equal(nSamples(m), 10)
  
  ## specify empty V
  m <- newmodel(V = matrix(0, ncol=0, nrow=10))
  expect_equal(nFeatures(m), 10)
  
  ## specify empty X and V
  m <- newmodel(X = matrix(0, ncol=0, nrow=10),
                 V = matrix(0, ncol=0, nrow=10))
  expect_equal(nSamples(m), 10)
  expect_equal(nFeatures(m), 10)
  
})
# BidMach vs SparkR

Several tests has been made in order to compare both tools. All of them
were developed on amazon web services.
The aim was to compare how better can be the use of a GPU library than the use
of a cluster of CPUs based tools.

In this case, BidMach is the GPU based tool and Spark (by using Sparklyr conector)
is the CPU one.

## BidMach

### Logistic Regression

#### Testbed:
* 1 g2.2xlarge
* BidMach
* Dataset: RCV1-V2 (From tutorials)

#### Results

| Parameters | Train Time | Eval Time
| -----------|  --- | --- |
| BatchSize=10000 npasses=0| ERROR cuda memory allocation | -
| BatchSize=500   npasses=0|ERROR cuda memory allocation | -
| BatchSize=20000 npasses=0|ERROR cuda memory allocation| --
| BatchSize=40000 npasses=0|4.12s| 1,1s
| BatchSize=40000 npasses=2|8.73s| 0,87s

#### Testbed:
* 1 g2.8xlarge
* BidMach
* Dataset: RCV1-V2 (From tutorials)

#### Results

| Parameters | Train Time | Eval Time
| -----------|  --- | --- |
| BatchSize=10000 npasses=0 | ERROR cuda memory allocation | --
| BatchSize=500   npasses=0|ERROR cuda memory allocation | --
| BatchSize=20000 npasses=0|ERROR cuda memory allocation| --
| BatchSize=40000 npasses=0|3.12s| 0,992s
| BatchSize=40000 npasses=2|6.08s| 0,66s


#### Testbed:
* 1 p2.xlarge
* BidMach
* Dataset: RCV1-V2

#### Results

| Parameters | Train Time | Eval Time
| -----------|  --- | --- |
| BatchSize=10000 npasses=0  | ERROR cuda memory allocation | --
| BatchSize=500   npasses=0 |ERROR cuda memory allocation | 130.48s
| BatchSize=20000 npasses=0 |ERROR cuda memory allocation| 148.90s
| BatchSize=40000 npasses=0 |1,6s| 0,96s
| BatchSize=40000 npasses=2 |3,2s| 0,25s

Program output with BatchSize=10000

```
pass= 0
 2.00%, ll=-0.69315, gf=2.854, secs=0.2, GB=0.02, MB/s=90.36, GPUmem=0.928004
16.00%, ll=-0.69315, gf=9.603, secs=0.6, GB=0.13, MB/s=242.20, GPUmem=0.721118
30.00%, ll=-0.07004, gf=11.605, secs=0.9, GB=0.25, MB/s=288.28, GPUmem=0.514363
44.00%, ll=-0.06021, gf=12.609, secs=1.2, GB=0.36, MB/s=311.13, GPUmem=0.307390
58.00%, ll=-0.06213, gf=13.394, secs=1.4, GB=0.48, MB/s=329.29, GPUmem=0.100231
java.lang.RuntimeException: CUDA alloc failed out of memory
```

Program output with BatchSize=40000

```
pass= 0
10.00%, ll=-0.69316, gf=7.483, secs=0.3, GB=0.08, MB/s=262.77, GPUmem=0.917995
66.00%, ll=-0.06621, gf=16.890, secs=1.1, GB=0.54, MB/s=491.68, GPUmem=0.661874
100.00%, ll=-0.04942, gf=17.928, secs=1.6, GB=0.81, MB/s=515.77, GPUmem=0.508638
Time=1.5640 secs, gflops=17.92
```
#### Testbed:
* 1 g2.xlarge
* BidMach
* Datasets: (Flights)[http://stat-computing.org/dataexpo/]

#### Results

| Parameters | Train Time | Eval Time
| -----------|  --- | --- |
| BatchSize=40000 npasses=0 |53,18s| 6,27s
| BatchSize=40000 npasses=2 |83,18s| 4,66s

#### Testbed:
* 1 g2.8xlarge
* BidMach
* Datasets: (Flights)[http://stat-computing.org/dataexpo/]

#### Results

| Parameters | Train Time | Eval Time
| -----------|  --- | --- |
| BatchSize=40000 npasses=0 |47,22s| 5,56s
| BatchSize=40000 npasses=2 |78,8s| 3,12s

#### Testbed:
* 1 g2.8xlarge
* BidMach
* Datasets: (Flights)[http://stat-computing.org/dataexpo/]

#### Results

| Parameters | Train Time | Eval Time
| -----------|  --- | --- |
| BatchSize=40000 npasses=0 |47,22s| 5,56s
| BatchSize=40000 npasses=2 |52,31| 2,03s


## Spark-R

### Regression

#### Testbed:
* 4 r3.xlarge
* Spark-R
* Dataset: Flights (From https://github.com/beeva/data-lab/tree/master/PoC-regression-benchmark)

#### Results

| n | Train Time | Eval Time
| -----------|  --- | --- |
| 10M  | 119.76 | 22,89


#### Testbed:
* 6 g2.8xlarge
* Spark-R
* Dataset: Flights (From https://github.com/beeva/data-lab/tree/master/PoC-regression-benchmark)

#### Results

| n | Train Time | Eval Time
| -----------|  --- | --- |
| 10M  | 107.87 | 15,91


#### Testbed:
* 8 r3.xlarge
* Spark-R
* Dataset: Flights (From https://github.com/beeva/data-lab/tree/master/PoC-regression-benchmark)

#### Results

| n | Train Time | Eval Time
| -----------|  --- | --- |
| 10M  | 99.41 | 12,13

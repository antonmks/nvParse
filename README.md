# nvParse
Fast, gpu-based CSV parser


The purpose of this project is to demonstrate the possibility of parsing CSV files on gpu with very high speed, currently unreachable on general-purpose cpus. To achieve this, we use a massively parallel gpu to process the CSV files at the speed of 1.5 GB/s.
 
Almost instant loading of CSV files allows to significantly accelerate, or, in many cases, totally eliminate the database loading steps and start running the queries as soon as receiving the source data files.

About test.cu file : it parses a 750MB lineitem.tbl file from TPC-H benchmark in about half a second. You need to have an Nvidia gpu and CUDA software on your machine. You can compile the test file with the following command :
 
nvcc  -O3 -arch=sm_35 -lcuda test.cu -o test

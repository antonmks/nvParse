# nvParse
**Parsing CSV files with GPU**

Parsing delimiter-separated files is a common task in data processing. The regular way of extracting the columns from a text file is to use strtok function :

     char * p = strtok(line, "|");
	 while (p != NULL)
     {
    	printf ("%s\n",p);
    	p = strtok (NULL, "|");
  	 }

  
However this method of parsing is CPU bound because 
 
- it doesn't take advantage of multiple cores of modern CPUs.

-  memory bandwidth limitations

This is how the same task can be done using a GPU :
 
    auto break_cnt = thrust::count(d_readbuff.begin(), d_readbuff.end(), '\n');
    thrust::device_vector<int> dev_pos(break_cnt);
    thrust::copy_if(thrust::make_counting_iterator(0), thrust::make_counting_iterator(bytes_read-1),
    				d_readbuff.begin(), dev_pos.begin(), _1 == '\n');	

The first line counts the number of lines in a buffer (assuming that file is read into memory and copied to gpu buffer d\_readbuff).
The second line creates a vector in gpu memory that will hold the positions of new line characters.
The last line compares the characters in a buffer to new line character and, if match is found, copies the position of the character to dev_pos vector. 

Now that we know the starting positions of every line in a buffer, we can launch a gpu procedure that will parse the lines using several thousands gpu cores :

    thrust::counting_iterator<unsigned int> begin(0);
    parse_functor ff(...); // examples of call's parameters are in test.cu file 
    thrust::for_each(begin, begin + break_cnt, ff);

As a result we get the needed columns in separate arrays in gpu memory and can copy them to host memory. Or convert them to binary values using relevant gpu procedures :

    gpu_atoll atoll_ff(...); 
    thrust::for_each(begin, begin + break_cnt, atoll_ff); 
    

Benchmarks !

Hardware : PC with one Intel i3-4130, 16GB of RAM, one 2TB hard drive and GTX Titan

File : 750GB lineitem,tbl text file (6001215 total lines in a file)

Parsing 1 field using CPU :

$ time cut -d "|" -f 6 lineitem.tbl > /dev/null

real    0m28.764s

Parsing 11 fields using hand-written program with strtok :

14.5s 

Parsing 11 fields from the same file using GPU :

$ time ./test

real    0m1.736s

The actual gpu parsing is done in just 0.25 seconds.  


 

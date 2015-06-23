#include <thrust/device_vector.h>
#include <thrust/copy.h>
#include <thrust/count.h>
#include <ctime>
#include "nvparse.h"

#ifdef _WIN64
#define atoll(S) _atoi64(S)
#include <windows.h>
#else
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#endif

int main() {

	std::clock_t start1 = std::clock();
    FILE* f = fopen("lineitem.tbl", "r" );
    fseek(f, 0, SEEK_END);
    long fileSize = ftell(f);
    thrust::device_vector<char> dev(fileSize);
    fclose(f);
	
#ifdef _WIN64
	HANDLE file = CreateFileA("lineitem.tbl", GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, NULL);
    assert(file != INVALID_HANDLE_VALUE);

    HANDLE fileMapping = CreateFileMapping(file, NULL, PAGE_READONLY, 0, 0, NULL);
    assert(fileMapping != INVALID_HANDLE_VALUE);
 
    LPVOID fileMapView = MapViewOfFile(fileMapping, FILE_MAP_READ, 0, 0, 0);
    auto fileMapViewChar = (const char*)fileMapView;
    assert(fileMapView != NULL);

    thrust::copy(fileMapViewChar, fileMapViewChar+fileSize, dev.begin());
#else

    struct stat sb;
	char *p;
	int fd;

    fd = open ("lineitem.tbl", O_RDONLY);
	if (fd == -1) {
		perror ("open");
		return 1;
	}

	if (fstat (fd, &sb) == -1) {
		perror ("fstat");
		return 1;
	}

	if (!S_ISREG (sb.st_mode)) {
		fprintf (stderr, "%s is not a file\n", "lineitem.tbl");
		return 1;
	}

	p = (char*)mmap (0, fileSize, PROT_READ, MAP_SHARED, fd, 0);

	if (p == MAP_FAILED) {
		perror ("mmap");
		return 1;
	}

	if (close (fd) == -1) {
		perror ("close");
		return 1;
	}

	thrust::copy(p, p+fileSize, dev.begin());

#endif

    int cnt = thrust::count(dev.begin(), dev.end(), '\n');
    std::cout << "There are " << cnt << " total lines in a file" << std::endl;

    thrust::device_vector<int> dev_pos(cnt+1);
    dev_pos[0] = -1;

    thrust::copy_if(thrust::make_counting_iterator((unsigned int)0), thrust::make_counting_iterator((unsigned int)fileSize),
                    dev.begin(), dev_pos.begin()+1, is_break());

    thrust::device_vector<char> dev_res1(cnt*15);
    thrust::fill(dev_res1.begin(), dev_res1.end(), 0);
    thrust::device_vector<char> dev_res2(cnt*15);
    thrust::fill(dev_res2.begin(), dev_res2.end(), 0);
    thrust::device_vector<char> dev_res3(cnt*15);
    thrust::fill(dev_res3.begin(), dev_res3.end(), 0);
    thrust::device_vector<char> dev_res4(cnt*15);
    thrust::fill(dev_res4.begin(), dev_res4.end(), 0);
    thrust::device_vector<char> dev_res5(cnt*15);
    thrust::fill(dev_res5.begin(), dev_res5.end(), 0);
    thrust::device_vector<char> dev_res6(cnt*15);
    thrust::fill(dev_res6.begin(), dev_res6.end(), 0);
    thrust::device_vector<char> dev_res7(cnt*15);
    thrust::fill(dev_res7.begin(), dev_res7.end(), 0);
    thrust::device_vector<char> dev_res8(cnt*15);
    thrust::fill(dev_res8.begin(), dev_res8.end(), 0);
    thrust::device_vector<char> dev_res9(cnt);
    thrust::fill(dev_res9.begin(), dev_res9.end(), 0);
    thrust::device_vector<char> dev_res10(cnt);
    thrust::fill(dev_res10.begin(), dev_res10.end(), 0);
    thrust::device_vector<char> dev_res11(cnt*10);
    thrust::fill(dev_res11.begin(), dev_res11.end(), 0);

    thrust::device_vector<char*> dest(11);
    dest[0] = thrust::raw_pointer_cast(dev_res1.data());
    dest[1] = thrust::raw_pointer_cast(dev_res2.data());
    dest[2] = thrust::raw_pointer_cast(dev_res3.data());
    dest[3] = thrust::raw_pointer_cast(dev_res4.data());
    dest[4] = thrust::raw_pointer_cast(dev_res5.data());
    dest[5] = thrust::raw_pointer_cast(dev_res6.data());
    dest[6] = thrust::raw_pointer_cast(dev_res7.data());
    dest[7] = thrust::raw_pointer_cast(dev_res8.data());
    dest[8] = thrust::raw_pointer_cast(dev_res9.data());
    dest[9] = thrust::raw_pointer_cast(dev_res10.data());
    dest[10] = thrust::raw_pointer_cast(dev_res11.data());

    thrust::device_vector<unsigned int> ind(11); //fields positions
    ind[0] = 0;
    ind[1] = 1;
    ind[2] = 2;
    ind[3] = 3;
    ind[4] = 4;
    ind[5] = 5;
    ind[6] = 6;
    ind[7] = 7;
    ind[8] = 8;
    ind[9] = 9;
    ind[10] = 10;

    thrust::device_vector<unsigned int> dest_len(11); //fields max lengths
    dest_len[0] = 15;
    dest_len[1] = 15;
    dest_len[2] = 15;
    dest_len[3] = 15;
    dest_len[4] = 15;
    dest_len[5] = 15;
    dest_len[6] = 15;
    dest_len[7] = 15;
    dest_len[8] = 1;
    dest_len[9] = 1;
    dest_len[10] = 10;

    thrust::device_vector<unsigned int> ind_cnt(1); //fields count
    ind_cnt[0] = 10;

    thrust::device_vector<char> sep(1);
    sep[0] = '|';

    thrust::counting_iterator<unsigned int> begin(0);
    parse_functor ff((const char*)thrust::raw_pointer_cast(dev.data()),(char**)thrust::raw_pointer_cast(dest.data()), thrust::raw_pointer_cast(ind.data()),
                     thrust::raw_pointer_cast(ind_cnt.data()), thrust::raw_pointer_cast(sep.data()), thrust::raw_pointer_cast(dev_pos.data()), thrust::raw_pointer_cast(dest_len.data()));
    thrust::for_each(begin, begin + cnt, ff); // now dev_pos vector contains the indexes of new line characters

	std::cout<< "time0 " <<  ( ( std::clock() - start1 ) / (double)CLOCKS_PER_SEC ) << '\n';
	
    thrust::device_vector<long long int> d_int(cnt);
    thrust::device_vector<double> d_float(cnt);
    
    //check the text results in dev_res array :
    for(int i = 0; i < 100; i++)
        std::cout << dev_res9[i];
    std ::cout << std::endl;

    for(int i = 0; i < 100; i++)
        std::cout << dev_res10[i];
    std ::cout << std::endl;

    //binary integer results
    ind_cnt[0] = 15;
    gpu_atoll atoll_ff((const char*)thrust::raw_pointer_cast(dev_res3.data()),(long long int*)thrust::raw_pointer_cast(d_int.data()),
                       thrust::raw_pointer_cast(ind_cnt.data()));
    thrust::for_each(begin, begin + cnt, atoll_ff);

    for(int i = 0; i < 10; i++)
        std::cout << d_int[i] << std::endl;

    std::cout <<  std::endl;

    //binary float results
    gpu_atof atof_ff((const char*)thrust::raw_pointer_cast(dev_res6.data()),(double*)thrust::raw_pointer_cast(d_float.data()),
                     thrust::raw_pointer_cast(ind_cnt.data()));
    thrust::for_each(begin, begin + cnt, atof_ff);

    std::cout.precision(10);
    for(int i = 0; i < 10; i++)
        std::cout << d_int[i] << std::endl;
		

    return 0;

}

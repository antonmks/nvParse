struct is_break
{
 __host__ __device__
 bool operator()(const char x)
 {
   return x == 10;
 }
};

struct gpu_date
{
	const char *source;
    long long int *dest;
		
	gpu_date(const char *_source, long long int *_dest):
			  source(_source), dest(_dest) {}
    template <typename IndexType>
    __host__ __device__
    void operator()(const IndexType & i) {	std ::cout << std::endl;
		const char *s;
		long long int acc;
		int z = 0, c;
		
		s = source + 10*i;		
		c = (unsigned char) *s++;

		for (acc = 0; z < 10; c = (unsigned char) *s++) {
			if(c != '-') {
				c -= '0';
				acc *= 10;
				acc += c;
			};	
			z++;		
		}		
		dest[i] = acc;	
	}
};	


struct gpu_atof
{
	const char *source;
    double *dest;
	const unsigned int *len;
	
	gpu_atof(const char *_source, double *_dest, const unsigned int *_len):
			  source(_source), dest(_dest), len(_len) {}
    template <typename IndexType>
    __host__ __device__
    void operator()(const IndexType & i) {	
		const char *p;
		int frac;
		double sign, value, scale;	
		
		p = source + len[0]*i;		
		
    	while (*p == ' ') {
			p += 1;
		}
    
		sign = 1.0;
		if (*p == '-') {
			sign = -1.0;
			p += 1;
		} else if (*p == '+') {
			p += 1;
		}
		
		for (value = 0.0; *p >= '0' && *p <= '9'; p += 1) {
			value = value * 10.0 + (*p - '0');
		}

        if (*p == '.') {
			double pow10 = 10.0;
			p += 1;
			while (*p >= '0' && *p <= '9') {
				value += (*p - '0') / pow10;
				pow10 *= 10.0;
				p += 1;
			}
		}
		
		frac = 0;
		scale = 1.0;
		
		dest[i] = sign * (frac ? (value / scale) : (value * scale));		
	}
};	


struct gpu_atoll
{
	const char *source;
    long long int *dest;
	const unsigned int *len;
	
	gpu_atoll(const char *_source, long long int *_dest, const unsigned int *_len):
			  source(_source), dest(_dest), len(_len) {}
    template <typename IndexType>
    __host__ __device__
    void operator()(const IndexType & i) {	
		const char *s;
		long long int acc;
		int c;
		int neg;						
		
		s = source + len[0]*i;		
	
		do {
			c = (unsigned char) *s++;
		} while (c == ' ');				
		
		if (c == '-') {
			neg = 1;
			c = *s++;
		} else {
			neg = 0;
			if (c == '+')
				c = *s++;
		}		
		
		for (acc = 0;; c = (unsigned char) *s++) {
			if (c >= '0' && c <= '9')
				c -= '0';
			else
				break;
			if (c >= 10)
				break;	
			if (neg) {
				acc *= 10;
				acc -= c;
			} 
			else {
				acc *= 10;
				acc += c;
			}		
		}		
		dest[i] = acc;	
	}
};
   
struct parse_functor
{
	const char *source;
    char **dest;
    const unsigned int *ind;
	const unsigned int *cnt;
	const char *separator;
	const int *src_ind;
	const unsigned int *dest_len;

    parse_functor(const char* _source, char** _dest, const unsigned int* _ind, const unsigned int* _cnt, const char* _separator,
				  const int* _src_ind, const unsigned int* _dest_len):
        source(_source), dest(_dest), ind(_ind), cnt(_cnt),  separator(_separator), src_ind(_src_ind), dest_len(_dest_len) {}

    template <typename IndexType>
    __host__ __device__
    void operator()(const IndexType & i) {
		unsigned int curr_cnt = 0, dest_curr = 0, j = 0, t, pos;
		pos = src_ind[i]+1;
		
		while(dest_curr < *cnt) {
			if(ind[dest_curr] == curr_cnt) { //process				
				t = 0;
				while(source[pos+j] != *separator) {
					if(source[pos+j] != 0) {
						dest[dest_curr][dest_len[dest_curr]*i+t] = source[pos+j];
						t++;
					};	
					j++;					
				};
				j++;
				dest_curr++;				
			}
			else {
				while(source[pos+j] != *separator) {
					j++;
				};	
				j++;
			};
			curr_cnt++;
		}
    }
};
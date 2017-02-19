#include "schema1.h"

#include <cstdlib>
#include <cassert>
#include <cstring>
#include <iostream>
#include <chrono>
#include <ctime>

auto main(int argc, char *argv[]) -> int
{
    int random_variable{0};

    std::chrono::time_point<std::chrono::system_clock> start, end;
    start = std::chrono::system_clock::now();

///
    KeyValue kv;
///
    for( size_t i = 0; i < 1000; ++i )
    {
        std::srand(std::time(0));
        random_variable = std::rand();

        kv.setIntvalue(random_variable);
        
        kv.setDoublevalue(random_variable/RAND_MAX);

        std::cout << "Size = " << kv.toBinary().size << std::endl;
    }
///

    end = std::chrono::system_clock::now();
    std::chrono::duration<double> elapsed_seconds = end-start;
    std::time_t end_time = std::chrono::system_clock::to_time_t(end);

    std::cout << "Elapsed time = " << elapsed_seconds.count() << " sec\n";

    return 0;
}

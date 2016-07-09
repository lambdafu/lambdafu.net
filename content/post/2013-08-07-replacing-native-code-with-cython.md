---
title: Replacing native code with Cython
author: Marcus
date: 2013-08-07T03:32:50+00:00
url: /2013/08/07/replacing-native-code-with-cython/
categories:
  - Programming
tags:
  - Cython
  - euclidian distance
  - numpy
  - ocropus
  - optimization
  - parallel programming
  - performance
  - Python
  - scipy

---
Here is a little exercise in rewriting native code with [Cython][1] while not losing performance. It turns out that this requires pulling out all the stops and applying a lot of optimization magic provided by Cython. On the other hand, the resulting code is portable to Windows without worrying about compilers etc.

## A real world example

The example code comes from a real world project, [OCRopus][2], a wonderful collection of OCR tools that uses latest algorithms in machine learning (such as deep learning) to transform images to text. In `ocropy/ocrolib/distance.py`, the authors of OCRopus implement the function `cdist`, which calculates the Euclidian distances D(na,nb) between all d-dimensional vectors that are the rows of two matrices A(na, d) and B(nb, d). D(i,j) is the distance of vector A(i) and B(j). This function is also provided as [`scipy.spatial.distance.cdist`][3], but that implementation is limited to a single thread, while the OCRopus version supports OpenMP and thus can run faster on several cores.

```python
cdist_native_c = r'''
#include <math.h>
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <omp.h>

int maxthreads = 1;

void cdist(int d,int na,int nb,float a[na][d],float b[nb][d],float result[na][nb]) {
    int n = na*nb;
#pragma omp parallel for num_threads (maxthreads)
    for(int job=0;job<n;job++) {
        int i = job/nb;
        int j = job%nb;
        double total = 0.0;
        for(int k=0;k<d;k++) {
            float delta = a[i][k]-b[j][k];
            total += delta*delta;
        }
        result[i][j] = sqrt(total);
    }
}
'''
```

If we run the above code on arrays A(1000, 100) and B(800, 100), we get the resulting distance matrix D(1000, 800) in 44ms on a quadcore Q9550 processor, while SciPy's cdist function takes 67ms on a single core. Sure, the [speedup][4] is not linear by any means, which shows how brutally efficient NumPy's vectorization strategies are &#8211; so either the OCRopus team has more powerful hardware than I do, or they decided that the reduced wall time is well worth the loss in overall efficiency.

## Cython to the rescue

Unfortunately, OCRopus' home-baked native code compiler is not very portable, so we would like to use Cython instead, which conveniently has support for NumPy arrays and OpenMP built in. Cython compiles (possibly annotated) Python code to C code, so we start with a slightly different implementation of the above (a first version of the code had `a[i][k]` etc. to access the matrix elements. That was so horrible that I didn't even try to measure the slowness):

```python
import numpy as py
def native_cdist(a, b, out):
    na = a.shape[0]
    nb = b.shape[0]
    d = a.shape[1]
    for i in range(na):
        for j in range(nb):
            total = 0
            for k in range(n):
                value = a[i,k] - b[j,k]
                total = total + value * value
            out[i,j] = np.sqrt(total)
```

The code is similar to the native code in that it does not make use of any vectorization in NumPy. Also, because we didn't use any type annotations, Cython can not perform any optimizations. The performance is consequently very bad at 10s, 150 times slower than SciPy. A few simple type annotations help a lot:

```python
import numpy as np
cimport numpy as np
DTYPE = np.float32
ctypedef np.float32_t DTYPE_t

cdef native_cdist(np.ndarray[DTYPE_t, ndim=2] a, np.ndarray[DTYPE_t, ndim=2] b, np.ndarray[DTYPE_t, ndim=2] out): 
    cdef Py_ssize_t na, nb, n, job, d, i, j, k
    cdef DTYPE_t total, value

    na = a.shape[0]
    nb = b.shape[0]
    n = a.shape[1]
    for i in range(na):
        for j in range(nb):
            total = 0
            for k in range(n):
                value = a[i, k] - b[j, k]
                total = total + value * value
            out[i, j] = np.sqrt(total)
```

This helps tremendously, and the execution time is now down to 130ms, which gets us within a factor of 2 of SciPy's code. The HTML report of Cython informs us that we are still using Python code in the array access and in the `sqrt` function. Let's deal with the latter first:

```python
cdef extern from "math.h":
    double sqrt(double x) nogil
```

These statements import the C function `sqrt`, which avoids a round-trip through Python, saving a whopping 2ms (because `sqrt` is not called in the most inner loop), and we are at 128ms. Before worrying about the NumPy array access, let's pick some low-hanging fruit:

```python
@cython.boundscheck(False)
@cython.wraparound(False)
```

Disabling bound checking reduces runtime to 95ms, and disabling negative array indices (which we don't use) reduces it again to 73ms. We have not quite matched SciPy's performance, but we are getting there. Really, the only thing left to do is to optimize the array access. To do this, we have to move on to the newer [memoryview][5] interface of Cython, that allows us a more precise definition of what an array looks like:

```python
cdef void native_cdist(DTYPE_t [:, :] a, DTYPE_t [:, :] b, DTYPE_t [:, :] out):
    pass
```

Alas, we can not measure any performance gain. The reason is that we have not told Cython yet what kind of restrictions we want to enforce on the array. In C, a 2-dimensional array uses a contiguous chunk of memory, and `a[i][j]` is found by calculating `i * d + j`. The _strides_ (offset between elements along an axis) in this case are (d, 1), because there are d elements from one row to another, and there is 1 element from one column to another. In this case (C), the stride for the k-th axis is just the product of the dimensions of the axes 1 to k-1. But in Python, slicing operations can create different stride layouts, allowing zero-copy access to the slice:

```python
aa = np.arange(60).reshape(5,4,3)
array(aa.strides)/aa.itemsize # Out: array([12,  3,  1])
a = aa[:,:,1]
array(a.strides)/a.itemsize # Out: array([12,  3])
```

If we can assume that the input matrices to our function do not make use of this feature, we can tell Cython to use native C array access to the data, which saves one multiplication for every access:

```python
cdef void native_cdist(DTYPE_t [:, ::1] a, DTYPE_t [:, ::1] b, DTYPE_t [:, ::1] out):
    pass
```

This now gives us a single-threaded execution time of 66ms, which is equivalent to SciPy's cdist implementation.

## Making it parallel

To make use of several threads, and thus to match the performance of the OCRopus implementation, we need a GIL-free version of the above code (the GIL is the global interpreter lock that ensures that only a single thread is running in the Python interpreter at any time). Luckily, the above optimizations, in particular the move to the memoryview interface, made our code GIL-free automatically, we just have to declare it thus by appending `nogil` to the function prototype:

```python
cdef void native_cdist(DTYPE_t [:, ::1] a, DTYPE_t [:, ::1] b, DTYPE_t [:, ::1] out) nogil:
    pass
```

We are now ready to use the `cython.parallel.prange` function to run the outer loops in parallel. To do this in an optimal way, we rewrite the two outer loops in the same way the OCRopus code does it:

```python
import numpy as np
cimport numpy as np
cimport cython
from cython.parallel import prange
DTYPE = np.float32
ctypedef np.float32_t DTYPE_t
cdef extern from "math.h":
    double sqrt(double x) nogil

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void native_cdist(DTYPE_t [:, ::1] a, DTYPE_t [:, ::1] b, DTYPE_t [:, ::1] out) nogil:
    cdef Py_ssize_t na, nb, n, job, d, i, j, k
    cdef DTYPE_t total, value

    na = a.shape[0]
    nb = b.shape[0]
    n = na * nb
    d = a.shape[1]
    for job in prange(n):
        i = job / nb;
        j = job % nb;
        total = 0
        for k in range(d):
            value = a[i,k] - b[j,k]
            total = total + value * value
        out[i,j] = sqrt(total)
```

When I ran this code, I was surprised: Although it used four cores alright, it actually ran 76ms, slower than the single-core version. The HTML view in Cython revealed that the division and modulo operators made use of Python code. That makes sense, as these operators behave quite differently in Python than in C. Luckily, there is a pragma available to change them to the default C operators:

```python
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision
cdef void native_cdist(DTYPE_t [:, ::1] a, DTYPE_t [:, ::1] b, DTYPE_t [:, ::1] out) nogil:
     pass
```

With this change, the performance increased to 38ms, which is even faster than the native version in OCRopus by 10%, a resounding success!

**Update:** The improvement over native code is revealed by comparing the generated assembler code in each case: I used single-precision float for the `total` variable, while the OCRopus implementation above uses `double`. Changing the type in the Cython code brings the performance down to 45ms, which is a 3% slow-down compared OCRopus. Some minor differences remain, which would require even closer scrutiny to figure out.

## Testing

Here are the complete source files:

```python
# cdist.pyx
import numpy as np
cimport numpy as np
cimport cython
from cython.parallel import prange
DTYPE = np.float32sudo cat /sys/devices/system/cpu/cpu?/cpufreq/cpuinfo_cur_freq
ctypedef np.float32_t DTYPE_t
cdef extern from "math.h":
    double sqrt(double x) nogil

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void native_cdist(DTYPE_t [:, ::1] a, DTYPE_t [:, ::1] b, DTYPE_t [:, ::1] out) nogil:
    cdef Py_ssize_t na, nb, n, job, d, i, j, k
    cdef DTYPE_t total, value

    na = a.shape[0]
    nb = b.shape[0]
    n = na * nb
    d = a.shape[1]
    for job in prange(n):
        i = job / nb;
        j = job % nb;
        total = 0
        for k in range(d):
            value = a[i,k] - b[j,k]
            total = total + value * value
        out[i,j] = sqrt(total)

def cdist(a not None, b not None, out=None):
    # Some additional sanity checks from OCRopus are missing here.
    assert a.dtype == DTYPE and b.dtype == DTYPE
    if out is None:
        out = np.zeros((len(a),len(b)), dtype=DTYPE)
    native_cdist(a,b,out)
    return out

```python
# cdist.pyxbld
def make_ext(modname, pyxfilename):
    from distutils.extension import Extension
    return Extension(name=modname,
                     sources=[pyxfilename],
                     extra_link_args=['-fopenmp'],
                     extra_compile_args=['-fopenmp'])
```

```python
import pyximport
pyximport.install()
import cdist
from pylab import *
a = array(randn(1000,100),'f')
b = array(randn(800,100),'f')
o1 = cdist.cdist(a, b)
from scipy.spatial.distance import cdist as scipy_cdist
o2 = scipy_cdist.cdist(a, b)
amin(o1-o2)
amax(o1-o2)
```

 [1]: http://cython.org
 [2]: http://code.google.com/p/ocropus/
 [3]: http://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.distance.cdist.html
 [4]: http://en.wikipedia.org/wiki/Speedup
 [5]: http://docs.cython.org/src/userguide/memoryviews.html
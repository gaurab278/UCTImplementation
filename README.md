# UCTImplementation

This repository is an implementation of the UCT algorithm on a multi-armed bandit problem. 

The Implementation of the algorithm is based off of the POMCP algorithm with modification to 
work on MDPs. 


Note: Python Code is working just fine 

Currently having trouble importing cython modules into the main UCT module.
Have properly cythonized env and node, they compile just fine -> getting import/compilation errors when trying to do the same withUCT


With what I have in UCT, I am just trying to initialize so far but keep getting the following errors: 
C:\Users\Gaurab Pokharel\Anaconda3\envs\tf\lib\site-packages\numpy\core\include\numpy\npy_1_7_deprecated_api.h(14) : Warning Msg: Using deprecated NumPy API, disable it with #define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION

UCT.c(1459): error C2061: syntax error: identifier '__pyx_ctuple___dunderpyx_ctuple_int__dunderand_int__and_double__and_int'
UCT.c(1460): error C2143: syntax error: missing ')' before '*'
UCT.c(1460): error C2143: syntax error: missing '{' before '*'
UCT.c(1460): error C2059: syntax error: ')'
UCT.c(1463): error C2059: syntax error: '}'
UCT.c(2875): error C2037: left of 'action_space' specifies undefined struct/union '__pyx_vtabstruct_3env_Env'
UCT.c(2924): error C2037: left of 'getState' specifies undefined struct/union '__pyx_vtabstruct_3env_Env'
UCT.c(2965): warning C4244: 'function': conversion from 'unsigned __int64' to 'double', possible loss of data
error: command 'C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.24.28314\\bin\\HostX86\\x64\\cl.exe' failed with exit status 2
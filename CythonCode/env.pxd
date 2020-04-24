
"""
Defines the domain on which the agent works 

@Author: Gaurab Pokharel  

"""
import numpy as np 
cimport numpy as np 
cimport cython  
import random 


#Some Global Static Variables 
cdef double WINWARD = 1.00  
cdef double LOSEWARD = -1.00 
cdef (int, int) START = (2,0)
cdef double REWARD = -0.04
cdef int BOARD_ROWS = 3
cdef int BOARD_COLS = 4
cdef (int, int) WIN_STATE = (0, 3)
cdef (int, int) LOSE_STATE = (1, 3)


cdef class Env(): 
    #Attributes 
    cdef np.int32_t[:, :] board 
    # cdef np.ndarray[np.int32_t, ndim=2] board
    cdef (int, int) state 
    cdef bint isTerminal
    

    
    
    #Functions
    cpdef void reset(self)
    cdef double giveReward(self)
    cdef void isEnd(self)
    cpdef bint IsTerminal(self)
    cdef bint isValidAction(self, (int, int) state, int action)
    cdef bint isValid(self, (int, int) nxtState)
    cpdef (int, int) getState(self)
    cdef void step(self, int action)
    cpdef void debuggerstep(self, int action)
    cdef list actionspace(self)
    cpdef void showBoard(self)
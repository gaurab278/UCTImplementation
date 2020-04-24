
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


cdef class Env: 
    #Attributes 
    cdef np.int32_t[:, :] board 
    # cdef np.ndarray[np.int32_t, ndim=2] board
    cdef (int, int) state 
    cdef bint isTerminal

    
    
    #Functions
    cdef bint reset(self)
    cdef double giveReward(self)
    cdef void isEnd(self)
    cdef bint IsTerminal(self)
    cdef bint isValidAction(self, (int, int) state, int action)
    cdef bint isValid(self, (int, int) nxtState)
    cdef (int, int) getState(self)
    cdef ((int, int), double, bint) step(self, int action)
    cdef ((int, int), double, bint) debuggerstep(self, int action)
    cdef list action_space(self)
    cdef void showBoard(self)
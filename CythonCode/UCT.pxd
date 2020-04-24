"""
Defines the Main UCT function  

@author: Gaurab Pokharel
"""


import random, time
from env import Env 
from node import StateNode 
from node import ActionNode
from math import sqrt, log 




from node cimport StateNode 
from node cimport ActionNode
from env cimport Env

cdef double GAMMA = 0.90
cdef double EXPLORATION_CONSTANT =sqrt(2)
cdef int TIME =10
cdef unsigned long long NEWREWARD = 100000000000000






cdef class UCT: 
     
    #Attributes 
    cdef Env env  
    cdef list action_space 
    cdef StateNode root 
    
    #Functions 
    cdef list MakeActionSpace(self, Env env)
    cdef StateNode makeroot(self, Env env)
    # cdef StateNode getroot(self)
    # cdef double _rollout_(self,Env env, double gamma)
    # cdef double rollout(self, StateNode node)
    # cdef StateNode Expand(self, StateNode node)
    # cdef double ExplorationTerm(self, (int, int) state, int action, double expCons)
    # cdef ActionNode bestaction(self, StateNode node, double expCons)
    # cdef void UpdateReward(self, ActionNode node, double rwrd)
    # cdef double simulate (self, StateNode stateNode, int depth)
    # cdef ActionNode search(self)
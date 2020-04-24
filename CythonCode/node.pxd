# -*- coding: utf-8 -*-
"""
Created on Fri Apr 24 02:35:52 2020

@author: Gaurab Pokharel
"""
import random 
cdef unsigned long long NEWREWARD = 100000000000000

cdef class StateNode(): 
    
    #Attributes 
    cdef (int, int) state 
    cdef int action 
    cdef ActionNode parent  
    cdef list children 
    cdef list action_space
    cdef list untriedActions
    cdef int numVisits 
    cdef double reward 
    cdef bint root 
    cdef bint isterminal
    
    #Functions 
    cdef void SetRoot(self) 
    cdef bint IsRoot(self)
    cdef int GetParentAction(self) 
    cpdef (int, int) GetState(self) 
    cdef bint IsAction(self) 
    cdef bint IsState(self) 
    cdef ActionNode GetParent(self) 
    cdef list GetChildren(self) 
    cdef void AddChild(self, ActionNode node) 
    cdef int GetUntriedAction(self)
    cdef list GetActionSpace(self) 
    cdef bint IsTerminal(self)
    cdef void IncVistCount(self)
    cdef int GetVisitCount(self)
    cdef double GetReward(self)
    cdef void SetReward(self, double newReward) 
    cdef void IncReward(self, double newReward)
    cdef bint IsExpandable(self) 
    cdef bint IsLeaf(self)
    
    
cdef class ActionNode(): 
    
    #Attributes
    cdef int action 
    cdef StateNode parent 
    cdef list children 
    cdef int numVisits 
    cdef double reward 
  
    #Functions 
    cdef bint IsAction(self) 
    cpdef int GetAction(self) 
    cdef bint IsState(self) 
    cdef StateNode GetParent(self) 
    cdef list GetChildren(self)
    # cdef StateNode InChildren(self, (int, int) state)
    cdef void AddChild(self, StateNode node) 
    cdef void IncVistCount(self) 
    cdef int GetVisitCount(self) 
    cdef double GetReward(self) 
    cdef void SetReward(self, double newReward)
    cdef void IncReward(self, double newReward) 
   
    
        
        
    
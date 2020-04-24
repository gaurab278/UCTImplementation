"""
Defines a node structure 

@author: Gaurab Pokharel
"""


import random 
cdef unsigned long long NEWREWARD = 100000000000000

cdef class StateNode: 
    
    def __init__ (self, (int, int) state, int Action_Taken, list action_space, ActionNode parent = None, bint isTerminal = False): 
        # print(action_space)
        self.state = state  
        self.action = Action_Taken
        self.parent = parent 
        self.children = []
        self.action_space = action_space
        self.untriedActions = action_space 
        self.numVisits = 1
        self.reward = NEWREWARD 
        self.root = False 
        self.isterminal = isTerminal 
        
    def __str__(self):
        print("State ", end = "")
        return "{}: (Parent Action={}, visits={}, reward={:f})".format(
                                                self.state,
                                                self.action,
                                                self.numVisits, 
                                                self.reward)
    
    
    #Function that sets the current node to be the root node 
    cdef void SetRoot(self): 
        self.root = True
    
    cdef bint IsRoot(self): 
        return self.root
    
    #Get the action taken to reach this state 
    cdef int GetParentAction(self): 
        return self.action
    
    
    #Funtion to get the state of current node 
    cdef (int, int) GetState(self): 
        return self.state 
    
    #Function to check if the node is action node 
    cdef bint IsAction(self): 
        return False
    
    #Function to check if the node is state node
    cdef bint IsState(self): 
        return True
     
    #Function to get the parent node 
    cdef ActionNode GetParent(self): 
        return self.parent 
    
    #Function to get the children of current node 
    cdef list GetChildren(self): 
        return self.children 
     
    #Function to add a child to the node 
    cdef void AddChild(self, ActionNode node): 
        self.children.append(node) 
    
    #Get one action at a time that hasn't been tried yet 
    cdef int GetUntriedAction(self):
        cdef int action 
        action = random.choice(self.untriedActions)
        self.untriedActions.remove(action)
        return action
    
    cdef list GetActionSpace(self): 
        return self.untriedActions
    
    
    #Function to check if the current node is terminal node 
    cdef bint IsTerminal(self): 
        return self.isterminal 
     
    #Function to increment node visit count 
    cdef void IncVistCount(self): 
        self.numVisits = self.numVisits + 1 
    
    cdef int GetVisitCount(self): 
        return self.numVisits
     
    #Function to get the reward accumulated in current node 
    cdef double GetReward(self): 
        return self.reward  
    
    cdef void SetReward(self, double newReward): 
        self.reward = newReward
         
    #Function to set the reward for this node 
    cdef void IncReward(self, double newReward): 
        self.reward = self.reward + newReward
    

    #Function to check if the current node is expandable 
    cdef bint IsExpandable(self): 
        if self.isterminal: 
            return False 
        if self.isAction: 
            return False 

        if len(self.untriedActions) > 0: 
            return True 
        return False 
    
    #Function to check if the node is a leaf node 
    cdef bint IsLeaf(self): 
        if  self.isAction == False and len(self.children) == 0: 
            return True 
        else: 
            return False 
        
        
        
cdef class ActionNode: 
    
    def __init__ (self, int action, StateNode parent = None): 
         
        self.action = action
        self.parent = parent 
        self.children = [] 
        self.numVisits = 1
        self.reward = NEWREWARD  
        
    def __str__(self):
        print("Action ", end = "")
        return "{}: (Parent State={}, visits={}, reward={:f})".format(
                                                self.action,
                                                self.parent.GetState(),
                                                self.numVisits, 
                                                self.reward)
    
    
    #Function to check if the node is action node 
    cdef bint IsAction(self): 
        return True 
    
    cdef int GetAction(self): 
        return self.action 
    
    #Function to check if the node is state node
    cdef bint IsState(self): 
        return False
     
    #Function to get the parent node 
    cdef StateNode GetParent(self): 
        return self.parent 
    
    #Function to get the children of current node 
    cdef list GetChildren(self): 
        return self.children 
     
    cdef StateNode InChildren(self, (int, int) state): 
        cdef StateNode child 
        cdef (int, int) stt 
        
        for child in self.children: 
            stt = child.GetState() 
            if stt == state: 
                return child
        return None
        
    #Function to add a child to the node 
    cdef void AddChild(self, StateNode node): 
        if len(self.children) == 0: 
            self.children.append(node) 
            return
        
        cdef (int, int) newstt, cstt 
        cdef bint present 
        cdef StateNode child 
        
        newstt = node.GetState()
        present = False 
        for child in self.children: 
            cstt = child.GetState() 
            if cstt == newstt :
                present = True
        
        if present == False: 
            self.children.append(node) 
            return
       
     
    #Function to increment node visit count 
    cdef void IncVistCount(self): 
        self.numVisits = self.numVisits + 1 
    
    cdef int GetVisitCount(self): 
        return self.numVisits
     
    #Function to get the reward accumulated in current node 
    cdef double GetReward(self): 
        return self.reward  
    
    cdef void SetReward(self, double newReward): 
        self.reward = newReward
         
    #Function to set the reward for this node 
    cdef void IncReward(self, double newReward): 
        self.reward = self.reward + newReward
    
    
    
        
        

    
    
        

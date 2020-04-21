import random 
cdef unsigned long long NEWREWARD = 100000000000000


cdef class StateNode: 
    
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
 
    
    #Initilization
    def __init__ (self, (int, int) state, int Action_Taken, list action_space, ActionNode parent = None, bint isTerminal = False): 
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
        
        
    #To String
    def __str__(self):
        print("State ", end = "")
        return "{}: (Parent Action={}, visits={}, reward={:f})".format(
                                                self.state,
                                                self.action,
                                                self.numVisits, 
                                                self.reward)
    
    
    #Function that sets the current node to be the root node 
    cpdef void SetRoot(self): 
        self.root = True
    
    
    #Function to check if the current node is a root
    cpdef bint IsRoot(self): 
        return self.root
    
    #Get the action taken to reach this state 
    cpdef int GetParentAction(self): 
        return self.action
    
    
    #Funtion to get the state of current node 
    cpdef (int, int) GetState(self): 
        return self.state 
    
    #Function to check if the node is action node 
    cpdef bint IsAction(self): 
        return False
    
    #Function to check if the node is state node
    cpdef bint IsState(self): 
        return True
     
    #Function to get the parent node 
    cpdef ActionNode GetParent(self): 
        return self.parent 
    
    #Function to get the children of current node 
    def GetChildren(self): 
        return self.children 
     
    #Function to add a child to the node 
    cpdef void AddChild(self, ActionNode node): 
        self.children.append(node) 
    
    #Get one action at a time that hasn't been tried yet 
    cpdef int GetUntriedAction(self):
        cdef int action 
        action = random.choice(self.untriedActions)
        self.untriedActions.remove(action)
        return action
    
    
    def GetActionSpace(self): 
        return self.untriedActions
    
    
    #Function to check if the current node is terminal node 
    cpdef bint IsTerminal(self): 
        return self.isterminal 
     
    #Function to increment node visit count 
    cpdef void IncVistCount(self): 
        self.numVisits = self.numVisits + 1 
    
    cpdef int GetVisitCount(self): 
        return self.numVisits
     
    #Function to get the reward accumulated in current node 
    cpdef double GetReward(self): 
        return self.reward  
    
    cpdef void SetReward(self, double newReward): 
        self.reward = newReward
         
    #Function to set the reward for this node 
    cpdef void IncReward(self, double newReward): 
        self.reward = self.reward + newReward
    

    #Function to check if the current node is expandable 
    cpdef bint IsExpandable(self): 
        if self.isterminal: 
            return False 
        if self.isAction: 
            return False 

        if len(self.untriedActions) > 0: 
            return True 
        return False 
    
    #Function to check if the node is a leaf node 
    cpdef bint IsLeaf(self): 
        if  self.isAction == False and len(self.children) == 0: 
            return True 
        else: 
            return False 
        
        
        
        
        
cdef class ActionNode:
    cdef int action 
    cdef StateNode parent 
    #Initialization
    def __init__ (self, int action, StateNode parent = None): 
        self.action = action
        self.parent = parent 
        self.children = [] 
        self.numVisits = 1
        self.reward = NEWREWARD  
        
    #To string 
    def __str__(self):
        print("Action ", end = "")
        return "{}: (Parent State={}, visits={}, reward={:f})".format(
                                                self.action,
                                                self.parent.GetState(),
                                                self.numVisits, 
                                                self.reward)
    
    
    #Function to check if the node is action node 
    cpdef bint IsAction(self): 
        return True 
    
    cpdef int GetAction(self): 
        return self.action 
    
    #Function to check if the node is state node
    cpdef bint IsState(self): 
        return False
     
    #Function to get the parent node 
    cpdef StateNode GetParent(self): 
        return self.parent 
    
    #Function to get the children of current node 
    def GetChildren(self): 
        return self.children 
     
        
    #HAVEN'T CONVERTED THIS TO CYTHON, type error on state 
    def InChildren(self, state): 
        cdef (int, int) stt 
        cdef StateNode child 
        for child in self.children: 
            stt = child.GetState() 
            if stt == state: 
                return child
        return None
        
    #Function to add a child to the node 
    cpdef void AddChild(self, StateNode node): 
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
    cpdef void IncVistCount(self): 
        self.numVisits = self.numVisits + 1 
    
    cpdef int GetVisitCount(self): 
        return self.numVisits
     
    #Function to get the reward accumulated in current node 
    cpdef double GetReward(self): 
        return self.reward  
    
    cpdef void SetReward(self, double newReward): 
        self.reward = newReward
         
    #Function to set the reward for this node 
    cpdef void IncReward(self, double newReward): 
        self.reward = self.reward + newReward    

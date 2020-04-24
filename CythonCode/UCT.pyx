"""
Defines the Main UCT function  

@author: Gaurab Pokharel
"""


import random, time
# from env import Env 
# from node import StateNode 
# from node import ActionNode
from math import sqrt, log 


from node cimport StateNode 
from node cimport ActionNode
from env cimport Env


cdef double GAMMA = 0.90
cdef double EXPLORATION_CONSTANT = sqrt(2)
cdef int TIME =10
cdef unsigned long long NEWREWARD = 100000000000000




cdef class UCT: 
      
    def __init__(self, Env environment):
        self.env = environment 
        self.action_space = self.MakeActionSpace(environment) 
        self.root = self.makeroot(environment)


    cdef list MakeActionSpace(self, Env env): 
        cdef list temp = self.env.actionspace() 
        return temp 
    
    
    cdef StateNode makeroot(self, Env env): 
        cdef (int, int) state
        cdef StateNode NewNode 
        # state = env.getState() 
        NewNode = StateNode(env.getState(), 999, self.action_space, None, False)
        NewNode.SetRoot()
        NewNode.SetReward(NEWREWARD)
        return NewNode
        
    cdef StateNode getroot(self): 
        return self.root
        
        
        
        
    #================================================================================================    
    #ROLLOUT FUNCTION 
    #================================================================================================    
    #Actual recursive function called by the wrapper function 
    
    cdef double _rollout_(self, Env envI, double gamma): 
        cdef int action 
        # cdef (int, int) nxtState
        cdef double reward 
        cdef bint nxtDone
        cdef Env env = envI
        
        #Base case
        if env.IsTerminal(): 
            return gamma * env.giveReward()
        
        #Else find list of possible actions 
        action = random.choice(env.actionspace())
        
        #Simulate action on environment 
        env.step(action)
        # nxtState = env.getState() 
        reward = env.giveReward() 
        nxtDone = env.IsTerminal() 
        
        return reward + (gamma * (self._rollout_(env, gamma)))
    
  
    #Wrapper function that is called on a *STATE* node 
    cdef double rollout(self, StateNode node): 
        # print("rollout")
        #Check if the input node is indeed a state node 
        assert node.IsAction() == False 
        
        cdef Env env 
        cdef double rwrd  
        
        #Can't rollout on terminal state 
        if node.IsTerminal(): 
            env = Env(node.GetState())
            rwrd = env.giveReward() 
            node.SetReward(rwrd)
            return rwrd
        
        #Call the actual function 
        rwrd = self._rollout_(Env(node.GetState()), GAMMA)  
        
        return rwrd 
       
    
    #================================================================================================    
    #EXPAND FUNCTION 
    #================================================================================================  
    #Function to expand a current state node into possible action nodes 
    cdef StateNode Expand(self, StateNode node): 
        # print("Expanding")
        #First check if node is state node 
        assert node.IsAction() == False
        
        cdef list actions 
        actions = node.GetActionSpace() 
        
        cdef int act 
        #cdef ActionNode newActNode 
        
        for act in actions: 
            newActNode = ActionNode(act, node)
            node.AddChild(newActNode)
            
        return node   
    
    
    
    #================================================================================================    
    #BEST CHILD CALCULATOR 
    #================================================================================================  
    
    cdef double ExplorationTerm(self, StateNode state, ActionNode action, double expCons): 
        return expCons * sqrt(log(state.GetVisitCount())/action.GetVisitCount())
    
    
    #Get the best child action from a state node
    cdef ActionNode bestaction(self, StateNode node, double expCons): 
        assert node.IsState() == True 
        
        cdef list children  
        cdef ActionNode best, child  
        cdef double bestval, value  
 
        
        children = node.GetChildren() 
        best = children[0]
        
        bestval = best.GetReward() + self.ExplorationTerm(node, best, expCons)
        
        iter_children = iter(children) 
        next(iter_children)
        
        for child in iter_children: 
            value = child.GetReward() + self.ExplorationTerm(node, child, expCons)
            
            if value > bestval: 
                best = child 
                bestval = value 
        return best 
    

    # #####################################################################################################
    
    # #================================================================================================    
    # #TREE POLICY 
    # #================================================================================================  
    
    
    #Helper 
    cdef void UpdateReward(self, ActionNode node, double rwrd):  
        cdef double R 
        
        if node.GetReward() == NEWREWARD: 
            node.SetReward(rwrd) 
        else: 
            R = node.GetReward() + ((rwrd - node.GetReward())/node.GetVisitCount())
            node.SetReward(R)
    
   
    cdef double simulate (self, StateNode stateNode, int depth): 
        
        #BASE CASE 1
        #If reached max recursive depth, return 
        if depth == 10: 
            return 0 
        #BASE CASE 2 
        #If current state node hasn't been expanded 
        if len(stateNode.GetChildren()) == 0: 
            stateNode = self.Expand(stateNode)
            return self.rollout(stateNode)
        
        cdef StateNode child, NewNode 
        cdef ActionNode action 
        cdef Env envtemp 
        cdef double rwrd, Reward  
        cdef bint done 
        
        action = self.bestaction(stateNode, EXPLORATION_CONSTANT)
        envtemp = Env(stateNode.GetState())
        
        #Carry out virtual action step on environment 
        envtemp.step(action.GetAction())
        rwrd = envtemp.giveReward() 
        done = envtemp.IsTerminal() 
       
        child = action.InChildren(envtemp.getState() )
        
        if child == None: 
            
            NewNode = StateNode(envtemp.getState(), action.GetAction(),  envtemp.actionspace(), action, done)
            action.AddChild(NewNode) 
        else: 
           
            NewNode = child 
       
        if done: 
            #Need to check this for edge cases when right next to terminal to update rewards 
            if depth == 0: 
                stateNode.IncVistCount() 
                action.IncVistCount() 
                self.UpdateReward(action, rwrd)
            return rwrd 
        
        Reward = rwrd + GAMMA*self.simulate(NewNode, depth + 1)
        stateNode.IncVistCount() 
        action.IncVistCount() 
        self.UpdateReward(action, Reward)
        return Reward
           
    
    cpdef ActionNode search(self):     
        #Set up end Time 
        cdef double timeout 
        cdef ActionNode child 
        
        timeout = time.time() + TIME 
        
        #While the time resource hasn't ended 
        while time.time() <= timeout: 
            self.simulate(self.root, 0) 
        
        for child in self.root.GetChildren(): 
            print(child)
            
        return self.bestaction(self.root, 0)
  
    
  
    
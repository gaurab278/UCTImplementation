
import random 
NEWREWARD = 100000000000000

class Node: 
    
    def __init__ (self, state, isAct, actioni, trueAct, action_space, parent = None, isTerminal = False): 
        
        self.state = state  
        self.isAction = isAct
        self.action = actioni  
        self.trueAction = trueAct
        self.parent = parent 
        self.children = []
        self.untriedActions = action_space 
        self.numVisits = 1  
        self.reward = NEWREWARD 
        self.root = False 
        self.isterminal = isTerminal 
        self.rollout = False
        
    def __str__(self):
        
        if self.isAction: 
            print("Action: ", end = "")
        else: 
            print("State: ", end = "")
        return "{}: (action={}, visits={}, isAction = {} , reward={:f})".format(
                                                self.state,
                                                self.action,
                                                self.numVisits,
                                                self.isAction, 
                                                self.reward)
    
    
    
    
    #Function that sets the current node to be the root node 
    def SetRoot(self): 
        self.root = True
    
    def IsRoot(self): 
        return self.root
    
    def GetTrueAct(self): 
        return self.trueAction
    
    
    #Funtion to get the state of current node 
    def GetState(self): 
        return self.state 
    
    def Rollout(self): 
        self.rollout = True
    
    
    #Function to check if the node is action node 
    def IsAction(self): 
        return self.isAction 
    
    
    
    
    #Function to get the parent node 
    def GetParent(self): 
        return self.parent 
    
    
    
    
    #Function to get the children of current node 
    def GetChildren(self): 
        return self.children 
    
    
    
    
    #Function to add a child to the node 
    def AddChild(self, node): 
        self.children.append(node) 
    
    
    
    
    #Get one action at a time that hasn't been tried yet 
    def GetUntriedAction(self):
        action = random.choice(self.untriedActions)
        self.untriedActions.remove(action)
        return action
    
    def GetActionSpace(self): 
        return self.untriedActions
    
   
    
    #Function that returns the action that was taken to get here
    def GetAction(self): 
        return self.action 
    
    
    
    
    #Function to check if the current node is terminal node 
    def IsTerminal(self): 
        return self.isterminal 
    
    
    
    
    #Function to increment node visit count 
    def IncVistCount(self): 
        self.numVisits = self.numVisits + 1 
    
    def GetVistCount(self): 
        return self.numVisits
    
    
    #Function to get the reward accumulated in current node 
    def GetReward(self): 
        return self.reward  
    
    
    def SetReward(self, newReward): 
        self.reward = newReward
        
    
    #Function to set the reward for this node 
    def IncReward(self, newReward): 
        self.reward = self.reward + newReward
    
    
    
    
    #Function to check if the current node is expandable 
    def IsExpandable(self): 
        if self.isterminal: 
            return False 
        if self.isAction: 
            return False 

        if len(self.untriedActions) > 0: 
            return True 
        return False 
    
    #Function to check if the node is a leaf node 
    def IsLeaf(self): 
        if  self.isAction == False and len(self.children) == 0: 
            return True 
        else: 
            return False 
    
        
        

    
    
        
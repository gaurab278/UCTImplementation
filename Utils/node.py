
import random 
NEWREWARD = 100000000000000

class StateNode: 
    
    def __init__ (self, state, Action_Taken, action_space, parent = None, isTerminal = False): 
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
    def SetRoot(self): 
        self.root = True
    
    def IsRoot(self): 
        return self.root
    
    #Get the action taken to reach this state 
    def GetParentAction(self): 
        return self.action
    
    
    #Funtion to get the state of current node 
    def GetState(self): 
        return self.state 
    
    #Function to check if the node is action node 
    def IsAction(self): 
        return False
    
    #Function to check if the node is state node
    def IsState(self): 
        return True
     
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
    
    
    #Function to check if the current node is terminal node 
    def IsTerminal(self): 
        return self.isterminal 
     
    #Function to increment node visit count 
    def IncVistCount(self): 
        self.numVisits = self.numVisits + 1 
    
    def GetVisitCount(self): 
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
        
        
        
class ActionNode: 
    
    def __init__ (self, action, parent = None): 
         
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
    def IsAction(self): 
        return True 
    
    def GetAction(self): 
        return self.action 
    
    #Function to check if the node is state node
    def IsState(self): 
        return True
     
    #Function to get the parent node 
    def GetParent(self): 
        return self.parent 
    
    #Function to get the children of current node 
    def GetChildren(self): 
        return self.children 
     
    def InChildren(self, state): 
        for child in self.children: 
            stt = child.GetState() 
            if stt == state: 
                return child
        return None
        
    #Function to add a child to the node 
    def AddChild(self, node): 
        if len(self.children) == 0: 
            self.children.append(node) 
            return
        
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
    def IncVistCount(self): 
        self.numVisits = self.numVisits + 1 
    
    def GetVisitCount(self): 
        return self.numVisits
     
    #Function to get the reward accumulated in current node 
    def GetReward(self): 
        return self.reward  
    
    def SetReward(self, newReward): 
        self.reward = newReward
         
    #Function to set the reward for this node 
    def IncReward(self, newReward): 
        self.reward = self.reward + newReward
    
    
    
        
        

    
    
        
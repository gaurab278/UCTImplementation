
import random, time
from Utils.node import StateNode 
from Utils.node import ActionNode
from Utils.env import Env
from math import sqrt, log 


GAMMA = 0.9
EXPLORATION_CONSTANT =sqrt(2)
TIME =10
NEWREWARD = 100000000000000




class UCT: 
    
    
    
    def __init__(self, env):
        self.env = env
        self.action_space = self.env.action_space()
        state = self.env.getState()
        # print(self.action_space)
     
        NewNode = StateNode(state=state, Action_Taken= None,  action_space=self.action_space, parent=None, isTerminal=False)
        NewNode.SetRoot()
        NewNode.SetReward(NEWREWARD)
        self.root = NewNode
                
    def getroot(self): 
            return self.root
        
        
        
        
    #================================================================================================    
    #ROLLOUT FUNCTION 
    #================================================================================================    
    #Actual recursive function called by the wrapper function 
    def _rollout_(self, env, gamma): 
        
        #Base case
        if env.IsTerminal(): 
            return gamma*env.giveReward()
        
        #Else find list of possible actions 
        action = random.choice(env.action_space())
        
        #Simulate action on environment 
        nxtState, reward, nxtDone = env.step(action)
        
        return reward + gamma * (self._rollout_(env, gamma))
    
  
    #Wrapper function that is called on a *STATE* node 
    def rollout(self, node): 
        # print("rollout")
        #Check if the input node is indeed a state node 
        assert node.IsAction() == False 
        
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
    def Expand(self, node): 
        # print("Expanding")
        #First check if node is state node 
        assert node.IsAction() == False
        actions = node.GetActionSpace() 
        
        for act in actions: 
            newActNode = ActionNode(act, node)
            node.AddChild(newActNode)
            
        return node   
    
    
    
    #================================================================================================    
    #BEST CHILD CALCULATOR 
    #================================================================================================  
    
    def ExplorationTerm(self, state, action, expCons): 
        return expCons * sqrt(log(state.GetVisitCount())/action.GetVisitCount())
    
    
    #Get the best child action from a state node
    def bestaction(self, node, expCons): 
        assert node.IsState() == True 
        
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
    

    #####################################################################################################
    
    #================================================================================================    
    #TREE POLICY 
    #================================================================================================  
    
    
    #Helper 
    def UpdateReward(self, node, rwrd):    
        if node.GetReward() == NEWREWARD: 
            node.SetReward(rwrd) 
        else: 
            R = node.GetReward() + ((rwrd - node.GetReward())/node.GetVisitCount())
            node.SetReward(R)
    
    def simulate (self, stateNode, parentAction, depth): 
        
        #BASE CASE 1
        #If reached max recursive depth, return 
        if depth == 10: 
            return 0 
        #BASE CASE 2 
        #If current state node hasn't been expanded 
        if len(stateNode.GetChildren()) == 0: 
            stateNode = self.Expand(stateNode)
            return self.rollout(stateNode)
        
    
        action = self.bestaction(stateNode, EXPLORATION_CONSTANT)
        envtemp = Env(stateNode.GetState())
        
        #Carry out virtual action step on environment 
        newState, rwrd, done = envtemp.step(action.GetAction())
        NewNode = StateNode(newState, action.GetAction(),  envtemp.action_space(), action, done)
       
        if done: 
            #Need to check this for edge cases when right next to terminal to update rewards 
            if depth == 0: 
                if parentAction != None: 
                    parentAction.AddChild(stateNode)
                stateNode.IncVistCount() 
                action.IncVistCount() 
                self.UpdateReward(action, rwrd)
            return rwrd 
        
        Reward = rwrd + GAMMA*self.simulate(NewNode, action, depth + 1)
        if parentAction != None: 
            parentAction.AddChild(stateNode)
        stateNode.IncVistCount() 
        action.IncVistCount() 
        self.UpdateReward(action, Reward)
        return Reward
        
    
    def search(self):     
        #Set up end Time 
        timeout = time.time() + TIME 
        
        #While the time resource hasn't ended 
        while time.time() <= timeout: 
            self.simulate(self.root, None, 0) 
        
        for child in self.root.GetChildren(): 
            print(child)
            
        return self.bestaction(self.root, 0)
  
    
  
    
    
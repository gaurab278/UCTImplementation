
import random, time
from Utils.node import Node 
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
     
        NewNode = Node(state=state, isAct = False, actioni=None, trueAct = None,  action_space=self.action_space, parent=None, isTerminal=False)
        NewNode.SetRoot()
        NewNode.SetReward(0)
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
        
        #Check if the input node is indeed a state node 
        assert node.IsAction() == False 
        
        #Can't rollout on terminal state 
        if node.IsTerminal(): 
            env = Env(node.GetState())
            rwrd = env.giveReward() 
            node.SetReward(rwrd)
            return node
        
        #Call the actual function 
        rwrd = self._rollout_(Env(node.GetState()), GAMMA)  
        
        node.SetReward(rwrd)
        
        return node 
    
    
    
    
    #================================================================================================ 
    #UCB Function Calculator 
    #================================================================================================ 
    def compute_value (self, parent, child, exploration_constant): 
        exploitation_term = child.GetReward() / child.GetVistCount()
        exploration_term = exploration_constant * sqrt(2 * log(parent.GetVistCount() / child.GetVistCount()))
        return exploitation_term + exploration_term
    
    
    
        
    #================================================================================================ 
    #BACKPROPAGATE
    #================================================================================================ 
    #Recursive BackPropagate Function 
    def _backpropagate_(self, node, reward): 
        # print(node)
        #Base Case 
        if node.IsRoot(): 
            node.IncVistCount()
            
            if node.GetReward() == NEWREWARD: 
                node.SetReward(reward)
            else: 
                node.IncReward(reward)
            
            return node 
        
        #Recursive Case
        parent = node.GetParent()
        
        #Update on Parent 
        parent.IncVistCount()
        if parent.GetReward() == NEWREWARD: 
            parent.SetReward(reward)
        else: 
            parent.IncReward(reward) 
        
        #Recurse on Parent 
        return self._backpropagate_(parent, reward)
    
    def backpropagate(self, node): 
        # print("***********************************************************")
        return self._backpropagate_(node, node.GetReward())
    
    
    #================================================================================================    
    #EXPAND FUNCTION 
    #================================================================================================  
    #Function to expand a current state node into possible action nodes 
    def Expand(self, node): 
        
        #First check if node is state node 
        assert node.IsAction() == False
        
        while(len(node.GetActionSpace())!=0): 
            act = node.GetUntriedAction() 
            newEnv = Env(node.GetState())
            newActNode = Node(node.GetState(), True, act, act, newEnv.action_space(), node, False)
    
            node.AddChild(newActNode)
    
        return node   
    
    
    
    #================================================================================================    
    #BEST CHILD CALCULATOR 
    #================================================================================================  
    #Get the best child action from a state node
    def bestaction(self, node, expCons): 
        
        #Check if the function is being called on a state node 
        assert node.IsAction() == False 
        
        
        children = node.GetChildren() 
        best = children[0]
        
        bestval = self.compute_value(node, best, expCons)
        
        iter_children = iter(children) 
        next(iter_children)
        
        for child in iter_children: 
            value = self.compute_value(node, child, expCons)
            
            if value > bestval: 
                best = child 
                bestval = value 
        return best 
    
    #================================================================================================  
    #Get the best child state from taking an action  
    def beststate(self, node, expCons): 
        
        #Check if the function is being called on a state node 
        assert node.IsAction() == True
        
        
        children = node.GetChildren() 
        best = children[0]
        
        bestval = self.compute_value(node, best, expCons)
        
        iter_children = iter(children) 
        next(iter_children)
        
        for child in iter_children: 
            value = self.compute_value(node, child, expCons)
            
            if value > bestval: 
                best = child 
                bestval = value 
        return best 
    
    
    
    
    #================================================================================================    
    #FORWARD FUNCTION FOR ACTUALLY MOVING 
    #================================================================================================  
    def forward(self): 
        #Get Best Child Action Node 
        best_child = self.bestaction(self.root, 0) 
        print("****** <{}> ******".format(best_child.GetState()))
        print()
        
        for child in self.root.GetChildren(): 

            print("<{}> Value : {:0.4f}".format(child.GetAction(), self.compute_value(self.root, child, 0)))
        print("******************************")
        
        for child in self.root.GetChildren(): 
            print(child)
        print("******************************")
        
        
        
        stt, reward, done = self.env.debuggerstep(best_child.GetAction())
        return stt
    
    
    
    
    #================================================================================================    
    #TREE POLICY 
    #================================================================================================  
    
    
    #Helper 
    def inChildren(self, stt, children): 
        for child in children: 
            cstt = child.GetState() 
            if cstt == stt: 
                return True
        return False 
    
  
    def tree_policy(self): 
        
        #Start by expanding the root of the tree 
        node = self.root 
        node = self.Expand(node)
        
        #Set up end time 
        timeout = time.time() + TIME 
        
        #While time resource hasn't ended 
        while time.time() <= timeout: 
            
            #If current node is action node
            if node.IsAction(): 
                #Simulate the action on parent state 
                env = Env(node.GetState())
                newStt, reward, done = env.step(node.GetAction())
                # print(newStt, end = '')
                # print(reward, end = '')
                # print(done)
                
                #If resultant child state is in list of children 
                if self.inChildren(newStt, node.GetChildren()): 
                    #Pick best child among available children
                    node = self.beststate(node, EXPLORATION_CONSTANT)
                #Else 
                else: 
                    #Create new state node child 
                    newNode = Node(newStt, False, node.GetAction(), node.GetAction(), env.action_space(), node, done) 
                    
                    if done: 
                        newNode.SetReward(reward)
                    else:
                        #Call rollout on child node 
                        newNode = self.rollout(newNode)
                    #Set newNode to be child of action node 
                    node.AddChild(newNode)
                    #Back propagate from child node 
                    node = self.backpropagate(newNode)
            
            #If current node is state node 
            if not node.IsAction(): 
                # If state node is terminal
                if node.IsTerminal(): 
                    #Backpropagate from node
                    node = self.backpropagate(node)
                    
                #Elif state node isn't leaf
                elif not node.IsLeaf():  
                    #Select best action node child 
                    node = self.bestaction(node, EXPLORATION_CONSTANT)
                #Else: 
                else: 
                    #Node is leaf 
                    #Check if node has been expanded (redundant check)
                    #If not expanded then expand 
                    node = self.Expand(node)
                
            
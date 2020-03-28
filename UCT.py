
import random, time
from Utils.node import Node 
from Utils.env import Env
from math import sqrt, log 


GAMMA = 0.9
EXPLORATION_CONSTANT =5
TIME =20
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
    
    #Function to Rollout Simulate from a Given **State** node 
    def RollOut(self, state, gamma): 
        #create copy of env 
        newEnv = Env(state)
        
        #Get list of possible actions at current state
        possible_actions = newEnv.action_space() 
        
        #pick a random action 
        action = random.choice(possible_actions)
        
        #Simulate this action
        nxtState, reward, nxtDone = newEnv.step(action)
        
        #If action results in terminal state
        if nxtDone: 
            #return reward
            return gamma*reward
        else: 
            #else recurse on the new environment
            return reward + gamma*(self.RollOut(nxtState, gamma))
        
    
    #Compute Value function to find the best child state 
    def compute_value (self, parent, child, exploration_constant): 
        exploitation_term = child.GetReward() / child.GetVistCount()
        exploration_term = exploration_constant * sqrt(2 * log(parent.GetVistCount() / child.GetVistCount()))
        return exploitation_term + exploration_term 
    
    
    
    #Back Propagate function that back propagates from the best_child? 
    def BackPropagate(self, node, rwrd): 
        curr = node 

        while not curr == self.root: 
            curr.IncVistCount()
            parent = curr.GetParent() 
            
            if parent.GetReward() == NEWREWARD: 
                parent.SetReward(rwrd)
            else: 
                parent.IncReward(rwrd)

            curr = parent 
        curr.IncVistCount()
        return curr
        
    
    
    #Expands state node into possible action nodes, then expands each action node in turn 
    def Expand(self, node): 
        #This expand function is only called on state nodes, so check if that is true 
        assert node.IsAction() == False
        
        
        while (len(node.GetActionSpace()) != 0 ): 
            act = node.GetUntriedAction()
            newEnv1 = Env(node.GetState())
            new_action_node = Node(node.GetState(), True, act, act, newEnv1.action_space(), node, False)
            
            
            #Expand current state node to have action node as child
            node.AddChild(new_action_node)
            
        return node 

  
    #Get best action child 
    def GetBestChild(self, node, expCons): 
        
        #Check first if this node is a state node or not 
        assert node.IsAction() == False 
        
        """Each state node has children action nodes. 
        Each one of those children action nodes have multiple state children. 
        So compile a list of all possible children action nodes and call bestchild
        on that list of children *STATE* nodes"""
        
        actionChildren = node.GetChildren() 
        best_child = actionChildren[0]
        
        
        best_value = self.compute_value(node, best_child, expCons)
        
        #Create an iterator to iterate over all children 
        iter_children = iter(actionChildren)
        
        #move one step because first child is already taken into account 
        next(iter_children)
        
        for child in iter_children: 
            value = self.compute_value(node, child, expCons)
            
            # if child.GetReward() == NEWREWARD: 
            #     return child
            
            #Check if this child did better 
            if value > best_value:
                best_child = child
                best_value = value
        return best_child
        
     
        
    

        
    #Figure out best child from possible state childs
    def _best_child (self, parent, exploration_constant): 
        
        children = parent.GetChildren()
        best_child = children[0]
        #print(best_child)
   
        #Check if children are action nodes, they are NOT supposed to be action nodes   
        assert best_child.IsAction() == False 
        
        best_value = self.compute_value(parent, best_child, exploration_constant)
        
        #Create an iterator to iterate over all children 
        iter_children = iter(children)
        
        #move one step because first child is already taken into account 
        next(iter_children)
        
        for child in iter_children:
            
            # if child.GetReward() == NEWREWARD: 
            #     return child
            
            value = self.compute_value(parent, child, exploration_constant)
            
            #Check if this child did better 
            if value > best_value:
                best_child = child
                best_value = value
        return best_child
    
    
    def inChidlren(self, node, children): 
        stt = node.GetState()
        
        for child in children: 
            cstt = child.GetState() 
            
            if cstt == stt: 
                return True
        return False 
    
    
    
    def tree_policy(self): 

        #Start at the base of the tree 
        node = self.root
        node = self.Expand(node)
   

        #set up ending time 
        timeout = time.time() + TIME 
        

        #while time resource is not up 
        while time.time() < timeout: 
            
            #If the current node is a state node 
            if not node.IsAction(): 
                
                #If current node is leaf node
                if node.IsLeaf(): 
                    
                    #If rollout hasn't been done on it
                    if node.GetReward() == NEWREWARD:
                        rwrd = self.RollOut(node.GetState(), GAMMA)
                        node.SetReward(rwrd)
                        node = self.BackPropagate(node, rwrd) 
                    #if rollout has already been done, expand state node into action nodes 
                    else:
                        node = self.Expand(node)
                #If not leaf state, pick best action and recurse on it 
                else: 
                    node = self.GetBestChild(node, EXPLORATION_CONSTANT)
            #If current node is action node     
            elif node.IsAction(): 
                #Create a copy of env 
                newEnv = Env(node.GetState())
                act = node.GetAction()
                
                #Simulate action of the action node in environment
                newEnvState, reward, doneNxt = newEnv.step(act) 
            
                #Create new state node, with the resultant state 
                new_state_node = Node(newEnvState, False, act,act, newEnv.action_space(), node, doneNxt)
                
                children = node.GetChildren()
                
                #If the new state node is already in list of children 
                present = self.inChidlren(new_state_node, children)
                
                
                if present: 
                    #Pick the best child from possible childs 
                    node = self._best_child(node, EXPLORATION_CONSTANT)
                    
                #If new state node is  not in list of children 
                else: 
                    #Add new node to list of children 
                    node.AddChild(new_state_node)
                    if doneNxt:
                         new_state_node.SetReward(reward)
                         node = self.BackPropagate(new_state_node, reward) 
                    else: 
                       rwrd = self.RollOut(new_state_node.GetState(), GAMMA)
                       new_state_node.SetReward(rwrd)
                       node = self.BackPropagate(new_state_node, rwrd) 
           
                 

    
    def forward(self): 

        #Get Best Child Action Node 
        best_child = self.GetBestChild(self.root, 0) 
        print("****** <{}> ******".format(best_child.GetState()))
        print()
        actionParent = best_child.GetParent() 
        for child in actionParent.GetChildren(): 
            print("<{}> Value : {:0.4f}".format(child.GetAction(), self.compute_value(self.root, child, 0)))
        print("******************************")
        
        stt, reward, done = self.env.debuggerstep(best_child.GetAction())
        return stt
    
    
  
    
        
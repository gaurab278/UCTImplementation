import numpy as np 
cimport numpy as np
import random,time
from math import sqrt, log 

#Global Variables
cdef int BOARD_ROWS = 3
cdef int BOARD_COLS = 4

cdef (int, int) WIN_STATE = (0, 3)
cdef (int, int) LOSE_STATE = (1, 3)

cdef double WINWARD  = 1.00
cdef double LOSEWARD = -1.00

cdef (int, int) START = (2,0)
cdef double REWARD = -0.04  
cdef unsigned long long NEWREWARD = 100000000000000




cdef double GAMMA = 0.9
cdef double EXPLORATION_CONSTANT =sqrt(2)
cdef int TIME =10


#The environment Class 
cdef class Env: 
    # cdef np.ndarray[np.int32_t, ndim=2] board = np.empty((BOARD_ROWS, BOARD_COLS), dtype=np.int32)
    
    #Initialization function 
    def __init__(self, (int, int) state=START):
        self.board = np.zeros([BOARD_ROWS, BOARD_COLS])
        self.board[1, 1] = -1
        self.state = state
        self.isTerminal = False
        
    
    #Reset game state to START 
    cpdef bint reset(self): 
        self.state = START 
        return True 
    
    
    #Give reward to the current state 
    cpdef double giveReward(self):
        if self.state == WIN_STATE:
            return WINWARD
        elif self.state == LOSE_STATE:
            return LOSEWARD
        else:
            return REWARD
        
    
    #Check to see if the current state of environment is terminal 
    cdef void isEnd(self): 
        if (self.state == WIN_STATE) or (self.state == LOSE_STATE):
            self.isTerminal = True
        else: 
            self.isTerminal = False 
    
    
    #Get return on whether or not the env is terminal
    cpdef bint IsTerminal(self): 
        self.isEnd()
        return self.isTerminal
    
    
    
    #Main valid action checker function, Used by multiple procedures
    #Not called outside class
    cdef bint isValid(self, (int, int) nxtState): 
       if (nxtState[0] >= 0) and (nxtState[0] <= 2):
               if (nxtState[1] >= 0) and (nxtState[1] <= 3):
                   if nxtState != (1, 1):
                       return True
       return False
    
    
    #Function to check if the next action is valid or not
    #Called outside of class
    cpdef bint isValidAction(self, (int, int) state, int action): 
        if action == 0:
            nxtState = (state[0] - 1, state[1])
        elif action == 1:
            nxtState = (state[0], state[1] - 1)
        elif action == 2:
            nxtState = (state[0], state[1] + 1) 
        elif action == 3:
            nxtState = (state[0] +1, state[1]) 
        else: 
            nxtState = state
            
        if self.isValid(nxtState): 
            return True 
        else: 
            return False
        
        
    #Get the current state of the environment 
    #Called outside of class
    cpdef (int, int) getState(self): 
        return self.state
        
    
    #Main stepping function for the environment 
    cpdef ((int, int), double, bint) step(self, int action): 
        cpdef double correctMove 
        cpdef (int, int) nxtState, nxtState1
        cpdef list altActions
        
        if action == 0:
            nxtState = (self.state[0] - 1, self.state[1])
        elif action == 1:
            nxtState = (self.state[0], self.state[1] - 1)
        elif action == 2:
            nxtState = (self.state[0], self.state[1] + 1) 
        elif action == 3: 
            nxtState = (self.state[0] + 1, self.state[1])

                
        correctMove = random.random() 
        if self.isValid(nxtState):   
            if correctMove <= 0.8: 
                self.state = nxtState
                self.isEnd()
                return self.state, self.giveReward(), self.IsTerminal()
            else:  
                altActions =[]
                
                if action == 0:
                    altActions.append(1)
                    altActions.append(2)
                elif action == 1: 
                    altActions.append(0)
                    altActions.append(3)
                elif action == 2: 
                    altActions.append(0)
                    altActions.append(3)
                else: 
                    altActions.append(1)
                    altActions.append(2)
    
                altAction = random.choice(altActions)
               
                if altAction == 0:
                    nxtState1 = (self.state[0] - 1, self.state[1])
                elif altAction == 1:
                    nxtState1 = (self.state[0], self.state[1] - 1)
                elif altAction == 2:
                    nxtState1 = (self.state[0], self.state[1] + 1) 
                elif altAction == 3: 
                    nxtState1 = (self.state[0] + 1, self.state[1])
                
                
                if self.isValid(nxtState1): 
                    self.state = nxtState1
                    self.isEnd()
                    return self.state, self.giveReward(), self.IsTerminal()
                else: 
                    #Randomly select from the remaining two 
                    self.isEnd()
                    return self.state, self.giveReward(), self.IsTerminal()
        else: 
                    self.isEnd()
                    return self.state, self.giveReward(), self.IsTerminal()
        
        
        
        
        
        
    #THIS IS THE SAME AS STEP but this shows debugging steps, MAINLY USED IN INTERFACING                
    cpdef ((int, int), double, bint) debuggerstep(self, int action):
        cpdef double correctMove 
        cpdef (int, int) nxtState, nxtState1
        cpdef list altActions

        
        """
        -------------
        0 | 1 | 2| 3|
        1 |
        2 |
        
        up = 0 
        left = 1 
        right = 2
        down = 3
        """



        #Calculate actual Next State you are supposed to reach via action
        if action == 0:
            nxtState = (self.state[0] - 1, self.state[1])
        elif action == 1:
            nxtState = (self.state[0], self.state[1] - 1)
        elif action == 2:
            nxtState = (self.state[0], self.state[1] + 1) 
        elif action == 3: 
            nxtState = (self.state[0] + 1, self.state[1])

                
        #BUT YOU CAN ONLY REACH THERE WITH 80% PROBABIBILITY
        #Stocasticity Implementation
        correctMove = random.random() 
        
        #Check if nextState to reach is valid, Redundant Check (Might have to remove in future iterations)
        if self.isValid(nxtState):   
            #If you have a valid next state, you reach there with 80% probability
            if correctMove <= 0.8: 
                
                print("Ended up in correct state taking action ", end = "")
                if (action == 0): 
                    print("Up")
                elif (action == 1): 
                    print("Left")
                elif (action == 2): 
                    print("Right")
                elif(action == 3): 
                    print("Down")
                self.state = nxtState
                self.isEnd()
                return nxtState, self.giveReward(), self.isTerminal
                
            #Else you didn't end up in right place
            else: 
                
                print("Ended up in wrong state. Had to go ", end = "")
                if (action == 0): 
                    print("Up ", end = "")
                elif (action == 1): 
                    print("Left ", end = "")
                elif (action == 2): 
                    print("Right ", end = "")
                elif(action == 3): 
                    print("Down ", end = "")
               
                print("And end up in ", end = "")
                print(nxtState)
                    
                print("But ended up in: ", end = "")
                
               
                #Find remaining states that can be possibly reached: 
                altActions =[]
                
                if action == 0:
                    altActions.append(1)
                    altActions.append(2)
                elif action == 1: 
                    altActions.append(0)
                    altActions.append(3)
                elif action == 2: 
                    altActions.append(0)
                    altActions.append(3)
                else: 
                    altActions.append(1)
                    altActions.append(2)
    
                
                #Pick one random of all possible next states
                altAction = random.choice(altActions)
                #Check if alternate possibility is valid 
                if altAction == 0:
                    nxtState1 = (self.state[0] - 1, self.state[1])
                elif altAction == 1:
                    nxtState1 = (self.state[0], self.state[1] - 1)
                elif altAction == 2:
                    nxtState1 = (self.state[0], self.state[1] + 1) 
                elif altAction == 3: 
                    nxtState1 = (self.state[0] + 1, self.state[1])
                
                
                
                #If alternate possibility is valid, update values
                if self.isValid(nxtState1): 
                    print(nxtState1)
                        
                    #Update Values 
                    self.state = nxtState1
                    self.isEnd()
                    return nxtState1, self.giveReward(), self.isTerminal
                
                #If alternate possibility is not valid, then you stay in place
                else: 
                    #Stay in place 
                    print(self.state)
                    print("Stayed in Place!")
                    self.isEnd()
                    return self.state, self.giveReward(), self.isTerminal
        else: 
             #Stay in place 
                    print(self.state)
                    print("Invalid action picked, Stayed in Place!")
                    self.isEnd()
                    return self.state, self.giveReward(), self.isTerminal
                
                
                
    #Get a list of possible actions that can be conducted at current state
    def action_space(self):
        
        actions_allowed = []
        if self.state == WIN_STATE or self.state == LOSE_STATE: 
            return actions_allowed
        
        #Check if up is valid 
        upAction = (self.state[0] - 1, self.state[1])
        if self.isValid(upAction): 
            actions_allowed.append(0)
            
        #Check if down is valid 
        downAction = (self.state[0] + 1, self.state[1])
        if self.isValid(downAction): 
            actions_allowed.append(3)
            
        #Check if left is valid 
        if self.isValid (nxtState =(self.state[0], self.state[1] - 1)): 
            actions_allowed.append(1)
        
        #Check if right is valid
        if self.isValid (nxtState =(self.state[0], self.state[1] + 1)): 
            actions_allowed.append(2)
            

        return actions_allowed
    
    
    
    #Function to print out the current board
    cpdef void showBoard(self):
        cpdef int i = 0
        self.board[self.state] = 1
        for i in range(0, BOARD_ROWS):
            print('-----------------')
            out = '| '
            for j in range(0, BOARD_COLS):
                if self.board[i, j] == 1:
                    token = '*'
                if self.board[i, j] == -1:
                    token = 'X'
                if self.board[i, j] == 0:
                    token = '0'
                out += token + ' | '
            print(out)
        print('-----------------')
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
  
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
        
    
    
    





































cdef class UCT: 
    
    def __init__(self, env):
        self.env = env
        self.action_space = self.env.action_space()
        state = self.env.getState()
        # print(self.action_space)
     
        NewNode = StateNode(state=state, Action_Taken= None,  action_space=self.action_space, parent=None, isTerminal=False)
        NewNode.SetRoot()
        NewNode.SetReward(NEWREWARD)
        self.root = NewNode
                
    cpdef StateNode  getroot(self): 
            return self.root
        
        
        
        
    #================================================================================================    
    #ROLLOUT FUNCTION 
    #================================================================================================    
    #Actual recursive function called by the wrapper function 
    cpdef double _rollout_(self,Env env, double gamma): 
        
        #Base case
        if env.IsTerminal(): 
            return gamma*env.giveReward()
        
        cdef int action 
        #Else find list of possible actions 
        action = random.choice(env.action_space())
        
        cdef (int, int) nxtState 
        cdef double reward 
        cdef bint nxtDone
        
        #Simulate action on environment 
        nxtState, reward, nxtDone = env.step(action)
        
        return reward + gamma * (self._rollout_(env, gamma))
    
  
    #Wrapper function that is called on a *STATE* node 
    cpdef double rollout(self, StateNode node): 
        # print("rollout")
        #Check if the input node is indeed a state node 
        assert node.IsAction() == False 
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
    cpdef StateNode Expand(self, StateNode node): 
        # print("Expanding")
        #First check if node is state node 
        assert node.IsAction() == False
        cdef list actions
        actions = node.GetActionSpace() 
        cdef int act 
        cdef ActionNode newActNode 
        for act in actions: 
            newActNode = ActionNode(act, node)
            node.AddChild(newActNode)
            
        return node   
    
    
    
    #================================================================================================    
    #BEST CHILD CALCULATOR 
    #================================================================================================  
    
    cdef double  ExplorationTerm(self, (int, int) state, int action, double expCons): 
        return expCons * sqrt(log(state.GetVisitCount())/action.GetVisitCount())
    
    
    #Get the best child action from a state node
    cpdef ActionNode bestaction(self, StateNode node, double expCons): 
        assert node.IsState() == True 
        cdef list children
        cdef ActionNode best, child
        cdef double bestval,value 
        
        
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
    
    
    cpdef double simulate (self, StateNode stateNode, int depth): 
        
        #BASE CASE 1
        #If reached max recursive depth, return 
        if depth == 10: 
            return 0 
        #BASE CASE 2 
        #If current state node hasn't been expanded 
        if len(stateNode.GetChildren()) == 0: 
            stateNode = self.Expand(stateNode)
            return self.rollout(stateNode)
        
        cdef ActionNode action 
        cdef Env envtemp 
        cdef (int,int) newState 
        cdef double rwrd, Reward  
        cdef bint done 
        cdef StateNode child, NewNode
        
        action = self.bestaction(stateNode, EXPLORATION_CONSTANT)
        envtemp = Env(stateNode.GetState())
        
        #Carry out virtual action step on environment 
        newState, rwrd, done = envtemp.step(action.GetAction())
       
        child = action.InChildren(newState)
        
        if child == None: 
            
            NewNode = StateNode(newState, action.GetAction(),  envtemp.action_space(), action, done)
            action.AddChild(NewNode) 
        else: 
           
            NewNode = child 
       
        
        # parentAction = stateNode.GetParent()
        
        if done: 
            #Need to check this for edge cases when right next to terminal to update rewards 
            if depth == 0: 
                # action.AddChild(stateNode)
                # if parentAction != None: 
                #     parentAction.AddChild(stateNode)
                stateNode.IncVistCount() 
                action.IncVistCount() 
                self.UpdateReward(action, rwrd)
            return rwrd 
        
        Reward = rwrd + GAMMA*self.simulate(NewNode, depth + 1)
        # action.AddChild(stateNode)
        # if parentAction != None: 
        #     parentAction.AddChild(stateNode)
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
  
    
  
    
  
    
  
def main():
    
    cdef Env env 
    cdef UCT uct 
    cdef ActionNode actionNode  
    cdef (int, int) newEnvState 
    cdef double rwrd 
    cdef bint done  
    
    
    env = Env()
    env.reset()
    # random.seed(67)
    #Show env state: 
    print()
    env.showBoard()
    print("==================================================")
    print("==================================================")
    print()
    
    while not env.IsTerminal(): 
        uct = UCT(env) 
        actionNode = uct.search() 
        
        newEnvState, rwrd, done  = env.debuggerstep(actionNode.GetAction())
        env = Env(newEnvState)
        print("Resultant Board: ")
        env.showBoard()
        print()
        print("==================================================")
        print("==================================================")
        print()
        

if __name__ == "__main__":
   main()
    
    

   
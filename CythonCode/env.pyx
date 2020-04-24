
"""
Defines the domain on which the agent works 

@Author: Gaurab Pokharel  

"""
import numpy as np 
cimport numpy as np 
cimport cython  
import random 


#Some Global Static Variables 
cdef double WINWARD = 1.00  
cdef double LOSEWARD = -1.00 
cdef (int, int) START = (2,0)
cdef double REWARD = -0.04
cdef int BOARD_ROWS = 3
cdef int BOARD_COLS = 4
cdef (int, int) WIN_STATE = (0, 3)
cdef (int, int) LOSE_STATE = (1, 3)



cdef class Env(): 
    
    #Initialize 
    def __init__(self, (int, int) state=START):
        self.board = np.zeros((BOARD_ROWS, BOARD_COLS), dtype=np.int32)
        self.board[1, 1] = -1
        self.state = state
        self.isTerminal = False
        
        
        
    #Reset Game State to START
    cpdef void reset(self): 
        self.state = START
        
    
    
    #Reward the current state of the environment 
    cdef double giveReward(self):
        if self.state == WIN_STATE:
            return WINWARD
        elif self.state == LOSE_STATE:
            return LOSEWARD
        else:
            return REWARD
        
       
    #Check if the environment is in the terminal state     
    cdef void isEnd(self):
        if (self.state == WIN_STATE) or (self.state == LOSE_STATE):
            self.isTerminal = True
        else: 
            self.isTerminal = False 
    
    
    #Return whether or not the environment is terminal 
    cpdef bint IsTerminal(self): 
        self.isEnd()
        return self.isTerminal    
    
        
    #Function to check if the next action is valid or not
    cdef bint isValidAction(self, (int, int) state, int action): 
        
        cdef  (int, int) nxtState
        
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
        
        
    #Check to see if a state is valid 
    cdef bint isValid(self, (int, int) nxtState): 
       if (nxtState[0] >= 0) and (nxtState[0] <= 2):
               if (nxtState[1] >= 0) and (nxtState[1] <= 3):
                   if nxtState != (1, 1):
                       return True
       return False
   
    
    #Get the state of the environment 
    cpdef (int, int) getState(self): 
        return self.state 
       
        
       
    #Carry out a step in environment 
    cdef void step(self, int action):

        cdef (int, int) nxtState        
        cdef list altActions = list() 
        cdef int altAction 
        cdef (int, int) nxtState1 
        cdef double correctMove 
         
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
                # return self.state, self.giveReward(), self.IsTerminal()
            else:  
                
                
                
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
                    # return self.state, self.giveReward(), self.IsTerminal()
                else: 
                    #Randomly select from the remaining two 
                    self.isEnd()
                    # return self.state, self.giveReward(), self.IsTerminal()
        else: 
                    self.isEnd()
                    # return self.state, self.giveReward(), self.IsTerminal()
                    
                    
    

    #THIS IS THE SAME AS STEP but this shows debugging steps, MAINLY USED IN INTERFACING                
    cpdef void debuggerstep(self, int action):

        cdef (int, int) nxtState        
        cdef list altActions = list() 
        cdef int altAction 
        cdef (int, int) nxtState1 
        cdef double correctMove        
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
                # return nxtState, self.giveReward(), self.isTerminal
                
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
                    # return nxtState1, self.giveReward(), self.isTerminal
                
                #If alternate possibility is not valid, then you stay in place
                else: 
                    #Stay in place 
                    print(self.state)
                    print("Stayed in Place!")
                    self.isEnd()
                    # return self.state, self.giveReward(), self.isTerminal
        else: 
             #Stay in place 
                    print(self.state)
                    print("Invalid action picked, Stayed in Place!")
                    self.isEnd()
                    # return self.state, self.giveReward(), self.isTerminal
                    
                    
    #Get a list of possible actions that can be conducted at current state
    cdef list actionspace(self):
        cdef list actions_allowed = []
        if self.state == WIN_STATE or self.state == LOSE_STATE: 
            return actions_allowed
        
        
        cdef (int, int) nxtState
        
        #Check if up is valid 
        if self.isValid(nxtState =(self.state[0] - 1, self.state[1])): 
            actions_allowed.append(0)
            
        #Check if down is valid 
        if self.isValid(nxtState = (self.state[0] + 1, self.state[1])): 
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
        cdef int i, j
        
        cdef temp1 = self.state[0] 
        cdef temp2 = self.state[1] 
        self.board[temp1, temp2] = 1
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
      
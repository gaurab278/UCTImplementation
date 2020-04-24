import cython 
import random
from UCT import  UCT
from env import Env


def main():
    env = Env((2,0))
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
        
        env.debuggerstep(actionNode.GetAction())
        newEnvState = env.getState() 
        # rwrd = env.giveReward() 
        # done = env.IsTerminal() 
        env = Env(newEnvState)
        print("Resultant Board: ")
        env.showBoard()
        print()
        print("==================================================")
        print("==================================================")
        print()
        

if __name__ == "__main__":
   main()
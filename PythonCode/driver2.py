
import random
from UCT import  UCT
from Utils.env import Env


def main():
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
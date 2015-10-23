import gringo
def id(x):
    return x
 
def seq(x, y):
    return [x, y]
 
def main(prg):
    prg.ground([("base", [])])
    prg.solve()
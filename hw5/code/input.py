from basic import checkKeyReturnValue

class InputFile (object):
    """Store path of configuration files
       according to path of folder given in constructor
    """
    def __init__(self, config_path, i_loc = 1):
        with open(config_path) as f:
            content = f.readlines()
        c = [x for x in content]

        self.name = checkKeyReturnValue(c[0], "name", '=')
        self.A = checkKeyReturnValue(c[1], "A", '=')
        self.B = checkKeyReturnValue(c[2], "B", '=')
        self.C = checkKeyReturnValue(c[3], "C", '=')
        self.writeAllo = checkKeyReturnValue(c[4], "writeAllo", '=')
        self.policy= checkKeyReturnValue(c[5], "policy", '=')
        self.insData = checkKeyReturnValue(c[6], "insData", '=')
        

    def printConfig (self):
        nameList = ["l1", "l2"]
        writeAlloList = ["False", "True"]
        policyList = ["LRU", "RND"]
        insDataList = ["instruction only", "data only", "unified"]

        print("Cache type: %s_%s" %(nameList[self.name], insDataList[self.insData]))
        print("A: %d, B: %d, C: %d" %(self.A, self.B, self.C))
        print("Write Allocate: %s, policy: %s" %(policyList[self.policy], writeAlloList[self.writeAllo]))



if __name__ == '__main__':
    inputfile = InputFile('configuration.txt')
    inputfile.printConfig()

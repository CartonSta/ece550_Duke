import numpy as np

def checkKeyReturnValue(line, key, sep):
    if line.split(sep)[0].strip() != key:
        print "The content before " + sep + " should be " + key \
                + " rather than " + line.split(sep)[0].strip()
        exit
    tmp = line.split(sep)[1].strip('\n ') #remove newline and space
    return int(tmp)


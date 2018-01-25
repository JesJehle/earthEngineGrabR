
l = [1, 2, 3]
n = [3,4,5]


test = range(1,10)
print len(test)

l = range(0, len(test))
print l

for i in range(0, len(test)):
    l[i] = test[i]
    print i
print l
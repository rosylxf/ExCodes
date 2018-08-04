# import re
#
# source = 'Young Frankenstein'
#
# # m = re.match('.*Frank', source)
#
# m = re.search('Frank', source)
#
# if m:
#     print(m.group())

def frange(start, stop, step):
    x = start
    while x < stop:
        yield x
        x += step

for i in frange(10, 20, 0.5):
    print(i)
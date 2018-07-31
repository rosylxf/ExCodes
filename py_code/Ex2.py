# def knight(saying):
#     def inner(bbb):
#         name = saying + bbb
#         return "war are knights who say: '%s'" % name,
#     return inner
#
# a = knight('duck')
# b = knight('Hasenpfeffer')
#
# print(type(a))
# print(type(b))
#
# print(a('abc'))

#### lambda()函数

# def edit_story(words, fun):
#     for word in words:
#         print(fun(word))
#
# def enliven(word):
#     return word.capitalize() + '!'
#
# stairs = ['thud', 'meow', 'thud']
# # edit_story(stairs, enliven)
# edit_story(stairs, lambda word: word.capitalize() + '!')

#装饰器
# def document_it(func):
#     def new_function(*args, **kwargs):
#         print('Runing function:', func.__name__)
#         print('Positional arguments:', args)
#         print('Keyword arguments:', kwargs)
#         result = func(*args, **kwargs)
#         print('Result:', result)
#         return result
#     return new_function

animal = 'fruitbat'
# def print_global():
#     print('inside print_global:', animal)
#
# print_global()

# def change_and_print_global():
#     animal = 'wombat'
#     print('inside change_and_print_global:', animal)
#
#
# change_and_print_global()

# def amazing():
#     print('This function is named:', amazing.__name__)
#     print('And its docstring is:', amazing.__doc__)
#
# amazing()






class Person():
    def __init__(self, name):
        self.name = name

hunter = Person('nonob')

print(hunter.name)

#类的继承


class Teacher(Person):
    pass

zhangsan = Teacher('san')
print(zhangsan.name)
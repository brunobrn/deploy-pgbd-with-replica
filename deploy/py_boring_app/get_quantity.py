from functions import get_quantity
from random import randrange
import time

while True:
    quantity = randrange(2000)
    print(get_quantity(quantity))
    time.sleep(1)

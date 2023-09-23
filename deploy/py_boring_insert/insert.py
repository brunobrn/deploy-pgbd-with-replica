from functions import insert
from random import randrange
import time

while True:
    random = randrange(2000)
    insert(random)
    time.sleep(1)

from functions import boring_report
from random import randrange
import time

while True:
    random = randrange(45)
    boring_report(random)
    time.sleep(5)
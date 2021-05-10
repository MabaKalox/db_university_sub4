import random
import json

taken_val = []
repeated = []
max_repeat = 1


def get_random_unique():
    val = random.randint(1, 255)
    if val in taken_val:
        i = taken_val.index(val)
        while repeated[i] > max_repeat:
            val = random.randint(1, 255)
            if val in taken_val:
                i = taken_val.index(val)
            else:
                break
        repeated[i] += 1
    else:
        taken_val.append(val)
        repeated.append(1)
    return val


def format_output(_data):
    _output = []
    for _row in _data:
        _output.append("(" + ",".join(("'" + v + "'") if isinstance(v, str) else str(v) for v in _row) + ")")

    return ",\n".join(set(_output))


free = [33, 50, 68, 71, 98, 101, 144, 177, 178, 187, 196, 201, 241]
random.shuffle(free)

output = []
for x in random.sample(free, 7):
    output.append([1 if random.randint(1, 100) > 15 else 0, x])
print(format_output(output))

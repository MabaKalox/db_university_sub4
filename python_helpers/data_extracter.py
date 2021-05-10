import random
import json
import datetime

taken_val = []
repeated = []
max_repeat = 3


def get_random_unique():
    val = random.randint(1, 30)
    if val in taken_val:
        i = taken_val.index(val)
        while repeated[i] > max_repeat:
            val = random.randint(1, 30)
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


with open("../source_data.json", "r") as file:
    data = json.loads(file.read())


output = []
for row in data:
    row[0] = int(row[0])
    row[1] = int(row[1])
    row[4] = int(row[4])
    fixed = row[2].split(":")
    if int(fixed[-1]) > 59:
        fixed[-1] = str(random.randint(1, 59))
    if int(fixed[-2]) > 59:
        fixed[-2] = str(random.randint(1, 59))
    row[2] = ":".join(fixed)
    fixed = row[3].split(":")
    if int(fixed[-1]) > 59:
        fixed[-1] = str(random.randint(1, 59))
    if int(fixed[-2]) > 59:
        fixed[-2] = str(random.randint(1, 59))
    row[3] = ":".join(fixed)
    try:
        parsed1 = datetime.datetime.fromisoformat(row[3])
        parsed2 = datetime.datetime.fromisoformat(row[2])
    except:
        print(row[3])
        print(row[2])
        continue
    if random.randint(1, 100) < 40:
        row[3] = None
        row[-1] = None
    output.append(row)

print(format_output(output))

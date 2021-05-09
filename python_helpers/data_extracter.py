import random
import json

taken_val = []
repeated = []
max_repeat = 3


def get_random_unique():
    val = random.randint(1, 200)
    if val in taken_val:
        i = taken_val.index(val)
        while repeated[i] > max_repeat:
            val = random.randint(1, 200)
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
        _output.append("("+",".join(("'"+v+"'") if isinstance(v, str) else str(v) for v in _row)+")")
    return ",\n".join(_output)

def postal_to_id(postal_code):
    for [_id, code] in data["a"]:
        if code == postal_code:
            return _id

with open("../source_data.json", "r") as file:
    data = json.loads(file.read())
    output = []
    for row in data["d"]:
        row[-1] = postal_to_id(row[-1])
        output.append(row)
    print(format_output(output))

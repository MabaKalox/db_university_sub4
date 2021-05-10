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
for i in range(1, 73):
    for _ in range(random.randint(1, 3)):
        create_time = datetime.datetime(random.randint(2012, 2021),
                                        random.randint(1, 12),
                                        random.randint(1, 28),
                                        random.randint(7, 23),
                                        random.randint(1, 59),
                                        random.randint(1, 59))
        deadline_time = create_time + datetime.timedelta(random.randint(1, 60))
        output.append(
            (random.choice(data), create_time.isoformat(), deadline_time.isoformat(),
             0 if random.randint(1, 100) <= 40 else 1, i)
        )

print(format_output(output))

import json


def format_output(_data):
    _output = []
    for _row in _data:
        _output.append("(" + ",".join(("'" + v + "'") if isinstance(v, str) else str(v) for v in _row) + ")")

    return ",\n".join(set(_output))


with open("../json_data/adresses.json", "r") as file:
    data = json.loads(file.read())


class ArrayUnique(list):
    def append_uni(self, value):
        if value in self:
            return False, self.index(value)
        else:
            self.append(value)
            return True, len(self) - 1


countries = ArrayUnique()
countries_insert = []
states = ArrayUnique()
states_insert = []
cities = ArrayUnique()
cities_insert = []
streets = ArrayUnique()
streets_insert = []
addresses_insert = []
for block in data:
    is_street_uni, street_i = streets.append_uni(block[0])
    is_city_uni, city_i = cities.append_uni(block[1])
    is_country_uni, country_i = countries.append_uni(block[3])
    is_state_uni, state_i = states.append_uni(block[5])
    if is_country_uni:
        countries_insert.append([block[3]])
    if is_state_uni:
        states_insert.append([block[5], country_i+1])
    if is_city_uni:
        cities_insert.append([block[1], state_i+1])
    if is_street_uni:
        streets_insert.append([block[0], city_i+1])
    addresses_insert.append([block[2], block[4], street_i+1, block[6]])

print(format_output(countries_insert))
print()
print(format_output(states_insert))
print()
print(format_output(cities_insert))
print()
print(format_output(streets_insert))
print()
print(format_output(addresses_insert))

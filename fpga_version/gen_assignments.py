import sys
import os

project_name = sys.argv[1]



def extract_indexes(string):
    l = string.find("[")
    r = string.find("]")
    if l == -1 or r == -1:
        return False, None, None, None
    else:
        return True, int(string[l + 1:r].split(":")[0]), int(string[l + 1:r].split(":")[1]), string[r + 1:]


script_dir = os.path.dirname(os.path.abspath(__file__))
file_path = os.path.join(script_dir, "DE2_115_PINS")

with open(file_path, "r") as f:
    lines = f.readlines()

pins = {}

for line in lines:
    words = line.split()
    if len(words) < 2:
        continue
    pins[words[0]] = words[1]

assignments = []

with open(f"{project_name}.v") as f:
    lines = f.readlines()

for line in lines:
    line = line.replace(",", "")
    if "// ASSIGN " in line:
        assignment = line.split("// ASSIGN ")[1]
        pin = line.split("// ASSIGN ")[0].split()[-1]

        assignment = assignment.strip()
        pin = pin.strip()

        flag, left, right, pin = extract_indexes(pin)

        if flag:
            for i in range(right, left + 1):
                _, offset, _, _ = extract_indexes(assignment)
                offset -= left
                brace = "["
                assignments.append(
                    f"set_location_assignment {pins[f'{assignment.split(brace)[0]}{i + offset}']} -to {pin}[{i}]\n")
        else:
            pin = line.split("// ASSIGN ")[0].split()[-1]
            pin = pin.strip()
            assignments.append(f"set_location_assignment {pins[f'{assignment}']} -to {pin}\n")


with open(f"{project_name}.qsf", "r+") as f:
    lines = f.readlines()
    for assignment in assignments:
        if assignment in lines:
            continue
        f.write(assignment)
import sys
import re

args = sys.argv
if len(args) <= 1:
    print("Error: Specify file")
    sys.exit()

fileName = args[1]
file = open(fileName, "r+")
content = file.read()
fields = re.findall("let +(\w[\w\d]*:\w[\w\d]*)", content)
structName = re.search("struct +([\w[\w\d]*)", content).group(1)
constructor = "    init(_ map:Dictionary<String, AnyObject>) {\n"
constructorPrefix = constructor

_8_spaces = "        "
for field in fields:
    split = field.split(":")
    name = split[0]
    typeName = split[1]
    defaultValue = "0" if typeName == "Int" else "\"\""
    constructor += _8_spaces
    constructor += name + " = " + "Json.get" + typeName + "(map, \"" + name + "\") ?? " + defaultValue + "\n"
constructor += "    }\n"

constructorIndex = content.find(constructorPrefix)
if constructorIndex >= 0:
    end = content.find("}\n", constructorIndex)
    content = content[:constructorIndex] + content[end + 2:]

print(content)

endIndex = content.rfind("}")
content = content[:endIndex] + constructor + content[endIndex:]
print(content)

arrayFactory = """    public static func to_sArray(array:[[String:AnyObject]]) -> [_] {
        return try! array.map {
            return Event($0)
        }
    }""".replace("_", structName)

if content.find(arrayFactory) < 0:
    endIndex = content.rfind("}")
    content = content[:endIndex] + "\n" + arrayFactory + "\n" + content[endIndex:]

file.seek(0)
file.write(content)
file.truncate()
file.close()

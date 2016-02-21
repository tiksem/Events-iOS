import json
from collections import OrderedDict

config = json.JSONDecoder(object_pairs_hook=OrderedDict).decode(open("config.json", "r").read())
template = open("Template.swift", "r").read()

_8_spaces = "        "
_4_spaces = "    "

for struct in config["structs"]:
    structName = struct["name"]
    content = template.replace("__StructName__", structName)
    content = content.replace("__key__", struct["key"])
    fields = struct["fields"]
    declaration_parts = []
    init_parts = []
    for name, typeName in fields.items():
        defaultValue = 0
        declarationName = name
        declarationType = typeName
        if not name.startswith("var "):
            declarationName = "let " + name
            if type(typeName) is list:
                defaultValue = typeName[1]
                if isinstance(defaultValue, str):
                    defaultValue = "\"" + defaultValue + "\""
                typeName = typeName[0]
                declarationType = typeName + " = " + defaultValue
            elif typeName == "String":
                defaultValue = "\"\""
            init_parts.append(name + " = " + "Json.get" + typeName + "(map, \"" + name + "\") ?? " + str(defaultValue))
        declaration_parts.append(declarationName + ":" + declarationType)

    init = ("\n" + _8_spaces).join(init_parts)
    declaration = ("\n" + _4_spaces).join(declaration_parts)
    content = content.replace("/*init*/", init)
    content = content.replace("/*fields*/", declaration)
    open(structName + ".swift", 'w').write(content)



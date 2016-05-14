import json
from collections import OrderedDict

config = json.JSONDecoder(object_pairs_hook=OrderedDict).decode(open("config.json", "r").read())
template = open("Template.swift", "r").read()

_8_spaces = "        "
_4_spaces = "    "

for struct in config["structs"]:
    structName = struct["name"]
    content = template.replace("__StructName__", structName)
    content = content.replace("__KeyType__", struct.get("keyType", "Int"))
    key = struct["key"]
    if " " in key:
        key = "(" + key + ")"
    content = content.replace("__key__", key)
    fields = struct["fields"]
    declaration_parts = []
    init_parts = []
    manual_init_parts = []
    manual_init_args = []
    for name, typeName in fields.items():
        defaultValue = 0
        declarationName = name
        declarationType = typeName
        isObject = False
        if not name.startswith("var "):
            declarationName = "let " + name
        if not name.startswith("var ") or not declarationType.endswith("?"):
            name = name.replace("var ", "")
            if type(typeName) is list:
                defaultValue = typeName[1]
                if isinstance(defaultValue, str):
                    defaultValue = "\"" + defaultValue + "\""
                typeName = typeName[0]
                declarationType = typeName + " = " + defaultValue
            elif typeName == "String":
                defaultValue = "\"\""
            elif typeName == "Bool":
                defaultValue = "false"
            elif typeName != "Int":
                isObject = True
            if isObject:
                init_parts.append(name + " = " + typeName + "(Json.getDictionary(map, \"" + name + "\")!)")
            else:
                init_parts.append(name + " = " + "Json.get" + typeName + "(map, \"" + name + "\") ?? " +
                                  str(defaultValue))

            manual_init_parts.append("self." + name + " = " + name)
            manual_init_args.append(name + ":" + declarationType)
        declaration_parts.append(declarationName + ":" + declarationType)

    init = ("\n" + _8_spaces).join(init_parts)
    declaration = ("\n" + _4_spaces).join(declaration_parts)
    content = content.replace("/*init*/", init)
    content = content.replace("/*fields*/", declaration)
    content = content.replace("/*manual_init*/", ("\n" + _8_spaces).join(manual_init_parts))
    content = content.replace("__manual_init_args__", (", ").join(manual_init_args))
    open(structName + ".swift", 'w').write(content)

template = open("EnumTemplate.swift", "r").read()
for enum in config["enums"]:
    name = enum["name"]
    content = template.replace("__Name__", name)
    cases = enum["cases"]
    parts = []
    for case in cases:
        parts.append("case " + case + " = \"" + case + "\"")
    content = content.replace("/*cases*/", ("\n" + _4_spaces).join(parts))
    open(name + ".swift", 'w').write(content)




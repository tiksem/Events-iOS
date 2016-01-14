import json
import re
import sys
from collections import OrderedDict

_4_spaces = "    "
_8_spaces = _4_spaces * 2
_12_spaces = _4_spaces * 3

data = json.loads(open("config.json", "r").read())
print(data)

args = sys.argv
if len(args) <= 1:
    print("Error: Specify file")
    sys.exit()

fileName = args[1]
file = open(fileName, "r")
input = file.read()

fileName = args[2]
output = open(fileName, "r+")

baseUrl = data["baseUrl"]
requests = data["requests"]

def find_between(s, first, last):
    start = s.index( first ) + len( first )
    end = s.index( last, start )
    return s[start:end]

def remove_between_including_quotes(s, first, last):
    start = s.index(first)
    end = s.index(last, start) + len(last)
    return s[:start] + s[end:]

def get_lazy_list_type_name(returnType):
    search = re.search("^LazyList<(\w[\d\w]*)>$", returnType)
    if search is not None:
        return search.group(1)
    return None

def get_array_type_name(returnType):
    search = re.search("^\[(\w[\d\w]*)\]$", returnType)
    if search is not None:
        return search.group(1)
    return None

def quote(s):
    return '"' + s + '"'

def generate_base(request, type_name, first_quote, second_quote):
    template = find_between(input, first_quote, second_quote)
    method_name = request["method"]
    template = template.replace("__methodName__", method_name)
    template = template.replace("__ParamName__", type_name)
    url = quote(baseUrl + request.get("url", method_name))
    template = template.replace("__url__", url)
    template = template.replace("__key__", quote(request["key"]))
    return template

def generate_lazy_list_method(request, type_name):
    template = generate_base(request, type_name, "/*lazyList*/", "/*}*/")
    template = template.replace("__limit__", str(request.get("limit", 10)))
    return template

def generate_array_method(request, typeName):
    template = generate_base(request, typeName, "/*array*/", "/*}*/")
    func_args = OrderedDict()
    request_args = OrderedDict()
    args = request["args"]
    for arg in args:
        name = arg["name"]
        argName = arg.get("argName", name)
        func_args[argName] = arg["type"]
        request_args[name] = argName
    func_args_str = ", ".join([key + ":" + value for key, value in func_args.items()])
    template = template.replace("__args__", func_args_str)
    items = [_12_spaces + quote(key) + ": " + value for key, value in request_args.items()]
    request_args_str = "[\n" + (",\n".join(items)) + "\n" + _8_spaces + "]"
    template = template.replace("__request_args__", request_args_str)
    return template

body = ""
for request in requests:
    returnType = request["return"]
    typeName = get_lazy_list_type_name(returnType)
    if typeName is not None:
        body += generate_lazy_list_method(request, typeName)
        continue
    typeName = get_array_type_name(returnType)
    if typeName is not None:
        body += generate_array_method(request, typeName)
        continue

input = remove_between_including_quotes(input, "/*helpers*/", "/*helpersEnd*/")
input = input.replace("/*BODY*/", body)
input = input.replace("class RequestManagerTemplate", "class RequestManager")

print(body)

output.seek(0)
output.write(input)
output.truncate()
output.close()
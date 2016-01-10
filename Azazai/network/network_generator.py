import json
import re
import sys

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

def quote(s):
    return '"' + s + '"'

def generate_lazy_list_method(request, typeName):
    template = find_between(input, "/*lazyList*/", "/*}*/")
    method_name = request["method"]
    template = template.replace("__methodName__", method_name)
    template = template.replace("__ParamName__", typeName)
    template = template.replace("__url__", quote(baseUrl + method_name))
    template = template.replace("__key__", quote(request["key"]))
    template = template.replace("__limit__", str(request.get("limit", 10)))
    return template

body = ""
for request in requests:
    returnType = request["return"]
    typeName = get_lazy_list_type_name(returnType)
    if typeName is not None:
        body += generate_lazy_list_method(request, typeName)

input = remove_between_including_quotes(input, "/*helpers*/", "/*helpersEnd*/")
input = input.replace("/*BODY*/", body)
input = input.replace("class RequestManagerTemplate", "class RequestManager")

output.seek(0)
output.write(input)
output.truncate()
output.close()
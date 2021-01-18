import random
sep = "\t"
def loadRules(fname):
    rules = {}
    with open(fname,"r", encoding = "utf-8") as f:
        for line in f:
            key = line.split(sep)[0]
            textval = line.split(sep)[1].replace("\\n","\n")
            codeval = line.split(sep)[2].replace("\\n","\n")
            if key not in rules:
                rules[key] = []
            rules[key].append([tokenize(textval),codeval]) 
    return rules

def generate(rules, start):
    rule = random.choice(rules[start.strip()])
    code = rule[1]
    
    result = generate2(rules,rule,code)
   # print("%10s:\n    -->%s\n    %50s\n    %50s"%(start,rule[0], result[0],result[1]))
    return result
def generate2(rules,rule, code):
    text = ""
    i = 0
    while i <(len( rule[0])):
        token = rule[0][i]
        if token.startswith("$"):
            #print(token, rule)
            result = generate(rules, token)
            text += result[0]
            code = code.replace(token, result[1],1)
            
        elif token == "{":
            textchoicelist = []
            i+=1
            nextChoice = rule[0][i]
            choice = []
            if nextChoice =="/":
                textchoicelist.append("")
                nextChoice = ""
            while nextChoice != "}":
                i+=1
                choice.append(nextChoice)
                nextChoice = rule[0][i]
                if nextChoice == "}":
                    textchoicelist.append(choice)
                    choice = []
                    break
                if nextChoice == "/":
                    textchoicelist.append(choice)
                    choice = []
                    i+=1
                    nextChoice = rule[0][i]
            codechoicestart = code.find("{")
            codechoiceend = code.find("}")
            codechoicelist = code[codechoicestart+1:codechoiceend].split("/")
            if len(codechoicelist) != len(textchoicelist):
                raise Exception("Aah\n"+str(textchoicelist)+"\n"+str(codechoicelist))
            index = random.randint(0, len(codechoicelist)-1)
            textchoice = textchoicelist[index]
            codechoice = codechoicelist[index]
            result = generate2(rules,[textchoice, tokenize(codechoice)],codechoice)
            text+= result[0]
            codechoice = result[1]
            code = code[:codechoicestart]+codechoice+code[codechoiceend+1:]
        else:
            text+=token

        i+=1
    return[text,code]

def tokenize(rulestring):
    currenttoken =""
    tokens = []
    for letter in rulestring:
        if letter.isalnum() or letter =='"':
            currenttoken+=letter
            continue
        elif letter == "$":
            if currenttoken !="":
                tokens.append(currenttoken)
            currenttoken = "$"
            continue
        
        else:
            if currenttoken !="":
                tokens.append(currenttoken)
            tokens.append(letter)
            currenttoken = ""
    tokens.append(currenttoken)
    return tokens

def main():
    rules = loadRules("cardRules.tsv")
    for i in range(1):
        results = generate(rules,"$Start")
        print("%30s%30s"%(results[0],results[1]))
        
main()

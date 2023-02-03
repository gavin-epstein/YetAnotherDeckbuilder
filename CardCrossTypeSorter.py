# Import Module
import os
import random
# Folder Path
path = "CardFiles/"

# Change the directory


class Trie():
    
    def __init__(self):
        self.branches = {}
        self.cards = []
        self.noimages=[]
    def add(self,card,types, image):
        if len(types) ==0:
            self.cards.append((card,image))
            return
        if types[0] not in self.branches:
            self.branches[types[0]] = Trie()
        self.branches[types[0]].add(card,types[1:], image)
        if not image and card not in self.noimages:
            self.noimages.append(card)
    def get(self,types):
        if len(types) ==0:
            return self.cards
        if types[0] not in self.branches:
            return []
        return self.branches[types[0]].get(types[1:])
    def printNoImages(self):
        for i in noimages:
            print(i, end=", ")
        print("\n")
    def size(self):
        total = len(self.cards)
        for branch in self.branches.values():
            total+=branch.size()
        return total
    def toString(self, tab):
        ret = ""
        ret += ",".join(map(lambda x: str(x[0]).strip().strip('"') , self.cards))
        ret += "\n"
        for key in self.branches.keys():
            ret += tab + key+": "
            ret += self.branches[key].toString(tab+"    ")
           # ret += "\n" + tab
        return ret
def read_text_file(file_path,trie,alltypes):
    card=""
    image = False
    types=[]

    totalcards=0
    totalimages=0
    with open(file_path, 'r') as f:
        for line in f:
                if line.startswith("title") or line.startswith("name"):
                    card = line.split("(")[1].split(")")[0]
                   # print(card.strip('"'), end = "|")
                    totalcards+=1
                elif line.startswith("types"):
                    intypes = line.split("(")[1].split(")")[0].split(",")
                    for t in intypes:
                        t=t.strip().strip('"')
                        types.append(t)
                        if t in alltypes.keys():
                            alltypes[t]+=1
                        else:
                            alltypes[t]=1
                    types.sort()
                elif line.startswith("image"):
                    image = True
                    totalimages+=1
                elif line.strip()=="":
                    if card !="":
                      trie.add(card,types, image)
                    
                    card = ""
                    image = False
                    types =[]
        if card !="":
            
            trie.add(card,types,image)

    return totalcards,totalimages
def pickrandom(trie,alltypes):
    types =[]
    type1 = random.choice(list(alltypes.keys()))
    type2 = random.choice(list(alltypes.keys()))
    while type2==type1:
        type2 = random.choice(list(alltypes.keys()))
    types = [type1,type2]
    if random.uniform(0,1)<.1:
        type3 = random.choice(list(alltypes.keys()))
        while type3==type2 or type3 == type1:
            type3= random.choice(list(alltypes.keys()))
        types.append(type3)
    types.sort()
    return types,trie.get(types)

def main():
    trie = Trie()
    alltypes ={}
    totalcards= 0
    totalimages= 0
# iterate through all file
    os.chdir(path)
    for file in os.listdir():
            # Check whether file is in text format or not
            if file.endswith(".txt"):
                    file_path =  file

                    # call read text file function
                    cards, images = read_text_file(file_path,trie,alltypes)
                    totalcards+=cards
                    totalimages+=images
    trie.printNoImages()
    alltypes.pop("meme");
    alltypes.pop("starter");
    alltypes.pop("void")
    alltypes.pop("evil")
    alltypes["tap"]=True
    printedimage = True
    printedcombo = False
    while not (printedimage and printedcombo):
        types, cards = pickrandom(trie,alltypes)
        if len(cards) == 0 and not printedcombo :#and "light" in types:
            print(types)
            printedcombo = True
    print(random.choice(trie.noimages))
    print("%d/%d cards have images (%.2f%%)" % (totalimages, totalcards, 100.0 * totalimages/totalcards))
    sorttypes = []
    for key in alltypes.keys():
        sorttypes.append((key, alltypes[key]))
    sorttypes = sorted(sorttypes, key = lambda x: x[1])
    for i in range(3):
        print (sorttypes[i])
noimages=[]
main()


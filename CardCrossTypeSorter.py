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
    def add(self,card,types, image):
        if len(types) ==0:
            self.cards.append((card,image))
            return
        if types[0] not in self.branches:
            self.branches[types[0]] = Trie()
        self.branches[types[0]].add(card,types[1:], image)
    def get(self,types):
        if len(types) ==0:
            return self.cards
        if types[0] not in self.branches:
            return []
        return self.branches[types[0]].get(types[1:])


def read_text_file(file_path,trie,alltypes):
    card=""
    image = False
    types=[]
    with open(file_path, 'r') as f:
        for line in f:
                if line.startswith("title") or line.startswith("name"):
                   card = line.split("(")[1].split(")")[0]
                elif line.startswith("types"):
                    intypes = line.split("(")[1].split(")")[0].split(",")
                    for t in intypes:
                        types.append(t.strip().strip('"'))
                        alltypes[t.strip().strip('"')]=True
                    types.sort()
                elif line.startswith("image"):
                    image = True
                elif line.strip()=="":
                    if card !="":
                      trie.add(card,types, image)
                    card = ""
                    image = False
                    types =[]
        if card !="":
            trie.add(card,types,image)
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
# iterate through all file
    os.chdir(path)
    for file in os.listdir():
            # Check whether file is in text format or not
            if file.endswith(".txt"):
                    file_path =  file

                    # call read text file function
                    read_text_file(file_path,trie,alltypes)

    alltypes.pop("meme");
    alltypes.pop("starter");
    alltypes.pop("void")
    alltypes.pop("evil")
    alltypes.pop("typeless")
    while True:
        types, cards = pickrandom(trie,alltypes)
        for card in cards:
            if card[1] == False:
                print( card[0])
                return
        if len(cards) == 0:
            print(types)
            #break

main()

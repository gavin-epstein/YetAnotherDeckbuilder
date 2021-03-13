title(Illuminate)
rarity(15)
types(light)
cost(1)
$Energy=2
trigger(onPlay,do(gainEnergy(2)))
text("Gain $Energy Energy")
removetrigger(endofturn,true,1)

title(Ignite);
types(fire,light);
cost(1);
$Energy=1
trigger(startofturn, do(voided,((select(Hand,true,"pick a card to void (Ignite)")),Hand),false));
trigger(startofturn, do(gainEnergy,($Energy),false));
removetrigger(endofturn, true,3);
text("At the start of your next three turns, void a card in your hand and gain $Energy energy");
rarity(4);
image("res://Images/CardArt/Ignite.png")

title(Luminous Earth);
$Energy=1
text("On draw, gain $Energy energy\n Unplayable.");
cost(-);
trigger(onDraw, do(gainEnergy,($Energy), false));
types(earth,light);
modifiers(unplayable);
rarity(3);
removetrigger(never, true, 0);

title("Clothed in Light");
cost("X");
$X="X"
trigger(onRemoveFromPlay, do(setVar(self,X,X)));
trigger(onPlay, do(armor($X)))
text("Gain X armor");
types("light");
removetrigger(endofturn, true, 4);
rarity(2);

title("Self Immolate");
types(fire,light)
cost(0)
$Energy=2
$Status=1
trigger(onPlay,do(gainEnergy($Energy)))
trigger(onPlay,do(addStatus(flaming,$Energy)))
text("Gain $Energy energy, and $Status burn")
removetrigger(endofturn, true, 1);
rarity(3);

title("Glowing Blood");
$Energy=3
cost(0)
trigger(onPlay,do(move(Play,Reaction,self)));
trigger(onReaction,do(move(Reaction,Play,self)));
trigger(startofturn,do(gainEnergy($Energy)));
removetrigger(endofturn,true,1);
text("Add this to your reaction pile.\n On reaction, at the start of your next turn gain $Energy Energy");
types(fire,reaction);
rarity(7);

title(Black Lettuce);
text("Gain $Energy energy.\nVoid.");
$Energy=3
rarity(1);
trigger(onPlay, do(gainEnergy,($Energy),false));
trigger(onPlay, do(voided,(self, Play),false));
removetrigger(endofturn, true, 0);
types(light,shadow,fire,earth,water,meme);
cost(0);
image("res://Images/CardArt/BlackLettuce.png");

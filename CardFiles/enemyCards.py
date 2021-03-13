title("Toxic Spores")
trigger(onReaction, do(heal(1)));
trigger(onReaction, do(addStatus(bleed,1)));
trigger(onReaction, do(purge,(self),false));
cost(-);
text("Heal 1, gain 1 bleed");
removetrigger(endofturn, true, 0);

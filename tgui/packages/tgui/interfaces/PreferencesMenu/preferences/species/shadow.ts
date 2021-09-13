import { Species } from "./base";

const Shadowperson: Species = {
  description: "Victims of a long extinct space alien. Their flesh is a sickly \
    seethrough filament, their tangled insides in clear view. Their form \
    is a mockery of life, leaving them mostly unable to work with others under \
    normal circumstances.",
  features: {
    good: [{
      icon: "moon",
      name: "Shadowborn",
      description: "Their skin blooms in the darkness. All kinds of damage- \
      no matter how extreme- will heal over time as long as there is no light.",
    }, {
      icon: "eye",
      name: "Nightvision",
      description: "Their eyes have adapted to the night. Their red eyes can \
      see in the dark with no problems.",
    }],
    neutral: [],
    bad: [{
      icon: "sun",
      name: "Lightburn",
      description: "Their skin withers in the light. Any exposure to light is \
      incredibly painful for the shadowperson, charring their skin.",
    }],
  },
  lore: "Nanotrasen has promised the victims of the long extinct \
    \"Shadowling\" that a cure for their ailment would be found... as time \
    goes on, it becomes clearer and clearer that Nanotrasen would rather just \
    wait out the existence of these cursed sufferers, their attention \
    and funding elsewhere.",
};

export default Shadowperson;

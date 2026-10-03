import '../models/pet_name.dart';

// One name per line: name | gender (m, f, u) | style | species (d c r b s f t h, empty for any) | meaning
const _raw = '''
Biscuit|u|food||Crunchy, golden and impossible to resist
Waffles|u|food|d|Soft in the middle, a little crispy around the edges
Pickles|u|food||Small, green-spirited and full of zing
Noodle|u|food|d c|Long, wiggly and always a little silly
Mochi|u|food|c r|A squishy Japanese rice-cake treat
Peanut|u|food|s d|Tiny but full of personality
Nacho|m|food|d c|Cheesy charm with a bit of spice
Pumpkin|u|food|c d|Round, warm and perfect for autumn
Cookie|f|food||Sweet, crumbly and best shared
Muffin|u|food|d c r|A soft little bundle fresh out of the oven
Pretzel|u|food|d|Twisty, salty and a loyal snack companion
Cinnamon|u|food|c d|Warm, spicy and cozy
Ginger|f|food|c|Fiery coat, fierier temper
Pepper|f|food|d c|A little bit spicy, a lot of fun
Olive|f|food|c d|Small, elegant and Mediterranean
Tofu|u|food|c r|Soft, pale and goes with everything
Sushi|u|food|c f|Neat, colorful and loves fish
Bagel|u|food|d|Round, chewy and a breakfast favorite
Dumpling|u|food|d c s|Plump, soft and full of good things
Nugget|u|food|s d b|A small golden treasure
Taco|m|food|d|Crunchy on the outside, full of surprises
Kiwi|u|food|b|Bright green and a little fuzzy
Maple|f|food|d c|Sweet as syrup, bold as autumn leaves
Truffle|f|food|d c|Rare, rich and a little fancy
Brownie|u|food|d|Chocolate-colored and gooey-hearted
Butterscotch|u|food|d c h|Golden, buttery and smooth
Marshmallow|u|food|r c|White, fluffy and squishable
Oreo|u|food|d c r|Black and white and loved by everyone
Cupcake|f|food||Tiny, frosted and full of joy
Popcorn|u|food|s r|Bouncy and always popping around
Toffee|u|food|d c|Sticky sweet and hard to let go of
Mango|u|food|b c|Tropical, sunny and sweet
Basil|m|food|c d|Fresh, green and a little herbaceous
Sprout|u|food|r s t|Small, green and growing fast
Clover|f|nature|r c|Lucky, green and rare with four leaves
Willow|f|nature|c d h|Graceful as a tree bending in the breeze
River|u|nature|d h|Always moving, always calm
Aspen|u|nature|d|Strong, tall and bright like the mountain tree
Hazel|f|nature|d c|Warm brown and clever
Juniper|f|nature|c d|An evergreen with a bright berry spirit
Fern|f|nature|t r|Delicate, green and a little wild
Moss|u|nature|t|Soft, green and quietly content
Pebble|u|nature|t s f|Small, smooth and steady
Storm|u|nature|d h|Powerful, fast and dramatic
Thunder|m|nature|d h|Loud arrival, big presence
Breeze|f|nature|b h|Light, cool and free
Sky|u|nature|b|Wide open and blue
Coral|f|nature|f|Colorful and at home in warm water
Meadow|f|nature|r h|Open fields, sunshine and calm
Birch|m|nature|d|Pale, sturdy and Nordic
Ivy|f|nature|c|Climbs everything, clings to you
Rain|u|nature|c|Soft, soothing and a little moody
Sunny|u|nature|d b|Bright and always happy
Daisy|f|nature|d r|Simple, cheerful and sweet
Poppy|f|nature|d c|Bold, bright and joyful
Rosie|f|nature|d c|Rosy-cheeked and lovely
Lily|f|nature|c|Pure, elegant and graceful
Robin|u|nature|b|A cheerful little songbird
Wren|f|nature|b|Tiny bird, enormous song
Fox|m|nature|d c|Quick, clever and a little sly
Bear|m|nature|d|Big, cuddly and protective
Wolf|m|nature|d|Loyal to the pack, wild at heart
Otter|u|nature|d s|Playful, slippery and loves water
Acorn|u|nature|s|Small now, mighty later
Rocky|m|nature|d t|Solid as a stone
Zeus|m|mythic|d h|King of the Greek gods
Athena|f|mythic|c d|Greek goddess of wisdom
Apollo|m|mythic|d h|Greek god of the sun and music
Artemis|f|mythic|d c|Greek goddess of the hunt and moon
Thor|m|mythic|d|Norse god of thunder
Loki|m|mythic|c d|Norse god of mischief
Freya|f|mythic|c d|Norse goddess of love
Odin|m|mythic|d|All-father of the Norse gods
Hermes|m|mythic|b d|Swift messenger of the Greek gods
Luna|f|mythic|c d|Roman goddess of the moon
Juno|f|mythic|c|Queen of the Roman gods
Merlin|m|mythic|c b|The legendary wizard
Phoenix|u|mythic|b|Rises from the ashes, every time
Draco|m|mythic|t|Latin for dragon
Atlas|m|mythic|d h|Titan who held up the sky
Pegasus|m|mythic|h|The winged horse of legend
Medusa|f|mythic|t|Gorgon whose gaze turns you to stone
Isis|f|mythic|c|Egyptian goddess of magic
Anubis|m|mythic|d|Egyptian god with a jackal's head
Ra|m|mythic|c|Egyptian god of the sun
Gaia|f|mythic|t h|Greek goddess of the earth
Hera|f|mythic|c|Queen of the Greek gods
Ares|m|mythic|d|Greek god of war
Nyx|f|mythic|c|Greek goddess of the night
Kraken|m|mythic|f|The sea monster of legend
Griffin|m|mythic|b d|Part eagle, part lion
Sphinx|u|mythic|c|Keeper of riddles
Nova|f|cosmic|c d|A star that suddenly shines brighter
Orion|m|cosmic|d|The hunter constellation
Comet|u|cosmic|d h|Fast, bright and leaves a trail
Stella|f|cosmic|c d|Latin for star
Cosmo|m|cosmic|d c|The universe, in one small pet
Astro|m|cosmic|d|Made for the stars
Vega|f|cosmic|c|One of the brightest stars in the sky
Sirius|m|cosmic|d|The Dog Star, brightest in the night sky
Mars|m|cosmic|d|The red planet
Venus|f|cosmic|c|The bright evening star
Jupiter|m|cosmic|d|The biggest planet of them all
Saturn|m|cosmic|c|The ringed beauty
Pluto|m|cosmic|d c|Small, far away and still loved
Lyra|f|cosmic|c b|A constellation shaped like a harp
Eclipse|u|cosmic|c|Dark and mysterious
Galaxy|f|cosmic|c|Full of stars
Rocket|m|cosmic|d r|Zero to full speed in a second
Starla|f|cosmic|c|Little star
Meteor|m|cosmic|d|Blazing fast across the sky
Celeste|f|cosmic|c b|Heavenly
Max|m|classic|d|The greatest, in Latin
Bella|f|classic|d c|Beautiful, in Italian
Charlie|u|classic|d c|Free and friendly
Lucy|f|classic|d c|Light
Buddy|m|classic|d|Your best friend, always
Daisy May|f|classic|d|Sweet and old-fashioned
Molly|f|classic|d c|A classic girl's name
Jack|m|classic|d|Cheerful and dependable
Oliver|m|classic|c d|Peaceful as an olive tree
Sophie|f|classic|c d|Wisdom
Teddy|m|classic|d r|Soft, huggable and brave
Rosie Lee|f|classic|c|A cup of tea and a cuddle
Leo|m|classic|c d|Lion-hearted
Milo|m|classic|c d|Gracious and soldierly
Oscar|m|classic|c d|Friend of deer
Felix|m|classic|c|Lucky and happy
Simba|m|classic|c d|Lion, in Swahili
Coco|f|classic|d c|Elegant and chic
Ruby|f|classic|d c|A deep red gemstone
Sadie|f|classic|d|Princess
Bailey|u|classic|d|A steward, always on duty
Toby|m|classic|d c|God is good
Ziggy|m|classic|d c|Victorious and a little zany
Winston|m|classic|d|Joyful stone, a statesman's name
Penny|f|classic|d c|Small, shiny and lucky
Frankie|u|classic|d c|Free and frank
Archie|m|classic|d|Genuine and bold
Rufus|m|classic|d|Red-haired
Bruno|m|tough|d|Brown and strong
Tank|m|tough|d t|Unstoppable
Diesel|m|tough|d|Built for power
Brutus|m|tough|d|Heavy and fearless
Rex|m|tough|d t|King
Duke|m|tough|d|Noble leader
Blaze|m|tough|d h|Burns bright and fast
Bolt|m|tough|d|As quick as lightning
Spike|m|tough|t d|Sharp edges, soft heart
Titan|m|tough|d|Giant among giants
Rambo|m|tough|d|Never backs down
Gunner|m|tough|d|Always ready for action
Maverick|m|tough|d h|An independent spirit
Ranger|m|tough|d h|Explorer and protector
Xena|f|tough|d|Warrior princess
Valkyrie|f|tough|d h|Chooser of the brave
Raven|f|tough|c b|Dark, clever and bold
Onyx|u|tough|c d|Black stone, strong spirit
Ace|m|tough|d|The best of the deck
Rogue|u|tough|c|Lives by their own rules
Princess|f|fancy|c d|Royalty, and knows it
Duchess|f|fancy|c|Elegant and a bit aloof
Sir Reginald|m|fancy|c d|A gentleman of distinguished whiskers
Lady Belle|f|fancy|c d|Poised, polished and proper
Baron|m|fancy|d c h|Lord of the household
Countess|f|fancy|c|Old money, new collar
Earl Grey|m|fancy|c|Refined, like a fine cup of tea
Pearl|f|fancy|c f|Rare and luminous
Diamond|f|fancy|c h|Brilliant and unbreakable
Sapphire|f|fancy|c b|Deep blue elegance
Velvet|f|fancy|c r|Soft and luxurious
Bijou|f|fancy|c d|A little jewel, in French
Monsieur|m|fancy|c d|A very French gentleman
Chanel|f|fancy|d c|Timeless style
Gatsby|m|fancy|d c|Throws the best parties
Fitzgerald|m|fancy|d|Distinguished and literary
Dior|f|fancy|c|Haute couture whiskers
Opal|f|fancy|c|Shimmers with every color
Regal|u|fancy|h|Born to be admired
Mr. Whiskers|m|funny|c|Exactly what it sounds like
Sir Barks-a-Lot|m|funny|d|Has opinions about the mailman
Chairman Meow|m|funny|c|Leads the household with an iron paw
Fuzzy Wuzzy|u|funny|r c|Was he fuzzy? He was
Captain Fluff|m|funny|c r|Commander of the couch
Meatball|u|funny|d|Round, beloved and saucy
Potato|u|funny|d c|Couch potato, literally
Pudding|u|funny|d c|Wobbly and sweet
Wiggles|u|funny|d s|Can't sit still
Bubbles|u|funny|f|Blows them all day long
Sir Hops-a-Lot|m|funny|r|Professional jumper
Squeaky|u|funny|s|You'll hear them before you see them
Professor Paws|m|funny|d c|Knows a lot, mostly about snacks
Admiral Fishbones|m|funny|f c|Commands the aquarium
Doctor Hoot|m|funny|b|Wise beyond his feathers
Bark Twain|m|funny|d|A literary dog
Catrick Swayze|m|funny|c|Nobody puts this cat in a corner
Hairy Pawter|m|funny|c d|The cat who lived
Fishy McFishface|u|funny|f|Elected by popular vote
Tater Tot|u|funny|d s|Small, crispy and golden
Chewbarka|m|funny|d|Fluffy co-pilot
Sherlock Bones|m|funny|d|Can sniff out any snack
Count Snackula|m|funny|d c|Only comes out at dinner time
Shellby|f|funny|t|A turtle with a sense of humor
Speedy|m|funny|t|Ironically slow
Fluffy|u|cute|c r d|Fluffiness level: maximum
Button|u|cute|c r s|Small and cute as a button
Bunny|f|cute|r|Hop hop
Pip|u|cute|b s|Small seed, big spirit
Sprinkles|f|cute|c d|Adds color to every day
Snowball|u|cute|c r|White and round
Smudge|u|cute|c|A little dark spot of love
Pixie|f|cute|c d|Small, magical and mischievous
Bean|u|cute|c d s|Tiny and wholesome
Boo|u|cute|c d|Little sweetheart
Dot|f|cute|c b|Little and perfectly round
Teacup|f|cute|d c|Small enough to fit in one
Tinkerbell|f|cute|c d|A fairy with attitude
Dimple|f|cute|d|The sweetest smile
Honey|f|cute|d c|Sweet and golden
Bubba|m|cute|d|A big, sweet baby
Squishy|u|cute|r s|Begs to be hugged
Peaches|f|cute|c d|Fuzzy and sweet
Cuddles|u|cute|r d c|Lives for a hug
Snuggles|u|cute|c r|Professional snuggler
Pom Pom|u|cute|d r|A fluffy cheerleader
Chickpea|u|cute|s b|Small and round
Tiny|u|cute|d s|Small but mighty
Nibbles|u|cute|r s|Always munching
Paws|u|cute|c d|Four of the best
Whiskers|u|cute|c|Sensitive and curious
Bluebell|f|cute|b r|A delicate blue flower
Goldie|f|cute|f d|Shines like gold
Finn|m|cute|f d|Fair, and a fine swimmer
Nemo|m|cute|f|Small fish, big adventure
Shelly|f|cute|t f|Comes with her own home
Polly|f|cute|b|Wants a cracker
Tweety|u|cute|b|A sweet little singer
Hammy|m|cute|s|Round, fluffy and loves wheels
Pumba|m|funny|s d|Hakuna matata
''';

const _codes = {'d': Species.dog, 'c': Species.cat, 'r': Species.rabbit, 'b': Species.bird, 's': Species.small, 'f': Species.fish, 't': Species.reptile, 'h': Species.horse};

const _genders = {'m': Gender.male, 'f': Gender.female, 'u': Gender.neutral};

/// Every name in the catalog, parsed once.
final List<PetName> catalog = _raw
    .trim()
    .split('\n')
    .map((line) {
      final parts = line.split('|');
      return PetName(
        name: parts[0],
        gender: _genders[parts[1]]!,
        style: NameStyle.values.byName(parts[2]),
        species: parts[3].split(' ').where((c) => c.isNotEmpty).map((c) => _codes[c]!).toSet(),
        meaning: parts[4],
      );
    })
    .toList(growable: false);

/// Themed sets for naming a whole litter.
const litterThemes = <String, List<String>>{
  '🍰 Desserts': ['Cupcake', 'Brownie', 'Muffin', 'Cookie', 'Toffee', 'Truffle', 'Pudding', 'Sprinkles', 'Mochi', 'Macaron', 'Tiramisu', 'Eclair'],
  '🪐 Planets': ['Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto', 'Luna', 'Nova', 'Comet', 'Orion'],
  '💎 Gems': ['Ruby', 'Sapphire', 'Opal', 'Pearl', 'Jade', 'Onyx', 'Amber', 'Topaz', 'Garnet', 'Diamond', 'Emerald', 'Jasper'],
  '⚡ Greek gods': ['Zeus', 'Hera', 'Athena', 'Apollo', 'Artemis', 'Hermes', 'Ares', 'Nyx', 'Gaia', 'Atlas', 'Iris', 'Eros'],
  '🌶️ Spices': ['Pepper', 'Ginger', 'Cinnamon', 'Basil', 'Saffron', 'Nutmeg', 'Paprika', 'Clove', 'Sage', 'Thyme', 'Cumin', 'Mint'],
  '☁️ Weather': ['Storm', 'Thunder', 'Breeze', 'Rain', 'Sunny', 'Misty', 'Frost', 'Hail', 'Cloud', 'Snowy', 'Rainbow', 'Gale'],
  '🎨 Artists': ['Picasso', 'Frida', 'Monet', 'Dali', 'Van Gogh', 'Matisse', 'Banksy', 'Klimt', 'Rembrandt', 'Warhol', 'Degas', 'Kahlo'],
  '🌸 Flowers': ['Daisy', 'Poppy', 'Lily', 'Rosie', 'Violet', 'Iris', 'Tulip', 'Jasmine', 'Lavender', 'Magnolia', 'Dahlia', 'Peony'],
};

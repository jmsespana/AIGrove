/// Kini ang nag-store sa complete details sa kada species
class MangroveSpecies {
  final String scientificName;
  final String commonName;
  final String localName;
  final String description;
  final String habitat;
  final String location;
  final List<String> characteristics;
  final String imagePath;

  MangroveSpecies({
    required this.scientificName,
    required this.commonName,
    required this.localName,
    required this.description,
    required this.habitat,
    required this.location,
    required this.characteristics,
    this.imagePath = '',
  });

  /// Database ng all mangrove species information
  static final Map<String, MangroveSpecies> speciesDatabase = {
    'Avicennia Marina': MangroveSpecies(
      scientificName: 'Avicennia Marina',
      commonName: 'Grey Mangrove',
      localName: 'Bungalon',
      description:
          'A common mangrove species found in coastal areas. It is characterized by its grey-green leaves and pencil-like aerial roots (pneumatophores) that project upward from the mud.',
      habitat:
          'Grows in intertidal zones, particularly in areas with high salinity. Prefers muddy to sandy substrates in sheltered bays and estuaries.',
      location:
          'Found in Caraga Region (Region XIII), particularly in coastal areas of Agusan del Norte, Agusan del Sur, Surigao del Norte (especially Siargao and mainland coasts), Surigao del Sur, and Dinagat Islands. Common in mangrove forests along Butuan Bay and Lianga Bay.',
      characteristics: [
        'Grey-green elliptical leaves with salt-excreting glands',
        'Pencil-like pneumatophores (breathing roots)',
        'Yellow-orange flowers in clusters',
        'Can tolerate high salinity levels',
        'Height: 3-10 meters',
      ],
    ),
    'Avicennia Officinalis': MangroveSpecies(
      scientificName: 'Avicennia Officinalis',
      commonName: 'Indian Mangrove',
      localName: 'Piapi',
      description:
          'A medium-sized mangrove tree with distinctive glossy leaves. Known for its medicinal properties and ability to thrive in highly saline environments.',
      habitat:
          'Typically found in middle to seaward zones of mangrove forests. Tolerates varying salinity levels and grows well in mudflats and coastal areas.',
      location:
          'Found in Caraga Region coastal areas, particularly in Agusan del Norte (Butuan Bay area), Surigao del Sur (especially Bislig and Tandag coastal zones), and scattered locations in Dinagat Islands and Siargao.',
      characteristics: [
        'Glossy, bright green leaves',
        'Numerous pneumatophores surrounding the trunk',
        'Orange-yellow flowers',
        'Elliptical to oval-shaped fruits',
        'Height: 5-15 meters',
      ],
    ),
    'Bruguiera Cylindrica': MangroveSpecies(
      scientificName: 'Bruguiera Cylindrica',
      commonName: 'Cylindric Mangrove',
      localName: 'Busain',
      description:
          'A medium-sized mangrove tree characterized by its cylindrical propagules and distinctive knee roots. Important for coastal protection.',
      habitat:
          'Grows in mid to landward zones of mangrove forests. Prefers areas with moderate tidal influence and muddy substrates.',
      location:
          'Found in Caraga Region, particularly in Agusan del Norte and Agusan del Sur river deltas, coastal areas of Surigao del Norte and Surigao del Sur, and protected bays in Dinagat Islands.',
      characteristics: [
        'Elliptical leaves with pointed tips',
        'Knee-shaped aerial roots',
        'White to cream colored flowers',
        'Long cylindrical propagules',
        'Height: 5-20 meters',
      ],
    ),
    'Bruguiera Gymnorhiza': MangroveSpecies(
      scientificName: 'Bruguiera Gymnorhiza',
      commonName: 'Large-leafed Mangrove',
      localName: 'Pototan',
      description:
          'One of the largest mangrove species, known for its distinctive knee roots and large leaves. Provides excellent habitat for fish and crustaceans.',
      habitat:
          'Thrives in areas with regular tidal inundation. Prefers muddy substrates in estuaries and coastal areas with freshwater influence.',
      location:
          'Abundant in Caraga Region, especially in Agusan Marsh Wildlife Sanctuary (Agusan del Sur), Butuan Bay (Agusan del Norte), Lianga Bay (Surigao del Sur), and river estuaries in Surigao del Norte including Siargao wetlands.',
      characteristics: [
        'Large, oval-shaped leaves (10-20 cm long)',
        'Prominent knee roots for breathing',
        'Red to orange flowers with curved petals',
        'Very long propagules (20-40 cm)',
        'Height: up to 30 meters',
      ],
    ),
    'Ceriops Tagal': MangroveSpecies(
      scientificName: 'Ceriops Tagal',
      commonName: 'Spurred Mangrove',
      localName: 'Tangal',
      description:
          'A small to medium-sized mangrove with distinctive ridged bark and small leaves. Highly valued for its durable timber.',
      habitat:
          'Grows in areas with moderate to high salinity. Commonly found in the mid to seaward zones of mangrove forests.',
      location:
          'Common in Caraga Region coastal areas, particularly in Surigao del Sur (Bislig and Tandag coasts), Agusan del Norte, and mangrove forests of Dinagat Islands and Siargao.',
      characteristics: [
        'Small, elliptical leaves with rounded tips',
        'Deeply fissured, ridged bark',
        'White flowers with five petals',
        'Short, cigar-shaped propagules',
        'Height: 6-15 meters',
      ],
    ),
    'Excoecaria Agallocha': MangroveSpecies(
      scientificName: 'Excoecaria Agallocha',
      commonName: 'Milky Mangrove / Blind-your-eye',
      localName: 'Buta-buta',
      description:
          'A highly toxic mangrove species with milky white sap. The sap can cause severe eye irritation and temporary blindness, hence its common names.',
      habitat:
          'Typically found in the landward zones of mangrove forests. Grows in areas with less frequent tidal inundation.',
      location:
          'Found in Caraga Region, particularly in Agusan del Sur (including Agusan Marsh areas), Surigao del Norte and Surigao del Sur landward mangrove zones, and scattered locations in Dinagat Islands.',
      characteristics: [
        'Bright green, glossy leaves that turn red before falling',
        'Contains toxic milky white latex',
        'Small greenish-yellow flowers',
        'No visible aerial roots',
        'Height: 5-15 meters',
      ],
    ),
    'Lumnitzera Littorea': MangroveSpecies(
      scientificName: 'Lumnitzera Littorea',
      commonName: 'Black Mangrove',
      localName: 'Kulasi',
      description:
          'A small mangrove tree or shrub with beautiful red flowers. Important for stabilizing coastal areas and preventing erosion.',
      habitat:
          'Grows in the seaward zones and coastal fringes. Tolerates high wave action and rocky substrates.',
      location:
          'Found in scattered locations in Caraga Region, more common in rocky coastal areas of Siargao (Surigao del Norte), Dinagat Islands, and exposed coastal zones of Surigao del Sur.',
      characteristics: [
        'Small, fleshy oval leaves',
        'Bright red, showy flowers',
        'Grows on rocky to sandy substrates',
        'No aerial roots',
        'Height: 3-8 meters',
      ],
    ),
    'Nypa Fruticans': MangroveSpecies(
      scientificName: 'Nypa Fruticans',
      commonName: 'Nipa Palm',
      localName: 'Nipa / Sasa',
      description:
          'The only palm species in the mangrove ecosystem. Widely used for thatching, weaving, and production of alcohol and vinegar from its sap.',
      habitat:
          'Grows along riverbanks and in areas with brackish water. Prefers muddy substrates with freshwater influence.',
      location:
          'Extremely common throughout Caraga Region, found in virtually all coastal areas, particularly abundant in Agusan River delta, Butuan Bay, river estuaries in Surigao provinces, and coastal areas of Dinagat and Siargao islands.',
      characteristics: [
        'Palm-like appearance with no visible trunk',
        'Large, pinnate leaves (5-9 meters long)',
        'Grows in dense colonies',
        'Round, woody fruits in large clusters',
        'Horizontal underground stem',
      ],
    ),
    'Rhizophora Apiculata': MangroveSpecies(
      scientificName: 'Rhizophora Apiculata',
      commonName: 'Tall-stilted Mangrove',
      localName: 'Bakhaw Lalaki / Bakauan Lalaki',
      description:
          'One of the most common and important mangrove species in the Philippines. Known for its distinctive stilt roots and excellent wood quality.',
      habitat:
          'Thrives in areas with regular tidal inundation. Prefers muddy substrates in estuaries and coastal areas.',
      location:
          'Widely distributed across Caraga Region, particularly abundant in Agusan del Norte (Butuan Bay), Agusan del Sur (Agusan Marsh), Surigao del Sur (Lianga Bay, Bislig Bay), and major mangrove forests in Surigao del Norte and Dinagat Islands.',
      characteristics: [
        'Distinctive stilt roots (prop roots)',
        'Elliptical leaves with pointed tips',
        'Cream to pale yellow flowers',
        'Long, pendulous propagules (20-40 cm)',
        'Height: 20-30 meters',
      ],
    ),
    'Rhizophora Mucronata': MangroveSpecies(
      scientificName: 'Rhizophora Mucronata',
      commonName: 'Loop-root Mangrove',
      localName: 'Bakhaw Babae / Bakauan Babae',
      description:
          'Similar to R. apiculata but with broader leaves and more loop-like stilt roots. Important for coastal protection and fisheries.',
      habitat:
          'Grows in areas with regular to frequent tidal inundation. Common in the seaward to mid zones of mangrove forests.',
      location:
          'Found throughout Caraga Region, especially in Agusan del Norte (coastal Butuan areas), Surigao del Sur (Bislig, Tandag, Lianga coasts), Surigao del Norte, and major mangrove areas in Dinagat Islands and Siargao.',
      characteristics: [
        'Stilt roots forming loops',
        'Broader, more rounded leaves than R. apiculata',
        'Cream-colored flowers',
        'Very long propagules (40-70 cm)',
        'Height: 15-27 meters',
      ],
    ),
    'Rhizophora Stylosa': MangroveSpecies(
      scientificName: 'Rhizophora Stylosa',
      commonName: 'Spotted Mangrove',
      localName: 'Bakhaw Bato',
      description:
          'A medium-sized mangrove with fewer stilt roots compared to other Rhizophora species. Often found in rocky areas.',
      habitat:
          'Grows in rocky to muddy substrates. Tolerates more exposed coastal conditions than other Rhizophora species.',
      location:
          'Found in scattered locations in Caraga Region, more common in rocky coastal areas of Siargao (Surigao del Norte), Dinagat Islands, and exposed rocky zones of Surigao del Sur coastline.',
      characteristics: [
        'Fewer and more spread out stilt roots',
        'Small, pointed leaves with distinctive spots',
        'White to cream flowers',
        'Shorter propagules (15-25 cm)',
        'Height: 10-15 meters',
      ],
    ),
    'Sonneratia Alba': MangroveSpecies(
      scientificName: 'Sonneratia Alba',
      commonName: 'Mangrove Apple',
      localName: 'Pagatpat / Pedada Puti',
      description:
          'A large mangrove tree with beautiful white flowers that bloom at night. The fruits are edible and used in local cuisine.',
      habitat:
          'Typically found in the seaward zones. Prefers areas with strong tidal influence and can grow in sandy to muddy substrates.',
      location:
          'Common in Caraga Region, particularly in seaward zones of Surigao del Norte (including Siargao), Surigao del Sur, Agusan del Norte coastal areas, and Dinagat Islands mangrove forests.',
      characteristics: [
        'Conical pneumatophores surrounding the trunk',
        'Large, oval leaves',
        'Large white flowers that open at night',
        'Round, apple-like edible fruits',
        'Height: 15-25 meters',
      ],
    ),
    'Sonneratia Caseolaris': MangroveSpecies(
      scientificName: 'Sonneratia Caseolaris',
      commonName: 'Cork Mangrove',
      localName: 'Pedada / Pagatpat Pula',
      description:
          'Similar to S. alba but with red-tinged flowers. The wood is lightweight and used for making floats and corks.',
      habitat:
          'Grows in areas with freshwater influence, often along riverbanks and in estuaries. Prefers muddy substrates.',
      location:
          'Found in various locations across Caraga Region, more common in areas with significant freshwater input such as Agusan River delta, Butuan Bay estuaries, and river mouths in Surigao del Norte and Surigao del Sur.',
      characteristics: [
        'Numerous conical breathing roots',
        'Oval to elliptical leaves',
        'Red to pink flowers',
        'Round fruits similar to S. alba',
        'Height: 15-20 meters',
      ],
    ),
    'Sonneratia Ovata': MangroveSpecies(
      scientificName: 'Sonneratia Ovata',
      commonName: 'Ovate-leaved Mangrove Apple',
      localName: 'Pagatpat',
      description:
          'A mangrove species with distinctive ovate leaves. Less common than other Sonneratia species but ecologically important.',
      habitat:
          'Grows in coastal areas with moderate tidal influence. Prefers muddy substrates in estuaries.',
      location:
          'Found in selected locations in Caraga Region, particularly in Agusan del Norte and Agusan del Sur estuarine areas, and some coastal zones in Surigao del Sur.',
      characteristics: [
        'Ovate (egg-shaped) leaves',
        'Cone-shaped pneumatophores',
        'Pink to white flowers',
        'Round, edible fruits',
        'Height: 10-18 meters',
      ],
    ),
    'Xylocarpus Granatum': MangroveSpecies(
      scientificName: 'Xylocarpus Granatum',
      commonName: 'Cannonball Mangrove',
      localName: 'Tabigi / Bungalon',
      description:
          'Named for its large, round, cannonball-like fruits. The wood is highly valued for its durability and resistance to marine borers.',
      habitat:
          'Typically found in the landward zones of mangrove forests. Grows in areas with less frequent tidal inundation.',
      location:
          'Found in Caraga Region, particularly in Agusan del Norte and Agusan del Sur landward mangrove zones, Surigao del Sur (inland mangrove areas of Bislig and Tandag), and scattered locations in Surigao del Norte.',
      characteristics: [
        'Large buttressed trunk',
        'Pinnate compound leaves',
        'Small white to pink flowers',
        'Large, round woody fruits (8-20 cm diameter)',
        'Height: 10-20 meters',
      ],
    ),
  };

  /// Get species information by scientific name
  /// Gina-trim og gina-normalize ang name para sure na makit-an
  static MangroveSpecies? getSpeciesInfo(String scientificName) {
    // Trim whitespace and try exact match first
    final trimmedName = scientificName.trim();
    
    // Try exact match
    if (speciesDatabase.containsKey(trimmedName)) {
      return speciesDatabase[trimmedName];
    }
    
    // Try case-insensitive match
    final lowerName = trimmedName.toLowerCase();
    for (var entry in speciesDatabase.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value;
      }
    }
    
    return null;
  }
}

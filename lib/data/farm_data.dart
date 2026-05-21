// ════════════════════════════════════════════════════════════════
// FARM DATA — FarmConnect Kenya
// ════════════════════════════════════════════════════════════════

// ── Crops ────────────────────────────────────────────────────────

const Map<String, List<String>> kCropVarieties = {
  'Maize':              ['H614D (Hybrid)', 'H6213 (Hybrid)', 'DK8031 (Pioneer)', 'SC403 (Seed Co)', 'Katumani (Drought Tolerant)', 'WH507 (Open Pollinated)', 'H625 (Hybrid)', 'DH04 (Drought Tolerant)'],
  'Beans':              ['Rose Coco', 'Canadian Wonder', 'Mwitemania', 'Faida (Bush)', 'GLP-2 (Climbing)', 'Jesca (Climbing)', 'Lyamungu 85'],
  'Tomatoes':           ['Tengeru 97', 'Rio Grande', 'Money Maker', 'Anna F1', 'Prostar F1', 'Bramble F1', 'Tylka F1', 'Kilele F1'],
  'Potatoes':           ['Shangi', 'Tigoni', 'Kenya Mpya', 'Dutch Robjin', 'Asante', 'Unica', 'Desiree', 'Safari'],
  'Wheat':              ['Eagle 10', 'Fahari', 'Duma', 'Kenya Swara', 'Njoro BW1', 'Njoro BW2'],
  'Tea (Green Leaf)':   ['TRFK 6/8', 'TRFK 31/8', 'SFS150', 'Purple Tea', 'BBK35', 'TRFK 303/577'],
  'Coffee (Cherry)':    ['Ruiru 11', 'Batian', 'SL28', 'SL34', 'K7', 'Blue Mountain'],
  'Avocado (Fruit)':    ['Hass', 'Fuerte', 'Jumbo', 'Pinkerton', 'Reed', 'Nabal', 'Ettinger', 'GEM'],
  'Onions':             ['Red Creole', 'Jambar F1', 'Bombay Red', 'Red Pinoy F1', 'Belstar F1', 'Texas Grano'],
  'Cabbage':            ['Gloria F1', 'Pruktor F1', 'Oxylus F1', 'Copenhagen Market', 'Kilimo F1'],
  'Kale (Sukuma Wiki)': ['Thousand Headed', 'Marrow Stem', 'Georgia', 'Bora F1', 'Siku F1'],
  'Sorghum':            ['Gadam', 'Serena', 'KARI Mtama 1', 'Seredo', 'Macia'],
  'Rice':               ['Komboka', 'Basmati 370', 'TXD-306', 'IR2793', 'BW196'],
  'Bananas':            ['Williams', 'Grand Nain', 'Cavendish', 'Pisang Awak', 'Muraru', 'Bogoya'],
  'Mangoes (Fruit)':    ['Apple', 'Tommy Atkins', 'Kent', 'Ngowe', 'Boribo', 'Van Dyke', 'Sensation'],
  'Sugarcane':          ['Co 421', 'N14', 'N19', 'N52', 'EAK69-313'],
  'Cassava':            ['Migyera', 'Tajirika', 'Karembo', 'Mkombozi', 'Serere 25'],
  'Spinach':            ['Texas Savoy', 'Malabar', 'New Zealand', 'Bloomsdale'],
  'Groundnuts':         ['Makulu Red', 'Natal Common', 'Homa Bay', 'ICGV 86699', 'Nyota'],
  'Sunflower':          ['Sunco', 'Record', 'Hysun 33', 'PAN 7351', 'Challenger'],
  'Sweet Potatoes':     ['Kabode', 'Ejumula', 'KSP20', 'Zapallo', 'Wagabolige'],
  'Cowpeas':            ['M66', 'K80', 'KVU 27-1', 'Kunde 1', 'Kunde 2'],
  'Green Grams':        ['N26', 'KS20', 'Biashara', 'Pesa 1', 'Lifelong'],
  'Peas':               ['Meteor', 'Little Marvel', 'Oregon Sugar Pod', 'Telephone'],
  'Carrots':            ['Nantes', 'Chantenay', 'Dordogne F1', 'Maestro F1'],
  'Watermelon':         ['Sugar Baby', 'Crimson Sweet', 'Charleston Grey', 'Sukari F1'],
  'Capsicum':           ['California Wonder', 'Yolo Wonder', 'Domino F1', 'Commanche F1'],
  'Eggplant':           ['Black Beauty', 'Long Purple', 'Brinco F1'],
  'Lettuce':            ['Great Lakes', 'Iceberg', 'Romaine', 'Red Oak'],
  'Garlic':             ['Creole Red', 'Silverskin', 'Local Variety'],
  'Macadamia (Nut)':    ['KMAC 1', 'KMAC 2', 'Beaumont', 'Keauhou'],
  'Passion Fruit':      ['Purple Passion', 'Yellow Passion', 'Hybrid F1'],
  'Pawpaw':             ['Solo', 'Sunrise Solo', 'Bettina', 'Hong Kong'],
  'Pineapple':          ['Smooth Cayenne', 'MD2 (Del Monte Gold)', 'Queen Victoria'],
  'Strawberry':         ['Chandler', 'Douglas', 'Tioga'],
  'Pyrethrum':          ['Kenya Selection', 'White Star'],
  'Cotton':             ['UK 91', 'BPA 97', 'HART 89-B'],
  'Miraa (Khat)':       ['Local Variety', 'Giza', 'Meru Variety'],
  'Pumpkins':           ['Jap', 'Flat White Boer', 'Butternut', 'Grey Zucchini'],
  'Other':              ['Local Variety', 'Custom Variety'],
};

const Map<String, String> kCropEmojis = {
  'Maize': '🌽', 'Beans': '🫘', 'Tomatoes': '🍅', 'Potatoes': '🥔',
  'Wheat': '🌾', 'Tea (Green Leaf)': '🍵', 'Coffee (Cherry)': '☕',
  'Avocado (Fruit)': '🥑', 'Onions': '🧅', 'Cabbage': '🥬',
  'Kale (Sukuma Wiki)': '🥬', 'Spinach': '🥬', 'Sorghum': '🌾',
  'Rice': '🍚', 'Bananas': '🍌', 'Mangoes (Fruit)': '🥭',
  'Sugarcane': '🎋', 'Cassava': '🥕', 'Groundnuts': '🥜',
  'Sunflower': '🌻', 'Sweet Potatoes': '🍠', 'Cowpeas': '🫘',
  'Green Grams': '🫘', 'Peas': '🟢', 'Carrots': '🥕',
  'Watermelon': '🍉', 'Pumpkins': '🎃', 'Capsicum': '🫑',
  'Eggplant': '🍆', 'Lettuce': '🥬', 'Garlic': '🧄',
  'Macadamia (Nut)': '🥜', 'Passion Fruit': '🟣', 'Pawpaw': '🟠',
  'Pineapple': '🍍', 'Strawberry': '🍓', 'Pyrethrum': '🌼',
  'Cotton': '⚪', 'Miraa (Khat)': '🌿', 'Other': '🌱',
};

// Days to harvest. For trees, two options are given:
// [daysFromSeedling, daysForEstablishedTree]
// For annuals, just one value.
const Map<String, Map<String, dynamic>> kCropHarvestInfo = {
  // ── Vegetables & annuals ────────────────────────────────────
  'Spinach':            {'days': 45,  'type': 'annual',    'note': '6-7 weeks. Cut outer leaves, plant keeps growing.'},
  'Lettuce':            {'days': 55,  'type': 'annual',    'note': '7-8 weeks from transplant.'},
  'Kale (Sukuma Wiki)': {'days': 60,  'type': 'annual',    'note': 'First cut at 60 days. Harvest outer leaves continuously.'},
  'Green Grams':        {'days': 65,  'type': 'annual',    'note': '9-10 weeks. Pesa 1 is fastest at 65 days.'},
  'Cowpeas':            {'days': 70,  'type': 'annual',    'note': '10 weeks for fresh pods, 14 weeks for dry grain.'},
  'Peas':               {'days': 70,  'type': 'annual',    'note': '10 weeks for fresh pods.'},
  'Beans':              {'days': 75,  'type': 'annual',    'note': '10-11 weeks. Climbing varieties take 90+ days.'},
  'Carrots':            {'days': 80,  'type': 'annual',    'note': '70-90 days. Harvest when shoulders are 2-3cm wide.'},
  'Tomatoes':           {'days': 80,  'type': 'annual',    'note': '75-90 days from transplanting to first ripe fruit.'},
  'Cabbage':            {'days': 80,  'type': 'annual',    'note': '80-100 days. Heads ready when firm to press.'},
  'Eggplant':           {'days': 80,  'type': 'annual',    'note': '75-90 days from transplant. Harvest before fully ripe.'},
  'Maize':              {'days': 90,  'type': 'annual',    'note': '3 months for hybrid, 4 months for OPV varieties.'},
  'Capsicum':           {'days': 90,  'type': 'annual',    'note': '3 months from transplanting. Green stage or wait for red.'},
  'Watermelon':         {'days': 90,  'type': 'annual',    'note': '80-100 days. Check tendril closest to fruit has dried.'},
  'Potatoes':           {'days': 90,  'type': 'annual',    'note': '85-95 days. Shangi & Tigoni are 90 days in Kenya.'},
  'Sorghum':            {'days': 100, 'type': 'annual',    'note': '90-120 days depending on variety and altitude.'},
  'Pumpkins':           {'days': 100, 'type': 'annual',    'note': '90-110 days. Butternut takes 110 days.'},
  'Groundnuts':         {'days': 120, 'type': 'annual',    'note': '4 months. Dig when lower leaves yellow.'},
  'Onions':             {'days': 120, 'type': 'annual',    'note': '4 months from seed. 3 months from sets. Tops fall over when ready.'},
  'Rice':               {'days': 120, 'type': 'annual',    'note': '3-4 months. Komboka (120 days) is most popular in Kenya.'},
  'Wheat':              {'days': 120, 'type': 'annual',    'note': '4 months. Eagle 10 is 120 days in highlands.'},
  'Sunflower':          {'days': 110, 'type': 'annual',    'note': '100-120 days. Back of head turns yellow-brown when ready.'},
  'Garlic':             {'days': 150, 'type': 'annual',    'note': '5 months. Tops dry and fall over when ready.'},
  'Sweet Potatoes':     {'days': 120, 'type': 'annual',    'note': '3-4 months. Kabode is 120 days.'},
  'Cassava':            {'days': 270, 'type': 'annual',    'note': '9 months minimum. Better quality at 12-18 months.'},
  'Pyrethrum':          {'days': 180, 'type': 'annual',    'note': '6 months to first flower. Harvest when 80% of flowers open.'},
  'Cotton':             {'days': 180, 'type': 'annual',    'note': '6 months. Bolls open 50-60 days after flowering.'},
  'Miraa (Khat)':       {'days': 365, 'type': 'perennial', 'note': '1 year from seedling to first harvest. Established plants harvested every 3-4 months.'},
  'Strawberry':         {'days': 90,  'type': 'annual',    'note': '3 months from runners. Fruit continuously for 2-3 years.'},
  // ── Bananas ─────────────────────────────────────────────────
  'Bananas':            {'days': 270, 'type': 'perennial',
    'daysEstablished': 270,
    'daysNewPlanting': 270,
    'note': '9 months from sucker planting to first bunch. After first harvest, ratoon crops take 10-12 months each.'},
  // ── Fruits from trees ────────────────────────────────────────
  'Passion Fruit':      {'days': 240, 'type': 'perennial',
    'daysNewPlanting': 240,
    'daysEstablished': 90,
    'note': 'NEW VINE: 8 months to first fruit. ESTABLISHED VINE (already flowering): 90 days after flowering to harvest.'},
  'Pawpaw':             {'days': 210, 'type': 'perennial',
    'daysNewPlanting': 210,
    'daysEstablished': 180,
    'note': 'NEW PLANT: 7 months from seed to first fruit. ESTABLISHED TREE: fruits continuously once mature.'},
  'Pineapple':          {'days': 540, 'type': 'perennial',
    'daysNewPlanting': 540,
    'daysEstablished': 365,
    'note': 'NEW PLANT: 18 months to first fruit. RATOON CROP: 12 months per cycle after first harvest.'},
  'Avocado (Fruit)':    {'days': 1095, 'type': 'tree',
    'daysNewPlanting': 1095,
    'daysEstablished': 365,
    'note': 'NEW GRAFTED TREE: 3 years to first harvest. ESTABLISHED TREE (already fruiting): fruits once per year, harvest 6-8 months after flowering.'},
  'Mangoes (Fruit)':    {'days': 1095, 'type': 'tree',
    'daysNewPlanting': 1095,
    'daysEstablished': 180,
    'note': 'NEW GRAFTED TREE: 3 years to first fruit. ESTABLISHED TREE: fruits once per year, 4-6 months after flowering.'},
  'Macadamia (Nut)':    {'days': 1825, 'type': 'tree',
    'daysNewPlanting': 1825,
    'daysEstablished': 270,
    'note': 'NEW TREE: 5 years to first harvest. ESTABLISHED TREE: nuts ready 7-9 months after flowering. Harvest when husks split.'},
  // ── Tea & Coffee ────────────────────────────────────────────
  'Tea (Green Leaf)':   {'days': 1095, 'type': 'bush',
    'daysNewPlanting': 1095,
    'daysEstablished': 7,
    'note': 'NEW SEEDLING: 3 years before first plucking. ESTABLISHED BUSH (already producing): pluck every 7-14 days. Only pick top 2 leaves + bud.'},
  'Coffee (Cherry)':    {'days': 730, 'type': 'bush',
    'daysNewPlanting': 730,
    'daysEstablished': 270,
    'note': 'NEW PLANT: 2 years (Ruiru 11) to first harvest. ESTABLISHED TREE: cherries ready 9 months after flowering. Main harvest Oct-Dec.'},
  // ── Sugarcane ───────────────────────────────────────────────
  'Sugarcane':          {'days': 365, 'type': 'perennial',
    'daysNewPlanting': 365,
    'daysEstablished': 365,
    'note': '12 months for first harvest (plant cane). Ratoon crops also take 12 months per cycle.'},
  'Other':              {'days': 90,  'type': 'annual',    'note': 'Enter the expected days based on your specific crop.'},
};


// Backward-compatible const map for farm_management_screen
const Map<String, int> kCropDefaultDays = {
  'Spinach': 45, 'Lettuce': 55, 'Kale (Sukuma Wiki)': 60, 'Green Grams': 65,
  'Cowpeas': 70, 'Peas': 70, 'Beans': 75, 'Carrots': 80, 'Tomatoes': 80,
  'Cabbage': 80, 'Eggplant': 80, 'Maize': 90, 'Capsicum': 90, 'Watermelon': 90,
  'Potatoes': 90, 'Sorghum': 100, 'Pumpkins': 100, 'Groundnuts': 120,
  'Onions': 120, 'Rice': 120, 'Wheat': 120, 'Sunflower': 110, 'Garlic': 150,
  'Sweet Potatoes': 120, 'Cassava': 270, 'Pyrethrum': 180, 'Cotton': 180,
  'Bananas': 270, 'Passion Fruit': 240, 'Pawpaw': 210, 'Pineapple': 540,
  'Strawberry': 90, 'Sugarcane': 365, 'Miraa (Khat)': 365,
  'Tea (Green Leaf)': 1095, 'Coffee (Cherry)': 730,
  'Avocado (Fruit)': 1095, 'Mangoes (Fruit)': 1095, 'Macadamia (Nut)': 1825,
  'Other': 90,
};

int getCropDefaultDays(String crop, {bool isEstablished = false}) {
  final info = kCropHarvestInfo[crop];
  if (info == null) return 90;
  if (isEstablished && info.containsKey('daysEstablished')) {
    return info['daysEstablished'] as int;
  }
  return info['days'] as int;
}

bool isCropPerennial(String crop) {
  final type = kCropHarvestInfo[crop]?['type'] as String?;
  return type == 'perennial' || type == 'tree' || type == 'bush';
}

bool cropHasTwoModes(String crop) {
  return kCropHarvestInfo[crop]?.containsKey('daysEstablished') ?? false;
}

String getCropHarvestNote(String crop) {
  return kCropHarvestInfo[crop]?['note'] as String? ?? '';
}

// ── Planting season advice per crop & county ─────────────────────

// Kenya has 2 main rainy seasons:
// Long rains: March - May (best for most crops)
// Short rains: October - December (secondary planting)
// Highland areas (above 1800m): cooler, rely more on rainfall

const Map<String, Map<String, dynamic>> kCropPlantingAdvice = {
  'Maize': {
    'bestMonths': [3, 4, 10, 11],  // March-April, Oct-Nov
    'goodCounties': ['Trans Nzoia', 'Uasin Gishu', 'Nakuru', 'Kakamega', 'Bungoma', 'Nandi', 'Elgeyo-Marakwet', 'Nyandarua', 'Laikipia'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa', 'Marsabit', 'Isiolo', 'Samburu'],
    'tip': 'Kenyas main staple. Plant at the onset of rains. Hybrid varieties (H614D, DK8031) give best yields. Use certified seed only.',
  },
  'Beans': {
    'bestMonths': [3, 4, 10, 11],
    'goodCounties': ['Meru', 'Embu', 'Kirinyaga', 'Nyeri', 'Kiambu', 'Murang\'a', 'Nakuru', 'Bungoma'],
    'poorCounties': ['Mombasa', 'Kwale', 'Kilifi', 'Turkana', 'Mandera'],
    'tip': 'Intercrop with maize for best results. Rose Coco and Canadian Wonder fetch premium prices in Kenya markets.',
  },
  'Tomatoes': {
    'bestMonths': [1, 2, 3, 7, 8, 9],  // Dry seasons (need irrigation)
    'goodCounties': ['Kirinyaga', 'Meru', 'Kajiado', 'Nakuru', 'Kiambu', 'Muranga\'a', 'Machakos'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir'],
    'tip': 'Best grown during dry season with irrigation to avoid blight. Avoid planting during heavy rains. Kajiado (Isinya) and Kirinyaga are Kenyas top tomato-producing areas.',
  },
  'Tea (Green Leaf)': {
    'bestMonths': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],  // Year round
    'goodCounties': ['Kericho', 'Bomet', 'Nyamira', 'Kiambu', 'Murang\'a', 'Meru', 'Embu', 'Nandi', 'Kakamega'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa', 'Mombasa', 'Kilifi', 'Kwale', 'Taita-Taveta'],
    'tip': 'Tea requires high rainfall (1400-2000mm/yr), cool temperatures (13-24°C), and altitudes of 1500-2700m. Kericho and Bomet are ideal.',
  },
  'Coffee (Cherry)': {
    'bestMonths': [3, 4, 5, 10, 11],
    'goodCounties': ['Kiambu', 'Murang\'a', 'Nyeri', 'Meru', 'Embu', 'Kirinyaga', 'Kisii', 'Bungoma'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa', 'Mombasa'],
    'tip': 'Kenya AA coffee is world famous. Needs altitude 1500-2100m, 1000-2000mm rainfall. Ruiru 11 is CBD-resistant and recommended.',
  },
  'Avocado (Fruit)': {
    'bestMonths': [3, 4, 10, 11],
    'goodCounties': ['Murang\'a', 'Kiambu', 'Nyeri', 'Meru', 'Embu', 'Kirinyaga', 'Nakuru', 'Trans Nzoia'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Kwale', 'Turkana', 'Mandera'],
    'tip': 'Murang\'a is Kenyas avocado capital — Hass avocados fetch premium export prices. Needs good drainage and moderate rainfall.',
  },
  'Potatoes': {
    'bestMonths': [3, 4, 10, 11],
    'goodCounties': ['Nyandarua', 'Nakuru', 'Elgeyo-Marakwet', 'Meru', 'Nyeri', 'Kirinyaga', 'Laikipia'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Kwale', 'Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Shangi and Tigoni are most popular in Kenya. Nyandarua (Ol Kalou) and Meru highlands are the best growing areas.',
  },
  'Onions': {
    'bestMonths': [6, 7, 8, 1, 2],  // Dry seasons with irrigation
    'goodCounties': ['Kajiado', 'Narok', 'Machakos', 'Makueni', 'Meru', 'Tharaka-Nithi'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir'],
    'tip': 'Best grown in dry conditions with irrigation. Kajiado (Isinya area) is Kenyas main onion-growing region. Jambar F1 is most popular.',
  },
  'Mangoes (Fruit)': {
    'bestMonths': [3, 4, 10, 11],
    'goodCounties': ['Machakos', 'Makueni', 'Kitui', 'Mombasa', 'Kilifi', 'Kwale', 'Taita-Taveta', 'Meru', 'Embu'],
    'poorCounties': ['Nyandarua', 'Elgeyo-Marakwet', 'Turkana'],
    'tip': 'Machakos, Makueni and Coast are best for mangoes. Ngowe mango is popular at coast; Apple mango dominates inland markets.',
  },
  'Rice': {
    'bestMonths': [3, 4, 10, 11],
    'goodCounties': ['Mwea (Kirinyaga)', 'Kisumu', 'Homa Bay', 'Migori', 'Siaya', 'Tana River', 'Kwale'],
    'poorCounties': ['Nyandarua', 'Elgeyo-Marakwet', 'Bomet'],
    'tip': 'Mwea irrigation scheme (Kirinyaga) produces 90% of Kenyas rice. Komboka variety is high-yielding and blight-resistant.',
  },
  'Sugarcane': {
    'bestMonths': [3, 4, 10, 11],
    'goodCounties': ['Kakamega', 'Bungoma', 'Busia', 'Siaya', 'Kisumu', 'Migori', 'Homa Bay', 'Vihiga', 'Uasin Gishu', 'Nandi'],
    'poorCounties': ['Nyandarua', 'Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Western Kenya (Kakamega, Bungoma) dominates cane production. Mumias Sugar area is ideal. Contract with mill before planting.',
  },
  'Strawberry': {
    'bestMonths': [1, 2, 3, 7, 8, 9],
    'goodCounties': ['Kiambu', 'Murang\'a', 'Nyeri', 'Nyandarua', 'Nakuru'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Kwale', 'Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Limuru (Kiambu) and Kinangop (Nyandarua) are best for strawberries. High demand in Nairobi supermarkets and export.',
  },
  'Bananas': {
    'bestMonths': [1,2,3,4,5,6,7,8,9,10,11,12],
    'goodCounties': ['Meru', 'Embu', 'Kirinyaga', 'Murang\'a', 'Kakamega', 'Kisumu', 'Bungoma', 'Homa Bay', 'Kilifi', 'Mombasa'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Marsabit', 'Isiolo'],
    'tip': 'Bananas grow year-round. Meru and Embu produce high-quality varieties. Ensure good drainage — roots rot in waterlogged soil. Tissue culture seedlings give better yield.',
  },
  'Cassava': {
    'bestMonths': [3,4,5,10,11],
    'goodCounties': ['Kilifi', 'Kwale', 'Mombasa', 'Taita-Taveta', 'Machakos', 'Kitui', 'Makueni', 'Tana River', 'Homa Bay', 'Siaya', 'Migori'],
    'poorCounties': ['Nairobi', 'Nakuru', 'Kericho', 'Nyandarua'],
    'tip': 'Cassava is drought-tolerant and ideal for dry coastal and eastern counties. Plant cuttings at onset of rains. Harvest 8-18 months after planting.',
  },
  'Wheat': {
    'bestMonths': [3,4,9,10],
    'goodCounties': ['Uasin Gishu', 'Trans Nzoia', 'Nakuru', 'Nyandarua', 'Laikipia', 'Elgeyo-Marakwet', 'Baringo', 'Narok'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Kwale', 'Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Kenyas wheat basket is Uasin Gishu and Trans Nzoia. Requires cool temperatures and well-drained soils. Use certified seed varieties like Eagle 10 or Fahari.',
  },
  'Sunflower': {
    'bestMonths': [3,4,10,11],
    'goodCounties': ['Machakos', 'Kitui', 'Makueni', 'Kajiado', 'Nakuru', 'Narok', 'Trans Nzoia', 'Uasin Gishu'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Kwale', 'Turkana', 'Mandera'],
    'tip': 'Sunflower is drought-tolerant and a good cash crop. KARI and ETHO varieties are popular. Contract farming with oil processors gives guaranteed market.',
  },
  'Sweet Potatoes': {
    'bestMonths': [3,4,5,10,11],
    'goodCounties': ['Vihiga', 'Kakamega', 'Bungoma', 'Busia', 'Siaya', 'Homa Bay', 'Meru', 'Embu', 'Kirinyaga', 'Murang\'a'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa', 'Marsabit'],
    'tip': 'Western Kenya is the sweet potato heartland. Orange-fleshed varieties are high in Vitamin A. Vines are planted, not seeds. Ready in 3-4 months.',
  },
  'Sorghum': {
    'bestMonths': [3,4,10,11],
    'goodCounties': ['Siaya', 'Homa Bay', 'Migori', 'Busia', 'Kitui', 'Makueni', 'Machakos', 'Baringo', 'Turkana'],
    'poorCounties': ['Nairobi', 'Kiambu', 'Kericho', 'Bomet'],
    'tip': 'Sorghum thrives in dry areas where maize struggles. Used for food, feed, and brewing. Plant at start of rains. Resistant to drought once established.',
  },
  'Kale (Sukuma Wiki)': {
    'bestMonths': [1,2,3,4,5,6,7,8,9,10,11,12],
    'goodCounties': ['Kiambu', 'Murang\'a', 'Nyeri', 'Nakuru', 'Nyandarua', 'Meru', 'Embu', 'Nairobi'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Sukuma wiki is Kenyas most consumed vegetable. Grows year-round with irrigation. Plant transplants 45cm apart. Harvest outer leaves to keep plant producing.',
  },
  'Cabbage': {
    'bestMonths': [2,3,4,8,9,10],
    'goodCounties': ['Kiambu', 'Nyandarua', 'Nakuru', 'Meru', 'Nyeri', 'Kericho', 'Elgeyo-Marakwet'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa', 'Mombasa'],
    'tip': 'Cool highland areas give best cabbage quality. Gloria F1 and Copenhagen are popular varieties. Dense planting with 60cm spacing. Watch for black rot disease.',
  },
  'Groundnuts': {
    'bestMonths': [3,4,10,11],
    'goodCounties': ['Siaya', 'Homa Bay', 'Migori', 'Busia', 'Vihiga', 'Bungoma', 'Machakos', 'Kitui', 'Makueni'],
    'poorCounties': ['Nairobi', 'Kiambu', 'Nyandarua', 'Kericho'],
    'tip': 'Western Kenya and eastern regions are top groundnut areas. Need light sandy-loam soils. Plant at start of rains. Rosette disease is the main challenge — use resistant varieties.',
  },
  'Cowpeas': {
    'bestMonths': [3,4,10,11],
    'goodCounties': ['Machakos', 'Kitui', 'Makueni', 'Siaya', 'Homa Bay', 'Migori', 'Turkana', 'Baringo', 'Kilifi'],
    'poorCounties': ['Nairobi', 'Kiambu', 'Kericho', 'Nyandarua'],
    'tip': 'Excellent drought-tolerant legume for dry areas. Fixes nitrogen improving soil. Leaves also eaten as vegetables. Harvest pods when dry, 60-90 days after planting.',
  },
  'Green Grams': {
    'bestMonths': [3,4,10,11],
    'goodCounties': ['Machakos', 'Kitui', 'Makueni', 'Kilifi', 'Kwale', 'Taita-Taveta', 'Tana River', 'Isiolo'],
    'poorCounties': ['Kericho', 'Bomet', 'Nyandarua', 'Kiambu'],
    'tip': 'Dry eastern and coastal regions are ideal. N26 and KS20 are popular varieties. Short season (60-75 days). High demand from Asian and Middle East export markets.',
  },
  'Peas': {
    'bestMonths': [2,3,9,10],
    'goodCounties': ['Nyandarua', 'Nakuru', 'Kericho', 'Elgeyo-Marakwet', 'Nyeri', 'Murang\'a', 'Meru'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Turkana', 'Mandera', 'Wajir'],
    'tip': 'Cool highland areas above 1500m are best for peas. Snow peas and sugar snaps have high export value. Trellis climbing varieties for better yields.',
  },
  'Carrots': {
    'bestMonths': [2,3,4,8,9,10],
    'goodCounties': ['Nyandarua', 'Nakuru', 'Kericho', 'Meru', 'Nyeri', 'Elgeyo-Marakwet', 'Uasin Gishu'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Turkana', 'Mandera'],
    'tip': 'Sandy loam soils in cool highlands produce best carrots. Nyandaruas Ol Kalou is Kenyas carrot capital. Chantenay and Nantes are popular varieties.',
  },
  'Watermelon': {
    'bestMonths': [1,2,3,10,11,12],
    'goodCounties': ['Machakos', 'Makueni', 'Kitui', 'Kilifi', 'Kwale', 'Taita-Taveta', 'Kajiado', 'Narok'],
    'poorCounties': ['Kericho', 'Bomet', 'Nyandarua', 'Nakuru'],
    'tip': 'Hot dry areas with irrigation produce sweet watermelons. Charleston Gray and Sugar Baby are top varieties. Needs full sun and deep watering.',
  },
  'Capsicum': {
    'bestMonths': [2,3,4,9,10],
    'goodCounties': ['Kiambu', 'Nakuru', 'Meru', 'Embu', 'Murang\'a', 'Nyeri', 'Machakos'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Capsicum (pilipili hoho) has strong urban market demand. California Wonder and Yolo Wonder are common varieties. Stakes needed for heavy-fruiting plants.',
  },
  'Eggplant': {
    'bestMonths': [3,4,5,10,11],
    'goodCounties': ['Kilifi', 'Kwale', 'Mombasa', 'Machakos', 'Kitui', 'Nairobi', 'Kiambu', 'Meru'],
    'poorCounties': ['Nyandarua', 'Kericho', 'Elgeyo-Marakwet'],
    'tip': 'Eggplant (brinjal) does well in warm lowland areas. Strong coastal and Asian community market. Black Beauty and Long Purple are popular varieties.',
  },
  'Spinach': {
    'bestMonths': [1,2,3,4,5,6,7,8,9,10,11,12],
    'goodCounties': ['Kiambu', 'Nairobi', 'Nakuru', 'Nyeri', 'Meru', 'Embu', 'Nyandarua'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir'],
    'tip': 'Spinach grows year-round with water. Bloomsdale and Viroflay are popular varieties. High demand from restaurants and supermarkets. Can be intercropped with maize.',
  },
  'Lettuce': {
    'bestMonths': [1,2,3,4,5,6,7,8,9,10,11,12],
    'goodCounties': ['Kiambu', 'Nairobi', 'Nakuru', 'Nyandarua', 'Nyeri', 'Kericho'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa', 'Turkana'],
    'tip': 'Lettuce suits cool highlands and is increasingly grown in urban farms. Great Lakes and Butterhead are top sellers. High-value crop with quick turnover (45-60 days).',
  },
  'Garlic': {
    'bestMonths': [6,7,8,9],
    'goodCounties': ['Meru', 'Embu', 'Nyeri', 'Nakuru', 'Nyandarua', 'Laikipia'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Turkana', 'Mandera'],
    'tip': 'Kenya imports most of its garlic — local production is very profitable. Needs cool dry conditions. Plant individual cloves. Harvest when tops die down (5-6 months).',
  },
  'Macadamia (Nut)': {
    'bestMonths': [3,4,10,11],
    'goodCounties': ['Meru', 'Embu', 'Kirinyaga', 'Murang\'a', 'Nyeri', 'Kiambu', 'Nakuru'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa', 'Mombasa'],
    'tip': 'Kenya is Africas top macadamia exporter. Trees start producing in 5-7 years. Very profitable long-term investment. Embu and Meru have ideal climate.',
  },
  'Passion Fruit': {
    'bestMonths': [3,4,5,10,11],
    'goodCounties': ['Murang\'a', 'Kirinyaga', 'Embu', 'Meru', 'Nakuru', 'Kiambu', 'Nyeri'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Purple passion fruit is best for juice processing. Yellow passion is for fresh export. Requires trellis support. Woodiness virus is the main threat — use certified seedlings.',
  },
  'Pawpaw': {
    'bestMonths': [3,4,5,10,11],
    'goodCounties': ['Kilifi', 'Kwale', 'Mombasa', 'Taita-Taveta', 'Machakos', 'Kitui', 'Embu', 'Meru', 'Kirinyaga', 'Tana River'],
    'poorCounties': ['Nyandarua', 'Kericho', 'Bomet', 'Elgeyo-Marakwet', 'Turkana'],
    'tip': 'Pawpaw loves warm humid areas. Coastal and lower Eastern Kenya are ideal. Solo and Sunrise varieties are popular. Fruits in 9-11 months. Avoid waterlogged soils.',
  },
  'Pineapple': {
    'bestMonths': [3,4,5,10,11],
    'goodCounties': ['Kilifi', 'Kwale', 'Mombasa', 'Siaya', 'Homa Bay', 'Busia', 'Kakamega', 'Kirinyaga'],
    'poorCounties': ['Nyandarua', 'Kericho', 'Elgeyo-Marakwet', 'Turkana', 'Mandera'],
    'tip': 'Thika and the Coast are top pineapple zones. Smooth Cayenne and MD2 varieties are grown. Takes 18-24 months to first fruit. Plant crowns or suckers.',
  },
  'Pyrethrum': {
    'bestMonths': [3,4,9,10],
    'goodCounties': ['Nakuru', 'Nyandarua', 'Kericho', 'Bomet', 'Elgeyo-Marakwet', 'Nyeri', 'Meru', 'Laikipia'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Kenya is a world-leading pyrethrum producer. Cool highlands above 1800m are best. Contracted by Pyrethrum Board of Kenya. Flowers harvested and dried for natural pesticide.',
  },
  'Cotton': {
    'bestMonths': [3,4,10,11],
    'goodCounties': ['Siaya', 'Homa Bay', 'Migori', 'Busia', 'Bungoma', 'Tana River', 'Kilifi', 'Kwale', 'Baringo', 'Turkana'],
    'poorCounties': ['Nairobi', 'Kiambu', 'Kericho', 'Nyandarua', 'Bomet'],
    'tip': 'Cotton thrives in hot semi-arid areas. Western Kenya and Coast are top cotton zones. BT Cotton (pest-resistant) is approved in Kenya. Contract with textile mills for guaranteed market.',
  },
  'Miraa (Khat)': {
    'bestMonths': [1,2,3,4,5,6,7,8,9,10,11,12],
    'goodCounties': ['Meru', 'Tharaka-Nithi', 'Embu', 'Isiolo', 'Nyeri'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Turkana', 'Mandera', 'Nairobi'],
    'tip': 'Miraa is exclusively grown in Meru and surrounding areas. Propagated by cuttings. High-value export to Somalia, Uganda and Middle East. Trees produce for decades.',
  },
  'Pumpkins': {
    'bestMonths': [3,4,5,10,11],
    'goodCounties': ['Machakos', 'Kitui', 'Makueni', 'Kajiado', 'Nakuru', 'Narok', 'Kisumu', 'Siaya', 'Homa Bay'],
    'poorCounties': ['Nyandarua', 'Kericho', 'Bomet', 'Elgeyo-Marakwet'],
    'tip': 'Pumpkins are drought-tolerant and low-maintenance. Both flesh and seeds are sold. Butternut fetches premium supermarket prices. Plant on mounds with 2m x 2m spacing.',
  },
};

Map<String, dynamic>? getPlantingAdvice(String crop, String county, DateTime plantingDate) {
  final advice = kCropPlantingAdvice[crop];
  if (advice == null) return null;

  final month = plantingDate.month;
  final bestMonths = List<int>.from(advice['bestMonths'] as List);
  final goodCounties = List<String>.from(advice['goodCounties'] as List);
  final poorCounties = List<String>.from(advice['poorCounties'] as List);

  final isGoodMonth = bestMonths.contains(month);
  final isGoodCounty = goodCounties.any((c) => county.toLowerCase().contains(c.toLowerCase()) || c.toLowerCase().contains(county.toLowerCase()));
  final isPoorCounty = poorCounties.any((c) => county.toLowerCase().contains(c.toLowerCase()) || c.toLowerCase().contains(county.toLowerCase()));

  String timing = '';
  if (isGoodMonth) {
    timing = '✅ Good planting time! ${_monthName(month)} is ideal for $crop.';
  } else {
    final nextBest = _nextGoodMonth(month, bestMonths);
    timing = '⚠️ Not ideal timing. Best months are ${bestMonths.map(_monthName).join(', ')}. Next good window: $nextBest.';
  }

  String location = '';
  if (isPoorCounty) {
    location = '❌ $crop is NOT well-suited for $county. Consider crops better adapted to this area.';
  } else if (isGoodCounty) {
    location = '✅ $county is an excellent area for $crop!';
  } else {
    location = 'ℹ️ $county can grow $crop with proper management.';
  }

  return {
    'timing': timing,
    'location': location,
    'tip': advice['tip'],
    'isGoodMonth': isGoodMonth,
    'isGoodCounty': isGoodCounty,
    'isPoorCounty': isPoorCounty,
  };
}

String _monthName(int m) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return months[m - 1];
}

String _nextGoodMonth(int current, List<int> best) {
  for (int i = 1; i <= 12; i++) {
    final next = ((current - 1 + i) % 12) + 1;
    if (best.contains(next)) return _monthName(next);
  }
  return _monthName(best.first);
}

// ── Market Prices ────────────────────────────────────────────────
// Prices in KSh — March 2025 averages from Kenya market surveys.
// Sources: AMIS, County governments, Wakulima market, KALRO

const Map<String, List<Map<String, dynamic>>> kCountyMarketPrices = {
  'Nairobi (Wholesale)': [
    // Cereals
    {'crop': 'Maize (90kg bag)',          'price': 3200,  'unit': 'bag',    'trend': 'up',     'change': '+5%',  'type': 'crop'},
    {'crop': 'Beans - Rose Coco (90kg)',  'price': 9500,  'unit': 'bag',    'trend': 'up',     'change': '+3%',  'type': 'crop'},
    {'crop': 'Wheat (90kg bag)',          'price': 4200,  'unit': 'bag',    'trend': 'up',     'change': '+7%',  'type': 'crop'},
    {'crop': 'Rice - Pishori (1kg)',      'price': 180,   'unit': 'kg',     'trend': 'stable', 'change': '+1%',  'type': 'crop'},
    {'crop': 'Green Grams (1kg)',         'price': 130,   'unit': 'kg',     'trend': 'up',     'change': '+10%', 'type': 'crop'},
    {'crop': 'Sorghum (90kg bag)',        'price': 3800,  'unit': 'bag',    'trend': 'up',     'change': '+8%',  'type': 'crop'},
    // Vegetables
    {'crop': 'Tomatoes',                  'price': 65,    'unit': 'kg',     'trend': 'down',   'change': '-8%',  'type': 'crop'},
    {'crop': 'Onions',                    'price': 55,    'unit': 'kg',     'trend': 'up',     'change': '+12%', 'type': 'crop'},
    {'crop': 'Kale (Sukuma Wiki)',        'price': 15,    'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Cabbage',                   'price': 25,    'unit': 'kg',     'trend': 'down',   'change': '-5%',  'type': 'crop'},
    {'crop': 'Carrots',                   'price': 40,    'unit': 'kg',     'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Capsicum',                  'price': 120,   'unit': 'kg',     'trend': 'up',     'change': '+6%',  'type': 'crop'},
    {'crop': 'Spinach (bunch)',           'price': 30,    'unit': 'bunch',  'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Eggplant',                  'price': 70,    'unit': 'kg',     'trend': 'stable', 'change': '+2%',  'type': 'crop'},
    // Potatoes
    {'crop': 'Potatoes - Shangi (50kg)', 'price': 1800,  'unit': 'bag',    'trend': 'stable', 'change': '0%',   'type': 'crop'},
    // Fruits
    {'crop': 'Avocado (Hass)',            'price': 30,    'unit': 'piece',  'trend': 'up',     'change': '+10%', 'type': 'crop'},
    {'crop': 'Bananas (bunch)',           'price': 350,   'unit': 'bunch',  'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Mangoes (Apple)',           'price': 25,    'unit': 'kg',     'trend': 'down',   'change': '-5%',  'type': 'crop'},
    {'crop': 'Passion Fruit',             'price': 150,   'unit': 'kg',     'trend': 'up',     'change': '+8%',  'type': 'crop'},
    {'crop': 'Pawpaw',                    'price': 80,    'unit': 'kg',     'trend': 'stable', 'change': '+1%',  'type': 'crop'},
    {'crop': 'Watermelon',                'price': 20,    'unit': 'kg',     'trend': 'down',   'change': '-3%',  'type': 'crop'},
    {'crop': 'Pineapple',                 'price': 80,    'unit': 'piece',  'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Strawberry',                'price': 350,   'unit': 'kg',     'trend': 'up',     'change': '+20%', 'type': 'crop'},
    // Cash crops
    {'crop': 'Coffee (Parchment)',        'price': 130,   'unit': 'kg',     'trend': 'up',     'change': '+12%', 'type': 'crop'},
    {'crop': 'Tea (Green Leaf)',          'price': 28,    'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'crop'},
    {'crop': 'Macadamia (nut in shell)',  'price': 85,    'unit': 'kg',     'trend': 'up',     'change': '+15%', 'type': 'crop'},
    {'crop': 'Pyrethrum',                 'price': 120,   'unit': 'kg',     'trend': 'up',     'change': '+10%', 'type': 'crop'},
    // Livestock products
    {'crop': 'Fresh Milk',                'price': 45,    'unit': 'litre',  'trend': 'stable', 'change': '+1%',  'type': 'livestock'},
    {'crop': 'Eggs (Tray of 30)',         'price': 380,   'unit': 'tray',   'trend': 'up',     'change': '+4%',  'type': 'livestock'},
    {'crop': 'Kienyeji Chicken (live)',   'price': 900,   'unit': 'bird',   'trend': 'up',     'change': '+6%',  'type': 'livestock'},
    {'crop': 'Broiler Chicken (live)',    'price': 450,   'unit': 'kg',     'trend': 'stable', 'change': '+2%',  'type': 'livestock'},
    {'crop': 'Honey (Raw)',               'price': 800,   'unit': 'kg',     'trend': 'up',     'change': '+8%',  'type': 'livestock'},
    {'crop': 'Beef (live weight)',        'price': 350,   'unit': 'kg',     'trend': 'stable', 'change': '+1%',  'type': 'livestock'},
    {'crop': 'Goat Meat (live)',          'price': 700,   'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'livestock'},
    {'crop': 'Pork (live weight)',        'price': 280,   'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'livestock'},
    {'crop': 'Mutton (live)',             'price': 650,   'unit': 'kg',     'trend': 'up',     'change': '+4%',  'type': 'livestock'},
    {'crop': 'Fish - Tilapia (fresh)',    'price': 380,   'unit': 'kg',     'trend': 'down',   'change': '-5%',  'type': 'livestock'},
    {'crop': 'Rabbit (live)',             'price': 700,   'unit': 'kg',     'trend': 'up',     'change': '+8%',  'type': 'livestock'},
    {'crop': 'Beeswax',                   'price': 600,   'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'livestock'},
    {'crop': 'Ghee',                      'price': 900,   'unit': 'kg',     'trend': 'stable', 'change': '+2%',  'type': 'livestock'},
  ],
  'Nakuru': [
    {'crop': 'Maize (90kg bag)',          'price': 2900,  'unit': 'bag',    'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Potatoes - Shangi (50kg)', 'price': 1500,  'unit': 'bag',    'trend': 'down',   'change': '-3%',  'type': 'crop'},
    {'crop': 'Wheat (90kg bag)',          'price': 3900,  'unit': 'bag',    'trend': 'up',     'change': '+6%',  'type': 'crop'},
    {'crop': 'Pyrethrum',                 'price': 120,   'unit': 'kg',     'trend': 'up',     'change': '+10%', 'type': 'crop'},
    {'crop': 'Onions',                    'price': 48,    'unit': 'kg',     'trend': 'up',     'change': '+8%',  'type': 'crop'},
    {'crop': 'Tomatoes',                  'price': 58,    'unit': 'kg',     'trend': 'down',   'change': '-6%',  'type': 'crop'},
    {'crop': 'Kale (Sukuma Wiki)',        'price': 12,    'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Cabbage',                   'price': 20,    'unit': 'kg',     'trend': 'down',   'change': '-4%',  'type': 'crop'},
    {'crop': 'Fresh Milk',                'price': 38,    'unit': 'litre',  'trend': 'stable', 'change': '0%',   'type': 'livestock'},
    {'crop': 'Eggs (Tray of 30)',         'price': 350,   'unit': 'tray',   'trend': 'stable', 'change': '+2%',  'type': 'livestock'},
    {'crop': 'Beef (live weight)',        'price': 320,   'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'livestock'},
    {'crop': 'Honey (Raw)',               'price': 750,   'unit': 'kg',     'trend': 'up',     'change': '+6%',  'type': 'livestock'},
    {'crop': 'Kienyeji Chicken (live)',   'price': 850,   'unit': 'bird',   'trend': 'up',     'change': '+5%',  'type': 'livestock'},
    {'crop': 'Sunflower',                 'price': 50,    'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'crop'},
  ],
  'Meru': [
    {'crop': 'Tea (Green Leaf)',          'price': 28,    'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'crop'},
    {'crop': 'Coffee (Parchment)',        'price': 130,   'unit': 'kg',     'trend': 'up',     'change': '+12%', 'type': 'crop'},
    {'crop': 'Miraa (Khat)',             'price': 200,   'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Bananas (bunch)',           'price': 280,   'unit': 'bunch',  'trend': 'stable', 'change': '+1%',  'type': 'crop'},
    {'crop': 'Macadamia (nut in shell)',  'price': 85,    'unit': 'kg',     'trend': 'up',     'change': '+15%', 'type': 'crop'},
    {'crop': 'Avocado (Hass)',            'price': 22,    'unit': 'piece',  'trend': 'up',     'change': '+8%',  'type': 'crop'},
    {'crop': 'Honey (Raw)',               'price': 700,   'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'livestock'},
    {'crop': 'Maize (90kg bag)',          'price': 3100,  'unit': 'bag',    'trend': 'up',     'change': '+3%',  'type': 'crop'},
    {'crop': 'Beans - Rose Coco (90kg)', 'price': 9000,  'unit': 'bag',    'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Potatoes - Shangi (50kg)', 'price': 1600,  'unit': 'bag',    'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Fresh Milk',                'price': 40,    'unit': 'litre',  'trend': 'stable', 'change': '0%',   'type': 'livestock'},
    {'crop': 'Eggs (Tray of 30)',         'price': 360,   'unit': 'tray',   'trend': 'up',     'change': '+3%',  'type': 'livestock'},
    {'crop': 'Kienyeji Chicken (live)',   'price': 900,   'unit': 'bird',   'trend': 'up',     'change': '+6%',  'type': 'livestock'},
    {'crop': 'Beef (live weight)',        'price': 340,   'unit': 'kg',     'trend': 'stable', 'change': '+1%',  'type': 'livestock'},
  ],
  'Kiambu': [
    {'crop': 'Tea (Green Leaf)',          'price': 27,    'unit': 'kg',     'trend': 'stable', 'change': '+2%',  'type': 'crop'},
    {'crop': 'Coffee (Parchment)',        'price': 125,   'unit': 'kg',     'trend': 'up',     'change': '+10%', 'type': 'crop'},
    {'crop': 'Potatoes - Shangi (50kg)', 'price': 1600,  'unit': 'bag',    'trend': 'down',   'change': '-4%',  'type': 'crop'},
    {'crop': 'Tomatoes',                  'price': 70,    'unit': 'kg',     'trend': 'down',   'change': '-6%',  'type': 'crop'},
    {'crop': 'Strawberry',                'price': 340,   'unit': 'kg',     'trend': 'up',     'change': '+18%', 'type': 'crop'},
    {'crop': 'Avocado (Hass)',            'price': 25,    'unit': 'piece',  'trend': 'up',     'change': '+9%',  'type': 'crop'},
    {'crop': 'Fresh Milk',                'price': 42,    'unit': 'litre',  'trend': 'stable', 'change': '+1%',  'type': 'livestock'},
    {'crop': 'Eggs (Tray of 30)',         'price': 370,   'unit': 'tray',   'trend': 'up',     'change': '+4%',  'type': 'livestock'},
    {'crop': 'Maize (90kg bag)',          'price': 3100,  'unit': 'bag',    'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Cabbage',                   'price': 22,    'unit': 'kg',     'trend': 'down',   'change': '-3%',  'type': 'crop'},
    {'crop': 'Kale (Sukuma Wiki)',        'price': 14,    'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Kienyeji Chicken (live)',   'price': 880,   'unit': 'bird',   'trend': 'up',     'change': '+5%',  'type': 'livestock'},
    {'crop': 'Honey (Raw)',               'price': 780,   'unit': 'kg',     'trend': 'up',     'change': '+7%',  'type': 'livestock'},
  ],
  'Kisumu': [
    {'crop': 'Fish - Tilapia (fresh)',    'price': 350,   'unit': 'kg',     'trend': 'down',   'change': '-5%',  'type': 'livestock'},
    {'crop': 'Maize (90kg bag)',          'price': 3100,  'unit': 'bag',    'trend': 'up',     'change': '+3%',  'type': 'crop'},
    {'crop': 'Sorghum (90kg bag)',        'price': 3500,  'unit': 'bag',    'trend': 'up',     'change': '+8%',  'type': 'crop'},
    {'crop': 'Rice - Pishori (1kg)',      'price': 170,   'unit': 'kg',     'trend': 'stable', 'change': '+1%',  'type': 'crop'},
    {'crop': 'Sugarcane (tonne)',         'price': 3800,  'unit': 'tonne',  'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Sweet Potatoes',            'price': 30,    'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'crop'},
    {'crop': 'Cassava',                   'price': 25,    'unit': 'kg',     'trend': 'stable', 'change': '+2%',  'type': 'crop'},
    {'crop': 'Eggs (Tray of 30)',         'price': 360,   'unit': 'tray',   'trend': 'up',     'change': '+5%',  'type': 'livestock'},
    {'crop': 'Fresh Milk',                'price': 36,    'unit': 'litre',  'trend': 'stable', 'change': '+1%',  'type': 'livestock'},
    {'crop': 'Kienyeji Chicken (live)',   'price': 850,   'unit': 'bird',   'trend': 'up',     'change': '+4%',  'type': 'livestock'},
    {'crop': 'Beef (live weight)',        'price': 330,   'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'livestock'},
    {'crop': 'Kale (Sukuma Wiki)',        'price': 13,    'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Bananas (bunch)',           'price': 300,   'unit': 'bunch',  'trend': 'stable', 'change': '+1%',  'type': 'crop'},
  ],
  'Kakamega': [
    {'crop': 'Maize (90kg bag)',          'price': 2800,  'unit': 'bag',    'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Sugarcane (tonne)',         'price': 3600,  'unit': 'tonne',  'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Tea (Green Leaf)',          'price': 25,    'unit': 'kg',     'trend': 'up',     'change': '+3%',  'type': 'crop'},
    {'crop': 'Beans - Rose Coco (90kg)', 'price': 8800,  'unit': 'bag',    'trend': 'up',     'change': '+3%',  'type': 'crop'},
    {'crop': 'Cassava',                   'price': 22,    'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'crop'},
    {'crop': 'Sweet Potatoes',            'price': 28,    'unit': 'kg',     'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Fresh Milk',                'price': 35,    'unit': 'litre',  'trend': 'stable', 'change': '+1%',  'type': 'livestock'},
    {'crop': 'Eggs (Tray of 30)',         'price': 340,   'unit': 'tray',   'trend': 'up',     'change': '+3%',  'type': 'livestock'},
    {'crop': 'Kienyeji Chicken (live)',   'price': 830,   'unit': 'bird',   'trend': 'up',     'change': '+4%',  'type': 'livestock'},
    {'crop': 'Kale (Sukuma Wiki)',        'price': 12,    'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Beef (live weight)',        'price': 310,   'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'livestock'},
  ],
  'Machakos': [
    {'crop': 'Maize (90kg bag)',          'price': 3300,  'unit': 'bag',    'trend': 'up',     'change': '+6%',  'type': 'crop'},
    {'crop': 'Beans - Rose Coco (90kg)', 'price': 9000,  'unit': 'bag',    'trend': 'up',     'change': '+5%',  'type': 'crop'},
    {'crop': 'Green Grams (90kg bag)',    'price': 12000, 'unit': 'bag',    'trend': 'up',     'change': '+10%', 'type': 'crop'},
    {'crop': 'Mangoes (Apple)',           'price': 20,    'unit': 'kg',     'trend': 'down',   'change': '-8%',  'type': 'crop'},
    {'crop': 'Cowpeas',                   'price': 100,   'unit': 'kg',     'trend': 'up',     'change': '+7%',  'type': 'crop'},
    {'crop': 'Onions',                    'price': 50,    'unit': 'kg',     'trend': 'up',     'change': '+9%',  'type': 'crop'},
    {'crop': 'Goat Meat (live)',          'price': 680,   'unit': 'kg',     'trend': 'up',     'change': '+4%',  'type': 'livestock'},
    {'crop': 'Honey (Raw)',               'price': 750,   'unit': 'kg',     'trend': 'up',     'change': '+6%',  'type': 'livestock'},
    {'crop': 'Kienyeji Chicken (live)',   'price': 870,   'unit': 'bird',   'trend': 'up',     'change': '+5%',  'type': 'livestock'},
    {'crop': 'Eggs (Tray of 30)',         'price': 365,   'unit': 'tray',   'trend': 'up',     'change': '+4%',  'type': 'livestock'},
    {'crop': 'Fresh Milk',                'price': 38,    'unit': 'litre',  'trend': 'stable', 'change': '0%',   'type': 'livestock'},
  ],
  'Trans Nzoia': [
    {'crop': 'Maize (90kg bag)',          'price': 2700,  'unit': 'bag',    'trend': 'up',     'change': '+3%',  'type': 'crop'},
    {'crop': 'Wheat (90kg bag)',          'price': 3800,  'unit': 'bag',    'trend': 'up',     'change': '+5%',  'type': 'crop'},
    {'crop': 'Beans - Rose Coco (90kg)', 'price': 8500,  'unit': 'bag',    'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Potatoes - Shangi (50kg)', 'price': 1600,  'unit': 'bag',    'trend': 'stable', 'change': '0%',   'type': 'crop'},
    {'crop': 'Sunflower',                 'price': 48,    'unit': 'kg',     'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Fresh Milk',                'price': 37,    'unit': 'litre',  'trend': 'stable', 'change': '0%',   'type': 'livestock'},
    {'crop': 'Eggs (Tray of 30)',         'price': 345,   'unit': 'tray',   'trend': 'up',     'change': '+3%',  'type': 'livestock'},
    {'crop': 'Beef (live weight)',        'price': 325,   'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'livestock'},
    {'crop': 'Kale (Sukuma Wiki)',        'price': 13,    'unit': 'kg',     'trend': 'stable', 'change': '0%',   'type': 'crop'},
  ],
  'Uasin Gishu': [
    {'crop': 'Maize (90kg bag)',          'price': 2750,  'unit': 'bag',    'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Wheat (90kg bag)',          'price': 3850,  'unit': 'bag',    'trend': 'up',     'change': '+6%',  'type': 'crop'},
    {'crop': 'Potatoes - Shangi (50kg)', 'price': 1550,  'unit': 'bag',    'trend': 'down',   'change': '-2%',  'type': 'crop'},
    {'crop': 'Pyrethrum',                 'price': 115,   'unit': 'kg',     'trend': 'up',     'change': '+8%',  'type': 'crop'},
    {'crop': 'Fresh Milk',                'price': 38,    'unit': 'litre',  'trend': 'stable', 'change': '0%',   'type': 'livestock'},
    {'crop': 'Eggs (Tray of 30)',         'price': 348,   'unit': 'tray',   'trend': 'up',     'change': '+3%',  'type': 'livestock'},
    {'crop': 'Beef (live weight)',        'price': 328,   'unit': 'kg',     'trend': 'stable', 'change': '+1%',  'type': 'livestock'},
    {'crop': 'Sunflower',                 'price': 50,    'unit': 'kg',     'trend': 'up',     'change': '+5%',  'type': 'crop'},
  ],
  'Nyeri': [
    {'crop': 'Tea (Green Leaf)',          'price': 26,    'unit': 'kg',     'trend': 'stable', 'change': '+2%',  'type': 'crop'},
    {'crop': 'Coffee (Parchment)',        'price': 128,   'unit': 'kg',     'trend': 'up',     'change': '+11%', 'type': 'crop'},
    {'crop': 'Potatoes - Shangi (50kg)', 'price': 1550,  'unit': 'bag',    'trend': 'down',   'change': '-3%',  'type': 'crop'},
    {'crop': 'Macadamia (nut in shell)',  'price': 82,    'unit': 'kg',     'trend': 'up',     'change': '+12%', 'type': 'crop'},
    {'crop': 'Fresh Milk',                'price': 40,    'unit': 'litre',  'trend': 'stable', 'change': '+1%',  'type': 'livestock'},
    {'crop': 'Honey (Raw)',               'price': 760,   'unit': 'kg',     'trend': 'up',     'change': '+6%',  'type': 'livestock'},
    {'crop': 'Maize (90kg bag)',          'price': 3000,  'unit': 'bag',    'trend': 'up',     'change': '+3%',  'type': 'crop'},
    {'crop': 'Beans - Rose Coco (90kg)', 'price': 9200,  'unit': 'bag',    'trend': 'up',     'change': '+4%',  'type': 'crop'},
    {'crop': 'Eggs (Tray of 30)',         'price': 358,   'unit': 'tray',   'trend': 'up',     'change': '+3%',  'type': 'livestock'},
    {'crop': 'Kienyeji Chicken (live)',   'price': 880,   'unit': 'bird',   'trend': 'up',     'change': '+5%',  'type': 'livestock'},
  ],
};

List<Map<String, dynamic>> getCountyPrices(String county) {
  // Try exact match
  if (kCountyMarketPrices.containsKey(county)) return kCountyMarketPrices[county]!;
  // Try partial match
  for (final key in kCountyMarketPrices.keys) {
    if (county.toLowerCase().contains(key.toLowerCase()) ||
        key.toLowerCase().contains(county.toLowerCase())) {
      return kCountyMarketPrices[key]!;
    }
  }
  return kCountyMarketPrices['Nairobi (Wholesale)']!;
}

// ── County performance ───────────────────────────────────────────

const Map<String, Map<String, List<String>>> kCountyPerformance = {
  'Nairobi (Wholesale)': {
    'doing_well': ['Onions', 'Avocado', 'Honey', 'Wheat', 'Maize', 'Eggs', 'Coffee', 'Macadamia'],
    'doing_poorly': ['Tomatoes', 'Cabbage', 'Fish'],
  },
  'Nakuru': {
    'doing_well': ['Pyrethrum', 'Wheat', 'Onions', 'Maize', 'Honey', 'Sunflower'],
    'doing_poorly': ['Potatoes', 'Tomatoes'],
  },
  'Meru': {
    'doing_well': ['Macadamia', 'Coffee', 'Avocado', 'Tea', 'Honey', 'Miraa'],
    'doing_poorly': [],
  },
  'Kiambu': {
    'doing_well': ['Coffee', 'Tea', 'Strawberry', 'Avocado', 'Honey'],
    'doing_poorly': ['Potatoes', 'Tomatoes', 'Cabbage'],
  },
  'Kisumu': {
    'doing_well': ['Sorghum', 'Rice', 'Maize', 'Eggs', 'Sweet Potatoes'],
    'doing_poorly': ['Fish - Tilapia'],
  },
  'Machakos': {
    'doing_well': ['Green Grams', 'Beans', 'Maize', 'Goat Meat', 'Honey', 'Onions'],
    'doing_poorly': ['Mangoes'],
  },
  'Kakamega': {
    'doing_well': ['Maize', 'Tea', 'Cassava', 'Sugarcane', 'Beans'],
    'doing_poorly': ['Milk'],
  },
  'Trans Nzoia': {
    'doing_well': ['Maize', 'Wheat', 'Beans', 'Sunflower'],
    'doing_poorly': ['Potatoes'],
  },
  'Uasin Gishu': {
    'doing_well': ['Maize', 'Wheat', 'Sunflower', 'Pyrethrum'],
    'doing_poorly': ['Potatoes'],
  },
  'Nyeri': {
    'doing_well': ['Coffee', 'Tea', 'Macadamia', 'Honey', 'Beans'],
    'doing_poorly': ['Potatoes'],
  },
};

Map<String, List<String>> getCountyPerformance(String county) {
  if (kCountyPerformance.containsKey(county)) return kCountyPerformance[county]!;
  for (final key in kCountyPerformance.keys) {
    if (county.toLowerCase().contains(key.toLowerCase())) return kCountyPerformance[key]!;
  }
  return {'doing_well': ['Maize', 'Beans', 'Eggs'], 'doing_poorly': ['Tomatoes']};
}

// ── Livestock ────────────────────────────────────────────────────

const Map<String, Map<String, dynamic>> kLivestockTypes = {
  // ── Cattle ──────────────────────────────────────────
  'Beef Cattle':        {'emoji': '🐂', 'breeds': ['Boran', 'Zebu (Local)', 'Angus', 'Hereford', 'Charolais', 'Sahiwal x Zebu', 'Crossbreed']},
  'Dairy Cows':         {'emoji': '🐄', 'breeds': ['Friesian', 'Ayrshire', 'Jersey', 'Sahiwal', 'Guernsey', 'Crossbreed']},
  // ── Poultry ─────────────────────────────────────────
  'Broiler Chickens':   {'emoji': '🐔', 'breeds': ['Ross 308', 'Cobb 500', 'Hubbard Classic', 'Arbor Acres']},
  'Ducks':              {'emoji': '🦆', 'breeds': ['Muscovy', 'Khaki Campbell', 'Pekin', 'Indian Runner']},
  'Geese':              {'emoji': '🪿', 'breeds': ['Toulouse', 'Embden', 'African', 'Local']},
  'Guinea Fowl':        {'emoji': '🐦', 'breeds': ['Helmeted', 'Local']},
  'Kienyeji Chicken':   {'emoji': '🐓', 'breeds': ['KARI Improved Kienyeji', 'Rainbow Rooster', 'Kenbro', 'Local']},
  'Layer Chickens':     {'emoji': '🥚', 'breeds': ['Hy-Line Brown', 'Lohmann Brown', 'ISA Brown', 'Nick Chick']},
  'Quail':              {'emoji': '🐦', 'breeds': ['Japanese Quail', 'Coturnix']},
  'Turkeys':            {'emoji': '🦃', 'breeds': ['Broad Breasted White', 'Bronze', 'Bourbon Red', 'Local']},
  // ── Goats & Sheep ───────────────────────────────────
  'Dairy Goats':        {'emoji': '🐐', 'breeds': ['Toggenburg', 'Saanen', 'German Alpine', 'Crossbreed']},
  'Meat Goats':         {'emoji': '🐐', 'breeds': ['Boer', 'Galla', 'Local']},
  'Sheep':              {'emoji': '🐑', 'breeds': ['Dorper', 'Red Maasai', 'Hampshire', 'Local']},
  // ── Pigs ────────────────────────────────────────────
  'Pigs':               {'emoji': '🐷', 'breeds': ['Large White', 'Landrace', 'Duroc', 'Hampshire', 'Crossbreed']},
  // ── Small & Quick Income ────────────────────────────
  'Rabbits':            {'emoji': '🐇', 'breeds': ['New Zealand White', 'Californian', 'Chinchilla', 'Dutch', 'Flemish Giant']},
  // ── Niche / Additional ──────────────────────────────
  'Bees':               {'emoji': '🐝', 'breeds': ['African Honey Bee', 'Langstroth Colony', 'Log Hive Colony', 'Kenya Top Bar']},
  'Camels':             {'emoji': '🐪', 'breeds': ['One-humped (Dromedary)', 'Somali', 'Rendille']},
  'Fish (Aquaculture)': {'emoji': '🐟', 'breeds': ['Tilapia (Nile)', 'Catfish', 'Rainbow Trout', 'Common Carp']},
};

// ── Vaccination schedule ─────────────────────────────────────────

// ════════════════════════════════════════════════════════════════
// LIVESTOCK COUNTY SUITABILITY
// ════════════════════════════════════════════════════════════════
const Map<String, Map<String, dynamic>> kLivestockSuitability = {
  'Dairy Cows': {
    'bestCounties': ['Nakuru', 'Kiambu', 'Nyandarua', 'Meru', 'Nyeri', 'Kericho', 'Bomet', 'Muranga', 'Trans Nzoia', 'Uasin Gishu', 'Elgeyo-Marakwet'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa', 'Marsabit', 'Isiolo'],
    'tip': 'Cool highlands above 1500m are ideal. Friesian and Ayrshire thrive in Nakuru, Nyandarua, and Kiambu. Crossbreeds (Sahiwal x Friesian) work better in warmer areas.',
  },
  'Beef Cattle': {
    'bestCounties': ['Kajiado', 'Narok', 'Baringo', 'Laikipia', 'Samburu', 'Isiolo', 'Turkana', 'Marsabit', 'Tana River', 'Taita-Taveta'],
    'poorCounties': ['Mombasa', 'Kisumu'],
    'tip': 'Beef cattle suit dry rangelands. Boran and Zebu are hardy for ASAL areas. Kajiado and Narok are Kenya traditional beef regions. Good income with group ranches.',
  },
  'Dairy Goats': {
    'bestCounties': ['Meru', 'Nyeri', 'Kiambu', 'Muranga', 'Nakuru', 'Nyandarua', 'Embu', 'Kirinyaga'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir'],
    'tip': 'Toggenburg and Saanen do well in cool highlands. Good alternative to dairy cows for small farms. Milk is nutritious and sells well locally.',
  },
  'Meat Goats': {
    'bestCounties': ['Kajiado', 'Narok', 'Machakos', 'Kitui', 'Makueni', 'Baringo', 'Turkana', 'Samburu', 'Isiolo', 'Garissa', 'Wajir', 'Mandera'],
    'poorCounties': [],
    'tip': 'Galla goats are ideal for ASAL areas. Meat goats suit almost all counties. Boer goats command premium prices. Goat meat demand is very high during festivals.',
  },
  'Sheep': {
    'bestCounties': ['Narok', 'Kajiado', 'Baringo', 'Laikipia', 'Nakuru', 'Nyandarua', 'Samburu', 'Turkana', 'Marsabit'],
    'poorCounties': ['Mombasa', 'Kilifi', 'Kwale'],
    'tip': 'Red Maasai sheep are drought-resistant and ideal for Narok and Kajiado. Dorper crossbreeds give good meat yields. Sheep farming suits dry areas well.',
  },
  'Pigs': {
    'bestCounties': ['Kakamega', 'Bungoma', 'Busia', 'Vihiga', 'Homa Bay', 'Migori', 'Siaya', 'Kisumu', 'Kiambu', 'Nakuru', 'Trans Nzoia'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir', 'Garissa'],
    'tip': 'Western Kenya is the pig farming hub. Requires good hygiene and clean water. Pigs grow fast (6 months to market). Avoid in Muslim-majority counties.',
  },
  'Kienyeji Chicken': {
    'bestCounties': ['Kakamega', 'Bungoma', 'Siaya', 'Homa Bay', 'Machakos', 'Kitui', 'Meru', 'Embu', 'Nakuru', 'Kisumu'],
    'poorCounties': [],
    'tip': 'Kienyeji chickens suit all counties and require minimal input. KARI Improved Kienyeji gives 3x more eggs than local birds. Very hardy, low mortality.',
  },
  'Layer Chickens': {
    'bestCounties': ['Kiambu', 'Nakuru', 'Nairobi', 'Meru', 'Nyeri', 'Uasin Gishu', 'Trans Nzoia', 'Kakamega'],
    'poorCounties': ['Turkana', 'Mandera', 'Marsabit'],
    'tip': 'Layers need consistent feed, water, and cool temperatures. Best near urban markets for easy egg sales. Requires capital investment but steady daily income.',
  },
  'Broiler Chickens': {
    'bestCounties': ['Kiambu', 'Nakuru', 'Nairobi', 'Uasin Gishu', 'Kakamega', 'Mombasa', 'Kisumu', 'Meru'],
    'poorCounties': ['Turkana', 'Marsabit', 'Mandera'],
    'tip': 'Broilers are a 6-week business. Best near urban areas for meat market. Requires controlled housing and quality feeds. Ross 308 and Cobb 500 are top performers.',
  },
  'Ducks': {
    'bestCounties': ['Kisumu', 'Homa Bay', 'Siaya', 'Migori', 'Busia', 'Kilifi', 'Kwale', 'Mombasa', 'Tana River'],
    'poorCounties': ['Nyandarua', 'Elgeyo-Marakwet'],
    'tip': 'Ducks love water areas. Lake Victoria region and Coast are ideal. More disease-resistant than chickens. Muscovy ducks are the most popular in Kenya for meat.',
  },
  'Turkeys': {
    'bestCounties': ['Kiambu', 'Nakuru', 'Meru', 'Nyeri', 'Uasin Gishu', 'Trans Nzoia', 'Nyandarua', 'Kakamega'],
    'poorCounties': ['Turkana', 'Mandera', 'Wajir'],
    'tip': 'Turkeys fetch premium prices especially at Christmas and Easter. Require space and good nutrition. Broad Breasted White is the most popular commercial breed.',
  },
  'Rabbits': {
    'bestCounties': ['Kiambu', 'Nakuru', 'Meru', 'Nyeri', 'Muranga', 'Embu', 'Kirinyaga', 'Nyandarua', 'Kakamega', 'Bungoma'],
    'poorCounties': ['Turkana', 'Mandera', 'Garissa'],
    'tip': 'Rabbits need cool to moderate temperatures. Excellent starter livestock for youth and women. New Zealand White and Californian are best for meat. Very fast income.',
  },
  'Guinea Fowl': {
    'bestCounties': ['Machakos', 'Kitui', 'Makueni', 'Kajiado', 'Narok', 'Baringo', 'Turkana', 'Samburu'],
    'poorCounties': [],
    'tip': 'Guinea fowl are hardy and suit dry areas. They control insects naturally. Meat and eggs are considered a delicacy and command higher prices than chicken.',
  },
  'Quail': {
    'bestCounties': ['Nairobi', 'Kiambu', 'Nakuru', 'Meru', 'Nyeri', 'Kakamega', 'Kisumu', 'Mombasa'],
    'poorCounties': [],
    'tip': 'Quail farming is ideal for urban and peri-urban areas. Very small space needed. Eggs are prized for health benefits. Mature in 6 weeks and lay daily.',
  },
  'Bees': {
    'bestCounties': ['Baringo', 'Nakuru', 'Laikipia', 'Meru', 'Kitui', 'Machakos', 'Kajiado', 'Narok', 'Tana River', 'Kilifi', 'Kwale'],
    'poorCounties': ['Nairobi', 'Mombasa'],
    'tip': 'Kenya is Africa 3rd largest honey producer. Baringo and Laikipia are the honey belt. Log hives are cheapest to start. Honey, wax, and propolis all sell well.',
  },
  'Fish (Aquaculture)': {
    'bestCounties': ['Kisumu', 'Homa Bay', 'Siaya', 'Migori', 'Busia', 'Kirinyaga', 'Embu', 'Meru', 'Tana River', 'Nakuru'],
    'poorCounties': ['Turkana', 'Marsabit', 'Mandera', 'Wajir'],
    'tip': 'Tilapia is the most farmed fish in Kenya. Mwea (Kirinyaga) is the top fish farming area. A 300m² pond can produce 500kg of fish in 6 months. Needs clean water source.',
  },
  'Camels': {
    'bestCounties': ['Turkana', 'Marsabit', 'Mandera', 'Wajir', 'Garissa', 'Isiolo', 'Samburu'],
    'poorCounties': ['Nairobi', 'Kiambu', 'Mombasa', 'Kisumu', 'Nakuru', 'Kericho'],
    'tip': 'Camels are perfectly suited to arid northern Kenya. Milk production is very high (10-20L/day). Camel milk sells at premium prices (KSh 150-300/L) in Nairobi markets.',
  },
  'Geese': {
    'bestCounties': ['Kisumu', 'Homa Bay', 'Siaya', 'Busia', 'Kakamega', 'Bungoma', 'Kilifi', 'Kwale'],
    'poorCounties': ['Turkana', 'Mandera', 'Marsabit'],
    'tip': 'Geese are low-maintenance and excellent grazers. They produce large eggs and quality meat. Popular in Lake Victoria region and Coast. Good alarm birds against intruders.',
  },
};

// Get livestock suitability advice for a county
Map<String, dynamic>? getLivestockSuitability(String livestockType, String county) {
  final data = kLivestockSuitability[livestockType];
  if (data == null) return null;

  final bestCounties = List<String>.from(data['bestCounties'] as List);
  final poorCounties = List<String>.from(data['poorCounties'] as List);

  final isGood = bestCounties.any((c) =>
      county.toLowerCase().contains(c.toLowerCase()) ||
      c.toLowerCase().contains(county.toLowerCase().split(' ').first));
  final isPoor = poorCounties.any((c) =>
      county.toLowerCase().contains(c.toLowerCase()) ||
      c.toLowerCase().contains(county.toLowerCase().split(' ').first));

  String suitability;
  String icon;
  if (isPoor) {
    suitability = 'Not recommended for $county. Consider alternatives better suited to this region.';
    icon = '❌';
  } else if (isGood) {
    suitability = '$county is excellent for ${livestockType.toLowerCase()}!';
    icon = '✅';
  } else {
    suitability = '$county can support ${livestockType.toLowerCase()} with proper management.';
    icon = 'ℹ️';
  }

  return {
    'isGood': isGood,
    'isPoor': isPoor,
    'suitability': suitability,
    'icon': icon,
    'tip': data['tip'],
  };
}

const Map<String, List<Map<String, dynamic>>> kVaccinationSchedule = {
  'Dairy Cows': [
    {'vaccine': 'Foot & Mouth Disease (FMD)', 'interval': 'Every 6 months', 'notes': 'Compulsory in Kenya. Schedule: March & September.'},
    {'vaccine': 'Lumpy Skin Disease (LSD)',   'interval': 'Annually',        'notes': 'Vaccinate before onset of rains.'},
    {'vaccine': 'Brucellosis',                'interval': 'Once (heifers)',   'notes': 'Vaccinate heifers at 3-8 months only.'},
    {'vaccine': 'Anthrax',                    'interval': 'Annually',         'notes': 'In anthrax-prone areas only.'},
    {'vaccine': 'East Coast Fever (ECF)',     'interval': 'Once',             'notes': 'Contact DVS for ITM method.'},
  ],
  'Beef Cattle': [
    {'vaccine': 'Foot & Mouth Disease (FMD)', 'interval': 'Every 6 months', 'notes': 'Compulsory.'},
    {'vaccine': 'Lumpy Skin Disease (LSD)',   'interval': 'Annually',        'notes': 'Before rainy season.'},
    {'vaccine': 'Anthrax',                    'interval': 'Annually',         'notes': 'Prone areas only.'},
    {'vaccine': 'East Coast Fever (ECF)',     'interval': 'Once',             'notes': 'Tick-infested areas.'},
  ],
  'Goats': [
    {'vaccine': 'PPR (Goat Plague)',          'interval': 'Every 3 years',   'notes': 'Critical. High mortality if unvaccinated.'},
    {'vaccine': 'Foot & Mouth Disease (FMD)', 'interval': 'Every 6 months', 'notes': 'Compulsory.'},
    {'vaccine': 'Goat Pox',                   'interval': 'Annually',         'notes': 'Arid/semi-arid areas especially.'},
    {'vaccine': 'Enterotoxaemia',             'interval': 'Every 6 months',  'notes': 'Especially kids and fast-growing animals.'},
  ],
  'Dairy Goats': [
    {'vaccine': 'PPR (Goat Plague)',          'interval': 'Every 3 years',   'notes': 'Critical. High mortality if unvaccinated.'},
    {'vaccine': 'Foot & Mouth Disease (FMD)', 'interval': 'Every 6 months', 'notes': 'Compulsory.'},
    {'vaccine': 'Goat Pox',                   'interval': 'Annually',         'notes': 'Arid/semi-arid areas especially.'},
    {'vaccine': 'Enterotoxaemia',             'interval': 'Every 6 months',  'notes': 'Especially kids and fast-growing animals.'},
  ],
  'Meat Goats': [
    {'vaccine': 'PPR (Goat Plague)',          'interval': 'Every 3 years',   'notes': 'Critical. High mortality if unvaccinated.'},
    {'vaccine': 'Foot & Mouth Disease (FMD)', 'interval': 'Every 6 months', 'notes': 'Compulsory.'},
    {'vaccine': 'Goat Pox',                   'interval': 'Annually',         'notes': 'Arid/semi-arid areas especially.'},
    {'vaccine': 'Enterotoxaemia',             'interval': 'Every 6 months',  'notes': 'Especially kids and fast-growing animals.'},
  ],
  'Sheep': [
    {'vaccine': 'PPR',                        'interval': 'Every 3 years',   'notes': 'Critical. Can wipe out entire flock.'},
    {'vaccine': 'Foot & Mouth Disease (FMD)', 'interval': 'Every 6 months', 'notes': 'Compulsory.'},
    {'vaccine': 'Enterotoxaemia',             'interval': 'Every 6 months',  'notes': 'Especially lambs 2-6 months.'},
  ],
      'Kienyeji Chicken': [
    {'vaccine': 'Newcastle Disease (ND)',     'interval': 'Every 3 months',  'notes': 'Most important. Lasota 3ml/litre water.'},
    {'vaccine': 'Fowl Pox',                  'interval': 'Every 6 months',  'notes': 'Wing stab method. Free-range birds especially.'},
  ],
  'Pigs': [
    {'vaccine': 'Foot & Mouth Disease (FMD)', 'interval': 'Every 6 months', 'notes': 'Compulsory.'},
    {'vaccine': 'Erysipelas',                 'interval': 'Every 6 months',  'notes': 'Piglets from 6-8 weeks.'},
  ],
  'Rabbits': [
    {'vaccine': 'Rabbit Haemorrhagic Disease (RHD)', 'interval': 'Annually', 'notes': 'Kits from 10 weeks.'},
  ],

  'Broiler Chickens': [
    {'vaccine': 'Newcastle Disease (Lasota)', 'interval': 'Every 6 weeks', 'notes': 'Critical for broilers. Administer in drinking water or eye drop. First dose at day 7.'},
    {'vaccine': 'Gumboro (IBD)',               'interval': 'Every 3 weeks',  'notes': 'Infectious Bursal Disease. Vaccinate at day 14 and day 21. Prevents immunosuppression.'},
    {'vaccine': 'Fowl Typhoid',                'interval': 'Annually',        'notes': 'Killed vaccine. Protects against Salmonella gallinarum.'},
  ],
  'Layer Chickens': [
    {'vaccine': 'Newcastle Disease (Lasota)', 'interval': 'Every 6 weeks', 'notes': 'Essential throughout laying period. Use La Sota strain in water.'},
    {'vaccine': 'Gumboro (IBD)',               'interval': 'Every 3 weeks',  'notes': 'Vaccinate chicks at 14 and 21 days. Critical before point-of-lay.'},
    {'vaccine': 'Mareks Disease',            'interval': 'Once (day old)',  'notes': 'Given at hatchery on day 1. Lifetime protection against tumours.'},
    {'vaccine': 'Infectious Bronchitis (IB)',  'interval': 'Every 3 months', 'notes': 'Protects respiratory system. Use H120 strain at day 7, then every 3 months.'},
  ],
  'Ducks': [
    {'vaccine': 'Duck Virus Hepatitis (DVH)', 'interval': 'Annually',       'notes': 'Vaccinate breeders 2 weeks before egg collection. Protects ducklings via maternal antibodies.'},
    {'vaccine': 'Duck Plague (Duck Enteritis)', 'interval': 'Annually',     'notes': 'Modified live vaccine. Critical in areas with wild waterfowl. Annual booster needed.'},
    {'vaccine': 'Newcastle Disease',           'interval': 'Every 6 months', 'notes': 'Ducks are carriers — vaccinate to protect other poultry nearby.'},
  ],
  'Turkeys': [
    {'vaccine': 'Newcastle Disease',           'interval': 'Every 6 weeks',  'notes': 'Turkeys are highly susceptible. Use La Sota strain. Critical for flocks near chickens.'},
    {'vaccine': 'Turkey Rhinotracheitis (TRT)', 'interval': 'Annually',      'notes': 'Live attenuated vaccine. Protects respiratory system. Administer at 6-8 weeks.'},
    {'vaccine': 'Haemorrhagic Enteritis',       'interval': 'Once at 6wks',  'notes': 'Mild strain vaccine in drinking water. Protect birds at 6 weeks of age.'},
  ],
  'Geese': [
    {'vaccine': 'Duck Plague',                 'interval': 'Annually',       'notes': 'Goose enteritis is caused by same virus. Annual vaccination before breeding season.'},
    {'vaccine': 'Newcastle Disease',           'interval': 'Every 6 months', 'notes': 'Waterfowl can carry virus without symptoms. Protects nearby chickens.'},
  ],
  'Guinea Fowl': [
    {'vaccine': 'Newcastle Disease (Lasota)', 'interval': 'Every 3 months', 'notes': 'Guinea fowl are susceptible to Newcastle. Administer in drinking water every 3 months.'},
    {'vaccine': 'Fowl Pox',                   'interval': 'Annually',        'notes': 'Wing-web stab method. Vaccinate at 6-8 weeks before dry season (peak pox period).'},
  ],
  'Quail': [
    {'vaccine': 'Newcastle Disease',          'interval': 'Every 6 weeks',  'notes': 'Japanese quail are susceptible. Use La Sota in drinking water from week 1.'},
    {'vaccine': 'Quail Bronchitis',            'interval': 'Every 3 months', 'notes': 'Available as combined vaccine. Protects respiratory tract.'},
  ],
  'Ostriches': [
    {'vaccine': 'Newcastle Disease',          'interval': 'Every 6 months', 'notes': 'Ostriches are susceptible to NDV. Injectable killed vaccine preferred.'},
    {'vaccine': 'Anthrax',                    'interval': 'Annually',        'notes': 'Critical in Rift Valley and arid areas. Sterne spore vaccine annually before rains.'},
    {'vaccine': 'Avian Influenza (AI)',        'interval': 'Annually',        'notes': 'Required if near wild birds or poultry operations. Contact DVS for licensed vaccine.'},
  ],
  'Camels': [
    {'vaccine': 'Camel Pox',                  'interval': 'Annually',        'notes': 'Live attenuated vaccine. Critical in NFD counties. Vaccinate young camels before age 1.'},
    {'vaccine': 'Anthrax',                    'interval': 'Annually',        'notes': 'Sterne vaccine annually before long rains. Mandatory in Turkana, Marsabit, Wajir areas.'},
    {'vaccine': 'CCPP (Contagious Pleuropneumonia)', 'interval': 'Annually', 'notes': 'Compulsory for camels in northern Kenya. Contact DVS for government vaccination programs.'},
  ],
  'Horses': [
    {'vaccine': 'African Horse Sickness (AHS)', 'interval': 'Annually',     'notes': 'Compulsory in Kenya. Polyvalent vaccine covering multiple AHS serotypes. Before vector season.'},
    {'vaccine': 'Tetanus',                     'interval': 'Annually',       'notes': 'Toxoid vaccine. Essential especially after injuries or surgery. Annual booster.'},
    {'vaccine': 'Equine Influenza',             'interval': 'Every 6 months', 'notes': 'Killed vaccine. Required for horses attending shows or racing events.'},
  ],
  'Donkeys': [
    {'vaccine': 'African Horse Sickness (AHS)', 'interval': 'Annually',     'notes': 'Donkeys are sentinel animals for AHS. Annual vaccination before rains.'},
    {'vaccine': 'Tetanus',                     'interval': 'Annually',       'notes': 'Working donkeys are highly at risk from wounds. Annual toxoid booster.'},
    {'vaccine': 'Anthrax',                    'interval': 'Annually',        'notes': 'Annual Sterne vaccine in endemic areas (Rift Valley, North Kenya).'},
  ],

    };

List<Map<String, dynamic>> getVaccinationSchedule(String livestockType) {
  // Direct lookup first
  if (kVaccinationSchedule.containsKey(livestockType)) {
    return kVaccinationSchedule[livestockType]!;
  }
  // Fuzzy match for renamed types
  final t = livestockType.toLowerCase();
  for (final key in kVaccinationSchedule.keys) {
    final k = key.toLowerCase();
    if (t.contains(k.split(' ').first) || k.contains(t.split(' ').first)) {
      return kVaccinationSchedule[key]!;
    }
  }
  return <Map<String, dynamic>>[];
}

// ── Task categories ──────────────────────────────────────────────

const List<String> kTaskCategories = [
  'Planting', 'Fertilizing', 'Weeding', 'Watering', 'Spraying',
  'Harvesting', 'Livestock Care', 'Equipment', 'Market', 'Soil Testing',
  'Pruning', 'Pest Control', 'Vaccination', 'Other',
];

// ── Kenya Counties ───────────────────────────────────────────────

const List<String> kKenyaCounties = [
  'Baringo', 'Bomet', 'Bungoma', 'Busia', 'Elgeyo-Marakwet', 'Embu',
  'Garissa', 'Homa Bay', 'Isiolo', 'Kajiado', 'Kakamega', 'Kericho',
  'Kiambu', 'Kilifi', 'Kirinyaga', 'Kisii', 'Kisumu', 'Kitui',
  'Kwale', 'Laikipia', 'Lamu', 'Machakos', 'Makueni', 'Mandera',
  'Marsabit', 'Meru', 'Migori', 'Mombasa', 'Murang\'a', 'Nairobi',
  'Nakuru', 'Nandi', 'Narok', 'Nyamira', 'Nyandarua', 'Nyeri',
  'Samburu', 'Siaya', 'Taita-Taveta', 'Tana River', 'Tharaka-Nithi',
  'Trans Nzoia', 'Turkana', 'Uasin Gishu', 'Vihiga', 'Wajir', 'West Pokot',
];

// ── Farming tips ─────────────────────────────────────────────────

const List<Map<String, String>> kFarmingTips = [
  {'category': 'Planting', 'title': 'Best time to plant maize in Kenya', 'source': 'Kenya Seed Company',
   'body': 'Plant at the onset of long rains (March-May) or short rains (Oct-Nov). Soil temperature must be above 16°C. Plant 2 seeds per hole, 75cm between rows, 25cm between plants.'},
  {'category': 'Planting', 'title': 'Soil preparation for tomatoes', 'source': 'Horticulture Research Institute',
   'body': 'Prepare deep-tilled beds with well-rotten manure (3 tonnes/acre). Test soil pH — tomatoes prefer 6.0-6.8. Apply lime if pH is below 5.5.'},
  {'category': 'Planting', 'title': 'Intercropping maize and beans', 'source': 'KALRO',
   'body': 'Plant beans between maize rows to fix nitrogen and maximise land use. KALRO recommends 2 rows maize to 1 row beans. Increases total yield by 20-30%.'},
  {'category': 'Pest Control', 'title': 'Fall Armyworm (FAW) management', 'source': 'FAO Kenya',
   'body': 'Scout crops weekly. FAW attacks maize in the whorl stage. Apply Coragen early. Biological control with Bt is effective for organic farming.'},
  {'category': 'Pest Control', 'title': 'Stem borer control in maize', 'source': 'ICIPE',
   'body': 'Apply granular insecticide into the whorl at V3-V6 stage. Push-pull system with Desmodium is very effective and eco-friendly — reduces stemborers by 80%.'},
  {'category': 'Irrigation', 'title': 'Drip irrigation saves water', 'source': 'Kenya Irrigation Authority',
   'body': 'Drip irrigation uses 30-50% less water than furrow irrigation. Flush pipes weekly to prevent clogging. Fertigation through drip lines increases nutrient efficiency.'},
  {'category': 'Soil Health', 'title': 'Soil testing — why and when', 'source': 'KALRO',
   'body': 'Test soil every 2-3 years or when yields drop. KALRO Kabete lab costs KSh 500/sample. Test for pH, N, P, K, and micronutrients. Results guide fertilizer use.'},
  {'category': 'Market', 'title': 'Getting the best price for produce', 'source': 'Kenya Farmers Association',
   'body': 'Join a farmer cooperative to access better prices. Avoid selling immediately after harvest when prices are low. Store properly and wait 2-4 weeks for prices to rise.'},
  {'category': 'Market', 'title': 'Value addition for higher income', 'source': 'Kenya Agri-Business',
   'body': 'Dry tomatoes to sun-dried — value increases 3x. Mill maize to flour — sell for KSh 50/kg vs KSh 25 grain. Small packaging investment opens supermarket access.'},
  {'category': 'Livestock', 'title': 'Dairy cow milk production tips', 'source': 'Kenya Dairy Board',
   'body': 'Feed 1kg dairy meal per 2.5 litres produced. Ensure clean water always available. Deworm every 3 months. Vaccinate against FMD and LSD on schedule.'},
  {'category': 'Livestock', 'title': 'Poultry disease prevention', 'source': 'DVS Kenya',
   'body': 'Vaccinate against Newcastle Disease every 3 months using Lasota. Maintain biosecurity — restrict farm visitors, disinfect equipment weekly. Do not mix old and new birds.'},
  {'category': 'Livestock', 'title': 'Bee farming for extra income', 'source': 'KEPHIS',
   'body': 'One Langstroth hive produces 20-30kg honey/year. Raw honey sells for KSh 700-900/kg. Beeswax adds KSh 600/kg extra. Install hives near water source and flowering plants.'},
  {'category': 'Planting', 'title': 'Avocado grafted vs seedling trees', 'source': 'HCD Kenya',
   'body': 'Always plant grafted avocado (not seedling). Grafted Hass trees fruit in 3 years; seedlings take 7+ years and fruit quality is unknown. Buy from certified nurseries only.'},

  // ── Planting Tips ──────────────────────────────────────────────
  {'category': 'Planting', 'title': 'Maize: Plant at rains onset, not before',
   'source': 'KARLO',
   'body': 'Planting maize 2 weeks before rains fail leads to seed rot. Wait for reliable rain — at least 25mm in a week — before planting. Use certified seed varieties for your altitude zone.'},
  {'category': 'Planting', 'title': 'Intercrop beans with maize for double income',
   'source': 'CIMMYT Kenya',
   'body': 'Plant 2 bean seeds between every maize station. Beans fix nitrogen that feeds the maize, and you get two harvests from one plot. Use climbing beans (not bush) with tall maize varieties.'},
  {'category': 'Planting', 'title': 'Tissue culture bananas yield 3x more',
   'source': 'Kenya Horticultural Exporters',
   'body': 'Tissue culture banana plantlets (Ksh 150-250 each) are disease-free and produce bunches 40-60% heavier than suckers. They fruit earlier — 12 months vs 18. Buy from KARI or certified labs.'},
  {'category': 'Planting', 'title': 'Sukuma wiki: harvest outer leaves only',
   'source': 'HCD Kenya',
   'body': 'Never cut the whole kale plant. Remove only the 3-4 outer leaves per week. This keeps the plant growing for 2+ years. Top-dress with CAN fertiliser every 6 weeks for continuous flush.'},

  // ── Soil Health Tips ───────────────────────────────────────────
  {'category': 'Soil Health', 'title': 'Test your soil before buying fertiliser',
   'source': 'Kenya Soil Survey',
   'body': 'Soil test kits cost Ksh 500-2000 at agrovets. Without testing you may buy the wrong fertiliser. Kenyan highlands are often acidic (pH < 5.5) — lime is needed before DAP will work effectively.'},
  {'category': 'Soil Health', 'title': 'Lime acidic soils 3 months before planting',
   'source': 'KALRO',
   'body': 'Apply agricultural lime at 2-4 bags/acre on acidic soils. Lime must be worked into the soil and watered in for 3 months before planting to be effective. Check pH target for your crop.'},
  {'category': 'Soil Health', 'title': 'Compost replaces expensive fertiliser',
   'source': 'KARI',
   'body': 'A well-made compost heap of crop residues, animal manure, and kitchen waste produces 2-4 tonnes of fertiliser per season for free. Apply 2-4 tonnes/acre to improve yield and soil structure.'},
  {'category': 'Soil Health', 'title': 'Mulching cuts water use by 50%',
   'source': 'FAO Kenya',
   'body': 'Apply 10cm of dry grass, straw or maize stalks around plants. Mulch reduces evaporation, suppresses weeds, and adds organic matter. Critical for tomatoes, capsicum and dryland crops.'},
  {'category': 'Soil Health', 'title': 'Green manure: plough in legumes before flowering',
   'source': 'KALRO',
   'body': 'Plant Dolichos lablab, sun hemp, or Mucuna between seasons and plough them in when 50cm tall. Green manures add 50-80kg nitrogen/acre — equivalent to a full bag of CAN fertiliser.'},

  // ── Pest Control Tips ──────────────────────────────────────────
  {'category': 'Pest Control', 'title': 'FAW in maize: treat early or lose the crop',
   'source': 'KEPHIS',
   'body': 'Fall Armyworm attacks maize at whorl stage. Check for "window pane" leaf damage. Spray Emamectin benzoate (e.g. Coragen) or apply granules into the whorl. Act within 3 days of first sighting.'},
  {'category': 'Pest Control', 'title': 'Push-pull: cheapest FAW and Striga control',
   'source': 'ICIPE',
   'body': 'Plant Desmodium between maize rows and Napier grass on borders. Desmodium repels stem borers and FAW, and suppresses Striga weed. Napier traps borers away from maize. No chemicals needed.'},
  {'category': 'Pest Control', 'title': 'Tomato blight: spray copper before rains',
   'source': 'KEPHIS',
   'body': 'Early blight and late blight kill tomato crops fast in wet weather. Begin spraying copper oxychloride or mancozeb weekly from transplanting. Never wait for symptoms — prevention is critical.'},
  {'category': 'Pest Control', 'title': 'Neem spray: organic pest control that works',
   'source': 'KEPHIS',
   'body': 'Grind 500g neem seeds, soak in 10L water for 24 hours, filter and spray. Controls aphids, whitefly, thrips, and some caterpillars. Repeat every 5-7 days. Safe for humans and bees.'},
  {'category': 'Pest Control', 'title': 'Aphids on vegetables: blast them off with water',
   'source': 'HCD Kenya',
   'body': 'A strong jet of water knocks 80% of aphids off plants. Do this early morning so plants dry quickly. For heavy infestations, spray 1% soap solution (1 tbsp dish soap per litre) — not detergent.'},

  // ── Irrigation Tips ─────────────────────────────────────────────
  {'category': 'Irrigation', 'title': 'Drip irrigation pays back in one season',
   'source': 'Kenya Drip Irrigation Assoc.',
   'body': 'Drip kits (starting Ksh 5,000 for 1/8 acre) cut water use by 60% and increase tomato/capsicum yields by 40-60%. Government subsidies available through county agriculture offices.'},
  {'category': 'Irrigation', 'title': 'Water early morning, never at midday',
   'source': 'KALRO',
   'body': 'Watering at noon wastes 40% to evaporation and can scorch leaves. Water before 9am or after 5pm. Overhead watering in evening promotes fungal diseases — drip or furrow irrigation is better.'},
  {'category': 'Irrigation', 'title': 'Rainwater harvesting for dry season farming',
   'source': 'WRMA Kenya',
   'body': 'A 10,000L tank costs Ksh 25,000-40,000 and collects roof runoff. This supports dry season vegetable production that sells at 3-5x wet season prices. Government subsidises 3,000L tanks.'},

  // ── Market Tips ─────────────────────────────────────────────────
  {'category': 'Market', 'title': 'Sell in dry season for 3-5x better prices',
   'source': 'KAM',
   'body': 'Most farmers sell at harvest when prices crash. Store maize at home for 3 months and sell in Dec-Feb when prices peak. Use PICS bags (Ksh 150) to prevent weevil damage — no chemicals needed.'},
  {'category': 'Market', 'title': 'Group marketing gets better prices',
   'source': 'Kenya Federation of Agricultural Producers',
   'body': 'Individual farmers selling 1 bag get the worst price. Form a group of 10-20 farmers, aggregate produce, and negotiate as a block. Transporters and traders pay 15-25% more for volume.'},
  {'category': 'Market', 'title': 'Grade and sort before selling',
   'source': 'EPC Kenya',
   'body': 'Grade 1 tomatoes sell for 2x grade 3. Spend 30 minutes sorting your produce by size and quality. Supermarkets and hotels pay premium for uniform, well-packaged produce. Use Kenya Bureau of Standards grades.'},
  {'category': 'Market', 'title': 'Check Wakulima Market prices before selling',
   'source': 'Nairobi City County',
   'body': 'Nairobi Wakulima Wholesale Market sets the benchmark price for Kenya. Check prices by phone (0722-000000) or visit the market before selling. Never sell to a middleman at less than 60% of Wakulima price.'},
  {'category': 'Market', 'title': 'Contract farming eliminates market risk',
   'source': 'AFFA',
   'body': 'Companies like Vegpro, Sunripe, and AAA Growers buy vegetables at fixed prices year-round. Apply through your local agricultural officer. Requirements: irrigation, good records, GAP certification.'},

  // ── Livestock Tips ─────────────────────────────────────────────
  {'category': 'Livestock', 'title': 'Dairy cow: feed determines milk production',
   'source': 'Kenya Dairy Board',
   'body': 'A Friesian cow needs 35kg of good quality feed daily for 20L milk. Provide 6kg dairy meal + Napier grass + mineral lick. Cutting dairy meal by half cuts milk by more than half — never underfeed.'},
  {'category': 'Livestock', 'title': 'AI breeding improves your herd permanently',
   'source': 'Kenya Stud Book',
   'body': 'Artificial insemination from proven bulls (Ksh 1,500-2,500 per straw) improves your herd in one generation. Contact your local DVS office or dial AI Kenya (0800-720-400) — some counties subsidise this.'},
  {'category': 'Livestock', 'title': 'Tick control: spray every 7 days in wet season',
   'source': 'DVS Kenya',
   'body': 'East Coast Fever, Anaplasmosis, and Babesiosis are all tick-borne and kill cattle quickly. Spray or dip every 7 days during rains, every 14 days in dry weather. Rotate acaricides to prevent resistance.'},
  {'category': 'Livestock', 'title': 'Kienyeji chicken: vaccinate for Newcastle at 3 weeks',
   'source': 'DVS Kenya',
   'body': 'Newcastle Disease kills entire flocks within days. Free Lasota vaccine is available at DVS offices. Vaccinate chicks at 3 weeks, again at 2 months, then every 4 months. One dose costs Ksh 5.'},
  {'category': 'Livestock', 'title': 'Zero-grazing cuts feed waste by 40%',
   'source': 'Kenya Livestock Research Organisation',
   'body': 'Free-ranging cattle waste 30-40% of energy walking. Zero-grazing with cut Napier grass produces 30% more milk per cow and allows manure collection for biogas or compost. Start with 2-3 cows.'},
  {'category': 'Livestock', 'title': 'Rabbit farming: high returns, low investment',
   'source': 'Kenya Rabbit Farmers Assoc.',
   'body': 'A rabbit doe produces 30-40 kits per year. Meat sells at Ksh 700-900/kg live weight. Feed cost is minimal — kitchen waste, grass, and lucerne. Start with 2 does + 1 buck (Ksh 3,000-6,000 total).'},
];

// ════════════════════════════════════════════════════════════════
// NAIROBI WHOLESALE PRICES (Wakulima Market)
// Updated weekly. Prices in KSh.
// ════════════════════════════════════════════════════════════════

const List<Map<String, dynamic>> kNairobiPrices = [

  // ── CEREALS & PULSES ─────────────────────────────────────────
  {'crop': 'Maize (90kg bag)',              'price': 3500,  'range': 'KSh 3,200–3,800', 'unit': '90kg bag', 'trend': 'up',     'change': '+8%',  'type': 'crop'},
  {'crop': 'Maize Flour (1kg)',             'price': 58,    'range': 'KSh 54–62',        'unit': 'kg',       'trend': 'up',     'change': '+5%',  'type': 'crop'},
  {'crop': 'Beans — Rose Coco (1kg)',       'price': 130,   'range': 'KSh 120–140',      'unit': 'kg',       'trend': 'up',     'change': '+8%',  'type': 'crop'},
  {'crop': 'Beans — Canadian Wonder (1kg)', 'price': 115,   'range': 'KSh 105–125',      'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Beans — Mwitemania (1kg)',      'price': 140,   'range': 'KSh 130–150',      'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'crop'},
  {'crop': 'Green Grams (1kg)',             'price': 150,   'range': 'KSh 140–160',      'unit': 'kg',       'trend': 'up',     'change': '+12%', 'type': 'crop'},
  {'crop': 'Cowpeas (1kg)',                 'price': 115,   'range': 'KSh 105–125',      'unit': 'kg',       'trend': 'up',     'change': '+8%',  'type': 'crop'},
  {'crop': 'Lentils (1kg)',                 'price': 175,   'range': 'KSh 160–190',      'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Wheat Grain (90kg bag)',        'price': 4500,  'range': 'KSh 4,200–4,800',  'unit': '90kg bag', 'trend': 'up',     'change': '+7%',  'type': 'crop'},
  {'crop': 'Rice — Pishori (1kg)',          'price': 200,   'range': 'KSh 185–220',      'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'crop'},
  {'crop': 'Rice — Komboka (1kg)',          'price': 130,   'range': 'KSh 120–140',      'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Sorghum (1kg)',                 'price': 65,    'range': 'KSh 58–72',        'unit': 'kg',       'trend': 'up',     'change': '+9%',  'type': 'crop'},
  {'crop': 'Millet (1kg)',                  'price': 70,    'range': 'KSh 62–78',        'unit': 'kg',       'trend': 'up',     'change': '+7%',  'type': 'crop'},
  {'crop': 'Groundnuts — Raw (1kg)',        'price': 200,   'range': 'KSh 180–220',      'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'crop'},
  {'crop': 'Groundnuts — Roasted (1kg)',    'price': 280,   'range': 'KSh 250–310',      'unit': 'kg',       'trend': 'up',     'change': '+7%',  'type': 'crop'},
  {'crop': 'Sunflower Seed (1kg)',          'price': 75,    'range': 'KSh 68–82',        'unit': 'kg',       'trend': 'up',     'change': '+5%',  'type': 'crop'},

  // ── VEGETABLES ───────────────────────────────────────────────
  {'crop': 'Tomatoes (1kg)',                'price': 70,    'range': 'KSh 55–90',        'unit': 'kg',       'trend': 'down',   'change': '-5%',  'type': 'crop'},
  {'crop': 'Onions — Red (1kg)',            'price': 70,    'range': 'KSh 60–80',        'unit': 'kg',       'trend': 'up',     'change': '+15%', 'type': 'crop'},
  {'crop': 'Onions — White (1kg)',          'price': 75,    'range': 'KSh 65–85',        'unit': 'kg',       'trend': 'up',     'change': '+12%', 'type': 'crop'},
  {'crop': 'Kale (Sukuma Wiki) (1kg)',      'price': 20,    'range': 'KSh 15–25',        'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Cabbage (head)',                'price': 55,    'range': 'KSh 45–65',        'unit': 'head',     'trend': 'down',   'change': '-4%',  'type': 'crop'},
  {'crop': 'Carrots (1kg)',                 'price': 50,    'range': 'KSh 40–60',        'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'crop'},
  {'crop': 'Capsicum (1kg)',                'price': 140,   'range': 'KSh 120–160',      'unit': 'kg',       'trend': 'up',     'change': '+8%',  'type': 'crop'},
  {'crop': 'Spinach (bunch)',               'price': 35,    'range': 'KSh 28–42',        'unit': 'bunch',    'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Lettuce (head)',                'price': 70,    'range': 'KSh 60–80',        'unit': 'head',     'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Eggplant (1kg)',                'price': 80,    'range': 'KSh 65–95',        'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Garlic (1kg)',                  'price': 450,   'range': 'KSh 400–500',      'unit': 'kg',       'trend': 'up',     'change': '+10%', 'type': 'crop'},
  {'crop': 'Ginger (1kg)',                  'price': 400,   'range': 'KSh 350–450',      'unit': 'kg',       'trend': 'up',     'change': '+8%',  'type': 'crop'},
  {'crop': 'Peas — Fresh (1kg)',            'price': 140,   'range': 'KSh 120–160',      'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'crop'},
  {'crop': 'Pumpkin (1kg)',                 'price': 35,    'range': 'KSh 28–42',        'unit': 'kg',       'trend': 'stable', 'change': '+1%',  'type': 'crop'},
  {'crop': 'Courgette/Zucchini (1kg)',      'price': 90,    'range': 'KSh 75–105',       'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Spring Onions (bunch)',         'price': 25,    'range': 'KSh 20–30',        'unit': 'bunch',    'trend': 'stable', 'change': '+1%',  'type': 'crop'},
  {'crop': 'Coriander (bunch)',             'price': 20,    'range': 'KSh 15–25',        'unit': 'bunch',    'trend': 'stable', 'change': '+1%',  'type': 'crop'},
  {'crop': 'Broccoli (1kg)',                'price': 170,   'range': 'KSh 150–190',      'unit': 'kg',       'trend': 'up',     'change': '+12%', 'type': 'crop'},
  {'crop': 'Cauliflower (head)',            'price': 140,   'range': 'KSh 120–160',      'unit': 'head',     'trend': 'up',     'change': '+10%', 'type': 'crop'},
  {'crop': 'Beetroot (1kg)',                'price': 90,    'range': 'KSh 80–100',       'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'crop'},
  {'crop': 'Sweet Potatoes (1kg)',          'price': 40,    'range': 'KSh 32–48',        'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'crop'},
  {'crop': 'Cassava (1kg)',                 'price': 35,    'range': 'KSh 28–42',        'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Arrow Roots / Nduma (1kg)',     'price': 70,    'range': 'KSh 60–80',        'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},

  // ── POTATOES ─────────────────────────────────────────────────
  {'crop': 'Potatoes — Shangi (50kg bag)',  'price': 2000,  'range': 'KSh 1,800–2,200',  'unit': '50kg bag', 'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Potatoes — Tigoni (50kg bag)',  'price': 2200,  'range': 'KSh 2,000–2,400',  'unit': '50kg bag', 'trend': 'up',     'change': '+4%',  'type': 'crop'},
  {'crop': 'Potatoes — Desiree (50kg bag)', 'price': 2100,  'range': 'KSh 1,900–2,300',  'unit': '50kg bag', 'trend': 'stable', 'change': '+2%',  'type': 'crop'},

  // ── FRUITS ───────────────────────────────────────────────────
  {'crop': 'Avocado — Hass (each)',         'price': 32,    'range': 'KSh 25–40',        'unit': 'piece',    'trend': 'up',     'change': '+12%', 'type': 'crop'},
  {'crop': 'Avocado — Fuerte (each)',       'price': 28,    'range': 'KSh 22–34',        'unit': 'piece',    'trend': 'up',     'change': '+10%', 'type': 'crop'},
  {'crop': 'Bananas (bunch)',               'price': 380,   'range': 'KSh 320–440',      'unit': 'bunch',    'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Bananas — Cavendish (1kg)',     'price': 65,    'range': 'KSh 55–75',        'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Mangoes — Apple (1kg)',         'price': 90,    'range': 'KSh 70–110',       'unit': 'kg',       'trend': 'down',   'change': '-4%',  'type': 'crop'},
  {'crop': 'Mangoes — Tommy Atkins (1kg)',  'price': 70,    'range': 'KSh 55–85',        'unit': 'kg',       'trend': 'down',   'change': '-3%',  'type': 'crop'},
  {'crop': 'Passion Fruit (1kg)',           'price': 180,   'range': 'KSh 150–210',      'unit': 'kg',       'trend': 'up',     'change': '+10%', 'type': 'crop'},
  {'crop': 'Pawpaw (1kg)',                  'price': 90,    'range': 'KSh 75–105',       'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Watermelon (1kg)',              'price': 22,    'range': 'KSh 18–26',        'unit': 'kg',       'trend': 'down',   'change': '-2%',  'type': 'crop'},
  {'crop': 'Pineapple (each)',              'price': 90,    'range': 'KSh 75–105',       'unit': 'piece',    'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Strawberry (250g punnet)',      'price': 150,   'range': 'KSh 130–170',      'unit': 'punnet',   'trend': 'up',     'change': '+18%', 'type': 'crop'},
  {'crop': 'Oranges (1kg)',                 'price': 65,    'range': 'KSh 55–75',        'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Lemons (1kg)',                  'price': 90,    'range': 'KSh 75–105',       'unit': 'kg',       'trend': 'up',     'change': '+8%',  'type': 'crop'},
  {'crop': 'Guava (1kg)',                   'price': 90,    'range': 'KSh 75–105',       'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'crop'},

  // ── CASH CROPS ───────────────────────────────────────────────
  {'crop': 'Coffee — Parchment (1kg)',      'price': 145,   'range': 'KSh 130–160',      'unit': 'kg',       'trend': 'up',     'change': '+14%', 'type': 'crop'},
  {'crop': 'Tea — Green Leaf (1kg)',        'price': 30,    'range': 'KSh 27–33',        'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'crop'},
  {'crop': 'Macadamia — Nut in Shell (1kg)','price': 95,   'range': 'KSh 85–105',       'unit': 'kg',       'trend': 'up',     'change': '+18%', 'type': 'crop'},
  {'crop': 'Macadamia — Kernel (1kg)',      'price': 680,   'range': 'KSh 620–740',      'unit': 'kg',       'trend': 'up',     'change': '+15%', 'type': 'crop'},
  {'crop': 'Pyrethrum — Dried Flower (1kg)','price': 130,  'range': 'KSh 115–145',      'unit': 'kg',       'trend': 'up',     'change': '+12%', 'type': 'crop'},
  {'crop': 'Cotton — Seed Cotton (1kg)',    'price': 50,    'range': 'KSh 44–56',        'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'crop'},
  {'crop': 'Sugarcane (tonne)',             'price': 4200,  'range': 'KSh 3,800–4,600',  'unit': 'tonne',    'trend': 'stable', 'change': '+2%',  'type': 'crop'},
  {'crop': 'Miraa / Khat (1kg)',            'price': 220,   'range': 'KSh 180–260',      'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'crop'},

  // ── DAIRY ────────────────────────────────────────────────────
  {'crop': 'Fresh Milk — Farm Gate (1L)',   'price': 45,    'range': 'KSh 40–50',        'unit': 'litre',    'trend': 'up',     'change': '+5%',  'type': 'livestock'},
  {'crop': 'Fresh Milk — Retail (1L)',      'price': 60,    'range': 'KSh 55–65',        'unit': 'litre',    'trend': 'stable', 'change': '+3%',  'type': 'livestock'},
  {'crop': 'Ghee — Clarified Butter (1kg)','price': 1000,  'range': 'KSh 900–1,100',    'unit': 'kg',       'trend': 'up',     'change': '+5%',  'type': 'livestock'},
  {'crop': 'Yoghurt (500ml)',               'price': 90,    'range': 'KSh 80–100',       'unit': '500ml',    'trend': 'stable', 'change': '+2%',  'type': 'livestock'},
  {'crop': 'Fresh Cream (1L)',              'price': 350,   'range': 'KSh 300–400',      'unit': 'litre',    'trend': 'stable', 'change': '+3%',  'type': 'livestock'},

  // ── EGGS ─────────────────────────────────────────────────────
  {'crop': 'Eggs — Tray of 30 (Large)',     'price': 450,   'range': 'KSh 420–490',      'unit': 'tray',     'trend': 'up',     'change': '+8%',  'type': 'livestock'},
  {'crop': 'Eggs — Tray of 30 (Medium)',    'price': 400,   'range': 'KSh 370–430',      'unit': 'tray',     'trend': 'up',     'change': '+6%',  'type': 'livestock'},
  {'crop': 'Eggs — Kienyeji (tray of 30)',  'price': 600,   'range': 'KSh 550–650',      'unit': 'tray',     'trend': 'up',     'change': '+10%', 'type': 'livestock'},
  {'crop': 'Eggs — Duck (each)',            'price': 35,    'range': 'KSh 30–40',        'unit': 'piece',    'trend': 'up',     'change': '+6%',  'type': 'livestock'},

  // ── POULTRY ──────────────────────────────────────────────────
  {'crop': 'Kienyeji Chicken — Live (each)','price': 1000, 'range': 'KSh 900–1,200',    'unit': 'bird',     'trend': 'up',     'change': '+8%',  'type': 'livestock'},
  {'crop': 'Kienyeji Chicken — Dressed (kg)','price': 680, 'range': 'KSh 620–740',      'unit': 'kg',       'trend': 'up',     'change': '+7%',  'type': 'livestock'},
  {'crop': 'Broiler — Live (kg)',           'price': 290,   'range': 'KSh 270–310',      'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'livestock'},
  {'crop': 'Broiler — Dressed (kg)',        'price': 420,   'range': 'KSh 380–460',      'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'livestock'},
  {'crop': 'Turkey — Live (kg)',            'price': 700,   'range': 'KSh 650–750',      'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'livestock'},
  {'crop': 'Duck — Live (each)',            'price': 700,   'range': 'KSh 600–800',      'unit': 'bird',     'trend': 'up',     'change': '+5%',  'type': 'livestock'},

  // ── BEEF & DAIRY CATTLE ──────────────────────────────────────
  {'crop': 'Beef — Live Weight (kg)',       'price': 380,   'range': 'KSh 350–410',      'unit': 'kg',       'trend': 'up',     'change': '+4%',  'type': 'livestock'},
  {'crop': 'Beef — Dressed Carcass (kg)',   'price': 600,   'range': 'KSh 550–650',      'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'livestock'},
  {'crop': 'Dairy Heifer (head)',           'price': 90000, 'range': 'KSh 80,000–100,000','unit': 'head',    'trend': 'up',     'change': '+4%',  'type': 'livestock'},
  {'crop': 'Dairy Bull (head)',             'price': 130000,'range': 'KSh 110,000–150,000','unit': 'head',   'trend': 'stable', 'change': '+2%',  'type': 'livestock'},
  {'crop': 'Beef Steer (head)',             'price': 72000, 'range': 'KSh 65,000–80,000', 'unit': 'head',    'trend': 'stable', 'change': '+3%',  'type': 'livestock'},
  {'crop': 'Cattle Hide (each)',            'price': 1400,  'range': 'KSh 1,200–1,600',  'unit': 'piece',    'trend': 'stable', 'change': '+2%',  'type': 'livestock'},

  // ── GOATS & SHEEP ─────────────────────────────────────────────
  {'crop': 'Goat — Live (kg)',              'price': 750,   'range': 'KSh 680–820',      'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'livestock'},
  {'crop': 'Goat — Dressed (kg)',           'price': 950,   'range': 'KSh 880–1,020',    'unit': 'kg',       'trend': 'up',     'change': '+6%',  'type': 'livestock'},
  {'crop': 'Boer Goat — Breeding (head)',   'price': 20000, 'range': 'KSh 18,000–22,000','unit': 'head',     'trend': 'up',     'change': '+5%',  'type': 'livestock'},
  {'crop': 'Sheep — Live (kg)',             'price': 700,   'range': 'KSh 640–760',      'unit': 'kg',       'trend': 'up',     'change': '+5%',  'type': 'livestock'},
  {'crop': 'Mutton — Dressed (kg)',         'price': 900,   'range': 'KSh 840–960',      'unit': 'kg',       'trend': 'up',     'change': '+5%',  'type': 'livestock'},
  {'crop': 'Goat Skin (each)',              'price': 350,   'range': 'KSh 280–420',      'unit': 'piece',    'trend': 'stable', 'change': '+2%',  'type': 'livestock'},

  // ── PIGS ─────────────────────────────────────────────────────
  {'crop': 'Pig — Live (kg)',               'price': 310,   'range': 'KSh 280–340',      'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'livestock'},
  {'crop': 'Pork — Dressed (kg)',           'price': 480,   'range': 'KSh 440–520',      'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'livestock'},
  {'crop': 'Piglet (each)',                 'price': 4000,  'range': 'KSh 3,500–4,500',  'unit': 'head',     'trend': 'up',     'change': '+5%',  'type': 'livestock'},

  // ── RABBITS ──────────────────────────────────────────────────
  {'crop': 'Rabbit — Live (kg)',            'price': 750,   'range': 'KSh 680–820',      'unit': 'kg',       'trend': 'up',     'change': '+10%', 'type': 'livestock'},
  {'crop': 'Rabbit — Dressed (kg)',         'price': 950,   'range': 'KSh 880–1,020',    'unit': 'kg',       'trend': 'up',     'change': '+10%', 'type': 'livestock'},
  {'crop': 'Rabbit — Breeding Doe (each)', 'price': 3000,  'range': 'KSh 2,500–3,500',  'unit': 'head',     'trend': 'up',     'change': '+8%',  'type': 'livestock'},

  // ── HONEY & BEE PRODUCTS ─────────────────────────────────────
  {'crop': 'Honey — Raw Unprocessed (1kg)', 'price': 900,   'range': 'KSh 800–1,000',    'unit': 'kg',       'trend': 'up',     'change': '+10%', 'type': 'livestock'},
  {'crop': 'Honey — Processed Jar (500g)', 'price': 700,   'range': 'KSh 620–780',      'unit': '500g jar', 'trend': 'up',     'change': '+8%',  'type': 'livestock'},
  {'crop': 'Beeswax (1kg)',                 'price': 700,   'range': 'KSh 620–780',      'unit': 'kg',       'trend': 'up',     'change': '+8%',  'type': 'livestock'},
  {'crop': 'Propolis (100g)',               'price': 600,   'range': 'KSh 520–680',      'unit': '100g',     'trend': 'up',     'change': '+12%', 'type': 'livestock'},

  // ── FISH ─────────────────────────────────────────────────────
  {'crop': 'Tilapia — Fresh (1kg)',         'price': 420,   'range': 'KSh 380–460',      'unit': 'kg',       'trend': 'down',   'change': '-3%',  'type': 'livestock'},
  {'crop': 'Tilapia — Dried (1kg)',         'price': 680,   'range': 'KSh 620–740',      'unit': 'kg',       'trend': 'stable', 'change': '+3%',  'type': 'livestock'},
  {'crop': 'Catfish — Fresh (1kg)',         'price': 400,   'range': 'KSh 360–440',      'unit': 'kg',       'trend': 'stable', 'change': '+2%',  'type': 'livestock'},
  {'crop': 'Omena / Dagaa (1kg)',           'price': 230,   'range': 'KSh 200–260',      'unit': 'kg',       'trend': 'up',     'change': '+8%',  'type': 'livestock'},
  {'crop': 'Trout — Fresh (1kg)',           'price': 780,   'range': 'KSh 720–840',      'unit': 'kg',       'trend': 'up',     'change': '+8%',  'type': 'livestock'},
];


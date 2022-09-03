// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Radikal Riders data store
/// @author Radikal Riders
/// @notice Data storage of main on-chain Radikal Rider data, except presale data
/// @dev  Data stored relates to RiderFactory, RecipeFactory, PizzeriaFactory, PVP, RewardPool (PVE)
contract RadikalStore is Ownable{
  
  enum IngredientPacks { FIRST , SECOND, THIRD }
  enum Multipliers {x2, x3, x5, x10, x50, x100}
  enum MintingPacks {x1, x5, x10, x20}
  struct RiderAttributes {
    uint8 pizzaQuantity;
    uint8[2] wheel;
    uint8[2] fairing;
    uint8[2] clutch;
    uint8[2] exhaustPipe;
    uint8[2] turbo;
    uint8[2] nitro;
  }
  mapping(uint16 => RiderAttributes) probabilityToriderAttributes;
  mapping(IngredientPacks => uint16) ingredientPackToDays;
  mapping(IngredientPacks => uint) ingredientPackToPrice; // price in dollars
  mapping(uint => uint16[]) buyinToProbability; // buyin in dollars
  mapping(uint => uint) public buyinToReward; // buyin in dollars
  mapping(Multipliers => uint16) multiplierToProbability;
  mapping(Multipliers => uint16) multiplier;
  mapping(MintingPacks => uint8) mintingPackToQuantity;
  mapping(uint => uint16) recipeAttribute; 
  mapping(uint => uint) recipeTPRange;
  // URI Probability range per each attribute value
  mapping(uint => uint[]) ridersBaseURIProbability;
  // base URI length by Base URI
  mapping(string => uint) baseURILength;
  // Riders Base URI by attribute
  mapping(uint => string) ridersBaseURI;
  mapping(uint => string) rarenessToTokenURI;
  // Chainlink radikal fees
  mapping(uint => uint) riderQuantityToChainLinkFee;
  mapping(uint => uint) recipeQuantityToChainLinkFee;
  uint pveChainLinkFee;
  uint pvpChainLinkFee;
  uint[] regularMintingProbs;
  uint[] tipPowerURIRanges;
  uint16[] public tipPower;
  //Type of MotorBikes
  bytes12 [] private motorBikes;
  string private recipeBaseURI;
  constructor () {
    // PVE data
    tipPower = [199,299,399,499,599,699,799,899,999,1199,1399,1599,1799,1999,2199,2399,2599,2799,2999,3299,3599,3899,4199,4499,4799,5099,5399,5699,5999,7249,8499,9749,10999, 50000];
    ingredientPackToDays[IngredientPacks.FIRST] = 7;
    ingredientPackToDays[IngredientPacks.SECOND] = 15;
    ingredientPackToDays[IngredientPacks.THIRD] = 30;
    ingredientPackToPrice[IngredientPacks.FIRST] = 875;
    ingredientPackToPrice[IngredientPacks.SECOND] = 1875;
    ingredientPackToPrice[IngredientPacks.THIRD] = 3750;
    buyinToProbability[50] = [7900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900,9900];
    buyinToProbability[100] = [3750,7800,8800,9133,9300,9400,9467,9514,9550,9578,9600,9618,9633,9646,9657,9667,9675,9682,9689,9695,9700,9705,9709,9713,9717,9720,9723,9726,9729,9731,9766,9783,9900];
    buyinToProbability[150] = [2500,5200,7700,8367,8700,8900,9033,9129,9200,9256,9300,9336,9367,9392,9414,9433,9450,9465,9478,9489,9500,9510,9518,9526,9533,9540,9546,9552,9557,9562,9631,9666,9900];
    buyinToProbability[200] = [1875,3900,5775,7600,8100,8400,8600,8743,8850,8933,9000,9055,9100,9138,9171,9200,9225,9247,9267,9284,9300,9314,9327,9339,9350,9360,9369,9378,9386,9393,9497,9548,9900];
    buyinToProbability[250] = [1563,3250,4813,5700,7500,7900,8167,8357,8500,8611,8700,8773,8833,8885,8929,8967,9000,9029,9056,9079,9100,9119,9136,9152,9167,9180,9192,9204,9214,9224,9362,9431,9900];
    buyinToProbability[300] = [1250,2600,3850,4750,6000,7400,7733,7971,8150,8289,8400,8491,8567,8631,8686,8733,8775,8812,8844,8874,8900,8924,8945,8965,8983,9000,9015,9030,9043,9055,9228,9314,9900];
    buyinToProbability[350] = [1071,2229,3300,3800,5143,6343,7300,7586,7800,7967,8100,8209,8300,8377,8443,8500,8550,8594,8633,8668,8700,8729,8755,8778,8800,8820,8838,8856,8871,8886,9093,9197,9900];
    buyinToProbability[400] = [938,1950,2888,3257,4500,5550,6388,7200,7450,7644,7800,7927,8033,8123,8200,8267,8325,8376,8422,8463,8500,8533,8564,8591,8617,8640,8662,8681,8700,8717,8959,9079,9900];
    buyinToProbability[450] = [833,1733,2567,2850,4000,4933,5678,6400,7100,7322,7500,7645,7767,7869,7957,8033,8100,8159,8211,8258,8300,8338,8373,8404,8433,8460,8485,8507,8529,8548,8824,8962,9900];
    buyinToProbability[500] = [750,1560,2310,2533,3600,4440,5110,5760,6390,7000,7200,7364,7500,7615,7714,7800,7875,7941,8000,8053,8100,8143,8182,8217,8250,8280,8308,8333,8357,8379,8690,8845,9900];
    buyinToProbability[550] = [625,1300,1925,2280,3000,3700,4258,4800,5325,5833,6900,7082,7233,7362,7471,7567,7650,7724,7789,7847,7900,7948,7991,8030,8067,8100,8131,8159,8186,8210,8555,8728,9900];
    buyinToProbability[600] = [536,1114,1650,1900,2571,3171,3650,4114,4564,5000,5909,6800,6967,7108,7229,7333,7425,7506,7578,7642,7700,7752,7800,7843,7883,7920,7954,7985,8014,8041,8421,8610,9900];
    buyinToProbability[650] = [469,975,1444,1629,2250,2775,3194,3600,3994,4375,5166,5945,6700,6854,6986,7100,7200,7288,7367,7437,7500,7557,7609,7657,7700,7740,7777,7811,7843,7872,8286,8493,9900];
    buyinToProbability[700] = [417,867,1283,1425,2000,2467,2839,3200,3550,3889,4587,5279,5951,6600,6743,6867,6975,7071,7156,7232,7300,7362,7418,7470,7517,7560,7600,7637,7671,7703,8152,8376,9900];
    buyinToProbability[750] = [375,780,1155,1267,1800,2220,2555,2880,3195,3500,4123,4747,5351,5935,6500,6633,6750,6853,6944,7026,7100,7167,7227,7283,7333,7380,7423,7463,7500,7534,8017,8259,9900];
    buyinToProbability[800] = [341,709,1050,1140,1636,2018,2323,2618,2905,3182,3743,4310,4859,5390,5904,6400,6525,6635,6733,6821,6900,6971,7036,7096,7150,7200,7246,7289,7329,7366,7883,8141,9900];
    buyinToProbability[850] = [313,650,963,1036,1500,1850,2129,2400,2663,2917,3426,3946,4449,4936,5407,5862,6300,6418,6522,6616,6700,6776,6845,6909,6967,7020,7069,7115,7157,7197,7748,8024,9900];
    buyinToProbability[900] = [293,609,902,950,1406,1734,1996,2250,2496,2734,3207,3694,4166,4623,5064,5490,5901,6200,6311,6411,6500,6581,6655,6722,6783,6840,6892,6941,6986,7028,7614,7907,9900];
    buyinToProbability[950] = [274,569,843,891,1314,1620,1865,2102,2332,2555,2991,3447,3887,4314,4726,5125,5509,5788,6100,6205,6300,6386,6464,6535,6600,6660,6715,6767,6814,6859,7479,7790,9900];
    buyinToProbability[1000] = [259,538,797,832,1241,1531,1762,1986,2203,2414,2821,3251,3668,4071,4461,4837,5200,5463,5758,6000,6100,6190,6273,6348,6417,6480,6538,6593,6643,6690,7345,7672,9900];
    buyinToProbability[1050] = [203,422,624,786,973,1200,1381,1557,1727,1892,2206,2543,2870,3186,3491,3786,4070,4277,4508,4698,5900,5995,6082,6161,6233,6300,6362,6419,6471,6521,7210,7555,9900];
    buyinToProbability[1100] = [179,371,550,616,857,1057,1217,1371,1521,1667,1939,2236,2523,2802,3071,3330,3581,3763,3967,4133,5190,5800,5891,5974,6050,6120,6185,6244,6300,6352,7076,7438,9900];
    buyinToProbability[1150] = [144,300,444,543,692,854,983,1108,1229,1346,1561,1801,2033,2258,2475,2685,2887,3034,3199,3334,4184,4677,5700,5787,5867,5940,6008,6070,6129,6183,6941,7321,9900];
    buyinToProbability[1200] = [129,269,398,438,621,766,881,993,1102,1207,1394,1609,1818,2019,2214,2402,2584,2715,2863,2984,3743,4185,5100,5600,5683,5760,5831,5896,5957,6014,6807,7203,9900];
    buyinToProbability[1250] = [121,252,373,393,581,716,824,929,1031,1129,1299,1501,1695,1884,2066,2242,2412,2535,2673,2786,3493,3907,4761,5229,5500,5580,5654,5722,5786,5845,6672,7086,9900];
    buyinToProbability[1300] = [107,223,330,368,514,634,730,823,913,1000,1146,1324,1497,1664,1825,1981,2131,2240,2363,2463,3086,3452,4207,4621,4861,5400,5477,5548,5614,5676,6538,6969,9800];
    buyinToProbability[1350] = [91,190,282,326,439,541,623,702,779,854,973,1125,1273,1415,1553,1686,1814,1908,2012,2097,2626,2939,3581,3935,4140,4600,5300,5374,5443,5507,6403,6852,9700];
    buyinToProbability[1400] = [86,179,266,278,414,510,587,662,734,805,912,1056,1194,1329,1459,1584,1705,1793,1891,1972,2468,2762,3366,3699,3892,4325,4985,5200,5271,5338,6269,6734,9600];
    buyinToProbability[1450] = [80,166,246,262,383,472,544,613,680,745,839,972,1101,1225,1345,1461,1573,1654,1745,1820,2276,2549,3105,3413,3592,3993,4604,4803,5100,5169,6134,6617,9500];
    buyinToProbability[1500] = [75,156,231,243,360,444,511,576,639,700,784,909,1030,1146,1259,1369,1474,1550,1636,1706,2131,2388,2909,3199,3367,3744,4318,4505,4784,5000,6000,6500,9000];
    buyinToProbability[1550] = [50,104,154,152,240,296,341,384,426,467,518,601,681,759,835,907,977,1028,1086,1132,1413,1584,1929,2122,2234,2486,2869,2993,3179,3313,3900,4233,8000];
    buyinToReward[50] = 500;
    buyinToReward[100] = 1000;
    buyinToReward[150] = 1500;
    buyinToReward[200] = 2000;
    buyinToReward[250] = 2400;
    buyinToReward[300] = 3000;
    buyinToReward[350] = 3500;
    buyinToReward[400] = 4000;
    buyinToReward[450] = 4500;
    buyinToReward[500] = 5000;
    buyinToReward[550] = 6000;
    buyinToReward[600] = 7000;
    buyinToReward[650] = 8000;
    buyinToReward[700] = 9000;
    buyinToReward[750] = 10000;
    buyinToReward[800] = 11000;
    buyinToReward[850] = 12000;
    buyinToReward[900] = 12800;
    buyinToReward[950] = 13700;
    buyinToReward[1000] = 14500;
    buyinToReward[1050] = 18500;
    buyinToReward[1100] = 21000;
    buyinToReward[1150] = 26000;
    buyinToReward[1200] = 29000;
    buyinToReward[1250] = 31000;
    buyinToReward[1300] = 35000;
    buyinToReward[1350] = 41000;
    buyinToReward[1400] = 43500;
    buyinToReward[1450] = 47000;
    buyinToReward[1500] = 50000;
    buyinToReward[1550] = 75000;
    multiplierToProbability[Multipliers.x2] = 4990;
    multiplierToProbability[Multipliers.x3] = 3330;
    multiplierToProbability[Multipliers.x5] = 1990;
    multiplierToProbability[Multipliers.x10] = 990;
    multiplierToProbability[Multipliers.x50] = 190;
    multiplierToProbability[Multipliers.x100] = 90;
    multiplier[Multipliers.x2] = 2;
    multiplier[Multipliers.x3] = 3;
    multiplier[Multipliers.x5] = 5;
    multiplier[Multipliers.x10] = 10;
    multiplier[Multipliers.x50] = 50;
    multiplier[Multipliers.x100] = 100;
    ///// Regular minting data /////
    regularMintingProbs = [440,790,940,990,1000];
    mintingPackToQuantity[MintingPacks.x1] = 1;
    mintingPackToQuantity[MintingPacks.x5] = 5;
    mintingPackToQuantity[MintingPacks.x10] = 10; 
    mintingPackToQuantity[MintingPacks.x20] = 20;
    // Recipes probability to BottomTipPower
    recipeAttribute[440] = 15;
    recipeAttribute[790] = 51;
    recipeAttribute[940] = 101;
    recipeAttribute[990] = 151;
    recipeAttribute[1000] = 201;
    // recipe TP range by bottom limit init
    recipeTPRange[15] = 36;
    recipeTPRange[51]= 50;
    recipeTPRange[101]= 50;
    recipeTPRange[151]= 50;
    recipeTPRange[201]= 50;
    recipeBaseURI = "receipts base URI";
    // Riders Attributes init
    probabilityToriderAttributes[440] = RiderAttributes(1,[1,3],[0,2],[0,2],[0,2],[0,2],[0,1]);
    probabilityToriderAttributes[790] = RiderAttributes(2,[1,2],[3,3],[0,3],[0,3],[0,3],[0,2]);
    probabilityToriderAttributes[940] = RiderAttributes(3,[1,3],[1,3],[5,3],[1,3],[1,3],[0,3]);
    probabilityToriderAttributes[990] = RiderAttributes(4,[1,5],[1,5],[2,4],[7,2],[1,5],[1,4]);
    probabilityToriderAttributes[1000] = RiderAttributes(5,[3,6],[3,6],[5,4],[3,6],[9,3],[2,5]);
    // riders Base URI probability by attribute init
    ridersBaseURIProbability[1] = [980,995,1000];
    ridersBaseURIProbability[2] = [955,985,1000];
    ridersBaseURIProbability[3] = [820,940,1000];
    ridersBaseURIProbability[4] = [490,840,1000];
    ridersBaseURIProbability[5] = [200,700,1000];
    motorBikes  = [bytes12(bytes("Chopper")),bytes12(bytes("Scooter")), bytes12(bytes("Sport")), bytes12(bytes("Supermotard"))]; 
    // motorbikes equivalents to ["0x43686f707065720000000000", 0x53636f6f7465720000000000, 0x53706f727400000000000000, 0x53757065726d6f7461726400]
    // Number of NFTs by rider folders init
    baseURILength["rider common"] = 1000;
    baseURILength["rider rare"] = 1000;
    baseURILength["rider very rare"] = 1000;
    // riders Base URIs init (0 = common, 1 = rare, 2 = very rare)
    ridersBaseURI[0] = "rider common";
    ridersBaseURI[1] = "rider rare";
    ridersBaseURI[2] = "rider very rare";
    // Pizzerias Data
		tipPowerURIRanges = [3000, 5000, 6000, 50000];
		rarenessToTokenURI[3000] = "Family Business"; // TODO ipfs
		rarenessToTokenURI[5000] = "Haute Cousine"; // TODO ipfs
		rarenessToTokenURI[6000] = "Franchise"; // TODO ipfs
		rarenessToTokenURI[50000] = "Multinational Chain"; // TODO ipfs  
    ///// Chainlink fee data /////
    // ChainLink fees in Matic to be charged when minting riders
    riderQuantityToChainLinkFee[1] = 72240400000000000;
    riderQuantityToChainLinkFee[5] = 129655000000000000;
    riderQuantityToChainLinkFee[10] = 215692400000000000;
    riderQuantityToChainLinkFee[20] = 381781600000000000;
    // ChainLink fees in Matic to be charged when minting recipe
    recipeQuantityToChainLinkFee[1] = 72935600000000000;
    recipeQuantityToChainLinkFee[5] = 88148000000000000;
    recipeQuantityToChainLinkFee[10] = 129662200000000000;
    recipeQuantityToChainLinkFee[20] = 215682200000000000;
    // ChainLink fees in Matic to be charged when playing PVE
    pveChainLinkFee = 50000000000000000;
    // ChainLink fees in Matic to be charged when playing PVE
    pvpChainLinkFee = 22666667000000000;
  }

  /********************************************************
   *                                                      *
   *                    VIEW FUNCTIONS                    *
   *                                                      *
   ********************************************************/
  
  ///// PVE view functions /////

  /// @dev The index of the tipPower limit for a pizzeria is related to the index of buyinToProbability. Check play function of RewardPool contract for better understanding.
  /// @return tipPowerArray get array with all tipPower top limits for pve
  function getTipPower() external view returns(uint16 [] memory) {
    return tipPower;
  }

  /// @dev used to buy Ingredient packs in pve
  /// @param _ingredientPack pack of ingredients to buy. 0: 7 days | 1: 15 days | 2: 30 days
  /// @return days days to add in pizzeria day Balance
  function getIngredientPackToDays(uint8 _ingredientPack) external view returns(uint16) {
    return ingredientPackToDays[IngredientPacks(_ingredientPack)];
  }

  /// @dev used to buy Ingredient packs in pve
  /// @param _ingredientPack pack of ingredients to buy. 0: 7 days | 1: 15 days | 2: 30 days
  /// @return price price of days in dollars. e.g. $1 -> 100. 0: 875 | 1: 1875 | 2: 3750
  function getIngredientPackToPrice(uint8 _ingredientPack) external view returns(uint) {
    return ingredientPackToPrice[IngredientPacks(_ingredientPack)];
  }

  /// @dev used to decide if user wins in RewardPool play function
  /// @param _buyin buyin in dollars. e.g: 5$ -> 500. If incorrect buyin is passed the user will have 0 probabilities to win
  /// @param _probIndex indexed of probability. This depends on the tip power of pizzeria
  /// @return _probablitiy probability to beat pve in a race. E.G 79% -> 7900   
  function getPveProbability(uint _buyin, uint _probIndex) external view returns(uint16) {
    return buyinToProbability[_buyin][_probIndex];
  }

  /// @dev used in RewardPool contract. 
  /// @param _buyin buyin in dollars with 2 decimals. e.g: 5$ -> 500. 
  /// @return _reward reward in dollars with 2 decimals
  function getBuyinReward(uint _buyin) external view returns(uint) {
    return buyinToReward[_buyin];
  }

  /// @dev used in RewardPool contract
  /// @param _multiplier enum value for multiplier. From 0 to 5. 
  /// @return multiplier  Actual multiplier value. 0: x2 | 1: x3 | 2: x5 | 3: x10 | 4: x50 | 5: x100. The higher it is the less chances. 
  function getMultiplier(uint8 _multiplier) external view returns(uint16) {
    return multiplier[Multipliers(_multiplier)];
  }

  /// @dev used in RewardPool contract
  /// @param _multiplier enum value for multiplier. From 0 to 5. 0: x2 | 1: x3 | 2: x5 | 3: x10 | 4: x50 | 5: x100. The higher it is the less chances. 
  /// @return _probability probablity to beat the multiplier game
  function getMultiplierToProbability(uint _multiplier) external view returns(uint16) {
    return multiplierToProbability[Multipliers(_multiplier)];
  }

  ///// Regular minting view functions /////

  /// @dev used in RidersFactory and RecipesFactory contracts
  /// @param mintingPack value for MintinPacks enum. 
  /// @return quantity quantity of nfts to mint. 0: 1 nft | 1: 5 nfts | 2: 10 nfts | 3: 20 nfts
  function getMintingPackToQuantity(uint8 mintingPack) external view returns(uint8) {
    return mintingPackToQuantity[MintingPacks(mintingPack)];
  }

  /// @dev used in RidersFactory and RecipesFactory contracts
  /// @return CummulativeRarenessProbability probability assigned to each nft rareness. e.g [440,790,940,990,1000] -> 44% chances to get a common rider. (790-440) -> 35% chances to get a rare rider..... 1% chances to get a mythic rider 
  function getRegularMintingProbs() external view returns(uint [] memory) {
    return regularMintingProbs;
  }

  /// @dev used in RecipesFactory contracts to define the final tipPower. Tip Power = Bottom Tip Power + (random number in range for that Bottom Tip Power)
  /// @param _prob cummulative probability chosen in RecipesFactory contract after using chainlink VRF
  /// @return bottomTipPower Returns the recipe bottom TipPower
  function getRecipeAttribute(uint _prob) external view returns(uint16) {
    return recipeAttribute[_prob];
  }
  
  /// @dev helps to set recipe Tip Power in PresaleRecipeFactory contract. Tip Power = Bottom Tip Power + (random number in range for that Bottom Tip Power)
  /// @param _bottomLimit tip power bottom limit
  /// @return tipPowerRange Tip Power Range per each Bottom Tip Power Range
  function getRecipeTPRange(uint _bottomLimit) external view returns (uint) {
    return recipeTPRange[_bottomLimit];
  }

  /// @dev used in PresaleRecipesFactory to point to the right IPFs folder
  /// @return recipeBase the Recipes Base URI  IPFs folder
  function getRecipesBaseURI() external view returns (string memory) {
    return recipeBaseURI;
  }

  /// @dev helps to set riders Attributes in RidersFactory contract
  /// @param _prob cummulative probability chosen in RidersFactory contract after using chainlink VRF
  /// @return attributes rider attributes per each rareness cummulative probability
  function getRiderAttributes(uint16 _prob) external view returns (RiderAttributes memory attributes) {
    return probabilityToriderAttributes[_prob];
  }

  /// @dev Used in PresaleFactoryRiders contract to set motorbike of a rider (nft)
  /// @return motorbikeList array with all motorbike types. Initially there is only 4
  function getMotorbikes() external view returns (bytes12 [] memory) {
    return motorBikes;
  }
  
  /// @dev used in RidersFactory to pick the baseURI (image rareness) depending on pizzaQuantity
  /// @param _attribute # of pizzas a rider can deliver in one go
  /// @return _baseURICummulativeProbs Riders Base URI cummulative probability per each pizzaQuantity attribute
  function getRidersBaseURIProbability(uint _attribute) external view returns (uint [] memory) {
    return ridersBaseURIProbability[_attribute];
  }

  /// @notice Returns the number of images available inside a IPFs folder
  /// @dev used in RidersFactory and RecipesFactory to pick a image inside the IPFs folder after using chainlink VRF
  /// @param _baseURI base URI of either riders or recipe IPFs folder
  function getBaseURILength(string memory _baseURI) external view returns (uint) {
    return baseURILength[_baseURI];
  }

  /// @dev used in PresaleRidersFactory to pick rareness of IMAGE after using chainlink VRF
  /// @param _baseURIIndex  0 = common | 1 = rare | 2 = rare
  /// @return riderBaseURI rider Base URI
  function getRidersBaseURI(uint _baseURIIndex) external view returns (string memory) {
    return ridersBaseURI[_baseURIIndex];
  }

  /// @dev helps to pick the token URI in the PizzeriaFactory contract
  /// @return tipPowerURIRanges list with the max tipPower for each tokenURI
  function getTipPowerURIRanges() external view returns(uint[] memory) {
    return tipPowerURIRanges;
  }

  /// @dev picks the token URI in the PizzeriaFactory contract, based on the range of tipPower the Pizzeria belongs to
  /// @return tokenURI tokenURI of pizzeria
  function getRarenessToTokenURI(uint _rarenessLimit) external view returns(string memory) {
    return rarenessToTokenURI[_rarenessLimit];
  }

  /// @dev used in RidersFactory to charge the user the cost Radikals subscription needs to pay for using Chainlink VRF
  /// @param _riderQuantity quantity of riders to be minted
  /// @return chainLinkfee Returns the chainlink fee by number of riders in wei
  function getRiderQuantityToChainLinkFee(uint _riderQuantity) external view returns (uint) {
    return riderQuantityToChainLinkFee[_riderQuantity];
  }

  /// @dev used in RecipesFactory to charge the user the cost Radikals subscription needs to pay for using Chainlink VRF
  /// @param _recipeQuantity quantity of recipe to be minted
  /// @return chainLinkfee Returns the chainlink fee by number of recipe in wei
  function getRecipeQuantityToChainLinkFee(uint _recipeQuantity) external view returns (uint) {
    return recipeQuantityToChainLinkFee[_recipeQuantity];
  }

  /// @dev used in RewardPool to charge the user the cost Radikals subscription needs to pay for using Chainlink VRF
  /// @return chainLinkfee Returns the chainlink fee to pay in wei
  function getPveChainLinkFee() external view returns(uint) {
    return pveChainLinkFee;
  }

  /// @dev used in PVP contract to charge the user the cost Radikals subscription needs to pay for using Chainlink VRF
  /// @return chainLinkfee Returns the chainlink fee to pay in wei
  function getPvpChainLinkFee() external view returns(uint) {
    return pvpChainLinkFee;
  }

  /********************************************************
   *                                                      *
   *               ADMIN-ONLY FUNCTIONS                   *
   *                                                      *
   ********************************************************/

  /// @notice update tip Power list PVE
  /// @dev originally there are 34 different values in the list
  /// @param _tipPower new tipPower list
  function setTipPower(uint16 [] memory _tipPower) external onlyOwner {
    tipPower = _tipPower;
  }

  /// @notice update days per ingredient pack
  /// @param _ingredientPack enum of pack days goes from 0 to 2
  /// @param _packDays days to be assigened to a pack
  function setIngredientPackToDays(uint8 _ingredientPack, uint16 _packDays) external onlyOwner {
    ingredientPackToDays[IngredientPacks(_ingredientPack)] = _packDays;
  }

  /// @notice update price per ingredient pack
  /// @param _ingredientPack enum of pack days goes from 0 to 2
  /// @param _packPrice price of a pack in dollars with 2 decimals. E.g: $37,5 -> 3750
  function setIngredientPackToPrice(uint8 _ingredientPack, uint _packPrice) external onlyOwner {
    ingredientPackToPrice[IngredientPacks(_ingredientPack)] = _packPrice;
  }

  /// @notice update the probabilities to beat the PVE per buyin
  /// @param _buyin quantity to pay to play pve in dollars with 2 decimals. E.g: $37,5 -> 3750
  /// @param _prob probabilities to beat the PVE. Initially there are 34 different probabilities
  function setPveProbability(uint _buyin, uint16[] memory _prob) external onlyOwner {
    buyinToProbability[_buyin] = _prob;
  }

  /// @notice update the reward to be obtained if PVE is beaten
  /// @param _buyin quantity to pay to play pve in dollars with 2 decimals. E.g: $37,5 -> 3750
  /// @param _reward reward in dollars with 2 decimals
  function setBuyinReward(uint _buyin, uint _reward) external onlyOwner {
    buyinToReward[_buyin] = _reward;
  }
  
  /// @notice update the probabilities to beat the PVE per buyin
  /// @param _multiplier quantity to pay to play pve in dollars with 2 decimals. E.g: $37,5 -> 3750
  /// @param _prob reward in dollars with 2 decimals
  function setMultiplierToProbability(uint _multiplier, uint16 _prob) external onlyOwner {
    multiplierToProbability[Multipliers(_multiplier)] = _prob;
  }

  /// @notice update the multiplier value for PVE
  /// @param _multiplier multiplier actual value for enum. Original values are: 0: x2 | 1: x3 | 2: x5 | 3: x10 | 4: x50 | 5: x100
  function setMultiplier(uint8 _multiplier) external onlyOwner {
    multiplier[Multipliers(_multiplier)] = _multiplier;
  }

  /// @notice Update quantity of nfts per each minting pack
  /// @param _mintingPack enum numeric value. Packs goes from 0 to 3. Original values are: 0: 1 nft | 1: 5 nfts | 2: 10 nfts | 3: 20 nfts
  /// @param _packQuantity new quantity of riders to be allocated in a pack
  function setMintingPackToQuantity(uint8 _mintingPack, uint8 _packQuantity) external onlyOwner {
    mintingPackToQuantity[MintingPacks(_mintingPack)] = _packQuantity;
  }

  /// @notice Update nft rareness probabilities for riders and recipe
  /// @param _prob  list of cummulative probabilitiews assigned to each nft rareness. Originally [440,790,940,990,1000] -> 44% chances to get a common rider. (790-440) -> 35% chances to get a rare rider..... 1% chances to get a mythic rider 
  function setRegularMintingProbs(uint[] memory _prob) external onlyOwner {
    regularMintingProbs = _prob;
  }

  // Returns the recipe bottom TipPower
  /// @notice Allows owner to set recipe Attribute (Tip Power)
  /// @param _prob cumulative probability for NFT rareness
  /// @param _tipPower Bottom Tip Power
  /// @custom:extra Tip Power = Bottom Tip Power + (random number in a range per each Bottom TP). Important not to overlap possible final Tip Power values for different NFT rareness
  function setRecipeAttribute(uint _prob, uint16 _tipPower) external onlyOwner {
    recipeAttribute[_prob] = _tipPower;
  } 
  
  /// @notice Allows owner to set the recipe Tip Power range per TP bottom limit
  /// @param _bottomLimit tip power bottom limit representing NFT rareness. The higher it is the more rare
  /// @param _tpRange range of tip power used to define Final Tip Power in recipe factories contracts
  /// @custom:extra Tip Power = Bottom Tip Power + (random number in a range per each Bottom TP). Important not to overlap possible final Tip Power values for different NFT rareness
  function setRecipeTPRange(uint _bottomLimit, uint _tpRange) external onlyOwner {
    recipeTPRange[_bottomLimit] = _tpRange;
  }

  /// @notice Allows owner to include a new IPFS Base URI for recipe
  /// @dev uses Ownable oppenzeppelin library
  /// @param _recipeBaseURI IPFs URI where recipe nfts are stored
  function setRecipesBaseURI(string memory _recipeBaseURI) external onlyOwner {
    recipeBaseURI = _recipeBaseURI;
  }

  /// @notice Update Rider Attributes 
  /// @dev udpate Rider attributes per each cummulative probability
  /// @param _prob cumulative probabilities for NFT rareness
  /// @param _pizzaQuantity new pizza quantity value
  /// @param _wheel [min wheel value, (max wheel value - min wheel value + 1)]
  /// @param _fairing [min fairing value, (max fairing value - min fairing value + 1)]
  /// @param _clutch [min clutch value, (max clutch value - min clutch value + 1)]
  /// @param _exhaustPipe [min exhaustPipe value, (max exhaustPipe value - min exhaustPipe value + 1)]
  /// @param _turbo [min turbo value, (max turbo value - min turbo value + 1)]
  /// @param _nitro [min nitro value, (max nitro value - min nitro value + 1)]
  function setRiderAttributes(
    uint16 _prob, 
    uint8 _pizzaQuantity,
    uint8[2] memory _wheel,
    uint8[2] memory _fairing,
    uint8[2] memory _clutch,
    uint8[2] memory _exhaustPipe,
    uint8[2] memory _turbo,
    uint8[2] memory _nitro
    ) external onlyOwner {
    probabilityToriderAttributes[_prob] = RiderAttributes(_pizzaQuantity, _wheel, _fairing, _clutch, _exhaustPipe, _turbo, _nitro);
  }

  /// @notice Set the Motorbikes of riders
  /// @param _motorbikes array of motorbikes. Value should be coverted to bytes12 before inputing. Length of array should always be 4
  function setMotorBikes(bytes12 [] memory _motorbikes) external onlyOwner {
    motorBikes = _motorbikes;
  }
  
  // Returns Riders Base URI probability by attribute
  /// @notice Set the Motorbikes of riders
  /// @param _pizzaQuantity pizzaQuantity which indirectly defines NFT rareness
  /// @param _prob list with cummulative probabilities to have the 3 different rider base URI (common, rare, very rare). Input should be [Cumm. prob common, Cumm. prob common + Cumm. prob rare, 1000] -> 1000 represents 100% 
  function setRidersBaseURIProbability(uint _pizzaQuantity, uint [] memory _prob) external onlyOwner {
    ridersBaseURIProbability[_pizzaQuantity] = _prob;
  }

  /// @notice Sets the # of NFTs available in IPFs folder
  /// @param _baseURI IPFs folder URI
  /// @param _URILenght # of NFTs available in IPFs folder
  function setBaseURILength(string memory _baseURI, uint _URILenght) external onlyOwner {
    baseURILength[_baseURI] = _URILenght;
  }

  /// @notice Allows owner to include a new IPFSs Base URI for riders
  /// @param _baseURIIndex 0 = common | 1 = rare | 2 = rare
  /// @param _baseURI IPFs URI where nfts are stored
  function setRidersBaseURI(uint _baseURIIndex, string memory _baseURI) external onlyOwner {
    ridersBaseURI[_baseURIIndex] = _baseURI;
  }

  /// @notice Sets the chainlink fee by # of riders to be minted. Fee is payed to Radikal address
  /// @param _riderQuantity # of riders to be minted in presaleRidersFactory contract
  /// @param _fee fee in native token weis 
  function setRiderQuantityToChainLinkFee(uint _riderQuantity, uint _fee) external onlyOwner {
    riderQuantityToChainLinkFee[_riderQuantity] = _fee;
  }

  /// @notice Sets the chainlink fee by # of recipe to be minted. Fee is payed to Radikal address
  /// @param _recipeQuantity # of recipe to be minted in presalerecipeFactory contract
  /// @param _fee fee in native token weis
  function setRecipeQuantityToChainLinkFee(uint _recipeQuantity, uint _fee) external onlyOwner {
    recipeQuantityToChainLinkFee[_recipeQuantity] = _fee;
  }

  /// @notice Sets the chainlink fee to pay for using Chainlink VRF in PVE (rewardPool)
  /// @param _pveChainLinkFee fee in native token 
  function setPveChainLinkFee(uint _pveChainLinkFee) external onlyOwner {
    pveChainLinkFee = _pveChainLinkFee;
  }

  /// @notice Sets the chainlink fee to pay for using Chainlink VRF in PVE
  /// @param _pvpChainLinkFee fee in native token 
  function setPvpChainLinkFee(uint _pvpChainLinkFee) external onlyOwner {
    pvpChainLinkFee = _pvpChainLinkFee;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
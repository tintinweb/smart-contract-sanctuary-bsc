// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/// @title A radikal presale store of mystery boxes and data storage for presale minting
/// @author Radikal Riders
/// @notice You can only use this contract to buy mystery boxes during presale period
/// @dev All function calls are currently implemented without side effects
contract Presale is Ownable, VRFConsumerBaseV2 {

  // ChainLink parameters for getting random number
  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;
  // RadikalRiders Chainlink subscription ID.
  uint64 s_subscriptionId;
  // Polygon Mainnet coordinator
  address vrfCoordinator;
  // Polygon Mainnet LINK token contract
  address link;
  // The gas lane to use, which specifies the maximum gas price to bump to
  bytes32 keyHash;
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas
  uint32 callbackGasLimit;
  // The default is 3, but you can set this higher.
  uint16 requestConfirmations;
  // Last Chainlink requestId generated for this contract
  uint256 public s_requestId;
  // LINK fee in Matic to be charged to user as result of using ChainLink
  uint chainlinkFeeMatic;
  // Total mystery box counter
  uint public mysteryBoxId;

  // NFT Type
  enum NftType { Rider, Recipe }

  /*** Mystery Box types ***/ //
  // LEG = Legendary | MYT = Mythic | SP = Special
  // It is the higher mystery box classification. 
  // NFT rareness probablities are at this level
  // Limit of mystery boxes to buy in presale is at this level
  enum MBoxTypeTop { LEG, MYT, SP } 
  // Middle level differentiates rider and recipe attributes based on the purchased mystery box
  enum MBoxTypeMid { RiderLEG, RiderMYT, RiderSP, RecipeLEG, RecipeMYT, RecipeSP } 
  // User buys mystery box at this level. The number at the end corresponds to the price in dollars
  // Price of mystery box is at this level
  // Number of nfts inside the mystery box (quantity) is at this level
  enum MBoxTypeBot { LEG30, LEG250, MYT60, MYT500, SP75, SP1000 }

  // Used in presaleCounter tracks the number of riders and recipe purchased and their midlevel
  struct TypeCounter {
    uint riderMidType;
    uint riderCounter;
    uint recipeMidType;
    uint recipeCounter;
  }

  // Rider attributes/skills
  struct RiderAttributes {
    uint8 pizzaQuantity;
    uint8[2] wheel;
    uint8[2] fairing;
    uint8[2] clutch;
    uint8[2] exhaustPipe;
    uint8[2] turbo;
    uint8[2] nitro;
  }
  // Rider and recipe attributes ranges by typeMid and NFT rareness probability
  mapping(MBoxTypeMid => mapping(uint16 => RiderAttributes)) private riderAttributes;
  mapping(MBoxTypeMid => mapping(uint => uint)) private recipeAttribute;
  // Relation between Top Types and Bot & Mid Types
  mapping(MBoxTypeBot => MBoxTypeTop) private typeBotToTop;
  mapping(NftType => mapping(MBoxTypeBot => MBoxTypeMid))private typeBotToMid;
  mapping(MBoxTypeMid => MBoxTypeTop) private typeMidToTop;
  // Price per each Mystery Box type
  mapping(MBoxTypeBot => uint) private typePrice;
  // Number of nfts per each Mystery Box type
  mapping(MBoxTypeBot => uint) private typeQuantity;
  // Probability range per each Mystery Box type
  mapping(MBoxTypeTop => uint[]) private typeProbability;
  // URI Probability range per each rider attribute value
  mapping(uint => uint[]) private ridersBaseURIProbability;
  // Number of NFTs/images available in IPFS folder (BaseURI)
  mapping(string => uint) private baseURILength;
  // Riders Base URI by attribute/skill
  mapping(uint => string) private ridersBaseURI;
  // Recipes base URI (ipfs folder)
  string private recipeBaseURI;
  // Tip Power Range (TPRange) by bottom Tip Power limit
  mapping(uint => uint) private recipeTPRange;
  // Number of mystery boxes bought per top level (LEG, MYT, SP)
  mapping(MBoxTypeTop => uint) private mysteryBoxTypeCounter;
  // Limit of mystery boxes that can be bought per top level
  mapping(MBoxTypeTop => uint) private mysteryBoxTypeLimit; 
  // Number of Mysteryboxes that are not opened by user
  mapping(address => mapping(MBoxTypeBot => uint)) private addressToClosedMysteryBox;
  // Tracks TypeCounter per mysteryboxId and user
  mapping(address => mapping(uint => TypeCounter)) private presaleCounter;
  // Mystery boxes bought by user
  mapping(address => uint[]) addressToMysteryBoxes;
  // Chainlink VRF
  mapping(uint => address) requestToSender;
  mapping(uint => uint) requestToType;
  mapping(uint => uint) requestToMysteryBoxId;
  // Fee to use Chainlink VRF in rider/recipe contracts per quantity of nfts to mint
  mapping(uint => uint) riderQuantityToChainLinkFee;
  mapping(uint => uint) recipeQuantityToChainLinkFee;
  // Motorbikes for Riders
  bytes12 [] private motorBikes;
  // Due date to purchase Mystery Boxes
  uint private presaleDate;
  // Addresses
  address payable externalFunds;
  address payable rewardPool;
  address payable chainLinkRDKFeeAddress;

  // Events
  event MysteryBoxBought(address indexed user, uint _mBoxType);

  constructor(
    uint _presaleDate, 
    address _externalFundsAddress, 
    address _rewardPoolAddress, 
    address _chainLinkRDKFeeAddress,
    uint64 subscriptionId, 
    address _vrfCoordinator, 
    address _link, 
    bytes32 _keyHash, 
    uint32 _callbackGasLimit, 
    uint16 _requestConfirmations
  )
    VRFConsumerBaseV2(_vrfCoordinator)
    Ownable()   
  {
    presaleDate = _presaleDate;
    externalFunds = payable(_externalFundsAddress);
    rewardPool = payable(_rewardPoolAddress);
    chainLinkRDKFeeAddress = payable(_chainLinkRDKFeeAddress);
    vrfCoordinator = _vrfCoordinator;
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    link = _link; 
    keyHash = _keyHash;
    callbackGasLimit = _callbackGasLimit;
    requestConfirmations = _requestConfirmations;
    LINKTOKEN = LinkTokenInterface(link);    
    s_subscriptionId = subscriptionId;
    // Fee to pay chainLink VRF usage in presale
    chainlinkFeeMatic = 60000000000000000;
    // Limit of mystery boxes to by per top type
    mysteryBoxTypeLimit[MBoxTypeTop.LEG] = 40000;
    mysteryBoxTypeLimit[MBoxTypeTop.MYT] = 20000;
    mysteryBoxTypeLimit[MBoxTypeTop.SP] = 10000;
    // typeMidToTop init
    typeMidToTop[MBoxTypeMid.RiderLEG] = MBoxTypeTop.LEG;
    typeMidToTop[MBoxTypeMid.RiderMYT] = MBoxTypeTop.MYT;
    typeMidToTop[MBoxTypeMid.RiderSP] = MBoxTypeTop.SP;
    typeMidToTop[MBoxTypeMid.RecipeLEG] = MBoxTypeTop.LEG;
    typeMidToTop[MBoxTypeMid.RecipeMYT] = MBoxTypeTop.MYT;
    typeMidToTop[MBoxTypeMid.RecipeSP] = MBoxTypeTop.SP;
    // typeBotToTop init
    typeBotToTop[MBoxTypeBot.LEG30] = MBoxTypeTop.LEG;
    typeBotToTop[MBoxTypeBot.LEG250] = MBoxTypeTop.LEG;
    typeBotToTop[MBoxTypeBot.MYT60] = MBoxTypeTop.MYT;
    typeBotToTop[MBoxTypeBot.MYT500] = MBoxTypeTop.MYT;
    typeBotToTop[MBoxTypeBot.SP75] = MBoxTypeTop.SP;
    typeBotToTop[MBoxTypeBot.SP1000] = MBoxTypeTop.SP;
    // typeBotToMid init 
    typeBotToMid[NftType.Rider][MBoxTypeBot.LEG30] = MBoxTypeMid.RiderLEG;
    typeBotToMid[NftType.Rider][MBoxTypeBot.LEG250] = MBoxTypeMid.RiderLEG;
    typeBotToMid[NftType.Rider][MBoxTypeBot.MYT60] = MBoxTypeMid.RiderMYT;
    typeBotToMid[NftType.Rider][MBoxTypeBot.MYT500] = MBoxTypeMid.RiderMYT;
    typeBotToMid[NftType.Rider][MBoxTypeBot.SP75] = MBoxTypeMid.RiderSP;
    typeBotToMid[NftType.Rider][MBoxTypeBot.SP1000] = MBoxTypeMid.RiderSP;
    typeBotToMid[NftType.Recipe][MBoxTypeBot.LEG30] = MBoxTypeMid.RecipeLEG;
    typeBotToMid[NftType.Recipe][MBoxTypeBot.LEG250] = MBoxTypeMid.RecipeLEG;
    typeBotToMid[NftType.Recipe][MBoxTypeBot.MYT60] = MBoxTypeMid.RecipeMYT;
    typeBotToMid[NftType.Recipe][MBoxTypeBot.MYT500] = MBoxTypeMid.RecipeMYT;
    typeBotToMid[NftType.Recipe][MBoxTypeBot.SP75] = MBoxTypeMid.RecipeSP;
    typeBotToMid[NftType.Recipe][MBoxTypeBot.SP1000] = MBoxTypeMid.RecipeSP;
    // Probability init
    typeProbability[MBoxTypeTop.LEG] = [760,920,980,995,1000];
    typeProbability[MBoxTypeTop.MYT] = [500,850,970,1000];
    typeProbability[MBoxTypeTop.SP] = [650,850,1000];
    // Price Riders init
    typePrice[MBoxTypeBot.LEG30] = 30;  // TODO update with real values
    typePrice[MBoxTypeBot.LEG250] = 250; // TODO update with real values
    typePrice[MBoxTypeBot.MYT60] = 60;  // TODO update with real values
    typePrice[MBoxTypeBot.MYT500] = 500; // TODO change back to 500 
    typePrice[MBoxTypeBot.SP75] = 75;   // TODO update with real values
    typePrice[MBoxTypeBot.SP1000] = 1000; // TODO CHANGE BACK TO 1000
    // Quantity Riders init
    typeQuantity[MBoxTypeBot.LEG30] = 1;
    typeQuantity[MBoxTypeBot.LEG250] = 10;
    typeQuantity[MBoxTypeBot.MYT60] = 1;
    typeQuantity[MBoxTypeBot.MYT500] = 10;
    typeQuantity[MBoxTypeBot.SP75] = 1;
    typeQuantity[MBoxTypeBot.SP1000] = 15;   
    // Attribute Riders init
    riderAttributes[MBoxTypeMid.RiderLEG][760] = RiderAttributes(2,[1,4],[6,5],[1,4],[0,5],[0,5],[0,3]);
    riderAttributes[MBoxTypeMid.RiderLEG][920] = RiderAttributes(3,[2,5],[2,5],[10,5],[2,5],[1,6],[1,4]);
    riderAttributes[MBoxTypeMid.RiderLEG][980] = RiderAttributes(4,[4,7],[4,7],[4,7],[14,3],[2,9],[2,7]);
    riderAttributes[MBoxTypeMid.RiderLEG][995] = RiderAttributes(5,[6,11],[6,11],[6,11],[6,11],[18,5],[5,8]);
    riderAttributes[MBoxTypeMid.RiderLEG][1000] = RiderAttributes(10,[9,12],[9,12],[10,11],[10,11],[10,11],[24,27]);
    riderAttributes[MBoxTypeMid.RiderMYT][500] = RiderAttributes(3,[2,5],[2,5],[10,5],[2,5],[1,6],[1,4]);
    riderAttributes[MBoxTypeMid.RiderMYT][850] = RiderAttributes(4,[4,7],[4,7],[4,7],[14,3],[2,9],[2,7]);
    riderAttributes[MBoxTypeMid.RiderMYT][970] = RiderAttributes(5,[6,11],[6,11],[6,11],[6,11],[18,5],[5,8]);
    riderAttributes[MBoxTypeMid.RiderMYT][1000] = RiderAttributes(10,[9,12],[9,12],[10,11],[10,11],[10,11],[24,27]);
    riderAttributes[MBoxTypeMid.RiderSP][650] = RiderAttributes(4,[4,7],[4,7],[4,7],[14,3],[2,9],[2,7]);
    riderAttributes[MBoxTypeMid.RiderSP][850] = RiderAttributes(5,[6,11],[6,11],[6,11],[6,11],[18,5],[5,8]);
    riderAttributes[MBoxTypeMid.RiderSP][1000] = RiderAttributes(10,[9,12],[9,12],[10,11],[10,11],[10,11],[24,27]);
    // Number of NFT images per image rareness
    baseURILength["rider common"] = 1000; // TODO: to be updated with real values
    baseURILength["rider rare"] = 1000; // TODO: to be updated with real values
    baseURILength["rider very rare"] = 1000; // TODO: to be updated with real values
    // Riders Base URI probability by attribute init
    ridersBaseURIProbability[2] = [980,995,1000]; // TODO: to be updated with real values
    ridersBaseURIProbability[3] = [955,985,1000]; // TODO: to be updated with real values
    ridersBaseURIProbability[4] = [820,940,1000]; // TODO: to be updated with real values
    ridersBaseURIProbability[5] = [490,840,1000]; // TODO: to be updated with real values
    ridersBaseURIProbability[10] = [200,700,1000]; // TODO: to be updated with real values
    // riders Base URIs init (0 = common, 1 = rare, 2 = very rare)
    ridersBaseURI[0] = "rider common";
    ridersBaseURI[1] = "rider rare";
    ridersBaseURI[2] = "rider very rare";
    // motorBikes init
    // motorbikes equivalents to ["0x43686f707065720000000000", 0x53636f6f7465720000000000, 0x53706f727400000000000000, 0x53757065726d6f7461726400]
    motorBikes  = [bytes12(bytes("Chopper")),bytes12(bytes("Scooter")), bytes12(bytes("Sport")), bytes12(bytes("Supermotard"))];
    // ChainLink fees in Matic to be charged when minting riders
    riderQuantityToChainLinkFee[1] = 72240400000000000; 
    riderQuantityToChainLinkFee[2] = 79845200000000000;
    riderQuantityToChainLinkFee[3] = 96452800000000000;
    riderQuantityToChainLinkFee[4] = 119051400000000000;
    riderQuantityToChainLinkFee[5] = 129655000000000000;
    riderQuantityToChainLinkFee[6] = 146257000000000000;
    riderQuantityToChainLinkFee[7] = 162867000000000000;
    riderQuantityToChainLinkFee[8] = 179472600000000000;
    riderQuantityToChainLinkFee[9] = 196075000000000000;
    riderQuantityToChainLinkFee[10] = 215692400000000000;
    riderQuantityToChainLinkFee[11] = 232296800000000000;
    riderQuantityToChainLinkFee[12] = 254902200000000000;
    riderQuantityToChainLinkFee[13] = 265509200000000000;
    riderQuantityToChainLinkFee[14] = 279112200000000000;
    riderQuantityToChainLinkFee[15] = 295724600000000000;

    
    // Bottom Tip Power of Recipe
    recipeAttribute[MBoxTypeMid.RecipeLEG][760] = 51;
    recipeAttribute[MBoxTypeMid.RecipeLEG][920] = 101;
    recipeAttribute[MBoxTypeMid.RecipeLEG][980] = 151;
    recipeAttribute[MBoxTypeMid.RecipeLEG][995] = 201;
    recipeAttribute[MBoxTypeMid.RecipeLEG][1000] = 251;
    recipeAttribute[MBoxTypeMid.RecipeMYT][500] = 101;
    recipeAttribute[MBoxTypeMid.RecipeMYT][850] = 151;
    recipeAttribute[MBoxTypeMid.RecipeMYT][970] = 201;
    recipeAttribute[MBoxTypeMid.RecipeMYT][1000] = 251;
    recipeAttribute[MBoxTypeMid.RecipeSP][650] = 151;
    recipeAttribute[MBoxTypeMid.RecipeSP][850] = 201;
    recipeAttribute[MBoxTypeMid.RecipeSP][1000] = 251;
    // recipe Base URIs init
    recipeBaseURI = "recipe base URI";
    // recipe Tip Power range by bottom limit init
    recipeTPRange[51]= 50;
    recipeTPRange[101]= 50;
    recipeTPRange[151]= 50;
    recipeTPRange[201]= 50;
    recipeTPRange[251]= 250;
    // ChainLink fees in Matic to be charged when minting recipe
    recipeQuantityToChainLinkFee[1] = 72935600000000000;
    recipeQuantityToChainLinkFee[2] = 63239600000000000;
    recipeQuantityToChainLinkFee[3] = 71541400000000000;
    recipeQuantityToChainLinkFee[4] = 88855600000000000;
    recipeQuantityToChainLinkFee[5] = 88148000000000000;
    recipeQuantityToChainLinkFee[6] = 99456200000000000;
    recipeQuantityToChainLinkFee[7] = 107753400000000000;
    recipeQuantityToChainLinkFee[8] = 128055600000000000;
    recipeQuantityToChainLinkFee[9] = 121354400000000000;
    recipeQuantityToChainLinkFee[10] = 129662200000000000;
    recipeQuantityToChainLinkFee[11] = 137961200000000000;
    recipeQuantityToChainLinkFee[12] = 146259400000000000;
    recipeQuantityToChainLinkFee[13] = 154566600000000000;
    recipeQuantityToChainLinkFee[14] = 162867000000000000;
    recipeQuantityToChainLinkFee[15] = 174167200000000000;
  }
  
  /********************************************************
   *                                                      *
   *                   MAIN FUNCTIONS                     *
   *                                                      *
   ********************************************************/

  /// @notice It is the Mystery box shop
  /// @dev Uses ChainLink Request and allocates how many riders and recipe there are in mystery box 
  /// @param _mBoxType The bottom type of mystery boxes. It represents the options a user have to purchase in the FE
  function buyMysteryBox (uint _mBoxType) external payable {
    // Checks Limit of bought mystery boxes (LEG, MYT, SP) is not exceeded
    require(mysteryBoxTypeCounter[typeBotToTop[MBoxTypeBot(_mBoxType)]] < mysteryBoxTypeLimit[typeBotToTop[MBoxTypeBot(_mBoxType)]], "Presale: sold out");
    // Presale time condition
    require(block.timestamp < presaleDate, "Presale: presale is over");
    uint mysteryBoxPriceMatic = typePrice[MBoxTypeBot(_mBoxType)];
    mysteryBoxId++;
    uint _mysteryBoxId = mysteryBoxId;
    // Checks that msg.value is the price of mystery box + fee for using chainlink
    require(msg.value == (mysteryBoxPriceMatic + chainlinkFeeMatic), "Presale: amount is too small");
    mysteryBoxTypeCounter[typeBotToTop[MBoxTypeBot(_mBoxType)]] ++;
    // TODO: Distribute funds to External Funds and Reward Pool this is not fully defined
    chainLinkRDKFeeAddress.transfer(chainlinkFeeMatic);
    externalFunds.transfer(mysteryBoxPriceMatic/2);
    rewardPool.transfer(mysteryBoxPriceMatic/2);
    // Request random numbers to define riders and recipe inside the mystery box
    uint32 numWords = uint32(getTypeQuantity(_mBoxType));
    _requestRandomWords(numWords,_mBoxType, _mysteryBoxId);
    // Updates user related mystery boxes information used in the Front End
    addressToClosedMysteryBox[msg.sender][MBoxTypeBot(_mBoxType)]++;
    addressToMysteryBoxes[msg.sender].push(_mysteryBoxId);
    // Event emitted
    emit MysteryBoxBought(msg.sender, _mBoxType);
  }

  /********************************************************
   *                                                      *
   *                  INTERNAL FUNCTIONS                  *
   *                                                      *
   ********************************************************/
  
  /// @dev Requests Random Generation
  /// @param _numWords number of random numbers to generate
  /// @param _mBoxType bottom mystery box type
  /// @param _mysteryBoxId mystery box Id created when executing buyMysteryBox function 
  function _requestRandomWords(uint32 _numWords, uint _mBoxType, uint _mysteryBoxId) internal {
    s_requestId  = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      _numWords
    );  
    requestToSender[s_requestId] = msg.sender;
    requestToType[s_requestId] = _mBoxType;
    requestToMysteryBoxId[s_requestId] = _mysteryBoxId;
  }

  /// @dev chainLink team runs this function when the randoms for the request are ready
  /// @param requestId chainLink request Id 
  /// @param randomWords array with random numbers needed
  function fulfillRandomWords(
    uint256 requestId,
    uint256[] memory randomWords
  ) 
    internal override 
  {
    uint _mBoxType = requestToType[requestId];
    address user = requestToSender[requestId];    
    uint _mysteryBoxId = requestToMysteryBoxId[requestId];
    uint riderCounter = 0;
    uint recipeCounter = 0;
    uint _quantity = getTypeQuantity(_mBoxType);
    // Sets how many riders and recipe there will be in the mystery box
    for(uint i = 0; i < _quantity; i++){
      if( (1 + (randomWords[i]% 999) ) < 501 ) {
        riderCounter++;
      } else {
        recipeCounter++;
      }
    }
    uint _riderNType = uint(typeBotToMid[NftType.Rider][MBoxTypeBot(_mBoxType)]);
    uint _recipeNType = uint(typeBotToMid[NftType.Recipe][MBoxTypeBot(_mBoxType)]);
    presaleCounter[user][_mysteryBoxId] = TypeCounter(_riderNType, riderCounter, _recipeNType, recipeCounter);
  }

  /********************************************************
   *                                                      *
   *               ADMIN-ONLY FUNCTIONS                   *
   *                                                      *
   ********************************************************/

  /// @notice Allows owner to set the price of each type of Mystery Box
  /// @dev uses Ownable oppenzeppelin library
  /// @param _mBoxType The bottom type of mystery boxes
  function setTypePrice(MBoxTypeBot _mBoxType, uint _price) external onlyOwner {
    typePrice[_mBoxType] = _price;
  }

  /// @notice Allows owner to set NFT rareness probabilities per each Mystery Box type 
  /// @dev uses Ownable oppenzeppelin library
  /// @param _mBoxType The bottom type of mystery boxes
  /// @param _prob cumulative probabilities for NFT rareness
  function setTypeProbability(MBoxTypeTop _mBoxType, uint[] calldata _prob) external onlyOwner {
    typeProbability[_mBoxType] = _prob;
  }

  // Allows owner to set the attribute (number of pizzas or TP) to each (Mystery Box type)/probability combination
  /// @notice Update Rider Attributes 
  /// @dev udpate Rider attributes per each mid mysteryBoxType and cummulative probability
  /// @param _mBoxType The mid type of mystery boxes
  /// @param _prob cumulative probabilities for NFT rareness
  /// @param _pizzaQuantity new pizza quantity value
  /// @param _wheel [min wheel value, (max wheel value - min wheel value + 1)]
  /// @param _fairing [min fairing value, (max fairing value - min fairing value + 1)]
  /// @param _clutch [min clutch value, (max clutch value - min clutch value + 1)]
  /// @param _exhaustPipe [min exhaustPipe value, (max exhaustPipe value - min exhaustPipe value + 1)]
  /// @param _turbo [min turbo value, (max turbo value - min turbo value + 1)]
  /// @param _nitro [min nitro value, (max nitro value - min nitro value + 1)]
  function setRiderAttributes(
    MBoxTypeMid _mBoxType, 
    uint16 _prob, 
    uint8 _pizzaQuantity,
    uint8[2] memory _wheel,
    uint8[2] memory _fairing,
    uint8[2] memory _clutch,
    uint8[2] memory _exhaustPipe,
    uint8[2] memory _turbo,
    uint8[2] memory _nitro
  ) 
    external onlyOwner 
  {
    riderAttributes[_mBoxType][_prob] = RiderAttributes(_pizzaQuantity, _wheel, _fairing, _clutch, _exhaustPipe, _turbo, _nitro);
  }

  /// @notice Allows owner to set recipe Attribute (Tip Power)
  /// @dev uses Ownable oppenzeppelin library
  /// @param _mBoxType The mid type of mystery boxes
  /// @param _prob cumulative probability for NFT rareness
  /// @param _value Bottom Tip Power
  /// @custom:extra Tip Power = Bottom Tip Power + (random number in a range per each Bottom TP). Important not to overlap possible final Tip Power values for different NFT rareness
  function setRecipeAttribute(uint _mBoxType, uint _prob, uint _value) external onlyOwner {
    recipeAttribute[MBoxTypeMid(_mBoxType)][_prob] = _value;
  }

  /// @notice Allows owner to set the recipe Tip Power range per TP bottom limit
  /// @dev uses Ownable oppenzeppelin library
  /// @param _bottomLimit tip power bottom limit representing NFT rareness. The higher it is the more rare
  /// @param _range range of tip power used to define Final Tip Power in recipe factories contracts
  /// @custom:extra Tip Power = Bottom Tip Power + (random number in a range per each Bottom TP). Important not to overlap possible final Tip Power values for different NFT rareness
  function setRecipeTPRange(uint _bottomLimit, uint _range) external onlyOwner {
    recipeTPRange[_bottomLimit] = _range;
  }

  /// @notice Allows owner to update the number of tokens bought by type
  /// @dev uses Ownable oppenzeppelin library
  /// @param _mBoxType The bottom type of mystery boxes
  /// @param _typeQuantity # of NFTs inside the mystery box
  function setTypeQuantity(MBoxTypeBot _mBoxType, uint _typeQuantity) external onlyOwner {
    typeQuantity[MBoxTypeBot(_mBoxType)] = _typeQuantity;
  }

  /// @notice Allows owner to include a new IPFSs Base URI for riders
  /// @dev uses Ownable oppenzeppelin library
  /// @param _index 0 = common | 1 = rare | 2 = rare
  /// @param _newBaseURI IPFs URI where nfts are stored
  function setRidersBaseURI(uint _index, string memory _newBaseURI) external onlyOwner {
    ridersBaseURI[_index] = _newBaseURI;
  }
  
  /// @notice Allows owner to include a new IPFS Base URI for recipe
  /// @dev uses Ownable oppenzeppelin library
  /// @param _newBaseURI IPFs URI where recipe nfts are stored
  function setRecipesBaseURI(string memory _newBaseURI) external onlyOwner {
    recipeBaseURI = _newBaseURI;
  }

  /// @notice Sets the # of NFTs available in IPFs folder
  /// @dev uses Ownable oppenzeppelin library
  /// @param _baseURI IPFs folder URI
  /// @param _length # of NFTs available in IPFs folder
  function setBaseURILength(string memory _baseURI, uint _length) external onlyOwner {
    baseURILength[_baseURI] = _length;
  }

  /// @notice Set the Motorbikes of riders
  /// @dev uses Ownable oppenzeppelin library
  /// @param _motorbikes array of motorbikes. Value should be coverted to bytes12 before inputing. Length of array should always be 4
  function setMotorbikes(bytes12[] memory  _motorbikes) external onlyOwner {
    motorBikes = _motorbikes;
  }

  /// @notice Sets ChainLink VRF parameters
  /// @dev uses Ownable oppenzeppelin library
  /// @param subscriptionId RadikalRiders Chainlink subscription ID.
  /// @param _vrfCoordinator Polygon Mainnet coordinator
  /// @param _link Polygon Mainnet LINK token contract
  /// @param _keyHash The gas lane to use, which specifies the maximum gas price to bump to
  /// @param _callbackGasLimit fulfillRandomWords() function gas limit. Current Maximum possible value is 2,000,000
  /// @param _requestConfirmations The default is 3, but you can set this higher incrementing security robustness
  function setVRFParameters(    
    uint64 subscriptionId, 
    address _vrfCoordinator, 
    address _link, 
    bytes32 _keyHash, 
    uint32 _callbackGasLimit, 
    uint16 _requestConfirmations
  ) 
    external onlyOwner
  {
    s_subscriptionId = subscriptionId;
    vrfCoordinator = _vrfCoordinator;
    link = _link;
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    keyHash = _keyHash;
    callbackGasLimit = _callbackGasLimit;
    requestConfirmations = _requestConfirmations;
    LINKTOKEN = LinkTokenInterface(link);    
    VRFConsumerBaseV2(_vrfCoordinator);
  }

  /// @notice Sets limit of mystery boxes to purchase by top type 
  /// @dev uses Ownable oppenzeppelin library
  /// @param _nftType 0 = Legendary | 1 = Mythic | 2 = Special
  /// @param _value limit of mystery boxes
  function setMysterBoxLimit(MBoxTypeTop _nftType, uint _value) external onlyOwner {
    mysteryBoxTypeLimit[_nftType] = _value; 
  }

  /// @notice Sets the chainlink fee by # of riders to be minted. Fee is payed to Radikal address
  /// @dev uses Ownable oppenzeppelin library
  /// @param _riderQuantity # of riders to be minted in presaleRidersFactory contract
  /// @param _fee fee in native token weis 
  function setRiderQuantityToChainLinkFee(uint _riderQuantity, uint _fee) external onlyOwner {
    riderQuantityToChainLinkFee[_riderQuantity] = _fee;
  }

  /// @notice Sets the chainlink fee by # of recipe to be minted. Fee is payed to Radikal address
  /// @dev uses Ownable oppenzeppelin library
  /// @param _recipeQuantity # of recipe to be minted in presalerecipeFactory contract
  /// @param _fee fee in native token weis 
  function setRecipeQuantityToChainLinkFee(uint _recipeQuantity, uint _fee) external onlyOwner {
    recipeQuantityToChainLinkFee[_recipeQuantity] = _fee;
  }

  /// @notice Sets the chainlink fee for using VRF in this contract
  /// @dev uses Ownable oppenzeppelin library
  /// @param _fee fee in native token weis 
  function setPresaleChainLinkFee(uint _fee) external  {
    chainlinkFeeMatic = _fee;
  } 

  /********************************************************
   *                                                      *
   *                   VIEW FUNCTIONS                     *
   *                                                      *
   ********************************************************/
  
  /// @notice Returns price of each type of Mystery Box
  /// @dev used in BuyMysteryBox function on this contract
  /// @param _mBoxType bottom mystery box type
  function getTypePrice(uint _mBoxType) external view returns (uint){
    return typePrice[MBoxTypeBot(_mBoxType)];
  }

  /// @notice Returns array of probability to each Mystery Box type 
  /// @dev used in PresaleRidersFactory and PresaleRecipesFactory to identify NFT rareness based on the top mystery box type
  /// @param _mBoxType Middle mystery box type
  function getTypeProbability(uint _mBoxType) external view returns (uint[] memory){
    uint[] memory _typeProbability = typeProbability[typeMidToTop[MBoxTypeMid(_mBoxType)]];
    return _typeProbability;
  }

  /// @notice Returns rider attributes per each Mid type and cummulative probability
  /// @dev helps to set riders Attributes in PresaleRidersFactory contract
  /// @param _mBoxType middle mystery box type
  /// @param _prob cummulative probability chosen in PresaleRidersFactory contract after using chainlink VRF
  function getRiderAttributes(uint _mBoxType, uint16 _prob) external view returns (RiderAttributes memory attributes){
    return riderAttributes[MBoxTypeMid(_mBoxType)][_prob];
  }

  /// @notice Returns recipe bottom Tip Power per each Mid type and cummulative probability
  /// @dev helps to set recipe Bottom Tip Power in PresaleRecipeFactory contract
  /// @param _mBoxType middle mystery box type
  /// @param _prob cummulative probability chosen in PresaleRecipesFactory contract after using chainlink VRF
  function getRecipeAttribute(uint _mBoxType, uint _prob) external view returns (uint) {
    return recipeAttribute[MBoxTypeMid(_mBoxType)][_prob];
  }

  /// @notice Returns Tip Power Range per each Bottom Tip Power Range
  /// @dev helps to set recipe Tip Power in PresaleRecipeFactory contract. Tip Power = Bottom Tip Power + (random number in range for that Bottom Tip Power)
  /// @param _bottomLimit tip power bottom limit
  function getRecipeTPRange(uint _bottomLimit) external view returns (uint) {
    return recipeTPRange[_bottomLimit];
  }

  /// @notice Returns # of riders and recipe inside a mysterybox
  /// @dev used in PresaleRidersFactory and PresaleRecipeFactory to mint needed # of riders and recipe inside a mystery box
  /// @param _userAddress user who bought the mystery box
  /// @param _mysteryBoxId Id of mystery box
  /// @return midTypes it also returns the midType of riders and recipe helping to define their specific attributes in PresaleRidersFactory and PresaleRecipeFactory
  function getPresaleCounter(address _userAddress, uint _mysteryBoxId) external view returns (uint,uint,uint,uint){
    return (
      presaleCounter[_userAddress][_mysteryBoxId].riderMidType,
      presaleCounter[_userAddress][_mysteryBoxId].riderCounter,
      presaleCounter[_userAddress][_mysteryBoxId].recipeMidType,
      presaleCounter[_userAddress][_mysteryBoxId].recipeCounter
    
    );
  }

  /// @notice Returns # of NFTs inside a mystery box 
  /// @dev used in PresaleRidersFactory and PresaleRecipeFactory to mint needed # of riders and recipe inside a mystery box
  /// @param _mBoxType bottom mystery box type. Users use this to buy a mystery box. 0 = LEG30 | 1 = LEG250 | 2 = MYT60 | 3 = MYT500 | 4 = SP75 | 5 = SP1000
  function getTypeQuantity(uint _mBoxType) public view returns (uint){
    return typeQuantity[MBoxTypeBot(_mBoxType)];
  }

  /// @notice Returns Riders Base URI cummulative probability per each pizzaQuantity attribute
  /// @dev used in PresaleRidersFactory to mint needed # of riders inside a mystery box
  /// @param _attribute # of pizzas a rider can deliver in one go
  function getRidersBaseURIProbability(uint _attribute) external view returns (uint [] memory) {
    return ridersBaseURIProbability[_attribute];
  }

  /// @notice Returns one rider Base URI
  /// @dev used in PresaleRidersFactory to pick rareness of IMAGE after using chainlink VRF
  /// @param _baseURIIndex  0 = common | 1 = rare | 2 = rare
  function getRidersBaseURI(uint _baseURIIndex) external view returns (string memory) {
    return ridersBaseURI[_baseURIIndex];
  }

  /// @notice Returns the Recipes Base URI 
  /// @dev used in PresaleRecipesFactory to point to the right IPFs folder
  function getRecipesBaseURI() external view returns (string memory) {
    return recipeBaseURI;
  }

  /// @notice Returns the number of images available inside a IPFs folder
  /// @dev used in PresaleRidersFactory and PresaleRecipesFactory to pick a image inside the IPFs folder after using chainlink VRF
  /// @param _baseURI base URI of either riders or recipe IPFs folder
  function getBaseURILength(string memory _baseURI) external view returns (uint) {
    return baseURILength[_baseURI];
  }

  /// @notice Returns the # of images available inside a IPFs folder
  /// @dev used in buyMysteryBox function of this contract to do not allow to buy more mysteryboxes if the limit's been reached
  /// @param _mBoxType 0 = Legendary | 1 = Mythic | 2 = Special
  function getMysterBoxLimit(uint _mBoxType) external view returns (uint) {
    return mysteryBoxTypeLimit[MBoxTypeTop(_mBoxType)];
  }

  /// @notice Returns how many boxes of each type have been sold
  /// @dev used in buyMysteryBox function of this contract to do not allow to buy more mysteryboxes if the limit's been reached
  /// @param _mBoxType 0 = Legendary | 1 = Mythic | 2 = Special
  function getMysterBoxTypeCounter(uint _mBoxType) external view returns (uint) {
    return mysteryBoxTypeCounter[MBoxTypeTop(_mBoxType)];
  }
  
  /// @notice Returns how many boxes of each type are bought and not opened by an user
  /// @dev used by front-end. Has no implication with contract logic
  /// @param _user address of user who bought the Mystery Box
  /// @param _mBoxType 0 = LEG30 | 1 = LEG250 | 2 = MYT60 | 3 = MYT500 | 4 = SP75 | 5 = SP1000
  function getAddressToClosedMysteryBox(address _user, uint _mBoxType) external view returns (uint) {
    return addressToClosedMysteryBox[_user][MBoxTypeBot(_mBoxType)];
  }

  /// @notice Returns the motorbike type
  /// @dev Used in PresaleFactoryRiders contract to set motorbike of a rider (nft)
  function getMotorbikes() external view returns (bytes12 [] memory) {
    bytes12 [] memory _motorBikes = motorBikes;
    return _motorBikes;
  }

  /// @notice Returns list of all mystery boxes bought by an user
  /// @dev used by front-end. Has no implication with contract logic
  /// @param _user address of user who bought the Mystery Box
  function getAddressToMysteryBoxes(address _user) external view returns (uint[] memory) {
    return addressToMysteryBoxes[_user];
  }

  /// @notice Returns the chainlink fee by number of riders
  /// @dev used in PresaleRidersFactory to charge the user the cost Radikals subscription needs to pay for using Chainlink VRF
  /// @param _riderQuantity quantity of riders to be minted
  function getRiderQuantityToChainLinkFee(uint _riderQuantity) external view returns (uint) {
    return riderQuantityToChainLinkFee[_riderQuantity];
  }
  
  /// @notice Returns the chainlink fee by number of recipe
  /// @dev used in PresalerecipeFactory to charge the user the cost Radikals subscription needs to pay for using Chainlink VRF
  /// @param _recipeQuantity quantity of recipe to be minted
  function getRecipeQuantityToChainLinkFee(uint _recipeQuantity) external view returns (uint) {
    return recipeQuantityToChainLinkFee[_recipeQuantity];
  }

  /// @notice Returns the chainlink fee for using VRF in this contract
  function getPresaleChainLinkFee() external view returns (uint) {
    return chainlinkFeeMatic;
  } 

  /// @notice gets ChainLink VRF parameters
  /// @dev uses Ownable oppenzeppelin library
  /// @return subscriptionId RadikalRiders Chainlink subscription ID.
  /// @return _vrfCoordinator Polygon Mainnet coordinator
  /// @return _link Polygon Mainnet LINK token contract
  /// @return _keyHash The gas lane to use, which specifies the maximum gas price to bump to
  /// @return _callbackGasLimit fulfillRandomWords() function gas limit. Current Maximum possible value is 2,000,000
  /// @return _requestConfirmations The default is 3, but you can set this higher incrementing security robustness
  function getVRFParameters(   
  ) 
    external view onlyOwner 
    returns (    
      uint64 subscriptionId, 
      address _vrfCoordinator, 
      address _link, 
      bytes32 _keyHash, 
      uint32 _callbackGasLimit, 
      uint16 _requestConfirmations
      )
  {
    subscriptionId = s_subscriptionId ;
    _vrfCoordinator = vrfCoordinator;
    _link = link;
    _vrfCoordinator = vrfCoordinator;
    _keyHash = keyHash;
    _callbackGasLimit = callbackGasLimit;
    _requestConfirmations = requestConfirmations;
    _link = link;
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
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../4. Interfaces/IRadikalStore.sol";
import "../4. Interfaces/ICollectionRiders.sol";
import "../4. Interfaces/IPriceOracle.sol";
import "../3. Token/ERC20RDK.sol";

/// @title The non-presale factory of riders
/// @author Radikal Riders
/// @notice This contract allows to buy packs of riders
/// @dev This contract channels all the functional/business rules needed to mint riders
contract RidersFactory is VRFConsumerBaseV2, Ownable  
{
  using Strings for uint;

  // Minting state
  enum MintingState { TO_OPEN, WAITING_RANDOM, TO_REVEAL, COMPLETED } 
  MintingState private mintingState;

  // Addresses receiving payaments from NFT purchase
  address payable public rewardPoolAddress;
  address payable public retirementPlanAddress;
  address payable public devTeamAddress;
  address payable public liquidityAddress;
  address payable public chainLinkRDKFeeAddress;

  // Address per chainlink request
  mapping(uint => address) public requestToSender;
  // Minting state per user
  mapping(address => MintingState) public userToMintingState;
  // ChainLink randoms requested by user
  mapping(address => uint256[]) public s_randomWords;

  // ChainLink parameters for getting random number
  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;

  // Your subscription ID.
  uint64 s_subscriptionId;
  // Polygon LINK token contract
  address link;
  // The gas lane to use, which specifies the maximum gas price to bump to
  bytes32 keyHash;
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas
  uint32 callbackGasLimit;
  // The default is 3, but you can set this higher.
  uint16 requestConfirmations;
  // Last Request done by this contract to ChainLink
  uint256 public s_requestId;

  // Contract instances
  ICollectionRiders ridersInstance;
  IRadikalStore radikalStoreInstance;
  IPriceOracle priceOracleInstance;
  ERC20RDK rdkToken;

  // Events
  event Purchased(address indexed user);
  event Minted(address indexed user);
  
  constructor(
    address _radikalStoreAddress,
    address _ridersAddress,
    address _rdkTokenAddress,
    address _chainLinkRDKFeeAddress,
    address _priceOracleAddress,
    uint64 subscriptionId, 
    address _vrfCoordinator,
    address _link, 
    bytes32 _keyHash, 
    uint32 _callbackGasLimit, 
    uint16 _requestConfirmations
  )
    VRFConsumerBaseV2(_vrfCoordinator)
  {    
    radikalStoreInstance = IRadikalStore(_radikalStoreAddress);
    ridersInstance = ICollectionRiders(_ridersAddress);
    rdkToken = ERC20RDK(_rdkTokenAddress);
    chainLinkRDKFeeAddress = payable(_chainLinkRDKFeeAddress);
    priceOracleInstance = IPriceOracle(_priceOracleAddress);
    COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    link = _link; 
    keyHash = _keyHash;
    callbackGasLimit = _callbackGasLimit;
    requestConfirmations = _requestConfirmations;
    LINKTOKEN = LinkTokenInterface(link);    
    s_subscriptionId = subscriptionId;
  }

  /********************************************************
   *                                                      *
   *                   REGULAR MINTING                    *
   *                                                      *
   ********************************************************/

  /// @notice Purchase a Mystery Box
  /// @dev Reads how many riders are inside the mystery box and proportionally request random numbers to ChainLink
  /// @param mintingPack Pack of nfts to mint. 0: 1 rider | 1: 5 riders | 2: 10 riders | 3: 20 riders
  function purchase(uint8 mintingPack) external payable {
    // pay 25 $ 
      // require 15 % in Matic
          // 10 % goes to development
          // 5 % to liquidity
      // require 85% in token
          // send 75% to reward Pool
          // send 10% to retirement plan
    require(userToMintingState[msg.sender] == MintingState.TO_OPEN || userToMintingState[msg.sender] == MintingState.COMPLETED, "Collection Riders: already opened");       
    uint8 tokenQuantity = radikalStoreInstance.getMintingPackToQuantity(mintingPack);
    uint tokenPart = uint(tokenQuantity) * priceOracleInstance.getUsdtToToken(2125); // 2125 is 85% of 25 dollars;
    uint maticPart = 375 * uint(tokenQuantity) * (10 ** 18) * (10 ** 6) / (uint(priceOracleInstance.getLatestPrice())); // 375 is 15% of 25 dollars;
    // Fee to maintain Radikal subscription in chainlink paying to generate random numbers
    uint chainlinkFeeMatic = radikalStoreInstance.getRiderQuantityToChainLinkFee(tokenQuantity);
    require(msg.value >= (maticPart + chainlinkFeeMatic), "Collection Riders: Matic insufficient funds");
    devTeamAddress.transfer(maticPart * 10 / 15);
    liquidityAddress.transfer(maticPart - (maticPart * 10 / 15));
    chainLinkRDKFeeAddress.transfer(chainlinkFeeMatic);
    payable(msg.sender).transfer(msg.value - ((maticPart * 10 / 15) + (maticPart - (maticPart * 10 / 15)) + chainlinkFeeMatic));
    rdkToken.transferFrom(msg.sender, rewardPoolAddress, tokenPart * 75 / 85);
    rdkToken.transferFrom(msg.sender, retirementPlanAddress, tokenPart - (tokenPart * 75 / 85));
    _requestRandomWords(tokenQuantity * 4);
  }

  /// @dev Requests Random Generation
  /// @param _numWords number of random numbers to generate
  function _requestRandomWords(uint32 _numWords) internal {
    // Will revert if subscription is not set and funded.
    s_requestId  = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      _numWords
    );
    requestToSender[s_requestId] = msg.sender;
    userToMintingState[msg.sender] = MintingState.WAITING_RANDOM;  
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
    address user = requestToSender[requestId];
    s_randomWords[user] = randomWords;
    userToMintingState[user] = MintingState.TO_REVEAL;
    emit Purchased(user);
  }

  /// @notice Mints a pack of riders
  /// @dev Applies business rules to set Rider Attributes and their token URI and delegate minting to CollectionRiders
  function mint() external {
    require(userToMintingState[msg.sender] == MintingState.TO_REVEAL, "Collection Riders: there are no NFT to reveal yet");
    uint[] memory _randomWords = s_randomWords[msg.sender];
    // first random --> Number of Pizzas = NFT rareness
    // second random --> Image Rareness -> Base URI from IPFS 
    // third random --> Image Id and Motorbike
    // fourth random --> PVP Attributes  
    uint _randomWordsLength = _randomWords.length;
    for(uint i = 0; i < _randomWordsLength; i += 4) {
      // Range of probability for the first random number
      uint16 rangeResult = uint16(_getProbabilityRange(uint16((_randomWords[i] % 1000) + 1), radikalStoreInstance.getRegularMintingProbs()));
      // Get PVP Rider Attributes array with bottom skill value and range of skill
      IRadikalStore.RiderAttributes memory attributes = radikalStoreInstance.getRiderAttributes(rangeResult);
      // Get the IPFs folder for the NFT being minted using the second random
      string memory currentBaseURI = radikalStoreInstance.getRidersBaseURI(_getTokenBaseURIIndex( (_randomWords[i + 1] % 1000) + 1 , radikalStoreInstance.getRidersBaseURIProbability(attributes.pizzaQuantity)));
      // Gets the final IPFs URI of the image and the motorbike of the rider using the third random
      (string memory _tokenURI, bytes12 motorBike) = _getTokenURIandBike(
        radikalStoreInstance.getMotorbikes(),
        currentBaseURI, 
        radikalStoreInstance.getBaseURILength(currentBaseURI),
        _randomWords[i + 2]
      );
      _mint(msg.sender, (_randomWords[i + 3]), motorBike, _tokenURI, attributes);      
    }
    emit Minted(msg.sender);
    // updates the minting state of the user so that he/she can buy more packs
    userToMintingState[msg.sender] = MintingState.COMPLETED;
  }

  // PROMOTIONAL MINT 
  /// @notice Mint promotional riders
  /// @dev version of mint function, but with pseudorandom values. To be used only by Radical Riders team for promotional purposes
  /// @param _mintQuantity quantity of riders to mint
  function promotionalMint(uint _mintQuantity) external onlyOwner {
    for(uint i = 0; i < _mintQuantity; i++) {
      uint16 rangeResult = uint16(_getProbabilityRange(uint16((uint(keccak256(abi.encodePacked(i,block.timestamp, 'First Random'))) % 1000) + 1), radikalStoreInstance.getRegularMintingProbs()));
    IRadikalStore.RiderAttributes memory attributes  = radikalStoreInstance.getRiderAttributes(rangeResult);
    // Get the IPFs folder for the NFT being minted using the second random
    string memory currentBaseURI = radikalStoreInstance.getRidersBaseURI(_getTokenBaseURIIndex( (uint(keccak256(abi.encodePacked(i,block.timestamp, 'Second Random'))) % 1000) + 1 , radikalStoreInstance.getRidersBaseURIProbability(attributes.pizzaQuantity)));
    // Gets the final IPFs URI of the image and the motorbike of the rider using the third random
    (string memory _tokenURI, bytes12 _motorBike) = _getTokenURIandBike(
        radikalStoreInstance.getMotorbikes(),
        currentBaseURI, 
        radikalStoreInstance.getBaseURILength(currentBaseURI),
        uint(keccak256(abi.encodePacked(i,block.timestamp, 'Third Random')))
      );
    ICollectionRiders.RidersAttributes memory riderAttributes = ICollectionRiders.RidersAttributes(
      attributes.pizzaQuantity,
      attributes.wheel[0] + uint8(uint(keccak256(abi.encodePacked(i,block.timestamp, 'Wheel'))) % attributes.wheel[1]),
      attributes.fairing[0] + uint8(uint(keccak256(abi.encodePacked(i,block.timestamp, 'Fairing'))) % attributes.fairing[1]),
      attributes.clutch[0] + uint8(uint(keccak256(abi.encodePacked(i,block.timestamp, 'Clutch'))) % attributes.clutch[1]),
      attributes.exhaustPipe[0] + uint8(uint(keccak256(abi.encodePacked(i,block.timestamp, 'Exhaust Pipe'))) % attributes.exhaustPipe[1]),
      attributes.turbo[0] + uint8(uint(keccak256(abi.encodePacked(i,block.timestamp, 'Turbo'))) % attributes.turbo[1]),
      attributes.nitro[0] + uint8(uint(keccak256(abi.encodePacked(i,block.timestamp, 'Nitro'))) % attributes.nitro[1]),
      _motorBike,
      false,
      true, 
      false
    );
    // Information is ready and sent to mint the NFT in the CollectionRiders contract
    ridersInstance.mint(msg.sender, _tokenURI, riderAttributes); 
    }
    
  }

  /********************************************************
   *                                                      *
   *                  INTERNAL FUNCTIONS                  *
   *                                                      *
   ********************************************************/
  
  /// @dev Picks the cumulative probability range where the random number falls 
  /// @param _randomNumber first random from chainLink 
  /// @param _riderTypeProbability array with cummulative probabilities for a specific mysteryBox type. E.g for Legendary mystery box: [760,920,980,995,1000] -> [76% prob for a rare rider, 16% prob for a epic rider, 6% prob for a Legendary rider, 1.5% prob for Mythical rider, 0.5% prob for Special rider]
  function _getProbabilityRange(uint _randomNumber, uint[] memory _riderTypeProbability) internal pure returns (uint rangeResult){
    for(uint i= 0; i < _riderTypeProbability.length; i++){
      if(_randomNumber <= _riderTypeProbability[i]){
        rangeResult = _riderTypeProbability[i];
        break;
      }
    }
    return rangeResult;
  }

  /// @dev Returns a TOKEN URI for the token being minted
  /// @param _motorBikes array of the 4 motorbikes available for riders (Chopper, Scooter, Sport, Supermotard)
  /// @param _currentBaseURI ipfs folder URI previosly picked
  /// @param _tokenURILength # of images inside the URI folder / _currentBaseURI
  /// @param _randNumber3 third random from chainlink
  function _getTokenURIandBike(bytes12[] memory _motorBikes, string memory _currentBaseURI,uint _tokenURILength,  uint _randNumber3)
    internal
    pure
    returns (string memory, bytes12)
  {
    // randURINumber is the specific image to pick in the IPFs folder 
    uint randURINumber = _randNumber3 % _tokenURILength;
    string memory randURIString = randURINumber.toString();
    uint motorBikesLength = _motorBikes.length;
    bytes12 motorBike;
    // Every IPFs has a # of images which is multiple of 4
    // Each quarter of this images corresponds to a specific motorbike type
    // E.G there are 12 images -> images 1,2,3 have Chopper motorbike | images 4,5,6 have Scooter motorbike | images 7,8,9 have Sport motorbike | images 10,11,12 have Supermotard motorbike
    // In the loop below we identify in which quarter falls the selected image (randoURINumber) and then assign a motorbike for the rider to be minted
    for(uint i = 1; i <= motorBikesLength; i++){
      if(randURINumber < _tokenURILength * i / ( motorBikesLength)){
        motorBike = _motorBikes[i - 1];
        break;
      }
    }
    // concatenates currentBaseURI and number and the json with token off-chain metadata. E.G: https://gateway.pinata.cloud/ipfs/QmawCN8E4FSBKVarZVxg8TpDvUhzbtzWgAYcTnUHhK75Tv/riders/rare/5.json
    return (
        bytes(_currentBaseURI).length > 0
          ? string(abi.encodePacked(_currentBaseURI, "/", randURIString, ".json"))
          : "",
        motorBike
    );
  } 

  /// @dev Picks the index of image rareness -> 0: common | 1: rare | 2: very rare
  /// @param _randomNumber2 second random from chainlink
  /// @param _baseURIProbability array with image rareness cummulative probabilities. E.G [490,840,1000] -> 49% prob to have a common image | 35% prob to have rare image | 16% prob to have a very rare image
  function _getTokenBaseURIIndex(uint _randomNumber2, uint[] memory _baseURIProbability) internal pure returns (uint value){
    for(uint i= 0; i < _baseURIProbability.length; i++){
      if(_randomNumber2 <= _baseURIProbability[i]){
        value = i;
        break;
      }
    }
    return value;
  }

  /// @dev Picks the index of image rareness -> 0: common | 1: rare | 2: very rare
  /// @param user owner of NFT to be minted
  /// @param _randonNumber3 third random from ChainLink
  /// @param _motorBike motorbike of NFT to be minted
  /// @param _tokenURI final URI of NFT to be minted
  /// @param attributes pizzaQuantity and information to pick the other skills/attributes
  function _mint(address user, uint _randonNumber3, bytes12 _motorBike, string memory _tokenURI, IRadikalStore.RiderAttributes memory attributes) internal {
    // Setting the last attribute values of NFT to mint. PizzaQuantity is already precalculated
    // other skills follow this calculation: bottom Skill value + random inside the range of Skill value
    // E.G wheel can have a value from 9 to 20 --> wheel = 9 + (random from 0 to 11)
    ICollectionRiders.RidersAttributes memory riderAttributes = ICollectionRiders.RidersAttributes(
      attributes.pizzaQuantity,
      attributes.wheel[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber3, 'Wheel'))) % attributes.wheel[1]),
      attributes.fairing[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber3, 'Fairing'))) % attributes.fairing[1]),
      attributes.clutch[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber3, 'Clutch'))) % attributes.clutch[1]),
      attributes.exhaustPipe[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber3, 'Exhaust Pipe'))) % attributes.exhaustPipe[1]),
      attributes.turbo[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber3, 'Turbo'))) % attributes.turbo[1]),
      attributes.nitro[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber3, 'Nitro'))) % attributes.nitro[1]),
      _motorBike,
      false,
      false,
      false
    );
    // Information is ready and sent to mint the NFT in the CollectionRiders contract
    ridersInstance.mint(user, _tokenURI, riderAttributes); 
  }

  /********************************************************
   *                                                      *
   *                    ADMIN FUNCTIONS                   *
   *                                                      *
   ********************************************************/

  /// @notice state of minting process per mysteryBox
  /// @dev can only be set by owner of contract. It's set here because stack too deep when trying to initialize these in the constructor
  /// @param _devTeamAddress development team address receiving part of purchase payments
  /// @param _liquidityAddress liquidity pool address receiving part of purchase payments
  /// @param _rewardPoolAddress Reward Pool address receiving part of purchase payments
  /// @param _retirementPlanAddress retirement plan address receiving part of purchase payments
  function setAddressesToPay(address payable _devTeamAddress, address payable _liquidityAddress, address payable _rewardPoolAddress, address payable _retirementPlanAddress) external onlyOwner{
    devTeamAddress = _devTeamAddress;
    liquidityAddress = _liquidityAddress;
    rewardPoolAddress = _rewardPoolAddress;
    retirementPlanAddress = _retirementPlanAddress;
  }

  /********************************************************
   *                                                      *
   *                    VIEW FUNCTIONS                    *
   *                                                      *
   ********************************************************/

  /// @notice state of minting process per mysteryBox
  /// @dev consumed by front-end team
  /// @param _user user to check
  function getMintingState(address _user) external view returns(uint) {
    return uint(userToMintingState[_user]);
  }
  
  // TODO: DELETE before going prod. Helpful for testing
  function getRandoms(uint mod) external view returns (uint256[] memory) {
    if(mod == 0) {
      return s_randomWords[msg.sender];
    } else {      
      uint[] memory arr = new uint[](s_randomWords[msg.sender].length);
      for(uint i = 0; i < s_randomWords[msg.sender].length; i++) {
        arr[i] = (s_randomWords[msg.sender][i] % mod);
      }
      return arr;
    }
  }

    // TODO: DELETE before going prod. Helpful for testing
  function getRandomsSkills(
    address _user,
    uint[2] memory _wheel,
    uint[2] memory _fairing,
    uint[2] memory _clutch,
    uint[2] memory _exhaustPipe,
    uint[2] memory _turbo,
    uint[2] memory _nitro
    ) external view returns (uint256[] memory) {

      uint[] memory arr = new uint[](6 *  s_randomWords[_user].length / 4 );
      for(uint i = 0; i < s_randomWords[_user].length; i += 4) {
        arr[i * 6/4 ] = _wheel[0] + (uint(keccak256(abi.encodePacked(s_randomWords[_user][i + 3], 'Wheel'))) % _wheel[1]);
        arr[i * 6/4 + 1] = _fairing[0] + uint(keccak256(abi.encodePacked(s_randomWords[_user][i + 3], 'Fairing'))) % _fairing[1];
        arr[i * 6/4 + 2] =  _clutch[0] + uint(keccak256(abi.encodePacked(s_randomWords[_user][i + 3], 'Clutch'))) % _clutch[1];
        arr[i * 6/4 + 3] = _exhaustPipe[0] + uint(keccak256(abi.encodePacked(s_randomWords[_user][i + 3], 'Exhaust Pipe'))) % _exhaustPipe[1];
        arr[i * 6/4 + 4] = _turbo[0] + uint(keccak256(abi.encodePacked(s_randomWords[_user][i + 3], 'Turbo'))) % _turbo[1];
        arr[i * 6/4 + 5] = _nitro[0] + uint(keccak256(abi.encodePacked(s_randomWords[_user][i + 3], 'Nitro'))) % _nitro[1];
      }
      return arr;
  }

  receive() external payable {

  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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

interface IRadikalStore {

	struct RiderAttributes {
    uint8 pizzaQuantity;
    uint8[2] wheel;
    uint8[2] fairing;
    uint8[2] clutch;
    uint8[2] exhaustPipe;
    uint8[2] turbo;
    uint8[2] nitro;
  }

	// PVE/rewardPool
	function getTipPower() external view returns(uint16 [] memory);
	function getIngredientPackToDays(uint8 _ingredientPack) external view returns(uint16);
	function getIngredientPackToPrice(uint8 _ingredientPack) external view returns(uint);
	function getPveProbability(uint _buyin, uint _probIndex) external view returns(uint16);
	function getBuyinReward(uint _buyin) external view returns(uint);
	function getMultiplierToProbability(uint _multiplier) external view returns(uint16);
	function getMultiplier(uint8 _multiplier) external view returns(uint16);
	function getPveChainLinkFee() external view returns(uint);
	function getPvpChainLinkFee() external view returns(uint);
	
	// Minting
	function getMintingPackToQuantity(uint8 mintingPack) external view returns(uint8);
	function getRecipeAttribute(uint _prob) external view returns(uint16);
	function getRegularMintingProbs() external view returns(uint [] memory);
	function getRecipeTPRange(uint _bottomLimit) external view returns (uint);
	function getRecipesBaseURI() external view returns (string memory);
	function getRiderAttributes(uint16 _prob) external view returns (RiderAttributes memory attributes);
	function getMotorbikes() external view returns (bytes12 [] memory);
	function getRidersBaseURIProbability(uint _attribute) external view returns (uint [] memory);
	function getBaseURILength(string memory _baseURI) external view returns (uint);
	function getRidersBaseURI(uint _baseURIIndex) external view returns (string memory);
	function getRiderQuantityToChainLinkFee(uint _riderQuantity) external view returns (uint);
	function getRecipeQuantityToChainLinkFee(uint _recipeQuantity) external view returns (uint);

	// Pizzerias
	function getTipPowerURIRanges() external view returns(uint[] memory);
	function getRarenessToTokenURI(uint _rarenessLimit) external view returns(string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollectionRiders {
	struct RidersAttributes {
    uint8 pizzaQuantity;
    uint8 wheel;
    uint8 fairing;
    uint8 clutch;
    uint8 exhaustPipe;
    uint8 turbo;
    uint8 nitro;
    bytes12 motorBike;
    bool inPizzeria;
    bool isPromotional;
    bool isFusioned;
	}

	function setInPizzeria(uint[] calldata riders) external;
	function getInPizzeria(uint _tokenId) external view returns(bool);
	function getPizzaQuantity(uint _tokenId) external view returns(uint8);
	function isOwner(uint _tokenId, address _user) external view returns(bool);
  function getMotorbike(uint _tokenId) external view returns(bytes12);
  function getAttributes(uint[] memory riders) external view returns(RidersAttributes[] memory attributes);
  function mint(address user, string memory _tokenURI, RidersAttributes memory attributes) external;
  function getRiderList(address _user) external view returns(uint[] memory);
  function getTokenURI(uint _tokenId) external view returns (string memory);
  function burn(uint _tokenId) external;
  function getIsPromotional(uint _tokenId) external view returns(bool);
  function getIsFusioned(uint _tokenId) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceOracle {
  function getTokenToUsdt(uint tokenQuantity) external view returns(uint exchange);
  function getUsdtToToken(uint usdtQuantity) external view returns(uint exchange);
  function getLatestPrice() external view returns (int);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Radikal Riders Token
/// @author Radikal Riders
/// @notice This is the utility ERC20 token of Radikal Riders
/// @dev Follows ERC20 standard with specific modifications 
contract ERC20RDK is ERC20, Ownable  {
    address[] radikalContracts;
    mapping(address=>uint) private _balancesTransferable;    
    
    constructor(
        address payable _tokenDistributorAddress
    ) 
        ERC20("Radikal", "RDK") { // TODO: Set final name / symbol
        address[] memory distributor = new address[](1);
        distributor[0] = _tokenDistributorAddress;
        addContracts(distributor);
        _mint(_tokenDistributorAddress, 5000000 * (10 ** 18));
    }

    // /********************************************************
    //  *                                                      *
    //  *                    MAIN FUNCTIONS                    *
    //  *                                                      *
    //  ********************************************************/
    
    /// @notice Tokens can only be transferred if they were utilized first
    /// @dev This function is executed before every token transfer
    /// @param from address from who the token is intended to be transferred
	/// @param to address to who the token is intended to be transferred
    /// @param amount amount of Tokens to be transferred
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        address[] memory _radikalContracts = radikalContracts;
        bool userToUser = true;
        for(uint i = 0; i < _radikalContracts.length; i++) {
           if(from == _radikalContracts[i] || to == _radikalContracts[i]) {
               userToUser = false;
           }
        }
        if(userToUser == true) {
            require(_balancesTransferable[from] >= amount, "ERC20: transfer amount exceeds transferable balance");
        }
    }

    /// @notice Update token transferable balances once tokens are transferred
    /// @dev This function is executed after every token transfer
    /// @param from address from who the token was transferred
	/// @param to address to who the token was transferred
    /// @param amount amount of Tokens transferred
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        address[] memory _radikalContracts = radikalContracts;
        bool fromContract = false;
        bool toContract = false;
        for(uint i = 0; i < _radikalContracts.length; i++) {
           if(from == _radikalContracts[i]) {
               fromContract = true;
           } else if(to == _radikalContracts[i]) {
               toContract = true;
           }
        }
        if(fromContract == false && toContract == false) {
            _balancesTransferable[from] -= amount;
        } else if(fromContract == true && toContract == false) {
            _balancesTransferable[to] += amount;
        } else if(fromContract == false && toContract == true) {
            uint balance = balanceOf(from);
            if(balance < _balancesTransferable[from]) {
                _balancesTransferable[from] = balance;
            }
        }
    }

    /********************************************************
     *                                                      *
     *                    ADMIN FUNCTIONS                   *
     *                                                      *
     ********************************************************/
    
    // Admin can add contracts to the list of Radikal contracts
    /// @notice Tokens sent to the listed contracts will be considered transferrable
    /// @dev Admin can add contracts to the list of Radikal contracts
    /// @param newContracts Address of the contract added to the whitelist
    function addContracts(address[] memory newContracts) public onlyOwner {
        for(uint i = 0; i < newContracts.length; i++) {
            radikalContracts.push(newContracts[i]);
        }
        
    }

    /********************************************************
     *                                                      *
     *                    VIEW FUNCTIONS                    *
     *                                                      *
     ********************************************************/

    /// @notice Check balance of transferrable tokens (utilized first through one of the whitelisted contracts)
    /// @param account Address of the account to be evaluated
     function balanceTransferableOf(address account) public view returns (uint256) {
        return _balancesTransferable[account];
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
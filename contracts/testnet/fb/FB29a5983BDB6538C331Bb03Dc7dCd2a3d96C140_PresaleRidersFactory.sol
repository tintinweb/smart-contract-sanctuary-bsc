// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../4. Interfaces/IPresale.sol";
import "../4. Interfaces/ICollectionRiders.sol";

/// @title The presale factory of riders
/// @author Radikal Riders
/// @notice This contract can only be used to open mystery boxes which are sold only during presale period
/// @dev This contract channels all the functional/business rules needed to mint riders
contract PresaleRidersFactory is VRFConsumerBaseV2, Ownable  
{
  using Strings for uint;

  // Minting state
  enum MintingState { TO_OPEN, WAITING_RANDOM, TO_REVEAL, COMPLETED } 

  // Address of Presale contract of Radikals
  address public presaleAddress;
  // Radikal address so that users reimburse radikals chainlink usage costs
  address payable public chainLinkRDKFeeAddress;
  // MysteryBoxId per chainLink request Id
  mapping(uint => uint) public requestToMysteryBox;
  // User address per chainLink request Id
  mapping(uint => address) requestToUser;
  // MintingState per mystery box Id
  mapping(uint => MintingState) mysteryBoxToMintingState;
  // Chainlink randoms requested per mystery box Id
  mapping(uint => uint256[]) private s_randomWords;

  // ChainLink parameters for getting random number
  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;

  // Your subscription ID.
  uint64 s_subscriptionId;
  // Polygon coordinator
  address vrfCoordinator;
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
  IPresale presaleInstance;
  ICollectionRiders ridersInstance;

  // Events
  event MysteryBoxOpened(uint indexed mysteryBoxId, address indexed user);
  event NftRevealed(uint indexed mysteryBoxId, address indexed user);
  
  constructor(
    address _presaleAddress,
    address _ridersAddress,
    address _chainLinkRDKFeeAddress,
    uint64 subscriptionId, 
    address _vrfCoordinator, 
    address _link, 
    bytes32 _keyHash, 
    uint32 _callbackGasLimit, 
    uint16 _requestConfirmations
  )
    VRFConsumerBaseV2(_vrfCoordinator)
  {    
    presaleInstance = IPresale(_presaleAddress);
    ridersInstance = ICollectionRiders(_ridersAddress);
    chainLinkRDKFeeAddress = payable(_chainLinkRDKFeeAddress);
    vrfCoordinator = _vrfCoordinator;
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    link = _link; 
    keyHash = _keyHash;
    callbackGasLimit = _callbackGasLimit;
    requestConfirmations = _requestConfirmations;
    LINKTOKEN = LinkTokenInterface(link);    
    s_subscriptionId = subscriptionId;
  }

  /********************************************************
   *                                                      *
   *                   PRESALE FUNCTIONS                  *
   *                                                      *
   ********************************************************/
  
  /// @notice Open a Mystery Box
  /// @dev Reads how many riders are inside the mystery box and proportionally request random numbers to ChainLink
  /// @param _mysteryBoxId Mystery box bought in presale
  function openMysteryBox(uint _mysteryBoxId) external payable {
    // Read # of Riders in mystery box
    ( , uint _quantity, , ) = presaleInstance.getPresaleCounter(msg.sender, _mysteryBoxId);
    uint chainlinkFeeMatic = presaleInstance.getRiderQuantityToChainLinkFee(_quantity);
    require(msg.value == chainlinkFeeMatic, "Collection Riders: Insufficient funds");
    require(mysteryBoxToMintingState[_mysteryBoxId] == MintingState.TO_OPEN, "Collection Riders: already opened"); 
    require(_quantity > 0, "Collection Riders: first, buy selected mystery box");   
    chainLinkRDKFeeAddress.transfer(chainlinkFeeMatic); 
    // Number of random values in one request
    uint32 numWords =  uint32(_quantity) * 4;
    // Request random numbers
    _requestRandomWords(numWords,_mysteryBoxId, msg.sender);
  }

  /// @dev Requests Random Generation
  /// @param _numWords number of random numbers to generate
  /// @param _mysteryBoxId mystery box Id with riders to be minted 
  function _requestRandomWords(uint32 _numWords, uint _mysteryBoxId, address _user) internal {
    // Will revert if subscription is not set and funded.
    s_requestId  = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      _numWords
    );
    requestToMysteryBox[s_requestId] = _mysteryBoxId;
    mysteryBoxToMintingState[_mysteryBoxId] = MintingState.WAITING_RANDOM;  
    requestToUser[s_requestId] = _user;
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
    uint mysteryBoxId = requestToMysteryBox[requestId];
    s_randomWords[mysteryBoxId] = randomWords;
    mysteryBoxToMintingState[mysteryBoxId] = MintingState.TO_REVEAL;
    emit MysteryBoxOpened(mysteryBoxId, requestToUser[requestId]);
  }

  /// @notice reveals the riders NFTs inside the mystery box
  /// @dev Applies business rules to set Rider Attributes and their token URI and delegates minting to CollectionRiders
  /// @param _mysteryBoxId mystery box Id with riders to be minted
  function revealNFT(uint _mysteryBoxId) external{
    uint _riderType;
    (_riderType, , , ) = presaleInstance.getPresaleCounter(msg.sender, _mysteryBoxId);
    require(mysteryBoxToMintingState[_mysteryBoxId] == MintingState.TO_REVEAL, "Collection Riders: there are no NFT to reveal yet");
    uint[] memory _randomWords = s_randomWords[_mysteryBoxId];
    // first random --> Number of Pizzas = NFT rareness
    // second random --> Image Rareness -> Base URI from IPFS 
    // third random --> Image Id and Motorbike
    // fourth random --> PVP Attributes 
    uint _randomWordsLength = _randomWords.length;
    for(uint i = 0; i < _randomWordsLength; i += 4) {
      // Range of probability for the first random number and riderType
      uint16 rangeResult = uint16(_getProbabilityRange(uint16((_randomWords[i] % 1000) + 1), presaleInstance.getTypeProbability(_riderType)));
      // Get PVP Rider Attributes array with bottom skill value and range of skill
      IPresale.RiderAttributes memory attributes = presaleInstance.getRiderAttributes(_riderType, rangeResult);
      // Get the IPFs folder for the NFT being minted using the second random
      string memory currentBaseURI = presaleInstance.getRidersBaseURI( _getTokenBaseURIIndex((_randomWords[i + 1] % 1000) + 1 , presaleInstance.getRidersBaseURIProbability(attributes.pizzaQuantity)) );
      // Gets the final IPFs URI of the image and the motorbike of the rider using the third random
      (string memory _tokenURI, bytes12 motorBike) = _getTokenURIandBike(
        presaleInstance.getMotorbikes(),
        currentBaseURI, 
        presaleInstance.getBaseURILength(currentBaseURI),
        _randomWords[i + 2]
      );
      _presaleMint(msg.sender, _randomWords[i + 3], motorBike, _tokenURI, attributes); 
    }
    emit NftRevealed(_mysteryBoxId, msg.sender);
    // updates the minting state of the mysteryBox so that it cannot be openned again
    mysteryBoxToMintingState[_mysteryBoxId] = MintingState.COMPLETED;
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
  function _getTokenURIandBike(bytes12[] memory _motorBikes, string memory _currentBaseURI, uint _tokenURILength,  uint _randNumber3)
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
  /// @param _randonNumber4 third random from ChainLink
  /// @param _motorBike motorbike of NFT to be minted
  /// @param _tokenURI final URI of NFT to be minted
  /// @param attributes pizzaQuantity and information to pick the other skills/attributes
  function _presaleMint(address user, uint _randonNumber4, bytes12 _motorBike, string memory _tokenURI, IPresale.RiderAttributes memory attributes) internal {
    // Setting the last attribute values of NFT to mint. PizzaQuantity is already precalculated
    // other skills follow this calculation: bottom Skill value + random inside the range of Skill value
    // E.G wheel can have a value from 9 to 20 --> wheel = 9 + (random from 0 to 11)
    ICollectionRiders.RidersAttributes memory riderAttributes = ICollectionRiders.RidersAttributes(
      attributes.pizzaQuantity,
      attributes.wheel[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber4, 'Wheel'))) % attributes.wheel[1]),
      attributes.fairing[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber4, 'Fairing'))) % attributes.fairing[1]),
      attributes.clutch[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber4, 'Clutch'))) % attributes.clutch[1]),
      attributes.exhaustPipe[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber4, 'Exhaust Pipe'))) % attributes.exhaustPipe[1]),
      attributes.turbo[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber4, 'Turbo'))) % attributes.turbo[1]),
      attributes.nitro[0] + uint8(uint(keccak256(abi.encodePacked(_randonNumber4, 'Nitro'))) % attributes.nitro[1]),
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
   *                    VIEW FUNCTIONS                    *
   *                                                      *
   ********************************************************/

  /// @notice state of minting process per mysteryBox
  /// @dev consumed by front-end team
  /// @param _mysteryBoxId mystery box Id to check
  function getMintingState(uint _mysteryBoxId) external view returns(uint) {
    return uint(mysteryBoxToMintingState[_mysteryBoxId]);
  }
  
  // TODO: DELETE before going prod. Helpful for testing
  function getRandoms(uint _mysteryBoxId, uint mod) external view returns (uint256[] memory) {
    if(mod == 0) {
      return s_randomWords[_mysteryBoxId];
    } else {      
      uint[] memory arr = new uint[](s_randomWords[_mysteryBoxId].length);
      for(uint i = 0; i < s_randomWords[_mysteryBoxId].length; i++) {
        arr[i] = (s_randomWords[_mysteryBoxId][i] % mod);
      }
      return arr;
    }
  }
  
    // TODO: DELETE before going prod. Helpful for testing
  function getRandomsSkills(
    uint _mysteryBoxId,
    uint[2] memory _wheel,
    uint[2] memory _fairing,
    uint[2] memory _clutch,
    uint[2] memory _exhaustPipe,
    uint[2] memory _turbo,
    uint[2] memory _nitro
    ) external view returns (uint256[] memory) {

      uint[] memory arr = new uint[](6*s_randomWords[_mysteryBoxId].length/4);
      for(uint i = 0; i < s_randomWords[_mysteryBoxId].length; i += 4) {
        arr[i * 6/4 ] = _wheel[0] + (uint(keccak256(abi.encodePacked(s_randomWords[_mysteryBoxId][i + 3], 'Wheel'))) % _wheel[1]);
        arr[i * 6/4 + 1] = _fairing[0] + uint(keccak256(abi.encodePacked(s_randomWords[_mysteryBoxId][i + 3], 'Fairing'))) % _fairing[1];
        arr[i * 6/4 + 2] =  _clutch[0] + uint(keccak256(abi.encodePacked(s_randomWords[_mysteryBoxId][i + 3], 'Clutch'))) % _clutch[1];
        arr[i * 6/4 + 3] = _exhaustPipe[0] + uint(keccak256(abi.encodePacked(s_randomWords[_mysteryBoxId][i + 3], 'Exhaust Pipe'))) % _exhaustPipe[1];
        arr[i * 6/4 + 4] = _turbo[0] + uint(keccak256(abi.encodePacked(s_randomWords[_mysteryBoxId][i + 3], 'Turbo'))) % _turbo[1];
        arr[i * 6/4 + 5] = _nitro[0] + uint(keccak256(abi.encodePacked(s_randomWords[_mysteryBoxId][i + 3], 'Nitro'))) % _nitro[1];
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

  interface IPresale{ 

    struct RiderAttributes {
      uint8 pizzaQuantity;
      uint8[2] wheel;
      uint8[2] fairing;
      uint8[2] clutch;
      uint8[2] exhaustPipe;
      uint8[2] turbo;
      uint8[2] nitro;
    }

    function getRecipeTPRange(uint _bottomLimit) external view returns (uint16);
    function getRecipesBaseURI() external view returns (string memory);
    function getTypePrice(uint _mBoxType) external view returns (uint);
    function getTypeProbability(uint _mBoxType) external view returns (uint[] memory);
    function getRiderAttributes(uint _mBoxType, uint16 _prob) external view returns (RiderAttributes memory attributes);
    function getRecipeAttribute(uint _mBoxType, uint _prob) external view returns (uint16);
    function getPresaleCounter(address _userAddress, uint _mysteryBoxCounter) external view returns (uint, uint, uint, uint);
    function countDown(address _userAddress, uint _mysteryBoxCounter, uint _mBoxType) external;
    function getTypeQuantity(uint _mBoxType) external view returns (uint);
    function getRidersBaseURIProbability(uint _attribute) external view returns (uint [] memory);
    function getRidersBaseURI(uint _baseURIIndex) external view returns (string memory);
    function getBaseURILength(string memory _baseURI) external view returns (uint);  
    function getMotorbikes() external view returns (bytes12 [] memory);
    function getAddressToMysteryBoxes(address _user) external view returns (uint[] memory);
    function getRiderQuantityToChainLinkFee(uint _riderQuantity) external view returns (uint);
    function getRecipeQuantityToChainLinkFee(uint _recipeQuantity) external view returns (uint);
    function getPresaleChainLinkFee() external view returns (uint);
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
  function getOwnerOf(uint _tokenId) external view returns(address);
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
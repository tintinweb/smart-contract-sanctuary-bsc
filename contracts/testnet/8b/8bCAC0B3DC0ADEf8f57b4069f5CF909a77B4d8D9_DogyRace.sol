// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721{
function ownerOf(uint256 tokenId) external view returns (address owner);
}
contract DogyRace is VRFConsumerBaseV2,Ownable{
VRFCoordinatorV2Interface COORDINATOR;

IERC721 NFT;

uint64 s_subscriptionId = 582; ///
address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
uint32 callbackGasLimit = 100000;
uint16 requestConfirmations = 3;
uint32 numWords = 1;

uint256 public s_requestId; ///
uint256 public RNumer; ///

address payable public Commission;

bool public paused = false;

uint256 public costLobby3 =1000000000000000;

uint256 private IdS;
uint256 private LobbyAmount = 8;
uint256 private Track =100000;

constructor() VRFConsumerBaseV2(vrfCoordinator) {
Commission = payable (msg.sender);
COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
NFT = IERC721(0xc48c1b73252B62783953f1Dc6b59DED1908f4d97);
}
uint256[] MetaTire = [11,3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3,	3];
uint256[] MetaTime = [11,21,28,	28,	27,	11,	29,	31,	22,	12,	38,	27,	28,	14,	12,	27,	28,	31,	39,	27,	20,	16,	29,	38,	14,	23,	39,	10,	15,	9,	29,	31,	18,	39,	18,	21,	33,	18,	26,	16,	22,	20,	29,	25,	25,	38,	15,	20,	24,	39,	34,	39,	27,	18,	34,	37,	27,	28,	25,	10,	36,	26,	35,	34,	13,	22,	39,	16,	25,	16,	25,	11,	31,	29,	18,	11,	36,	38,	17,	39,	23,	34,	34,	11,	23,	24,	33,	25,	35,	36,	13,	39,	15,	34,	15,	13,	14,	17,	23,	19,	10,	36,	30,	21,	12,	29,	31,	24,	11,	30,	26,	31,	19,	36,	17,	29,	19,	15,	31,	27,	28,	15,	14,	21,	21,	25];

struct BasePlayer{
uint256 place;
address payable Address;
uint256 ID;
uint256 Time;
}

mapping (uint256 => mapping (uint256 => BasePlayer)) private _BasePlayer;
mapping (uint256 => uint256) public numTier;
mapping (uint256 => uint256[]) private ArrTier;
mapping (uint256 => uint256[]) private WTier;

function LobbyTier3(uint256 IdTrack, uint256 _ID) public payable {
require(msg.value >= costLobby3+costLobby3/10,"Incorrect ticket price");
require(NFT.ownerOf(_ID) == msg.sender,"You are not the owner" );
require( MetaTire[_ID-499] == 3,"Your token has the wrong Tier 3" );
require(_ID != _BasePlayer[IdTrack][1].ID,"This id, is already participating in the race");
require(_ID != _BasePlayer[IdTrack][2].ID,"This id, is already participating in the race");
require(_ID != _BasePlayer[IdTrack][3].ID,"This id, is already participating in the race");
require(_ID != _BasePlayer[IdTrack][4].ID,"This id, is already participating in the race");
require(_ID != _BasePlayer[IdTrack][5].ID,"This id, is already participating in the race");
require(_ID != _BasePlayer[IdTrack][6].ID,"This id, is already participating in the race");
require(_ID != _BasePlayer[IdTrack][7].ID,"This id, is already participating in the race");
require(numTier[IdTrack]<=LobbyAmount);
require(msg.sender != _BasePlayer[IdTrack][1].Address,"This address, is already participating in the race");
require(msg.sender != _BasePlayer[IdTrack][2].Address,"This address, is already participating in the race");
require(msg.sender != _BasePlayer[IdTrack][3].Address,"This address, is already participating in the race");
require(msg.sender != _BasePlayer[IdTrack][4].Address,"This address, is already participating in the race");
require(msg.sender != _BasePlayer[IdTrack][5].Address,"This address, is already participating in the race");
require(msg.sender != _BasePlayer[IdTrack][6].Address,"This address, is already participating in the race");
require(msg.sender != _BasePlayer[IdTrack][7].Address,"This address, is already participating in the race");

uint256 _Time = Track/(MetaTime[_ID-499] + RNumer);

(bool success, ) = Commission.call{value: costLobby3/10 }("");
require(success, "Transfer failed.");

if(numTier[IdTrack]<LobbyAmount-1){
    if(numTier[IdTrack]==1){
        requestRandomWords();
    }
    if(numTier[IdTrack]==3){
        requestRandomWords();
    }
    if(numTier[IdTrack]==5){
        requestRandomWords();
    }
numTier[IdTrack]++;
BasePlayer memory newBasePlayer;
newBasePlayer.Address = payable(msg.sender);
newBasePlayer.ID = _ID;
newBasePlayer.Time = _Time;

_BasePlayer[IdTrack][numTier[IdTrack]] = newBasePlayer;
ArrTier[IdTrack].push(_Time);
}
else{
numTier[IdTrack]++;    
BasePlayer memory newBasePlayer;
newBasePlayer.Address = payable(msg.sender);
newBasePlayer.ID = _ID;
newBasePlayer.Time = _Time;

_BasePlayer[IdTrack][numTier[IdTrack]] = newBasePlayer;

ArrTier[IdTrack].push(_Time);
IdS=IdTrack;
Start();
}
}

function Start () internal{   
uint256[] memory Arr = ArrTier[IdS];
Game(Arr,0,7);
Take(IdS);
}

function Game(uint256[] memory arr, uint256 left,uint256 right) internal {
    uint256 i = left;
    uint256 j = right;
if (i == j) return;
    uint256 pivot = arr[uint256(left + (right - left) / 2)];
while (i <= j) {
while (arr[uint256(i)] < pivot) i++;
while (pivot < arr[uint256(j)]) j--;
if (i <= j) {
    (arr[uint256(i)], arr[uint256(j)]) = (arr[uint256(j)], arr[uint256(i)]);
    i++;
    j--;
}
}
if (left < j)
    Game(arr, left, j);
if (i < right)
    Game(arr, i, right);
WTier[IdS] = arr;
}

function Take (uint256 _IdTrack) internal {
uint256[] memory ArrTier1 = ArrTier[_IdTrack]; 
uint256[] memory WTier1 = WTier[_IdTrack];  
for (uint256 w=0; w<=LobbyAmount-1; w++){
for (uint256 a=0; a<=LobbyAmount-1; a++){
if(WTier1[w] == ArrTier1[a]){
    _BasePlayer[_IdTrack][a+1].place = w+1;
    if(w==0){
        Prize( _BasePlayer[_IdTrack][a+1].Address, costLobby3*LobbyAmount/2);
    }
    if(w==1){
        Prize( _BasePlayer[_IdTrack][a+1].Address, costLobby3*LobbyAmount/100*35);
    }
    if(w==2){
        Prize( _BasePlayer[_IdTrack][a+1].Address, costLobby3*LobbyAmount/100*15);
    }
WTier1[w]=888888;
ArrTier1[a] =444444;
}}}}

function Prize( address to ,uint256 prize) internal {
(bool success, ) = to.call{value: prize }("");
require(success, "Transfer failed.");
}

function requestRandomWords() internal {
    s_requestId = COORDINATOR.requestRandomWords(
    keyHash,
    s_subscriptionId,
    requestConfirmations,
    callbackGasLimit,
    numWords);
}

function fulfillRandomWords(uint256,uint256[] memory randomWords) internal override {
    RNumer = (randomWords[0] % 15) + 1;
}

function withdraw() public payable {
(bool hs, ) = payable(Commission).call{value: address(this).balance}("");
require(hs);
}

function Base123 (uint256 _IDTrack) public view
returns (
uint256 place1,address payable Address1,uint256 ID1,uint256 Time1,
uint256 place2,address payable Address2,uint256 ID2,uint256 Time2,
uint256 place3,address payable Address3,uint256 ID3,uint256 Time3){
    place1 =_BasePlayer[_IDTrack][1].place;
    Address1 = _BasePlayer[_IDTrack][1].Address;
    ID1 = _BasePlayer[_IDTrack][1].ID;
    Time1 = _BasePlayer[_IDTrack][1].Time;

    place2 =_BasePlayer[_IDTrack][2].place;
    Address2 = _BasePlayer[_IDTrack][2].Address;
    ID2 = _BasePlayer[_IDTrack][2].ID;
    Time2 = _BasePlayer[_IDTrack][2].Time;

    place3 =_BasePlayer[_IDTrack][3].place;
    Address3 = _BasePlayer[_IDTrack][3].Address;
    ID3 = _BasePlayer[_IDTrack][3].ID;
    Time3 = _BasePlayer[_IDTrack][3].Time;
}

function Base456 (uint256 _IDTrack) public view
returns (
uint256 place4,address payable Address4,uint256 ID4,uint256 Time4,
uint256 place5,address payable Address5,uint256 ID5,uint256 Time5,
uint256 place6,address payable Address6,uint256 ID6,uint256 Time6){
    place4 =_BasePlayer[_IDTrack][4].place;
    Address4 = _BasePlayer[_IDTrack][4].Address;
    ID4 = _BasePlayer[_IDTrack][4].ID;
    Time4 = _BasePlayer[_IDTrack][4].Time;

    place5 =_BasePlayer[_IDTrack][5].place;
    Address5 = _BasePlayer[_IDTrack][5].Address;
    ID5 = _BasePlayer[_IDTrack][5].ID;
    Time5 = _BasePlayer[_IDTrack][5].Time;

    place6 =_BasePlayer[_IDTrack][6].place;
    Address6 = _BasePlayer[_IDTrack][6].Address;
    ID6 = _BasePlayer[_IDTrack][6].ID;
    Time6 = _BasePlayer[_IDTrack][6].Time;
}

function Base78 (uint256 _IDTrack) public view
returns (
uint256 place7,address payable Address7,uint256 ID7,uint256 Time7,
uint256 place8,address payable Address8,uint256 ID8,uint256 Time8){
    place7 =_BasePlayer[_IDTrack][7].place;
    Address7 = _BasePlayer[_IDTrack][7].Address;
    ID7 = _BasePlayer[_IDTrack][7].ID;
    Time7 = _BasePlayer[_IDTrack][7].Time;

    place8 =_BasePlayer[_IDTrack][8].place;
    Address8 = _BasePlayer[_IDTrack][8].Address;
    ID8 = _BasePlayer[_IDTrack][8].ID;
    Time8 = _BasePlayer[_IDTrack][8].Time;
}

//only owner------------------------------------------------------
function setCommissionAddress(address payable _newCommission) public onlyOwner {
Commission = _newCommission;
}

function setTrack(uint256 _newTrack) public onlyOwner {
Track = _newTrack;
}

function pause(bool _state) public onlyOwner {
paused = _state;
}

function setcostLobby3(uint256 _costLobby3) public onlyOwner {
costLobby3 = _costLobby3;
}
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
pragma solidity ^0.8.6;

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
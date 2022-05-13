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

uint256 public costLobby1 =50000000000000000;

uint256 private IdS;
uint256 private LobbyAmount = 8;
uint256 private Track =100000;

constructor() VRFConsumerBaseV2(vrfCoordinator) {
Commission = payable (msg.sender);
COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
NFT = IERC721(0xc2fEf26F3dA0Cd49eC791789D22980B63631Df8c);
}
uint256[] MetaTire = [12,2,	2,	2,	2,	1,	2,	1,	2,	2,	1,	1,	2,	2,	2,	1,	2,	1,	2,	1,	2,	1,	1,	1,	1,	1,	2,	1,	2,	2,	1,	2,	1,	2,	2,	1,	2,	1,	2,	2,	2,	2,	1,	1,	2,	2,	1,	1,	1,	2,	1,	1,	1,	1,	1,	2,	2,	2,	1,	2,	1,	1,	1,	2,	1,	2,	1,	1,	2,	2,	1,	1,	1,	1,	1,	2,	1,	1,	1,	2,	2,	1,	2,	2,	1,	1,	1,	1,	1,	2,	2,	2,	2,	2,	2,	2,	1,	2,	1,	2,	1,	1,	2,	2,	1,	1,	2,	2,	1,	1,	1,	1,	2,	2,	2,	2,	2,	1,	2,	1,	1,	2,	1,	2,	2,	1,	1,	2,	2,	2,	2,	2,	1,	2,	1,	2,	2,	2,	1,	1,	1,	2,	2,	2,	1,	1,	2,	1,	1,	2,	1,	1,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2,	2];
uint256[] MetaTime = [11,56,53,	41,	49,	91,	50,	90,	59,	52,	86,	83,	45,	73,	46,	90,	68,	75,	69,	77,	66,	91,	81,	83,	89,	91,	43,	75,	65,	48,	86,	56,	80,	60,	48,	93,	72,	94,	58,	43,	66,	57,	89,	82,	39,	56,	78,	88,	77,	45,	95,	88,	83,	83,	78,	50,	68,	41,	84,	47,	80,	82,	94,	52,	93,	50,	96,	84,	50,	45,	82,	96,	85,	94,	96,	68,	82,	74,	73,	71,	65,	98,	57,	54,	98,	93,	94,	94,	77,	65,	48,	44,	52,	71,	39,	48,	73,	44,	79,	58,	88,	88,	56,	62,	92,	84,	48,	50,	86,	91,	77,	96,	56,	45,	69,	67,	54,	75,	63,	95,	86,	41,	92,	68,	47,	79,	89,	68,	64,	43,	46,	66,	76,	42,	87,	44,	72,	51,	82,	91,	93,	60,	54,	57,	90,	80,	72,	77,	77,	50,	89,	95,	40,	62,	72,	56,	62,	51,	68,	62,	61,	66,	39,	54,	70,	44,	52,	55,	53,	66,	48,	72,	68,	68,	64,	56,	65,	44,	39,	70,	71,	60,	72,	43,	74,	73,	52,	60,	45,	51,	68,	54,	58,	68,	56,	44,	47,	51,	67,	62,	64,	71,	58,	54,	69,	43,	60,	53,	62,	48,	46,	66,	42,	55,	50,	69,	46,	50,	49,	48,	54,	59,	42,	43,	45,	50,	63,	58,	41,	43,	51,	69,	71,	65,	65,	47,	43,	70,	65,	72,	69,	41,	71,	58,	73,	59,	50,	58,	72,	39,	44,	46,	71,	68,	63,	61,	43,	69,	74,	64,	66,	45,	57,	53,	69,	52,	70,	42,	39,	68,	41,	40,	49,	64,	49,	47,	66,	66,	60,	44,	65,	69,	57,	59,	44,	56,	70,	67,	70,	45,	43,	66,	71,	44,	43,	64,	52,	40,	43,	57,	65,	62,	49,	51,	52,	52,	44,	49,	39,	62,	48,	50,	63,	49,	61,	62,	59,	70,	50,	67,	70,	69,	58,	55,	69,	46,	73,	56,	57,	40,	50,	39,	41,	69,	72,	45,	70,	55,	45,	39,	64,	64,	73,	41,	43,	47,	50,	56,	42,	60,	56,	41,	73,	48,	46,	47,	41,	56,	63,	47,	69,	40,	50,	69,	52,	61,	41,	54,	62,	71,	45,	59,	39,	63,	71,	67,	52,	64,	43,	61,	44,	40,	54,	65,	48,	55,	45,	61,	63,	69,	50,	60,	58,	45,	43,	46,	55,	47,	64,	69,	69,	70,	39,	45,	50,	59,	71,	50,	70,	70,	52,	46,	41,	67,	43,	52,	59,	60,	53,	44,	46,	40,	48,	64,	47,	68,	46,	40,	40,	69,	53,	69,	43,	73,	46,	48,	45,	49,	55,	40,	47,	69,	63,	48,	73,	61,	68,	43,	50,	73,	41,	63,	42,	66,	45,	39,	66,	62,	41,	52,	60,	65,	68,	46,	72,	73,	63,	69,	62,	69,	60,	57,	43,	53,	45,	57,	51,	40,	61,	53,	55,	44,	73,	69,	53,	73,	62,	71,	54,	57,	39,	45,	49,	41,	68,	63,	60,	56,	52,	67];

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

function LobbyTier1(uint256 IdTrack, uint256 _ID) public payable {
require(msg.value >= costLobby1+costLobby1/10,"Incorrect ticket price");
require(NFT.ownerOf(_ID) == msg.sender,"You are not the owner" );
require( MetaTire[_ID] == 1,"Your token has the wrong Tier 1" );
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

uint256 _Time = Track/(MetaTime[_ID] + RNumer);

(bool success, ) = Commission.call{value: costLobby1/10 }("");
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
        Prize( _BasePlayer[_IdTrack][a+1].Address, costLobby1*LobbyAmount/2);
    }
    if(w==1){
        Prize( _BasePlayer[_IdTrack][a+1].Address, costLobby1*LobbyAmount/100*35);
    }
    if(w==2){
        Prize( _BasePlayer[_IdTrack][a+1].Address, costLobby1*LobbyAmount/100*15);
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

function setcostLobby1(uint256 _costLobby1) public onlyOwner {
costLobby1 = _costLobby1;
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
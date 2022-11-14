/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
                                                                                                                                                       
                                 ++++++++        *****.        +****      =***    +++++++++++       *****=            ****      *****    =***          
                                 *@@@@@@@%       #@@@@%         @@@@%      @@#   #@@@@@@@@@@%       *@@@@@         #@@@@@@@@     @@@@#   :@@*          
                      *    *     *@@@%   -       @@@@@@=        %@@@@%     %@#   .  :@@@@:  +       %@@@@@*       #@@@#    -     :@@@@+  %@%           
                     +:    *     *@@@%          *@@#@@@%        %@@@@@@    %@#       @@@@          [email protected]@#@@@@       %@@@%           *@@@@.*@@            
                     =:    -=    *@@@%          @@* @@@@*       %@%@@@@@   %@#       @@@@          %@# %@@@#      *@@@@@%          %@@@@@@             
                    *-.    =:    *@@@@@@#      *@@  *@@@@       %@#=%@@@@  %@#       @@@@         [email protected]@  [email protected]@@@       [email protected]@@@@@@%        %@@@@*             
        *- *        *=.    +-=   *@@@%  +      @@%###@@@@*      %@#  %@@@@*%@#       @@@@         %@@###@@@@#         %@@@@@@       [email protected]@@@              
      #=   ###   %#=*=     +=+   *@@@%        *@@%%%%%@@@@      %@#   #@@@@@@#       @@@@        [email protected]@%%%%%@@@@           [email protected]@@@#      [email protected]@@%              
    ##+     #   :%#*#+---- *+    *@@@%        @@*     %@@@#     %@#    #@@@@@*       @@@@        %@#     %@@@%           #@@@#      [email protected]@@%              
    ##           #*#**+=---.+    *@@@%       *@@      [email protected]@@@     %@#     *@@@@*       @@@@       *@@      [email protected]@@@    %%*   *@@@%       [email protected]@@@              
   ##*            **==++==++     #@@@@      [email protected]@@      *@@@@%    @@@       *@@*      [email protected]@@@#      @@@      [email protected]@@@@   +%@@@@@@%.        #@@@@=             
   ##*           #***-=++--:                                                                                                                           
   ###+           +=+==+**                                                                                                                             
    %##       %#  =:-++**+                        %@@@@+        *@@@@@@@@%:      #@@@@@@@@     @@@@#      %@@        #@@@@%                            
     %%#     #%* .=..*+=+-:                       %@@@@@        [email protected]@@@*#@@@@#     [email protected]@@@***%     *@@@@%     *@%        #@@@@@                            
      #%#*   %%#*=*:+**+=--                      [email protected]@@@@@*       [email protected]@@@  [email protected]@@@     [email protected]@@@         *@@@@@%    *@%        @@%@@@%                           
        ####*%%#***+     *+                      @@*[email protected]@@@       [email protected]@@@  [email protected]@@%     [email protected]@@@         *@@@@@@%   *@%       #@%[email protected]@@@=                          
               %##                              *@%  %@@@#      [email protected]@@@  %@@%      [email protected]@@@%%%      *@@[email protected]@@@@  *@%       @@  *@@@%                          
               %%#                              @@#  #@@@@      [email protected]@@@%@@@*       [email protected]@@@##%      *@@  %@@@@+*@%      #@%  [email protected]@@@+                         
                ##*                            *@@@@@@@@@@#     [email protected]@@@*@@@@       [email protected]@@@         *@@   %@@@@%@%      @@@@@@@@@@@                         
                #                              @@*    [email protected]@@@     [email protected]@@@-#@@@@      [email protected]@@@         *@@    %@@@@@%     #@%     @@@@*                        
                %                             *@@      %@@@%    [email protected]@@@  %@@@%     [email protected]@@@     +   *@@     #@@@@%    [email protected]@:     *@@@@                        
                                              @@#      *@@@@=   [email protected]@@@   %@@@%    *@@@@@@@@@*   #@@      :%@@%    %@@      [email protected]@@@#                       
                                                                          #:                               *#                                          
                                                                                                                                                       

*/
//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

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


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Receiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

interface IERC721Mintable is IERC721, IERC721Enumerable, IERC721Metadata {
    function autoMint(string memory tokenURI, address to) external returns (uint256);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

contract FASecondEditionBlindbox is VRFConsumerBaseV2
{
    using SafeMath for uint256;

    address public owner;
    address public prizeContractAddress;
    address public nftContractAddress;
    address payable public wallet;
    uint256 public totalSupply;
    uint256 public blindboxCost;
    bool public enabled;
    bool public openable;
    bool public reservedNftsMinted;
    bool public chainlinkBypass;

    IERC721Mintable private NFT_MINTABLE;
    IERC721Mintable private PRIZE_MINTABLE;
    VRFCoordinatorV2Interface private COORDINATOR;

    uint256 private nonce;

    // Chainlink
    uint64 private subscriptionId;
    bytes32 private keyHash;
    uint32 private callbackGasLimit;
    uint16 private requestConfirmations;

    uint256 public totalCreated;
    mapping(uint256 => uint256) private boxIndexes;
    mapping(address => uint256[]) private ownerBoxes;
    Blindbox[] private soldBoxes;
    PossibleNft[] public possibleNfts;

    struct PossibleNft {
        uint256 totalAvailable;
        uint256 totalIssued;
        string uri;
        bool prize;
    }

    struct Blindbox {
        uint256 id;
        address purchaser;
        bool opened;
        uint256 key;
        uint256 tokenID;
        bool wasPrize;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    modifier isEnabled() {
        require(enabled, "Contract is currently disabled");
        _;
    }

    modifier canOpen() {
        require(openable, "Opening is currently disabled");
        _;
    }

    constructor() VRFConsumerBaseV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE)  {
        owner = msg.sender;
        wallet = payable(0x9eE18a3bBa5C48dCBAebef598d5519Db9Ce63eE7);
        blindboxCost = 1 * 10 ** 17; // 0.1 BNB

        // Nft Contract
        nftContractAddress = 0x339b877da6Df5b941E953dfD32d3E634984edeD1;
        NFT_MINTABLE = IERC721Mintable(nftContractAddress);
        prizeContractAddress = 0x339b877da6Df5b941E953dfD32d3E634984edeD1;
        PRIZE_MINTABLE = IERC721Mintable(prizeContractAddress);

        // Chainlink
        setChainlink(
            0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04,
            100000,
            3
        );

        COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
        subscriptionId = 1866;

        // Box Contents
        possibleNfts.push(PossibleNft(95, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/1/", false));  // Leg Magic
        possibleNfts.push(PossibleNft(95, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/2/", false));  // Leg Warrior
        possibleNfts.push(PossibleNft(95, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/3/", false));  // Leg Support
        possibleNfts.push(PossibleNft(95, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/4/", false));  // Leg Tank
        possibleNfts.push(PossibleNft(245, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/5/", false));  // Epic Magic
        possibleNfts.push(PossibleNft(245, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/6/", false));  // Epic Warrior
        possibleNfts.push(PossibleNft(245, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/7/", false));  // Epic Support
        possibleNfts.push(PossibleNft(245, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/8/", false));  // Epic Tank
        possibleNfts.push(PossibleNft(495, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/9/", false));  // Rare Magic
        possibleNfts.push(PossibleNft(495, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/10/", false));  // Rare Warrior
        possibleNfts.push(PossibleNft(495, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/11/", false));  // Rare Support
        possibleNfts.push(PossibleNft(495, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/12/", false));  // Rare Tank
        possibleNfts.push(PossibleNft(995, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/13/", false));  // Com Magic
        possibleNfts.push(PossibleNft(995, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/14/", false));  // Com Warrior
        possibleNfts.push(PossibleNft(995, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/15/", false));  // Com Support
        possibleNfts.push(PossibleNft(995, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/16/", false));  // Com Tank
        possibleNfts.push(PossibleNft(995, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/17/", false));  // Com Magic
        possibleNfts.push(PossibleNft(995, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/18/", false));  // Com Warrior
        possibleNfts.push(PossibleNft(995, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/19/", false));  // Com Support
        possibleNfts.push(PossibleNft(995, 0, "https://www.fantasyarena.io/wp-json/edition-two/v1/uri/20/", false));  // Com Tank
        possibleNfts.push(PossibleNft(10, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_1BNB/", true));
        possibleNfts.push(PossibleNft(1, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_1ETH/", true));
        possibleNfts.push(PossibleNft(5, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_3BNB/", true));
        possibleNfts.push(PossibleNft(5, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_10LINK/", true));
        possibleNfts.push(PossibleNft(10, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_100BUSD/", true));
        possibleNfts.push(PossibleNft(3, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_300BUSD/", true));
        possibleNfts.push(PossibleNft(5, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_1000BUSD/", true));
        possibleNfts.push(PossibleNft(1, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_KILLERCLOWN/", true));
        possibleNfts.push(PossibleNft(1, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_LARGELAND/", true));
        possibleNfts.push(PossibleNft(2, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_MEDIUMLAND/", true));
        possibleNfts.push(PossibleNft(3, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_SMALLLAND/", true));
        possibleNfts.push(PossibleNft(2, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_SINNERMAN/", true));
        possibleNfts.push(PossibleNft(1, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_TSUKADRAGON/", true));
        possibleNfts.push(PossibleNft(1, 0, "https://www.fantasyarena.io/wp-json/prize/v1/uri/ED2_TSUKALAND/", true));
        
        for (uint256 i = 0; i < possibleNfts.length; i++) {
            totalCreated += possibleNfts[i].totalAvailable;
        }
    }

    function status() public view returns (bool canPurchase, uint256 cost, uint256 available) {
        canPurchase = enabled;
        cost = blindboxCost;
        available = totalAvailable();
    }

    function purchaseBlindbox() public payable isEnabled {
        require (totalAvailable() > 0, "No more blindboxes available");
        require (msg.value == blindboxCost, "Incorrect BNB value.");

        uint256 request = requestRandomWords();
        soldBoxes.push(Blindbox(
            request,
            msg.sender,
            false,
            0, 0, false
        ));

        wallet.transfer(blindboxCost);

        uint256 index = soldBoxes.length - 1;
        boxIndexes[request] = index;
        ownerBoxes[msg.sender].push(index);
    }

    function openBlindbox(uint256 index) public isEnabled canOpen  {
        require(soldBoxes[boxIndexes[index]].purchaser == msg.sender, "You do not own this blindbox.");
        require(chainlinkBypass || soldBoxes[boxIndexes[index]].key > 0, "This box is not ready to be opened yet. Please try again soon.");
        require(soldBoxes[boxIndexes[index]].opened == false, "This box is already open.");
        
        if (chainlinkBypass && soldBoxes[boxIndexes[index]].key == 0) {
            soldBoxes[boxIndexes[index]].key = manualRequestRandomWords();
        }

        uint256 total;
        for (uint256 i = 0; i < possibleNfts.length; i++) {
            total += possibleNfts[i].totalAvailable - possibleNfts[i].totalIssued;
        }

        uint256 roll = soldBoxes[boxIndexes[index]].key.mod(total).add(1);
        uint256 current;
        string memory uri;
        bool isPrize;
        for (uint256 i = 0; i < possibleNfts.length; i++) {
            current += possibleNfts[i].totalAvailable - possibleNfts[i].totalIssued;
            if (roll <= current) {
                uri = possibleNfts[i].uri;
                isPrize = possibleNfts[i].prize;
                possibleNfts[i].totalIssued++;
                break;
            }
        }

        uint256 tokenID;
        if (isPrize) {
            tokenID = PRIZE_MINTABLE.autoMint(uri, msg.sender);
        } else {
            tokenID = NFT_MINTABLE.autoMint(uri, msg.sender);
        }
        soldBoxes[boxIndexes[index]].opened = true;
        soldBoxes[boxIndexes[index]].tokenID = tokenID;
        soldBoxes[boxIndexes[index]].wasPrize = isPrize;
    }

    function balanceOf(address who) public view returns (Blindbox[] memory) {
        Blindbox[] memory boxes = new Blindbox[](ownerBoxes[who].length);

        for (uint256 i = 0; i < ownerBoxes[who].length; i++) {
            boxes[i] = soldBoxes[ownerBoxes[who][i]];
        }

        return boxes;
    }

    function totalAvailable() public view returns (uint256) {
        return totalCreated - soldBoxes.length;
    }


    // Admin Only
    function reserveNfts() public onlyOwner {
        require(reservedNftsMinted == false, "Reserved NFTs already minted");
        for (uint256 i = 1; i < possibleNfts.length; i++) {
            // Reserve 5 of each NFT
            if (possibleNfts[i].prize == false) {
                for (uint256 x = 0; x < 5; x++) {
                    NFT_MINTABLE.autoMint(possibleNfts[i].uri, wallet);
                }
            }
        }
        reservedNftsMinted = true;
    }

    function setOwner(address who) external onlyOwner {
        require(who != address(0), "Cannot be zero address");
        owner = who;
    }

    function setWallet(address payable who) external onlyOwner {
        require(who != address(0), "Cannot be zero address");
        wallet = who;
    }

    function setChainlink(bytes32 hash, uint32 gasLimit, uint16 confirmations) public onlyOwner {
        keyHash = hash;
        callbackGasLimit = gasLimit;
        requestConfirmations = confirmations;
    }

    
    function setChainlinkSubscription(uint64 subId) public onlyOwner {
        subscriptionId = subId;
    }

    function setPrice(uint256 price) public onlyOwner {
        blindboxCost = price;
    }

    function setEnabled(bool on) public onlyOwner {
        enabled = on;
    }

    function setOpenable(bool on) public onlyOwner {
        openable = on;
    }

    function setChainlinkBypass(bool on) public onlyOwner {
        chainlinkBypass = on;
    }

    function manualRequestRandomWords() private returns (uint256) {
        nonce += 1;
        return uint(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }

    // Chainlink
    function requestRandomWords() private returns (uint256) {
        return COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            1
        );
    }
  
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        soldBoxes[boxIndexes[requestId]].key = randomWords[0];
    }
}
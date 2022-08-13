/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT
// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol


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

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts/Betlify.sol


// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract DiceRoller is VRFConsumerBaseV2, ReentrancyGuard {
  //using SafeMath for uint256;
  VRFCoordinatorV2Interface COORDINATOR;

  // Your subscription ID.
  uint64 s_subscriptionId;

  // Rinkeby coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address vrfCoordinator = 	0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;

  // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.
  uint32 callbackGasLimit = 2500000;

  // The default is 3, but you can set this higher.
  uint16 requestConfirmations = 3;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords =  2;

  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address s_owner;
  uint256 public magnitude = 1000000000000000000; //used for percentage calculations
  uint256 public totalBets;
  uint256 public totalBetsWon;
  uint256 public totalWinnings;
  uint256 public totalBetsLost;
  
  uint256 public referralFees;
  
  uint256 public maxBetPercentage;

  uint256 public minerFees;

  uint256 public minerWalletBalance;
  
  mapping (address => uint256) public userBet;
  mapping (uint256 => uint256) public betValue;
  mapping (address => uint256) public playerCurrentResult1;
  mapping (address => uint256) public playerCurrentResult2;
  mapping (address => uint256) public playerTotalBets;
  mapping (address => address) public playerReferrer;
  mapping (address => uint256) public referralUnclaimedBalance;
  mapping (address => uint256) public referralEarnings;
  //mapping (address => uint256) public lastReawardClaimedTime;
  mapping (address => uint256) public lastReferralClaimedTime;
  mapping (address => uint256) public unclaimedWinning;
  mapping (address => uint256) public userLostBalance;
  //mapping (address => uint256) public userStakes;
  //mapping (address => uint256) public lastStakeTime;
  //mapping (address => uint256) public totalRewardsClaimed;
  mapping (uint256 => address) public requesterAddress;
  mapping (address => bool) public roundStatus;
  //uint256 public minAPR = 18;
  //uint256 public rewardsTimeBlock = 5760; //considering 15 seconds block
  //uint256 public totalBlocksPerYear = rewardsTimeBlock * 365;
  //uint256 public stakeLockDuration = 90; // nummber of days;

  struct Bet{
    uint256 requestId;
    uint256 amount;
    uint256 bet;
    uint256 dice1Result;
    uint256 dice2Result;
    bool isWon;
    uint256 createdTime;
  }

  Bet bet;
  mapping (address => Bet[]) public userBets;

  address public minerAddress;
  address public UNISWAP_FACTORY_ADDRESS;
  address public UNISWAP_ROUTER_ADDRESS;
  address public WETH;
  address public busdAddress;
  address public receiverAddress;

  IERC20 busdToken;
  IUniswapV2Router02 uniswapRouter;
  IERC20 wethToken;

  constructor() VRFConsumerBaseV2(vrfCoordinator) {
    
    //Testnet Addresses
    minerAddress = 0xA2a295E49e262226F152681bc9c7A719Cb8d23C5;
    UNISWAP_FACTORY_ADDRESS = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    UNISWAP_ROUTER_ADDRESS = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //WBNB
    busdAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    receiverAddress = msg.sender;
    busdToken = IERC20(busdAddress);
    wethToken = IERC20(WETH);
    uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);

    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    
    setSubscriptionId(681);
   
    setMinerFees(10);
    setReferralFees(5);

    setMaxBetPercentage(10);
  }

  function setSubscriptionId(uint64 _setSubscriptionId) public onlyOwner {
    s_subscriptionId = _setSubscriptionId;
  }

  function setMinerFees(uint256 _minerFees) public onlyOwner {
    minerFees = _minerFees;
  }
  
  function setReferralFees(uint256 _referralFees) public onlyOwner {
    referralFees = _referralFees;
  }
 
  function setMaxBetPercentage(uint256 _maxBetPercentage) public onlyOwner {
    maxBetPercentage = _maxBetPercentage;
  }

  function getMaxBetAmount() public view returns(uint256){
    return (address(this).balance * maxBetPercentage)/100;
  }

  function betUp(address _referrer) public payable{
    rollDice(1,_referrer);
  }

  function betDown(address _referrer) public payable{
    rollDice(0,_referrer);
  }

  // Assumes the subscription is funded sufficiently.
  function rollDice(uint16 _bet, address _referrer) internal {
    // Will revert if subscription is not set and funded.
    // require(msg.value <= getMaxBetAmount(),"You can not bet more than maximum allowed limit");
    require(roundStatus[msg.sender] == false,"Your game round is already in progress, Please wait till round is finished");
    
    if(playerReferrer[msg.sender] == address(0x0)) {
      playerReferrer[msg.sender] = _referrer;
    }
    
    playerCurrentResult1[msg.sender] = 0;
    playerCurrentResult2[msg.sender] = 0;
    playerTotalBets[msg.sender]++;

    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
    
    userBet[msg.sender] = _bet;
    requesterAddress[s_requestId] = msg.sender;
    totalBets += msg.value;
    betValue[s_requestId] = msg.value;
    roundStatus[msg.sender] = true;
  }
  
  function getRoundStatus() public view returns (bool){
      return roundStatus[msg.sender];
  }

  function getRoundStatusByAddress(address _address) public view returns (bool){
      return roundStatus[_address];
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords ) internal override {
  
    address playerAddress = requesterAddress[requestId];
    bool isWon;

    playerCurrentResult1[playerAddress] = (randomWords[0] % 5) + 1;
    playerCurrentResult2[playerAddress] = (randomWords[1] % 5) + 1;

    roundStatus[playerAddress] = false;
    
    if(userBet[playerAddress] == 1){
      if((playerCurrentResult1[playerAddress]+playerCurrentResult2[playerAddress]) >= 7){
          addBets(playerAddress, requestId, userBet[playerAddress], betValue[requestId], playerCurrentResult1[playerAddress],playerCurrentResult2[playerAddress],true);
          isWon = true;
          totalBetsWon++;
      }else{
          addBets(playerAddress, requestId, userBet[playerAddress], betValue[requestId], playerCurrentResult1[playerAddress],playerCurrentResult2[playerAddress],false);
          userLostBalance[playerAddress] += betValue[requestId];
          totalBetsLost++;
      }
    }else {
      if((playerCurrentResult1[playerAddress]+playerCurrentResult2[playerAddress]) < 7){
        addBets(playerAddress, requestId, userBet[playerAddress], betValue[requestId], playerCurrentResult1[playerAddress],playerCurrentResult2[playerAddress],true);
        isWon = true;
        totalBetsWon++;
      }else{
        addBets(playerAddress, requestId, userBet[playerAddress], betValue[requestId], playerCurrentResult1[playerAddress],playerCurrentResult2[playerAddress],false);
        userLostBalance[playerAddress] += betValue[requestId];
        totalBetsLost++;
      }
    }
    
    processDistribution(playerAddress,betValue[requestId],isWon);
  }

  function processDistribution(address _playerAddress, uint256 _amount, bool _isWon) public {
    minerWalletBalance += (_amount * minerFees)/100;
    
    address referrerPlayer = playerReferrer[_playerAddress];

    if(referrerPlayer != address(0)){
      referralUnclaimedBalance[referrerPlayer] += (_amount * referralFees)/100;
    }
    
    if(_isWon){
      uint256 wonAmount = (_amount - (_amount * getTotalFees())/100);
      totalWinnings += wonAmount;
      unclaimedWinning[_playerAddress] += wonAmount;
    }

    swapAndSendBUSDToMinerContract();
  
  }

  function swapAndSendBUSDToMinerContract() internal {
    
    address _tokenOut = busdAddress; 
    
    wethToken.deposit{value: minerWalletBalance}();
    wethToken.approve(UNISWAP_ROUTER_ADDRESS,wethToken.balanceOf(address(this)));
    
    uint deadline = block.timestamp + 1 days;
    uniswapRouter.swapExactTokensForTokens(wethToken.balanceOf(address(this)), 0, getPathForTokenToToken(WETH,_tokenOut), address(this), deadline);

    uint256 minerAmount = busdToken.balanceOf(address(this));
    bool success = busdToken.transfer(minerAddress, minerAmount);
    require(success, "Token Transfer failed.");

  }

  /*
  function swapBNBtoBUSD(uint256 _swapAmount) public returns(bool){
    address _tokenOut = busdAddress; 
    
    wethToken.deposit{value:_swapAmount}();
    wethToken.approve(UNISWAP_ROUTER_ADDRESS,wethToken.balanceOf(address(this)));
    
    uint deadline = block.timestamp + 1 days;
    uniswapRouter.swapExactTokensForTokens(wethToken.balanceOf(address(this)), 0, getPathForTokenToToken(WETH,_tokenOut), address(this), deadline);

    return true;

  }
  */

  function getPathForTokenToToken(address _tokenIn, address _tokenOut) public view returns (address[] memory) {
    address[] memory path = new address[](3);
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }
    return path;
  }

  function getTotalFees() public view returns(uint256){
    return (minerFees + referralFees);
  }

  function addBets(address _playerAddress, uint256 _requestId, uint256 _bet, uint256 _amount, uint256 _dice1Result, uint256 _dice2Result, bool _isWon) internal {
    bet =  Bet(_requestId, _amount, _bet, _dice1Result, _dice2Result, _isWon, block.timestamp);
    userBets[_playerAddress].push(bet);
  }

  function getBets() public view returns (Bet[] memory){
      return userBets[msg.sender];
  }

  function getResult() public view returns (uint256, uint256, bool){
    bool isWon;
    if(userBet[msg.sender] == 1){
      if((playerCurrentResult1[msg.sender]+playerCurrentResult2[msg.sender]) >= 7){
        isWon = true;
      }
    }else {
      if((playerCurrentResult1[msg.sender]+playerCurrentResult2[msg.sender]) < 7){
        isWon = true;
      }
    }
    return(playerCurrentResult1[msg.sender],playerCurrentResult2[msg.sender],isWon);
  }

  function getResultByAddress(address _address) public view returns (uint256, uint256, bool){
    bool isWon;
    if(userBet[_address] == 1){
      if((playerCurrentResult1[_address]+playerCurrentResult2[_address]) >= 7){
        isWon = true;
      }
    }else {
      if((playerCurrentResult1[_address]+playerCurrentResult2[_address]) < 7){
        isWon = true;
      }
    }
    return(playerCurrentResult1[_address],playerCurrentResult2[_address],isWon);
  }

  function claimWinnings() public nonReentrant {
    uint256 claimableWinnings = unclaimedWinning[msg.sender];
    unclaimedWinning[msg.sender] = 0;
    (bool success, ) = msg.sender.call{value: claimableWinnings}("");
    require(success, "Transfer failed.");
  }

  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }

  receive() external payable {
    //stake();
    //devWalletBalance += (address(this).balance * devFees)/100;
  }
}
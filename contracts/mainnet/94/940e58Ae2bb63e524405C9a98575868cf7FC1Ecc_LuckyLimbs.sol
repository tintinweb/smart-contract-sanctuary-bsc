/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// www.MoneyTreeCoin.io
// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

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

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

interface IMoneyTree {
    function buyLLCredits(address player, uint256 creditsPurchased) external;
    function claimLLPrizes(address winner, uint256 tokenAmount, uint256 nftAmount, uint256 randomness) external; 
}

contract LuckyLimbs is VRFConsumerBaseV2 {

    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    uint64 s_subscriptionId = 11;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    address link = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;

    receive() external payable {}

    address internal Developer = 0x6f02797A1176F6DB9b7965DD42ea61D398cCBAf9;
    address MTAddress = 0x2d5b21074D81Ae888c01722ec0657f20521be893;
    
    mapping(uint256 => uint256) public requestIdToRandomNumber;
    mapping(address => uint256) public _addressToRequestID;

    mapping(address => uint256) public _creditsOwned;
    mapping(address => uint256) public _addressCount;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public _addressIDResults;
    mapping(address => mapping(uint256 => uint256)) public _addressIDTokens;
    mapping(address => mapping(uint256 => uint256)) public _addressIDNFTs;

    uint256 public creditsBought;
    uint256 public tokensWon;
    uint256 public nftsWon;

    constructor () VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
    }

    function requestRandomWords() internal returns (uint256) {
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            1
        );
        return requestId;
    }
  
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        requestIdToRandomNumber[requestId] = randomWords[0];
    }

    function withdrawLink() public {
        require(msg.sender == Developer);
        LINKTOKEN.transfer(msg.sender, LINKTOKEN.balanceOf(address(this)));
    }

    function withdrawBNB(uint bnbAmount) public {
        require(msg.sender == Developer);
        payable(msg.sender).transfer(bnbAmount);
    }

    function buyCredits(uint256 amount) payable public {
        require(msg.value == 0.0025 ether);
        require(_creditsOwned[msg.sender] == 0);
        IMoneyTree(MTAddress).buyLLCredits(msg.sender, amount);
        creditsBought = creditsBought + amount;
        _creditsOwned[msg.sender] = amount;
        _addressToRequestID[msg.sender] = requestRandomWords();
    }

    function revealPrizes() public {
        require(_creditsOwned[msg.sender] != 0);
        require(requestIdToRandomNumber[_addressToRequestID[msg.sender]] != 0);
        
        uint256 randomValue = requestIdToRandomNumber[_addressToRequestID[msg.sender]];
        uint256[] memory expandedValues = new uint256[](_creditsOwned[msg.sender]);

        for (uint i=0; i<_creditsOwned[msg.sender]; i++) {
            expandedValues[i] =  uint256(keccak256(abi.encode(randomValue, i)))%100000+1;

            _addressIDResults[msg.sender][_addressCount[msg.sender]][i] = expandedValues[i];

            if(expandedValues[i] <= 66870){

            } else if(expandedValues[i] <= 81870){ 
                _addressIDTokens[msg.sender][_addressCount[msg.sender]] = _addressIDTokens[msg.sender][_addressCount[msg.sender]] + 3000;
                tokensWon = tokensWon + 3000;
            
            } else if(expandedValues[i] <= 91870){ 
                _addressIDTokens[msg.sender][_addressCount[msg.sender]] = _addressIDTokens[msg.sender][_addressCount[msg.sender]] + 5000;
                tokensWon = tokensWon + 5000;
            
            } else if(expandedValues[i] <= 94870){ 
                _addressIDTokens[msg.sender][_addressCount[msg.sender]] = _addressIDTokens[msg.sender][_addressCount[msg.sender]] + 10000;
                tokensWon = tokensWon + 10000;
            
            } else if(expandedValues[i] <= 97370){ 
                _addressIDNFTs[msg.sender][_addressCount[msg.sender]] = _addressIDNFTs[msg.sender][_addressCount[msg.sender]] + 1;
                nftsWon = nftsWon + 1;
            
            } else if(expandedValues[i] <= 98870){ 
                _addressIDTokens[msg.sender][_addressCount[msg.sender]] = _addressIDTokens[msg.sender][_addressCount[msg.sender]] + 25000;
                tokensWon = tokensWon + 25000;
            
            } else if(expandedValues[i] <= 99870){ 
                _addressIDTokens[msg.sender][_addressCount[msg.sender]] = _addressIDTokens[msg.sender][_addressCount[msg.sender]] + 50000;
                tokensWon = tokensWon + 50000;
            
            } else if(expandedValues[i] <= 99970){ 
                _addressIDTokens[msg.sender][_addressCount[msg.sender]] = _addressIDTokens[msg.sender][_addressCount[msg.sender]] + 100000;
                tokensWon = tokensWon + 100000;
            
            } else if(expandedValues[i] <= 99990){ 
                _addressIDTokens[msg.sender][_addressCount[msg.sender]] = _addressIDTokens[msg.sender][_addressCount[msg.sender]] + 250000;
                tokensWon = tokensWon + 250000;
            
            } else if(expandedValues[i] <= 100000){ 
                _addressIDTokens[msg.sender][_addressCount[msg.sender]] = _addressIDTokens[msg.sender][_addressCount[msg.sender]] + 500000;
                tokensWon = tokensWon + 500000;
            }
        }

        IMoneyTree(MTAddress).claimLLPrizes(msg.sender, 
                                            _addressIDTokens[msg.sender][_addressCount[msg.sender]], 
                                            _addressIDNFTs[msg.sender][_addressCount[msg.sender]],
                                            requestIdToRandomNumber[_addressToRequestID[msg.sender]]);

        _addressCount[msg.sender] = _addressCount[msg.sender] + 1;
        _creditsOwned[msg.sender] = 0;

    }
}
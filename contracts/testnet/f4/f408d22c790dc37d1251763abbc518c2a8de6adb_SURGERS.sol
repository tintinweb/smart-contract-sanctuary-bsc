/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-30
*/

// SPDX-License-Identifier: MIT

////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
//                                                                                //
//                                                                                //
//      The game is double or nothing, double your bet ⚡️ or lose it all 😭.      //
//               We take 5% of the bet as payment to play the game.               //
//      Bets are limited to a percentage of the available contract balance.       //
//          This is to ensure that the contract never runs out of funds.          //
//The outcome is decided fairly and transparently, on chain, using Chainlink VRF. //
//                      Minimum bets are 500 SRG                                  //
//                                                                                //
//                                                                                //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////


// File: @chainlink/contracts/src/v0.8/interfaces/VRFV2WrapperInterface.sol


pragma solidity ^0.8.0;

interface VRFV2WrapperInterface {
  /**
   * @return the request ID of the most recent VRF V2 request made by this wrapper. This should only
   * be relied option within the same transaction that the request was made.
   */
  function lastRequestId() external view returns (uint256);

  /**
   * @notice Calculates the price of a VRF request with the given callbackGasLimit at the current
   * @notice block.
   *
   * @dev This function relies on the transaction gas price which is not automatically set during
   * @dev simulation. To estimate the price at a specific gas price, use the estimatePrice function.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   */
  function calculateRequestPrice(uint32 _callbackGasLimit) external view returns (uint256);

  /**
   * @notice Estimates the price of a VRF request with a specific gas limit and gas price.
   *
   * @dev This is a convenience function that can be called in simulation to better understand
   * @dev pricing.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _requestGasPriceWei is the gas price in wei used for the estimation.
   */
  function estimateRequestPrice(uint32 _callbackGasLimit, uint256 _requestGasPriceWei) external view returns (uint256);
}

// File: @chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol


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

// File: @chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol


pragma solidity ^0.8.0;



/* ****************************
 * @notice Interface for contracts using VRF randomness through the VRF V2 wrapper
 * ****************************
 * @dev PURPOSE
 *
 * @dev Create VRF V2 requests without the need for subscription management. Rather than creating
 * @dev and funding a VRF V2 subscription, a user can use this wrapper to create one off requests,
 * @dev paying up front rather than at fulfillment.
 *
 * @dev Since the price is determined using the gas price of the request transaction rather than
 * @dev the fulfillment transaction, the wrapper charges an additional premium on callback gas
 * @dev usage, in addition to some extra overhead costs associated with the VRFV2Wrapper contract.
 * ***************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFV2WrapperConsumerBase. The consumer must be funded
 * @dev with enough LINK to make the request, otherwise requests will revert. To request randomness,
 * @dev call the 'requestRandomness' function with the desired VRF parameters. This function handles
 * @dev paying for the request based on the current pricing.
 *
 * @dev Consumers must implement the fullfillRandomWords function, which will be called during
 * @dev fulfillment with the randomness result.
 */
abstract contract VRFV2WrapperConsumerBase {
  LinkTokenInterface internal immutable LINK;
  VRFV2WrapperInterface internal immutable VRF_V2_WRAPPER;

  /**
   * @param _link is the address of LinkToken
   * @param _vrfV2Wrapper is the address of the VRFV2Wrapper contract
   */
  constructor(address _link, address _vrfV2Wrapper) {
    LINK = LinkTokenInterface(_link);
    VRF_V2_WRAPPER = VRFV2WrapperInterface(_vrfV2Wrapper);
  }

  /**
   * @dev Requests randomness from the VRF V2 wrapper.
   *
   * @param _callbackGasLimit is the gas limit that should be used when calling the consumer's
   *        fulfillRandomWords function.
   * @param _requestConfirmations is the number of confirmations to wait before fulfilling the
   *        request. A higher number of confirmations increases security by reducing the likelihood
   *        that a chain re-org changes a published randomness outcome.
   * @param _numWords is the number of random words to request.
   *
   * @return requestId is the VRF V2 request ID of the newly created randomness request.
   */
  function requestRandomness(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords
  ) internal returns (uint256 requestId) {
    LINK.transferAndCall(
      address(VRF_V2_WRAPPER),
      VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit),
      abi.encode(_callbackGasLimit, _requestConfirmations, _numWords)
    );
    return VRF_V2_WRAPPER.lastRequestId();
  }

  /**
   * @notice fulfillRandomWords handles the VRF V2 wrapper response. The consuming contract must
   * @notice implement it.
   *
   * @param _requestId is the VRF V2 request ID.
   * @param _randomWords is the randomness result.
   */
  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
    require(msg.sender == address(VRF_V2_WRAPPER), "only VRF V2 wrapper can fulfill");
    fulfillRandomWords(_requestId, _randomWords);
  }
}

// File: contracts/doubleOrNothing.sol



pragma solidity 0.8.7;


abstract contract ERC20  {
   function balanceOf(address account) external virtual view returns (uint256);
   function transfer(address recipient, uint256 amount) external virtual returns (bool);
   function approve(address spender, uint tokens) public virtual returns (bool success);
   function decimals() public virtual returns (uint8);
   function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
}

contract SURGERS is VRFV2WrapperConsumerBase {

    address private owner;
    bool private status = false;
    event Received(address sender, uint amount);
    address fees_address;
    mapping(address => bool) public whitelist;

    uint256 maximumStakePercentage = 10; 
    uint256 gameFee = 5; 
    uint256 minimumBNBstake = 0.05 ether;
    uint256 minimumUSDstake = 10;
    uint256 minimumSRGstake = 250;
    uint256 bnbVRFcost = 0.0016 ether;
    uint256 usdVRFcost = 0.5 ether;
    uint256 VRFcost = 0.5 ether;
    uint256 srgVRFcost = 30e9;

    event new_player(address indexed player, uint256 stake, address paidWithToken, uint256 indexed requestId);
    event result(address indexed player, uint256 stake, address paidWithToken, uint256 indexed requestId, bool indexed didWin);

    struct playerStatus {
        uint256 stake;
        uint256 randomWord;
        address player;
        bool didWin;
        address paidWithToken;
    } 
    
    mapping(uint256 => playerStatus) public statuses;   //player statuses using the VRF request ID as the key
    mapping(address => uint256[]) public entries;       //a map to track entires and the VRF request ID incase something fails - so user stakes do not get lost
    
 
    address constant linkToken = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06; //BSC TESTNET
    address constant vrfWrapper = 0x699d428ee890d55D56d5FC6e26290f3247A762bd; //BSC TESTNET
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684; //BSC MAINNET
    address constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; //BSC MAINNET
    address constant SURGE = 0x3816B271c3D89726e80f4c79EE303639d05999D0; //BSC TESTNET
    
    uint32 callbackGasLimit = 100000; 
    uint32 constant numWords = 1;
    uint16 constant requestConfirmations = 3; 

    receive() external payable {
       emit Received(msg.sender, msg.value);
    }

    constructor() VRFV2WrapperConsumerBase(linkToken, vrfWrapper) {
        owner = msg.sender; 
        whitelist[owner] = true;
    }
    
    modifier onlyOwner() {
       require (msg.sender == owner, "Only owner can do this");
       _;
    }

    modifier onlyWhitelist() {
       require (whitelist[msg.sender] == true, "Not on whitelist");
       _;
    }

    function changeOwnerEncoded(address _newOwner) public onlyOwner {
      require (msg.sender == owner, "NO");
      owner = _newOwner;
    }
    function withdraw() public onlyOwner  {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawERC(uint256 _amount, address _token) public onlyOwner  {
        ERC20 token = ERC20(_token);
        token.transfer(address(owner), _amount);
    }


    function updateCosts(uint256 _maximumStakePercentage, uint256 _gameFee,  uint256 _minimumBNBstake, uint256 _minimumUSDstake, uint256 _minimumSRGstake, uint256 _bnbVRFcost, uint256 _usdVRFcost, uint256 _srgVRFcost) public onlyWhitelist {
        maximumStakePercentage = _maximumStakePercentage; 
        gameFee = _gameFee;
        minimumBNBstake = _minimumBNBstake;
        minimumUSDstake = _minimumUSDstake;
        minimumSRGstake = _minimumSRGstake;
        bnbVRFcost = _bnbVRFcost;
        usdVRFcost = _usdVRFcost;
        srgVRFcost = _srgVRFcost;
    }

    function checkCosts() public view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        return (maximumStakePercentage,gameFee,minimumBNBstake,minimumUSDstake,minimumSRGstake,bnbVRFcost,usdVRFcost,srgVRFcost);
    }

    function contract_status(bool _status) public onlyWhitelist {
         status = _status;
     }

    function set_fees_address(address _address) public onlyOwner {
         fees_address = _address;
     }

    function isContract(address _address) public view returns (bool){
        uint32 size;
         assembly {
         size := extcodesize(_address)
        }
     return (size > 0);
    }

    function addToWhitelist(address[] calldata toAddAddresses) 
    external onlyOwner
    {
        for (uint i = 0; i < toAddAddresses.length; i++) {
            whitelist[toAddAddresses[i]] = true;
        }
    }

    function removeFromWhitelist(address[] calldata toRemoveAddresses)
    external onlyOwner
    {
        for (uint i = 0; i < toRemoveAddresses.length; i++) {
            delete whitelist[toRemoveAddresses[i]];
        }
    }

    function checkStatus() public view returns (bool) {
        return status;
    }

//GAME LOGIC
    function DoubleOrNothing(uint256 _amount, address _token) public payable {

        require(!isContract(msg.sender) || !isContract(tx.origin), "Caller is contract");
        require(status, "Contract paused");

        ERC20 token_link = ERC20(linkToken); 
        uint tokenBalance = token_link.balanceOf(address(this));
        require(tokenBalance/1e18 > 1, "Not enough LINK on the contract");

        address _tokenAddress;
        uint256 _stake = msg.value;

        if (msg.value > 0) {
            require(msg.value >= minimumBNBstake, "Minimum stake not met");
            require (address(this).balance >= msg.value * 2, "Not enough BNB to cover a win");
            uint256 tenPercentOfBalance = (address(this).balance / 100) * maximumStakePercentage;
            require(tenPercentOfBalance > msg.value, "Maximum stake is 10% of the contract balance");
            _stake = ((_stake / 100) * (100-gameFee)) - bnbVRFcost;
            payable(fees_address).transfer(msg.value-_stake);

        } else {
            require(_token == USDT || _token == BUSD || _token == SURGE, "Stable not supported");
            if(_token == USDT || _token == BUSD) {
                 require((_amount / 1e18) >= minimumUSDstake, "Minimum stake not met");
                 VRFcost = usdVRFcost;
            }
            else if (_token == SURGE) {
                  require((_amount / 1e9) >= minimumSRGstake, "Minimum stake not met");
                 VRFcost = srgVRFcost;
            }
            ERC20 token = ERC20(_token);
            require (token.balanceOf(address(this)) >= _amount * 2, "Not enough stablecoin to cover a win");
            uint256 tenPercentOfBalance = (token.balanceOf(address(this)) / 100) * maximumStakePercentage;
            require(tenPercentOfBalance > _amount, "Maximum stake is 10% of the contract balance");
            token.transferFrom(msg.sender, address(this), _amount);
            _tokenAddress = _token;

            _stake = ((_amount / 100) * (100-gameFee)) - VRFcost;
             token.transfer(fees_address, _amount-_stake);
        }
        
        uint256 requestId = requestRandomness(callbackGasLimit, requestConfirmations, numWords);

        statuses[requestId] = playerStatus({
            stake: _stake,
            randomWord: 0,
            player: msg.sender,
            didWin: false,
            paidWithToken: _tokenAddress 
        });

        entries[msg.sender].push(requestId);
        emit new_player(msg.sender, _stake, _tokenAddress, requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {

        require(statuses[requestId].stake > 0, "Request not found");

        statuses[requestId].didWin = false;
        statuses[requestId].randomWord = randomWords[0];

        if (randomWords[0] % 2 == 0) {
            statuses[requestId].didWin = true;
            if (statuses[requestId].paidWithToken == 0x0000000000000000000000000000000000000000) {
                payable(statuses[requestId].player).transfer(statuses[requestId].stake * 2);
            } else {
                ERC20 token = ERC20(statuses[requestId].paidWithToken);
                token.transfer(statuses[requestId].player, statuses[requestId].stake * 2);
            }

        }
        emit result(statuses[requestId].player, statuses[requestId].stake, statuses[requestId].paidWithToken, requestId, statuses[requestId].didWin);
        
    }

    function getRequestById(uint256 requestId) public view returns (playerStatus memory) {
        return statuses[requestId];
    }

    function getAllRequestIds(address sender) public view returns (uint256[] memory) {
        return entries[sender];
    }

    function getPlayerRequestByIndex(address sender, uint256 requestIndex) public view returns (playerStatus memory) {
        uint256 requestId = entries[sender][requestIndex];
        return statuses[requestId];
    }

   }
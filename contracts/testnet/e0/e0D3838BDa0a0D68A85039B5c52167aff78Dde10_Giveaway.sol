// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";


contract Giveaway is
    VRFV2WrapperConsumerBase,
    ConfirmedOwner{


    event ParticipantAdded();
    event Nftgivenaway();
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);


    uint256 registrationTime;
    uint256 count;
    address[] addresses;
    uint256[] randomValues;
    mapping(address => bool) winners;
    mapping(uint256 => RequestStatus) internal r_status;
    mapping(address => uint256) internal lastRequestId;
    mapping(address => uint256[]) internal userRequestIds;

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }


    uint32 callbackGasLimit = 1000000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    uint32 randomNums = 10;

    address linkAddress = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;

    // address WRAPPER 
    address wrapperAddress = 0x699d428ee890d55D56d5FC6e26290f3247A762bd;

    struct Participant{
        address beneficiery;
        string name;
        string email;
    }

    mapping(address => Participant) participants;

    constructor(uint256 _resgistrationTime)
    ConfirmedOwner(msg.sender)
    VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
    {
        registrationTime = (block.timestamp + _resgistrationTime);
    }

    function requestRandomNumber() external returns (uint256 requestId)
    {
        require(msg.sender == owner(), "onlyOwner");
        
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            randomNums
        );
        userRequestIds[msg.sender].push(requestId);
        r_status[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        lastRequestId[msg.sender] = requestId;
        emit RequestSent(requestId, randomNums);
        return requestId;
    }

    //callback function will be called at chainlink level
    function fulfillRandomWords( uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(r_status[_requestId].paid > 0, "request not found");
        r_status[_requestId].fulfilled = true;
        r_status[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords, r_status[_requestId].paid);
    }

    function getModAndSetRandomness() public
    {
        for(uint256 k = 0; k< userRequestIds[owner()].length; k++){
            require(r_status[userRequestIds[owner()][k]].paid > 0, "request not found");
            require(block.timestamp > registrationTime, "registeration not closed");
            require(msg.sender == owner(), "Not owner");
            RequestStatus memory request = r_status[userRequestIds[owner()][k]];
            bool exist = false;
            for(uint256 i=0; i<request.randomWords.length;i++){
                for(uint256 j = 0; j< randomValues.length;j++){
                    if( (request.randomWords[i]%4 + 1) == randomValues[j]){
                        exist = true;
                    }
                }
                if(!exist && randomValues.length < 25){
                    randomValues.push((request.randomWords[i]%4 + 1));
                }
                exist = false;
            }
            setRanddomWinners();
        }
    }

    function setRanddomWinners() internal{
        uint256 value;
        for(uint256 i = 0; i<randomValues.length; i++){
            value = randomValues[i];
            winners[addresses[value]] = true;
        } 
    }

    function register(string memory _name, string memory _email) external {
        require(block.timestamp < registrationTime, "Registration closed");
        require(participants[msg.sender].beneficiery != msg.sender, "already exists");
        addresses.push(msg.sender);
        participants[msg.sender] = Participant({
            beneficiery: msg.sender,
            name:_name,
            email: _email
        });
        count++;
        emit ParticipantAdded();
    }

    function getRequestStatus( uint256 _requestId) public view returns
    (uint256 paid, bool fulfilled, uint256[] memory randomWords)
    {
        require(r_status[_requestId].paid > 0, "request not found");
        RequestStatus memory request = r_status[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    function getRandomValues()external view returns(uint256[] memory){
        return randomValues;
    }

    function checkIfWinner(address participant) public view returns(bool){
        return winners[participant];
    }

    function lastUserRequest() external view returns(uint256){
        return lastRequestId[msg.sender];
    }

    function getWinners() external view returns(Participant[] memory){
        Participant[] memory winner = new Participant[](randomValues.length);
        for(uint256 i = 0; i < randomValues.length; i++){
            winner[i] = participants[addresses[i]];
        }
        return winner;
    }

    function isOwner() external view returns(bool){
        return msg.sender == owner();
    }

    function participantInfo(address participant) external view returns(Participant memory){
        return participants[participant];
    }

    function totalparticipants() external view returns(uint256){
        return count;
    }

    function timeLeft() external view returns(uint256){
        uint256 temp = 0;
        if(block.timestamp < registrationTime){
            temp = registrationTime - block.timestamp;
        }
        return temp;
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
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

import "./interfaces/LinkTokenInterface.sol";
import "./interfaces/VRFV2WrapperInterface.sol";

/** *******************************************************************************
 * @notice Interface for contracts using VRF randomness through the VRF V2 wrapper
 * ********************************************************************************
 * @dev PURPOSE
 *
 * @dev Create VRF V2 requests without the need for subscription management. Rather than creating
 * @dev and funding a VRF V2 subscription, a user can use this wrapper to create one off requests,
 * @dev paying up front rather than at fulfillment.
 *
 * @dev Since the price is determined using the gas price of the request transaction rather than
 * @dev the fulfillment transaction, the wrapper charges an additional premium on callback gas
 * @dev usage, in addition to some extra overhead costs associated with the VRFV2Wrapper contract.
 * *****************************************************************************
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}
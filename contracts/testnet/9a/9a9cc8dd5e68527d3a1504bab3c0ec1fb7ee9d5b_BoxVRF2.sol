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

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "lib/chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./IVNS.sol";

contract BoxVRF2 is VRFV2WrapperConsumerBase, ConfirmedOwner {
	event RequestSent(address indexed user, uint256 requestId);
	event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);

	struct RequestStatus {
		uint256 paid;
		bool fulfilled;
		uint256 randomWords;
	}
	struct BoxResult {
		uint256 vnsAmount;
		bool gotNft;
		uint256 nftId;
	}
	mapping(uint256 => RequestStatus) public requests; /* requestId --> requestStatus */
	mapping(address => uint256) public userRequestId;
	mapping(address => BoxResult) public lastBoxResult;

	uint32 public callbackGasLimit = 100000;
	uint16 public requestConfirmations = 3;

	bool public inProgress = false;

	address public immutable LINK_ADDRESS;
	address public immutable VRF_V2_WRAPPER_ADDRESS;

	address public vnsAddress;
	address public nftAddress;
	address public usdtAddress;

	uint256 public boxPrice;
	uint256 public nftOdds;

	event GetBox(address indexed user, bool gotNft, uint256 nftId);

	constructor(
		address _linkAddress,
		address _wrapperAddress
	) ConfirmedOwner(msg.sender) VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress) {
		LINK_ADDRESS = _linkAddress;
		VRF_V2_WRAPPER_ADDRESS = _wrapperAddress;
	}

	function setBoxInfo(
		address _vnsAddress,
		address _nftAddress,
		address _usdtAddress,
		uint256 _boxPrice,
		uint256 _nftOdds
	) external onlyOwner {
		vnsAddress = _vnsAddress;
		nftAddress = _nftAddress;
		usdtAddress = _usdtAddress;
		boxPrice = _boxPrice;
		nftOdds = _nftOdds;
	}

	function setVRFInfo(uint32 _callbackGasLimit, uint16 _requestConfirmations) external onlyOwner {
		callbackGasLimit = _callbackGasLimit;
		requestConfirmations = _requestConfirmations;
	}

	function buy() external {
		require(!inProgress, "inProgress");
		require(!requests[userRequestId[msg.sender]].fulfilled, "already fulfilled,claim first");
		require(IERC20(usdtAddress).transferFrom(msg.sender, address(this), boxPrice), "transfer usdt fail");
        
        uint256 paidLink =VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit);
        require(IERC20(LINK_ADDRESS).balanceOf(address(this)) > paidLink,"not enough link");

		inProgress = true;
		uint256 requestId = requestRandomness(callbackGasLimit, requestConfirmations, 1);
		requests[requestId] = RequestStatus({
			paid: paidLink,
			randomWords: 0,
			fulfilled: false
		});
		userRequestId[msg.sender] = requestId;
		emit RequestSent(msg.sender, requestId);
	}

	function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
		require(requests[_requestId].paid > 0, "request not found");
		inProgress = false;
		requests[_requestId].fulfilled = true;
		requests[_requestId].randomWords = _randomWords[0];
		emit RequestFulfilled(_requestId, _randomWords, requests[_requestId].paid);
	}

	function get() external {
		require(requests[userRequestId[msg.sender]].fulfilled, " not fulfilled");
		//transfer VNS
		IVNSToken(vnsAddress).mint(msg.sender, boxPrice * 100);

		bool gotNft = false;
		uint256 nftId = 0;
		//nft
		uint256 odds = requests[userRequestId[msg.sender]].randomWords % 100;
		if (odds <= nftOdds) {
			//mint nft
			gotNft = true;
			nftId = IVNSNFT(nftAddress).blindBoxTo(msg.sender);
		}

		BoxResult storage rd = lastBoxResult[msg.sender];
		rd.vnsAmount = boxPrice * 100;
		rd.gotNft = gotNft;
		rd.nftId = nftId;

		delete userRequestId[msg.sender];
		emit GetBox(msg.sender, gotNft, nftId);
	}

	function withdraw(address token) public onlyOwner {
		require(IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this))), "unable to transfer");
	}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

struct UserInfo {
	uint256 id;
	uint256 level;
	uint256 levelIndex; //index in level
	uint256 firstIdoTime;
	uint256 lastIdoTime;
	uint256 lastTransferTime;
	bool alreadyTransferred;
	uint256 memberPoints;
	uint256 pointsRefunded;//max memberPoints*0.9
	address parent; //=0 not initialized
}

interface IVNSCPD {
	function mint(address to, uint256 amount) external;
}

interface IVNSToken {
	function mint(address to, uint256 amount) external;

	function lockIdoAmount(address user, uint256 amount) external;

	function lockAirdropAmount(address user, uint256 amount) external;
}

interface IVNSNFT {
	function mintTo(address to, uint256 num) external returns (uint256);

	function blindBoxTo(address to) external returns (uint256);
}

interface IVNSMemberShip {
	function getUserInfo(address user) external view returns (UserInfo memory);

	function addUser(address user) external;

	function bindParent(address user, address parent) external;
function recordTrans(address user)external ;

	function addMemberPoints(address user, uint256 points) external;

	function updateLevel(address user) external;

	function getLevelLength(uint256 level) external returns (uint256);
}

interface INFTStakingPool {
	function getStakedNft(address user) external returns (uint256[] memory);
	function dividend(uint256 amount) external;
}

interface IStakingPool {
	function stakeTo(uint256 poolId, uint256 amount, address to) external;
	function dividend(uint256 amount) external;
}
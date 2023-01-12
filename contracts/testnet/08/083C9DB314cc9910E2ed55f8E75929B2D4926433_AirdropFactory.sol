// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
pragma solidity >=0.8.0;
/// @title Airdrop Smart Contract
/// @author @m3tamorphTECH
/// @dev Contract for a airdrop where users can claim a share of an airdrop token if they have been whitelisted

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AirdropFactory.sol";

contract Airdrop is Ownable {

    /* ========== STATE VARIABLES ========== */

    IERC20 public airdropToken;
    uint public airdropTokenAmount;
    uint public claimAmount;
    bool public airdropOpen;
    bool public airdropFinalized;
    uint public startTime;
    uint public endTime;
    uint public duration;
    address private feeRecipient;
    address private airdropFactory;
    mapping(address => bool) public claimed;

    /* ========== EVENTS ========== */

    event AirdropStarted(uint startTime, uint endTime);
    event Claimed(address claimant, uint amount);
    event AirdropFinalized();

    /* ========== CONSTRUCTOR ========== */

    constructor(
        IERC20 _airdropToken,
        uint _airdropTokenAmount,
        uint _duration,
        address _owner,
        address _feeRecipient,
        uint _whitelistCount,
        address _airdropFactory
    ) {
        airdropToken = _airdropToken;
        airdropTokenAmount = _airdropTokenAmount;
        duration = _duration;
        transferOwnership(_owner);
        feeRecipient = _feeRecipient;
        claimAmount = _airdropTokenAmount / _whitelistCount;
        airdropFactory = _airdropFactory;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function startAirdrop() public onlyOwner {
        require(!airdropOpen, "The airdrop is already open.");
        airdropOpen = true;
        startTime = block.timestamp;
        endTime = startTime + duration;
        emit AirdropStarted(startTime, endTime);
    }

    function claimAirdrop() external {
        require(airdropOpen, "The airdrop is not open.");
        require(
            block.timestamp <= endTime,
            "The airdrop has ended."
        );
        require(!claimed[msg.sender], "You have already claimed the airdrop.");
        require(checkIfWhitelisted(msg.sender), "You are not whitelisted.");
        claimed[msg.sender] = true;
        emit Claimed(msg.sender, claimAmount);
        require(
            airdropToken.transfer(msg.sender, claimAmount),
            "Transfer failed"
        );
    }

    function finalizeAirdrop() external {
        require(airdropOpen, "The airdrop is not open.");
        require(!airdropFinalized, "The airdrop has already been finalized.");
        require(
            block.timestamp > endTime,
            "The airdrop has not ended."
        );
        airdropFinalized = true;
        emit AirdropFinalized();
        uint unclaimedAmount = airdropToken.balanceOf(address(this));
        require(
            airdropToken.transfer(feeRecipient, unclaimedAmount),
            "Transfer failed"
        );
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function checkIfWhitelisted(address _user) internal view returns (bool) {
        AirdropFactory factory = AirdropFactory(airdropFactory);
        return factory.isAddressWhitelisted(_user);
    }

    //can use this to recalculate the claim amount if the whitelist changes
    //will have to build upon this
    function calculateClaimAmount(uint _whitelistLength) internal view returns (uint) {
        return airdropTokenAmount / _whitelistLength;
    }

    /* ========== VIEWS ========== */

    function getRemainingAirdropTokens() external view returns (uint) {
        return airdropToken.balanceOf(address(this));
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
/// @title Airdrop Factory Smart Contract
/// @author @m3tamorphTECH
/// @dev Factory contract to create airdrop contracts

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Airdrop.sol";

contract AirdropFactory is Ownable {
    /* ========== STATE VARIABLES ========== */

    uint public fee = 0.5 ether;
    address payable public feeRecipient;
    uint private airdropCount;
    uint private whitelistCount;
    mapping(address => bool) private isWhitelisted;

    /* ========== EVENTS ========== */

    event AirdropCreated(address airdropContract, IERC20 airdropToken);

    /* ========== MUTATIVE FUNCTIONS ========== */

    function createAirdrop(
        IERC20 _airdropToken,
        uint _airdropTokenAmount,
        uint _duration
    ) external payable returns(address){
        require(msg.value >= fee, "Insufficient fee");
        feeRecipient.transfer(fee);
        Airdrop airdropContract = new Airdrop(
            _airdropToken,
            _airdropTokenAmount,
            _duration,
            msg.sender,
            feeRecipient,
            whitelistCount,
            address(this)
        );
        address airdropContractAddress = address(airdropContract);
        airdropCount++;
        emit AirdropCreated(airdropContractAddress, _airdropToken);
        require(
            _airdropToken.transferFrom(
                msg.sender,
                airdropContractAddress,
                _airdropTokenAmount
            ),
            "Transfer failed"
        );
        return(airdropContractAddress);
    }

    /* ========== OWNER FUNCTIONS ========== */

    function whitelistAddresses(address[] calldata _users) external onlyOwner {
        uint length = _users.length;
        for (uint i; i < length; i++) {
            if(!isWhitelisted[_users[i]]) {
                isWhitelisted[_users[i]] = true;
                whitelistCount++;
            }
        }
    }

    function whitelistAddress(address _user) external onlyOwner {
        require(!isWhitelisted[_user], "Address is already whitelisted");
        isWhitelisted[_user] = true;
        whitelistCount++;
    }

    function removeWhitelistAddress(address _user) external onlyOwner {
        require(isWhitelisted[_user], "Address is not whitelisted");
        isWhitelisted[_user] = false;
        whitelistCount--;
    }

    function removeWhitelistAddresses(address[] calldata _users) external onlyOwner {
        uint length = _users.length;
        for (uint i; i < length; i++) {
            if(isWhitelisted[_users[i]]) {
                isWhitelisted[_users[i]] = false;
                whitelistCount--;
            }
        }
    }

    function updateFee(uint _fee) external onlyOwner {
        fee = _fee;
    }

    function updateFeeRecipient(
        address payable _feeRecipient
    ) external onlyOwner {
        feeRecipient = _feeRecipient;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function isAddressWhitelisted(address _address) public view returns (bool) {
        return isWhitelisted[_address];
    }

    function getWhitelistCount() public view returns (uint) {
        return whitelistCount;
    }

    function getAirdropCount() public view returns (uint) {
        return airdropCount;
    }
}
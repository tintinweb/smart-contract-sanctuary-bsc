/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

//SPDX-License-Identifier: MIT
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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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
}


pragma solidity ^0.8.0;

////import "@openzeppelin/contracts/access/Ownable.sol";

contract WhitelistPresale is Ownable { 
    
    /// @dev whitelisted users
    mapping(address => bool) whitelist;
    
    /**
     * @dev modifier to determine whitelisted users
     */
    modifier onlyWhitelisted() {
        require(isWhitelisted(_msgSender()), "Whitelist: User is not whitelisted!");
        _;
    }

    /**
     * @dev returns whether a recepient is whitelisted or not
     * @param _recepient user address
     */
    function isWhitelisted(address _recepient) public view returns(bool) {
        return whitelist[_recepient];
    }

    /**
     * @dev adds a user to whitelist
     */
    function addWhitelist(address _recepient) external onlyOwner {
        require(_recepient != address(0), "Whitelisted address cannot be address 0!");
        whitelist[_recepient] = true;
    }

    /**
     * @dev adds multiple accounts to whitelist
     * @param _recepients array of addresses of corresponding recepients
     */
    function addWhiteListMult(address[] memory _recepients) external onlyOwner {
        for(uint i=0; i < _recepients.length; i++) {
            whitelist[_recepients[i]] = true;
        }
    }
    
}


pragma solidity ^0.8.0;

////import "./WhitelistPresale.sol";
////import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author tg: @ghesthauss
 * @dev Crowdsale contract for RENS token.
 * Emission: default
 * Distribution: PostDelivery(Vested)
 * Price: fixed-rate
 * Validation: Timed + Whitelist + Capped + IndividuallyCapped
 */

contract RENSPresaleWhitelist is WhitelistPresale {
    // tokens bought
    mapping(address => uint256) totalAllocations;
    mapping(address => uint256) claimed;

    IERC20 token;
    IERC20 busd;
    // Individually capped
    uint256 public minCap; //in wei - busd
    uint256 public maxCap; //in wei - busd
    uint64 public openingTime; // uint64 epoch seconds
    uint64 public closingTime; // uint64 epoch seconds
    uint256 public rate = 25; //token buy rate
    address wallet;
    uint64 public vestingStart; // vesting start
    uint64 public cliff;
    uint64 public vestingDuration; // vesting duration
    uint256 public hardCap; // Hardcap in busd amount
    uint256 public totalRaised; //total funds raised

    constructor(
        IERC20 _token,
        IERC20 _busd,
        uint256 _minCap,
        uint256 _maxCap,
        uint64 _openingTime,
        uint64 _closingTime,
        address _wallet,
        uint64 _vestingStart,
        uint64 _cliff,
        uint64 _vestingDuration,
        uint256 _hardCap
    ) {
        token = _token;
        busd = _busd;
        minCap = _minCap;
        maxCap = _maxCap;
        openingTime = _openingTime;
        closingTime = _closingTime;
        wallet = _wallet;
        vestingStart = _vestingStart;
        cliff = _cliff;
        vestingDuration = _vestingDuration;
        hardCap = _hardCap;
    }

    function buyTokens(uint256 _amount) external onlyWhitelisted {
        totalRaised += _amount;
        // Calculate tokens to allocate
        uint256 _tokenAmount = calcTokens(_amount);
        // Check if hardcap if reached
        require(totalRaised < hardCap, "Hardcap reached!");
        // Individually cap buy limit
        uint256 _contribution = totalAllocations[_msgSender()] / rate;
        require(
            (_amount >= minCap) && ((_contribution + _amount) <= maxCap),
            "Buy amount is too low or too high!"
        );
        // Buying must be during open dates
        require(
            (uint64(block.timestamp) > openingTime) &&
                (uint64(block.timestamp) < closingTime),
            "Presale is not open or ended!"
        );
        // Check if the recepient sent the price
        bool sent = busd.transferFrom(_msgSender(), wallet, _amount);
        require(sent, "Transfer failed!");
        // Add the amount of tokens bought
        totalAllocations[_msgSender()] += _tokenAmount;
    }

    function tokenAlloc(address _beneficiary) external view returns (uint256) {
        return totalAllocations[_beneficiary];
    }

    /**
     *@dev calculates token amount based on rate
     */
    function calcTokens(uint256 _wei) internal view returns (uint256) {
        uint256 tokenAmount = _wei * rate;
        return tokenAmount;
    }

    /**
     * default linear vesting schedule
     */
    function _vestingSchedule(uint64 timestamp)
        internal
        view
        returns (uint256)
    {
        if (timestamp < vestingStart) {
            return 0;
        } else if (timestamp > vestingStart + vestingDuration) {
            return totalAllocations[_msgSender()];
        } else {
            return
                (totalAllocations[_msgSender()] * (timestamp - vestingStart)) /
                vestingDuration;
        }
    }

    function claim() external {
        require(block.timestamp > cliff, "Vesting has not started yet!");
        uint256 releasable = _vestingSchedule(uint64(block.timestamp)) -
            claimed[_msgSender()];
        claimed[_msgSender()] += releasable;
        token.transfer(_msgSender(), releasable);
    }

    function recoverERC20() external onlyOwner {
        require(
            block.timestamp > closingTime,
            "Can't recover before closing time"
        );
        uint256 amount_ = token.balanceOf(address(this));
        uint256 recAmount = amount_ - (totalRaised * rate);
        token.transferFrom(address(this), wallet, recAmount);
    }
}
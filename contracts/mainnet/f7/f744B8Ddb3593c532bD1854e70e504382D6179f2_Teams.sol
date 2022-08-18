/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: contracts/Teams.sol

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;



abstract contract Manageable is Ownable {
    mapping(address => bool) private _managers;
    event ManagerAdded(address indexed manager_);

    constructor() {}

    event ManagerRemoved(address indexed manager_);

    function managers(address manager_) public view virtual returns (bool) {
        return _managers[manager_];
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Manageable: caller is not the owner");
        _;
    }

    function removeManager(address manager_) public virtual onlyOwner {
        _managers[manager_] = false;
        emit ManagerRemoved(manager_);
    }

    function addManager(address manager_) public virtual onlyOwner {
        require(
            manager_ != address(0),
            "Manageable: new owner is the zero address"
        );
        _managers[manager_] = true;
        emit ManagerAdded(manager_);
    }
}

interface IManager {
    function compoundHelper(
        uint256 id,
        uint256 externalRewards,
        address user
    ) external;
    function getNetDeposit(address user) external returns (int256);
}

contract Teams is Ownable, Manageable {
    address payable public BANK;
    address public MARKETING_WALLET;
    IERC20 public TOKEN;
    address public POOL;
    IManager public MANAGER;

    uint256 changeTeamCost = 0.25 ether;
    uint256 claimFee = 3000;
    uint256 compoundFee = 0;

    mapping(address => address) public referrers;
    mapping(address => address[]) public referred;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public claimedRewards;
    mapping(address => bool) public isExcludedFromFee;

    constructor(
        address payable bank,
        address marketing,
        address token,
        address pool,
        address manager
    ) {
        BANK = bank;
        MARKETING_WALLET = marketing;
        TOKEN = IERC20(token);
        POOL = pool;
        MANAGER = IManager(manager);
    }

    function getReferrer(address user) public view returns (address) {
        return
            referrers[user] == address(0) ? MARKETING_WALLET : referrers[user];
    }

    function getReferred(address user) public view returns(address[] memory) {
        return referred[user];
    }


    function availableRewards(address user) public view returns (uint256) {
        return rewards[user] - claimedRewards[user];
    }

    function joinTeam(address referrer) public payable {
        require(referrer != _msgSender(), "JOIN: Can't join yourself...");
        if (getReferrer(_msgSender()) != MARKETING_WALLET) {
            require(
                msg.value == changeTeamCost,
                "JOIN: You must pay the change fee."
            );
        }

        if (address(this).balance > 0) {
            BANK.transfer(address(this).balance);
        }

        address temp = referrers[_msgSender()];

        if (temp != address(0)) {
            address[] memory tempReferred = referred[temp];
            for (uint256 i = 0; i < tempReferred.length; i++) {
                if (tempReferred[i] == _msgSender()) {
                    tempReferred[i] = tempReferred[tempReferred.length - 1];
                    delete tempReferred[tempReferred.length - 1];
                    referred[temp] = tempReferred;
                    break;
                }
            }
        }

        referrers[_msgSender()] = referrer;
        referred[referrer].push(_msgSender());
    }

    function claimRewards() public {
        uint256 availableRewards_ = availableRewards(_msgSender());
        require(availableRewards_ > 0, "CLAIM: No rewards");
        claimedRewards[_msgSender()] += availableRewards_;
        uint256 fee = (availableRewards_ * claimFee) / 10000;
        availableRewards_ -= fee;
        TOKEN.transferFrom(POOL, _msgSender(), availableRewards_);
    }

    function compoundRewards(uint256[] memory ids) public {
        uint256 availableRewards_ = availableRewards(_msgSender());
        require(availableRewards_ > 0, "CLAIM: No rewards");
        claimedRewards[_msgSender()] += availableRewards_;
        uint256 rewardsPerNode = availableRewards_ / ids.length;
        for (uint256 i = 0; i < ids.length; i++) {
            MANAGER.compoundHelper(ids[i], rewardsPerNode, _msgSender());
        }
    }

    function addRewardsToReferrer(address user, uint256 amount) public onlyManager {
        address who = getReferrer(user);
        if(MANAGER.getNetDeposit(user) >= 0) who = MARKETING_WALLET;
        rewards[who] += amount;
    }

    function addRewards(address user, uint256 amount) public onlyManager {
        if(MANAGER.getNetDeposit(user) >= 0) user = MARKETING_WALLET;
        rewards[user] += amount;
    }

    function setRewards(address user, uint256 amount) public onlyOwner {
        rewards[user] = amount;
    }

    function setBank(address payable bank) public onlyOwner {
        BANK = bank;
    }

    function setToken(address token) public onlyOwner {
        TOKEN = IERC20(token);
    }

    function setPool(address pool) public onlyOwner {
        POOL = pool;
    }

    function setMarketing(address marketing) public onlyOwner {
        MARKETING_WALLET = marketing;
    }

    function setManager(address manager) public onlyOwner {
        MANAGER = IManager(manager);
    }

    function setTeam(address user, address referrer) public onlyOwner {
        referrers[user] = referrer;
        referred[referrer].push(user);
    }

    function setChangeTeamCost(uint256 amount) public onlyOwner {
        changeTeamCost = amount;
    }

    function setIsExcludedFromFee(address user, bool value) public onlyOwner {
        isExcludedFromFee[user] = value;
    }

    function setClaimFee(uint256 amount) public onlyOwner {
        claimFee = amount;
    }

    function setCompoundFee(uint256 amount) public onlyOwner {
        compoundFee = amount;
    }
}
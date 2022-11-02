import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IRewardsVault.sol";

interface Pool {
    
    struct UserInfo {
        uint256 totalStaked;
        uint256 bnbRewardDebt;
        uint256 totalBNBCollected;
    } 

    function userInfo(address key) view external returns (UserInfo memory);

    function accDepositBNBRewardPerShare (  ) external view returns ( uint256 );
    
    function bnbRewardBalance (  ) external view returns ( uint256 );

    function totalDeposited (  ) external view returns ( uint256 );

    function totalBNBCollected (  ) external view returns ( uint256 );

}

contract DogPoundLinearPool is Ownable, ReentrancyGuard {
    uint256 public accDepositBNBRewardPerShare = 0;
    uint256 public totalDeposited = 0;
    uint256 public bnbRewardBalance = 0;
    uint256 public totalBNBCollected = 0;
    bool public vaultPay = false;
    bool public initializeUnpaused = true;
    bool public managerNotLocked = true;
    IERC20 public DogsToken;
    IRewardsVault public rewardsVault;

    address public DogPoundManger;

    struct UserInfo {
        uint256 totalStaked;
        uint256 bnbRewardDebt;
        uint256 totalBNBCollected;
    }

    mapping(address => UserInfo) public userInfo;

    receive() external payable {}

    // Modifiers
    modifier onlyDogPoundManager() {
        require(DogPoundManger == msg.sender, "manager only");
        _;
    }

    constructor(address _DogPoundManger, address _rewardsVaultAddress) {
        rewardsVault = IRewardsVault(_rewardsVaultAddress);
        DogPoundManger = _DogPoundManger;
    }

    function initializeVars(DogPoundLinearPool _pool) onlyOwner public {
        require(initializeUnpaused);
        DogPoundLinearPool pool = DogPoundLinearPool(_pool);
        accDepositBNBRewardPerShare = pool.accDepositBNBRewardPerShare();
        totalDeposited =  pool.totalDeposited();
        bnbRewardBalance = pool.bnbRewardBalance();
        totalBNBCollected = pool.totalBNBCollected();
    }

    function initialize(DogPoundLinearPool _pool, address [] memory _users) onlyOwner public {
        require(initializeUnpaused);
        DogPoundLinearPool pool = DogPoundLinearPool(_pool);
        for(uint i = 0; i < _users.length; i++){
            (uint256 totalStaked, uint256 bnbRewardDebt, uint256 _totalBNBCollected ) =  pool.userInfo(_users[i]);
            userInfo[_users[i]].totalStaked =  totalStaked;
            userInfo[_users[i]].bnbRewardDebt =  bnbRewardDebt;
            userInfo[_users[i]].totalBNBCollected =  _totalBNBCollected;
        }
    }


    function initializeM(DogPoundLinearPool _pool, address [] memory _users, UserInfo [] memory _info) onlyOwner public {
        require(initializeUnpaused);
        DogPoundLinearPool pool = DogPoundLinearPool(_pool);
        accDepositBNBRewardPerShare = pool.accDepositBNBRewardPerShare();
        for(uint i = 0; i <= _users.length; i++){
            userInfo[_users[i]] = _info[i];
        }
    }


    function deposit(address _user, uint256 _amount)
        external
        onlyDogPoundManager
        nonReentrant
    {
        if (vaultPay) {
            rewardsVault.payoutDivs();
        }
        UserInfo storage user = userInfo[_user];
        updatePool();
        uint256 bnbPending = payPendingBNBReward(_user);
        totalDeposited += _amount;
        user.totalBNBCollected += bnbPending;
        user.totalStaked += _amount;
        user.bnbRewardDebt = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24);
        if (bnbPending > 0) {
            payable(_user).transfer(bnbPending);
        }
    }

    function withdraw(address _user, uint256 _amount)
        external
        onlyDogPoundManager
        nonReentrant
    {
        if (vaultPay) {
            rewardsVault.payoutDivs();
        }
        UserInfo storage user = userInfo[_user];
        updatePool();
        uint256 bnbPending = payPendingBNBReward(_user);
        DogsToken.transfer(address(DogPoundManger), _amount); // must handle receiving in DogPoundManger
        user.totalBNBCollected += bnbPending;
        user.totalStaked -= _amount;
        totalDeposited -= _amount;
        user.bnbRewardDebt = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24);
        if (bnbPending > 0) {
            payable(_user).transfer(bnbPending);
        }
    }

    function updatePool() public {
        if (totalDeposited > 0) {
            uint256 bnbReceived = checkBNBRewardsReceived();
            if (bnbReceived > 0) {
                accDepositBNBRewardPerShare =
                    accDepositBNBRewardPerShare +
                    ((bnbReceived * 1e24) / totalDeposited);
                totalBNBCollected += bnbReceived;
            }
        }
    }

    // Pay pending BNB from the DOGS staking reward scheme.
    function payPendingBNBReward(address _user) internal returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 bnbPending = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24) - user.bnbRewardDebt;
        if (bnbRewardBalance < bnbPending) {
            bnbPending = bnbRewardBalance;
            bnbRewardBalance = 0;
        } else if (bnbPending > 0) {
            bnbRewardBalance = bnbRewardBalance - bnbPending;
        }
        return bnbPending;
    }

    function pendingBNBReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 bnbPending = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24) - user.bnbRewardDebt;
        return bnbPending;
    }

    function claim() public nonReentrant {
        if (vaultPay) {
            rewardsVault.payoutDivs();
        }
        updatePool();
        uint256 bnbPending = payPendingBNBReward(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        user.totalBNBCollected += bnbPending;
        user.bnbRewardDebt = ((user.totalStaked * accDepositBNBRewardPerShare) /
            1e24);
        if (bnbPending > 0) {
            payable(msg.sender).transfer(bnbPending);
        }
    }

    function checkBNBRewardsReceived() internal returns (uint256) {
        uint256 totalBNBBalance = address(this).balance;
        if (totalBNBBalance == 0) {
            return 0;
        }

        uint256 bnbReceived = totalBNBBalance - bnbRewardBalance;
        bnbRewardBalance = totalBNBBalance;

        return bnbReceived;
    }

    function setVaultPay(bool _bool) external onlyOwner {
        vaultPay = _bool;
    }

    function switchRewardVault(address _newvault) external onlyOwner {
        rewardsVault = IRewardsVault(_newvault);
    }

    function pauseInitialize() external onlyOwner {
        initializeUnpaused = false;
    }

    function setDogsToken(address _address) public onlyOwner {
        DogsToken = IERC20(_address);
    }
    
    function lockDogPoundManager() external onlyOwner{
        managerNotLocked = false;
    }

    function setDogPoundManager(address _address) public onlyOwner {
        require(managerNotLocked);
        DogPoundManger = _address;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRewardsVault {

    function payoutDivs()
    external;

}

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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PaymentGateway is Ownable {
    struct App {
        address owner;
        address wallet;
        uint fee; //x 10000
        uint parent;
    }
    event Paid(uint appId, address token, uint paymentId, uint256 amount);
    event AppCreated(uint parentId, uint appId, address owner, address wallet, uint fee);
    event AppWalletChanged(uint appId, address wallet);
    event AppDeleted(uint appId);
    event Collected(address token, address to, uint256 amount);

    mapping(uint => App) private _appById;
    mapping(address => uint) public _feeForDev;

    uint public _defaultFee;
    
    uint private _nonce;

    constructor() {
        _defaultFee = 300;// 3%
        _nonce = 0;
    }

    function payToken(uint appId, uint paymentId, uint256 amount, address dev, address token) public {
        require(amount > 0, "Amount must greater than zero");
        require(_appById[appId].owner != address(0), "App not existed");
        require(token != address(0), "Token must not null");
        
        uint fee = amount * _appById[appId].fee / 10000;
        uint devFee = amount * _feeForDev[dev] / 10000;
        if (devFee > fee) {
            devFee = fee;
        }
        IERC20 erc20 = IERC20(token);
        if (devFee > 0) {
            erc20.transferFrom(_msgSender(), dev, devFee);    
        }
        if (fee - devFee > 0) {
            erc20.transferFrom(_msgSender(), address(this), fee - devFee);
        }
        erc20.transferFrom(_msgSender(), _appById[appId].wallet, amount - fee);
        emit Paid(appId, token, paymentId, amount);
    }

    function payCoin(uint appId, uint paymentId, uint256 amount, address dev) payable public {
        require(amount > 0, "Amount must greater than zero");
        require(_appById[appId].owner != address(0), "App not existed");
        require(amount == msg.value, "Transfer different value");
        
        uint fee = amount * _appById[appId].fee / 10000;
        uint devFee = amount * _feeForDev[dev] / 10000;
        if (devFee > fee) {
            devFee = fee;
        }
        payable(_appById[appId].wallet).transfer(amount - fee);
        if (devFee > 0) {
            payable(dev).transfer(devFee);
        }
        emit Paid(appId, address(0), paymentId, amount);
    }

    function createApp(uint parentId, address wallet) public {
        require(wallet != address(0), "Receiver's wallet must not null");
        _nonce++;
        _appById[_nonce] = App({
            parent: parentId,
            owner:_msgSender(),
            wallet: wallet,
            fee: _defaultFee
        });
        emit AppCreated(parentId, _nonce, _msgSender(), wallet, _defaultFee); 
    }

    function getApp(uint appId) public view returns (App memory) {
        return _appById[appId];
    }

    function updateAppWallet(uint appId, address wallet) public {
        require(_appById[appId].owner == _msgSender(), "Only owner can change wallet");
        require(_appById[appId].wallet != wallet, "Wallet must be different");
        require(address(0) != wallet, "Receiver's wallet must not null");
        _appById[appId].wallet = wallet;
        emit AppWalletChanged(appId, wallet);
    }

    function transferToken(address token, address to, uint256 amount) public onlyOwner {
        require(token != address(0), "Token must not be null");
        require(to != address(0), "Receiver must not be null");
        require(amount > 0, "Amount must greater than zero");
        IERC20(token).transfer(to, amount);
        emit Collected(token, to, amount);
    }
    
    function transferCoin(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Receiver must not be null");
        require(amount > 0, "Amount must greater than zero");
        payable(to).transfer(amount);
        emit Collected(address(0), to, amount);
    }

    function setFee(uint appId, uint fee) public onlyOwner {
        require(fee < 10000, "Fee must be smaller than 10000");
        require(_appById[appId].fee != fee, "Fee must be different");
        _appById[appId].fee = fee;
    }

    function setDevFee(address dev, uint fee) public onlyOwner {
        require(dev != address(0), "Dev must not be null");
        require(fee < _defaultFee, "Dev fee must be smaller than default fee");
        _feeForDev[dev] = fee;
    }

    function setDefaultFee(uint fee) public onlyOwner {
        require(fee < 10000, "Fee must be smaller than 10000");
        _defaultFee = fee;
    }

    function deleteApp(uint appId) public {
        require(_appById[appId].owner == _msgSender() || owner() == _msgSender(), "Only app owner or admin can delete app");
        _appById[appId].owner = address(0);
        _appById[appId].wallet = address(0);
        _appById[appId].fee = 0;
        _appById[appId].parent = 0;
        emit AppDeleted(appId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT
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

// File: Flash/FlashPool.sol


pragma solidity ^0.8.0;



contract FlashPool is Ownable {
    uint256 public minQuantity;
    uint256 public maxQuantity;

    uint256 public amountMGFA;
    uint256 public amountExtraUSDT;
    uint256 public amountOriginalUSDT;

    address public extraUSDTPool;

    address public MGFA;
    address public USDT;

    uint256 lockPeriod = 86400;

    address public dead = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) public nonces;

    struct Package {
        address owner;
        uint256 quantity;

        uint256 amountMGFA;
        uint256 amountExtraUSDT;
        uint256 amountOriginalUSDT;
        uint256 releaseAfter;
        uint8 state;
    }

    uint256 count;
    mapping(uint256 => Package) packages;
    mapping(address => uint256) quantities;

    event Deposit(uint256 id, address indexed owner, uint256 quantity, uint256 amountMGFA, uint256 amountExtraUSDT, uint256 amountOriginalUSDT);
    event Redeem(uint256 id);
    event Release(uint256 id);

    constructor(address _extraUSDTPool) {
        extraUSDTPool = _extraUSDTPool;

        minQuantity = 1;
        maxQuantity = 100;

        amountMGFA = 50 * 10 ** 18;
        amountExtraUSDT = 0 * 10 ** 18;
        amountOriginalUSDT = 500 * 10 ** 18;
    }

    function setMinMaxQuantity(uint256 _minQuantity, uint256 _maxQuantity) public onlyOwner {
        minQuantity = _minQuantity;
        maxQuantity = _maxQuantity;
    }

    function setDepositAmount(uint256 _amountMGFA, uint256 _amountExtraUSDT, uint256 _amountOriginalUSDT) public onlyOwner {
        amountMGFA = _amountMGFA;
        amountExtraUSDT = _amountExtraUSDT;
        amountOriginalUSDT = _amountOriginalUSDT;
    }

    function setExtraUSDTPool(address _pool) public onlyOwner {
        extraUSDTPool = _pool;
    }

    function setMGFAAndUSDT(address _MGFA, address _USDT) public onlyOwner {
        MGFA = _MGFA;
        USDT = _USDT;
    }

    function setLockPeriod(uint256 _lockPeriod) public onlyOwner {
        lockPeriod = _lockPeriod;
    }

    function withdraw(address _recipient, uint256 _amount) public onlyOwner {
        IERC20 usdt = IERC20(USDT);
        usdt.transfer(_recipient, _amount);
    }

    function deposit(uint256 _quantity) public {
        require(quantities[msg.sender] + _quantity >= minQuantity, "Less than the minimum allowed purchase quantity");
        require(quantities[msg.sender] + _quantity <= maxQuantity, "More than the maximum allowed purchase quantity");

        IERC20 mgfa = IERC20(MGFA);
        IERC20 usdt = IERC20(USDT);

        mgfa.transferFrom(msg.sender, dead, _quantity * amountMGFA / 2);
        mgfa.transferFrom(msg.sender, address(this), _quantity * amountMGFA / 2);


        if (amountExtraUSDT != 0) {
            usdt.transferFrom(msg.sender, extraUSDTPool, _quantity * amountExtraUSDT);
        }
        usdt.transferFrom(msg.sender, address(this), _quantity * amountOriginalUSDT);

        packages[count] = Package(msg.sender, _quantity, _quantity * amountMGFA, _quantity * amountExtraUSDT, _quantity * amountOriginalUSDT, 0, 0);
        emit Deposit(count, msg.sender, _quantity, _quantity * amountMGFA, _quantity * amountExtraUSDT, _quantity * amountOriginalUSDT);

        count ++;
        quantities[msg.sender] += _quantity;
    }

    function redeem(uint256 _id) public {
        Package storage package = packages[_id];

        require(msg.sender == package.owner);
        require(package.state == 0);

        IERC20 mgfa = IERC20(MGFA);
        
        mgfa.transfer(package.owner, package.amountMGFA / 2);

        package.state = 1;
        package.releaseAfter = block.timestamp + lockPeriod;
        quantities[msg.sender] -= package.quantity;

        emit Redeem(_id);
    }

    function release(uint256 _id) public {
        Package storage package = packages[_id];

        require(package.state == 1);
        require(package.releaseAfter < block.timestamp);

        IERC20 usdt = IERC20(USDT);

        usdt.transfer(package.owner, package.amountOriginalUSDT);
        package.state = 2;

        emit Release(_id);
    }

}
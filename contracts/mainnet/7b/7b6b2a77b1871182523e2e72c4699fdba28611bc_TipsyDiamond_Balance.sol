/**
 *Submitted for verification at BscScan.com on 2022-07-07
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: contracts/DiscordBotTricker.sol


// Super basic contract to combine TipsyCoin + TipsyStake balance for TipsyDiamond checks

pragma solidity ^0.8.0;




interface ITipsyStakeBal {
    function getUserBal(address user) external view returns (uint);
}

contract TipsyDiamond_Balance is IERC20, IERC20Metadata, Ownable {

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;
    address public tipsyCoin;
    address public tipsyStake;
    //100mill = 100e6 * 1e18 == 100e24
    uint public tipsyDiamondMin = 100e24;

    constructor (address _tipsyCoin, address _tipsyStake)
    {
        _symbol = "$tipsy";
        _name = "TipsyCoin";
        _decimals = 18;
        _totalSupply = ~uint256(0);
        tipsyCoin = _tipsyCoin;
        tipsyStake = _tipsyStake;

    }

    function setTipsyCoinAddress(address newAddy) onlyOwner public returns (address) 
    {
        tipsyCoin = newAddy;
        return tipsyCoin;
    }

    function setTipsyStakeAddress(address newAddy) onlyOwner public returns (address) 
    {
        tipsyStake = newAddy;
        return tipsyStake;
    }


    function setTipsyDiamondMin(uint newAmount) onlyOwner public returns (uint)
    {
        tipsyDiamondMin = newAmount;
        return tipsyDiamondMin;
    }

    function name(
    ) public view returns (string memory)
    {
        return _name;
    }

    function symbol(
    ) public view returns (string memory)
    {
        return _symbol;
    }

        function decimals(
    ) public view returns (uint8)
    {
        return _decimals;
    }
    function totalSupply(
    ) public view returns (uint256)
    {
        return _totalSupply;
    }

        function balanceOf(address account) public view returns (uint256)
    {
        uint comboBalance = IERC20(tipsyCoin).balanceOf(account) + ITipsyStakeBal(tipsyStake).getUserBal(account);
        return comboBalance;
    }

    function isDiamond(address account) public view returns (bool)
    {
        uint comboBalance = IERC20(tipsyCoin).balanceOf(account) + ITipsyStakeBal(tipsyStake).getUserBal(account);
        return comboBalance >= tipsyDiamondMin;
    }

    function approve(
       address _spender, 
       uint256 _value
    ) public override
      returns (bool) 
    {
        revert("Balance + Stake balance viewer only, you may not transfer");
        return true;
   }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        revert("Balance + Stake balance viewer only, you may not transfer");
        return true;
    }

    function allowance(
        address _owner, 
        address _spender
    ) public override view 
      returns (uint256) 
    {
        return ~uint256(0);
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {
        revert("Balance + Stake balance viewer only, you may not transfer");
        return true;
    }

}
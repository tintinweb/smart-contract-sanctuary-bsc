//SPDX-License-Identifier: Unlicensed
//Author: Luiz Hemerly

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract tokenPresale is Ownable {

	IERC20 public buyToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
	address public recipient = 0xd8Fb75B1f1392eC07CBCA8262385908CA3411DBf;

	bool public isPresale;
	bool public isWhitelist;

	mapping(address => uint) public buys;
	mapping(address => bool) public whitelist;

	uint public minBuy = 82*10e17;
	uint public maxBuy = 830*10e17;
	uint public softcap;
	uint public hardcap = 400000*10e17;
	uint public totalSales;

	event buyLog(address who, uint amount);

	constructor() {
	}

	function buyTokens(uint amount) external {
		require(isPresale, "SafeHash Presale: No presale right now.");
		require(amount >= minBuy, "SafeHash Presale: Amount too low.");
		require(amount <= maxBuy, "SafeHash Presale: Amount too high.");
		if (isWhitelist){
            require(whitelist[msg.sender], "SafeHash Presale: You are not in the whitelist.");
        }
		totalSales += amount;
		require(totalSales <= hardcap, "SafeHash Presale: Hardcap reached.");
		buys[msg.sender] += amount;
		buyToken.transferFrom(msg.sender, recipient, amount);
		emit buyLog(msg.sender, amount);
	}

	function setWhitelist(address[] memory who, bool set) external onlyOwner{
        for(uint i=0; i<who.length; i++){
            whitelist[who[i]] = set;
        }
    }

    function tooglePreSale() external onlyOwner{
        isPresale = !isPresale;
    }

    function toogleWhitelist() external onlyOwner{
        isWhitelist = !isWhitelist;
    }

	function withdrawToken(uint amount_, address token_) external onlyOwner {
		IERC20 _token = IERC20(token_);
		_token.transfer(msg.sender, amount_);
	}

	function withdrawEth(uint amount_) external onlyOwner {
		payable(msg.sender).transfer(amount_);
	}

	function setMin(uint amount) external onlyOwner {
		minBuy = amount;
	}

	function setMax(uint amount) external onlyOwner {
		maxBuy = amount;
	}

	function setSoftcap(uint amount) external onlyOwner {
		softcap = amount;
	}

	function setHardcap(uint amount) external onlyOwner {
		hardcap = amount;
	}

	function setRecipient(address recipient_) external onlyOwner{
		recipient = recipient_;
	}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
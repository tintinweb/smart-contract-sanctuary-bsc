// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IStreAMMDiscountedTrading.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/**
 * @title StreAMMDiscountedTrading
 * @dev Handels balances of discounted trading rights. Discounted trading right can
 * be purchased with given token for a given price to trade discounted on streAMM.
 */
contract StreAMMDiscountedTrading is Ownable, IStreAMMDiscountedTrading {
    address public immutable factory; //address of the factory

    address public token; //address of the token to be used for payment
    address public tokenReceiver; //receiver of paid tokens
    uint256 public pricePerTrade; //absolute price per discounted trade

    mapping(address => uint8) public discountedTrades; //discounted trades for specific address

    event UpdateTrades(address indexed trader, uint8 trades);

    /**
     * @dev Initially setting addresses in the constructor
     * @param _factory the address of the factory contract
     * @param _token the address of the payment token contract
     * @param _tokenReceiver the address of the payment token receiver
     * @param _pricePerTrade the absolute price per discounted trade
     */
    constructor(
        address _factory,
        address _token,
        address _tokenReceiver,
        uint256 _pricePerTrade
    ) {
        require(
            _factory != address(0) && _token != address(0) && _tokenReceiver != address(0),
            'StreAMMDiscountedTrading: Zero address'
        );
        require(_pricePerTrade > 0, 'StreAMMDiscountedTrading: Invalid price');

        factory = _factory;
        token = _token;
        tokenReceiver = _tokenReceiver;
        pricePerTrade = _pricePerTrade;
    }

    /**
     * @dev get credits for discounted trades by paying with token
     * @param trader the address of the trader
     * @param amount the number of desired trades
     * @param tradePrice the desired buy price per trade
     */
    function purchaseDiscountedTrades(
        address trader,
        uint8 amount,
        uint256 tradePrice
    ) external {
        require(trader != address(0), 'StreAMMDiscountedTrading: Zero address');
        require(amount > 0, 'StreAMMDiscountedTrading: Invalid amount');
        // preventing race conditions
        require(tradePrice == pricePerTrade, 'StreAMMDiscountedTrading: Invalid price');

        require(
            IERC20(token).transferFrom(msg.sender, tokenReceiver, pricePerTrade * amount),
            'StreAMMDiscountedTrading: Transfer failed'
        );
        discountedTrades[trader] += amount;
        emit UpdateTrades(trader, amount);
    }

    /**
     * @dev returns if a trader has credits for discounted trading left
     * @param trader the address of the trader
     */
    function hasDiscountedTrades(address trader) external view override returns (bool) {
        return discountedTrades[trader] > 0;
    }

    /**
     * @dev decreases the credits for a trader by factory
     * @param trader the address of the trader
     */
    function decreaseTrades(address trader) external override {
        require(msg.sender == factory, 'StreAMMDiscountedTrading: FORBIDDEN');
        require(discountedTrades[trader] > 0, 'StreAMMDiscountedTrading: Has no trades');
        discountedTrades[trader]--;
        emit UpdateTrades(trader, discountedTrades[trader]);
    }

    /**
     * @dev set the payment token address by contract owner
     * @param _token address of the new payment token
     */
    function setToken(address _token) external onlyOwner {
        require(_token != address(0), 'StreAMMDiscountedTrading: Zero address');
        token = _token;
    }

    /**
     * @dev set the payment token receiver address by contract owner
     * @param _tokenReceiver address of the new payment token receiver
     */
    function setTokenReceiver(address _tokenReceiver) external onlyOwner {
        require(_tokenReceiver != address(0), 'StreAMMDiscountedTrading: Zero address');
        tokenReceiver = _tokenReceiver;
    }

    /**
     * @dev set absolute price for a discounted trade by contract owner
     * @param _pricePerTrade absolute value for discounted trade price
     */
    function setPricePerTrade(uint256 _pricePerTrade) external onlyOwner {
        pricePerTrade = _pricePerTrade;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @dev Interface of the StreAMMDiscountedTrading contract
 */
interface IStreAMMDiscountedTrading {
    /**
     * @dev returns if a given trader has discounted trades balance
     */
    function hasDiscountedTrades(address trader) external view returns (bool);

    /**
     * @dev decreases the discounted trades balance by one
     */
    function decreaseTrades(address trader) external;
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
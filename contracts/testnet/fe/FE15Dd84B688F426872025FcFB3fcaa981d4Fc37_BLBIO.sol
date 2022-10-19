// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";


/**
 * @title BLB Initial Offering
 *
 * @dev BLB Token is offered in BNB, BUSD and USDT.
 * @dev the prices are set in USD and calculated to corresponding BNB in 
 *   every buy transaction via chainlink price feed aggregator.
 * @dev since solidity does not support floating variables, all prices are
 *   multiplied by 10^18 to embrace decimals.
 */
contract BLBIO is Ownable {

    //price feed aggregator
    AggregatorInterface immutable AGGREGATOR_BUSD_BNB;

    IERC20 public BLB;
    IERC20 public BUSD;

    /**
     * @return price of the token in USD.
     *
     * @notice multiplied by 10^18.
     */
    uint256 public priceInUSD;


    /**
     * @dev emits when a user buys BLB, paying in BNB.
     */
    event BuyInBNB(uint256 indexed amountBLB, uint256 indexed amountBNB);

    /**
     * @dev emits when a user buys BLB, paying in BUSD.
     */
    event BuyInBUSD(uint256 indexed amountBLB, uint256 indexed amountBUSD);

    /**
     * @dev emits when the owner sets a new price for the BLB token (in USD).
     */
    event SetPriceInUSD(uint256 indexed newPrice);

    /**
     * @dev emits when the owner withdraws any amount of BNB or ERC20 token.
     *  
     * @notice if the withdrawing token is BNB, tokenAddr equals address zero.
     */
    event Withdraw(address indexed tokenAddr, uint256 indexed amount);


    constructor(
    ) {
        BLB = IERC20(0x134341a04B11B1FD697Fc57Eab7D96bDbcdEa414); 
        BUSD = IERC20(0xCd57b180aeA8B61C7b273785748988A3A8eAb9c2);
        AGGREGATOR_BUSD_BNB = AggregatorInterface(0x0630521aC362bc7A19a4eE44b57cE72Ea34AD01c);
        setPriceInUSD(10 ** 18);
    }


    /**
     * @return price of the token in BNB corresponding to the USD price.
     *
     * @notice multiplied by 10^18.
     */
    function priceInBNB() public view returns(uint256) {
        return uint256(AGGREGATOR_BUSD_BNB.latestAnswer())
            * priceInUSD
            / 10 ** 18;
    }


    /**
     * @dev buy BLB Token paying in BNB.
     *
     * @notice multiplied by 10^18.
     * @notice maximum tolerance 2%.
     *
     * @notice requirement:
     *   - there must be sufficient BLB token in ICO.
     *   - required amount must be paid in BNB.
     *
     * @notice emits a BuyInBNB event
     */
    function buyInBNB(uint256 amount) public payable {
        require(msg.value >= amount * priceInBNB() * 98 / 10**20, "insufficient fee");
        require(BLB.balanceOf(address(this)) >= amount, "insufficient BLB in the contract");
        BLB.transfer(msg.sender, amount);
        emit BuyInBNB(amount, msg.value);
    }

    /**
     * @dev buy BLB Token paying in BUSD.
     *
     * @notice multiplied by 10^18.
     *
     * @notice requirement:
     *   - there must be sufficient BLB token in ICO.
     *   - Buyer must approve the ICO to spend required BUSD.
     *
     * @notice emits a BuyInBUSD event
     */
    function buyInBUSD(uint256 amount) public {
        require(BLB.balanceOf(address(this)) >= amount, "insufficient BLB in the contract");
        uint256 payableBUSD = priceInUSD * amount / 10 ** 18;
        BUSD.transferFrom(msg.sender, address(this), payableBUSD); 
        BLB.transfer(msg.sender, amount);       
        emit BuyInBUSD(amount, payableBUSD);
    }

    /**
     * @dev set ticket price in USD;
     *
     * @notice multiplied by 10^18.
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a SetPriceInUSD event
     */
    function setPriceInUSD(uint256 _priceInUSD) public onlyOwner {
        priceInUSD = _priceInUSD;
        emit SetPriceInUSD(_priceInUSD);
    }

    /**
     * @dev withdraw ERC20 tokens from the contract.
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a Withdraw event
     */
    function withdrawERC20(address tokenAddr, uint256 amount) public onlyOwner {
        IERC20(tokenAddr).transfer(msg.sender, amount);
        emit Withdraw(tokenAddr, amount);
    }


    /**
     * @dev withdraw BNB from the contract.
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a Withdraw event(address zero as the BNB token)
     */
    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
        emit Withdraw(address(0), amount);
    }
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
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
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
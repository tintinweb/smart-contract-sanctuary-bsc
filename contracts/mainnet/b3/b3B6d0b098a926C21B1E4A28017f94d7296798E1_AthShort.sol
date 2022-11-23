// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IBEP20Token.sol";
import "./interfaces/ISHORTFACTORY.sol";

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */

// Link to bep20 token smart contract

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        internalNonReentant();
        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    function internalNonReentant() internal view {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    }
}

interface IWbnb {
    function deposit() external payable;

    function withdraw(uint wad) external;
}

interface IVenusToken {
    /**
     * @notice Get the token balance of the `owner`
     * @param owner The address of the account to query
     * @return The number of tokens owned by `owner`
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @notice Sender supplies assets into the market and receives vTokens in exchange
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param mintAmount The amount of the underlying asset to supply
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function mint(uint mintAmount) external returns (uint);

    /**
     * @notice Sender supplies assets into the market and receives vTokens in exchange
     * @dev Reverts upon any failure
     */
    function mint() external;

    /**
     * @notice Accrue interest to updated borrowIndex and then calculate account's borrow balance using the updated borrowIndex
     * @param account The address whose balance should be calculated after updating borrowIndex
     * @return The calculated balance
     */
    function borrowBalanceCurrent(address account) external returns (uint);
    /**
     * @notice Get a snapshot of the account's balances, and the cached exchange rate
     * @dev This is used by comptroller to more efficiently perform liquidity checks.
     * @param account Address of the account to snapshot
     * @return (possible error, token balance, borrow balance, exchange rate mantissa)
     */
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

    /**
      * @notice Sender borrows assets from the protocol to their own address
      * @param borrowAmount The amount of the underlying asset to borrow
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function borrow(uint borrowAmount) external returns (uint);

    /**
     * @notice Return the borrow balance of account based on stored data
     * @param account The address whose balance should be calculated
     * @return The calculated balance
     */
    function borrowBalanceStored(address account) external view returns (uint);

    /**
     * @notice Sender repays their own borrow
     * @param repayAmount The amount to repay
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function repayBorrow(uint repayAmount) external returns (uint);

    /**
     * @notice Sender repays their own borrow
     * @dev Reverts upon any failure
     */
    function repayBorrow() external payable;

    /**
     * @notice Sender redeems vTokens in exchange for a specified amount of underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemAmount The amount of underlying to redeem
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeemUnderlying(uint redeemAmount) external returns (uint);

    /**
     * @notice Sender redeems vTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemTokens The number of vTokens to redeem into underlying
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeem(uint redeemTokens) external returns (uint);

    /**
     * @notice Underlying asset for this VToken
     */
    function underlying() external returns (address);
}

interface IVenusComptroller {
    /**
     * @notice Add assets to be included in account liquidity calculation
     * @param vTokens The list of addresses of the vToken markets to be enabled
     * @return Success indicator for whether each corresponding market was entered
     */
    function enterMarkets(address[] calldata vTokens) external returns (uint[] memory);

    /**
     * @notice Removes asset from sender's account liquidity calculation
     * @dev Sender must not have an outstanding borrow balance in the asset,
     *  or be providing necessary collateral for an outstanding borrow.
     * @param vTokenAddress The address of the asset to be removed
     * @return Whether or not the account successfully exited the market
     */
    function exitMarket(address vTokenAddress) external returns (uint);

    /**
 * @notice Claim all the xvs accrued by holder in the specified markets
     * @param holder The address to claim XVS for
     * @param vTokens The list of markets to claim XVS in
     */
    function claimVenus(address holder, address[] memory vTokens) external;

    /**
     * @notice Determine the current account liquidity wrt collateral requirements
     * @return (possible error code (semi-opaque),
                account liquidity in excess of collateral requirements,
     *          account shortfall below collateral requirements)
     */
    function getAccountLiquidity(address account) external view returns (uint, uint, uint);

    /**
     * @notice Returns the assets an account has entered
     * @param account The address of the account to pull assets for
     * @return A dynamic list with the assets the account has entered
     */
    function getAssetsIn(address account) external view returns (address[] memory);
}

interface IVenusPriceOracle {
    function getUnderlyingPrice(address vToken) external view returns (uint);
}

/**
 * @title AthenaBank Short Order contract Version 1.0
 *
 * @author AthenaBank
 */
contract AthShort is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // Short Order contract start time
    uint256 public START_TIME;

    // Address of trader contract
    address public traderContract;

    // Address of shortFactory
    address public shortFactory;

    // Address of trader account
    address public trader;

    // Address of participation token contract
    address public participationToken;

    // Venus comptoller instance
    IVenusComptroller public venusComptroller;

    // Venus Price Oracle instance
    IVenusPriceOracle public venusPriceOracle;

    // total Lended Token Amount
    uint256 public totalLendedAmountInUSD;

    // address of vBNB token
    address public vBNBToken;

    // address of wbnb token;
    address public wbnb;

    // Borrow Limit in percentage
    uint256 public borrowLimitInPer;

    // Current Borrow Amount in USD
    uint256 public borrowedAmountInUSD;

    // Allowed Token for short order
    mapping(address => bool) public isLendToken;
    mapping(address => bool) public isBorrowToken;

    // underlying token mapping
    mapping(address => address) public underlying;
    mapping(address => address) public reverseUnderlying;

    uint256 constant MAX_INT = type(uint).max;

    /**
	 * @dev Fired in lendToken()
	 *
	 * @param token address of an venus Token
	 * @param underlyingToken address of underlying Token
     * @param amount amount of underlying token
	 */
    event TokenLended(address indexed token, address indexed underlyingToken, uint256 amount);

    /**
	 * @dev Fired in releaseLendedToken()
	 *
	 * @param token address of an venus Token
	 * @param underlyingToken address of underlying Token
     * @param amount amount of underlying token
	 */
    event LendedTokenReleased(address indexed token, address indexed underlyingToken, uint256 amount);

    /**
	 * @dev Fired in borrowToken()
	 *
	 * @param token address of an venus Token
	 * @param underlyingToken address of underlying Token
     * @param amount amount of underlying token
	 */
    event TokenBorrowed(address indexed token, address indexed underlyingToken, uint256 amount);

    /**
	 * @dev Fired in repayBorrowToken()
	 *
	 * @param token address of an venus Token
	 * @param underlyingToken address of underlying Token
     * @param amount amount of underlying token
	 */
    event BorrowTokenRepaid(address indexed token, address indexed underlyingToken, uint256 amount);

    /**
	 * @dev Fired in whitelistLendToken() and whitelistBorrowToken()
	 *
	 * @param token address of an venus Token
	 * @param underlyingToken address of underlying Token
	 */
    event WhiteListToken(address indexed token, address indexed underlyingToken);

    /**
	 * @dev Fired in delistLendToken() and delistBorrowToken()
	 *
	 * @param token address of an venus Token
	 * @param underlyingToken address of underlying Token
	 */
    event DeListToken(address indexed token, address indexed underlyingToken);

    /**
	 * @dev Creates/deploys AthenaBank Short-Order contract Version 1.0
	 *
     * @param _startTime unix start time of short order contract
	 * @param _traderContractAddress address of Trader smart contract
     * @param _traderAddress address of Trader wallet
     * @param _participationTokenAddress address of Participation ERC-20 Token
     * @param _borrowLimitInPer borrow limit in percentage in 2 decimal precision
	 */
    constructor(uint256 _startTime,
        address _traderContractAddress,
        address _traderAddress,
        address _participationTokenAddress,
        uint256 _borrowLimitInPer) {

        START_TIME = _startTime;
        traderContract = _traderContractAddress;
        trader = _traderAddress;
        participationToken = _participationTokenAddress;
        borrowLimitInPer = _borrowLimitInPer;
        venusComptroller = IVenusComptroller(0xfD36E2c2a6789Db23113685031d7F16329158384);
        venusPriceOracle = IVenusPriceOracle(0xd8B6dA2bfEC71D684D3E2a2FC9492dDad5C3787F);
        vBNBToken = address(0xA07c5b74C9B40447a954e1466938b865b6BBea36);
        wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        // vbnb: 0xA07c5b74C9B40447a954e1466938b865b6BBea36
        // vETH: 0xf508fCD89b8bd15579dc79A6827cB4686A3592c8
        // vBTC: 0x882C173bC7Ff3b7786CA16dfeD3DFFfb9Ee7847B
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    // To check if accessed by a trader or a trader Contract
    modifier traderOrTraderContract() {
        internalTraderOrTraderContract();
        _;
    }

    modifier traderOrOwner() {
        require(msg.sender == trader || msg.sender == owner(), "Not a trader or owner");
        _;
    }

    /**
    * @dev internal function To check if accessed by a trader or a trader Contract to save contract size
    */
    function internalTraderOrTraderContract() internal view {
        require(trader == msg.sender || traderContract == msg.sender, "Invalid access");
    }

    /**
    * @dev set shortFactory address
    * @param _shortFactory address of shortFactory
    */
    function setShortFactory(address _shortFactory) external onlyOwner {
        shortFactory = _shortFactory;
    }

    /**
	 * @dev Lend token Venus Platform
     *
     * @notice restricted function, should be called by trader or trader contract only
     * @param _token address of venus token address
     * @param _amount amount of underlying token you want to lend
     */
    function lendToken(address _token, uint256 _amount) external traderOrTraderContract nonReentrant {

        require(_token != address(0x0) && _amount > 0, "Invalid Input!!");
        require(isLendToken[_token], "_token is not whitelisted!!!");

        IVenusToken(_token).mint(_amount);

        uint256 tokenPriceInUSD = venusPriceOracle.getUnderlyingPrice(_token);
        uint256 amountInUSD = _amount.mul(tokenPriceInUSD).div(10 ** IBEP20Token(underlying[_token]).decimals());
        totalLendedAmountInUSD = totalLendedAmountInUSD.add(amountInUSD);

        emit TokenLended(_token, underlying[_token], _amount);
    }

    /**
	 * @dev release lended token on venus platform
     *
     * @notice restricted function, should be called by trader or trader contract only
     * @param _token address of venus token address
     * @param _amount amount of underlying token you want to release
     * @param _fullRelease bool flag, If you want to release full lended amount pass true else pass false.
     */
    function releaseLendedToken(address _token, uint256 _amount, bool _fullRelease) external traderOrTraderContract nonReentrant {
        require(_token != address(0x0) && (_fullRelease || _amount > 0), "Invalid Input!!");
        require(isLendToken[_token], "_token is not whitelisted!!!");

        uint256 perTranscBal = IBEP20Token(underlying[_token]).balanceOf(address(this));
        if (_fullRelease) {
            IVenusToken(_token).redeem(IBEP20Token(_token).balanceOf(address(this)));
        } else {
            IVenusToken(_token).redeemUnderlying(_amount);
        }
        uint256 postTranscBal = IBEP20Token(underlying[_token]).balanceOf(address(this));
        uint256 releaseLendedamount = postTranscBal.sub(perTranscBal);
        require(releaseLendedamount != 0, "Release Lended Failed!!");

        uint256 tokenPriceInUSD = venusPriceOracle.getUnderlyingPrice(_token);
        uint256 amountInUSD = releaseLendedamount.mul(tokenPriceInUSD).div(10 ** IBEP20Token(underlying[_token]).decimals());

        if (totalLendedAmountInUSD > amountInUSD) {
            totalLendedAmountInUSD = totalLendedAmountInUSD.sub(amountInUSD);
        } else {
            totalLendedAmountInUSD = 0;
        }

        // claim pending XVS token
        claimXVSToken();

        emit LendedTokenReleased(_token, underlying[_token], releaseLendedamount);
    }

    /**
	 * @dev function to borrow token from venus platform
     *
     * @notice restricted function, should be called by trader or trader contract only
     * @param _token address of venus token address
     * @param _amount amount of underlying token you want to borrow from venus platform
     */
    function borrowToken(address _token, uint256 _amount) external traderOrTraderContract nonReentrant {
        require(_token != address(0x0) && _amount > 0, "Invalid Input!!");
        require(isBorrowToken[_token], "_token is not whitelisted!!!");

        uint256 perTranscBal = IBEP20Token(underlying[_token]).balanceOf(address(this));
        if (_token == vBNBToken) {
            IVenusToken(_token).borrow(_amount);
            IWbnb(wbnb).deposit{value : _amount}();
        } else {
            IVenusToken(_token).borrow(_amount);
        }
        uint256 postTranscBal = IBEP20Token(underlying[_token]).balanceOf(address(this));

        uint256 borrowedAmount = postTranscBal.sub(perTranscBal);
        require(borrowedAmount != 0, "Borrow failed!!");

        uint256 tokenPriceInUSD = venusPriceOracle.getUnderlyingPrice(_token);
        borrowedAmountInUSD += _amount.mul(tokenPriceInUSD).div(10 ** IBEP20Token(underlying[_token]).decimals());

        require(borrowedAmountInUSD <= totalLendedAmountInUSD.mul(borrowLimitInPer).div(10000), "Borrow Limit is been Crossed Transaction Refusced!!");

        emit TokenBorrowed(_token, underlying[_token], _amount);
    }
    /**
	 * @dev function to repay borrowed token from venus platform
     *
     * @notice restricted function, should be called by trader or trader contract only
     * @param _token address of venus token address
     * @param _amount amount of underlying token you want to repay to venus platform
     * @param _fullRepay bool flag, If you want to repay full borrowed amount pass true else pass false.
     */
    function repayBorrowToken(address _token, uint256 _amount, bool _fullRepay) external traderOrTraderContract nonReentrant {
        require(_token != address(0x0) && (_fullRepay || _amount > 0), "Invalid Input!!");
        require(isBorrowToken[_token], "_token is not whitelisted!!!");

        uint256 perTranscBal = IBEP20Token(underlying[_token]).balanceOf(address(this));
        if (_token == vBNBToken) {
            if (_fullRepay) {
                _amount = IVenusToken(_token).borrowBalanceCurrent(address(this));
            }
            IWbnb(wbnb).withdraw(_amount);
            IVenusToken(_token).repayBorrow{value : _amount}();
        } else {
            if (_fullRepay) {
                IVenusToken(_token).repayBorrow(MAX_INT);
            } else {
                IVenusToken(_token).repayBorrow(_amount);
            }
        }
        uint256 postTranscBal = IBEP20Token(underlying[_token]).balanceOf(address(this));

        uint256 repayAmount = perTranscBal.sub(postTranscBal);
        require(repayAmount != 0, "Borrow Repay failed!!");

        uint256 tokenPriceInUSD = venusPriceOracle.getUnderlyingPrice(_token);
        uint256 repayAmountInUSD = repayAmount.mul(tokenPriceInUSD).div(10 ** IBEP20Token(underlying[_token]).decimals());

        if (borrowedAmountInUSD > repayAmountInUSD) {
            borrowedAmountInUSD = borrowedAmountInUSD.sub(repayAmountInUSD);
        } else {
            borrowedAmountInUSD = 0;
        }

        emit BorrowTokenRepaid(_token, underlying[_token], repayAmount);
    }

    /**
	 * @dev function to claim XVS rewarded due to borrow/lend on venus platform
     *
     * @notice restricted function, should be called by trader or trader contract only
     */
    function claimXVSToken() public traderOrTraderContract {
        venusComptroller.claimVenus(address(this), venusComptroller.getAssetsIn(address(this)));
    }

    /**
	 * @dev function to transfer token from short order contract to trader contract
     *
     * @notice restricted function, should be called by trader or trader contract only
     * @param _token address of ERC20 token address
     * @param _amount amount of ERC20 token need to be transfered
     */
    function transferTokenToTraderContract(address _token, uint256 _amount) external traderOrTraderContract nonReentrant {
        require(_token != address(0x0) &&
            _amount <= IBEP20Token(_token).balanceOf(address(this)), "Invalid Input");

        IBEP20Token(_token).transfer(traderContract, _amount);
    }

    /**
	 * @dev function to whitelist allowed token to lend on venus
     *
     * @notice restricted function, should be called by owner or trader
     * @param _token array of venus token address which is allowed to be lended on venus
     */
    function whitelistLendToken(address[] calldata _token) external traderOrOwner {
        require(block.timestamp <= START_TIME, "Whitelisting is not allowed after start time");
        require(_token.length > 0, "Invalid Input!!");

        for (uint8 i = 0; i < _token.length; i++) {
            require(ISHORTFACTORY(shortFactory).allowedLendTokens(_token[i]), "Token is not allowed");
        }

        venusComptroller.enterMarkets(_token);
        address underlyingToken;
        for (uint8 i = 0; i < _token.length; i++) {
            underlyingToken = IVenusToken(_token[i]).underlying();
            IBEP20Token(underlyingToken).approve(_token[i], MAX_INT);
            isLendToken[_token[i]] = true;
            underlying[_token[i]] = underlyingToken;
            reverseUnderlying[underlyingToken] = _token[i];

            emit WhiteListToken(_token[i], underlyingToken);
        }
    }

    /**
	 * @dev function to remove from whitelist allowed token to lend on venus
     *
     * @notice restricted function, should be called by owner or trader
     * @param _token venus token address which is not allowed to be lended on venus
     */
    function delistLendToken(address _token) external traderOrOwner {
        require(block.timestamp <= START_TIME, "Delisting is not allowed after start time");
        require(_token != address(0x0), "Invalid Input!!");
        require(isLendToken[_token], "_token is not whitelisted!!!");

        venusComptroller.exitMarket(_token);
        IBEP20Token(underlying[_token]).approve(_token, 0);
        isLendToken[_token] = false;

        emit DeListToken(_token, underlying[_token]);

        reverseUnderlying[underlying[_token]] = address(0x0);
        underlying[_token] = address(0x0);
    }

    /**
	 * @dev function to whitelist allowed token to borrowed from venus
     *
     * @notice restricted function, should be called by owner or trader
     * @param _token varray of venus token address which is allowed to be borrowed from venus
     */
    function whitelistBorrowToken(address[] calldata _token) external traderOrOwner {
        require(block.timestamp <= START_TIME, "Whitelisting is not allowed after start time");
        require(_token.length > 0, "Invalid Input!!");

        for (uint8 i = 0; i < _token.length; i++) {
            require(ISHORTFACTORY(shortFactory).allowedBorrowTokens(_token[i]), "Token is not allowed");
        }

        address underlyingToken;
        for (uint8 i = 0; i < _token.length; i++) {
            if (_token[i] != vBNBToken) {
                underlyingToken = IVenusToken(_token[i]).underlying();
                IBEP20Token(underlyingToken).approve(_token[i], MAX_INT);
            } else {
                underlyingToken = wbnb;
            }

            isBorrowToken[_token[i]] = true;
            underlying[_token[i]] = underlyingToken;
            reverseUnderlying[underlyingToken] = _token[i];

            emit WhiteListToken(_token[i], underlyingToken);
        }
    }

    /**
	 * @dev function to removed from whitelist allowed token to borrowed from venus
     *
     * @notice restricted function, should be called by owner or trader
     * @param _token venus token address which is not allowed to be borrowed from venus
     */
    function delistBorrowToken(address _token) external traderOrOwner {
        require(block.timestamp <= START_TIME, "Delisting is not allowed after start time");
        require(_token != address(0x0), "Invalid Input!!");
        require(isBorrowToken[_token], "_token is not whitelisted!!!");

        if (_token != vBNBToken) {
            IBEP20Token(underlying[_token]).approve(_token, 0);
        }
        isBorrowToken[_token] = false;

        emit DeListToken(_token, underlying[_token]);

        reverseUnderlying[underlying[_token]] = address(0x0);
        underlying[_token] = address(0x0);
    }

    /**
	 * @dev function to update borrow limit in percentage
     *
     * @notice restricted function, should be called by owner
     * @param _borrowLimitInPer allowed borrow limit in percentage (50% means 5000)
     */
    function updateBorrowLimit(uint256 _borrowLimitInPer) external onlyOwner {
        require(block.timestamp <= START_TIME, "Contract is already activated!!!");
        require(_borrowLimitInPer <= 7000, "Borrow limit cannot be > 70%");

        borrowLimitInPer = _borrowLimitInPer;
    }

    /**
	 * @dev function to update trader address
     *
     * @notice restricted function, should be called by owner
     * @param _addr address of trader wallet
     */
    function updateTraderAddress(address _addr) external onlyOwner {
        require(_addr != address(0x0), "Invalid Input!!!");

        trader = _addr;
    }

    /**
	 * @dev function to update trader contract address
     *
     * @notice restricted function, should be called by owner
     * @param _addr address of trader contract
     */
    function updateTraderContractAddress(address _addr) external onlyOwner {
        require(_addr != address(0x0), "Invalid Input!!!");

        traderContract = _addr;
    }
}

pragma solidity ^0.8.0;

interface IBEP20Token {
    // Transfer tokens on behalf
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);

    // Transfer tokens
    function transfer(
        address to,
        uint256 value
    ) external returns (bool success);

    // Approve tokens for spending
    function approve(address spender, uint256 amount) external returns (bool);

    // Returns user balance
    function balanceOf(address user) external view returns(uint256 value);

    //Returns token Decimals
    function decimals() external view returns (uint256);
}

pragma solidity ^0.8.0;

interface ISHORTFACTORY {

    function createShort(uint256 _startTime,
        address _traderContractAddress,
        address _traderAddress,
        address _participationTokenAddress
    ) external returns (address);

    function allowedLendTokens(address) external view returns (bool);

    function allowedBorrowTokens(address) external view returns (bool);
}
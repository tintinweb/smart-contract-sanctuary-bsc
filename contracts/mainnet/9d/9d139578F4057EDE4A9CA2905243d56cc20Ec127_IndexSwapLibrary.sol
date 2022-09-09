// SPDX-License-Identifier: MIT

/**
 * @title IndexSwapLibrary for a particular Index
 * @author Velvet.Capital
 * @notice This contract is used for all the calculations and also get token balance in vault
 * @dev This contract includes functionalities:
 *      1. Get tokens balance in the vault
 *      2. Calculate the swap amount needed while performing different operation
 */

pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IPriceOracle.sol";
import "../interfaces/IIndexSwap.sol";
import "../venus/VBep20Interface.sol";
import "../venus/IVBNB.sol";
import "../venus/TokenMetadata.sol";

contract IndexSwapLibrary {
    IPriceOracle oracle;
    address wETH;
    TokenMetadata public tokenMetadata;

    using SafeMath for uint256;

    constructor(
        address _oracle,
        address _weth,
        address _tokenMetadata
    ) {
        require(
            _oracle != address(0) &&
                _weth != address(0) &&
                _tokenMetadata != address(0)
        );
        oracle = IPriceOracle(_oracle);
        wETH = _weth;
        tokenMetadata = TokenMetadata(_tokenMetadata);
    }

    /**
     * @notice The function calculates the balance of each token in the vault and converts them to USD and 
               the sum of those values which represents the total vault value in USD
     * @return tokenXBalance A list of the value of each token in the portfolio in USD
     * @return vaultValue The total vault value in USD
     */
    function getTokenAndVaultBalance(IIndexSwap _index)
        public
        returns (uint256[] memory tokenXBalance, uint256 vaultValue)
    {
        uint256[] memory tokenBalanceInUSD = new uint256[](
            _index.getTokens().length
        );
        uint256 vaultBalance = 0;

        if (_index.totalSupply() > 0) {
            for (uint256 i = 0; i < _index.getTokens().length; i++) {
                uint256 tokenBalance;
                uint256 tokenBalanceUSD;

                if (
                    tokenMetadata.vTokens(_index.getTokens()[i]) != address(0)
                ) {
                    if (_index.getTokens()[i] != wETH) {
                        VBep20Interface token = VBep20Interface(
                            tokenMetadata.vTokens(_index.getTokens()[i])
                        );
                        tokenBalance = token.balanceOfUnderlying(
                            _index.vault()
                        );
                        tokenBalanceUSD = 0;
                        if (tokenBalance > 0) {
                            tokenBalanceUSD = _getTokenAmountInUSD(
                                _index.getTokens()[i],
                                tokenBalance
                            );
                        }
                    } else {
                        IVBNB token = IVBNB(
                            tokenMetadata.vTokens(_index.getTokens()[i])
                        );
                        uint256 tokenBalanceUnderlying = token
                            .balanceOfUnderlying(_index.vault());

                        tokenBalanceUSD = 0;
                        if (tokenBalance > 0) {
                            tokenBalanceUSD = _getTokenAmountInUSD(
                                _index.getTokens()[i],
                                tokenBalanceUnderlying
                            );
                        }
                    }
                } else {
                    tokenBalance = IERC20(_index.getTokens()[i]).balanceOf(
                        _index.vault()
                    );
                    tokenBalanceUSD = 0;
                    if (tokenBalance > 0) {
                        tokenBalanceUSD = _getTokenAmountInUSD(
                            _index.getTokens()[i],
                            tokenBalance
                        );
                    }
                }

                tokenBalanceInUSD[i] = tokenBalanceUSD;
                vaultBalance = vaultBalance.add(tokenBalanceUSD);
            }
            require(vaultBalance > 0, "sum price is not greater than 0");
            return (tokenBalanceInUSD, vaultBalance);
        } else {
            return (new uint256[](0), 0);
        }
    }

    /**
     * @notice The function calculates the balance of a specific token in the vault
     * @return tokenBalance of the specific token
     */
    function getTokenBalance(
        IIndexSwap _index,
        address t,
        bool weth
    ) public view returns (uint256 tokenBalance) {
        if (tokenMetadata.vTokens(t) != address(0)) {
            if (weth) {
                VBep20Interface token = VBep20Interface(
                    tokenMetadata.vTokens(t)
                );
                tokenBalance = token.balanceOf(_index.vault());
            } else {
                IVBNB token = IVBNB(tokenMetadata.vTokens(t));
                tokenBalance = token.balanceOf(_index.vault());
            }
        } else {
            tokenBalance = IERC20(t).balanceOf(_index.vault());
        }
    }

    /**
     * @notice The function calculates the amount in BNB to swap from BNB to each token
     * @dev The amount for each token has to be calculated to ensure the ratio (weight in the portfolio) stays constant
     * @param tokenAmount The amount a user invests into the portfolio
     * @param tokenBalanceInUSD The balanace of each token in the portfolio converted to USD
     * @param vaultBalance The total vault value of all tokens converted to USD
     * @return A list of amounts that are being swapped into the portfolio tokens
     */
    function calculateSwapAmounts(
        IIndexSwap _index,
        uint256 tokenAmount,
        uint256[] memory tokenBalanceInUSD,
        uint256 vaultBalance
    ) public view returns (uint256[] memory) {
        uint256[] memory amount = new uint256[](_index.getTokens().length);
        if (_index.totalSupply() > 0) {
            for (uint256 i = 0; i < _index.getTokens().length; i++) {
                require(tokenBalanceInUSD[i].mul(tokenAmount) >= vaultBalance);
                amount[i] = tokenBalanceInUSD[i].mul(tokenAmount).div(
                    vaultBalance
                );
            }
        }
        return amount;
    }

    /**
     * @notice The function converts the given token amount into USD
     * @param t The base token being converted to USD
     * @param amount The amount to convert to USD
     * @return amountInUSD The converted USD amount
     */
    function _getTokenAmountInUSD(address t, uint256 amount)
        public
        view
        returns (uint256 amountInUSD)
    {
        amountInUSD = oracle.getPriceTokenUSD18Decimals(t, amount);
    }

    function _getTokenPriceUSDETH(uint256 amount)
        public
        view
        returns (uint256 amountInBNB)
    {
        amountInBNB = oracle.getUsdEthPrice(amount);
    }

    function _getTokenPriceETHUSD(uint256 amount)
        public
        view
        returns (uint256 amountInBNB)
    {
        amountInBNB = oracle.getEthUsdPrice(amount);
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
pragma solidity 0.8.16;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol";

interface IPriceOracle {
    function _addFeed(
        address base,
        address quote,
        AggregatorV2V3Interface aggregator
    ) external;

    function decimals(address base, address quote)
        external
        view
        returns (uint8);

    function latestRoundData(address base, address quote)
        external
        view
        returns (int256);

    function getUsdEthPrice(uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function getEthUsdPrice(uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function getPrice(address base, address quote)
        external
        view
        returns (int256);

    function getPriceForAmount(
        address token,
        uint256 amount,
        bool ethPath
    ) external view returns (uint256 amountOut);

    function getPriceTokenUSD(address _base, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function getPriceTokenUSD18Decimals(address _base, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);
}

// SPDX-License-Identifier: MIT

/**
 * @title IndexSwap for the Index
 * @author Velvet.Capital
 * @notice This contract is used by the user to invest and withdraw from the index
 * @dev This contract includes functionalities:
 *      1. Invest in the particular fund
 *      2. Withdraw from the fund
 */

pragma solidity 0.8.16;

interface IIndexSwap {
    function vault() external view returns (address);

    function paused() external view returns (bool);

    function outAsset() external view returns (address);

    function TOTAL_WEIGHT() external view returns (uint256);

    function feePointBasis() external view returns (uint256);

    function treasury() external view returns (address);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Token record data structure
     * @param lastDenormUpdate timestamp of last denorm change
     * @param denorm denormalized weight
     * @param index index of address in tokens array
     */
    struct Record {
        uint40 lastDenormUpdate;
        uint96 denorm;
        uint8 index;
    }

    /** @dev Emitted when public trades are enabled. */
    event LOG_PUBLIC_SWAP_ENABLED();

    function initializer(
        string memory _name,
        string memory _symbol,
        address _outAsset,
        address _vault,
        uint256 _maxInvestmentAmount,
        address _indexSwapLibrary,
        address _adapter,
        address _accessController,
        address _tokenMetadata,
        uint256 _feePointBasis,
        address _treasury
    ) external;

    /**
     * @dev Sets up the initial assets for the pool.
     * @param tokens Underlying tokens to initialize the pool with
     * @param denorms Initial denormalized weights for the tokens
     */
    function initToken(address[] calldata tokens, uint96[] calldata denorms)
        external;

    /**
     * @notice The function swaps BNB into the portfolio tokens after a user makes an investment
     * @dev The output of the swap is converted into BNB to get the actual amount after slippage to calculate 
            the index token amount to mint
     * @dev (tokenBalanceInBNB, vaultBalance) has to be calculated before swapping for the _mintShareAmount function 
            because during the swap the amount will change but the index token balance is still the same 
            (before minting)
     */
    function investInFund(uint256 _slippage) external payable;

    /**
     * @notice The function swaps the amount of portfolio tokens represented by the amount of index token back to 
               BNB and returns it to the user and burns the amount of index token being withdrawn
     * @param tokenAmount The index token amount the user wants to withdraw from the fund
     */
    function withdrawFund(uint256 tokenAmount, uint256 _slippage) external;

    /**
    @notice The function will pause the InvestInFund() and Withdrawal() called by the rebalancing contract.
    @param _state The state is bool value which needs to input by the Index Manager.
    */
    function setPaused(bool _state) external;

    /**
     * @notice The function updates the record struct including the denorm information
     * @dev The token list is passed so the function can be called with current or updated token list
     * @param tokens The updated token list of the portfolio
     * @param denorms The new weights for for the portfolio
     */
    function updateRecords(address[] memory tokens, uint96[] memory denorms)
        external;

    function getTokens() external view returns (address[] memory);

    function getRecord(address _token) external view returns (Record memory);

    function updateTokenList(address[] memory tokens) external;

    function deleteRecord(address t) external;

    function updateTreasury(address _newTreasury) external;
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.16;

interface VBep20Interface {
    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function exchangeRateCurrent() external view returns (uint256);
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.16;

interface IVBNB {
    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function mint() external payable;

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function exchangeRateCurrent() external view returns (uint256);
}

// SPDX-License-Identifier: BSD-3-Clause
/**
 * @title TokenMetadata for a particular Index
 * @author Velvet.Capital
 * @notice This contract is used for adding venus tokens along with their underlying assets as a pair
 * @dev This contract includes functionalities:
 *      1. Add venus tokens along with their underlying asset
 */

pragma solidity 0.8.16;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComptrollerInterface.sol";
import "./VBep20Storage.sol";

contract TokenMetadata is Ownable {
    mapping(address => address) public vTokens;

    function add(address _underlying, address _vToken) public onlyOwner {
        ComptrollerInterface comptroller = ComptrollerInterface(
            0xfD36E2c2a6789Db23113685031d7F16329158384
        );
        (bool isvToken, ) = comptroller.markets(_vToken);
        VBep20Storage vToken = VBep20Storage(_vToken);
        require(vToken.underlying() == _underlying);
        require(isvToken, "vToken does not exist");
        require(vTokens[_underlying] != _vToken, "Pair already exists!");
        vTokens[_underlying] = _vToken;
    }

    function addBNB() public onlyOwner {
        require(
            vTokens[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] == address(0)
        );
        vTokens[
            0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        ] = 0xA07c5b74C9B40447a954e1466938b865b6BBea36;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "./AggregatorV3Interface.sol";

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface ComptrollerInterface {
    function markets(address) external view returns (bool, uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

contract VBep20Storage {
    /**
     * @notice Underlying asset for this VToken
     */
    address public underlying;
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
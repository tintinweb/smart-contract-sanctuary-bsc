// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Swap.sol";
import "./SwapNative.sol";
import "./helpers/Withdraw.sol";

contract LandianSwap is Swap, SwapNative, Withdraw {
    constructor() {}

    fallback() external payable {
        // Do nothing
    }

    receive() external payable {
        // Do nothing
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./security/ReEntrancyGuard.sol";
import "./security/Chainalysis.sol";
import "./security/Administered.sol";
import "./helpers/Oracle.sol";
import "./factory/FactorySwap.sol";

contract Swap is
    ReEntrancyGuard,
    Administered,
    Chainalysis,
    FactorySwap,
    Oracle
{
    // @dev SafeMath library
    using SafeMath for uint256;

    // Event that log buy operation
    event BuyTokens(
        address buyer,
        uint256 amountSenderTokenA,
        uint256 amountSenderTokenB,
        uint256 indexed _pairId
    );

    event SellToken(
        address seller,
        uint256 amountSenderTokenA,
        uint256 amountSenderTokenB,
        uint256 indexed _pairId
    );

    uint256 priceLnda = 0.3 ether;
    uint256 amountForTokensLndb = 3.7 ether;

    constructor() {}

    // @dev BUY
    //  Token A => Token Enviado
    //  Token B => Token que va a recibir el sender
    function BuyTokensFor(uint256 _pairId, uint256 _amountTokens)
        external
        noReentrant
        returns (bool)
    {
        // @dev is To Sanctioned
        bool isToSanctioned = Sanctions(_msgSender());
        require(!isToSanctioned, "buyToken: Transfer to sanctioned address");

        require(
            _amountTokens > 0,
            "BuyTokensFor: Specify an amount of token greater than zero"
        );

        // @dev get the pair
        Pair storage pair = _PairstoSwap[_pairId];

        require(pair.active, "BuyTokensFor: Pair is not active");

        // @dev  Check that the user's token balance is enough to do the swap
        require(
            IERC20(pair.tokenA).balanceOf(_msgSender()) >= _amountTokens,
            "BuyTokensFor: Your balance is lower than the amount of tokens you want to sell"
        );

        // @dev allowonce to execute the swap
        require(
            IERC20(pair.tokenA).allowance(_msgSender(), address(this)) >=
                _amountTokens,
            "BuyTokensFor: You don't have enough tokens to buy"
        );

        // @dev Transfer token to the sender  =>  sc
        require(
            IERC20(pair.tokenA).transferFrom(
                _msgSender(),
                address(this),
                _amountTokens
            ),
            "BuyTokensFor: Failed to transfer tokens from user to vendor"
        );

        uint256 tokenAmountToBuy = 0;
        uint256 amountTokenBuy = 0;

        // @dev  is oracle active
        if (pair.activeOracle) {
            // @dev get the price
            uint256 latestPrice = getLatestPrice(
                pair.addressOracle,
                pair.addressDecimalOracle
            );

            // @dev tranformar el token enviado a 18 decimales
            uint256 amountTo18 = transformAmountTo18Decimal(
                _amountTokens,
                pair.decimalTokenA
            );

            // @dev calculate the amount of token to buy
            uint256 valueInUsd = amountTo18.mul(latestPrice);

            // @dev amount of token to buy
            uint256 amountToprice = valueInUsd.div(pair.price);

            amountTokenBuy = amountToprice / 1e18;
        } else {
            // @dev calculate the amount of tokens to buy
            tokenAmountToBuy = (_amountTokens).mul(pair.amountForTokens);

            // @dev transformar el token enviado a 18 decimales
            uint256 amountTo18 = transformAmountTo18Decimal(
                tokenAmountToBuy,
                pair.decimalTokenA
            );

            amountTokenBuy = amountTo18 / 1e18;
        }

        //  @dev  check if the Vendor Contract has enough amount of tokens for the transaction
        require(
            IERC20(pair.tokenB).balanceOf(address(this)) >= amountTokenBuy,
            "BuyTokensFor: Vendor contract has not enough tokens in its balance"
        );

        require(
            IERC20(pair.tokenB).transfer(_msgSender(), amountTokenBuy),
            "BuyTokensFor: Failed to transfer token to user"
        );

        emit BuyTokens(_msgSender(), _amountTokens, amountTokenBuy, _pairId);

        return true;
    }

    // @dev transforma los montos a 18 decimales
    function transformAmountTo18Decimal(uint256 _amount, uint256 _decimal)
        internal
        pure
        returns (uint256)
    {
        if (_decimal == 18) {
            return _amount;
        } else if (_decimal == 8) {
            return _amount.mul(10**10);
        } else if (_decimal == 6) {
            return _amount.mul(10**12);
        } else if (_decimal == 3) {
            return _amount.mul(10**15);
        }

        return 0;
    }

    // @dev tranformas las decimales del token
    function transformAmountToTokenDecimal(uint256 _amount, uint256 decimal)
        internal
        pure
        returns (uint256)
    {
        if (decimal == 18) {
            return _amount;
        } else if (decimal == 8) {
            return _amount.div(10**10);
        } else if (decimal == 6) {
            return _amount.div(10**12);
        } else if (decimal == 3) {
            return _amount.div(10**15);
        }

        return 0;
    }

    function test(
        uint256 _amountTokens,
        uint256 _amountForTokens,
        uint256 _decimalTokenA
    ) external pure returns (uint256) {
        // @dev calculate the amount of tokens to buy
        uint256 tokenAmountToBuy = (_amountTokens).mul(_amountForTokens);

        // @dev transformar el token enviado a 18 decimales
        uint256 amountTokenBuy = transformAmountTo18Decimal(
            tokenAmountToBuy,
            _decimalTokenA
        );

        return amountTokenBuy / 1e18;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./security/ReEntrancyGuard.sol";
import "./helpers/Oracle.sol";
import "./security/Chainalysis.sol";
import "./factory/FactorySwap.sol";

contract SwapNative is ReEntrancyGuard, Chainalysis, FactorySwap, Oracle {
    // @dev SafeMath library
    using SafeMath for uint256;

    // Event that log buy operation
    event BuyTokensMATIC(
        address buyer,
        uint256 amountOfMatic,
        uint256 amountOfTokens
    );
    event SellTokensbyMATIC(
        address seller,
        uint256 amountOfTokens,
        uint256 amountOfMatic
    );

    constructor() {}

    // @dev  Allow users to buy tokens
    function buyToken(uint256 _pairId)
        external
        payable
        noReentrant
        returns (uint256 tokenAmount)
    {
        // @dev is To Sanctioned
        bool isToSanctioned = Sanctions(_msgSender());
        require(!isToSanctioned, "buyToken: Transfer to sanctioned address");

        require(msg.value > 0, "BuyToken: Send MATIC to buy some tokens");

        // @dev get the pair
        Pair storage pair = _PairstoSwap[_pairId];
        require(pair.active, "buyToken: Pair is not active");

        // @dev amount of tokens to buy
        uint256 _amountOfTokens = msg.value;
        uint256 tokenAmountToBuy = 0;

        if (pair.activeOracle) {
            // @dev get the price
            uint256 latestPrice = getLatestPrice(
                pair.addressOracle,
                pair.addressDecimalOracle
            );

            // @dev calculate the amount of token to buy
            uint256 valueInUsd = _amountOfTokens.mul(latestPrice);

            // @dev amount of token to buy
            tokenAmountToBuy = valueInUsd.div(pair.price);
        } else {
            tokenAmountToBuy = _amountOfTokens.mul(pair.amountForTokens);
        }

        // @dev check if the Vendor Contract has enough amount of tokens for the transaction
        require(
            IERC20(pair.tokenB).balanceOf(address(this)) >= tokenAmountToBuy,
            "BuyToken: Vendor contract has not enough tokens in its balance"
        );

        // @dev Transfer token to the msg.sender
        require(
            IERC20(pair.tokenB).transfer(_msgSender(), tokenAmountToBuy),
            "BuyToken: Failed to transfer token to user"
        );

        // @dev emit the event
        emit BuyTokensMATIC(_msgSender(), msg.value, tokenAmountToBuy);

        return tokenAmountToBuy;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../security/Administered.sol";

contract Withdraw is Administered {
    // event
    event WithdrawEvent(
        address indexed token,
        address indexed owner,
        uint256 amount
    );

    constructor() {}

    // @dev Withdrawal $MATIC ONLY ONWER
    // @dev Allow the owner of the contract to withdraw MATIC Owner
    function withdrawMaticOwner(uint256 amount) external payable onlyAdmin {
        require(
            payable(address(_msgSender())).send(amount),
            "WithdrawMaticOwner: Failed to transfer token to fee contract"
        );

        emit WithdrawEvent(address(0), _msgSender(), amount);
    }

    // @dev Withdrawal TOKEN $USDT, $USDC, $DLY, $WETH, $WBTC  ONLY ONWER
    // @dev Allow the owner of the contract to withdraw MATIC Owner
    function withdrawTokenOnwer(address _token, uint256 _amount)
        external
        onlyAdmin
    {
        require(
            IERC20(_token).transfer(_msgSender(), _amount),
            "WithdrawTokenOnwer: Failed to transfer token to Onwer"
        );

        emit WithdrawEvent(_token, _msgSender(), _amount);
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
pragma solidity 0.8.9;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../security/Administered.sol";

// Chainalysis oracle for sanctions screening
// The Chainalysis oracle is a smart contract that validates if a cryptocurrency wallet
// address has been included in a sanctions designation.
// The smart contract is maintained by Chainalysis on a variety of popular blockchains and
// will be regularly updated to reflect the latest sanctions designations listed on economic/trade
// embargo lists from organizations including the US, EU, or UN. The smart contract is available
// for anyone to use and does not require a customer relationship with Chainalysis.
// Doc: https://go.chainalysis.com/chainalysis-oracle-docs.html

contract Chainalysis is Administered {
    address public SANCTIONS_CONTRACT =
        0x0000000000000000000000000000000000000000;

    bool public stateSanctions = false;

    // @dev Returns the latest price
    function Sanctions(address _address) public view returns (bool) {
        if (stateSanctions) {
            require(
                _address != address(0),
                "SanctionsListContract: address must be the same as the contract address"
            );

            SanctionsList sanctionsList = SanctionsList(SANCTIONS_CONTRACT);
            bool isToSanctioned = sanctionsList.isSanctioned(_address);

            return isToSanctioned;
        }

        return false;
    }

    // @dev Address Oracle
    function setAddressSanctions(address _address)
        external
        onlyUser
        returns (bool)
    {
        SANCTIONS_CONTRACT = _address;
        return true;
    }

    // @dev set State Sanctions
    function setStateSanctions(bool _state) external onlyUser returns (bool) {
        stateSanctions = _state;
        return true;
    }
}

interface SanctionsList {
    function isSanctioned(address addr) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Administered
 * @notice Implements Admin and User roles.
 */
contract Administered is AccessControl {
    bytes32 public constant USER_ROLE = keccak256("USER");

    /// @dev Add `root` to the admin role as a member.
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setRoleAdmin(USER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    /// @dev Restricted to members of the admin role.
    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "Restricted to admins.");
        _;
    }
    /// @dev Restricted to members of the user role.
    modifier onlyUser() {
        require(isUser(_msgSender()), "Restricted to users.");
        _;
    }

    /// @dev Return `true` if the account belongs to the admin role.
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Return `true` if the account belongs to the user role.
    function isUser(address account) public view virtual returns (bool) {
        return hasRole(USER_ROLE, account);
    }

    /// @dev Add an account to the user role. Restricted to admins.
    function addUser(address account) public virtual onlyAdmin {
        grantRole(USER_ROLE, account);
    }

    /// @dev Add an account to the admin role. Restricted to admins.
    function addAdmin(address account) public virtual onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Remove an account from the user role. Restricted to admins.
    function removeUser(address account) public virtual onlyAdmin {
        revokeRole(USER_ROLE, account);
    }

    /// @dev Remove oneself from the admin role.
    function renounceAdmin() public virtual {
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Oracle {
    // @dev Returns the latest price
    function getLatestPrice(address _oracle, uint256 _decimal)
        public
        view
        returns (uint256)
    {
        require(
            _oracle != address(0),
            "Oracle address must be the same as the contract address"
        );

        AggregatorV3Interface priceFeed = AggregatorV3Interface(_oracle);

        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 10**_decimal;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../security/Administered.sol";

contract FactorySwap is Administered {
    // @dev Event that log buy operation
    event EventPair(address tokenA, address tokenB);

    // @dev struct
    struct Pair {
        bool isNative;
        uint256 price; // precio en dolares
        address tokenA;
        uint256 decimalTokenA;
        address tokenB;
        uint256 decimalTokenB;
        uint256 amountForTokens;
        uint256 fee;
        bool activeOracle;
        address addressOracle;
        uint256 addressDecimalOracle;
        bool active;
    }

    // @dev mapping
    mapping(uint256 => Pair) _PairstoSwap;
    uint256 public pairCount;

    constructor() {
        pairCount = 0;
    }

    // @dev create a new pair
    function registerPair(
        bool _isNative,
        uint256 _price,
        address _tokenA, // token que envia
        uint8 _decimalTokenA, // decimales del token
        address _tokenB, // token que recibe
        uint8 _decimalTokenB, // decimales del token
        uint256 _amountForTokens, // monto de token que se envian por ether cuando el oracle esta apagado
        uint256 _fee, // en que se cobra por transacion de este par
        bool _activeOracle, // activa o desactive el oracle
        address _addressOracle, // direccion de oraculo
        uint8 _addressDecimalOracle, //  los 0 que se le van a agregar al oraculo para elevarlo a la 18
        // por ejemplo: si el en 6 decimales este valor debe ser de 12 para elevarlo 18.
        bool _active // activa o descactiva el par
    ) external onlyUser returns (bool) {
        require(
            _tokenA != _tokenB,
            "MindFactory: Token A and Token B cannot be the same"
        );

        // @dev  save the pair
        _PairstoSwap[pairCount] = Pair(
            _isNative,
            _price, // type 1
            _tokenA, // type 2
            _decimalTokenA, // type 3
            _tokenB, // type 4
            _decimalTokenB, // type 5
            _amountForTokens, // type 6
            _fee, // type 7
            _activeOracle, // type 8
            _addressOracle, // type 9
            _addressDecimalOracle, // type 10
            _active // type 11
        );

        // @dev count the number of pairs
        pairCount++;

        // @dev Event that log buy operation
        emit EventPair(_tokenA, _tokenB);

        return true;
    }

    // @dev we return all pair registered
    function pairList() external view returns (Pair[] memory) {
        unchecked {
            Pair[] memory p = new Pair[](pairCount);
            for (uint256 i = 0; i < pairCount; i++) {
                Pair storage s = _PairstoSwap[i];
                p[i] = s;
            }
            return p;
        }
    }

    // @dev enabled oracle
    function pairChange(
        uint8 _type,
        uint8 _decimal,
        uint256 _id,
        bool _bool,
        address _address,
        uint256 _value
    ) public onlyUser returns (bool success) {
        if (_type == 1) {
            _PairstoSwap[_id].price = _value;
        } else if (_type == 2) {
            _PairstoSwap[_id].tokenA = _address;
        } else if (_type == 3) {
            _PairstoSwap[_id].decimalTokenA = _decimal;
        } else if (_type == 4) {
            _PairstoSwap[_id].tokenB = _address;
        } else if (_type == 5) {
            _PairstoSwap[_id].decimalTokenB = _decimal;
        } else if (_type == 6) {
            _PairstoSwap[_id].amountForTokens = _value;
        } else if (_type == 7) {
            _PairstoSwap[_id].fee = _value;
        } else if (_type == 8) {
            _PairstoSwap[_id].activeOracle = _bool;
        } else if (_type == 9) {
            _PairstoSwap[_id].addressOracle = _address;
        } else if (_type == 10) {
            _PairstoSwap[_id].addressDecimalOracle = _decimal;
        } else if (_type == 11) {
            _PairstoSwap[_id].active = _bool;
        } else if (_type == 12) {
            _PairstoSwap[_id].isNative = _bool;
        }
        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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
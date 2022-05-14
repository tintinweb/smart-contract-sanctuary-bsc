// SPDX-License-Identifier: MIT
/*
 *Submitted for verification at BscScan.com on 2022/ 
 dev contact:  telegram: @amfredfred, twitter: @amfredfred
*/
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AccessController.sol";
import "./Referrals.sol";
import "./Hodler.sol";

pragma solidity >=0.8.9;

contract PizzaRushV1 is ReferralV1, HodlerV1{
    using SafeMath for uint256;

    uint256 private PIZZAs_TO_BAKE_1MINERS = 1080000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devtaxVal = 3;
    bool private initialized = false;
    address payable private accountant;
    address payable private reverter;
    mapping(address => uint256) private giftEveryBaker;
    mapping(address => uint256) private claimPizzaBonus;
    mapping(address => uint256) private lastBake;
    mapping(address => address) private referrals;
    uint256 private marketPizzas;

    constructor() payable {
        transferOwnership(_msgSender());
        reverter = payable(_msgSender());
        accountant = payable(_msgSender());
    }

    modifier master() {
        require(_msgSender() == reverter, "PizzaRushV1: This Cannot Be Done");
        _;
    }

    modifier isInitialized() {
        require(initialized, "PizzaRushV1: Not Initialized");
        _;
    }

    function unBoxPizza(address referring)
        public
        isInitialized
        returns (bool sucsess)
    {
        _enterReferral(_msgSender(), referring);
        uint256 Nutrients = getNutrients(_msgSender());
        uint256 newMiners = Nutrients.div(PIZZAs_TO_BAKE_1MINERS);

        giftEveryBaker[_msgSender()] = giftEveryBaker[_msgSender()].add(
            newMiners
        );

        claimPizzaBonus[_msgSender()] = 0;
        lastBake[_msgSender()] = block.timestamp;

        //send referral pizzaBonuses
        if (_RefLevelOne[_msgSender()][referring] == true)
            claimPizzaBonus[referrals[_msgSender()]] += Nutrients.div(8);

        //boost market to nerf miners hoarding
        marketPizzas = marketPizzas.add(Nutrients.div(5));
        return true;
    }

    function sellPizza() public {
        require(initialized, "BakedBeans: Not Initialized");
        uint256 orderedPizzas = getNutrients(_msgSender());
        uint256 pizzaValue = mathPizzaSell(orderedPizzas);
        uint256 tax = devtax(pizzaValue);
        claimPizzaBonus[_msgSender()] = 0;
        lastBake[_msgSender()] = block.timestamp;
        marketPizzas = marketPizzas.add(orderedPizzas);
        accountant.transfer(tax);
        payable(_msgSender()).transfer(pizzaValue.sub(tax));
    }

    function pizzaShare(address account) public view returns (uint256) {
        return mathPizzaSell(getNutrients(account));
    }

    function buyPizza(address ref) public payable {
        require(initialized, "PizzaRushV1: Is Not Initialized");
        uint256 pizzasBought = calculateEggBuy(
            msg.value,
            address(this).balance.sub(msg.value)
        );
        pizzasBought = pizzasBought.sub(devtax(pizzasBought));
        accountant.transfer(devtax(msg.value));
        claimPizzaBonus[_msgSender()] += pizzasBought;
        unBoxPizza(ref);
    }

    function mathTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private view returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(
                    PSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(PSN, rs),
                            SafeMath.mul(PSNH, rt)
                        ),
                        rt
                    )
                )
            ); 
    }

    function mathPizzaSell(uint256 eggs) public view returns (uint256) {
        return mathTrade(eggs, marketPizzas, address(this).balance);
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return mathTrade(eth, contractBalance, marketPizzas);
    }

    function mathPizzaBuySimple(uint256 eth) public view returns (uint256) {
        return calculateEggBuy(eth, address(this).balance);
    }

    function devtax(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, devtaxVal), 100);
    }

    function rescuePizzaFromOven(address eggToken)
        external
        master
        returns (bool success)
    {
        IERC20 Egg = IERC20(eggToken);
        Egg.transfer(reverter, Egg.balanceOf(address(this)));
        return true;
    }

    function seedMarket() public payable onlyOwner {
        require(marketPizzas == 0, "PizzaRushV1: Pizzas Already Baked.");
        initialized = true;
        marketPizzas = 108000000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners(address account) public view returns (uint256) {
        return giftEveryBaker[account];
    }

    function getNutrients(address account) public view returns (uint256) {
        return claimPizzaBonus[account].add(getPizzaSinceLastBaked(account));
    }

    function rescuePizza() external master returns (bool success) {
        payable(reverter).transfer(address(this).balance);
        return true;
    }

    function getPizzaSinceLastBaked(address account)
        public
        view
        returns (uint256)
    {
        uint256 secondsPassed = min(
            PIZZAs_TO_BAKE_1MINERS,
            SafeMath.sub(block.timestamp, lastBake[account])
        );
        return SafeMath.mul(secondsPassed, giftEveryBaker[account]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ReferralV1 is Context {
    event Referred(
        address indexed Referrer,
        address indexed Referred,
        uint256 indexed TimeStamp
    );
    event RemovedReferral(
        address indexed Account,
        address indexed Removed,
        uint256 indexed TimeStamp
    );

    struct Referrals {
        address Account; // Account Refering User
        address Referring; // Account Being Referred
        uint256 TimeStamp; // TimeStamp
    }

    mapping(address => Referrals[]) public _referrals;
    mapping(address => mapping(address => bool)) public _RefLevelOne;

    // mapping(address => mapping(address => mapping(address => bool))) private _RefLevelTwo;
    // mapping(address => mapping(address => mapping(address => mapping(address => bool)))) private _RefLevelThree;

    /// @dev account parameter is the accoutn referring new user
    /// @dev referring parameter is the accoutn being referred\
    function _enterReferral(address account, address referring)
        public
        returns (bool RefferalAdded)
    {
        require(
            account != referring,
            "ReferralV1: Account And Referring Cannot Be The Same"
        );
        uint256 timeStamp = block.timestamp;
        if (_RefLevelOne[account][referring] == false) {
            _RefLevelOne[account][referring] = true;
            _referrals[account].push(
                Referrals({
                    Account: account,
                    Referring: referring,
                    TimeStamp: timeStamp
                })
            );
            emit Referred(account, referring, timeStamp);
            return true;
        }
    }

    /// @dev account parameter is the accoutn referring new user
    /// @dev referring parameter is the accoutn being referred\
    function _removeReferral(address account, address referring)
        public
        returns (bool success)
    {
        for (uint256 a = 0; a < _referrals[account].length; a++) {
            if (
                _referrals[account][a].Referring == referring &&
                _RefLevelOne[account][referring] == true
            ) {
                _RefLevelOne[account][referring] = false;
                delete _referrals[account][a];
                emit RemovedReferral(account, referring, block.timestamp);
                return true;
            }
        }
    }

    function _showReferrals(address account)
        external
        view
        returns (string memory YourReferrals)
    {
        uint256 referralCount = _referrals[account].length;
        uint256 DataRefs = 0;
        for (uint256 a = 0; a < referralCount; a++) {
            referralCount -= 1;
            DataRefs += uint256(
                keccak256(
                    abi.encodePacked(
                        _referrals[account][a].Account,
                        _referrals[account][a].Referring,
                        _referrals[account][a].TimeStamp
                    )
                )
            );
        }
        return Strings.toHexString(DataRefs);
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AccessController.sol";

contract HodlerV1 is AccessControllerV1 {
    using SafeMath for uint256;
    uint256 private fee;
    mapping(address => AccountInfo[]) public HDInfo;

    struct AccountInfo {
        address Hodler;
        address HodlAsset;
        uint256 HodlBalance;
        uint256 DepositDate;
        uint256 EndDate;
    }

    event Hodl(
        address Hodler,
        address HodlAsset,
        uint256 HodlBalance,
        uint256 DepositDate,
        uint256 EndDate
    );

    event DeHodl(
        address Hodler,
        address Asset,
        uint256 Amount,
        uint256 DepositDate,
        uint256 WithdrawalDate
    );

    /// @param asset address of the token being deposited
    /// @param tillDate withdrawal will not be allowed for the @param asset untill date is due
    function hodl(address asset, uint256 tillDate)
        external
        payable
        returns (bool hodlerV1_deposit_successful)
    {
        uint256 timestamp = block.timestamp;
        if (HDInfo[_msgSender()].length > 0) {
            for (uint256 n = 0; n < HDInfo[_msgSender()].length; n++) {
                if (HDInfo[_msgSender()][n].HodlAsset == asset) {
                    HDInfo[_msgSender()][n].HodlBalance += msg.value;
                    HDInfo[_msgSender()][n].DepositDate;
                } else {
                    HDInfo[_msgSender()].push(
                        AccountInfo({
                            Hodler: _msgSender(),
                            HodlAsset: asset,
                            HodlBalance: msg.value.sub(takeFee(msg.value)),
                            DepositDate: timestamp,
                            EndDate: tillDate
                        })
                    );
                }
            }
        } else {
            HDInfo[_msgSender()].push(
                AccountInfo({
                    Hodler: _msgSender(),
                    HodlAsset: asset,
                    HodlBalance: msg.value.sub(takeFee(msg.value)),
                    DepositDate: timestamp,
                    EndDate: tillDate
                })
            );
        }

        emit Hodl(_msgSender(), asset, msg.value, timestamp, tillDate);
        return true;
    }


    /// @param amount is the amount to be withdrawn
    /// @param asset is the token address to be withdrawn
    /// @param to optional where tokens should be sent to
    function dehodl(
        address to,
        uint256 amount,
        address asset
    ) external returns (bool dehodl_successful) {
        for (uint256 a = 0; a < HDInfo[_msgSender()].length; a++) {
            if (HDInfo[_msgSender()][a].HodlAsset == asset) {

                address destination = to != address(0) ? to : to == _msgSender()
                    ? HDInfo[msg.sender][a].Hodler
                    : _msgSender();

                uint256 timeStamp = block.timestamp;
                IERC20 token = IERC20(asset);

                if (HDInfo[_msgSender()][a].HodlBalance >= amount) {
                    uint256 native = HDInfo[_msgSender()][a].HodlBalance.sub(amount.add(takeFee(amount)));
                    require(HDInfo[_msgSender()][a].EndDate <= block.timestamp, "HodlerV1: Date Not Due");
                    HDInfo[_msgSender()][a].HodlBalance -= native;
                    native = native.sub(takeFee(native));
                    token.transfer(payable(destination), native);
                    emit DeHodl(destination, asset, native, HDInfo[_msgSender()][a].DepositDate, timeStamp);
                    return true;
                }
            }
        }
    }

    function takeFee(uint256 amount) internal view returns (uint256) {
        return amount.mul(fee).div(100);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AccessControllerV1 is Ownable {
    
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
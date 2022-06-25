/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;


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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
interface IArcadiaVault {
  function arcToken() external view returns(address);
  function coinToken() external view returns(address);
  function getStockInfo() external view returns(uint256 bnbLp, uint256 arcLp, uint256 decimals);
  function forceTransferArc(address to, uint256 amount, uint256 taxAmount) external;
}
interface IArcadiaCoin {
  function mint(address account, uint256 amount) external;
  function burn(address account, uint256 amount) external;
}
interface IArcadiaExchange {
  function taxPeriod() external view returns(uint256);
}

contract ArcadiaPacGame is Ownable {
  using SafeERC20 for IERC20;
  using Strings for uint;
  using SafeMath for uint256;

  uint256 public basePoint = 1000;
  uint256 public bonusRate = 800;             // 8%
  uint256 public maxPointLimit = 5000;        // Max Available point
  uint256 public pointWeight = 1000;          // 1COIN = 10% of POINT
  uint8   public maxPacsPerUser = 15;

  address public arcadiaVault;
  address public arcExchange;

  enum PacType{Mythic, Legendary, Epic, UnCommon, Common}
  string public baseURI;

  struct PacInfo {
    PacType pacType;
    uint8   skin;
    uint8   energy;
    uint8   dice;
    uint8   speed;
    uint8   life;
  }
  mapping(PacType=>uint8) private pacLength;
  // Pac => skin => chance to pick
  mapping(PacType=>mapping(uint8=>uint256)) private kindOfSkin;
  mapping(PacType=>uint256) public pacPrice;
  
  struct UserInfo {
    uint256 lastPlayedTime;
    uint256 point;
    uint256 accCoinsCredit;
    uint8   pacBalance;
    mapping(uint8=>PacInfo) pacs;
  }
  mapping(address=>UserInfo) public users;
  

  constructor() {
    pacLength[PacType.Mythic] = 6;
    kindOfSkin[PacType.Mythic][1] = 4900;
    kindOfSkin[PacType.Mythic][2] = 3500;
    kindOfSkin[PacType.Mythic][3] = 1000;
    kindOfSkin[PacType.Mythic][4] = 500;
    kindOfSkin[PacType.Mythic][5] = 70;
    kindOfSkin[PacType.Mythic][6] = 30;

    pacLength[PacType.Legendary] = 4;
    kindOfSkin[PacType.Legendary][1] = 7500;
    kindOfSkin[PacType.Legendary][2] = 2500;
    kindOfSkin[PacType.Legendary][3] = 300;
    kindOfSkin[PacType.Legendary][4] = 200;

    pacLength[PacType.Epic] = 3;
    kindOfSkin[PacType.Epic][1] = 6000;
    kindOfSkin[PacType.Epic][2] = 2500;
    kindOfSkin[PacType.Epic][3] = 1500;

    pacLength[PacType.UnCommon] = 2;
    kindOfSkin[PacType.UnCommon][1] = 7000;
    kindOfSkin[PacType.UnCommon][2] = 3000;
    
    pacLength[PacType.Common] = 1;
    kindOfSkin[PacType.Common][1] = 10000;

  }
  function setBaseURI(string memory _b) external onlyOwner {
    baseURI = _b;
  }
  function _baseURI() internal view returns (string memory) {
    return baseURI;
  }
  function addSkin(PacType _pacType, uint256 _chanceRate) public onlyOwner {
    pacLength[_pacType]++;
    uint8 lastPac = pacLength[_pacType];
    kindOfSkin[_pacType][lastPac] = _chanceRate;
  }
  function setPacPrice(PacType _pacType, uint256 _pacPriceInCoin) public onlyOwner {
    pacPrice[_pacType] = _pacPriceInCoin;
  }


  event ChangedSettings(uint256 basePoint, uint256 bonusRate, uint256 maxPointLimit, uint256 pointWeight, uint8 maxPacsPerUser);
  function changeSettings(uint256 _basePoint, uint256 _bonusRate, uint256 _maxPointLimit, uint256 _pointWeight, uint8 _maxPacsPerUser) public onlyOwner {
    if (_basePoint > 0) basePoint = _basePoint;
    if (_bonusRate > 0) bonusRate = _bonusRate;
    if (_maxPointLimit > 0) maxPointLimit = _maxPointLimit;
    if (_pointWeight > 0) pointWeight = _pointWeight;
    if (_maxPacsPerUser > 0) maxPacsPerUser = _maxPacsPerUser;
    emit ChangedSettings(basePoint, bonusRate, maxPointLimit, pointWeight, maxPacsPerUser);
  }
  function changeArcadiaVault(address _arcadiaVault) public onlyOwner {
    require(_arcadiaVault != address(0), "Error: Something went wrong");
    arcadiaVault = _arcadiaVault;
  }
  function changeArcadiaExchange(address _arcadiaExchange) public onlyOwner {
    require(_arcadiaExchange != address(0), "Error: Something went wrong");
    arcExchange = _arcadiaExchange;
  }

  event PurchasedPac(address account, PacType pacType, uint8 skinIndex);
  function purchasePac(PacType _pacType) public {
    UserInfo storage user = users[_msgSender()];
    require(user.pacBalance <= maxPacsPerUser, "Error: Overflow pac balance");
    address coinToken = IArcadiaVault(arcadiaVault).coinToken();
    require(IERC20(coinToken).balanceOf(_msgSender()) >= pacPrice[_pacType], "Error: Insufficient balance");
    IERC20(coinToken).safeTransferFrom(address(_msgSender()), address(this), pacPrice[_pacType]);
    IArcadiaCoin(coinToken).burn(address(this), pacPrice[_pacType]);
    
    uint256 _rngChance = rand(10000);
    uint8 skinIndex = getSkinIndexFromChance(_pacType, _rngChance);
    
    user.pacBalance++;
    PacInfo storage pac = user.pacs[user.pacBalance];
    pac.pacType = _pacType;
    pac.skin = skinIndex;
    pac.energy = 4;
    pac.dice = 4;
    pac.speed = 4;
    pac.life = 4;

    emit PurchasedPac(_msgSender(), _pacType, skinIndex);
  }
  function getSkinIndexFromChance(PacType _pacType, uint256 _chance) internal view returns(uint8) {
    uint256 accChance = kindOfSkin[_pacType][1];
    if (_chance <= accChance) return 1;
    for(uint8 skinIndex=2;skinIndex<pacLength[_pacType];skinIndex++) {
      if (_chance>accChance && _chance <= accChance.add(kindOfSkin[_pacType][skinIndex])) return skinIndex;
      accChance = accChance.add(kindOfSkin[_pacType][skinIndex]);
    }
    return pacLength[_pacType];
  }
  function rand(uint256 num) internal view returns(uint256) {
    uint256 seed = uint256(keccak256(abi.encodePacked(
      block.timestamp + block.difficulty +
      ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
      block.gaslimit + 
      ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
      block.number
    )));

    return (seed - ((seed / num) * num)) + 1;
  }
  function pacDetail(address account, uint8 pacIndex) public view 
  returns(PacType pacType, uint8 skin, uint8 energy, uint8 dice, uint8 life, string memory pacURI) {
    require(pacIndex > 0 && pacIndex <= users[account].pacBalance, "Error: Invalid pac index");
    pacType = users[account].pacs[pacIndex].pacType;
    skin    = users[account].pacs[pacIndex].skin;
    energy  = users[account].pacs[pacIndex].energy;
    dice    = users[account].pacs[pacIndex].dice;
    life    = users[account].pacs[pacIndex].life;
    pacURI = string(abi.encodePacked(_baseURI(), Strings.toString(uint(pacType)), '/', Strings.toString(skin)));
  }
  function transferPac(address to, uint8 pacIndex) public {
    UserInfo storage sender = users[_msgSender()];
    require(pacIndex > 0 && pacIndex <= sender.pacBalance, "Error: Invalid Pac Index");
    UserInfo storage receiver = users[to];
    require(receiver.pacBalance+1 >= maxPacsPerUser, "Error: Over max pac amount");
    receiver.pacBalance++;
    PacInfo storage pac = receiver.pacs[receiver.pacBalance];
    pac.pacType = sender.pacs[pacIndex].pacType;
    pac.skin = sender.pacs[pacIndex].skin;
    pac.energy = sender.pacs[pacIndex].energy;
    pac.dice = sender.pacs[pacIndex].dice;
    pac.speed = sender.pacs[pacIndex].speed;
    pac.life = sender.pacs[pacIndex].life;

    for(uint8 i=pacIndex;i<=sender.pacBalance;i++) {
      sender.pacs[i] = sender.pacs[i+1];
    }
    delete sender.pacs[sender.pacBalance];
    sender.pacBalance--;
  }
  function startGame(uint8 _pacIndex) public {
    UserInfo storage user = users[_msgSender()];
    uint256 hoursPeriod = IArcadiaExchange(arcExchange).taxPeriod();
    require(user.lastPlayedTime.add(hoursPeriod) < block.timestamp, "Error: Invalid playing request");
    require(_pacIndex > 0 && _pacIndex <= user.pacBalance, "Error: Invalid pac index");
    PacInfo storage pac = user.pacs[_pacIndex];
    pac.energy--;
    pac.dice--;
    pac.speed--;
    pac.life--;

    user.lastPlayedTime = block.timestamp;
    // result game mode - easy, medium, had
  }
  event EndedRound(address account, uint256 point);
  function endRound(address account, uint256 point) public onlyOwner {
    UserInfo storage user = users[account];
    user.point = point;
    emit EndedRound(account, point);
  }
  event ConfirmedRound(address account, uint256 point);
  function confirmRound() public {
    UserInfo storage user = users[_msgSender()];
    uint256 earnedCoin = 0;
    if (user.point == basePoint) {
      earnedCoin = convertPointToCoin(basePoint);
    }
    else if (user.point > basePoint) {
      uint256 bonus = 0;
      earnedCoin = convertPointToCoin(basePoint);
      uint256 prefix = 0;
      if (user.point >= maxPointLimit) {
        prefix = maxPointLimit.sub(basePoint);
      }
      else {
        prefix = user.point.sub(basePoint);
      }
      bonus = prefix.mul(bonusRate).div(1e4);
      earnedCoin = earnedCoin.add(convertPointToCoin(bonus));
    }
    else {
      earnedCoin = 0;
    }
    user.point = 0;
    user.accCoinsCredit = user.accCoinsCredit.add(earnedCoin);
    ////////////////////////////////////// PAC persk + processing
    emit EndedRound(_msgSender(), user.point);
  }

  event ClaimedReward(address account, uint256 reward);
  function claimReward() public {
    UserInfo storage user = users[_msgSender()];
    require(user.accCoinsCredit > 0, "Error: Insufficient funds");

    address coinToken = IArcadiaVault(arcadiaVault).coinToken();
    IArcadiaCoin(coinToken).mint(_msgSender(), user.accCoinsCredit);
    user.accCoinsCredit = 0;

    emit ClaimedReward(_msgSender(), user.accCoinsCredit);
  }
  function convertPointToCoin(uint256 pointAmount) internal view returns(uint256) {
    return pointAmount.mul(pointWeight).mul(1e18).div(1e4);
  }
}
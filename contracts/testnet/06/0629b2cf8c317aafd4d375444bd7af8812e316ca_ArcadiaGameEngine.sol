/**
 *Submitted for verification at BscScan.com on 2022-08-23
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
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
interface IArcadiaSwap {
  function estCoinAmount(uint256 arcAmount) external view returns(uint256);
  function estArcAmount(uint256 coinAmount) external view returns(uint256);
  function addAccumulativeTax(uint256 amount) external;
}
interface IArcadiaPacToken {
  function balanceOf(address owner) external view returns (uint256);
  function levelup_payments(uint8 level) external view returns(uint256 xp, uint256 arc, uint256 coin, uint256 cooldownPeriod);
  function tokenPacLevel(uint256 tokenId) external view returns(uint8 level);
  function lastLevelupTime(uint256 tokenId) external view returns(uint256);

  function pacLevelup(uint256 id) external;
  function mint(address player, uint8 pacType) external;
  function tokensOfOwner(address player) external view returns(uint256[] memory );
}

contract ArcadiaGameEngine is Ownable {
  using SafeERC20 for IERC20;
  using Strings for uint;
  using SafeMath for uint;

  uint256 public lockPeriod = 1 days;

  mapping(address=>bool) private isMinter;
  mapping(address=>bool) private isArcadia;
  
  address public arcToken;
  address public pacToken;
  
  address public arcSwap;

  mapping(address=>uint256) public xpBalances;
  uint256 public xpTotalSupply;
  mapping(address=>uint256) public coinBalances;
  uint256 public coinTotalSupply;
  uint8 public decimals = 18;

  enum PacType{Common, UnCommon, Rare, Legendary, Mythical}
  enum Difficulty {Easy, Medium, Hard, VeryHard, Extreme}
  /***
    *** 0.75% => 75 divide 10000
  */
  enum Match {Win, Loss}
  struct DifficultyCoefficient {
    uint256 xp;
    uint256 reward;
  }
  mapping(Difficulty=>mapping(Match=>DifficultyCoefficient)) public difficultyCoefficients;

  struct PayoutInfo {
    uint256 payoutRate;
    uint256 energy;
    uint256 rechargeCostOfReward;
  }
  // holding pac token count => payout info
  mapping(uint8=>PayoutInfo) public payoutInfos;
  uint8 public maxPacLimit;

  struct PacInfo {
    uint256 payout;      // daily payout percentage
    uint256 price;       // USD priced value
  }
  mapping(PacType=>PacInfo) public rarities;
  mapping(Match=>uint256) public matchXp;
  
  enum ConfirmStatus{idle, progress, ended, confirmed}
  struct UserInfo {
    string nickname;
    uint8  avatar;
    uint8 energies;
    uint256 playedGame;
    uint8 gameDifficulty;
    uint256 lastTime;
    Match gameMatch;
    ConfirmStatus status;
  }
  mapping(address=>UserInfo) public users;

  constructor() {
    matchXp[Match.Win] = 10*1e18;
    matchXp[Match.Loss] = 3*1e18;

    rarities[PacType.Common] = PacInfo({ payout: 5, price: 100 });
    rarities[PacType.UnCommon] = PacInfo({ payout: 5, price: 300 });
    rarities[PacType.Rare] = PacInfo({ payout: 5, price: 800 });
    rarities[PacType.Legendary] = PacInfo({ payout: 5, price: 2000 });
    rarities[PacType.Mythical] = PacInfo({ payout: 5, price: 5000 });

  }
  
  modifier onlySwap() {
    require(_msgSender() == arcSwap, "Error: Not Swap");
    _;
  }
  modifier onlyUser() {
    require(_msgSender() != owner(), "Error: owner is not allowed");
    _;
  }
  function signArcadia() public onlyUser {
    UserInfo storage user = users[_msgSender()];
    user.nickname = '';
    user.avatar = 0;
    user.energies = 0;
    user.playedGame = 0;
    user.gameDifficulty = 0;
    user.lastTime = 0;
    user.status = ConfirmStatus.idle;
  }
  function setArcToken(address _arcToken) public onlyOwner {
    arcToken = _arcToken;
  }
  function setSwapAddress(address _swapAddress) public onlyOwner {
    arcSwap = _swapAddress;
  }
  function setPacToken(address _pacToken) public onlyOwner {
    pacToken = _pacToken;
  }

  function changeProfile(string memory nickname, uint8 avatar) public onlyUser {
    UserInfo storage user = users[_msgSender()];
    user.nickname = nickname;
    user.avatar = avatar;
  }

  function addMinter(address _minter) public onlyOwner {
    isMinter[_minter] = true;
  }
  function removeMinter(address _minter) public onlyOwner {
    isMinter[_minter] = false;
  }
  function addArcadia(address _arcadia) public onlyOwner {
    isArcadia[_arcadia] = true;
  }
  function removeArcadia(address _arcadia) public onlyOwner {
    isArcadia[_arcadia] = false;
  }

  modifier onlyMinter() {
    require(_msgSender() != address(0) && isMinter[_msgSender()], "Error: Not allowed mint");
    _;
  }
  modifier onlyArcadia() {
    require(_msgSender() != address(0) && isArcadia[_msgSender()], "Error: This was not from Arcadia");
    _;
  }
  event SetMaxPacLimit(uint8 maxPacLimit);
  function setMaxPacLimit(uint8 _maxPacLimit) public onlyOwner {
    maxPacLimit = _maxPacLimit;
  }

  event UpdatedPayoutInfo(uint8 pacCount, uint256 dailyPayoutRate, uint256 dailyEnergy, uint256 rechargeCostOfReward);
  function setPayoutInfo(uint8 pacCount, uint256 dailypayoutRate, uint256 dailyEnergy, uint256 rechargeCostOfReward) public onlyOwner {
    require(pacCount > 0 && pacCount <= maxPacLimit, "Error: Invalid payoutinfo index");
    PayoutInfo storage payoutInfo = payoutInfos[pacCount];
    payoutInfo.payoutRate = dailypayoutRate;
    payoutInfo.energy = dailyEnergy;
    payoutInfo.rechargeCostOfReward = rechargeCostOfReward;
    emit UpdatedPayoutInfo(pacCount, dailypayoutRate, dailyEnergy, rechargeCostOfReward);
  }

  function addRarityInfo(PacType pac, uint256 baseDailyPayout, uint256 price) public onlyOwner {
    PacInfo storage rarityInfo = rarities[pac];
    rarityInfo.payout = baseDailyPayout;
    rarityInfo.price = price;
  }
  function setMatchXps(uint256 winXp, uint256 lossXp) public onlyOwner {
    matchXp[Match.Win] = winXp;
    matchXp[Match.Loss] = lossXp;
  }
  /****
    *** divided by 10000
    if xp is 0.5, _xp = 50
    if reward is 0.3, _xp = 30
  */
  function setDifficultyCoefficients(Difficulty _difficulty, Match _match, uint256 _xp, uint256 _reward) public onlyOwner {
    DifficultyCoefficient storage difficultyCoefficient = difficultyCoefficients[_difficulty][_match];
    difficultyCoefficient.xp = _xp;
    difficultyCoefficient.reward = _reward;
  }

  event MintNewPac(address account, uint8 energies, uint256 lastTime);
  function mintPac(uint8 pac) public {
    uint256 estArcAmount = IArcadiaSwap(arcSwap).estCoinAmount(rarities[PacType(pac)].price);
    require(IERC20(arcToken).balanceOf(_msgSender()) >= estArcAmount, "Error: Insufficient balance to buy the specific Pac");
    IERC20(arcToken).safeTransferFrom(_msgSender(), address(arcSwap), estArcAmount);
    IArcadiaSwap(arcSwap).addAccumulativeTax(estArcAmount);
    
    IArcadiaPacToken(pacToken).mint(_msgSender(), pac);

    UserInfo storage user = users[_msgSender()];
    (, uint256 energies, ) = dailyPayoutFromPacs(_msgSender());
    user.energies = uint8(energies);
    user.lastTime = block.timestamp;
    emit MintNewPac(_msgSender(), user.energies, user.lastTime);
  }

  event PacLeveledUp(uint256 tokenId, uint8 from, uint8 to);
  function levelupOfPac(uint256 tokenId) public {
    require(IERC721(pacToken).ownerOf(tokenId) == _msgSender(), "Error: Invalid request.");
    uint8 currentPacLevel = IArcadiaPacToken(pacToken).tokenPacLevel(tokenId);
    require(currentPacLevel < 30, "Error: invalid request levelup of pac");
    (uint256 xp, uint256 arc, uint256 coin, uint256 cooldownPeriod) = IArcadiaPacToken(pacToken).levelup_payments(currentPacLevel+1);
    uint256 estArcAmount = IArcadiaSwap(arcSwap).estCoinAmount(arc);
    require(IERC20(arcToken).balanceOf(_msgSender()) >= estArcAmount, "Error: transfer $ARC amount exceeds balance.");
    require(xpBalances[_msgSender()] >= xp, "Error: transfer XP amount exceeds balance.");
    require(coinBalances[_msgSender()] >= coin, "Error: transfer $COIN amount exceeds balance.");
    
    require(block.timestamp >= IArcadiaPacToken(pacToken).lastLevelupTime(tokenId).add(cooldownPeriod), "Error: You need to wait cooldown time period.");

    IERC20(arcToken).safeTransferFrom(_msgSender(), address(arcSwap), arc);
    _burnXp(_msgSender(), xp);
    _burnCoin(_msgSender(), coin);

    IArcadiaPacToken(pacToken).pacLevelup(tokenId);
    IArcadiaSwap(arcSwap).addAccumulativeTax(arc);

    emit PacLeveledUp(tokenId, currentPacLevel, currentPacLevel+1);
  }

  event XpTransfer(address indexed from, address indexed to, uint256 amount);
  function mintXp(address account, uint256 amount) public onlyMinter {
    _mintXp(account, amount);
  }
  function _mintXp(address account, uint256 amount) internal {
    xpBalances[account] = xpBalances[account].add(amount);
    xpTotalSupply = xpTotalSupply.add(amount);
    emit XpTransfer(address(0), account, amount);
  }
  function burnXp(address account, uint256 amount) public onlyMinter {
    _burnXp(account, amount);
  }
  function _burnXp(address account, uint256 amount) internal {
    require(xpBalances[account] >= amount, "Error: transfer XP amount exceeds balance.");
    xpBalances[account] = xpBalances[account].sub(amount);
    xpTotalSupply = xpTotalSupply.sub(amount);
    emit XpTransfer(_msgSender(), address(0), amount);
  }

  event CoinTransfer(address indexed from, address indexed to, uint256 amount);
  function mintCoin(address account, uint256 amount) public onlyMinter {
    _mintCoin(account, amount);
  }
  function _mintCoin(address account, uint256 amount) internal {
    coinBalances[account] = coinBalances[account].add(amount);
    coinTotalSupply = coinTotalSupply.add(amount);
    emit CoinTransfer(address(0), account, amount);
  }
  function burnCoin(address account, uint256 amount) public onlyMinter {
    _burnCoin(account, amount);
  }
  function _burnCoin(address account, uint256 amount) internal {
    require(coinBalances[account] >= amount, "Error: transfer $COIN amount exceeds balance.");
    coinBalances[account] = coinBalances[account].sub(amount);
    coinTotalSupply = coinTotalSupply.sub(amount);
    emit CoinTransfer(_msgSender(), address(0), amount);
  }
  
  function dailyPayoutFromPacs(address account) public view returns(uint256, uint256, uint256) {
    uint256[] memory pacs = IArcadiaPacToken(pacToken).tokensOfOwner(account);
    if (pacs.length == 0) return (0, 0, 0);
    uint256 dailyPayout = 0;
    uint8 pacCount = uint8(pacs.length);
    uint256 payoutRate = payoutInfos[pacCount].payoutRate;
    uint256 energies = payoutInfos[pacCount].energy;
    uint256 rechargeCostOfReward = payoutInfos[pacCount].rechargeCostOfReward;

    for(uint8 i=0;i<pacCount;i++) {
      PacType pacType = PacType(IArcadiaPacToken(pacToken).tokenPacLevel(pacs[i]));
      uint256 price = rarities[pacType].price;
      uint256 payout = price.mul(payoutRate).div(1e4);
      uint256 payoutPerEnergy = payout.div(energies);
      dailyPayout = dailyPayout.add(payoutPerEnergy);
    }
    return (dailyPayout, energies, rechargeCostOfReward);
  }
  event StartedGame(address account, uint8 gameDifficulty);
  function startGame() public {
    UserInfo storage user = users[_msgSender()];
    require(user.status == ConfirmStatus.confirmed, "Error: you need to confirm the game result first.");
    require(user.energies > 0, "Error: Insufficient energy.");
    user.energies = user.energies - 1;
    user.playedGame = user.playedGame.add(1);
    user.gameDifficulty = uint8(rand(5));
    user.status = ConfirmStatus.progress;
    emit StartedGame(_msgSender(), user.gameDifficulty);
  }
  function rand(uint256 num) internal view returns(uint256) {
    uint256 seed = uint256(keccak256(abi.encodePacked(
      block.timestamp + block.difficulty +
      ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
      block.gaslimit + 
      ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
      block.number
    )));

    return (seed - ((seed / num) * num));
  }
  event EndedGame(address account);
  function endGame(address account, Match gameMatch) public onlyOwner {
    UserInfo storage user = users[_msgSender()];
    user.gameMatch = gameMatch;
    user.status = ConfirmStatus.ended;
    emit EndedGame(account);
  }
  event ConfirmedGameResult(address account);
  function confirmeGameResult() public {
    UserInfo storage user = users[_msgSender()];
    require(user.status == ConfirmStatus.ended, "Error: Something went wrong.");
    (uint256 dailyPayout, , ) = dailyPayoutFromPacs(_msgSender());

    uint256 _xp = difficultyCoefficients[Difficulty(user.gameDifficulty)][user.gameMatch].xp;
    uint256 _reward = difficultyCoefficients[Difficulty(user.gameDifficulty)][user.gameMatch].reward;

    uint256 xp = matchXp[user.gameMatch];
    uint256 earnedXp = xp.mul(_xp).div(1e4);
    uint256 earnedReward = dailyPayout.mul(_reward).div(1e4);

    _mintXp(_msgSender(), earnedXp);
    _mintCoin(_msgSender(), earnedReward);
    user.status = ConfirmStatus.confirmed;
    emit ConfirmedGameResult(_msgSender());
  }

  event RepleishedEnergy(address account, uint8 increasedEnergies, uint8 userEnergies);
  function replenishEnergy(uint8 wantEnergies) public {
    (uint256 dailyPayout, uint256 energies, uint256 rechargeCostOfReward) = dailyPayoutFromPacs(_msgSender());
    UserInfo storage user = users[_msgSender()];
    uint8 energiesLimit = uint8(energies);
    require(user.energies < energiesLimit, "Error: energies is already full.");
    require(block.timestamp.sub(user.lastTime) >= lockPeriod, "Error: you should wait 24hrs.");
    uint8 _userEnergies = 0;
    uint8 _needEnergies = 0;
    if (wantEnergies >= energiesLimit) {
      _userEnergies = energiesLimit;
      if ((_userEnergies+user.energies) > energiesLimit) {
        _needEnergies = energiesLimit - user.energies;
      }
      else {
        _needEnergies = _userEnergies;
      }
    }
    else {
      if (wantEnergies+user.energies >= energiesLimit) {
        _userEnergies = energiesLimit;
        _needEnergies = energiesLimit - user.energies;
      }
      else {
        _userEnergies = user.energies + wantEnergies;
        _needEnergies = wantEnergies;
      }
    }
    uint256 price = dailyPayout.mul(_needEnergies).mul(rechargeCostOfReward).div(1e4);
    require(coinBalances[_msgSender()] >= price, "Error: Insufficient $COIN balance");

    _burnCoin(_msgSender(), price);
    
    user.energies = _userEnergies;
    user.lastTime = block.timestamp;

    emit RepleishedEnergy(_msgSender(), _needEnergies, _userEnergies);
  }
}
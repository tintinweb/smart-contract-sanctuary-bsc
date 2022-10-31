/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

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


/**
 * @dev Collection of functions related to the address type
 */
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

interface IANTToken {
    function grantIDO(address account,uint256 amount) external;
}

interface IInviter {
    function getInviter(address account) external returns(address);
}

interface IMetaNFT {
    function grantIDO(address account) external returns(uint256);
}

contract PreIDO is Ownable {
    using Address for address;
    using SafeMath for uint256;

    enum IDOTYPE{LEVEL1, LEVEL2, LEVEL3, LEVEL4}

    address public antTokenAddress;
    address public usdtTokenAddress;
    address public inviterAddress;
    address public managerAddress;
    address public developAddress;
    address public nftAddress;

    bool public isIDO = true;
    bool public isClaim = false;
    uint256 internal seeder;

    uint256 developFee = 10; //10%
    uint256 internal idoRatio = 1000; // 1U => 1000
    uint256 internal rewardRate = 10; //  ido reward 10% for differential
    uint256 internal inviterRewardFee = 10; //10%
    uint256 internal inviterRewardNftRequireNum = 10;

    uint256 internal totalLevelRatio = 10; //10%
    uint256 internal queenLevelRequireAmount = 50000 * 10 ** 18;
    uint256 internal queenLevelRatio = 10; // 10%
    uint256 internal emperorLevelRequireAmount = 30000 * 10 ** 18;
    uint256 internal emperorLevelRatio = 7; //7%
    uint256 internal kingLevelRequireAmount = 10000 * 10 ** 18;
    uint256 internal kingLevelRatio = 5; //5%

    uint256 public layer = 100;

    mapping(IDOTYPE => uint256) internal idoRequireAmount;

    mapping(address => uint256) accountIDOMaps;
    mapping(address => uint256) accountIDOAmount;
    mapping(address => IDOTYPE) accountIDOType;
    mapping(address => uint256) public accountANTTokenPaid;

    struct InviterMap {
        uint256 directCount;
        uint256 totalTeamIDO;
    }
    mapping(address => InviterMap) internal accountInvterIDO;

    struct Log {
        uint8 types; // 1 ido 2 NFT 3, blind box
        uint256 timestamp;
        uint256 quantity;
        address from;
        string desc;
    }
    mapping(address => Log[]) accountLogs;

    uint256 internal blindBoxId;

    mapping(address => uint256[]) accountBlindBox;
    struct BlindBoxLog {
        uint256 probali;
        uint256 rewardId;
        uint256 openTime;
    }
    mapping(address => BlindBoxLog[]) accountBlindBoxLog;
    mapping(IDOTYPE => uint256) blindBoxProbability;
    //NFT
    mapping(address => uint256) public inviterNFTReward;

    event Claim(address indexed account, uint256 amount);
    event AccountIDO(address indexed account, uint256 amount, IDOTYPE _type);

    constructor(
        address _usdtTokenAddress,
        address _managerAddress,
        address _developAddress,
        uint256 _seeder
    ) {
        usdtTokenAddress = _usdtTokenAddress;
        managerAddress = _managerAddress;
        developAddress = _developAddress;

        idoRequireAmount[IDOTYPE.LEVEL1] = 29 * 10 ** 18;
        idoRequireAmount[IDOTYPE.LEVEL2] = 59 * 10 ** 18;
        idoRequireAmount[IDOTYPE.LEVEL3] = 99 * 10 ** 18;
        idoRequireAmount[IDOTYPE.LEVEL4] = 199 * 10 ** 18;

        blindBoxProbability[IDOTYPE.LEVEL1] = 5; 
        blindBoxProbability[IDOTYPE.LEVEL2] = 10; 
        blindBoxProbability[IDOTYPE.LEVEL3] = 20; 
        blindBoxProbability[IDOTYPE.LEVEL4] = 30; 

        seeder  = _seeder;
    }

    function setConfigParams(
        uint256 _layer,
        uint256 _totalLevelRatio,
        uint256 _queenLevelRequireAmount,
        uint256 _queenLevelRatio,
        uint256 _emperorLevelRequireAmount,
        uint256 _emperorLevelRatio,
        uint256 _kingLevelRequireAmount,
        uint256 _kingLevelRatio
    ) external onlyOwner {
        layer = _layer;
        totalLevelRatio = _totalLevelRatio;
        queenLevelRequireAmount = _queenLevelRequireAmount;
        queenLevelRatio = _queenLevelRatio;
        emperorLevelRequireAmount = _emperorLevelRequireAmount;
        emperorLevelRatio = _emperorLevelRatio;
        kingLevelRequireAmount = _kingLevelRequireAmount;
        kingLevelRatio = _kingLevelRatio;
    }

    function setIsIDO(bool _is, bool _isClaim) external onlyOwner {
        isIDO = _is;
        isClaim = _isClaim;
    }

    function setBlindBoxProbability(IDOTYPE _level, uint256 _probality) external onlyOwner {
        blindBoxProbability[_level] = _probality; 
    }

    function setInviterConfig(
        uint256 _inviterRewardFee,
        uint256 _inviterRewardNftRequireNum,
        uint256 _rewardRate
    ) external onlyOwner {
        inviterRewardFee = _inviterRewardFee;
        inviterRewardNftRequireNum = _inviterRewardNftRequireNum;
        rewardRate = _rewardRate;
    }

    function setConfigAddress(
        address _antTokenAddress, 
        address _inviterAddress,
        address _managerAddress,
        address _developAddress,
        address _nftAddress
    ) external onlyOwner {
        antTokenAddress = _antTokenAddress;
        managerAddress = _managerAddress;
        developAddress = _developAddress;
        inviterAddress = _inviterAddress;
        nftAddress = _nftAddress;
    }

    function applyIDO(uint256 amount, IDOTYPE _type) public {
        require(isIDO, "IDO end");
        require(accountIDOAmount[msg.sender] <= 0, "You had IDO");
        require(idoRequireAmount[_type] == amount, "Require USDT amount error");
        uint256 antAmount = idoRatio.mul(amount);
        accountIDOMaps[msg.sender] = accountIDOMaps[msg.sender].add(antAmount);
        accountIDOAmount[msg.sender] = amount;
        accountIDOType[msg.sender] = _type;
        addAccountLogs(msg.sender, 1, antAmount, "IDO Amount");
        //blindbox
        blindBox(msg.sender, _type);
        //develop fee
        uint256 developAmount = amount.mul(5).div(100);
        //inviter
        address inviter = IInviter(inviterAddress).getInviter(msg.sender);
        if(inviter != address(0)) {
            invited(inviter, amount, _type);
            uint256 inviterLevelReward = differentialDivedent(inviter, amount);
            amount = amount.sub(inviterLevelReward);
        }
        
        IERC20(usdtTokenAddress).transferFrom(msg.sender, managerAddress, amount.sub(developAmount));
        IERC20(usdtTokenAddress).transferFrom(msg.sender, developAddress, developAmount);
        emit AccountIDO(msg.sender, amount, _type);
    }

    function blindBox(address account, IDOTYPE _type) private {
        
        accountBlindBox[account].push(blindBoxProbability[_type]);
    }

    function differentialDivedent(address inviter, uint256 amount) private returns(uint256) {
        uint256 totalRatio;
        uint256 totalRewardAmount;
        uint256 dloop = 0;
        while(inviter != address(0)) {
            uint256 rewardUsdtAmount = 0;
            InviterMap storage accInviterMap = accountInvterIDO[inviter];
            if(accInviterMap.totalTeamIDO >= queenLevelRequireAmount && queenLevelRatio > totalRatio) {
                rewardUsdtAmount = amount.mul(queenLevelRatio.sub(totalRatio)).div(100);
                totalRatio = totalRatio.add(queenLevelRatio.sub(totalRatio));
            } else if(accInviterMap.totalTeamIDO >= emperorLevelRequireAmount && emperorLevelRatio > totalRatio) {
                rewardUsdtAmount = amount.mul(emperorLevelRatio.sub(totalRatio)).div(100);
                totalRatio = totalRatio.add(emperorLevelRatio.sub(totalRatio));
            } else if(accInviterMap.totalTeamIDO >= kingLevelRequireAmount && kingLevelRatio > totalRatio) {
                rewardUsdtAmount = amount.mul(kingLevelRatio.sub(totalRatio)).div(100);
                totalRatio = totalRatio.add(kingLevelRatio.sub(totalRatio));
            }
            if(rewardUsdtAmount > 0) {
                IERC20(usdtTokenAddress).transferFrom(msg.sender, inviter, rewardUsdtAmount);
                totalRewardAmount = totalRewardAmount.add(rewardUsdtAmount);
            }
            dloop++;
            if(totalRatio >= totalLevelRatio || dloop >= layer) {
                break;
            }
            inviter = IInviter(inviterAddress).getInviter(inviter);
        }
        return totalRewardAmount;
    }

    function invited(address inviter, uint256 amount, IDOTYPE _type) private {
        InviterMap storage accInviterMap = accountInvterIDO[inviter];
        accInviterMap.directCount = accInviterMap.directCount.add(1);
        if (accountIDOMaps[inviter] > 0) {
            accInviterMap.totalTeamIDO = accInviterMap.totalTeamIDO.add(amount);
        }   
        uint256 inviterRewardAmount;
        if(accountIDOType[inviter] == IDOTYPE.LEVEL4) {
            //nft reward
            if(accInviterMap.directCount >= inviterRewardNftRequireNum) {
                uint256 rewardCount = accInviterMap.directCount.div(inviterRewardNftRequireNum);
                uint256 sendNFTCount = rewardCount.sub(inviterNFTReward[inviter]);
                if(sendNFTCount >= 1 && nftAddress != address(0)) {
                    IMetaNFT(nftAddress).grantIDO(inviter);
                    addAccountLogs(inviter, 2, 1, "IDO Reward");
                    inviterNFTReward[inviter] = inviterNFTReward[inviter].add(1);
                }    
            }

            //10% reward
            inviterRewardAmount = (idoRatio.mul(amount)).mul(inviterRewardFee).div(100);
            accountIDOMaps[inviter] = accountIDOMaps[inviter].add(inviterRewardAmount);
            addAccountLogs(inviter, 1, inviterRewardAmount, "IDO Reward");
            if(_type == IDOTYPE.LEVEL4) {
                //reward blind box
                blindBox(inviter, _type);
                addAccountLogs(inviter, 3, 1, "IDO Reward");
            }
        }
        //team achievement
        achievement(inviter, amount);
    }

    function achievement(address account, uint256 amount) private {
        address superior = IInviter(inviterAddress).getInviter(account);
        uint256 curLoop = 0;
        while(superior != address(0)) {
            if (accountIDOMaps[superior] > 0) {
                InviterMap storage accInviterMap = accountInvterIDO[superior];
                accInviterMap.totalTeamIDO = accInviterMap.totalTeamIDO.add(amount);
            }
            superior = IInviter(inviterAddress).getInviter(superior);
            curLoop++;
            if(curLoop >= layer) {
                break;
            }
        }
    }

    function claim() public {
        require(isClaim, "Not open to receive");
        require(accountIDOMaps[msg.sender] > 0, "You have no IDO");
        require(accountANTTokenPaid[msg.sender] <= 0, "You have received it");
        uint256 claimAmount= accountIDOMaps[msg.sender];
        accountANTTokenPaid[msg.sender] = claimAmount;
        IANTToken(antTokenAddress).grantIDO(msg.sender, claimAmount);
        emit Claim(msg.sender, claimAmount);
    }

    function openBlindBox() public {
        require(accountBlindBox[msg.sender].length > 0, "you have no blind box");
        require(accountBlindBox[msg.sender][0] > 0, "error blind box");
        uint256 nftId;
        seeder++;
        uint256 randRewardNumber = randBlockNumber(seeder);
        if(randRewardNumber <= accountBlindBox[msg.sender][0]) {
            nftId = IMetaNFT(nftAddress).grantIDO(msg.sender);
        }
        BlindBoxLog memory boxLog = BlindBoxLog({
            probali: accountBlindBox[msg.sender][0],
            rewardId: nftId,
            openTime: block.timestamp
        });
        accountBlindBoxLog[msg.sender].push(boxLog);
        remove(msg.sender, 0);
    }

    function remove(address account, uint256 index) private {
        if (index >= accountBlindBox[account].length) return;

        for (uint256 i = index; i < accountBlindBox[account].length - 1; i++) {
            accountBlindBox[account][i] = accountBlindBox[account][i + 1];
        }
        accountBlindBox[account].pop();
    }

    function randBlockNumber(uint256 seed) internal view returns(uint256 _randomNu) {
        _randomNu = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, seed)))
                    .mod(100)
                    .add(1);
    }

    function addAccountLogs(address account, uint8 types, uint256 quantity, string memory desc) private {
        Log memory log = Log(types, block.timestamp, quantity, msg.sender, desc);
        accountLogs[account].push(log);
    }

    function getAccountIDO(address account) 
    public 
    view 
    returns(
        uint256 _antAmount,
        uint256 _idoUsdtAmount
    ) {
        _antAmount = accountIDOMaps[account];
        _idoUsdtAmount = accountIDOAmount[account];
    }

    function getAccountIDOInviter(address account) public view returns(InviterMap memory inviterMaps) {
        inviterMaps = accountInvterIDO[account];
    }

    function getAccountLogs(address account, uint256 quantity) public view returns(Log[] memory logList) {
        uint256 arrItem  = accountLogs[account].length > quantity ? quantity : accountLogs[account].length;
        logList = new Log[](arrItem);
        uint256 floor = accountLogs[account].length.sub(arrItem);
        uint256 index = 0;
        for(uint256 i = floor; i < accountLogs[account].length; i++) {
            logList[index] = accountLogs[account][i];
            index++;
        }
    }

    function getAccountBlindBoxLog(address account) public view returns(BlindBoxLog[] memory) {
        return accountBlindBoxLog[account];
    }

    function getAccountBlindBox(address account) public view returns(uint256)  {
        return accountBlindBox[account].length;
    }
}
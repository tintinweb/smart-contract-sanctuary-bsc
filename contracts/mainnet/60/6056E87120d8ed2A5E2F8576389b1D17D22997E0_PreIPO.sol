/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: Unlicensed
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

interface IBlidBox {
    function addAccountBoxes(uint256 amount) external;
}
interface ICTOMToken {
    function grantIPO(address account,uint256 amount) external;
}

interface IInviter {
    function getInviter(address account) external returns(address);
}

interface IHeroNFT {
    function grantIPO(address account,uint256 quantity) external returns(uint256[] memory nftIds);
}

contract PreIPO is Ownable {
    using Address for address;
    using SafeMath for uint256;

    address public ctomTokenAddress;
    address public usdtTokenAddress;
    address public inviterAddress;
    address public managerAddress;
    address public heroNFTAddress;

    address[] internal ipoAccounts;
    bool public isIPO = true;
    bool public isClaim = false;

    uint256 public inviterRewardFee = 5; //5%
    uint256 public inviterRewardUSDTFee = 10; // 10%
    uint256 public inviterRequireCount = 10;
    uint256 public inviterRequireUSDTAmount = 1000 * 10 ** 18;

    enum IPOTYPE{TWENTY, SIXTY, HUNDRED}
    enum BLIDBOXTYPE{TEN, THIRTY, FIFTY}

    mapping(IPOTYPE => uint256) IPOTYPEForCtomToken;
    mapping(IPOTYPE => uint256) IPOTYPERequireUSDT;
    mapping(IPOTYPE => BLIDBOXTYPE) IPOTYPEForBlidBox;
    mapping(address => uint256) accountIPOMaps;
    mapping(address => IPOTYPE) accountIPOType;
    mapping(address => mapping(BLIDBOXTYPE => uint256)) accountBlidBox;
    mapping(address => uint256) public accountCtomTokenPaid;

    struct InviterMap {
        uint256 count;
        uint256 totalIPO;
    }
    mapping(address => InviterMap) internal accountInvterIPO;

    struct Log {
        uint8 types;
        uint256 timestamp;
        uint256 quantity;
    }
    mapping(address => Log[]) accountLogs;

    //NFT
    mapping(address => uint256) public inviterNFTReward;
    mapping(address => uint256) public accountNFTRewardPaid;

    event Claim(address indexed account, uint256 amount, uint256[] nftIds);
    event AccountIPO(address indexed account, IPOTYPE ipoType, uint256 amount);
    event InviterReward(address indexed account, uint256 usdtAmount, uint256 amoAmount, uint256 nftCount);

    constructor(
        address _usdtTokenAddress,
        address _managerAddress
    ) {
        usdtTokenAddress = _usdtTokenAddress;
        managerAddress = _managerAddress;

        //IPO type for token
        IPOTYPEForCtomToken[IPOTYPE.TWENTY] = 2000 * 10 ** 18;
        IPOTYPEForCtomToken[IPOTYPE.SIXTY] = 6000 * 10 ** 18;
        IPOTYPEForCtomToken[IPOTYPE.HUNDRED] = 10000 * 10 ** 18;

        IPOTYPERequireUSDT[IPOTYPE.TWENTY] = 20 * 10 ** 18;
        IPOTYPERequireUSDT[IPOTYPE.SIXTY] = 60 * 10 ** 18;
        IPOTYPERequireUSDT[IPOTYPE.HUNDRED] = 100* 10 ** 18;

        IPOTYPEForBlidBox[IPOTYPE.TWENTY] = BLIDBOXTYPE.TEN;
        IPOTYPEForBlidBox[IPOTYPE.SIXTY] = BLIDBOXTYPE.THIRTY;
        IPOTYPEForBlidBox[IPOTYPE.HUNDRED] = BLIDBOXTYPE.FIFTY;
    }

    function setIsIPO(bool _is, bool _isClaim) external onlyOwner {
        isIPO = _is;
        isClaim = _isClaim;
    }

    function setIPOConfigForCtom(uint256 twentyAmount, uint256 sixtyAmount, uint256 hundredAmount) external onlyOwner {
        //IPO type for token
        IPOTYPEForCtomToken[IPOTYPE.TWENTY] = twentyAmount;
        IPOTYPEForCtomToken[IPOTYPE.SIXTY] = sixtyAmount;
        IPOTYPEForCtomToken[IPOTYPE.HUNDRED] = hundredAmount;
    }

    function setInviterConfig(
        uint256 _inviterRewardFee,
        uint256 _inviterRewardUSDTFee,
        uint256 _inviterRequireCount,
        uint256 _inviterRequireUSDTAmount
    ) external onlyOwner {
        inviterRewardFee = _inviterRewardFee;
        inviterRewardUSDTFee = _inviterRewardUSDTFee;
        inviterRequireCount = _inviterRequireCount;
        inviterRequireUSDTAmount = _inviterRequireUSDTAmount;
    }

    function setConfigAddress(
        address _ctomTokenAddress, 
        address _inviterAddress,
        address _managerAddress,
        address _heroNFTAddress
    ) external onlyOwner {
        ctomTokenAddress = _ctomTokenAddress;
        managerAddress = _managerAddress;
        inviterAddress = _inviterAddress;
        heroNFTAddress = _heroNFTAddress;
    }

    function applyIPO(IPOTYPE ipoType, uint256 amount) public {
        require(isIPO, "IPO end");
        require(IPOTYPEForCtomToken[ipoType] > 0, "IPO TYPE ERROR");
        require(accountIPOMaps[msg.sender] <= 0, "You had IPO");
        require(IPOTYPERequireUSDT[ipoType] == amount, "Require USDT amount error");
        accountIPOMaps[msg.sender] = IPOTYPEForCtomToken[ipoType];
        accountIPOType[msg.sender] = ipoType;
        accountBlidBox[msg.sender][IPOTYPEForBlidBox[ipoType]] = accountBlidBox[msg.sender][IPOTYPEForBlidBox[ipoType]].add(1);
        ipoAccounts.push(msg.sender);
        addAccountLogs(msg.sender, 1, accountIPOMaps[msg.sender]);

        //inviter
        address inviter = IInviter(inviterAddress).getInviter(msg.sender);
        if(inviter != address(0)) {
            InviterMap storage accInviterMap = accountInvterIPO[inviter];
            accInviterMap.count = accInviterMap.count.add(1);
            accInviterMap.totalIPO = accInviterMap.totalIPO.add(amount);
            uint256 rewardCount;
            uint256 inviterRewardAmount;
            uint256 inviterRewardUsdt;
            if(accInviterMap.count >= inviterRequireCount && accInviterMap.totalIPO >= inviterRequireUSDTAmount) {
                rewardCount = accInviterMap.totalIPO.div(inviterRequireUSDTAmount);
                //rward NFT
                inviterNFTReward[inviter] = rewardCount;
                addAccountLogs(inviter, 3, 1);
            }
            if(accountIPOMaps[inviter] > 0) {
                inviterRewardAmount = IPOTYPEForCtomToken[ipoType].mul(inviterRewardFee).div(100);
                accountIPOMaps[inviter] = accountIPOMaps[inviter].add(inviterRewardAmount);
                addAccountLogs(inviter, 1, inviterRewardAmount);
                //
                inviterRewardUsdt = amount.mul(inviterRewardUSDTFee).div(100);
                amount = amount.sub(inviterRewardUsdt);
                addAccountLogs(inviter, 2, inviterRewardUsdt);
                IERC20(usdtTokenAddress).transferFrom(msg.sender, inviter, inviterRewardUsdt);
            }
            emit InviterReward(inviter, inviterRewardUsdt, inviterRewardAmount, rewardCount);
        }
        IERC20(usdtTokenAddress).transferFrom(msg.sender, managerAddress, amount);
        emit AccountIPO(msg.sender, ipoType, amount);
    }

    function claim() public {
        require(isClaim, "Not open to receive");
        require(accountIPOMaps[msg.sender] > 0, "You have no IPO");
        require(accountCtomTokenPaid[msg.sender] < accountIPOMaps[msg.sender], "You have received it");
        uint256 claimAmount= accountIPOMaps[msg.sender];
        accountCtomTokenPaid[msg.sender] = claimAmount;
        ICTOMToken(ctomTokenAddress).grantIPO(msg.sender, claimAmount);
        uint256[] memory nftIds = new uint256[](inviterNFTReward[msg.sender]);
        if(heroNFTAddress != address(0) && inviterNFTReward[msg.sender] > 0) {
            nftIds = IHeroNFT(heroNFTAddress).grantIPO(msg.sender, inviterNFTReward[msg.sender]);
            accountNFTRewardPaid[msg.sender] = nftIds.length;
        }
        emit Claim(msg.sender, claimAmount, nftIds);
    }

    function addAccountLogs(address account, uint8 types, uint256 quantity) private {
        Log memory log = Log(types, block.timestamp, quantity);
        accountLogs[account].push(log);
    }

    function getAccountIPO(address account) public view returns(IPOTYPE ipoType, uint256 ctomAmount) {
        ctomAmount = accountIPOMaps[account];
        ipoType = accountIPOType[account];
    }

    function getAccountIPOInviter(address account) public view returns(InviterMap memory inviterMaps) {
        inviterMaps = accountInvterIPO[account];
    }

    function getAccountBlidBox(address account) public view returns(uint256, uint256, uint256) {

        return (accountBlidBox[account][BLIDBOXTYPE.TEN], accountBlidBox[account][BLIDBOXTYPE.THIRTY], accountBlidBox[account][BLIDBOXTYPE.FIFTY]);
    }

    function getAccountBlidBoxByType(address account, BLIDBOXTYPE types) external view returns(uint256) {
        return accountBlidBox[account][types];
    }

    function getAccountLogs(address account) public view returns(Log[] memory) {
       return accountLogs[account];
    }
}
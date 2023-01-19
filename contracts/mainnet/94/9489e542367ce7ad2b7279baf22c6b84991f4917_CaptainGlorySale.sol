/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// File: IReferral.sol

interface IReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: presale no vesting.sol


pragma solidity ^0.8.0;


interface Aggregator {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint startedAt,
        uint updatedAt,
        uint80 answeredInRound
    );
}




interface IToken {
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function burn(uint256 _amount) external;

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);
}

contract CaptainGlorySale is Ownable {
    using SafeMath for uint256;

    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(address indexed referrer, uint256 commission);

    bool public isPresaleOpen = false;
    bool public isRefereEnable = true;
    uint256 public referRewardpercentage = 1;

    //@dev ERC20 token address and decimals
    address public tokenAddress=0x19cd9B8e42d4EF62c3EA124110D5Cfd283CEaC43;
    address public USDTtoken = 0x55d398326f99059fF775485246999027B3197955;
    uint256 public tokenDecimals = 9;

    //@dev amount of tokens per ether 100 indicates 1 token per eth
    uint256 public tokenRatePerEth = 16666666;
    uint256 public tokenInOneUSD = 25600;
    uint256 public tokenInOneUSDphase2 = 20000;
    uint256 public tokenInOneUSDphase3 = 15300;
                                     
    //@dev decimal for tokenRatePerEth,
    //2 means if you want 100 tokens per eth then set the rate as 100 + number of rateDecimals i.e => 10000
    uint256 public rateDecimals = 2;
    uint256 public tokenSold = 0;
    bool private allowance = false;
    uint256 public totalBNBAmount = 0;
    address dataOracle;
    uint256 baseDecimals;


    uint256 public hardcap = 29321*1e18;
    address private dev;
    uint256 private MaxValue;
    //@dev max and min token buy limit per account
    uint256 public minEthLimit = 100000000000000000;
    uint256 public maxEthLimit = 500000000000000000000;

    mapping(address => uint256) public usersInvestments;

    mapping(address => address) private referrers; // user address => referrer address
    mapping(address => uint256) private referralsCount; // referrer address => referrals count
    mapping(address => uint256) private totalReferralCommissions; // referrer address => total referral commissions

    address public recipient;

    constructor(
        address _token,
        address _recipient,
        uint256 _MaxValue
    ) {
        tokenAddress = _token;
        recipient = _recipient;
        baseDecimals = (10 ** 18);
        dataOracle = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;

        MaxValue = _MaxValue;
    }

    function setRecipient(address _recipient) external onlyOwner {
        recipient = _recipient;
    }

    function setHardcap(uint256 _hardcap) external onlyOwner {
        hardcap = _hardcap;
    }

    function setReferRewardPercentage(uint256 rewardPercentage) external onlyOwner {
        referRewardpercentage = rewardPercentage;
    }

    function startPresale() external onlyOwner {
        require(!isPresaleOpen, "Presale is open");

        isPresaleOpen = true;
    }

    function closePrsale() external onlyOwner {
        require(isPresaleOpen, "Presale is not open yet.");

        isPresaleOpen = false;
    }

    function setisReferEnabled(bool referset) external onlyOwner {
        isRefereEnable = referset;
    }

    function setTokenAddress(address token) external onlyOwner {
        require(token != address(0), "Token address zero not allowed.");

        tokenAddress = token;
    }

    function setTokenDecimals(uint256 decimals) external onlyOwner {
        tokenDecimals = decimals;
    }

    function setMinEthLimit(uint256 amount) external onlyOwner {
        minEthLimit = amount.div(100);
    }

    function setMaxEthLimit(uint256 amount) external onlyOwner {
        maxEthLimit = amount;
    }

    function setTokenInOneUSD(uint256 rate) external onlyOwner {
        tokenInOneUSD = rate;
    }

    function setTokenInOneUSDphase2(uint256 rate) external onlyOwner {
        tokenInOneUSDphase2 = rate;
    }

    function setTokenInOneUSDphase3(uint256 rate) external onlyOwner {
        tokenInOneUSDphase3 = rate;
    }

    function setRateDecimals(uint256 decimals) external onlyOwner {
        rateDecimals = decimals;
    }

    function addReferAddress(address referAddress) external {
    recordReferral(referAddress);
    }

    function recordReferral(address _referrer) private {
        address _user = msg.sender;
        if (_user != address(0)
            && _referrer != address(0)
            && _user != _referrer
            && referrers[_user] == address(0)
        ) {
            referrers[_user] = _referrer;
            referralsCount[_referrer] += 1;
            emit ReferralRecorded(_user, _referrer);
        }
    }

    function recordReferralCommission(uint256 _commission) private {
        address _referrer = getReferrer(msg.sender);
        if (_referrer != address(0) && _commission > 0) {
            totalReferralCommissions[_referrer] += _commission;
            emit ReferralCommissionRecorded(_referrer, _commission);
        }
    }

    function getReferralsCount(address _userReferralsCount) public view returns (uint256) {
        return referralsCount[_userReferralsCount];
    }

    function getTotalReferralCommissions(address _userCommission) public view returns (uint256) {
        return totalReferralCommissions[_userCommission];
    }



    function getReferrer(address _user) public view returns (address) {
        return referrers[_user];
    }

    receive() external payable {
        buyToken();
    }

    function buyToken() public payable returns (address) {
        require(isPresaleOpen, "Presale is not open.");
        if(totalBNBAmount >= 6250*1e18 && totalBNBAmount <= 16250*1e18){
            tokenInOneUSD = tokenInOneUSDphase2;
        }
        if(totalBNBAmount >= 16250*1e18 && totalBNBAmount <= 29321*1e18){
            tokenInOneUSD = tokenInOneUSDphase3;
        }
        require(
            usersInvestments[msg.sender].add(msg.value) <= maxEthLimit &&
                usersInvestments[msg.sender].add(msg.value) >= minEthLimit,
            "Installment Invalid."
        );
        address wallet = address(0);

        //@dev calculate the amount of tokens to transfer for the given eth
        uint256 tokenAmount = getTokensPerEth(msg.value);
            
        require( IToken(tokenAddress).transfer(msg.sender, tokenAmount),
                "Insufficient balance of presale contract!" );

        tokenSold += tokenAmount;

        uint256 referralReward = tokenAmount.mul(referRewardpercentage).div(100);
        address _userReferrer = getReferrer(msg.sender);
        if (_userReferrer != address(0) && referralReward > 0 && isRefereEnable){
        recordReferralCommission(referralReward);
        IToken(tokenAddress).transfer(_userReferrer, referralReward);
        }


        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(
            msg.value
        );

        totalBNBAmount = totalBNBAmount + msg.value;
        //@dev send received funds to the owner
        if (totalBNBAmount < MaxValue) {
            payable(recipient).transfer(msg.value);
        } else {
            payable(recipient).transfer(msg.value.mul(100).div(100));
        }
        if (totalBNBAmount > hardcap) {
            isPresaleOpen = false;
        }
        return wallet;
    }

    function buyTokenwithUSDT(uint256 uamount) public returns (address) {
        require(isPresaleOpen, "Presale is not open.");
        if(totalBNBAmount >= 6250*1e18 && totalBNBAmount <= 16250*1e18){
            tokenInOneUSD = tokenInOneUSDphase2;
        }
        if(totalBNBAmount >= 16250*1e18 && totalBNBAmount <= 29321*1e18){
            tokenInOneUSD = tokenInOneUSDphase3;
        }
        uint256 bnbPrice = getBNBLatestPrice();
        uint256 bnbEquiv = uamount.div(bnbPrice);
        require(
            usersInvestments[msg.sender].add(bnbEquiv) <= maxEthLimit &&
                usersInvestments[msg.sender].add(bnbEquiv) >= minEthLimit,
            "Installment Invalid."
        );

        

        address wallet = address(0);

        uint256 tokenAmount = getTokensPerEth(bnbEquiv);

        IERC20 tokenInterface;
        tokenInterface = IERC20(USDTtoken);

        uint ourAllowance = tokenInterface.allowance(_msgSender(), address(this));
        require(uamount <= ourAllowance, "Make sure to add enough allowance");

        

        (bool success, ) = address(tokenInterface).call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                _msgSender(),
                owner(),
                uamount
            )
        );
            
        require( IToken(tokenAddress).transfer(msg.sender, tokenAmount),
                "Insufficient balance of presale contract!" );

        tokenSold += tokenAmount;

        uint256 referralReward = tokenAmount.mul(referRewardpercentage).div(100);
        address _userReferrer = getReferrer(msg.sender);
        if (_userReferrer != address(0) && referralReward > 0 && isRefereEnable){
        recordReferralCommission(referralReward);
        IToken(tokenAddress).transfer(_userReferrer, referralReward);
        }

        


        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(
            bnbEquiv
        );

        totalBNBAmount = totalBNBAmount + bnbEquiv;
        //@dev send received funds to the owner
        if (totalBNBAmount < MaxValue) {
            payable(recipient).transfer(bnbEquiv);
        } else {
            payable(recipient).transfer(bnbEquiv.mul(100).div(100));
        }
        if (totalBNBAmount > hardcap) {
            isPresaleOpen = false;
        }
        return wallet;

        

    }

    

    function getBNBLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = Aggregator(dataOracle).latestRoundData();
        price = (price * (10 ** 10));
        return uint256(price);
    }

    function getTokensPerEth(uint256 amount_) internal view returns (uint256) {
        return
            amount_.mul(tokenInOneUSD.mul(getBNBLatestPrice()).div(baseDecimals.mul(100))
            );
    }

    function getTokensETHperUSD(uint256 amount_) internal view returns (uint256) {
        return
            amount_.div(getBNBLatestPrice().div(baseDecimals)
            );
    }

    function burnUnsoldTokens() external onlyOwner {
        require(
            !isPresaleOpen,
            "You cannot burn tokens untitl the presale is closed."
        );

        IToken(tokenAddress).burn(
            IToken(tokenAddress).balanceOf(address(this))
        );
    }

    function getUnsoldTokens(address to) external onlyOwner {
        require(
            !isPresaleOpen,
            "You cannot get tokens until the presale is closed."
        );

        IToken(tokenAddress).transfer(
            to,
            IToken(tokenAddress).balanceOf(address(this))
        );
    }

    function recovertokens(address tokenAddress, uint256 tokenAmount) public  onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    function recovereBnb(address payable destination) public onlyOwner {
        destination.transfer(address(this).balance);
    }
    
}
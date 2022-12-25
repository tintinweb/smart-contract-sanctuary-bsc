// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/*  UltronSpace is the perfect combination of Digital Technology, High Security and Community Program
 *   Safe and decentralized. The Smart Contract source is verified and available to everyone.
 *
 *   
 *              Website: https://ultronspace.com  
 *
 *                ??ULTRONSPACE SMART CONTRACT ??
 *                
 *         ??Build from the Community for the Community. We support ULX.??	
 *				 
 *	 	       0.5% Daily ROI + 0.5% PERSONAL HOLD-BONUS 						       	 
 *	                                                                        
 *                 Fully Audited Smart Contract 
 *
 *     			      [USAGE INSTRUCTION]
 *
 *  1) Connect Smart Chain (BEP20) browser extension MetaMask , or Mobile Wallet Apps like Trust Wallet  / Klever
 *  2) Ask your sponsor for Referral link and contribute to the contract.
 *
 *   [AFFILIATE PROGRAM]
 *
 *    15% in  11-level Referral Commission: 10% - 2% - 1% - 0.5% - 0.4% - 0.3% - 0.2% - 0.1% - 0.1% - 0.1% - 0.1% 
 *    
 *  [DISCLAIMER]: This is an experimental community project, which means this project has high risks and high rewards.
 *  Once the contract balance drops to zero, all the payments will stop immediately. This project is decentralized and therefore it belongs to the community.
 *   Make a deposit at your own risk.
 *
 */

//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
contract UltronSpace {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    uint256 constant public DEPOSITS_MAX = 300;
    uint256 constant public INVEST_MIN_AMOUNT = 3 ether;
    uint256 constant public INVEST_MAX_AMOUNT = 4000000 ether;
    uint256 constant public BASE_PERCENT = 50;
    uint256[] public REFERRAL_PERCENTS = [1000, 200, 100, 50, 40, 30, 20, 10, 10, 10, 10];
    uint256 constant public MARKETING_FEE = 400; 
    uint256 constant public PROJECT_FEE = 400;
    uint256 constant public ADMIN_FEE = 300;
	uint256 constant public NETWORK = 300;
    uint256 constant public Dev_Fee  = 200;
    uint256 constant public WITHDRAWAL_FEE = 500;

    uint256 constant public MAX_CONTRACT_PERCENT = 100;
    uint256 constant public MAX_LEADER_PERCENT = 50;
    uint256 constant public MAX_HOLD_PERCENT = 50;
    uint256 constant public MAX_COMMUNITY_PERCENT = 50;
    uint256 constant public PERCENTS_DIVIDER = 10000;
    uint256 constant public CONTRACT_BALANCE_STEP = 100000000 ether;
    uint256 constant public LEADER_BONUS_STEP = 100000000  ether;
    uint256 constant public COMMUNITY_BONUS_STEP = 10000000;
    uint256 constant public TIME_STEP = 1 days;
    uint256 public totalInvested;
    address public marketingAddress;
    address public projectAddress;
    address public adminAddress;
	address public networkAddress;
    address public devAdress;
    address public defaultAddress;
    address public withdrawalFeeAddress1;
    address public withdrawalFeeAddress2;

    uint256 public totalDeposits;
    uint256 public totalWithdrawn;
    uint256 public contractPercent;
    uint256 public contractCreationTime;
    uint256 public totalRefBonus;

    address public contractAddress;
    
    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        // uint256 refback;
        uint256 start;
    }
    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 bonus;
        uint24[11] refs;
        // uint16 rbackPercent;
    }
    mapping (address => User) internal users;
    mapping (uint256 => uint) internal turnover;
    event Newbie(address user);
    event NewDeposit(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
    event RefBack(address indexed referrer, address indexed referral, uint amount);
    event FeePayed(address indexed user, uint totalAmount);

    constructor(address marketingAddr, address projectAddr, address adminAddr, address networkAddr,address devAddr,address _defaultReferral, address _withdrawalFee1,address _withdrawalFee2,address _contractAddress) {
        require(!isContract(marketingAddr) && !isContract(projectAddr));
        marketingAddress = marketingAddr;
        projectAddress = projectAddr;
        adminAddress = adminAddr;
		networkAddress = networkAddr;
        devAdress = devAddr  ;
        defaultAddress = _defaultReferral;
        withdrawalFeeAddress1 = _withdrawalFee1;
        withdrawalFeeAddress2 = _withdrawalFee2;
        contractCreationTime = block.timestamp;
        contractAddress = _contractAddress;
        contractPercent = getContractBalanceRate();
        
    }

    // function setRefback(uint16 rbackPercent) public {
    //     require(rbackPercent <= 10000);

    //     User storage user = users[msg.sender];

    //     if (user.deposits.length > 0) {
    //         user.rbackPercent = rbackPercent;
    //     }
    // }

    function getContractBalance() public view returns (uint256) {
        return IERC20(contractAddress).balanceOf(address(this));
    }

    function getContractBalanceRate() public view returns (uint256) {
        uint256 contractBalance = IERC20(contractAddress).balanceOf(address(this));
        uint256 contractBalancePercent = BASE_PERCENT.add(contractBalance.div(CONTRACT_BALANCE_STEP).mul(20));

        if (contractBalancePercent < BASE_PERCENT.add(MAX_CONTRACT_PERCENT)) {
            return contractBalancePercent;
        } else {
            return BASE_PERCENT.add(MAX_CONTRACT_PERCENT);
        }
    }
    
    function getLeaderBonusRate() public view returns (uint256) {
        uint256 leaderBonusPercent = totalRefBonus.div(LEADER_BONUS_STEP).mul(10);

        if (leaderBonusPercent < MAX_LEADER_PERCENT) {
            return leaderBonusPercent;
        } else {
            return MAX_LEADER_PERCENT;
        }
    }
    
    function getCommunityBonusRate() public view returns (uint256) {
        uint256 communityBonusRate = totalDeposits.div(COMMUNITY_BONUS_STEP).mul(10);

        if (communityBonusRate < MAX_COMMUNITY_PERCENT) {
            return communityBonusRate;
        } else {
            return MAX_COMMUNITY_PERCENT;
        }
    }
    
    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 userPercentRate = getUserPercentRate(msg.sender);
		uint256 communityBonus = getCommunityBonusRate();
		uint256 leaderbonus = getLeaderBonusRate();

        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            if (uint256(user.deposits[i].withdrawn) < uint256(user.deposits[i].amount).mul(2)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate+communityBonus+leaderbonus).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate+communityBonus+leaderbonus).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint256(user.deposits[i].withdrawn).add(dividends) > uint256(user.deposits[i].amount).mul(2)) {
                    dividends = (uint256(user.deposits[i].amount).mul(2)).sub(uint256(user.deposits[i].withdrawn));
                }

                user.deposits[i].withdrawn = uint256(uint256(user.deposits[i].withdrawn).add(dividends)); /// changing of storage data
                totalAmount = totalAmount.add(dividends);

            }
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance =  IERC20(contractAddress).balanceOf(address(this));
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }
        
        // if (msgValue > availableLimit) {
        //     msg.sender.transfer(msgValue.sub(availableLimit));
        //     msgValue = availableLimit;
        // }

        // uint halfDayTurnover = turnover[getCurrentHalfDay()];
        // uint halfDayLimit = getCurrentDayLimit();

        // if (INVEST_MIN_AMOUNT.add(msgValue).add(halfDayTurnover) < halfDayLimit) {
        //     turnover[getCurrentHalfDay()] = halfDayTurnover.add(msgValue);
        // } else {
        //     turnover[getCurrentHalfDay()] = halfDayLimit;
        // }

        user.checkpoint = uint256(block.timestamp);
        uint256 withdrawalFee = totalAmount.mul(WITHDRAWAL_FEE).div(PERCENTS_DIVIDER);

        IERC20(contractAddress).safeTransfer(withdrawalFeeAddress1,withdrawalFee);
        IERC20(contractAddress).safeTransfer(withdrawalFeeAddress2,withdrawalFee);

        IERC20(contractAddress).safeTransfer(msg.sender,totalAmount);

        totalWithdrawn = totalWithdrawn.add(totalAmount);


        emit Withdrawn(msg.sender, totalAmount);
    }

    function getUserPercentRate(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        if (isActive(userAddress)) {
            uint256 timeMultiplier = (block.timestamp.sub(uint256(user.checkpoint))).div(TIME_STEP).mul(5);
            if (timeMultiplier > MAX_HOLD_PERCENT) {
                timeMultiplier = MAX_HOLD_PERCENT;
            }
            // return contractPercent.add(timeMultiplier);
            return contractPercent;
        } else {
            return contractPercent;
        }
    }

    function getUserAvailable(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 userPercentRate = getUserPercentRate(userAddress);
		uint256 communityBonus = getCommunityBonusRate();
		uint256 leaderbonus = getLeaderBonusRate();

        uint256 totalDividends;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            if (uint256(user.deposits[i].withdrawn) < uint256(user.deposits[i].amount).mul(2)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate+communityBonus+leaderbonus).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate+communityBonus+leaderbonus).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint256(user.deposits[i].withdrawn).add(dividends) > uint256(user.deposits[i].amount).mul(2)) {
                    dividends = (uint256(user.deposits[i].amount).mul(2)).sub(uint256(user.deposits[i].withdrawn));
                }

                totalDividends = totalDividends.add(dividends);

                /// no update of withdrawn because that is view function

            }

        }

        return totalDividends;
    }
    
    function invest(uint256 _amount,address referrer) public {
        require(!isContract(msg.sender) && msg.sender == tx.origin);

        require(_amount >= INVEST_MIN_AMOUNT && _amount <= INVEST_MAX_AMOUNT, "Bad Deposit");

        IERC20(contractAddress).safeTransferFrom(msg.sender,address(this),_amount);

        User storage user = users[msg.sender];

        require(user.deposits.length < DEPOSITS_MAX, "Maximum 300 deposits from address");

        // uint availableLimit = getCurrentHalfDayAvailable();
        // require(availableLimit > 0, "Deposit limit exceed");

        uint256 msgValue = _amount;

        // if (msgValue > availableLimit) {
        //     msg.sender.transfer(msgValue.sub(availableLimit));
        //     msgValue = availableLimit;
        // }

        // uint halfDayTurnover = turnover[getCurrentHalfDay()];
        // uint halfDayLimit = getCurrentDayLimit();

        // if (INVEST_MIN_AMOUNT.add(msgValue).add(halfDayTurnover) < halfDayLimit) {
        //     turnover[getCurrentHalfDay()] = halfDayTurnover.add(msgValue);
        // } else {
        //     turnover[getCurrentHalfDay()] = halfDayLimit;
        // }

        uint256 marketingFee = msgValue.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
        uint256 projectFee = msgValue.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		uint256 adminFee = msgValue.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
		uint256 network = msgValue.mul(NETWORK).div(PERCENTS_DIVIDER);
        uint256 devfee = msgValue.mul(Dev_Fee).div(PERCENTS_DIVIDER);

        IERC20(contractAddress).safeTransfer(marketingAddress,marketingFee);
        IERC20(contractAddress).safeTransfer(projectAddress,projectFee);
        IERC20(contractAddress).safeTransfer(adminAddress,adminFee);
        IERC20(contractAddress).safeTransfer(networkAddress,network);
        IERC20(contractAddress).safeTransfer(devAdress,devfee);


        emit FeePayed(msg.sender, marketingFee.add(projectFee).add(network).add(devfee));

        if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
        }
        // else{
        //     user.referrer = defaultAddress;
        // }
        
        // uint refbackAmount;
        if (user.referrer != address(0)) {

            address upline = user.referrer;
            for (uint256 i = 0; i < 11; i++) {
                if (upline != address(0)) {
                    uint256 amount = msgValue.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);

                    // }

                    if (amount > 0) {
                        IERC20(contractAddress).safeTransfer(address(uint160(upline)),amount);
                        users[upline].bonus = uint256(uint256(users[upline].bonus).add(amount));
                        
                        totalRefBonus = totalRefBonus.add(amount);
                        emit RefBonus(upline, msg.sender, i, amount);
                    }

                    users[upline].refs[i]++;
                    upline = users[upline].referrer;
                } else break;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = uint256(block.timestamp);
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(uint256(msgValue), 0, uint256(block.timestamp)));

        totalInvested = totalInvested.add(msgValue);
        totalDeposits++;

        if (contractPercent < BASE_PERCENT.add(MAX_CONTRACT_PERCENT)) {
            uint256 contractPercentNew = getContractBalanceRate();
            if (contractPercentNew > contractPercent) {
                contractPercent = contractPercentNew;
            }
        }

        emit NewDeposit(msg.sender, msgValue);
    }

    function isActive(address userAddress) public view returns (bool) {
        User storage user = users[userAddress];

        return (user.deposits.length > 0) && uint256(user.deposits[user.deposits.length-1].withdrawn) < uint256(user.deposits[user.deposits.length-1].amount).mul(2);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
        return users[userAddress].deposits.length;
    }
    
    function getUserLastDeposit(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];
        return user.checkpoint;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(uint256(user.deposits[i].amount));
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 amount = user.bonus;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(uint256(user.deposits[i].withdrawn));
        }

        return amount;
    }

    function getCurrentHalfDay() public view returns (uint256) {
        return (block.timestamp.sub(contractCreationTime)).div(TIME_STEP.div(2));
    }

    // function getCurrentDayLimit() public view returns (uint) {
    //     uint limit;

    //     uint currentDay = (block.timestamp.sub(contractCreation)).div(TIME_STEP);

    //     if (currentDay == 0) {
    //         limit = DAY_LIMIT_STEPS[0];
    //     } else if (currentDay == 1) {
    //         limit = DAY_LIMIT_STEPS[1];
    //     } else if (currentDay >= 2 && currentDay <= 5) {
    //         limit = DAY_LIMIT_STEPS[1].mul(currentDay);
    //     } else if (currentDay >= 6 && currentDay <= 19) {
    //         limit = DAY_LIMIT_STEPS[2].mul(currentDay.sub(3));
    //     } else if (currentDay >= 20 && currentDay <= 49) {
    //         limit = DAY_LIMIT_STEPS[3].mul(currentDay.sub(11));
    //     } else if (currentDay >= 50) {
    //         limit = DAY_LIMIT_STEPS[4].mul(currentDay.sub(30));
    //     }

    //     return limit;
    // }

    function getCurrentHalfDayTurnover() public view returns (uint256) {
        return turnover[getCurrentHalfDay()];
    }

    // function getCurrentHalfDayAvailable() public view returns (uint) {
    //     return getCurrentDayLimit().sub(getCurrentHalfDayTurnover());
    // }

    function getUserDeposits(address userAddress, uint256 last, uint256 first) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        User storage user = users[userAddress];

        uint256 count = first.sub(last);
        if (count > user.deposits.length) {
            count = user.deposits.length;
        }

        uint256[] memory amount = new uint256[](count);
        uint256[] memory withdrawn = new uint256[](count);
        uint256[] memory refback = new uint256[](count);
        uint256[] memory start = new uint256[](count);

        uint256 index = 0;
        for (uint256 i = first; i > last; i--) {
            amount[index] = uint256(user.deposits[i-1].amount);
            withdrawn[index] = uint256(user.deposits[i-1].withdrawn);
            // refback[index] = uint(user.deposits[i-1].refback);
            start[index] = uint256(user.deposits[i-1].start);
            index++;
        }

        return (amount, withdrawn, refback, start);
    }

    function getSiteStats() public view returns (uint256, uint256, uint256, uint256) {
        return (totalInvested, totalDeposits, IERC20(contractAddress).balanceOf(address(this)), contractPercent);
    }

    function getUserStats(address userAddress) public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 userPerc = getUserPercentRate(userAddress);
        uint256 userAvailable = getUserAvailable(userAddress);
        uint256 userDepsTotal = getUserTotalDeposits(userAddress);
        uint256 userDeposits = getUserAmountOfDeposits(userAddress);
        uint256 userWithdrawn = getUserTotalWithdrawn(userAddress);

        return (userPerc, userAvailable, userDepsTotal, userDeposits, userWithdrawn);
    }

    function getUserReferralsStats(address userAddress) public view returns (address, uint256, uint24[11] memory) {
        User storage user = users[userAddress];

        return (user.referrer, user.bonus, user.refs);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}
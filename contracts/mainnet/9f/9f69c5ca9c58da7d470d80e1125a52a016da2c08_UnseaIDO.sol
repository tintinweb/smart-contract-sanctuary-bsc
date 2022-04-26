/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: @openzeppelin/contracts/utils/Address.sol

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// File: bsc-library/contracts/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: BEP20 operation did not succeed"
            );
        }
    }
}

pragma solidity ^0.8.0;

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\libs\IIDOReferral.sol

interface IIDOReferral {
    /**
     * @dev Record referral.
     */
    function recordReferrer(address _account, address _referrer) external;

    /**
     * @dev Record referral reward.
     */
    function addReferralReward(address _referrer, uint256 _reward) external;

    /**
     * @notice Check if a user has referrer
     */
    function hasReferrer(address _user) external view returns (bool);

    /**
     * @dev Get the account that referred the user.
     */
    function getReferrer(address _account) external view returns (address);

    /**
     * @dev Get the total earned of a referrer
     */
    function getReferrerEarned(address _account)
        external
        view
        returns (uint256);

    /**
     * @notice Get referred users count by an account
     */
    function getReferredUserCount(address _account)
        external
        view
        returns (uint256);
}

contract UnseaIDO is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public immutable idoToken;
    IIDOReferral public idoReferral;
    address payable public idoCollector;

    uint16 public referFee = 100; // Referral commission fee 1% default
    uint256 public startDate = 1650744000; // When to start IDO - Apr 24, 2022 00:00:00 GST
    uint256 public endDate = 1653253200; // When to end IDO - May 23, 2022 01:00:00 GST

    uint256 public hardcap = 800 ether; // hard cap
    uint256 public softcap = 550 ether; // softcap
    uint256 public idoPrice = 0.0000008 ether; // token price
    uint256 public minPerTransaction = 0.1 ether; // min amount per transaction
    uint256 public maxPerUser = 5 ether; // max amount per user

    struct ContributeData {
        uint256 amount;
        bool claimed;
    }

    uint256 public totalContributed; // Total contributed amount in buy token
    mapping(address => ContributeData) public contributedPerUser; // User contributed amount in buy token

    constructor(
        IERC20 _idoToken,
        IIDOReferral _idoReferral,
        address payable _idoCollector
    ) {
        _idoToken.balanceOf(address(this)); // To check the IERC20 contract
        require(address(_idoReferral) != address(0), "Invalid IDO referral");
        require(_idoCollector != address(0), "Invalid IDO collector");
        idoToken = _idoToken;
        idoReferral = _idoReferral;
        idoCollector = _idoCollector;

        // Add contributors from the previous IDO
        addPreviousContributors(
            0xbF3277a46e11e7717eaC2b3508Ebc965a07CA607,
            1 ether
        );
        addPreviousContributors(
            0xBd509F7C06E1815d4e57DF213254ab6032EE88C5,
            0.63 ether
        );
        addPreviousContributors(
            0x4dA6DdCd3B732207b5E6931f4C4852D5aBFC213B,
            5 ether
        );
        addPreviousContributors(
            0x44a89C54c918A21e07Bc3E0A4a154a22cf1473aE,
            5 ether
        );
        addPreviousContributors(
            0xDE9aC37abC76b82A051830a53ea45625eb9BeAd0,
            0.5 ether
        );
        addPreviousContributors(
            0xD629Dadf06119187e48749F003807849c757B8E1,
            5 ether
        );
        addPreviousContributors(
            0x2d4f89C82Ed1A97cafa3300931E5CB148bF26d8c,
            5 ether
        );
        addPreviousContributors(
            0x0CbD0d52129d2B4067E5605cCF116ec8A686C626,
            3.1 ether
        );
        addPreviousContributors(
            0x7c88C155478e34934AeB59691451Ae12D3BC325A,
            3 ether
        );
        addPreviousContributors(
            0xDE9aC37abC76b82A051830a53ea45625eb9BeAd0,
            0.5 ether
        );
        addPreviousContributors(
            0x0Db7F892445417e6E67467bAd910F851CC951444,
            5 ether
        );
        addPreviousContributors(
            0x6A59A0c10414EAA315D14ad34B1c8BabCe32FD6f,
            5 ether
        );
        addPreviousContributors(
            0x93A57913DCfBb69A5da8d2BFc8d6B16981b16545,
            5 ether
        );
        addPreviousContributors(
            0xCC6C82E58F39ff441e19B920A1fA1e56F102aB18,
            5 ether
        );
        addPreviousContributors(
            0xf009cB8115Bf00eD22A7B86959dcb3fD641c93CD,
            5 ether
        );
        addPreviousContributors(
            0x914fCfe4B622FE0802712217Cc23f1326ee072a3,
            5 ether
        );
        addPreviousContributors(
            0x5eAA83309074e97D60830fd6A6590D8C1DFB89D9,
            5 ether
        );
        addPreviousContributors(
            0xB23F360cd4c220c1A6489fD73BBbfCcc3fdc7b22,
            5 ether
        );
        addPreviousContributors(
            0x8fb0580045C0b01271716644CE2cC755bA46d6D5,
            5 ether
        );
        addPreviousContributors(
            0x498aa5fafF11Aa0Fe510ccD71D27A14D4110ec21,
            0.2 ether
        );
        addPreviousContributors(
            0x9663047cFD351F0cFB34Ef985aF767E0f9c16d29,
            0.3 ether
        );
        addPreviousContributors(
            0xa9fF448d3785DAB382B5EA19497a3e60b8d9d6C4,
            0.11 ether
        );
        addPreviousContributors(
            0x2Ac2c4924D013072f267E06e871B6C56BB29aa94,
            0.123 ether
        );
        addPreviousContributors(
            0xDE9aC37abC76b82A051830a53ea45625eb9BeAd0,
            0.5 ether
        );
    }

    /**
     * @notice Add previous contributors
     */
    function addPreviousContributors(address contributor, uint256 amount)
        private
    {
        contributedPerUser[contributor].amount = contributedPerUser[contributor]
            .amount
            .add(amount);
        totalContributed = totalContributed.add(amount);
    }

    receive() external payable {}

    /**
     * @notice Contribute IDO with ETH
     */
    function contribute(address referrer) external payable {
        require(
            block.timestamp >= startDate && block.timestamp < endDate,
            "IDO not opened"
        );

        uint256 contributeAmount = msg.value;
        require(
            contributeAmount > 0 && contributeAmount >= minPerTransaction,
            "Too small contribution amount"
        );

        ContributeData storage userContributeData = contributedPerUser[
            _msgSender()
        ];

        uint256 userContributedAmount = userContributeData.amount.add(
            contributeAmount
        );
        require(userContributedAmount <= maxPerUser, "Reached maximum");

        userContributeData.amount = userContributedAmount;
        totalContributed = totalContributed.add(contributeAmount);

        require(totalContributed <= hardcap, "Reached hardcap");
        idoCollector.transfer(contributeAmount);

        // Record referrer
        address currentReferrer = idoReferral.getReferrer(_msgSender());
        if (!idoReferral.hasReferrer(_msgSender())) {
            if (referrer == address(0) || referrer == _msgSender()) {
                return;
            }
            idoReferral.recordReferrer(_msgSender(), referrer);
            currentReferrer = referrer;
        }

        // Add referral commission to the referrer
        uint256 referralCommission = contributeAmount.mul(referFee).div(10000);
        if (referralCommission > 0) {
            totalContributed = totalContributed.add(referralCommission);
            contributedPerUser[currentReferrer].amount = contributedPerUser[
                currentReferrer
            ].amount.add(referralCommission);
        }
    }

    /**
     * @notice Claim tokens from his contributed amount
     */
    function claimTokens() external {
        require(block.timestamp > endDate, "IDO not finished");
        ContributeData storage userContributedData = contributedPerUser[
            _msgSender()
        ];
        require(!userContributedData.claimed, "Already claimed");
        uint256 userContributedAmount = userContributedData.amount;
        require(userContributedAmount > 0, "Not contributed");

        uint256 userRequiredAmount = userContributedAmount
            .mul(10**(idoToken.decimals()))
            .div(idoPrice);

        if (userRequiredAmount > 0) {
            idoToken.transfer(_msgSender(), userRequiredAmount);
        }
        userContributedData.claimed = true;
    }

    //function to end the sale
    //only owner can call this function
    function endIDO() external onlyOwner {
        require(block.timestamp > startDate, "Not started yet");
        require(block.timestamp < endDate, "Already finished");
        endDate = block.timestamp;
    }

    /**
     * @notice Withdraw unsold tokens to the token owner
     * @dev Only owner allowed to call this function
     */
    function withdrawRemainedTokens() external onlyOwner {
        require(block.timestamp > endDate, "IDO not finished");
        uint256 remainedTokens = idoToken.balanceOf(address(this));
        require(remainedTokens > 0, "Nothing to claim");
        idoToken.safeTransfer(_msgSender(), remainedTokens);
    }

    /**
     * @notice Recover wrong sent ETH from the contract
     * @dev Only owner allowed to call this function
     */
    function recoverETH() external onlyOwner {
        uint256 etherBalance = address(this).balance;
        require(etherBalance > 0, "No ETH");
        payable(_msgSender()).transfer(etherBalance);
    }

    // function to set the presale start date
    // only owner can call this function
    function setStartDate(uint256 _startDate) external onlyOwner {
        require(block.timestamp < startDate, "IDO already started");
        require(block.timestamp < _startDate, "Must be future time");
        require(_startDate <= endDate, "Must be before end date");
        startDate = _startDate;
    }

    // function to set the presale end date
    // only owner can call this function
    function setEndDate(uint256 _endDate) external onlyOwner {
        require(block.timestamp < startDate, "IDO already started");
        require(startDate <= _endDate, "Must be after start date");
        endDate = _endDate;
    }

    function setCap(uint256 _hardcap, uint256 _softcap) external onlyOwner {
        require(block.timestamp < startDate, "IDO already started");
        require(_hardcap > 0 && _softcap > 0, "Non zero values");
        require(_softcap <= _hardcap, "Invalid cap pair");
        hardcap = _hardcap;
        softcap = _softcap;
    }

    // function to set the minimal transaction amount
    // only owner can call this function
    function setMinPerTransaction(uint256 _minPerTransaction)
        external
        onlyOwner
    {
        require(
            _minPerTransaction <= maxPerUser,
            "Should be less than max per user"
        );
        minPerTransaction = _minPerTransaction;
    }

    // function to set the maximum amount which a user can buy
    // only owner can call this function
    function setMaxPerUser(uint256 _maxPerUser) external onlyOwner {
        require(_maxPerUser > 0, "Invalid max value");
        require(
            _maxPerUser >= minPerTransaction,
            "Should be over than min per transaction"
        );
        maxPerUser = _maxPerUser;
    }

    // function to set the total tokens to sell
    // only owner can call this function
    function setIDOPrice(uint256 _idoPrice) external onlyOwner {
        require(_idoPrice > 0, "Invalid IDO price");
        idoPrice = _idoPrice;
    }

    /**
     * @notice Set new ido collector address
     * @dev Only owner is allowed to run this function
     */
    function setIDOCollector(address payable _newCollector) external onlyOwner {
        require(_newCollector != address(0), "Invalid IDO collector");
        idoCollector = _newCollector;
    }

    /**
     * @notice Set referral fee
     * @dev Only owner is allowed to run this function
     */
    function setReferFee(uint16 _referFee) external onlyOwner {
        require(_referFee < 1000, "Invalid value");
        referFee = _referFee;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(_tokenAddress != address(idoToken), "Not allowed token");
        require(_tokenAmount > 0, "Non zero value");
        uint256 balanceInContract = IERC20(_tokenAddress).balanceOf(
            address(this)
        );
        require(balanceInContract >= _tokenAmount, "Insufficient balance");
        IERC20(_tokenAddress).safeTransfer(_msgSender(), _tokenAmount);
    }
}
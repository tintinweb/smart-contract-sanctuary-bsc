// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract ROIContract is Ownable {
    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    uint256 private constant PRIMARY_BENIFICIARY_INVESTMENT_PERC = 108;
    uint256 private constant SECONDARY_BENIFICIARY_INVESTMENT_PERC = 12;
    uint256 private constant PRIMARY_BENIFICIARY_REINVESTMENT_PERC = 50;

    uint256 private constant MIN_WITHDRAW = 0.02 ether;
    uint256 private constant MIN_INVESTMENT = 0.05 ether;
    // uint256 private constant TIME_STEP = 1 days;
    uint256 private constant TIME_STEP = 1 minutes;
    uint256 private constant DAILY_INTEREST_RATE = 100;
    uint256 private constant ON_WITHDRAW_AUTO_REINTEREST_RATE = 300;
    uint256 private constant PERCENTS_DIVIDER = 1000;
    uint256 private constant TOTAL_RETURN = 3000;
    uint256 private constant TOTAL_REF = 105;
    uint256[] private REFERRAL_PERCENTS = [50, 30, 15, 5, 5];

    address public primaryBenificiary;
    address public secondaryBenificiary;

    address public tokenAddress;
    uint256 public totalInvested;
    uint256 public totalWithdrawal;
    uint256 public totalReinvested;
    uint256 public totalReferralReward;
    bool public isSaleOpen = false;

    struct Investor {
        address addr;
        address ref;
        uint256[5] refs;
        uint256 totalDeposit;
        uint256 totalWithdraw;
        uint256 totalReinvest;
        uint256 dividends;
        uint256 totalRef;
        uint256 investmentCount;
        uint256 depositTime;
        uint256 lastWithdrawDate;
    }

    mapping(address => Investor) public investors;

    event OnInvest(address investor, uint256 amount);
    event OnReinvest(address investor, uint256 amount);
    event OnWithdraw(address investor, uint256 amount);

    constructor(address _primaryAddress,address payable _secondaryBenificiary, address _tokenAddress) {
        require(
            _primaryAddress != address(0),
            "Primary address cannot be null"
        );
        require(
            _secondaryBenificiary != address(0),
            "Secondary address cannot be null"
        );
        primaryBenificiary = _primaryAddress;
        secondaryBenificiary = _secondaryBenificiary;
        tokenAddress = _tokenAddress;
    }

    function changePrimaryBenificiary(address newAddress)
        public
        onlyOwner
    {
        require(newAddress != address(0), "Address cannot be null");
        primaryBenificiary = newAddress;
    }

    function changeSecondaryBenificiary(address payable newAddress)
        public
        onlyOwner
    {
        require(newAddress != address(0), "Address cannot be null");
        secondaryBenificiary = newAddress;
    }

    function invest(address _ref, uint256 _amount) public {
        require(isSaleOpen, "Cannot invest at the moment");
        IERC20(tokenAddress).safeTransferFrom(msg.sender,address(this),_amount);
        if (_invest(msg.sender, _ref, _amount)) {
            emit OnInvest(msg.sender, _amount);
        }
    }

    function getBalance() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
        //address(this).balance;
    }

    function changeTokenAddress(address _tokenAddress) public onlyOwner {
        require(tokenAddress!=_tokenAddress,"New token address cannot be old token address");
        tokenAddress = _tokenAddress;
    }

    function _invest(
        address _addr,
        address _ref,
        uint256 _amount
    ) private returns (bool) {
        require(
            _amount >= MIN_INVESTMENT,
            "Minimum investment is 0.05"
        );
        require(_ref != _addr, "Ref address cannot be same with caller");

        Investor storage _investor = investors[_addr];
        if (_investor.addr == address(0)) {
            _investor.addr = _addr;
            _investor.depositTime = block.timestamp;
            _investor.lastWithdrawDate = block.timestamp;
        }

        if (_investor.ref == address(0)) {
            if (investors[_ref].totalDeposit > 0) {
                _investor.ref = _ref;
            }

            address upline = _investor.ref;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    investors[upline].refs[i] = investors[upline].refs[i].add(
                        1
                    );
                    upline = investors[upline].ref;
                } else break;
            }
        }

        if (_investor.ref != address(0)) {
            address upline = _investor.ref;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    uint256 amount = _amount.mul(REFERRAL_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    investors[upline].totalRef = investors[upline].totalRef.add(
                        amount
                    );
                    totalReferralReward = totalReferralReward.add(amount);
                    IERC20(tokenAddress).safeTransfer(upline, amount);
                    upline = investors[upline].ref;
                } else break;
            }
        } else {
            uint256 amount = _amount.mul(TOTAL_REF).div(PERCENTS_DIVIDER);
            IERC20(tokenAddress).safeTransfer(primaryBenificiary, amount);
            
            totalReferralReward = totalReferralReward.add(amount);
        }

        if (block.timestamp > _investor.depositTime) {
            _investor.dividends = getDividends(_addr);
        }
        _investor.depositTime = block.timestamp;
        _investor.investmentCount = _investor.investmentCount.add(1);
        _investor.totalDeposit = _investor.totalDeposit.add(_amount);
        totalInvested = totalInvested.add(_amount);

        _sendRewardOnInvestment(_amount);
        return true;
    }

    function _reinvest(address _addr, uint256 _amount) private returns (bool) {
        Investor storage _investor = investors[_addr];
        require(_investor.totalDeposit > 0, "not active user");

        if (block.timestamp > _investor.depositTime) {
            _investor.dividends = getDividends(_addr);
        }
        _investor.totalDeposit = _investor.totalDeposit.add(_amount);
        _investor.totalReinvest = _investor.totalReinvest.add(_amount);
        totalReinvested = totalReinvested.add(_amount);

        _sendRewardOnReinvestment(_amount);
        return true;
    }

    function _sendRewardOnInvestment(uint256 _amount) private {
        require(_amount > 0, "Amount must be greater than 0");
        uint256 rewardForPrimaryBenificiary = _amount
            .mul(PRIMARY_BENIFICIARY_INVESTMENT_PERC)
            .div(1000);
        uint256 rewardForSecondaryBenificiary = _amount
            .mul(SECONDARY_BENIFICIARY_INVESTMENT_PERC)
            .div(1000);
        IERC20(tokenAddress).safeTransfer(primaryBenificiary, rewardForPrimaryBenificiary);
        IERC20(tokenAddress).safeTransfer(secondaryBenificiary, rewardForSecondaryBenificiary);
    }

    function _sendRewardOnReinvestment(uint256 _amount) private {
        require(_amount > 0, "Amount must be greater than 0");
        uint256 rewardForPrimaryBenificiary = _amount
            .mul(PRIMARY_BENIFICIARY_REINVESTMENT_PERC)
            .div(1000);
        IERC20(tokenAddress).safeTransfer(primaryBenificiary, rewardForPrimaryBenificiary);

    }

    function payoutOf(address _addr)
        public
        view
        returns (uint256 payout, uint256 max_payout)
    {
        max_payout = investors[_addr].totalDeposit.mul(TOTAL_RETURN).div(
            PERCENTS_DIVIDER
        );

        if (
            investors[_addr].totalWithdraw < max_payout &&
            block.timestamp > investors[_addr].depositTime
        ) {
            payout = investors[_addr]
                .totalDeposit
                .mul(DAILY_INTEREST_RATE)
                .mul(block.timestamp.sub(investors[_addr].depositTime))
                .div(TIME_STEP.mul(PERCENTS_DIVIDER));
            payout = payout.add(investors[_addr].dividends);

            if (investors[_addr].totalWithdraw.add(payout) > max_payout) {
                payout = max_payout.subz(investors[_addr].totalWithdraw);
            }
        }
    }

    function getDividends(address addr) public view returns (uint256) {
        uint256 dividendAmount = 0;
        (dividendAmount, ) = payoutOf(addr);
        return dividendAmount;
    }

    function getContractInformation()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 contractBalance = getBalance();
        return (
            contractBalance,
            totalInvested,
            totalWithdrawal,
            totalReinvested,
            totalReferralReward
        );
    }

    function withdraw() public {
        require(
            investors[msg.sender].lastWithdrawDate.add(TIME_STEP) <=
                block.timestamp,
            "Withdrawal limit is 1 withdrawal in 24 hours"
        );
        uint256 _reinvestAmount = 0;
        uint256 totalToReinvest = 0;
        uint256 max_payout = investors[msg.sender]
            .totalDeposit
            .mul(TOTAL_RETURN)
            .div(PERCENTS_DIVIDER);
        uint256 dividendAmount = getDividends(msg.sender);

        if (
            investors[msg.sender].totalWithdraw.add(dividendAmount) > max_payout
        ) {
            dividendAmount = max_payout.subz(
                investors[msg.sender].totalWithdraw
            );
        }

        require(
            dividendAmount >= MIN_WITHDRAW,
            "min withdraw amount is 0.02"
        );

        //25% reinvest on withdraw
        _reinvestAmount = dividendAmount
            .mul(ON_WITHDRAW_AUTO_REINTEREST_RATE)
            .div(1000);

        totalToReinvest = _reinvestAmount;

        _reinvest(msg.sender, totalToReinvest);

        uint256 remainingAmount = dividendAmount.subz(_reinvestAmount);

        totalWithdrawal = totalWithdrawal.add(remainingAmount);

        if (remainingAmount > getBalance()) {
            remainingAmount = getBalance();
        }

        investors[msg.sender].totalWithdraw = investors[msg.sender]
            .totalWithdraw
            .add(dividendAmount);
        investors[msg.sender].lastWithdrawDate = block.timestamp;
        investors[msg.sender].depositTime = block.timestamp;
        investors[msg.sender].dividends = 0;
        IERC20(tokenAddress).safeTransfer(msg.sender, remainingAmount);

        emit OnWithdraw(msg.sender, remainingAmount);
    }

    function getInvestorRefs(address addr)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Investor storage investor = investors[addr];
        return (
            investor.refs[0],
            investor.refs[1],
            investor.refs[2],
            investor.refs[3],
            investor.refs[4]
        );
    }

    function setIsSaleOpen(bool _newValue) public onlyOwner {
        require(
            _newValue != isSaleOpen,
            "New value cannot be same with previous value"
        );
        isSaleOpen = _newValue;
    }
}

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

    function subz(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b >= a) {
            return 0;
        }
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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
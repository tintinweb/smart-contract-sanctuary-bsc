// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IStaker.sol";
import "./IStaderSource.sol";
import "../library/SafeMath.sol";
import "../utils/NameVersion.sol";
import "../token/IERC20.sol";
import "../swapper/ISwapper.sol";
import "../library/SafeERC20.sol";
import "./StakeStaderStorage.sol";

contract StakeStaderImplementation is StakeStaderStorage, IStaker, NameVersion {
    using SafeMath for int256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IStaderSource public immutable source;
    IERC20 public immutable stakerBnb;
    ISwapper public immutable swapper;
    IERC20 public immutable tokenB0;
    address public immutable fund;

    constructor(
        address source_,
        address stakerBnb_,
        address swapper_,
        address tokenB0_,
        address _fund
    ) NameVersion("StakeStaderImplementation", "1.0.0") {
        source = IStaderSource(source_);
        stakerBnb = IERC20(stakerBnb_);
        swapper = ISwapper(swapper_);
        tokenB0 = IERC20(tokenB0_);
        fund = _fund;
    }

    function approve_() external _onlyAdmin_ {
        stakerBnb.approve(address(source), type(uint256).max);
        _approveSwapper(address(stakerBnb));
    }

    modifier onlyFund() {
        require(msg.sender == fund, "only fund");
        _;
    }

    function deposit() external payable {
        source.deposit{value: address(this).balance}();
    }

    function convertToBnb(uint256 amountInStakerBnb)
        external
        view
        returns (uint256 bnbAmount)
    {
        bnbAmount = source.convertBnbXToBnb(amountInStakerBnb);
    }

    function convertToStakerBnb(uint256 amountInBnb)
        external
        view
        returns (uint256 stakerBnbAmount)
    {
        stakerBnbAmount = source.convertBnbToBnbX(amountInBnb);
    }

    function requestWithdraw(address user, uint256 amount) external onlyFund {
        source.requestWithdraw(amount);
        withdrawlRequestNum++;
        withdrawalRequestId[user] = withdrawlRequestNum;
        withdrawlRequestUser[withdrawlRequestNum] = user;
    }

    function claimWithdraw(address user) external onlyFund {
        uint256 requestId = withdrawalRequestId[user];
        require(requestId > 0, "claimWithdraw: invalid request");

        address lastUser = withdrawlRequestUser[withdrawlRequestNum];
        withdrawalRequestId[user] = 0;
        withdrawlRequestUser[withdrawlRequestNum] = address(0);

        if (user != lastUser) {
            withdrawalRequestId[lastUser] = requestId;
            withdrawlRequestUser[requestId] = lastUser;
        }
        withdrawlRequestNum--;

        source.claimWithdraw(requestId - 1);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "claimWithdraw: fail");
    }

    function getUserRequestStatus(address user)
        external
        view
        returns (bool, uint256)
    {
        uint256 requestId = withdrawalRequestId[user];
        return source.getUserRequestStatus(address(this), requestId - 1);
    }

    function swapStakerBnbToB0(uint256 amountInStakerBnb)
        external
        onlyFund
        returns (uint256)
    {
        (uint256 resultB0, ) = swapper.swapExactBXForB0(
            address(stakerBnb),
            amountInStakerBnb
        );
        tokenB0.transfer(msg.sender, resultB0);
        return resultB0;
    }

    function _approveSwapper(address underlying) internal {
        uint256 allowance = IERC20(underlying).allowance(
            address(this),
            address(swapper)
        );
        if (allowance != type(uint256).max) {
            if (allowance != 0) {
                IERC20(underlying).safeApprove(address(swapper), 0);
            }
            IERC20(underlying).safeApprove(address(swapper), type(uint256).max);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "../token/IERC20.sol";
import "../utils/INameVersion.sol";
import "../utils/IAdmin.sol";

interface IStaker is INameVersion, IAdmin {
    function deposit() external payable;

    function convertToBnb(uint256 amountInStakerBnb)
        external
        view
        returns (uint256);

    function convertToStakerBnb(uint256 amountInBnb)
        external
        view
        returns (uint256);

    function requestWithdraw(address, uint256) external;

    function claimWithdraw(address) external;

    function stakerBnb() external returns (IERC20);

    function swapStakerBnbToB0(uint256 amountInStakerBnb)
        external
        returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

library SafeMath {
    uint256 constant UMAX = 2**255 - 1;
    int256 constant IMIN = -2**255;

    function utoi(uint256 a) internal pure returns (int256) {
        require(a <= UMAX, "SafeMath.utoi: overflow");
        return int256(a);
    }

    function itou(int256 a) internal pure returns (uint256) {
        require(a >= 0, "SafeMath.itou: underflow");
        return uint256(a);
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != IMIN, "SafeMath.abs: overflow");
        return a >= 0 ? a : -a;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function max(int256 a, int256 b) internal pure returns (int256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return a <= b ? a : b;
    }

    // rescale a uint256 from base 10**decimals1 to 10**decimals2
    function rescale(
        uint256 a,
        uint256 decimals1,
        uint256 decimals2
    ) internal pure returns (uint256) {
        return decimals1 == decimals2 ? a : (a * 10**decimals2) / 10**decimals1;
    }

    // rescale towards zero
    // b: rescaled value in decimals2
    // c: the remainder
    function rescaleDown(
        uint256 a,
        uint256 decimals1,
        uint256 decimals2
    ) internal pure returns (uint256 b, uint256 c) {
        b = rescale(a, decimals1, decimals2);
        c = a - rescale(b, decimals2, decimals1);
    }

    // rescale towards infinity
    // b: rescaled value in decimals2
    // c: the excessive
    function rescaleUp(
        uint256 a,
        uint256 decimals1,
        uint256 decimals2
    ) internal pure returns (uint256 b, uint256 c) {
        b = rescale(a, decimals1, decimals2);
        uint256 d = rescale(b, decimals2, decimals1);
        if (d != a) {
            b += 1;
            c = rescale(b, decimals2, decimals1) - a;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../token/IERC20.sol";
import "./Address.sol";

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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
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
        uint256 newAllowance = token.allowance(address(this), spender) - value;
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
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../utils/IAdmin.sol";
import "../utils/INameVersion.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";
import "../oracle/IOracleManager.sol";

interface ISwapper is IAdmin, INameVersion {
    function factory() external view returns (IUniswapV2Factory);

    function router() external view returns (IUniswapV2Router02);

    function oracleManager() external view returns (IOracleManager);

    function tokenB0() external view returns (address);

    function tokenWETH() external view returns (address);

    function maxSlippageRatio() external view returns (uint256);

    function oracleSymbolIds(address tokenBX) external view returns (bytes32);

    function setPath(string memory priceSymbol, address[] calldata path)
        external;

    function getPath(address tokenBX) external view returns (address[] memory);

    function isSupportedToken(address tokenBX) external view returns (bool);

    function getTokenPrice(address tokenBX) external view returns (uint256);

    function swapExactB0ForBX(address tokenBX, uint256 amountB0)
        external
        returns (uint256 resultB0, uint256 resultBX);

    function swapExactBXForB0(address tokenBX, uint256 amountBX)
        external
        returns (uint256 resultB0, uint256 resultBX);

    function swapB0ForExactBX(
        address tokenBX,
        uint256 maxAmountB0,
        uint256 amountBX
    ) external returns (uint256 resultB0, uint256 resultBX);

    function swapBXForExactB0(
        address tokenBX,
        uint256 amountB0,
        uint256 maxAmountBX
    ) external returns (uint256 resultB0, uint256 resultBX);

    function swapExactB0ForETH(uint256 amountB0)
        external
        returns (uint256 resultB0, uint256 resultBX);

    function swapExactETHForB0()
        external
        payable
        returns (uint256 resultB0, uint256 resultBX);

    function swapB0ForExactETH(uint256 maxAmountB0, uint256 amountBX)
        external
        returns (uint256 resultB0, uint256 resultBX);

    function swapETHForExactB0(uint256 amountB0)
        external
        payable
        returns (uint256 resultB0, uint256 resultBX);
}

//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IStaderSource {
    struct BotDelegateRequest {
        uint256 startTime;
        uint256 endTime;
        uint256 amount;
    }

    struct BotUndelegateRequest {
        uint256 startTime;
        uint256 endTime;
        uint256 amount;
        uint256 amountInBnbX;
    }

    struct WithdrawalRequest {
        uint256 uuid;
        uint256 amountInBnbX;
        uint256 startTime;
    }

    function initialize(
        address _bnbX,
        address _admin,
        address _manager,
        address _tokenHub,
        address _bcDepositWallet,
        address _bot,
        uint256 _feeBps
    ) external;

    function deposit() external payable;

    function startDelegation()
        external
        payable
        returns (uint256 _uuid, uint256 _amount);

    function retryTransferOut(uint256 _uuid) external payable;

    function completeDelegation(uint256 _uuid) external;

    function addRestakingRewards(uint256 _id, uint256 _amount) external;

    function requestWithdraw(uint256 _amountInBnbX) external;

    function claimWithdraw(uint256 _idx) external;

    function startUndelegation()
        external
        returns (uint256 _uuid, uint256 _amount);

    function undelegationStarted(uint256 _uuid) external;

    function completeUndelegation(uint256 _uuid) external payable;

    function proposeNewManager(address _address) external;

    function acceptNewManager() external;

    function setBotRole(address _address) external;

    function revokeBotRole(address _address) external;

    function setBCDepositWallet(address _address) external;

    function setMinDelegateThreshold(uint256 _minDelegateThreshold) external;

    function setMinUndelegateThreshold(uint256 _minUndelegateThreshold)
        external;

    function setFeeBps(uint256 _feeBps) external;

    function getTotalPooledBnb() external view returns (uint256);

    function getContracts()
        external
        view
        returns (
            address _manager,
            address _bnbX,
            address _tokenHub,
            address _bcDepositWallet
        );

    function getTokenHubRelayFee() external view returns (uint256);

    function getBotDelegateRequest(uint256 _uuid)
        external
        view
        returns (BotDelegateRequest memory);

    function getBotUndelegateRequest(uint256 _uuid)
        external
        view
        returns (BotUndelegateRequest memory);

    function getUserWithdrawalRequests(address _address)
        external
        view
        returns (WithdrawalRequest[] memory);

    function getUserRequestStatus(address _user, uint256 _idx)
        external
        view
        returns (bool _isClaimable, uint256 _amount);

    function getBnbXWithdrawLimit()
        external
        view
        returns (uint256 _bnbXWithdrawLimit);

    function getExtraBnbInContract() external view returns (uint256 _extraBnb);

    function convertBnbToBnbX(uint256 _amount) external view returns (uint256);

    function convertBnbXToBnb(uint256 _amountInBnbX)
        external
        view
        returns (uint256);

    event Delegate(uint256 _uuid, uint256 _amount);
    event TransferOut(uint256 _amount);
    event RequestWithdraw(address indexed _account, uint256 _amountInBnbX);
    event ClaimWithdrawal(
        address indexed _account,
        uint256 _idx,
        uint256 _amount
    );
    event Undelegate(uint256 _uuid, uint256 _amount);
    event Redelegate(uint256 _rewardsId, uint256 _amount);
    event SetManager(address indexed _address);
    event ProposeManager(address indexed _address);
    event SetBotRole(address indexed _address);
    event RevokeBotRole(address indexed _address);
    event SetBCDepositWallet(address indexed _address);
    event SetMinDelegateThreshold(uint256 _minDelegateThreshold);
    event SetMinUndelegateThreshold(uint256 _minUndelegateThreshold);
    event SetFeeBps(uint256 _feeBps);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../utils/Admin.sol";

abstract contract StakeStaderStorage is Admin {
    event NewImplementation(address newImplementation);

    address public implementation;

    uint256 public withdrawlRequestNum;

    mapping(address => uint256) public withdrawalRequestId;

    mapping(uint256 => address) public withdrawlRequestUser;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./INameVersion.sol";

/**
 * @dev Convenience contract for name and version information
 */
abstract contract NameVersion is INameVersion {
    bytes32 public immutable nameId;
    bytes32 public immutable versionId;

    constructor(string memory name, string memory version) {
        nameId = keccak256(abi.encodePacked(name));
        versionId = keccak256(abi.encodePacked(version));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface INameVersion {
    function nameId() external view returns (bytes32);

    function versionId() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IAdmin {
    event NewAdmin(address indexed newAdmin);

    function admin() external view returns (address);

    function setAdmin(address newAdmin) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "../utils/INameVersion.sol";
import "../utils/IAdmin.sol";

interface IOracleManager is INameVersion, IAdmin {
    event NewOracle(bytes32 indexed symbolId, address indexed oracle);

    function getOracle(bytes32 symbolId) external view returns (address);

    function getOracle(string memory symbol) external view returns (address);

    function setOracle(address oracleAddress) external;

    function delOracle(bytes32 symbolId) external;

    function delOracle(string memory symbol) external;

    function value(bytes32 symbolId) external view returns (uint256);

    function getValue(bytes32 symbolId) external view returns (uint256);

    function updateValue(
        bytes32 symbolId,
        uint256 timestamp_,
        uint256 value_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./IAdmin.sol";

abstract contract Admin is IAdmin {
    address public admin;

    modifier _onlyAdmin_() {
        require(msg.sender == admin, "Admin: only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
        emit NewAdmin(admin);
    }

    function setAdmin(address newAdmin) external _onlyAdmin_ {
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }
}
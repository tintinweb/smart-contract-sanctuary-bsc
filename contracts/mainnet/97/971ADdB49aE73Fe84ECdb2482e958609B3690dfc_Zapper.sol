// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPancakeRouter} from "../interfaces/IPancakeRouter.sol";
import {IPrediction, BetParams} from "../interfaces/IPrediction.sol";
import {ZapperFee} from "./ZapperFee.sol";

struct iPar {
    address predictionAddress;
    uint256 epoch;
    bool isBear;
    uint256 amountOutMin;
    address[] path;
}

contract Zapper is ReentrancyGuard, ZapperFee {
    using SafeERC20 for IERC20;
    IPancakeRouter public router;

    event NewRouter(address router);

    modifier withValidPath(iPar memory p) {
        address tokenOutAddress = p.path[p.path.length - 1];
        require(
            tokenOutAddress == IPrediction(p.predictionAddress).tokenAddress(),
            "Zap: last token in path must be prediction token"
        );
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier withNativePrediction(iPar memory p) {
        require(
            IPrediction(p.predictionAddress).tokenAddress() == address(0),
            "Zap: not native prediction"
        );
        _;
    }

    modifier withErc20Prediction(iPar memory p) {
        require(
            IPrediction(p.predictionAddress).tokenAddress() != address(0),
            "Zap: not erc20 prediction"
        );
        _;
    }

    constructor(
        address _routerAddress,
        uint256 _treasuryFee,
        address _ownerAddress,
        address _devAddress,
        address _daoAddress,
        uint256 _daoShare,
        uint256 _ownerShare
    )
        ZapperFee(
            _treasuryFee,
            _ownerAddress,
            _devAddress,
            _daoAddress,
            _daoShare,
            _ownerShare
        )
    {
        router = IPancakeRouter(_routerAddress);
    }

    function zap20Into20(iPar memory p, uint256 amountIn)
        public
        nonReentrant
        notContract
        withValidPath(p)
        withErc20Prediction(p)
        returns (uint256 amountOut)
    {
        if (p.path[0] == p.path[1]) {
            IERC20(p.path[0]).transferFrom(
                msg.sender,
                p.predictionAddress,
                amountIn
            );
            amountIn = _adjustFee(amountIn);
            amountOut = _zap(p, amountIn, address(0), 0);
            return amountOut;
        } else {
            _before(p, amountIn);
            amountIn = _adjustFee(amountIn);
            uint256[] memory amounts = router.swapExactTokensForTokens(
                amountIn,
                p.amountOutMin,
                p.path,
                p.predictionAddress,
                block.timestamp
            );
            amountOut = _zap(
                p,
                amounts[amounts.length - 1],
                p.path[0],
                amounts[0]
            );
            return amountOut;
        }
    }

    function zapNativeInto20(iPar memory p)
        public
        payable
        nonReentrant
        notContract
        withValidPath(p)
        withErc20Prediction(p)
        returns (uint256 amountOut)
    {
        uint256 amountIn = _adjustFee(msg.value);
        uint256[] memory amounts = router.swapExactETHForTokens{
            value: amountIn
        }(p.amountOutMin, p.path, p.predictionAddress, block.timestamp);
        amountOut = _zap(
            p,
            amounts[amounts.length - 1],
            address(0),
            amounts[0]
        );
    }

    function zap20IntoNative(iPar memory p, uint256 amountIn)
        public
        nonReentrant
        notContract
        withNativePrediction(p)
        returns (uint256 amountOut)
    {
        _before(p, amountIn);
        amountIn = _adjustFee(amountIn);
        uint256[] memory amounts = router.swapExactTokensForETH(
            amountIn,
            p.amountOutMin,
            p.path,
            p.predictionAddress,
            block.timestamp
        );
        amountOut = _zap(p, amounts[amounts.length - 1], p.path[0], amounts[0]);
    }

    function zapNativeIntoNative(iPar memory p)
        public
        payable
        nonReentrant
        notContract
        withNativePrediction(p)
        returns (uint256 amountOut)
    {
        uint256 amountIn = _adjustFee(msg.value);
        (bool success, ) = p.predictionAddress.call{value: amountIn}("");
        require(success, "Zap: native transfer failed");
        amountOut = _zap(p, msg.value, address(0), 0);
    }

    function setRouter(address _routerAddress) public {
        router = IPancakeRouter(_routerAddress);
        emit NewRouter(_routerAddress);
    }

    function _zap(
        iPar memory p,
        uint256 amount,
        address oToken,
        uint256 oAmount
    ) internal returns (uint256) {
        BetParams memory params = BetParams(
            p.epoch,
            msg.sender,
            amount,
            oToken,
            oAmount
        );
        if (p.isBear) {
            IPrediction(p.predictionAddress).zapBear(params);
        } else {
            IPrediction(p.predictionAddress).zapBull(params);
        }
        return amount;
    }

    function _before(iPar memory p, uint256 amount) internal {
        IERC20(p.path[0]).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(p.path[0]).safeApprove(address(router), amount);
    }

    /**
     * @notice Returns true if `account` is a contract.
     * @param account: account address
     */
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ZapperFee {
    address public daoAddress;
    address public ownerAddress;
    address public devAddress;

    uint256 public treasuryAmount;

    uint256 public treasuryFee;

    uint256 public daoShare;
    uint256 public ownerShare;

    uint256 public constant FEE_DIVIDER = 10000; // 100%
    uint256 public constant MAX_TREASURY_FEE = 1000; // 10%
    uint256 public constant DEV_SHARE = 1000; // 10%

    event NewDaoAddress(address daoAddress);
    event NewDevAddress(address devAddress);
    event NewOwnerAddress(address ownerAddress);
    event NewTreasuryFee(uint256 treasuryFee);
    event NewTreasuryDistribution(uint256 daoShare, uint256 ownerShare);
    event TreasuryClaimed(
        address indexed token,
        address daoAddress,
        address ownerAddress,
        address devAddress,
        Splitted amounts
    );

    struct Splitted {
        uint256 owner;
        uint256 dao;
        uint256 dev;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Not dev");
        _;
    }

    modifier onlyDev() {
        require(msg.sender == devAddress, "Not dev");
        _;
    }

    modifier onlyDevOrOwner() {
        require(
            msg.sender == devAddress || msg.sender == ownerAddress,
            "Not dev/owner"
        );
        _;
    }

    constructor(
        uint256 _treasuryFee,
        address _ownerAddress,
        address _devAddress,
        address _daoAddress,
        uint256 _daoShare,
        uint256 _ownerShare
    ) {
        _setTreasuryFee(_treasuryFee);
        _setOwnerAddress(_ownerAddress);
        _setDevAddress(_devAddress);
        _setDaoAddress(_daoAddress);
        _setTreasuryDistribution(_daoShare, _ownerShare);
    }

    function claimTreasury(address[] memory tokens) external onlyDevOrOwner {
        for (uint8 i = 0; i < tokens.length; i += 1) {
            _claimTreasury(tokens[i]);
        }
    }

    // setter wrappers
    function setTreasuryFee(uint256 _treasuryFee) external onlyOwner  {
        _setTreasuryFee(_treasuryFee);
    }

    function setTreasuryDistribution(uint256 _dao, uint256 _owner)
        external
        onlyDevOrOwner
    {
        _setTreasuryDistribution(_dao, _owner);
    }

    function setOwnerAddress(address _address) external onlyOwner {
        _setOwnerAddress(_address);
    }

    function setDaoAddress(address _address) external onlyOwner {
        _setDaoAddress(_address);
    }

    function setDevAddress(address _address) external onlyDev {
        _setDevAddress(_address);
    }

    // internals
    function _adjustFee(uint256 amountIn)
        internal
        view
        returns (uint256 adjustedAmount)
    {
        uint256 fee = (amountIn * treasuryFee) / FEE_DIVIDER;
        return amountIn - fee;
    }

    function _claimTreasury(address token) private {
        uint256 balance = _getBalanceIn(token);
        require(balance > 0, "Token treasury is empty");

        Splitted memory amount = _split(balance);

        if (amount.dao > 0) {
            _safeTransferIn(token, daoAddress, amount.dao);
        }
        if (amount.owner > 0) {
            _safeTransferIn(token, ownerAddress, amount.owner);
        }
        if (amount.dev > 0) {
            _safeTransferIn(token, devAddress, amount.dev);
        }

        emit TreasuryClaimed(
          token,
            daoAddress,
            ownerAddress,
            devAddress,
            amount
        );
    }

    // utils
    function _getBalanceIn(address token) private view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        } else {
            address _this = address(this);
            return IERC20(token).balanceOf(_this);
        }
    }

    function _safeTransferIn(
        address token,
        address receiver,
        uint256 amount
    ) private {
        if (token == address(0)) {
            (bool success, ) = receiver.call{value: amount}("");
            require(success, "TransferHelper: BNB_TRANSFER_FAILED");
        } else {
            IERC20(token).transfer(receiver, amount);
        }
    }

    function _split(uint256 oAmount)
        private
        view
        returns (Splitted memory amount)
    {
        uint256 _devShare = (ownerShare * DEV_SHARE) / FEE_DIVIDER;
        amount.dao = (oAmount * daoShare) / FEE_DIVIDER;
        amount.dev = (oAmount * _devShare) / FEE_DIVIDER;
        amount.owner = oAmount - amount.dao - amount.dev;
    }

    // store setters
    function _setOwnerAddress(address _owner) private {
        require(_owner != address(0), "Owner address cannot be 0");
        ownerAddress = _owner;
        emit NewOwnerAddress(ownerAddress);
    }

    function _setDaoAddress(address _dao) private {
        require(_dao != address(0), "Dao address cannot be 0");
        daoAddress = _dao;
        emit NewDaoAddress(daoAddress);
    }

    function _setDevAddress(address _dev) private {
        require(_dev != address(0), "Dev address cannot be 0");
        devAddress = _dev;
        emit NewDevAddress(devAddress);
    }

    function _setTreasuryFee(uint256 _fee) private {
        require(
            _fee <= MAX_TREASURY_FEE,
            "Fee must be less than or equal to MAX_TREASURY_FEE"
        );
        treasuryFee = _fee;
        emit NewTreasuryFee(treasuryFee);
    }

    function _setTreasuryDistribution(uint256 _dao, uint256 _owner) private {
        require(_dao + _owner == FEE_DIVIDER, "Distribution must sum to 100");
        daoShare = _dao;
        ownerShare = _owner;

        emit NewTreasuryDistribution(daoShare, ownerShare);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

struct BetParams {
  uint256 epoch;
  address account;
  uint256 amount;
  address oToken;
  uint256 oAmount;
}

interface IPrediction {

    struct Round {
        uint256 epoch;
        uint256 startTimestamp;
        uint256 lockTimestamp;
        uint256 closeTimestamp;
        int256 lockPrice;
        int256 closePrice;
        uint256 lockOracleId;
        uint256 closeOracleId;
        uint256 totalAmount;
        uint256 bullAmount;
        uint256 bearAmount;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        bool oracleCalled;
    }

    function tokenAddress() external view returns (address);

    function zapBear(BetParams calldata params) external;
    function zapBull(BetParams calldata params) external;

    function oracle() external view returns (address);

    function rounds(uint256 epoch)
        external
        view
        returns (Round memory);
    function genesisStartOnce() external view returns (bool);

    function genesisLockOnce() external view returns (bool);

    function paused() external view returns (bool);

    function currentEpoch() external view returns (uint256);

    function bufferSeconds() external view returns (uint256);

    function intervalSeconds() external view returns (uint256);

    function genesisStartRound() external;

    function pause() external;
    function unpause() external;

    function genesisLockRound() external;

    function executeRound() external;





}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
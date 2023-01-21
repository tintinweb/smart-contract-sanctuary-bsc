/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

/*
 * Day of Defeat (DOD)
 *
 * Radical Social Experiment token mathematically designed to give holders 10,000,000X PRICE INCREASE
 *
 * Website: https://dayofdefeat.app/
 * Twitter: https://twitter.com/dayofdefeatBSC
 * Telegram: https://t.me/DayOfDefeatBSC
 * BTok: https://titanservice.cn/dayofdefeatCN
 *
 * By Studio L, Legacy Capital Division
*/

// SPDX-License-Identifier: MIT

// File: StudioL/DOD/lib/SafeTransferLib.sol


pragma solidity ^0.8.0;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// File: StudioL/DOD/interface/IPancakeSwapRouter.sol


pragma solidity ^0.8.0;

interface IPancakeSwapRouter {
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: StudioL/DOD/FundPool.sol


pragma solidity ^0.8.0;





contract FundPool {
    address public operator;

    address public dodToken;

    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public governor; // governance contract

    address[] public swapPath = [dodToken, BNB, BUSD];
    uint256 public burnAmount = 400_000 * 10**18; // While selling, destroy 400,000 DOD
    uint256 public swapToFundAmount = 500_000_000 * 10**18; // 500,000,000 DOD / 2hours
    uint256 public busdThreshold = 100 * 10**18; // 100 BUSD
    uint256 public swapToFundInterval = 2 hours;
    uint256 public lastSwapTime;
    bool public fundStatus = true;

    mapping(address => bool) public access;

    event SetGovernor(address indexed newGovernor, address indexed oldGovernor);
    event SetAccess(address indexed account, bool access);
    event SetForFundPath(address indexed operator, address[] path);
    event SetSwapToFundAmount(address indexed operator, uint256 amount);
    event SetSwapToFundInterval(
        address indexed operator,
        uint256 swapToFundInterval
    );
    event SetSwapOneKey(
        address indexed operator,
        address[] path,
        bool fundStatus,
        uint256 amount,
        uint256 swapToFundInterval
    );
    event WithdrawToken(
        address indexed operator,
        address token,
        address to,
        uint256 amount
    );
    event SetBurnAmount(address indexed operator, uint256 burnAmount);
    event SetBusdThreshold(address indexed operator, uint256 busdThreshold);
    event SetFundStatus(address indexed operator, bool enable);
    event UpdateToken(address indexed oldToken, address indexed newToken);

    /**
     *  Note: After this contract is deployed,
     *  The operator privileges will be transferred to the multi-signature wallet address
     */
    constructor(
        address _operator,
        address _dodToken,
        address _governor
    ) {
        require(_operator != address(0), "error operator");
        require(_dodToken != address(0), "error dod token");
        require(Address.isContract(_dodToken), "DOD token: non contract address");
        require(_governor != address(0), "Zero governor");
        require(Address.isContract(_governor), "governor: non contract address");
        operator = _operator;
        dodToken = _dodToken; // DODtoken
        governor = _governor;
        swapPath[0] = dodToken;
        access[dodToken] = true;
        SafeTransferLib.safeApprove(dodToken, ROUTER, type(uint256).max);
    }

    /**
     * @dev Throws if the sender is not the operator.
     */
    modifier onlyOperator() {
        require(msg.sender == operator, "Treasury: caller is not the operator");
        _;
    }

    /**
     * @dev Throws if the sender is not the governor.
     */
    modifier onlyGovernor() {
        require(msg.sender == governor, "Governor: caller is not the governor");
        _;
    }

    /**
     * @dev Current pool information.
     */
    function getPoolInfo()
        external
        view
        returns (
            address _governor,
            uint256 _lastSwapTime,
            uint256 _swapToFundAmount,
            uint256 _busdThreshold,
            uint256 _burnAmount,
            bool _fundStatus,
            uint256 _swapToFundInterval,
            address[] memory _swapPath
        )
    {
        return (
            governor,
            lastSwapTime,
            swapToFundAmount,
            busdThreshold,
            burnAmount,
            fundStatus,
            swapToFundInterval,
            swapPath
        );
    }

    /**
     * 15% sales tax => transition pool
     *
     * Swap and transfer destruction are performed separately,
     * not at the same time to reduce gas consumption
     */
    function swapForFundPool() external {
        if (
            swapPath[0] != address(0) &&
            access[msg.sender] &&
            fundStatus &&
            swapToFundAmount != 0 &&
            block.timestamp >= lastSwapTime + swapToFundInterval
        ) {
            uint256 busdBalance = IERC20(BUSD).balanceOf(address(this));
            uint256 dodBalance = IERC20(dodToken).balanceOf(address(this));

            // 1. While transferring 100BUSD to the bonus pool, burn 400000 DOD
            if (dodBalance >= burnAmount && busdBalance >= busdThreshold) {
                // i. Transfer 100BUSD to the bonus pool
                bool successTransfer = IERC20(BUSD).transfer(dodToken, busdThreshold);
                require(successTransfer, "FundPool: failed to transfer");

                // ii. Destroy 400,000 DOD
                bool successBurn = IERC20(dodToken).transfer(DEAD, burnAmount);
                require(successBurn, "FundPool: failed to burn");

                lastSwapTime = block.timestamp;
                return;
            }

            // 2. Sell DOD to BUSD until the BUSD threshold is reached
            if (dodBalance >= swapToFundAmount) {
                uint256[] memory amountsOut = IPancakeSwapRouter(ROUTER)
                    .getAmountsOut(swapToFundAmount, swapPath);  // [dodAmount, bnbAmount, busdAmount]
                IPancakeSwapRouter(ROUTER)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        swapToFundAmount,
                        amountsOut[amountsOut.length - 1] / 2, // Slippage 50%
                        swapPath,
                        address(this),
                        block.timestamp + 60
                    );
                lastSwapTime = block.timestamp;
            }
        }
    }

    function setFundStatus(bool _enable) external onlyOperator {
        require(fundStatus != _enable, "same value");
        fundStatus = _enable;
        emit SetFundStatus(msg.sender, _enable);
    }

    function setAccess(address account, bool _access) external onlyOperator {
        require(account != address(0), "error account");
        require(access[account] != _access, "same value");
        access[account] = _access;
        emit SetAccess(account, _access);
    }

    function setForFundPath(address[] calldata _path) external onlyOperator {
        require(_path.length >= 2, "FundPool: error path");
        for (uint8 i = 0; i < _path.length; i++) {
            require(
                _path[i] != address(0) && Address.isContract(_path[i]),
                "FundPool: error token address"
            );
        }
        swapPath = _path;
        emit SetForFundPath(msg.sender, _path);
    }

    function setBurnAmount(uint256 _burnAmount) external onlyOperator {
        require(burnAmount != _burnAmount, "same value");
        burnAmount = _burnAmount;
        emit SetBurnAmount(msg.sender, _burnAmount);
    }

    function setBusdThreshold(uint256 _busdThreshold) external onlyOperator {
        require(busdThreshold != _busdThreshold, "same value");
        busdThreshold = _busdThreshold;
        emit SetBusdThreshold(msg.sender, _busdThreshold);
    }

    function setSwapToFundAmount(uint256 _swapAmount) external onlyOperator {
        require(swapToFundAmount != _swapAmount, "same value");
        swapToFundAmount = _swapAmount;
        emit SetSwapToFundAmount(msg.sender, _swapAmount);
    }

    function setSwapToFundInterval(uint256 _swapToFundInterval)
        external
        onlyOperator
    {
        require(swapToFundInterval != _swapToFundInterval, "same value");
        swapToFundInterval = _swapToFundInterval;
        emit SetSwapToFundInterval(msg.sender, _swapToFundInterval);
    }

    function setSwapOneKey(
        address[] calldata _path,
        bool _fundStatus,
        uint256 _burnAmount,
        uint256 _swapAmount,
        uint256 _swapToFundInterval
    ) external onlyOperator {
        require(_path.length >= 2, "FundPool: error path");
        for (uint8 i = 0; i < _path.length; i++) {
            require(
                _path[i] != address(0) && Address.isContract(_path[i]),
                "FundPool: error token address"
            );
        }
        swapPath = _path;
        fundStatus = _fundStatus;
        burnAmount = _burnAmount;
        swapToFundAmount = _swapAmount;
        swapToFundInterval = _swapToFundInterval;
        emit SetSwapOneKey(
            msg.sender,
            _path,
            _fundStatus,
            _swapAmount,
            _swapToFundInterval
        );
    }

    /**
     * @dev Set up the governance contract
     */
    function setGovernor(address _newGovernor) external onlyGovernor {
        require(_newGovernor != address(0), "error governor");
        require(governor != _newGovernor, "same governor");
        emit SetGovernor(_newGovernor, governor);
        governor = _newGovernor;
    }

    function withdrawToken(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyGovernor {
        if (_token == address(0)) {
            SafeTransferLib.safeTransferETH(_to, _amount);
        } else {
            SafeTransferLib.safeTransfer(_token, _to, _amount);
        }
        emit WithdrawToken(msg.sender, _token, _to, _amount);
    }

    /**
     * @dev If the DOD token is attacked or needs to be migrated, update the token address
     */
    function updateToken(address _dodToken) external onlyGovernor {
        require(dodToken != _dodToken, "same address");
        require(Address.isContract(_dodToken), "error token address");
        require(IERC20(_dodToken).totalSupply() != 0, "error token protocol");
        emit UpdateToken(dodToken, _dodToken);
        dodToken = _dodToken;
        swapPath[0] = dodToken;
        SafeTransferLib.safeApprove(dodToken, ROUTER, type(uint256).max);
    }

}
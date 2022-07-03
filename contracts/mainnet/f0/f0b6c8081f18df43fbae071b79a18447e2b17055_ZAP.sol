/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// File: contracts/libs/Moon Labs/ML_TransferETH.sol

contract ML_TransferETH
{
    //========================
    // ATTRIBUTES
    //======================== 

    uint256 public transferGas = 30000;

    //========================
    // CONFIG FUNCTIONS
    //======================== 

    function _setTransferGas(uint256 _gas) internal
    {
        require(_gas >= 30000, "Gas to low");
        require(_gas <= 250000, "Gas to high");
        transferGas = _gas;
    }

    //========================
    // TRANSFERFUNCTIONS
    //======================== 

    function transferETH(address _to, uint256 _amount) internal
    {
        (bool success, ) = payable(_to).call{ value: _amount, gas: transferGas }("");
        success; //prevent warning
    }
}

// File: contracts/interfaces/IReferralManager.sol

interface IReferralManager
{
    //========================
    // ATTRIBUTES
    //========================

    function userReferralMap(uint256 _referralID) external view returns (address);

    //========================
    // REFERRAL INFO FUNCTIONS
    //========================

    function getUserReferralFeeShare(address _user, string calldata _service, uint256 _amount) external view returns (uint256);
}

// File: contracts/interfaces/IFactory.sol

interface IFactory
{
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: contracts/interfaces/IRouter.sol

interface IUniRouterV1
{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniRouterV2 is IUniRouterV1
{
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

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

// File: contracts/interfaces/IToken.sol

interface IToken is IERC20
{
	function decimals() external view returns (uint8);	
	function symbol() external view returns (string memory);
	function name() external view returns (string memory);
}

// File: contracts/libs/Moon Labs/ML_TransferHelper.sol

contract ML_TransferHelper
{
    //========================
    // LIBS
    //========================

    using SafeERC20 for IToken;

    //========================
    // STRUCTS
    //========================

    struct TransferResult
    {
        uint256 fromBefore;     //balance of from-token, before transfer
        uint256 toBefore;       //balance of token, before transfer
        uint256 toAfter;        //balance of token, after transfer
        uint256 transferred;    //transferred amount 
    }

    //========================
    // FUNCTIONS
    //========================

    function safeTransferFrom(
        IToken _token,
        uint256 _amount,
        address _from,
        address _to
    ) internal returns (TransferResult memory)
    {
        //init
        TransferResult memory result = TransferResult(
        {
            fromBefore: _token.balanceOf(_from),
            toBefore: _token.balanceOf(_to),
            toAfter: 0,
            transferred: 0
        });

        //transfer
        _token.safeTransferFrom(
            _from, 
            _to, 
            _amount
        );

        //process
        result.toAfter = _token.balanceOf(_to);
        result.transferred = result.toAfter - result.toBefore;

        return result;
    }

    function safeTransfer(
        IToken _token,
        uint256 _amount,
        address _to
    ) internal returns (TransferResult memory)
    {
        return safeTransferFrom(
            _token, 
            _amount, 
            address(this), 
            _to
        );
    }

    function safeApprove(IToken _token, address _spender, uint256 _amount) internal
    {
        _token.safeApprove(_spender, 0);
        _token.safeApprove(_spender, _amount);
    }
}

// File: contracts/libs/Moon Labs/Router/ML_RouterSwap.sol

contract ML_RouterSwap is ML_TransferHelper
{
    //========================
    // LIBS
    //========================

    using SafeERC20 for IToken;

    //========================
    // STRUCTS
    //========================

    struct SwapResult
    {
        uint256 fromBefore;     //balance of from-token, before swap
        uint256 toBefore;       //balance of to-token, before swap
        uint256 toAfter;        //balance of to-token, after swap
        uint256 swapped;        //swapped amount of to-token
    }

    //========================
    // FUNCTIONS
    //========================

    function swapTokens(
        uint256 _amountIn,
        uint256 _amountOutMin,
        IUniRouterV2 _router,
        address[] memory _path,
        address _to
    ) internal returns (SwapResult memory)
    {
        //init
        IToken from = IToken(_path[0]);
        IToken to = IToken(_path[_path.length - 1]);
        SwapResult memory result = SwapResult(
        {
            fromBefore: from.balanceOf(address(this)),
            toBefore: to.balanceOf(_to),
            toAfter: 0,
            swapped: 0
        });

        //swap
        safeApprove(from, address(_router), _amountIn);
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            _amountOutMin,
            _path,
            _to,
            block.timestamp
        );

        //process
        result.toAfter = to.balanceOf(_to);
        result.swapped = result.toAfter - result.toBefore;

        return result;
    }
}

// File: contracts/interfaces/IWrappedCoin.sol

interface IWrappedCoin is IToken
{
	function deposit() external payable;
    function withdraw(uint256 _amount) external;
}

// File: contracts/interfaces/ITokenPair.sol

interface ITokenPair is IToken
{	
	function token0() external view returns (address);
	
	function token1() external view returns (address);
	
	function getReserves() external view returns (uint112, uint112, uint32);	
}

// File: contracts/libs/Moon Labs/Router/ML_RemoveLiquidity.sol

contract ML_RemoveLiquidity is ML_TransferHelper
{
    //========================
    // LIBS
    //========================

    using SafeERC20 for IToken;
    using SafeERC20 for ITokenPair;    

    //========================
    // STRUCTS
    //========================

    struct RemoveLiquidityResult
    {
        uint256 t0Before;       //balance of token0, before remove liquditdy
        uint256 t0After;        //balance of token0, after remove liquditdy
        uint256 t1Before;       //balance of token1, before remove liquditdy
        uint256 t1After;        //balance of token1, after remove liquditdy
        uint256 t0Removed;      //removed amount of token0
        uint256 t1Removed;      //removed amount of token1
    }

    //========================
    // FUNCTIONS
    //========================

    function removeLiquidity(
        uint256 _amountIn,
        uint256 _amountOutMin0,
        uint256 _amountOutMin1,
        IUniRouterV2 _router,
        ITokenPair _pair,
        address _to
    ) internal returns (RemoveLiquidityResult memory)
    {
        //init
        IToken t0 = IToken(_pair.token0());
        IToken t1 = IToken(_pair.token1());
        RemoveLiquidityResult memory result = RemoveLiquidityResult(
        {
            t0Before: t0.balanceOf(_to),
            t0After: 0,
            t1Before: t1.balanceOf(_to),
            t1After: 0,
            t0Removed: 0,
            t1Removed: 0
        });

        //remove liquidity        
        safeApprove(_pair, address(_router), _amountIn);
        _router.removeLiquidity(
            address(t0),
            address(t1),
            _amountIn,
            _amountOutMin0,
            _amountOutMin1,
            _to,
            block.timestamp
        );

        //process
        result.t0After = t0.balanceOf(_to);
        result.t0Removed = result.t0After - result.t0Before;
        result.t1After = t1.balanceOf(_to);
        result.t1Removed = result.t1After - result.t1Before;

        return result;
    }
}

// File: contracts/libs/Moon Labs/Router/ML_AddLiquidity.sol

contract ML_AddLiquidity is ML_TransferHelper
{
    //========================
    // LIBS
    //========================

    using SafeERC20 for IToken;
    using SafeERC20 for ITokenPair;    

    //========================
    // STRUCTS
    //========================

    struct AddLiquidityResult
    {        
        uint256 t0Before;       //balance of token0, before add liquditdy
        uint256 t0After;        //balance of token0, after add liquditdy
        uint256 t1Before;       //balance of token1, before add liquditdy
        uint256 t1After;        //balance of token1, after add liquditdy
        uint256 lpBefore;       //balance of LP, before add liquidity
        uint256 lpAfter;        //balance of LP, after add liquidity
        uint256 t0Unused;       //unused amount of token0
        uint256 t1Unused;       //unused amount of token1        
        uint256 lpAdded;        //added LPs
    }

    //========================
    // FUNCTIONS
    //========================

    function addLiquidity(
        uint256 _amountIn0,
        uint256 _amountIn1,
        IUniRouterV2 _router,
        ITokenPair _pair,
        address _to
    ) internal returns (AddLiquidityResult memory)
    {
        //init
        IToken t0 = IToken(_pair.token0());
        IToken t1 = IToken(_pair.token1());
        AddLiquidityResult memory result = AddLiquidityResult(
        {
            t0Before: t0.balanceOf(address(this)),
            t0After: 0,
            t1Before: t1.balanceOf(address(this)),
            t1After: 0,
            lpBefore: _pair.balanceOf(_to),
            lpAfter: 0,
            t0Unused: 0,
            t1Unused: 0,
            lpAdded: 0
        });

        //add liquidity        
        safeApprove(t0, address(_router), _amountIn0);
        safeApprove(t1, address(_router), _amountIn1);
        _router.addLiquidity(
            address(t0),
            address(t1),
            _amountIn0,
            _amountIn1,
            0,
            0,
            _to,
            block.timestamp
        );

        //process
        result.t0After = t0.balanceOf(address(this));
        result.t0Unused = result.t0Before - result.t0After;
        result.t1After = t1.balanceOf(address(this));
        result.t1Unused = result.t1Before - result.t1After;
        result.lpAfter = _pair.balanceOf(_to);
        result.lpAdded = result.lpAfter - result.lpBefore;

        return result;
    }
}

// File: contracts/libs/Moon Labs/Router/ML_SwapPathFinder.sol

contract ML_SwapPathFinder
{
    //========================
    // STRUCT
    //========================

    struct SwapPathInfo
    {        
        IUniRouterV2 router;        //used router
        address[] path;             //swap path
        uint256 amountOut;          //out amount
    }

    //========================
    // INFO FUNCTIONS
    //========================

    function findSwapPathes(
        IToken _from, 
        IToken _to, 
        uint256 _amountIn, 
        IUniRouterV2[] calldata _routers, 
        IToken[] calldata _additionalTokens
    ) public view returns (SwapPathInfo[] memory)
    {        
        SwapPathInfo[] memory pathInfo = new SwapPathInfo[](_routers.length * (_additionalTokens.length + 1));
        
        //iterate over all routers and pathes
        for (uint256 n = 0; n < _routers.length; n++)
        {
            uint256 routerIdx = n * (_additionalTokens.length + 1);

            //check direct path
            pathInfo[routerIdx] = getSwapPathInfo(
                _routers[n],
                _from,
                _to,
                IToken(address(0)),
                _amountIn
            );

            //check additional tokens
            for (uint256 m = 0; m < _additionalTokens.length; m++)
            {
                if (_additionalTokens[m] == _from
                    || _additionalTokens[m] == _to)
                {
                    continue;
                }

                //check indirect with 1 hop
                pathInfo[routerIdx + m + 1] = getSwapPathInfo(
                    _routers[n],
                    _from,
                    _to,
                    _additionalTokens[m],
                    _amountIn
                );
            }
        }

        return removeEmptyPathes(pathInfo);
    }

    //========================
    // SWAP INFO FUNCTIONS
    //========================

    function getSwapEstimate(uint256 _amountIn, IUniRouterV2 _router, address[] memory _path) public view virtual returns (uint256)
    {
        uint256[] memory estimateOuts = _router.getAmountsOut(_amountIn, _path);
        return estimateOuts[estimateOuts.length - 1];
    }

    function makeSwapPath(IToken _from, IToken _to, IToken _swapOver) internal pure returns (address[] memory)
	{
	    address[] memory path;
		if (_from == _swapOver
			|| _to == _swapOver
            || address(_swapOver) == address(0))
		{
            //direct
			path = new address[](2);
			path[0] = address(_from);
			path[1] = address(_to);
		}
		else
		{
            //indirect over wrapped coin
			path = new address[](3);
			path[0] = address(_from);
			path[1] = address(_swapOver);
			path[2] = address(_to);
		}
		
		return path;
	}

    //========================
    // HELPER
    //========================    

    function getSwapPathInfo(
        IUniRouterV2 _router, 
        IToken _from, 
        IToken _to, 
        IToken _swapOver, 
        uint256 _amountIn
    ) private view returns (SwapPathInfo memory)
    {
        SwapPathInfo memory spi;

        //validate pair
        if (address(_swapOver) == address(0))
        {
            if (!checkPairValid(_router, _from, _to))
            {
                return spi;
            }
        }
        else if (!checkPairValid(_router, _from, _swapOver)
            || !checkPairValid(_router, _swapOver, _to))
        {
            return spi;
        }

        //get info
        spi.router = _router;
        spi.path = makeSwapPath(_from, _to, _swapOver);
        spi.amountOut = getSwapEstimate(_amountIn, _router, spi.path);
        return spi;
    }

    function checkPairValid(IUniRouterV2 _router, IToken _token0, IToken _token1) private view returns (bool)
    {
        //get pair
        ITokenPair pair = ITokenPair(IFactory(_router.factory())
            .getPair(
                address(_token0),
                address(_token1)));
        if (address(pair) == address(0))
        {
            return false;
        }

        //check if real or precalculated
        try pair.token0() {}
        catch
        {
            return false;
        }
        return true;
    }

    function removeEmptyPathes(SwapPathInfo[] memory _pathes) private pure returns (SwapPathInfo[] memory)
    {
        //count used
        uint256 used = 0;
        for (uint256 n = 0; n < _pathes.length; n++)
        {
            if (_pathes[n].amountOut != 0)
            {
                used += 1;
            }
        }

        //make new list without empty
        SwapPathInfo[] memory pathesUsed = new SwapPathInfo[](used);
        if (used == 0)
        {
            return pathesUsed;
        }
        uint256 newIndex = 0;
        for (uint256 n = 0; n < _pathes.length; n++)
        {
            if (_pathes[n].amountOut != 0)
            {
                pathesUsed[newIndex] = _pathes[n];
                newIndex += 1;
                if (newIndex == used)
                {
                    break;
                }
            }
        }
        return pathesUsed;
    }
}

// File: contracts/Products/ServiceWithReferral.sol

contract ServiceWithReferral is ML_TransferETH
{
    //========================
    // LIBS
    //========================

    using SafeERC20 for IERC20;

    //========================
    // ATTRIBUTES
    //======================== 

    IReferralManager public referralManager;
    string public serviceName;

    //========================
    // CONFIG FUNCTIONS
    //======================== 

    function _setReferralManager(IReferralManager _manager) internal
    {
        referralManager = _manager;
    }

    function _setServiceName(string memory _service) internal
    {
        serviceName = _service;
    }

    //========================
    // REFERRAL FEE FUNCTIONS
    //======================== 

    function _getReferralFeeInfo(uint256 _referralID, uint256 _amount) private view returns (address, uint256, uint256)
    {
        if (address(referralManager) == address(0)
            || bytes(serviceName).length == 0
            || _referralID == 0)
        {
            return (address(0), 0, _amount);
        }

        address referrer = referralManager.userReferralMap(_referralID);
        if (referrer == address(0))
        {
            return (referrer, 0, _amount);
        }

        uint256 referralFee = referralManager.getUserReferralFeeShare(referrer, serviceName, _amount);
        return (referrer, referralFee, _amount - referralFee);
    }

    function _handleReferralFeeETH(uint256 _referralID, uint256 _amount) internal returns (uint256)
    {
        (address referrer, uint256 referralFee, uint256 amount) = _getReferralFeeInfo(_referralID, _amount);
        if (referralFee != 0)
        {
            transferETH(referrer, referralFee);
        }

        return amount;
    }

    function _handleReferralFeeToken(uint256 _referralID, IERC20 _token, uint256 _amount) internal returns (uint256)
    {
        (address referrer, uint256 referralFee, uint256 amount) = _getReferralFeeInfo(_referralID, _amount);
        if (referralFee != 0)
        {
            _token.safeTransfer(referrer, referralFee);
        }

        return amount;
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

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
     * by making the `nonReentrant` function external, and make it call a
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

// File: @openzeppelin/contracts/utils/Context.sol

/*
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

// File: @openzeppelin/contracts/security/Pausable.sol

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/Products/ZAP.sol

contract ZAP is
    ML_SwapPathFinder,
    ML_RouterSwap,
    ML_AddLiquidity,
    ML_RemoveLiquidity,
    Pausable,
    Ownable,
    ReentrancyGuard,
    ServiceWithReferral
{
    //========================
    // LIBS
    //========================

    using SafeERC20 for IToken;
    using SafeERC20 for ITokenPair;
    using SafeERC20 for IWrappedCoin;

    //========================
    // STRUCT
    //========================

    struct RouterFunctionSelectors
    {
        bytes4 addLiquidity;     
        bytes4 removeLiquidity;
        bytes4 swapExactTokenToTokenWithFee;
    }

    struct LPSwapInfo
    {
        IUniRouterV2 lpRouter;
        ITokenPair pair;
        IUniRouterV2 router0;
        IUniRouterV2 router1;
        address[] path0;
        address[] path1;
    }

    //========================
    // CONSTANTS
    //========================

    uint256 public constant PERCENT_FACTOR = 1000000; //100%	
    uint256 public constant MAX_FEE = 1000; //0.1%

    //========================
    // ATTRIBUTES
    //========================

    IWrappedCoin public wrappedCoin;

    //fees
    uint256 public swapFee;
    address public feeReceiver;

    //========================
    // MODIFIERS
    //========================

    modifier validAmount(uint256 _amount)
    {    
        _validAmount(_amount);
        _;        
    }

    function _validAmount(uint256 _amount) private pure
    {
        require(_amount > 0, "Invalid Amount");
    }
   
    //========================
    // CONSTRUCT
    //========================

    constructor(IWrappedCoin _wrappedCoin)
    {   
        wrappedCoin = _wrappedCoin;
        //0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270 //wMATIC
        //0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c //wBNB

        //fees
        setFee(250); //0.025%
        setFeeReceiver(msg.sender);  
        _setServiceName("Swap");
    }

    //========================
    // CONFIG FUNCTIONS
    //========================

    function setFee(uint256 _swapFee) public onlyOwner
    {
        require(_swapFee <= MAX_FEE, "Fee to high");
        swapFee = _swapFee;
    }

    function setFeeReceiver(address _receiver) public onlyOwner
    {
        feeReceiver = _receiver;
    }

    function setTransferGas(uint256 _gas) external onlyOwner
    {
        _setTransferGas(_gas);
    }

    //========================
    // SWAP TOKEN / COIN FUNCTIONS
    //========================

    function swapCoinToToken(
        IUniRouterV2 _router, 
        address[] calldata _path, 
        uint256 _minAmountOut, 
        uint256 _referralID
    ) external payable whenNotPaused validAmount(msg.value) nonReentrant
    {
        //check
        require(_path[0] == address(wrappedCoin), "From token is not wETH");

        //take fees  
        uint256 amount = takeFees(
            IToken(address(0)), 
            _referralID, 
            msg.value);

        //wrap        
        wrappedCoin.deposit{ value: amount }();

        //swap
        ML_RouterSwap.SwapResult memory swapResult = _tokenToToken(
            _router,
            _path,
            amount,
            false,
            false, 
            _referralID
        );

        //slippage
        checkSlippage(swapResult.swapped, _minAmountOut);
    }

    function swapTokenToCoin(
        IUniRouterV2 _router, 
        address[] calldata _path, 
        uint256 _amountIn, 
        uint256 _minAmountOut, 
        uint256 _referralID
    ) external whenNotPaused validAmount(_amountIn) nonReentrant
    {
        //check
        require(_path[_path.length - 1] == address(wrappedCoin), "To token is not wETH");

        //receive
        ML_TransferHelper.TransferResult memory transferResult = safeTransferFrom(
            IToken(_path[0]),
            _amountIn,
            msg.sender,
            address(this)
        );
        checkNoTransferTax(_amountIn, transferResult.transferred);

        //swap
        ML_RouterSwap.SwapResult memory swapResult = _tokenToToken(
            _router, 
            _path, 
            _amountIn, 
            false, 
            true,
            _referralID
        );        

        //slippage
        checkSlippage(swapResult.swapped, _minAmountOut);

        //unwrap
        wrappedCoin.withdraw(swapResult.swapped);  

        //take fees
        uint256 amount = takeFees(
            IToken(address(0)), 
            _referralID, 
            swapResult.swapped);

        //send to user
        transferETH(msg.sender, amount);
    }

    function swapTokenToToken(
        IUniRouterV2 _router, 
        address[] calldata _path, 
        uint256 _amountIn, 
        uint256 _minAmountOut, 
        uint256 _referralID
    ) external whenNotPaused validAmount(_amountIn) nonReentrant
    {
        //check
        require(_path[0] != _path[_path.length - 1], "No Swap required!");

        //receive
        ML_TransferHelper.TransferResult memory transferResult = safeTransferFrom(
            IToken(_path[0]),
            _amountIn,
            msg.sender,
            address(this)
        );
        checkNoTransferTax(_amountIn, transferResult.transferred);

        //take fees
        uint256 amount = takeFees(
            IToken(_path[0]), 
            _referralID, 
            _amountIn);

        //swap
        ML_RouterSwap.SwapResult memory swapResult = _tokenToToken(
            _router, 
            _path, 
            amount, 
            true, 
            false,
            _referralID
        );   

        //slippage
        checkSlippage(swapResult.swapped, _minAmountOut);        
    }

    //========================
    // SWAP LP FUNCTIONS
    //========================    

    function swapCoinToLP(
        LPSwapInfo memory _swapInfoOut,
        uint256 _minAmountOut, 
        uint256 _referralID
    ) external payable whenNotPaused validAmount(msg.value) nonReentrant
    {
        //check
        (address from0, address from1, address to0, address to1) = getLPSwapInfoFromTo(_swapInfoOut);   
        require(from0 == address(wrappedCoin), "Token0 path start is not wETH");
        require(from1 == address(wrappedCoin), "Token1 path start is not wETH");         
        requirePairMatchPathEnd(_swapInfoOut.pair, to0, to1);    

        //take fees
        uint256 amount = takeFees(
            IToken(address(0)), 
            _referralID, 
            msg.value);

        //wrap        
        wrappedCoin.deposit{ value: amount }();

        //add liquidity
        ML_AddLiquidity.AddLiquidityResult memory addResult = _tokenToLp(
            amount,  
            _swapInfoOut,
            false
        );

        //slippage
        checkSlippage(addResult.lpAdded, _minAmountOut);
    }    

    function swapTokenToLP(
        uint256 _amountIn,
        LPSwapInfo memory _swapInfoOut,        
        uint256 _minAmountOut, 
        uint256 _referralID
    ) external whenNotPaused validAmount(_amountIn) nonReentrant
    {
        //check
        (address from0, address from1, address to0, address to1) = getLPSwapInfoFromTo(_swapInfoOut);           
        requireMatchPathStart(from0, from1);
        requirePairMatchPathEnd(_swapInfoOut.pair, to0, to1);

        //receive
        ML_TransferHelper.TransferResult memory transferResult = safeTransferFrom(
            IToken(from0),
            _amountIn,
            msg.sender,
            address(this)
        );
        checkNoTransferTax(_amountIn, transferResult.transferred);

        //take fees
        uint256 amount = takeFees(
            IToken(to0), 
            _referralID, 
            _amountIn);

        //add liquidity
        ML_AddLiquidity.AddLiquidityResult memory addResult = _tokenToLp(
            amount,  
            _swapInfoOut,
            false
        );

        //slippage
        checkSlippage(addResult.lpAdded, _minAmountOut);
    }

    function swapLPToCoin(
        LPSwapInfo memory _swapInfoIn,
        uint256 _amountIn,        
        uint256 _minAmountOut, 
        uint256 _referralID
    ) external whenNotPaused validAmount(_amountIn) nonReentrant
    {
        //check
        (address from0, address from1, address to0, address to1) = getLPSwapInfoFromTo(_swapInfoIn); 
        require(to0 == address(wrappedCoin), "Token0 path end is not wETH");
        require(to1 == address(wrappedCoin), "Token1 path end is not wETH");   
        requirePairMatchPathStart(_swapInfoIn.pair, from0, from1);

        //remove liquidity and swap
        uint256 swapped = _lpToToken(
            _swapInfoIn,
            _amountIn,      
            true,
            true
        );

        //slippage
        checkSlippage(swapped, _minAmountOut);

        //unwrap
        wrappedCoin.withdraw(swapped);  

        //take fees
        uint256 amount = takeFees(
            IToken(address(0)), 
            _referralID, 
            swapped);  

        //send to user
        transferETH(msg.sender, amount);
    }

    function swapLPToToken(
        LPSwapInfo memory _swapInfoIn,
        uint256 _amountIn,        
        uint256 _minAmountOut, 
        uint256 _referralID
    ) external whenNotPaused validAmount(_amountIn) nonReentrant
    {
        //check
        (address from0, address from1, address to0, address to1) = getLPSwapInfoFromTo(_swapInfoIn);           
        requireMatchPathEnd(to0, to1);
        requirePairMatchPathStart(_swapInfoIn.pair, from0, from1);

        //remove liquidity and swap
        uint256 swapped = _lpToToken(
            _swapInfoIn,
            _amountIn,     
            true,
            true
        );

        //slippage
        checkSlippage(swapped, _minAmountOut);

        //take fees
        uint256 amount = takeFees(
            IToken(to0), 
            _referralID, 
            swapped);

        //send to user
        IToken(to0).safeTransfer(msg.sender, amount);
    }

    function swapLPToLP() external whenNotPaused nonReentrant
    {
        require(false, "Not implemented yet!");
    }

    //========================
    // SWAP UTILITY FUNCTIONS
    //========================

    receive() external payable {}  

    function checkSlippage(uint256 _amountOut, uint256 _minAmountOut) private pure
    {
        require(_amountOut >= _minAmountOut, "Insufficient output amount!");
    }

    function checkNoTransferTax(uint256 _requested, uint256 _received) private pure
    {
        require(_requested == _received, "No support for taxed Tokens!");
    }

    function _tokenToToken(
        IUniRouterV2 _router, 
        address[] memory _path, 
        uint256 _amountIn, 
        bool _takeFee, 
        bool _sendToContract,
        uint256 _referralID
    ) private returns (ML_RouterSwap.SwapResult memory)
    {
        //take fees
        uint256 amount = (_takeFee
            ? takeFees(
                IToken(_path[0]), 
                _referralID, 
                _amountIn)
            : _amountIn);

        //swap
        ML_RouterSwap.SwapResult memory swapResult = swapTokens(
            amount,
            0,
            _router,
            _path,
            (_sendToContract ? address(this) : msg.sender)
        );

        return swapResult;
    }

    function _lpToToken(
        LPSwapInfo memory _swapInfoIn,
        uint256 _amountIn,  
        bool _sendToContract,
        bool _fromCaller
    ) private returns (uint256)
    {  
        //remove liquidity
        ML_RemoveLiquidity.RemoveLiquidityResult memory removeResult = _removeLiquidity(
            _swapInfoIn.lpRouter, 
            _swapInfoIn.pair,
            _amountIn,
            _sendToContract,
            _fromCaller
        );

        //swap token0
        uint256 balance = 0;
        if (_swapInfoIn.path0.length > 1)
        {
            ML_RouterSwap.SwapResult memory swapResult0 = _tokenToToken(
                _swapInfoIn.router0, 
                _swapInfoIn.path0, 
                removeResult.t0Removed, 
                false, 
                true,
                0
            );        
            balance += swapResult0.swapped;
        }
        else
        {
            balance += removeResult.t0Removed;
        }

        //swap token1
        if (_swapInfoIn.path1.length > 1)
        {
            ML_RouterSwap.SwapResult memory swapResult1 = _tokenToToken(
                _swapInfoIn.router1, 
                _swapInfoIn.path1, 
                removeResult.t1Removed, 
                false, 
                true,
                0
            );        
            balance += swapResult1.swapped;
        }
        else
        {
            balance += removeResult.t1Removed;
        }

        return balance;
    }    

    function _tokenToLp(        
        uint256 _amountIn,  
        LPSwapInfo memory _swapInfoOut,
        bool _sendToContract
    ) private returns (ML_AddLiquidity.AddLiquidityResult memory)
    {
        uint256 half = _amountIn / 2;

        //swap to token0
        uint256 balance0 = half;
        if (_swapInfoOut.path0.length > 1)
        {
            balance0 = _tokenToToken(
                _swapInfoOut.router0, 
                _swapInfoOut.path0, 
                _amountIn / 2, 
                false, 
                true,
                0
            ).swapped;
        }

        //swap to token1
        uint256 balance1 = _amountIn - half;
        if (_swapInfoOut.path1.length > 1)
        {
            balance1 = _tokenToToken(
                _swapInfoOut.router1, 
                _swapInfoOut.path1, 
                _amountIn / 2, 
                false, 
                true,
                0
            ).swapped;
        }     

        //add liquidity
        ML_AddLiquidity.AddLiquidityResult memory addResult = _addLiquidity(
            _swapInfoOut.lpRouter, 
            _swapInfoOut.pair,
            balance0,
            balance1,
            _sendToContract,
            false
        );

        return addResult;
    }

    function _removeLiquidity(
        IUniRouterV2 _router, 
        ITokenPair _pair, 
        uint256 _amountIn,
        bool _sendToContract,
        bool _fromCaller
    ) private returns(ML_RemoveLiquidity.RemoveLiquidityResult memory)
    {
        if (_fromCaller)
        {
            //receive
            safeTransferFrom(
                _pair,
                _amountIn,
                msg.sender,
                address(this)
            );
        } 

        //remove liquidity        
        ML_RemoveLiquidity.RemoveLiquidityResult memory removeResult = removeLiquidity(
            _amountIn,
            0,
            0,
            _router,
            _pair,
            (_sendToContract ? address(this) : msg.sender)
        );

        return removeResult;
    }

    function _addLiquidity(
        IUniRouterV2 _router, 
        ITokenPair _pair, 
        uint256 _amountIn0,
        uint256 _amountIn1,
        bool _sendToContract,
        bool _fromCaller
    ) private returns(ML_AddLiquidity.AddLiquidityResult memory)
    {
        IToken t0 = IToken(_pair.token0());
        IToken t1 = IToken(_pair.token1());
        if (_fromCaller)
        {
            //receive
            safeTransferFrom(
                t0,
                _amountIn0,
                msg.sender,
                address(this)
            );
            safeTransferFrom(
                t1,
                _amountIn1,
                msg.sender,
                address(this)
            );
        } 

        //add liquidity        
        ML_AddLiquidity.AddLiquidityResult memory addResult = addLiquidity(
            _amountIn0,
            _amountIn1,
            _router,
            _pair,
            (_sendToContract ? address(this) : msg.sender)
        );

        return addResult;
    }

    function getLPSwapInfoFromTo(LPSwapInfo memory _info) private view returns (address from0, address from1, address to0, address to1)
    {
        //token 0
        if (_info.path0.length == 0)
        {
            from0 = _info.pair.token0();
            to0 = from0;
        }
        else
        {
            from0 = _info.path0[0];
            to0 = _info.path0[_info.path0.length - 1];
        }

        //token 1
        if (_info.path1.length == 0)
        {
            from1 = _info.pair.token1();
            to1 = from1;
        }
        else
        {
            from1 = _info.path1[0];
            to1 = _info.path1[_info.path1.length - 1];
        }

        return (
            from0,
            from1,
            to0,
            to1
        );
    }

    //========================
    // FEE FUNCTIONS
    //========================

    function calcFees(uint256 _amount) private view returns (uint256 amountAfterFee, uint256 fee)
    {   
        fee = getShare(_amount, PERCENT_FACTOR, swapFee);
        amountAfterFee = _amount - fee;
        return (amountAfterFee, fee);
    }

    function takeFees(IToken _token, uint256 _referralID, uint256 _amount) private returns (uint256)
    {   
        //calc fee
        (uint256 amountAfterFee, uint256 feeAmount) = calcFees(_amount);

        //take
        if (feeAmount > 0)
        {
            //referral
            uint256 serviceFee = (address(_token) == address(0)
                ? _handleReferralFeeToken(
                    _referralID,
                    _token,
                    feeAmount)
                : _handleReferralFeeETH(
                    _referralID,
                    feeAmount));

            //service
            if (serviceFee > 0)
            {
                if (address(_token) == address(0))
                {
                    transferETH(feeReceiver, serviceFee);
                }
                else
                {
                    _token.safeTransfer(feeReceiver, serviceFee);
                }                
            }
        }

        return amountAfterFee;
    }

    function convertFees(IUniRouterV2 _router, address[] calldata _path) external onlyOwner
    {
        require(_path[_path.length - 1] == address(wrappedCoin), "Target is not wETH");
        swapTokens(
            IToken(_path[0]).balanceOf(address(this)),
            0,
            _router,
            _path,
            address(this)
        );
    }

    //========================
    // HELPER FUNCTIONS
    //========================    

    function requirePairMatchPathStart(ITokenPair _pair, address _from0, address _from1) private view
    {
        require(_from0 == _pair.token0(), "Token0 path start not matching pair");
        require(_from1 == _pair.token1(), "Token1 path start not matching pair");
    }

    function requirePairMatchPathEnd(ITokenPair _pair, address _to0, address _to1) private view
    {
        require(_to0 == _pair.token0(), "Token0 path end not matching pair");
        require(_to1 == _pair.token1(), "Token1 path end not matching pair");
    }

    function requireMatchPathStart(address _from0, address _from1) private pure
    {
        require(_from0 == _from1, "Token0 / Token1 path start mismatch");
    }

    function requireMatchPathEnd(address _to0, address _to1) private pure
    {
        require(_to0 == _to1, "Token0 / Token1 path end mismatch");
    }

    function getSwapEstimate(uint256 _amountIn, IUniRouterV2 _router, address[] memory _path) public view override returns (uint256)
    {
        (uint256 amount, ) = calcFees(super.getSwapEstimate(_amountIn, _router, _path));
        return amount;
    }

    function getShare(uint256 _amount, uint256 _total, uint256 _share) private pure returns (uint256)
    {
        return (_amount * _share) / _total;
    }    

    function isInLP(IToken _token, IToken _lpToken0, IToken _lpToken1) private pure returns (bool)
    {
        return (_token == _lpToken0
            || _token == _lpToken1);
    }

    //========================
    // SECURITY FUNCTIONS
    //========================

    function pause() external onlyOwner
    {
        _pause();
    }

    function unpause() external onlyOwner
    {
        _unpause();
    }
}
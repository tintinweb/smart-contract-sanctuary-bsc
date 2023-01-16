/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.2;
pragma experimental ABIEncoderV2;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


interface ISwapRouter {
    
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

}



abstract contract Token {
    
    function transfer(address to, uint256 value) public virtual returns (bool);
    
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
    
    function approve(address _spender, uint256 _value) public virtual returns (bool);
    
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract SIP {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    ISwapRouter public swapRouter;

    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
    }
    
    event SubscribeToSpp(uint256 indexed sppID,address indexed customerAddress,uint256 value,uint256 period,address indexed tokenGet,address tokenGive);
    event ChargeSpp(uint256 sppID);
    event CloseSpp(uint256 sppID);
    event Deposit(address indexed token,address indexed user,uint256 amount,uint256 balance);
    event Withdraw(address indexed token,address indexed user,uint256 amount,uint256 balance);

    modifier _ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    modifier _ifNotLocked() {
        require(scLock == false);
        _;
    }
    

    function setLock() external _ownerOnly {
        scLock = !scLock;
    }

    function changeOwner(address owner_) external _ownerOnly {
        potentialAdmin = owner_;
    }

    function becomeOwner() external {
        if (potentialAdmin == msg.sender) owner = msg.sender;
    }

    function depositToken(address token, uint256 amount) external {
        require(token != address(0), "IT");
        _depositToken(token, amount);
    }

    function _depositToken(address token, uint256 amount) internal{
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        tokens[token][msg.sender] = SafeMath.add(
            tokens[token][msg.sender],
            amount
        );
        emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
    }

    function withdrawToken(address token, uint256 amount) external {
        require(token != address(0), "IT");
        tokens[token][msg.sender] = SafeMath.sub(
            tokens[token][msg.sender],
            amount
        );
        if(token == address(WETH)){
            IWETH(WETH).withdraw(amount);
            msg.sender.transfer(amount);
        }
        else {
            IERC20(token).safeTransfer(msg.sender, amount);
        } 
        emit Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
    }

    function tokenBalanceOf(address token, address user) public view returns (uint256 balance) {
        return tokens[token][user];
    }
    
    function _storePairDetails(address _token0, address _token1, address _pair) internal {
         if(pairDetails[_token0][_token1]==address(0)){ // NOT SET YET
             pairDetails[_token0][_token1] = _pair;
         }
    } 
    
    function _fetchNewAddress( uint256 _sppID, address _token0, address _token1) internal view returns (address pair) {
         if(pairDetails[_token0][_token1]==address(0)){ // NOT SET YET
             return address(_sppID);
         }
         else {
            return pairDetails[_token0][_token1];
         }
    }

    function subscribeToSpp(uint256 value, uint256 period, address tokenGet, address tokenGive, uint256 _depositAmt) external _ifNotLocked returns (uint256 sID) {
        address customerAddress = msg.sender;
        require(period >= minPeriod, "MIN_FREQUENCY");
        require(period.mod(3600) == 0, "INTEGRAL_MULTIPLE_OF_HOUR_NEEDED");

        require(tokenGet != tokenGive, "IDENTICAL_ADDRESSES");
        require(tokenGet != address(0), "ZERO_ADDRESS");

        if(_depositAmt > 0){
            _depositToken(tokenGive, _depositAmt);
        }

        require(tokenBalanceOf(tokenGive,customerAddress) >= value, "INSUFFICENT_BALANCE");
        sppID += 1;
        
        address pair = _fetchNewAddress(sppID, tokenGive, tokenGet); // Set an arbitary pair if pair doesn't exists

        if(map[pair].exists== false){
            map[pair].token.push(tokenGive);
            map[pair].token.push(tokenGet);
            map[pair].exists = true;
            _storePairDetails(tokenGive, tokenGet, pair);
        }
        map[pair].sppList.push(sppID);
        
        sppSubscriptionStats[sppID] = sppSubscribers({
            exists: true,
            customerAddress: customerAddress,
            value: value,
            period: period,
            lastPaidAt: (block.timestamp).sub(period)
        });
        tokenStats[sppID] = currentTokenStats({
            TokenToGet: tokenGet,
            TokenToGive: tokenGive, 
            amountGotten: 0,
            amountGiven: 0
        });
        sppSubList[customerAddress].arr.push(sppID);
        emit SubscribeToSpp(sppID,customerAddress,value,period,tokenGet,tokenGive);
        return sppID;
    }
    
    
    function possibleToCharge(uint256 _sppID) public view returns (bool) {
        
        sppSubscribers storage _subscriptionData = sppSubscriptionStats[_sppID];
        currentTokenStats storage _tokenStats = tokenStats[_sppID];
        address tokenGive = _tokenStats.TokenToGive;
        if(_subscriptionData.exists==false){
            return false; // SIP is not active
        }
        else if(_subscriptionData.value > tokens[tokenGive][_subscriptionData.customerAddress]){
            return false; // Insufficient Balance
        }
        
        return true;
    }

    /// @notice swapInputMultiplePools swaps a fixed amount of DAI for a maximum possible amount of WETH9 through an intermediary pool.
    /// For this example, we will swap DAI to USDC, then USDC to WETH9 to achieve our desired output.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The amount of DAI to be swapped.
    /// @return amountOut The amount of WETH9 received after the swap.
    function _swapExactInputMultihop(uint256 amountIn, address token1, address token_int, address token2, uint24 poolFee1, uint24 poolFee2, uint256 _expBlock) internal returns (uint256 amountOut) {
        
        // Approve the router to spend DAI.
        // TransferHelper.safeApprove(token1, address(swapRouter), amountIn);
        IERC20(token1).safeApprove(address(swapRouter), amountIn);
        // safeApprove(IERC20 token, address spender, uint256 value)

        // IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Multiple pool swaps are encoded through bytes called a `path`. A path is a sequence of token addresses and poolFees that define the pools used in the swaps.
        // The format for pool encoding is (tokenIn, fee, tokenOut/tokenIn, fee, tokenOut) where tokenIn/tokenOut parameter is the shared token across the pools.
        // Since we are swapping DAI to USDC and then USDC to WETH9 the path encoding is (DAI, 0.3%, USDC, 0.3%, WETH9).
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(token1, poolFee1, token_int, poolFee2, token2),
                recipient: address(this),
                deadline: _expBlock,
                amountIn: amountIn,
                amountOutMinimum: 0
            });

        // Executes the swap.
        amountOut = swapRouter.exactInput(params);
    }

    /// @notice swapInputMultiplePools swaps a fixed amount of DAI for a maximum possible amount of WETH9 through an intermediary pool.
    /// For this example, we will swap DAI to USDC, then USDC to WETH9 to achieve our desired output.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The amount of DAI to be swapped.
    /// @return amountOut The amount of WETH9 received after the swap.
    function _swapExactInputTwohops(uint256 amountIn, address token1, address token_int1, address token_int2, address token2, uint24 poolFee1, uint24 poolFee2, uint24 poolFee3, uint256 _expBlock) internal returns (uint256 amountOut) {
        
        // Approve the router to spend DAI.
        // TransferHelper.safeApprove(token1, address(swapRouter), amountIn);
        IERC20(token1).safeApprove(address(swapRouter), amountIn);

        // Multiple pool swaps are encoded through bytes called a `path`. A path is a sequence of token addresses and poolFees that define the pools used in the swaps.
        // The format for pool encoding is (tokenIn, fee, tokenOut/tokenIn, fee, tokenOut) where tokenIn/tokenOut parameter is the shared token across the pools.
        // Since we are swapping DAI to USDC and then USDC to WETH9 the path encoding is (DAI, 0.3%, USDC, 0.3%, WETH9).
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(token1, poolFee1, token_int1, poolFee2, token_int2, poolFee3, token2),
                recipient: address(this),
                deadline: _expBlock,
                amountIn: amountIn,
                amountOutMinimum: 0
            });

        // Executes the swap.
        amountOut = swapRouter.exactInput(params);
    }

    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function _swapExactInputSingle(uint256 amountIn, address token1, address token2, uint24 poolFee, uint256 _expBlock) internal returns (uint256 amountOut) {

        // Approve the router to spend DAI.
        // TransferHelper.safeApprove(token1, address(swapRouter), amountIn);
        IERC20(token1).safeApprove(address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: token1,
                tokenOut: token2,
                fee: poolFee,
                recipient: address(this),
                deadline: _expBlock,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }

    function _storePathForSwap(address pair, address[] calldata _addresses, uint24[] calldata _feePool, bool _ignoreIfSaved) internal {

        pairStats storage _pairData = map[pair]; 

        if(_pairData.initialized && _ignoreIfSaved){
            return; // Save only once for other flow
        }

        _pairData.tokenCount = _addresses.length;
        _pairData.initialized = true;

        for(uint256 i=0; i < _addresses.length; i++){
            if(_pairData.path_address.length > i){
                _pairData.path_address[i] = _addresses[i];
            }
            else {
                _pairData.path_address.push(_addresses[i]);
            }
            
        }

        for(uint256 i=0; i < _feePool.length; i++){
            if(_pairData.poolFee.length > i){
                _pairData.poolFee[i] = _feePool[i];
            }
            else {
                _pairData.poolFee.push(_feePool[i]);
            }
        }

    }

    function storePathForSwap(address pair, address[] calldata _addresses, uint24[] calldata _feePool) external _ownerOnly _ifNotLocked {
        
        require(_addresses.length <= 2, "OOA");
        require(_feePool.length > _addresses.length, "FNA");

        _storePathForSwap(pair, _addresses, _feePool, false);

    }

    // function chargeWithSPPIndexesV3(address pair, uint256[] calldata _indexes, address[] calldata _addresses, uint24[] calldata _feePool, uint256 _minGetAmount , uint256 _expBlock) external _ownerOnly _ifNotLocked {

    //     // uint256 actualTokenRec;
    //     pairStats storage _pairData = map[pair]; 
        
    //     uint256[] storage sppList = _pairData.sppList;
        
    //     require(sppList.length!=0, "No SIP to charge");
    //     require(_addresses.length <= 2, "OOA");
    //     require(_feePool.length > _addresses.length, "FNA");

    //     _storePathForSwap(pair, _addresses, _feePool, true);
        
    //     address[] storage pathSwap = _pairData.token;
        
    //     // uint256 finalAmountGive = 0;
    //     // uint256 finalAmountGotten = 0;
        
    //     chargeSppStruct[] memory sppCharged = new chargeSppStruct[]((_indexes.length + 1));
    //     chargeSppStructLocals memory sppLocals;
        
    //     // uint successIndex = 0;
        
    //     for(uint256 i=0; i< _indexes.length; i++){
    //         if(_indexes[i] > (sppList.length-1)){
    //             continue; // No such SIP index. Invalid input. Return and save GAS
    //         }
    //         uint256 _sppID = sppList[_indexes[i]];
    //         sppSubscribers storage _subscriptionData = sppSubscriptionStats[_sppID];
    //         if(_subscriptionData.exists==false){
    //             continue; // SIP is not active
    //         }
    //         else if(_subscriptionData.lastPaidAt + _subscriptionData.period > block.timestamp){
    //             continue; // Charging too early
    //         }
    //         else if(_subscriptionData.value >= tokens[pathSwap[0]][_subscriptionData.customerAddress]){
    //             continue; // Insufficient Balance
    //         }
    //         else {
    //             sppLocals.amtCollected += _subscriptionData.value;
    //             _deductTokens(_subscriptionData.value, _subscriptionData.customerAddress, pathSwap[0]);
    //             sppCharged[sppCharged.length] = chargeSppStruct({
    //                 sppId: _sppID,
    //                 amt: _subscriptionData.value,
    //                 custAdd: _subscriptionData.customerAddress
    //             });
    //             // successIndex++;
    //         }
    //     }
        
    //     // uint256 finalAmountGiveOriginal = finalAmountGive;
    //     sppLocals.amtAfterFee = sppLocals.amtCollected.sub(_deductSppFee(sppLocals.amtCollected, pathSwap[0]));
    //     // finalAmountGive.sub(_deductSppFee(finalAmountGive, pathSwap[0]));
    //     require(sppLocals.amtAfterFee > 0 , "Nothing left after fee");
        
    //     if(_addresses.length == 0){
    //         // Consider direct swap 
    //         sppLocals.amtReceived = _swapExactInputSingle(sppLocals.amtAfterFee, pathSwap[0], pathSwap[1], _feePool[0], _expBlock);
    //     }
    //     else if(_addresses.length == 1){
    //         // Consider swap with one intermediate
    //         sppLocals.amtReceived = _swapExactInputMultihop(sppLocals.amtAfterFee, pathSwap[0], _addresses[0], pathSwap[1], _feePool[0], _feePool[1], _expBlock);
    //     }
    //     else {
    //         // Consider swap with one intermediate
    //         sppLocals.amtReceived = _swapExactInputTwohops(sppLocals.amtAfterFee, pathSwap[0], _addresses[0], _addresses[1], pathSwap[1], _feePool[0], _feePool[1], _feePool[2], _expBlock);
    //     }

    //     require(sppLocals.amtReceived >= _minGetAmount, "LTM");

    //     // finalAmountGotten = actualTokenRec;
        
    //     for(uint256 k=0; k<sppCharged.length; k++){
    //         uint256 _credAmt = ((sppCharged[k].amt).mul(sppLocals.amtReceived)).div(sppLocals.amtCollected);
    //         _creditTokens( _credAmt, sppCharged[k].custAdd, pathSwap[1]);
    //         require(setcurrentTokenStats(sppCharged[k].sppId, _credAmt, sppCharged[k].amt),"setcurrentTokenStats failed");
    //         require(setLastPaidAt(sppCharged[k].sppId),"setLastPaidAt failed");
    //     }
    // }

    function chargeWithSavedPathSPPIndexesV3(address pair, uint256[] calldata _indexes, uint256 _minGetAmount, uint256 _expBlock) external _ifNotLocked {

        pairStats storage _pairData = map[pair]; 

        require(_pairData.initialized, "NYI");

        uint256[] storage sppList = _pairData.sppList;
        
        require(sppList.length!=0, "No SIP to charge");
        
        address[] storage pathSwap = _pairData.token;
        
        
        chargeSppStruct[] memory sppCharged = new chargeSppStruct[]((_indexes.length + 1));

        chargeSppStructLocals memory sppLocals;
        
        // uint successIndex = 0;
        
        for(uint256 i=0; i< _indexes.length; i++){
            if(_indexes[i] > (sppList.length-1)){
                continue; // No such SIP index. Invalid input. Return and save GAS
            }
            uint256 _sppID = sppList[_indexes[i]];
            sppSubscribers storage _subscriptionData = sppSubscriptionStats[_sppID];
            if(_subscriptionData.exists==false){
                continue; // SIP is not active
            }
            else if(_subscriptionData.lastPaidAt + _subscriptionData.period > block.timestamp){
                continue; // Charging too early
            }
            else if(_subscriptionData.value > tokens[pathSwap[0]][_subscriptionData.customerAddress]){
                continue; // Insufficient Balance
            }
            else {
                sppLocals.amtCollected += _subscriptionData.value;
                _deductTokens(_subscriptionData.value, _subscriptionData.customerAddress, pathSwap[0]);
                sppCharged[sppLocals.successIndex] = chargeSppStruct({
                    sppId: _sppID,
                    amt: _subscriptionData.value,
                    custAdd: _subscriptionData.customerAddress
                });
                sppLocals.successIndex++;
                // successIndex++;
            }
        }
        

        sppLocals.amtAfterFee =  SafeMath.sub(sppLocals.amtCollected, _deductSppFee(sppLocals.amtCollected, pathSwap[0], msg.sender));
        // uint256 finalAmountGiveOriginal = finalAmountGive;
        // finalAmountGive.sub(_deductSppFee(finalAmountGive, pathSwap[0]));
        require(sppLocals.amtAfterFee > 0 , "Nothing left after fee");
        
        if(_pairData.tokenCount == 0){
            // Consider direct swap 
            sppLocals.amtReceived = _swapExactInputSingle(sppLocals.amtAfterFee, pathSwap[0], pathSwap[1], _pairData.poolFee[0], _expBlock);
        }
        else if(_pairData.tokenCount == 1){
            // Consider swap with one intermediate
            sppLocals.amtReceived = _swapExactInputMultihop(sppLocals.amtAfterFee, pathSwap[0], _pairData.path_address[0], pathSwap[1], _pairData.poolFee[0], _pairData.poolFee[1], _expBlock);
        }
        else {
            // Consider swap with one intermediate
            sppLocals.amtReceived = _swapExactInputTwohops(sppLocals.amtAfterFee, pathSwap[0], _pairData.path_address[0], _pairData.path_address[1], pathSwap[1], _pairData.poolFee[0], _pairData.poolFee[1], _pairData.poolFee[2], _expBlock);
        }

        require(sppLocals.amtReceived >= _minGetAmount, "LTM");
        
        for(uint256 k=0; k<sppLocals.successIndex; k++){
            uint256 _credAmt = ((sppCharged[k].amt).mul(sppLocals.amtReceived)).div(sppLocals.amtCollected);
            _creditTokens( _credAmt, sppCharged[k].custAdd, pathSwap[1]);
            require(setcurrentTokenStats(sppCharged[k].sppId, _credAmt, sppCharged[k].amt),"setcurrentTokenStats failed");
            require(setLastPaidAt(sppCharged[k].sppId),"setLastPaidAt failed");
        }
    }

    function calculateAmountToCharge(address pair, uint256[] calldata _indexes) public view returns (uint256 swapExactAmt) {

        pairStats storage _pairData = map[pair]; 

        uint256[] storage sppList = _pairData.sppList;
        
        address[] storage pathSwap = _pairData.token;

        chargeSppStructLocals memory sppLocals;
        
        for(uint256 i=0; i< _indexes.length; i++){
            if(_indexes[i] > (sppList.length-1)){
                continue; // No such SIP index. Invalid input. Return and save GAS
            }
            uint256 _sppID = sppList[_indexes[i]];
            sppSubscribers storage _subscriptionData = sppSubscriptionStats[_sppID];
            if(_subscriptionData.exists==false){
                continue; // SIP is not active
            }
            else if(_subscriptionData.lastPaidAt + _subscriptionData.period > block.timestamp){
                continue; // Charging too early
            }
            else if(_subscriptionData.value > tokens[pathSwap[0]][_subscriptionData.customerAddress]){
                continue; // Insufficient Balance
            }
            else {
                sppLocals.amtCollected += _subscriptionData.value;
            }
        }

        sppLocals.amtAfterFee =  SafeMath.sub(sppLocals.amtCollected, _calcSppFee(sppLocals.amtCollected));
        return sppLocals.amtAfterFee;

    }


    function chargeWithAggregator(address pair, uint256[] calldata _indexes, uint256 _minGetAmount, bytes calldata _data) external _ifNotLocked {

        pairStats storage _pairData = map[pair]; 

        uint256[] storage sppList = _pairData.sppList;
        
        require(sppList.length!=0, "No SIP to charge");
        
        address[] storage pathSwap = _pairData.token;

        (,SwapDescription memory desc,,) = abi.decode(_data[4:], (address, SwapDescription, bytes, bytes));

        require(address(desc.srcToken) == pathSwap[0], "IST"); // Invalid start token
        require(address(desc.dstToken) == pathSwap[1], "IET"); // Invalid end token
        require(address(desc.dstReceiver) == address(this), "SOA"); // Scammy overwrite attempt

        chargeSppStruct[] memory sppCharged = new chargeSppStruct[]((_indexes.length + 1));

        chargeSppStructLocals memory sppLocals;
        
        for(uint256 i=0; i< _indexes.length; i++){
            if(_indexes[i] > (sppList.length-1)){
                continue; // No such SIP index. Invalid input. Return and save GAS
            }
            uint256 _sppID = sppList[_indexes[i]];
            sppSubscribers storage _subscriptionData = sppSubscriptionStats[_sppID];
            if(_subscriptionData.exists==false){
                continue; // SIP is not active
            }
            else if(_subscriptionData.lastPaidAt + _subscriptionData.period > block.timestamp){
                continue; // Charging too early
            }
            else if(_subscriptionData.value > tokens[pathSwap[0]][_subscriptionData.customerAddress]){
                continue; // Insufficient Balance
            }
            else {
                sppLocals.amtCollected += _subscriptionData.value;
                _deductTokens(_subscriptionData.value, _subscriptionData.customerAddress, pathSwap[0]);
                sppCharged[sppLocals.successIndex] = chargeSppStruct({
                    sppId: _sppID,
                    amt: _subscriptionData.value,
                    custAdd: _subscriptionData.customerAddress
                });
                sppLocals.successIndex++;
                // successIndex++;
            }
        }
        

        sppLocals.amtAfterFee =  SafeMath.sub(sppLocals.amtCollected, _deductSppFee(sppLocals.amtCollected, pathSwap[0], msg.sender));
        // uint256 finalAmountGiveOriginal = finalAmountGive;
        // finalAmountGive.sub(_deductSppFee(finalAmountGive, pathSwap[0]));
        require(sppLocals.amtAfterFee > 0 , "Nothing left after fee");
        require(desc.amount == sppLocals.amtAfterFee , "Amt of transfer incorrect");

        IERC20(pathSwap[0]).approve(AGGREGATION_ROUTER_V3, desc.amount);

        (bool succ, bytes memory _dataRes) = address(AGGREGATION_ROUTER_V3).call(_data);
        if (succ) {
            (uint returnAmount,) = abi.decode(_dataRes, (uint, uint));
            require(returnAmount >= _minGetAmount, "LTM"); // Less than min
            sppLocals.amtReceived = returnAmount;
        } else {
            revert();
        }
        
        for(uint256 k=0; k<sppLocals.successIndex; k++){
            uint256 _credAmt = ((sppCharged[k].amt).mul(sppLocals.amtReceived)).div(sppLocals.amtCollected);
            _creditTokens( _credAmt, sppCharged[k].custAdd, pathSwap[1]);
            require(setcurrentTokenStats(sppCharged[k].sppId, _credAmt, sppCharged[k].amt),"setcurrentTokenStats failed");
            require(setLastPaidAt(sppCharged[k].sppId),"setLastPaidAt failed");
        }
    }

    function chargeSppByID(uint256 _sppId, uint256 _expBlock) external _ifNotLocked  {
        
        currentTokenStats storage _tokenStats = tokenStats[_sppId];
        uint256 actualTokenRec;

        pairStats storage _pairData = map[pairDetails[_tokenStats.TokenToGive][_tokenStats.TokenToGet]];
        
        uint256 finalAmountGive = 0;

        sppSubscribers storage _subscriptionData = sppSubscriptionStats[_sppId];
        require(_subscriptionData.exists==true, "NVS");
        require(_subscriptionData.lastPaidAt + _subscriptionData.period <= block.timestamp, "CTE");
        require(_subscriptionData.value <= tokens[_tokenStats.TokenToGive][_subscriptionData.customerAddress], "IB");

        finalAmountGive = _subscriptionData.value;

        finalAmountGive =  SafeMath.sub(finalAmountGive, _deductSppFee(finalAmountGive, _tokenStats.TokenToGive, msg.sender));
        // finalAmountGive.sub(_deductSppFee(finalAmountGive, _tokenStats.TokenToGive));
        require(finalAmountGive > 0 , "Nothing to charge");
        
        _deductTokens(_subscriptionData.value, _subscriptionData.customerAddress, _tokenStats.TokenToGive);


        if(_pairData.tokenCount == 0){
            // Consider direct swap 
            actualTokenRec = _swapExactInputSingle(finalAmountGive, _pairData.token[0], _pairData.token[1], _pairData.poolFee[0], _expBlock);
        }
        else if(_pairData.tokenCount == 1){
            // Consider swap with one intermediate
            actualTokenRec = _swapExactInputMultihop(finalAmountGive, _pairData.token[0], _pairData.path_address[0], _pairData.token[1], _pairData.poolFee[0], _pairData.poolFee[1], _expBlock);
        }
        else {
            // Consider swap with one intermediate
            actualTokenRec = _swapExactInputTwohops(finalAmountGive, _pairData.token[0], _pairData.path_address[0], _pairData.path_address[1], _pairData.token[1], _pairData.poolFee[0], _pairData.poolFee[1], _pairData.poolFee[2], _expBlock);
        }

        _creditTokens( actualTokenRec, _subscriptionData.customerAddress, _tokenStats.TokenToGet);
        require(setcurrentTokenStats(_sppId, actualTokenRec, _subscriptionData.value),"setcurrentTokenStats failed");
        require(setLastPaidAt(_sppId),"setLastPaidAt failed");

    }
    
 
    function _deductSppFee(uint256 _amt, address _token, address _charger) internal returns (uint256) {
        uint256 _feeAmt = ((_amt).mul(fee)).div(10000);
        uint _feeAdmin = ((_feeAmt).mul(split)).div(100);
        uint _feeCharger = _feeAmt.sub(_feeAdmin);
        if(_feeAdmin > 0){
            _creditTokens(_feeAdmin, feeAccount, _token);
        }
        if(_feeCharger > 0){
            _creditTokens(_feeCharger, _charger, _token);
        }
        return _feeAmt;
    }

    function _calcSppFee(uint256 _amt) internal view returns (uint256) {
        uint256 _feeAmt = ((_amt).mul(fee)).div(10000);
        return _feeAmt;
    }
    
    function _deductTokens(uint256 _amt, address _custAdd, address _token) internal {
        tokens[_token][_custAdd] = SafeMath.sub(tokens[_token][_custAdd],_amt);
    }
    
    function _creditTokens(uint256 _amt, address _custAdd, address _token) internal {
        tokens[_token][_custAdd] = SafeMath.add(tokens[_token][_custAdd],_amt);
    }
    

    function closeSpp(uint256 _sppId) external returns (bool success) {
        require(msg.sender == sppSubscriptionStats[_sppId].customerAddress, "NA");
        sppSubscriptionStats[_sppId].exists = false;
        emit CloseSpp(_sppId);
        return true;
    }  

    function setMinPeriod(uint256 p) external _ownerOnly {
        minPeriod = p;
    }

    function setLastPaidAt(uint256 _sppID) internal returns (bool success) {
        sppSubscribers storage _subscriptionData = sppSubscriptionStats[_sppID];
        _subscriptionData.lastPaidAt = getNearestHour(block.timestamp);
        return true;
    }

    function setcurrentTokenStats(uint256 _sppID, uint256 amountGotten, uint256 amountGiven) internal returns (bool success) {
        currentTokenStats storage _tokenStats = tokenStats[_sppID];
        _tokenStats.amountGotten = _tokenStats.amountGotten.add(amountGotten);
        _tokenStats.amountGiven = _tokenStats.amountGiven.add(amountGiven);
        return true;
    }

    function isActiveSpp(uint256 _sppID) public view returns (bool res) {
        return sppSubscriptionStats[_sppID].exists;
    }
    
     function getLatestSppId() public view returns (uint256 sppId) {
        return sppID;
    }

    function getlistOfSppSubscriptions(address _from) public view returns (uint256[] memory arr) {
        return sppSubList[_from].arr;
    }

    function getcurrentTokenAmounts(uint256 _sppID) public view returns (uint256[2] memory arr) {
        arr[0] = tokenStats[_sppID].amountGotten;
        arr[1] = tokenStats[_sppID].amountGiven;
        return arr;
    }

    function getTokenStats(uint256 _sppID) public view returns (address[2] memory arr) {
        arr[0] = tokenStats[_sppID].TokenToGet;
        arr[1] = tokenStats[_sppID].TokenToGive;
        return arr;
    }
    
    function fetchPair(uint256 _sppID) public view returns (address pair) {
        currentTokenStats storage _tokenStats = tokenStats[_sppID];
        
        address tokenGive = _tokenStats.TokenToGive;
        address tokenGet = _tokenStats.TokenToGet;

        address _pair = pairDetails[tokenGive][tokenGet];
        return (_pair);
    }
    
    function fetchPathDetailsAdd(address _pair) public view returns (address[] memory arr) {
        return map[_pair].token; 
    }
    
    function fetchPathDetailsSPP(address _pair) public view returns (uint256[] memory arr) {
        return map[_pair].sppList;
    }

    function getTimeRemainingToCharge(uint256 _sppID) public view returns (uint256 time) {
        if((sppSubscriptionStats[_sppID].lastPaidAt).add(sppSubscriptionStats[_sppID].period) < block.timestamp){
            return 0;
        }
        else {
          return ((sppSubscriptionStats[_sppID].lastPaidAt).add(sppSubscriptionStats[_sppID].period).sub(block.timestamp));  
        }
    }
    
    // Update dev address by initiating with the previous dev.
    function changeFee(uint8 _fee, uint8 _split) external _ownerOnly{
        require(_fee <= 100, "Cannot increase fee beyond 1%");
        require(_fee >= 0, "Cannot reduce beyond 0");
        require(_split <= 100, "More than 100 not possible");
        require(_split >= 0, "Cannot reduce beyond 0");
        fee = _fee;
        split = _split;
    }
    
    // This function is to optimise batching process
    function getNearestHour(uint256 _time) public pure returns (uint256) {
        uint256 _secondsExtra = _time.mod(3600);
        if(_secondsExtra > 1800){
            return ((_time).add(3600)).sub(_secondsExtra);
        }
        else {
            return (_time).sub(_secondsExtra);
        }
    }

    struct sppSubscribers {
        bool exists;
        address customerAddress;
        uint256 value; 
        uint256 period;
        uint256 lastPaidAt;
    }

    struct currentTokenStats {
        address TokenToGet;
        address TokenToGive;
        uint256 amountGotten;
        uint256 amountGiven;
    }

    struct listOfSppByAddress {
        uint256[] arr;
    }
    
    struct pairStats{
        address[] token;
        address[] path_address;
        uint256[] sppList;
        uint24[] poolFee;
        uint256 tokenCount;
        bool exists;
        bool initialized;
    }
    
    struct chargeSppStruct {
        uint256 sppId;
        uint256 amt;
        address custAdd;
    }

    struct chargeSppStructLocals {
        uint256 amtCollected;
        uint256 amtAfterFee;
        uint256 amtReceived;
        uint256 successIndex;
    }
    
    mapping(uint256 => uint256) public sppAmounts;
    mapping(address => pairStats) private map;
    mapping(uint256 => currentTokenStats) tokenStats;
    mapping(address => listOfSppByAddress) sppSubList;
    mapping(uint256 => sppSubscribers) public sppSubscriptionStats;
    
    mapping(address => mapping(address => uint256)) public tokens;
    
    // TOKEN0 -> TOKEN1 -> PAIRADD
    mapping(address => mapping(address => address)) public pairDetails;
    

    address public owner;
    address public WETH;
    address private potentialAdmin;
    uint256 public sppID;
    address public feeAccount;
    address public AGGREGATION_ROUTER_V3;
    
    uint256 public minPeriod = 3600;

    bool public scLock = false;
    uint8 public fee = 50;
    uint8 public split = 70; // % of fee admin accont gets
    
}

contract BNSSIPDapp is SIP {

    receive() external payable {
        uint256 eth = msg.value;
        if(msg.sender!=address(WETH)){
            IWETH(WETH).deposit{value: eth}();
            _creditTokens(eth, msg.sender, WETH);
        } // else its a withdraw call from WETH contract
    }

    string public name;

    constructor(ISwapRouter _swapRouter, address _feeAccount, address _weth, address _agg) {
        owner = msg.sender;
        name = "BNS SIP Dapp";
        swapRouter = _swapRouter;
        feeAccount = _feeAccount;
        WETH = _weth;
        AGGREGATION_ROUTER_V3 = _agg;
    }
}
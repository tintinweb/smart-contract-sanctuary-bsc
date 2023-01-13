/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
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
        assembly { size := extcodesize(account) }
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract MidWallet  {
    using Address for address;
    address public owner;
    mapping(address => uint) public userDepositedTokens;
    mapping(address => userDetails) public userProfile;
    struct userDetails {
        address userAddress;
        uint256 TokensDeposited;
        uint256 depositPrice;
        uint256 totalPriceBUSD;
        uint256 depositTime;
        bool hasDeposited;
        bool withdrawPaused;
        bool status;
        bool autoWithdraw;
    }
    userDetails[] private userDetailsHistory;
    userDetails[] private inactiveUserTransferHistory;
    IUniswapV2Router02 public uniswapV2Router;

    event Withdraw(address indexed user, uint256 amount, address token);
    event Deposit(address indexed user, uint256 amount, address token);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// NSI-Testnet(TKNSI3.0): 0x1acdaF174B876eaf7340628Fe0ce31B411C57853
    /// NSI-Mainnet: 0x7eFb55D9AC57B23Cc6811c9068db3CF83CBDfe39

    address public currentToken;

    /// BUSD-Testnet360: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    /// BUSD-Testnet-nhancv: 0xE0dFffc2E01A7f051069649aD4eb3F518430B6a4
    /// BUSD-Mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

    address public BUSD;
    uint256 public currentDepositBusdLimit = 10 *10**18;
    uint256 public tokenWorthIncrease =10;
    uint256 oneToken = 1 *10**18;

    constructor(address curTknAdd, address busdAdd ) {

        currentToken = curTknAdd;
        BUSD = busdAdd;
        //PCS router v2 testnet360: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //PCS router v2 mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapV2Router = IUniswapV2Router02(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0); 
        owner = msg.sender;
    }

    modifier checkAllowance( address token , uint amount)  {
        require(IERC20(token).allowance(msg.sender, address(this)) >= amount, "NSI_MidWallet: Transfering more than allowed");
        _;
    }

    function checkAllowanceof(address token) external view returns(uint) {
        return (IERC20(token).allowance(msg.sender, address(this)));        
    }

    function depositTokens(uint _amount) public checkAllowance(currentToken, _amount) {
        require(msg.sender == owner, "Only Owner");
        IERC20(currentToken).transferFrom(msg.sender, address(this), _amount);
        userDepositedTokens[owner] += _amount;
        emit Deposit(msg.sender, _amount, currentToken);
    }

    function stakeTokens() public checkAllowance(currentToken, currentTokenDepoitPrice()) {        
        require(!userProfile[msg.sender].hasDeposited, "Cannot deposit more than once.");
        uint256 currentPriceAll = currentTokenDepoitPrice();
        uint256 currentPricePerToken = currentTokenPrice();
        IERC20(currentToken).transferFrom(msg.sender, address(this), currentPriceAll);
        userDepositedTokens[msg.sender] += currentPriceAll;
        userProfile[msg.sender].userAddress = msg.sender;
        userProfile[msg.sender].TokensDeposited = currentPriceAll;
        userProfile[msg.sender].depositPrice = currentPricePerToken;
        userProfile[msg.sender].totalPriceBUSD = currentDepositBusdLimit ;
        userProfile[msg.sender].depositTime = block.timestamp;
        userProfile[msg.sender].hasDeposited = true;
        userProfile[msg.sender].withdrawPaused = true;
        userProfile[msg.sender].status = true;
        userProfile[msg.sender].autoWithdraw = false;
        userDetailsHistory.push(userDetails(msg.sender,currentPriceAll,currentPricePerToken,currentDepositBusdLimit,block.timestamp,true, true, true, false));
        emit Deposit(msg.sender, currentPriceAll, currentToken);        
    }

    function canWithdraw(address user) internal view returns(bool){
       require(userProfile[user].hasDeposited == true, "Deposit First");
       uint256 UserDepositPrice = userProfile[user].TokensDeposited;
       uint256 UserDepositLimitBUSD = userProfile[user].totalPriceBUSD;
       uint256 currentTotalPrice = getAmountOutMin(BUSD, currentToken, UserDepositLimitBUSD);
       uint256 withdrawThreshold = (UserDepositPrice * tokenWorthIncrease)/100;
       uint256 minPrice = UserDepositPrice + withdrawThreshold;
       return currentTotalPrice >= minPrice;
    }

    function isEligibleToWithdraw(address user) external view 
       returns (uint256 current, uint256 expected, bool withdraw_possible) {        
       require(userProfile[user].hasDeposited == true, "Deposit First");
       uint256 UserDepositPrice = userProfile[user].TokensDeposited;
       uint256 UserDepositLimitBUSD = userProfile[user].totalPriceBUSD;
       uint256 currentTotalPrice = getAmountOutMin(BUSD, currentToken, UserDepositLimitBUSD);
       uint256 withdrawThreshold = (UserDepositPrice * tokenWorthIncrease)/100;
       uint256 minPrice = UserDepositPrice + withdrawThreshold;
       return (currentTotalPrice ,minPrice, currentTotalPrice >= minPrice);
    }
  
    function updateUserDetails(address user,  uint256 TokensDeposited,
        uint256 depositPrice, uint256 totalPrice, uint256 depositTime, 
        bool hasDeposited, bool withdrawPaused, bool status, bool autoWithdraw
        ) external {
        require(msg.sender == owner,"Only Owner");
        userDepositedTokens[user] += TokensDeposited;
        userProfile[user].userAddress = user;
        userProfile[user].TokensDeposited = TokensDeposited;
        userProfile[user].depositPrice = depositPrice;
        userProfile[user].totalPriceBUSD = totalPrice;
        userProfile[user].depositTime = depositTime;
        userProfile[user].hasDeposited = hasDeposited;
        userProfile[user].withdrawPaused = withdrawPaused;
        userProfile[user].status = status;
        userProfile[user].autoWithdraw = autoWithdraw;
        userDetailsHistory.push(userDetails(user ,TokensDeposited,depositPrice,totalPrice,depositTime,hasDeposited, withdrawPaused, status, autoWithdraw));       
    }
        
    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) public view returns (uint256) {            
        address[] memory path;
        address  WETH = 0x0dE8FCAE8421fc79B29adE9ffF97854a424Cad09;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }            
        uint256[] memory amountOutMins = IUniswapV2Router02(uniswapV2Router).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == owner, "Only Owner");
        require(_amount <=userDepositedTokens[owner], "Withdraw amount exceeds current balance");
        IERC20(currentToken).transfer(msg.sender, _amount);
        userDepositedTokens[msg.sender] -= _amount;
        emit Withdraw(msg.sender, _amount, currentToken);
    }

    function userWithrawProfit() external  {
        require(userDepositedTokens[msg.sender] > 0,"User Doesn't have funds to withdraw.");
        require(userProfile[msg.sender].withdrawPaused == false,"Withdraw is paused");
        require(canWithdraw(msg.sender) == true, "You can't withdraw at the moment.");
        uint256 UserDepositPrice = userProfile[msg.sender].TokensDeposited;
        uint256 UserDepositLimitBUSD = userProfile[msg.sender].totalPriceBUSD;
        uint256 currentTotalPrice = getAmountOutMin(BUSD, currentToken, UserDepositLimitBUSD);
        uint256 withdrawableAmount = currentTotalPrice - UserDepositPrice;
        IERC20(currentToken).transfer(msg.sender, withdrawableAmount);
        userDepositedTokens[msg.sender] -= withdrawableAmount; 
        userProfile[msg.sender].TokensDeposited -= withdrawableAmount;
        userProfile[msg.sender].withdrawPaused = true;
        userDetailsHistory.push(userDetails(msg.sender,withdrawableAmount,userProfile[msg.sender].depositPrice,userProfile[msg.sender].totalPriceBUSD,userProfile[msg.sender].depositTime,true, true, true, userProfile[msg.sender].autoWithdraw));
        emit Withdraw(msg.sender, withdrawableAmount, currentToken);
    }

    function AutoWithdraw() public {
        require(msg.sender == owner, "Only Owner");
        for (uint i = 0; i < userDetailsHistory.length; i++) {
            address user = userDetailsHistory[i].userAddress;
            if (userProfile[user].autoWithdraw) {
                require(userDepositedTokens[user] > 0,"User Doesn't have funds to withdraw.");
                require(userProfile[user].withdrawPaused == false,"Withdraw is paused");
                require(canWithdraw(user) == true, "You can't withdraw at the moment.");
                uint256 UserDepositPrice = userProfile[user].TokensDeposited;
                uint256 UserDepositLimitBUSD = userProfile[user].totalPriceBUSD;
                uint256 currentTotalPrice = getAmountOutMin(BUSD, currentToken, UserDepositLimitBUSD);
                uint256 withdrawableAmount = currentTotalPrice - UserDepositPrice;
                IERC20(currentToken).transfer(user, withdrawableAmount);
                userDepositedTokens[user] -= withdrawableAmount;
                userProfile[user].TokensDeposited -= withdrawableAmount;
                userProfile[user].withdrawPaused = true;
                userDetailsHistory.push(userDetails(user,withdrawableAmount,userProfile[user].depositPrice,userProfile[user].totalPriceBUSD,userProfile[user].depositTime,true, true, true, userProfile[user].autoWithdraw));
                emit Withdraw(msg.sender, withdrawableAmount, currentToken);
            }
        }
    }


    function setDepositLimitInBusd(uint256 busdAmount) external {
        require(msg.sender == owner , "Only Owner");
        currentDepositBusdLimit = busdAmount * 10 **18;
    }

    function updateTokenWorthIncrease(uint256 percentage) external {
        require(msg.sender == owner, "Only Owner");
        tokenWorthIncrease = percentage;
    }

    function currentTokenDepoitPrice() public view returns (uint256){
        return getAmountOutMin(BUSD, currentToken, currentDepositBusdLimit);
    } 

    function currentTokenPrice() public view returns (uint256) {
        return getAmountOutMin(currentToken, BUSD , oneToken);
    }

    function usersHistory() external view returns(userDetails[] memory){
        return userDetailsHistory;
    }

    function inActiveUserTransferHistory() external view returns(userDetails[] memory){
        return inactiveUserTransferHistory;
    }

    function isWithdrawPaused(address user)external view returns (bool){
       return userProfile[user].withdrawPaused;
    }

    function updateUserWithdrawStatus(address user, bool paused) external {
        require(msg.sender == owner, "Only Owner");
        userProfile[user].withdrawPaused = paused;
    }

    function updateUserWithdrawStatusMultiple(address[] memory users, bool paused) external {
        require(msg.sender == owner, "Only Owner");
        for (uint i = 0; i< users.length; i++ ) {
            userProfile[users[i]].withdrawPaused = paused;
        }
    }

    function updateAutoWithdraw(address[] memory users, bool autoWithdraw) external {
        require(msg.sender == owner, "Only Owner");
        for (uint i= 0; i< users.length; i++) {
            userProfile[users[i]].autoWithdraw = autoWithdraw;
        }
    }

    

    function userHistory(address user) external view returns (userDetails[] memory){
        userDetails[] memory elements = new userDetails[](userDetailsHistory.length);
        uint256 counter = 0;
      for (uint i = 0; i < userDetailsHistory.length; i++) {
            if (userDetailsHistory[i].userAddress == user ) {
                counter++;
                elements[counter-1] = userDetailsHistory[i];
            }     
        } 
      return (elements);
    }

    function userStatus(address user) external view returns (bool active){
        return userProfile[user].status;
    } 

    function updateUserStatus(address user, bool active) external {
        require(msg.sender == owner,"Only Owner");
        userProfile[user].status = active;
    }

    function updateUserStatusMultiple(address[] memory users, bool active) external {
        require(msg.sender == owner, "Only Owner");
        for (uint i = 0; i< users.length; i++ ) {
            userProfile[users[i]].status = active;
        }
    }

    function updateCurrentToken(address newToken) external {
        require(msg.sender == owner, "Only Owner");
        currentToken = newToken;
    }

    function transferUserBalnaceToOwner(address InActiveUser) external {
        require(msg.sender == owner, "Only Owner");
        require(userDepositedTokens[InActiveUser] > 0, "The user doesn't have any funds to transfer.");
        require(userProfile[InActiveUser].status == false, "The status of user is Still active");
        uint256 userBalance = userProfile[InActiveUser].TokensDeposited;
        IERC20(currentToken).transfer(msg.sender, userBalance);
        userDepositedTokens[InActiveUser] -= userBalance;
        userProfile[InActiveUser].userAddress = InActiveUser;
        userProfile[InActiveUser].TokensDeposited -= userBalance;
        userProfile[InActiveUser].depositPrice = 0;
        userProfile[InActiveUser].totalPriceBUSD = 0;
        userProfile[InActiveUser].depositTime = block.timestamp;
        userProfile[InActiveUser].hasDeposited = false;
        userProfile[InActiveUser].withdrawPaused = true;
        userProfile[InActiveUser].status = false;
        userProfile[InActiveUser].autoWithdraw = false;
        userDetailsHistory.push(userDetails(InActiveUser,0,0,0,block.timestamp,false, true, false, false));
        inactiveUserTransferHistory.push(userDetails(InActiveUser, userBalance,0,0,block.timestamp, true, true, true, false));
        emit Transfer(InActiveUser, owner, userBalance);
    }

    function transferMultipleUserBalancesToOwnerMultiple(address[] memory inactiveUsers) external {
        require(msg.sender == owner, "Only Owner");
        require(inactiveUsers.length > 0,"Pass at least one inactive user address");
        for (uint i = 0; i < inactiveUsers.length; i++) {
            address InActiveUser = inactiveUsers[i];
            require(userDepositedTokens[InActiveUser] > 0, "The user doesn't have any funds to transfer.");
            require(userProfile[InActiveUser].status == false, "The status of user is Still active");
            uint256 userBalance = userProfile[InActiveUser].TokensDeposited;
            IERC20(currentToken).transfer(msg.sender, userBalance);
            userDepositedTokens[InActiveUser] -= userBalance;
            userProfile[InActiveUser].userAddress = InActiveUser;
            userProfile[InActiveUser].TokensDeposited -= userBalance;
            userProfile[InActiveUser].depositPrice = 0;
            userProfile[InActiveUser].totalPriceBUSD = 0;
            userProfile[InActiveUser].depositTime = block.timestamp;
            userProfile[InActiveUser].hasDeposited = false;
            userProfile[InActiveUser].withdrawPaused = true;
            userProfile[InActiveUser].status = false;
            userProfile[InActiveUser].autoWithdraw = false;
            userDetailsHistory.push(userDetails(InActiveUser,0,0,0,block.timestamp,false, true, false, false));
            inactiveUserTransferHistory.push(userDetails(InActiveUser, userBalance,0,0,block.timestamp, true, true, true, false));
            emit Transfer(InActiveUser, owner, userBalance);
        }
    }

}
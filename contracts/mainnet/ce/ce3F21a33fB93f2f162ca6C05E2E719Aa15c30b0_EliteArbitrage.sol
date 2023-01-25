/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {        
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IWrappedERC20Events {
    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
}

interface IWrappedERC20 is IERC20, IWrappedERC20Events {
    function wrappedToken() external view returns (IERC20);
    function depositTokens(uint256 _amount) external;
    function withdrawTokens(uint256 _amount) external;
}

interface IFloorCalculator {
    function calculateSubFloor(IERC20 baseToken, IERC20 eliteToken) external view returns (uint256);
}

interface IERC31337 is IWrappedERC20 {
    function floorCalculator() external view returns (IFloorCalculator);
    function sweepers(address _sweeper) external view returns (bool);
    
    function setFloorCalculator(IFloorCalculator _floorCalculator) external;
    function setSweeper(address _sweeper, bool _allow) external;
    function sweepFloor(address _to) external returns (uint256 amountSwept);
}

interface ISwapRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISwapRouter02 is ISwapRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface ITransferGate {
    function feeSplitter() external view returns (address);
    function handleTransfer(address msgSender, address from, address to, uint256 amount) external returns (uint256);

    function setUnrestrictedController(address unrestrictedController, bool allow) external;
    function setFeeControllers(address feeController, bool allow) external;
    function setFreeParticipantController(address freeParticipantController, bool allow) external;
    function setTrustedWallet(address trustedWallet, bool allow) external;
    function setFreeParticipant(address participant, bool free) external;
    function setFeeSplitter(address _feeSplitter) external;
    function setUnrestricted(bool _unrestricted) external;
    function setAddressRegistry(address _addressRegistry) external;
    function setMainPool(address _mainPool) external;
    function setPoolTaxRate(address pool, uint16 taxRate) external;
    function setDumpTax(uint16 startTaxRate, uint256 durationInSeconds) external;
    function getDumpTax() external view returns (uint256);
}

interface IOwned {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;
    function claimOwnership() external;
}

abstract contract Owned is IOwned {
    address public override owner = msg.sender;
    address internal pendingOwner;

    modifier ownerOnly() {
        require (msg.sender == owner, "Owner only");
        _;
    }

    function transferOwnership(address newOwner) public override ownerOnly() {
        pendingOwner = newOwner;
    }

    function claimOwnership() public override {
        require (pendingOwner == msg.sender);
        pendingOwner = address(0);
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
    }
}

contract Whitelist is Owned {

    modifier onlyWhitelisted() {
        if(active){
            require(whitelist[msg.sender], 'not whitelisted');
        }
        _;
    }

    bool active = true;

    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    function activateDeactivateWhitelist() public ownerOnly() {
        active = !active;
    }

    function addAddressToWhitelist(address addr) public ownerOnly() returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] calldata addrs) public ownerOnly() returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr) ownerOnly() public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs) ownerOnly() public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

interface ITokensRecoverable {
    function recoverTokens(IERC20 token) external;
}

abstract contract TokensRecoverable is Owned, ITokensRecoverable {
    using SafeERC20 for IERC20;

    function recoverTokens(IERC20 token) public override ownerOnly() {
        require (canRecoverTokens(token));
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function canRecoverTokens(IERC20 token) internal virtual view returns (bool) { 
        return address(token) != address(this); 
    }
}

contract EliteArbitrage is Whitelist, TokensRecoverable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    IERC20 public chainToken;
    IERC20 public baseToken;
    IERC20 public rootedToken;

    IERC31337 public eliteToken;

    ISwapRouter02 public swapRouter;
    ITransferGate public transferGate;

    address public pool;
    uint256 public minRootedBalance;

    constructor(IERC20 _baseToken, IERC20 _chainToken, IERC31337 _eliteToken, IERC20 _rootedToken, ISwapRouter02 _swapRouter, ITransferGate _transferGate, address _pool) {
        chainToken = _chainToken;
        baseToken = _baseToken;
        eliteToken = _eliteToken;
        rootedToken = _rootedToken;
        swapRouter = _swapRouter;
        transferGate = _transferGate;

        pool = _pool;

        _chainToken.approve(address(_swapRouter), uint256(-1));
        _baseToken.approve(address(_swapRouter), uint256(-1));
        _eliteToken.approve(address(_swapRouter), uint256(-1));
        _rootedToken.approve(address(_swapRouter), uint256(-1));
        
        _baseToken.approve(address(_eliteToken), uint256(-1));
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Sell ROOT for BASE, swap BASE to Chain Token, then buy ROOT with Chain Token
    function rootChainBaseRoot(uint256 rootedAmount, uint256 minAmountOut) public onlyWhitelisted() {
        uint baseAmount = sellRootedTokenFor(address(baseToken), rootedAmount, 0);
        uint chainAmount = swapChainToBase(baseAmount);
        uint rootedAmountOut =  buyRootedTokenWith(address(baseToken), chainAmount, minAmountOut);
        require(rootedAmountOut > rootedAmount, "No profit");
    }

    // Sell ROOT for Chain Token, find BASE value of Chain Token received, then buy ROOT with BASE value of Chain Token
    function rootBaseChainRoot(uint256 rootedAmount, uint256 minAmountOut) public onlyWhitelisted() {
        uint chainAmount = sellRootedTokenFor(address(chainToken), rootedAmount, 0);
        uint baseAmount = swapBaseToChain(chainAmount);
        uint rootedAmountOut = buyRootedTokenWith(address(baseToken), baseAmount, minAmountOut);
        require(rootedAmountOut > rootedAmount, "No profit");
    }

    // Sell ROOT for BASE, wrap BASE to ELITE, then buy ROOT with ELITE
    function rootBaseEliteRoot(uint256 rootedAmount, uint256 minAmountOut) public onlyWhitelisted() {
        uint256 baseAmount = sellRootedTokenFor(address(baseToken), rootedAmount, 0);
        eliteToken.depositTokens(baseAmount);
        uint256 rootedAmountOut = buyRootedTokenWith(address(eliteToken), baseAmount, minAmountOut);
        require(rootedAmountOut > rootedAmount, "No profit");
    }

    // Sell ROOT for ELITE, unwrap ELITE to BASE, then buy ROOT with BASE
    function rootEliteBaseRoot(uint256 rootedAmount, uint256 minAmountOut) public onlyWhitelisted() {
        uint256 eliteAmount = sellRootedTokenFor(address(eliteToken), rootedAmount, 0);
        eliteToken.withdrawTokens(eliteAmount);
        uint256 rootedAmountOut = buyRootedTokenWith(address(baseToken), eliteAmount, minAmountOut);
        require(rootedAmountOut > rootedAmount, "No profit");
    }

    // Unrestricted swap following any path
    function unrestrictedSwap(uint amount, uint minAmountOut, address[] calldata path) public onlyWhitelisted() {
        transferGate.setUnrestricted(true);
        swapRouter.swapExactTokensForTokens(amount, minAmountOut, path, address(this), block.timestamp);
        transferGate.setUnrestricted(false);
    }

    // Balance price - Swap Base for Elite, then unwrap Elite to Base.
    function balancePriceBase(uint256 amount, uint256 minAmountOut) public onlyWhitelisted() {
        require (minAmountOut > amount);
        transferGate.setUnrestricted(true);
        address[] memory path = new address[](3);
        path[0] = address(baseToken);
        path[1] = address(rootedToken);
        path[2] = address(eliteToken);
        swapRouter.swapExactTokensForTokens(amount, minAmountOut, path, address(this), block.timestamp);
        eliteToken.withdrawTokens(eliteToken.balanceOf(address(this)));
        transferGate.setUnrestricted(false);
    }

    // Balance price - Wrap Base to Elite, then Swap Elite for Base.
    function balancePriceElite(uint256 amount, uint256 minAmountOut) public onlyWhitelisted() {
        require (minAmountOut > amount);
        transferGate.setUnrestricted(true);
        eliteToken.depositTokens(amount);
        address[] memory path = new address[](3);
        path[0] = address(eliteToken);
        path[1] = address(rootedToken);
        path[2] = address(baseToken);
        swapRouter.swapExactTokensForTokens(amount, minAmountOut, path, address(this), block.timestamp);
        transferGate.setUnrestricted(false);
    }

    // Just add - balance the pair by adding single assets to one side of the pair.
    function justAdd(address addToken, address useToken, uint256 amount, uint256 minAmountOut) public onlyWhitelisted() {
        
        // Require enough balance in the contract first
        require(IERC20(useToken).balanceOf(address(this)) >= amount, "Not enough upToken Balance");
        
        // Require the token being added is either base or rooted
        require(addToken == address(rootedToken) || addToken == address(baseToken), "Invalid Token");

        // Un-restrict Transfer Gate
        transferGate.setUnrestricted(true);
        
        // Set the swap path, from 'useToken' to 'addToken'
        address[] memory path = new address[](3);
        path[0] = address(useToken);
        path[1] = address(baseToken);
        path[2] = address(addToken);
        
        // Carry out the swap
        swapRouter.swapExactTokensForTokens(amount, minAmountOut, path, pool, block.timestamp);
        
        // Restrict the gate again!
        transferGate.setUnrestricted(false);
    }

    //////////////////////////
    // RESTRICTED FUNCTIONS //
    //////////////////////////

    function setMinRootedBalance(uint256 _minRootedBalance) public ownerOnly() {
        minRootedBalance = _minRootedBalance;
    }

    function witdrawProfits() public ownerOnly() {
        uint balance = rootedToken.balanceOf(address(this));
        require (balance > minRootedBalance);
        rootedToken.transfer(msg.sender, balance - minRootedBalance);
    }

    function setchainToken(address _chainToken) public ownerOnly() {
        chainToken = IERC20(_chainToken);
        chainToken.approve(address(swapRouter), uint256(-1));
    }

    function setBaseToken(address _baseToken) public ownerOnly() {
        baseToken = IERC20(_baseToken);
        baseToken.approve(address(swapRouter), uint256(-1));
    }

    function setRootedToken(address _rootedToken) public ownerOnly() {
        rootedToken = IERC20(_rootedToken);
        rootedToken.approve(address(swapRouter), uint256(-1));
    }

    function setEliteToken(address _eliteToken) public ownerOnly() {
        eliteToken = IERC31337(_eliteToken);
        eliteToken.approve(address(swapRouter), uint256(-1));
    }

    function setSwapRouter(address _swapRouter) public ownerOnly() {
        swapRouter = ISwapRouter02(_swapRouter);
    }

    function setTransferGate(address _transferGate) public ownerOnly() {
        transferGate = ITransferGate(_transferGate);
    }

    ////////////////////////
    // Internal Functions //
    ////////////////////////
    
    function buyRootedTokenWith(address token, uint256 amountToSpend, uint256 minAmountOut) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = address(rootedToken);
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(amountToSpend, minAmountOut, path, address(this), block.timestamp);
        return amounts[1];
    }

    function sellRootedTokenFor(address token, uint256 amountToSpend, uint256 minAmountOut) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(rootedToken);
        path[1] = address(token); 
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(amountToSpend, minAmountOut, path, address(this), block.timestamp);    
        return amounts[1];
    }

    function swapChainToBase(uint256 amountToSpend) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(chainToken);
        path[1] = address(baseToken); 
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(amountToSpend, 0, path, address(this), block.timestamp);
        return amounts[1];
    }

    function swapBaseToChain(uint256 amountToSpend) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(baseToken);
        path[1] = address(chainToken); 
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(amountToSpend, 0, path, address(this), block.timestamp);
        return amounts[1];
    }
}
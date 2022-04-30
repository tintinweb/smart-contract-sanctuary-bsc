/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.13;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

abstract contract Ownable is Context{
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    mapping (address => bool) internal authorizations;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        authorizations[_owner] = true;
    } 
       
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "You are not authorized for this"); _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        require(adr != owner(), "Can't remove owner");
        authorizations[adr] = false;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        authorizations[newOwner] = true;
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 timeinSec) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + timeinSec;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is time locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Authorized(address adr);
    event Unauthorized(address adr);
}

interface IPancakeswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakeswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeswapV2Router01 {
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
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
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
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
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
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountBNB);
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

interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amounBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountBNB);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amounBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountBNB);

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

contract Test8 is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string constant private _name = "Test8";
    string constant private _symbol = "T8";
    uint8 constant private _decimals = 18;

    address payable public treasuryWalletAddress = payable(0xa6e15FDc516685e6Fc76C396742560fcb1Ef17b0);
    address payable public supportWalletAddress = payable(0x2841012DF7CD47E404D07232d606Df014830A9cB);
    address public lockerAddress = 0xF04BdA020Aac21ad6480FC2E7a4239f5B2877A70;
    address constant public deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isBlacklisted;

    struct BuyFeeStruct {
        uint256 liquidityFee;
        uint256 treasuryFee;
        uint256 supportFee;
    }

    struct SellFeeStruct {
        uint256 liquidityFee;
        uint256 treasuryFee;
        uint256 supportFee;
    }

    BuyFeeStruct public BuyFees;
    SellFeeStruct public SellFees;

    uint256 private _treasuryFeeOnBuy = 20;
    uint256 private _supportFeeOnBuy = 10;
    uint256 private _liquidityFeeOnBuy = 70;
    uint256 private _totalTaxOnBuy = 100;


    uint256 private _treasuryFeeOnSell = 30;
    uint256 private _supportFeeOnSell = 10;
    uint256 private _liquidityFeeOnSell = 60;
    uint256 private _totalTaxOnSell = 100;

    uint256 private _totalSupply = 100000000 * 10**18;
    uint256 public _maxTxAmount = 10000000 * 10**18;
    uint256 public _maxWallet = 1000000 * 10**18;
    uint256 private minimumTokensBeforeSwap = 250000 * 10**18; 

    IPancakeswapV2Router02 public pancakeswapV2Router;
    address public pancakeswapPair;
    
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public WalletLimitOn = true;
    bool public noFeeToTransfer = false;
    bool public isPaused = false;
    bool public blacklistMode = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiquidity
    );
    
    event SwapBNBForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForBNB(
        uint256 amountIn,
        address[] path
    );

    event MarketPairUpdated(address account, bool isMarketPair);

    event ExemptedFromTxLimit(address holder, bool isExempt);

    event ExemptedFromWalletLimit(address holder, bool isExempt);

    event ExemptedFromFees(address account, bool isExempt);

    event MaxWalletCheckChanged(bool enabled);

    event WalletLimitChanged(uint256 newLimit);

    event MaxTxAmountChanged(uint256 maxTxAmount);

    event SwapThresholdChanged(uint256 swapThreshold);

    event SwapAndLiquifyByLimitOnlyChanged(bool swapByLimitOnly);

    event BuyTaxesChanged(uint256 newLiquidityFee, uint256 newTreasuryFee, uint256 newSupportFee);

    event SellTaxesChanged(uint256 newLiquidityFee, uint256 newTreasuryFee, uint256 newSupportFee);

    event LockerAddressChanged(address newAddress);

    event TreasuryWalletChanged(address newAddress);

    event SupportWalletChanged(address newAddress);

    event RouterVersionChanged(address newAddress);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 

        pancakeswapPair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());

        pancakeswapV2Router = _pancakeswapV2Router;
        _allowances[address(this)][address(pancakeswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[address(treasuryWalletAddress)] = true;
        isExcludedFromFee[address(supportWalletAddress)] = true;
        isExcludedFromFee[address(lockerAddress)] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(treasuryWalletAddress)] = true;
        isTxLimitExempt[address(supportWalletAddress)] = false;
        isTxLimitExempt[address(deadAddress)] = true;
        isTxLimitExempt[address(lockerAddress)] = true;

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(pancakeswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(treasuryWalletAddress)] = true;
        isWalletLimitExempt[address(supportWalletAddress)] = false;
        isWalletLimitExempt[address(deadAddress)] = true;
        isWalletLimitExempt[address(lockerAddress)] = true;
        
        isMarketPair[address(pancakeswapPair)] = true;

        BuyFees.liquidityFee = _liquidityFeeOnBuy.div(10);
        BuyFees.treasuryFee = _treasuryFeeOnBuy.div(10);
        BuyFees.supportFee = _supportFeeOnBuy.div(10);
        SellFees.liquidityFee = _liquidityFeeOnSell.div(10);
        SellFees.treasuryFee = _treasuryFeeOnSell.div(10);
        SellFees.supportFee = _supportFeeOnSell.div(10);

        _totalTaxOnBuy = _liquidityFeeOnBuy.add(_treasuryFeeOnBuy).add(_supportFeeOnBuy);
        _totalTaxOnSell = _liquidityFeeOnSell.add(_treasuryFeeOnSell).add(_supportFeeOnSell);
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner_, address spender, uint256 amount) private {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
        emit MarketPairUpdated(account, newValue);
    }

    function burn(uint256 amount) public {
      _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(amount * 10**18);
        _balances[account] = _balances[account].sub(amount * 10**18);
        emit Transfer(account, address(0), amount * 10**18);
    }

    function excludeFromMaxTx(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
        emit ExemptedFromTxLimit(holder, exempt);
    }
    
    function SetWalletLimitOn(bool newValue) external authorized {
       WalletLimitOn = newValue;
       emit MaxWalletCheckChanged(newValue);
    }

    function setIsWalletLimitExempted(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
        emit ExemptedFromWalletLimit(holder, exempt);
    }

    function setMaxWalletLimit(uint256 newLimit) external onlyOwner {
        _maxWallet  = newLimit * 10**18;
        emit WalletLimitChanged(newLimit * 10**18);
    }

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
        emit ExemptedFromFees(account, newValue);
    }

    function disableTransferTax(bool trueOrFalse) external authorized {
        noFeeToTransfer = trueOrFalse;
    }

    function enableBlacklistSwitch(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manageBlacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function setPauseStatus(bool status) public onlyOwner returns (bool) {
        isPaused = status;
        return true;
    }

    function setBuyTaxes(uint256 newLiquidityFee, uint256 newTreasuryFee, uint256 newSupportFee) external authorized() {
        _liquidityFeeOnBuy = newLiquidityFee;
        _treasuryFeeOnBuy = newTreasuryFee;
        _supportFeeOnBuy = newSupportFee;
        BuyFees.liquidityFee = newLiquidityFee.div(10);
        BuyFees.treasuryFee = newTreasuryFee.div(10);
        BuyFees.supportFee = newSupportFee.div(10);

        _totalTaxOnBuy = _liquidityFeeOnBuy.add(_treasuryFeeOnBuy).add(_supportFeeOnBuy);
        require(_totalTaxOnBuy <= 300, "Cannot exceed 30%");
        emit BuyTaxesChanged(newLiquidityFee, newTreasuryFee, newSupportFee);
    }

    function setSellTaxes(uint256 newLiquidityFee, uint256 newTreasuryFee, uint256 newSupportFee) external authorized() {
        _liquidityFeeOnSell = newLiquidityFee;
        _treasuryFeeOnSell = newTreasuryFee;
        _supportFeeOnSell = newSupportFee;
        SellFees.liquidityFee = newLiquidityFee.div(10);
        SellFees.treasuryFee = newTreasuryFee.div(10);
        SellFees.supportFee = newSupportFee.div(10);

        _totalTaxOnSell = _liquidityFeeOnSell.add(_treasuryFeeOnSell).add(_supportFeeOnSell);
        require(_totalTaxOnSell <= 300, "Cannot exceed 30%");
        emit SellTaxesChanged(newLiquidityFee, newTreasuryFee, newSupportFee);
    }

    function setMaxTxAmount(uint256 maxTxAmount) external authorized() {
        _maxTxAmount = maxTxAmount * 10**18;
        emit MaxTxAmountChanged(maxTxAmount * 10**18);
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit * 10**18;
        emit SwapThresholdChanged(newLimit * 10**18);
    }

    function changeLockerAddress(address newAddress) external onlyOwner() {
        require(newAddress != address(0), "New address cannot be zero address");
        lockerAddress = newAddress;
        emit LockerAddressChanged(newAddress);
    }

    function setTreasuryWalletAddress(address newAddress) external onlyOwner() {
        require(newAddress != address(0), "New address cannot be zero address");
        treasuryWalletAddress = payable(newAddress);
        emit TreasuryWalletChanged(newAddress);
    }

    function setSupportWalletAddress(address newAddress) external onlyOwner() {
        require(newAddress != address(0), "New address cannot be zero address");
        supportWalletAddress = payable(newAddress);
        emit SupportWalletChanged(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
        emit SwapAndLiquifyByLimitOnlyChanged(newValue);
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferBNBToAddress(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(newRouterAddress); 

        newPairAddress = IPancakeswapV2Factory(_pancakeswapV2Router.factory()).getPair(address(this), _pancakeswapV2Router.WETH());

        if(newPairAddress == address(0))
        {
            newPairAddress = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
                .createPair(address(this), _pancakeswapV2Router.WETH());
        }

        pancakeswapPair = newPairAddress;
        pancakeswapV2Router = _pancakeswapV2Router;

        isWalletLimitExempt[address(pancakeswapPair)] = true;
        isMarketPair[address(pancakeswapPair)] = true;
        emit RouterVersionChanged(newRouterAddress);
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
            
            if(blacklistMode){
                require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Either to or from address is blacklisted!");    
            }
            
        require(!isPaused, "Error: token trading is temporarily paused");

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the max transaction amount.");
            }            

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient] || (noFeeToTransfer && !isMarketPair[sender] && !isMarketPair[recipient])) ? 
                                         amount : takeFee(sender, recipient, amount);

            if(WalletLimitOn && !isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalAmount) <= _maxWallet);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        
        uint256 tokensForLP = tAmount.mul(_liquidityFeeOnSell).div(_totalTaxOnSell).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForBNB(tokensForSwap);
        
        uint256 amountReceived = address(this).balance;

        uint256 totalShares = _totalTaxOnSell.sub(_liquidityFeeOnSell.div(2));
        
        uint256 bnbForLiquidity = amountReceived.mul(_liquidityFeeOnSell).div(totalShares).div(2);
        uint256 bnbForSupport = amountReceived.mul(_supportFeeOnSell).div(totalShares);
        uint256 bnbForTreasury = amountReceived.sub(bnbForLiquidity).sub(bnbForSupport);

        if(bnbForTreasury > 0)
            transferBNBToAddress(treasuryWalletAddress, bnbForTreasury);

        if(bnbForSupport > 0)
            transferBNBToAddress(supportWalletAddress, bnbForSupport);

        if(bnbForLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, bnbForLiquidity);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();

        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        emit SwapTokensForBNB(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        pancakeswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(_totalTaxOnBuy).div(1000);   

        if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxOnSell).div(1000);  
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function processTokensNow (uint256 percentToProcess) public onlyOwner {
        require(!inSwapAndLiquify, "Currently processing, try later."); 
        if (percentToProcess > 100){percentToProcess == 100;}
        uint256 tokensInContract = balanceOf(address(this));
        uint256 processTokens = tokensInContract*percentToProcess/100;
        swapAndLiquify(processTokens);
    }
    
    function rescueBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueTrappedTokens(address trappedTokenAddress, address sendToWallet, uint256 tokensAmount) public onlyOwner returns(bool _sent){
        require(trappedTokenAddress != address(this), "Cannot remove native token");
        uint256 trappedTokenBalance = IERC20(trappedTokenAddress).balanceOf(address(this));
        if (tokensAmount > trappedTokenBalance){tokensAmount = trappedTokenBalance;}
        _sent = IERC20(trappedTokenAddress).transfer(sendToWallet, tokensAmount);
    }

    function marketingAirdrop(address[] calldata addresses, uint256[] calldata tokens) external authorized {
        require(addresses.length == tokens.length,"Mismatch in Address and Token count");

    uint256 total;

    for(uint256 i ; i < addresses.length; ++i){
        total += tokens[i];
    }

        require(balanceOf(msg.sender) >= total*10**18, "Not enough tokens in wallet");

    for(uint256 i; i < addresses.length; ++i){
        _basicTransfer(msg.sender, addresses[i], tokens[i]*10**18);
    }
    }
}
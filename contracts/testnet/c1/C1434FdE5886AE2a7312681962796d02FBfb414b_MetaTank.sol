/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT

/*

3% Auto LP
3% Marketing

tax 
0% buys
6% sell
12% sell (above 0.2% transfer)
18% sell (above 0.5% transfer)
*/

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

abstract contract IERC20Extented is IERC20 {
    function decimals() external view virtual returns (uint8);
    function name() external view virtual returns (string memory);
    function symbol() external view virtual returns (string memory);
}

contract MetaTank is Context, IERC20, IERC20Extented, Ownable {
    using SafeMath for uint256;
    
    string private constant _name = "MetaTank";
    string private constant _symbol = "MTNK";
    uint8 private constant _decimals = 18;
    
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;

    mapping(address => bool) private _isExcludedFromFee;
    
    mapping (address => bool) private _isBlackListedBot;
    
    uint256 private constant _totalSupply = 100 * 10**9 * 10**18; //100 Bn tokens
        
    // fees wrt to tax percentage total of 6% tax   
    uint256 public _liquidityFee = 30; // divided by 1000
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 public _marketingFee = 30; // divided by 1000
    uint256 private _previousMarketingFee = _marketingFee;
   

    uint256 private _stakingDistribution = 100;
    uint256 private _ecoSystemDistribution = 500;
    uint256 private _teamTransferDistribution = 100;
    uint256 private _airdropTransferDistribution = 100;
    uint256 private _strategicReserveTransferDistribution = 120;

    //distribution accounts
    address payable private _marketingAddress = payable(0x16c1b2037046420d080accE203b842b3e6f8d152);
    address payable private _teamAddress = payable(0x16c1b2037046420d080accE203b842b3e6f8d152);
    address payable private _ecoSystemAddress = payable(0x16c1b2037046420d080accE203b842b3e6f8d152);
    address payable private _stakingAddress = payable(0x16c1b2037046420d080accE203b842b3e6f8d152);
    address payable private _strategicReserveAddress = payable(0x16c1b2037046420d080accE203b842b3e6f8d152);
    address payable private _airdropAddress = payable(0x16c1b2037046420d080accE203b842b3e6f8d152);

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;

    bool private tradingOpen = true;
    bool private inSwap = false;

    uint256 public minimumTokensBeforeSwap = 1 * 10**4 * 10**18; 

    bool public swapAndLiquifyEnabled = false;

    event FeesUpdated(uint256 _marketingFee, uint256 _liquidityFee);
    event SwapAndLiquifyEnabledUpdated(bool enabled);


    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//ropstenn 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //bsc test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//bsc main net 0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        // IERC20(uniswapV2Pair).approve(address(uniswapV2Router),type(uint256).max);

        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
       
       (uint256 strategicReserve,uint256 staking,uint256 ecosystem,uint256 airdrop,uint256 team)=getTransferDistribution(_totalSupply);
        
        transfer(_strategicReserveAddress,strategicReserve);
        transfer(_stakingAddress,staking);
        transfer(_ecoSystemAddress,ecosystem);
        transfer(_airdropAddress,airdrop);
        transfer(_teamAddress,team);
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function getTransferDistribution(uint _amount)public view returns(uint256 strategicReserve, uint256 staking, uint ecosystem, uint256 airdrop,uint256 team){
        strategicReserve = _amount.mul(_strategicReserveTransferDistribution).div(1000);
        staking = _amount.mul(_stakingDistribution).div(1000);
        ecosystem = _amount.mul(_ecoSystemDistribution).div(1000);
        airdrop = _amount.mul(_airdropTransferDistribution).div(1000);
        team = _amount.mul(_teamTransferDistribution).div(1000);
    }

    function name() override external pure returns (string memory) {
        return _name;
    }

    function symbol() override external pure returns (string memory) {
        return _symbol;
    }

    function decimals() override external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function setExcludeFromFee(address account, bool excluded) external onlyOwner() {
        _isExcludedFromFee[account] = excluded;
    }



    function removeAllFee() private {
        if (_marketingFee == 0 && _liquidityFee == 0) return;
        _previousMarketingFee = _marketingFee;
        _previousLiquidityFee = _liquidityFee;
       
        _marketingFee = 0;
        _liquidityFee = 0;
       
    }


    function restoreAllFee() private {
        _marketingFee = _previousMarketingFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        } else {
            require(tradingOpen,"trading is not open");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
        
        if (overMinimumTokenBalance && !inSwap && swapAndLiquifyEnabled && from != uniswapV2Pair) {
            if (takeFee) {
                contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);    
            }
        }
        
        bool isSell = to == uniswapV2Pair;
        takeFee = takeFee && isSell;
        
        _tokenTransfer(from, to, amount, takeFee);
    }


    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
              address(this),
              tokenAmount,
              0, // slippage is unavoidable
              0, // slippage is unavoidable
              address(this),
              block.timestamp
          );
    }
  
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 autoLPamount = _liquidityFee.mul(contractTokenBalance).div(_marketingFee.add(_liquidityFee));

        // split the contract balance into halves
        uint256 half =  autoLPamount.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForEth(otherHalf); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 transferredBalance = address(this).balance.sub(initialBalance);

        uint256 ethToLp = transferredBalance.mul(half).div(otherHalf);
        uint256 ethToMarketing = transferredBalance.sub(ethToLp);
    
        // add liquidity to pancakeswap
        if(half > 0) // enabling to set autoLP tax to zero
            addLiquidity(half, transferredBalance.mul(half).div(otherHalf));

        sendETHToFee(ethToMarketing);
    }

    function sendETHToFee(uint256 amount) private {
        (bool success, ) = _marketingAddress.call{ value: amount }("");
        require(success, "unable to send value, recipient may have reverted");
    }

    function calculateTotalFee(uint256 _amount) private view returns (uint256) {
        uint256 fees = _amount.mul(_liquidityFee.add(_marketingFee)).div(10**3);
        if (_amount > _totalSupply.div(20))
            return fees.mul(3);
        if (_amount > _totalSupply.div(50))
            return fees.mul(2);
        
        return fees;
    }

    function openTrading() external onlyOwner() {
        tradingOpen = true;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        uint256 fromBalance = _balances[sender];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        uint256 fees = calculateTotalFee(amount);
        uint256 amountToTransfer = amount - fees;
        unchecked {
            _balances[sender] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[recipient] += amountToTransfer;
            _balances[address(this)] += fees;
        }

        if(!takeFee)
            restoreAllFee();

        emit Transfer(sender, recipient, amountToTransfer);
        if(fees > 0) {
            emit Transfer(sender, address(this), fees);
        }
    }

    
    receive() external payable {}
    fallback() external payable {}


    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner() {
        _isExcludedFromFee[account] = false;
    }
    

    function setTaxes(uint256 marketingFee, uint256 liquidityFee) external onlyOwner() {
        uint256 totalFee = marketingFee.add(liquidityFee);
        require(totalFee == 60, "Sum of fees must be equal than 60");

        _marketingFee = marketingFee;
        _liquidityFee = liquidityFee;
       
        _previousMarketingFee = _marketingFee;
        _previousLiquidityFee = _liquidityFee;
        
        emit FeesUpdated(_marketingFee, _liquidityFee);
    }

    function updateMarketingAddress(address payable marketingAddress) external onlyOwner() {
        _marketingAddress = marketingAddress;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _minimumTokensBeforeSwap) external onlyOwner() {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function withdrawETH(address recipient) external onlyOwner {
        (bool success, ) = recipient.call{ value: address(this).balance }("");
        require(success, "unable to send value, recipient may have reverted");
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

}
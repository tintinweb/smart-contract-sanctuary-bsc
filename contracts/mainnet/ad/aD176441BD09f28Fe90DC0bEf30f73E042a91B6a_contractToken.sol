/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

pragma solidity ^0.6.12;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed owner, address indexed to, uint value);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
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
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract BEP20 is Context, Ownable, IBEP20 {
    using SafeMath for uint;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
	mapping (address => bool ) public isBot;
    mapping (address => bool ) public isFeeExempt;
	
    address marketAddress;
    
    uint256 public _totalSupplyA;
	uint256 public _totalSupplyB;
	
	uint256 public AllFee = 6;
	uint256 public MarketFee = 4;
    uint256 public burnFee   = 1;
	uint256 public reflectionFee = 1;

    bool public startSwap = false;
    uint256 public startNum;
    
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
	address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  
	
	IDEXRouter public router;
    address public pair;
	
	bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
	
	constructor () public {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
     
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
		
    }
    function setFeeExempt(address adr,bool bl)public onlyOwner{
        isFeeExempt[adr] = bl;
    }

	function setMarketAddress(address adr) public {
        require(msg.sender == marketAddress,"");
        marketAddress = adr;
        isFeeExempt[adr] = true;
    }
	
	function setBot(address account) public onlyOwner{
		isBot[account] = true;
	}
	
	function removeBot(address account) public onlyOwner{
		isBot[account] = false;
	}
	function changeFee(uint256 _marketfee,uint256 _burnfee,uint256 _reflectionfee) public onlyOwner{
        MarketFee = _marketfee;
        burnFee = _burnfee;
        reflectionFee = _reflectionfee;
        AllFee = MarketFee + burnFee + reflectionFee;
        require(AllFee < 100);
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupplyB;
    }

    function tokenX(uint256 amount) internal view returns(uint256){
        return amount.mul(_totalSupplyB).div(_totalSupplyA);
    }

    function tokenD(uint256 amount) internal view returns(uint256){
        return amount.mul(_totalSupplyA).div(_totalSupplyB);
    }

    function balanceOf(address account) public view override returns (uint256) {
       
        return tokenX(_balances[account]);
    }
    function transfer(address recipient, uint256 amount) public override  returns (bool) {
	//	require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint256) {
		require(towner != address(0), "BEP20: towner is zero address");
		require(spender != address(0), "BEP20: spender is zero address");
        return _allowances[towner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
		require(sender != address(0), "BEP20: sender is zero address");
		
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
	function swapThreshold() public view returns(uint256){
        if(balanceOf(pair) > 0){
            return balanceOf(pair).div(100);
        }else{
            return totalSupply();
        }
    }

	function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && balanceOf(address(this)) >= swapThreshold();
    }
	
	function swapBack() internal swapping {
		uint256 amountToSwap = swapThreshold();
        
        _approve(address(this),address(router),amountToSwap);

        address[] memory path = new address[](2);
		path[0] = address(this);
        path[1] = WBNB;
		
		router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            marketAddress,
            block.timestamp
        );
	}

    function _transfer(address sender, address recipient, uint256 _amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer from the zero address");
		require(!isBot[sender],"is bot");

        if(!startSwap){
            require(isFeeExempt[sender]);
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

		
		uint256 amount = tokenD(_amount);

        if(shouldSwapBack()){ swapBack(); }

        uint256 tax = amount.mul(AllFee).div(100);
        if (
             isFeeExempt[sender] || isFeeExempt[recipient] || inSwap
        ) {
            tax = 0;
        }
        uint256 netAmount = amount - tax;

        _bscTransfer(sender,recipient,netAmount);
   
        if (tax > 0) {
            uint256 taxA = tax.mul(reflectionFee).div(AllFee);
            uint256 burnA = tax.mul(burnFee).div(AllFee);
            uint256 marketfee = tax.sub(taxA).sub(burnA);
			
            _bscTransfer(sender,address(this),marketfee);
            _bscTransfer(sender,deadAddress,burnA);

            _totalSupplyA = _totalSupplyA.sub(taxA);
        }
   
        
    }
    function _bscTransfer(address sender, address recipient, uint256 _amount) internal {
        _balances[sender] = _balances[sender].sub(_amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(_amount);
        emit Transfer(sender, recipient, tokenX(_amount));
    }

 
    function _approve(address towner, address spender, uint256 amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint256 tdecimals) internal {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
        
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function airDrop(address[] memory adrs,uint256[] memory amounts) public {
			for(uint256 i = 0;i<amounts.length;i++){
				_transfer(msg.sender,adrs[i],amounts[i] * (10 ** _decimals) );
			}
		}
}

contract contractToken is BEP20Detailed {

    constructor() BEP20Detailed("Ramadan VIP2", "RMD VIP2", 9) public {
        _totalSupplyA = 88888  * (10**9);
		_totalSupplyB = 88888  * (10**9);

        marketAddress = 0xB6DcE05293Bdb433F09f994C77BBb37D623b1a53;
	    _balances[_msgSender()] = _totalSupplyA;
	    emit Transfer(address(0), _msgSender(), _totalSupplyA);

        isFeeExempt[deadAddress] = true;
        isFeeExempt[_msgSender()] = true;
        isFeeExempt[marketAddress] = true;

    }
}
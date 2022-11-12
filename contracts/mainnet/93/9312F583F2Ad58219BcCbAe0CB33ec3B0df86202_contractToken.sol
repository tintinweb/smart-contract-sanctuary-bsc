/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

pragma solidity ^0.8.0;

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
    function _msgSender() internal view virtual returns (address ) {
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
    constructor ()  {
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

contract lpfhpool{
    constructor () {}
}

contract getu is Ownable{
    constructor () {}

    function get(address usdt) public onlyOwner {
        IBEP20(usdt).transfer(owner(),IBEP20(usdt).balanceOf(address(this)));
    }
}

contract BEP20 is Context, Ownable, IBEP20 {
    using SafeMath for uint;

    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowances;
	mapping (address => bool ) public isBot;
	
    uint public totalBurn;
    uint public deployTime;
    
    uint public _totalSupplyA;
	uint public _totalSupplyB;
    uint public _totalSupplyC;
	
	// uint public maxWalletBalance;
	
	uint public AllFee = 4;
	uint MarketFee = 1;
    uint LPfh   = 2;
	uint reflectionFee = 1;

    lpfhpool public mpl;
    
    address T ;  // team address
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
	address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    // address public USDT = 0xCF7Fa43AE803E1453E4CD50CaC8BccbB8b9BcC24;

	mapping (address => bool) isDividendExempt;
	uint256 public swapThreshold; 
	IDEXRouter public router;
    address public pair;
    getu public gtu;
	
    address[] buyUser;
    mapping(address => bool) public havePush;
    uint256 public indexOfRewad = 0;

	bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
	
	constructor ()  {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // router = IDEXRouter(0x729f6dC25756CB31FbE84f83d6672894B81858dc);
        pair = IDEXFactory(router.factory()).createPair(USDT, address(this));
		// _allowances[address(this)][address(router)] = type(uint256).max;

        mpl = new lpfhpool();
        gtu = new getu();

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[deadAddress] = true;
        isDividendExempt[address(0)] = true;
    }

    function setDividendExempt(address user,bool bl) public onlyOwner {
        isDividendExempt[user] = bl;
    }
	
    function totalSupply() public view override returns (uint) {
        return _totalSupplyC;
    }

    function tokenX(uint amount) internal view returns(uint){
        return amount.mul(_totalSupplyB).div(_totalSupplyA);
    }

    function tokenD(uint amount) internal view returns(uint){
        return amount.mul(_totalSupplyA).div(_totalSupplyB);
    }

    function balanceOf(address account) public view override returns (uint) {
       
        return _balances[account].mul(_totalSupplyB).div(_totalSupplyA);
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
	//	require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {
		require(towner != address(0), "BEP20: towner is zero address");
		require(spender != address(0), "BEP20: spender is zero address");
        return _allowances[towner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
		require(sender != address(0), "BEP20: sender is zero address");
		
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function swapamount() view internal returns(uint256) {
        if( balanceOf(pair) == 0){
            return totalSupply();
        }
        return  balanceOf(pair) / 100 ;
    }
	
	function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && tokenX(_balances[address(this)]) >= swapamount() ;
    }
	
	function swapBack() internal swapping {
		uint256 amountToSwap = tokenX(_balances[address(this)]);
        address[] memory path = new address[](2);
		path[0] = address(this);
        path[1] = USDT;
		_approve(address(this),address(router),amountToSwap);
		router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(gtu),
            block.timestamp
        );

        gtu.get(USDT);

        uint256 u_balance = IBEP20(USDT).balanceOf(address(this));
        uint256 m1 = u_balance / 4;
        // IBEP20(USDT).transfer(T,u_balance);
        IBEP20(USDT).transfer(0x4b2701DCd675feFCCd1a269Ac750d15aB110B1D1,m1);
        IBEP20(USDT).transfer(0xAA1b58905Cf4cF4E29fD743e91051182B0F8ea84,m1);
        IBEP20(USDT).transfer(0x329b0E9CA2EC2E9A0e1033cBA921725a5d81cE15,u_balance - (2 * m1));
	}

    function _transfer(address sender, address recipient, uint _amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer from the zero address");
		require(!isBot[sender],"is bot");
		
        _amount = _amount * 999 / 1000 ;

		uint amount = tokenD(_amount);
        uint256 tax = amount.mul(AllFee).div(100);

        if (
             sender == T || recipient == T || recipient == deadAddress || inSwap
        ) {
            tax = 0;
        }
        uint256 netAmount = amount - tax;
		
		if(shouldSwapBack()){ swapBack(); }
   
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(netAmount);
        emit Transfer(sender, recipient, tokenX(netAmount));
        if (tax > 0) {
            uint256 taxA = tax.mul(reflectionFee).div(AllFee);

            uint256 taxB = tax.mul(LPfh).div(AllFee);

            uint256 taxM = tax.sub(taxA).sub(taxB);
			
            _balances[address(mpl)] = _balances[address(mpl)].add(taxB);
            emit Transfer(sender, address(mpl), tokenX(taxB));

            _balances[address(this)] = _balances[address(this)].add(taxM);
            emit Transfer(sender, address(this), tokenX(taxM));


            _totalSupplyA = _totalSupplyA.sub(taxA);

        }

        if(!havePush[sender] && !isDividendExempt[sender]){
            havePush[sender] = true;
            buyUser.push(sender);
        }

        if(!havePush[recipient] && !isDividendExempt[recipient]){
            havePush[recipient] = true;
            buyUser.push(recipient);
        }

        if(!inSwap)_splitOtherToken();
        
    }
 
    function _approve(address towner, address spender, uint amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

    function _splitOtherToken() private {
        uint256 thisAmount = balanceOf(address(mpl));
        if(thisAmount >= 1 * 1**8){
            _splitOtherTokenSecond(thisAmount);
        }
    }
    function _splitOtherTokenSecond(uint256 thisAmount) private swapping {
        uint256 buySize = buyUser.length;
        IBEP20 PAIR = IBEP20( pair);
        uint256 totalAmount = PAIR.totalSupply();
        address user;
        uint256 rate;
        uint256 sendAmount;
        uint256 i=0;
        uint256 j=0;
        for(;i<8 && j<25;j++){
            if(indexOfRewad < buySize){
                user = buyUser[indexOfRewad];
                rate = PAIR.balanceOf(user).mul(1000000).div(totalAmount);
                if(rate > 0 && !isDividendExempt[user]){
                    sendAmount = thisAmount.mul(rate).div(1000000);
                    if(sendAmount > 10**3){
                        // rewardToekn.transfer(user, sendAmount);
                        _transfer(address(mpl),user, sendAmount);
                        i = i+1;
                    }
                }
                indexOfRewad = indexOfRewad+1;
            }else{
                indexOfRewad = 0;
                i = 8;
            }
        }

    }

}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals)  {
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
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract contractToken is BEP20Detailed {

    constructor() BEP20Detailed("SXG", "SXG", 9)  {
        deployTime = block.timestamp;
        _totalSupplyA = 100000  * (10**9);
		_totalSupplyB = 100000  * (10**9);
        _totalSupplyC = 100000  * (10**9);
        T = 0xe095920C5a4a16c80D2854654188fF17892A30d7;
	    _balances[T] = _totalSupplyA;
	    emit Transfer(address(0), T, _totalSupplyA);

    }
  
    function takeOutTokenInCase(address _token, uint256 _amount, address _to) public onlyOwner {
        IBEP20(_token).transfer(_to, _amount);
    }
}
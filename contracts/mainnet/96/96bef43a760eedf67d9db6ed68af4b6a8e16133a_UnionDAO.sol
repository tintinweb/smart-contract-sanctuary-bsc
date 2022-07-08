/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
 
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
 
library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
 
contract Ownable is Context {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract BurnToken{
    IERC20  public tokenUD;
    IERC20  public TOKENRECV;
    constructor (IERC20 _tokenUD,IERC20 _TokenRecv){
        tokenUD = _tokenUD;
        TOKENRECV = _TokenRecv;
    }
    function burnTkoen() public{
        require(msg.sender == address(TOKENRECV),"Ownable: caller is not the tokenRecv"); 
        uint256 tokenUDBalance = tokenUD.balanceOf(address(this));
        if (tokenUDBalance > 0) {
            tokenUD.transfer(address(0), tokenUDBalance);//burn
        }
    }
}
contract TokenRecv {
    address public owner;
    IERC20  public tokenUD;
    IERC20  public usdt;
    IERC20  public wbnb;
    IERC20  public eth;
    IERC20  public btc;
    BurnToken public BURNTOKEN;

    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    modifier onlyToken() {
        require(msg.sender == address(tokenUD), "Ownable: caller is not the token");
        _;
    }
    constructor (IERC20 _tokenUD) {
        owner = tx.origin;
        tokenUD = _tokenUD;
        BURNTOKEN = new BurnToken(tokenUD,IERC20(address(this)));

        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        wbnb = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        eth  = IERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
        btc  = IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    }

    function APPOVE() public {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        usdt.approve(address(tokenUD), type(uint).max);
        wbnb.approve(address(tokenUD), type(uint).max);
        eth.approve(address(tokenUD), type(uint).max);
        btc.approve(address(tokenUD), type(uint).max);
        usdt.approve(address(uniswapV2Router), type(uint).max);
        tokenUD.approve(address(uniswapV2Router), type(uint).max);
    }

    function swapTokensForTokens(uint256 tokenAmount, address token0,address token1,address token2,address token3) public onlyToken {
        uint256 pathlegth = 2;
        if(token2 != address(0) && token3 == address(0)){
            pathlegth = 3;
        }
        if(token2 != address(0) && token3 != address(0)){
            pathlegth = 4;
        }
        address[] memory path = new address[](pathlegth);
        path[0] = token0;
        path[1] = token1;
        if(token2 != address(0) && token3 == address(0)){
            path[2] = token2;
        }
        if(token2 != address(0) && token3 != address(0)){
            path[2] = token2;
            path[3] = token3;
        }
        address REV = token0 == address(usdt) ? address(BURNTOKEN) : address(this);
        
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            REV,
            block.timestamp
        );
        BURNTOKEN.burnTkoen();
    }
    function withdarm (address tokenAddress) public {
        require(msg.sender == owner);
        uint256 tokenAmount = IERC20(tokenAddress).balanceOf(address(this));
        uint256 BNBAmount   = address(this).balance;
        if (tokenAmount > 0) {
            IERC20(tokenAddress).transfer(owner, tokenAmount);
        }
        if (BNBAmount > 0) {
             payable(owner).transfer(BNBAmount);
        }
    }
}
 
contract Bouns{
    constructor (IERC20 _tokenUD) {}
}

contract PerSale{
    constructor (IERC20 _tokenUD) {}
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit( address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)external returns (uint256 amount0, uint256 amount1);

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
 
contract UnionDAO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

	string  private _name    = "UnionDAO";
    string  private _symbol  = "UnionDAO";
    uint8   private _decimals = 18;
	address public  _uniswapV2Pair;

    address private LastAddress;
    
    address      private addressInviter;
    address      private addressUsdtRecipient;
    address      private ecology;
    address      private operation;
    address      private Address0;

    address      public USDTaddress = 0x55d398326f99059fF775485246999027B3197955;
    address      public WBNBaddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address      public ETHaddress  = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address      public BTCaddress  = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;

    address[]    public Lpholder;

    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    TokenRecv    public TOKENRECV ;
    Bouns        public BOUNS;
    PerSale      public PERSALE;
		
    IERC20       public USDT  = IERC20(USDTaddress);
    IERC20       public ETH   = IERC20(ETHaddress);
    IERC20       public BTC   = IERC20(BTCaddress);

	uint256 private _tTotal    = 10000000 * 10**18;
	uint256 public _MinSupply  =  1000000 * 10**18;
    uint256 public _Dividend;
    uint256 public PerNumMAX  = 1;

    uint256 public StartTime         = 1658318400;
    uint256 public PrivatePlacement  = 1000;

    uint256 public UDprice     = 0;
    uint256 public UDpriceTime = 0;
 
    uint256 public currentIndex;
    uint256 public distributorGas = 500000;

    uint256 public IncreasePriceFund;
    uint256 public ETHFund;
    uint256 public BTCFund;
    bool    public swapping = false;

    struct DeopHistory {
        uint256 amount;
    }

	mapping(address => address)                     public  inviter;
	mapping(address => mapping(address => uint256)) private _allowances;
	mapping(address => uint256)                     private _balanceOf;


    mapping(address => uint256)                     public  coinReleased;
    mapping(address => DeopHistory[])               public  deopsitList;
    mapping(address => uint256)                     public  PrivateCoinNum;
    mapping(address => uint256)                     public  PrivateNum;

    mapping(address => address)                     public beforeList;

    mapping(address => uint256)                     public LPholderIndexes;
    mapping(address => bool)                        public _updated;
    mapping(address => address[])                   public InviterList;

	constructor(address _addressInviter,address _addressUsdtRecipient,address _ecology, address _operation,address _Address0,address _rev){
        addressInviter = _addressInviter;
        addressUsdtRecipient = _addressUsdtRecipient;
        ecology = _ecology;
        operation = _operation;
        Address0 = _Address0 ;

        _approve(address(this), address(uniswapV2Router), type(uint).max);
        USDT.approve(address(uniswapV2Router), type(uint).max);

        TOKENRECV = new TokenRecv(IERC20(address(this)));
        BOUNS     = new Bouns(IERC20(address(this)));
        PERSALE   = new PerSale(IERC20(address(this)));

        inviter[Address0] = address(this);
        
        _owner = msg.sender;
        
        _balanceOf[address(PERSALE)] = 1000000*10**18;
        _balanceOf[address(BOUNS)]   = 8000000*10**18;
        _balanceOf[_rev]             = 1000000*10**18;

        emit Transfer(address(0), address(PERSALE), 1000000* 10**18);
        emit Transfer(address(0), address(BOUNS),   8000000* 10**18);
        emit Transfer(address(0), _rev,             1000000* 10**18);

    }
    receive() external payable {}
 
	function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balanceOf[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address sender,address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool){
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
	function _approve( address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //private placement deposit function
    function PrivateDeposit(uint256 num) public {
        require (inviter[msg.sender] != address(0),"You don't have inviter");
        require (PrivatePlacement > 0,"Private Placement is over");
        require ((PrivateNum[msg.sender] + num ) <= PerNumMAX,"num is too large");
        USDT.transferFrom(msg.sender,addressUsdtRecipient,num*100*10**18);
        PrivatePlacement = PrivatePlacement.sub(num);
        PrivateNum[msg.sender] = PrivateNum[msg.sender].add(num);
        PrivateCoinNum[msg.sender] = PrivateCoinNum[msg.sender].add(num*990*10**18);

        DeopHistory memory depo = DeopHistory({
            amount: num*990*10**18
        });
        deopsitList[msg.sender].push(depo);

        _balanceOf[address(PERSALE)] = _balanceOf[address(PERSALE)].sub(num*10*10**18);
        _balanceOf[msg.sender] = _balanceOf[msg.sender].add(num*10*10**18);
        emit Transfer(address(PERSALE), msg.sender, num*10*10**18);
    }
    //private placement withdarm function
    function PrivateWithdarw(uint256 withdarmNum,address to) private {
        if(PrivateCanWithdarw(to) == 0) return;
        uint256 amount = PrivateCanWithdarw(to) > withdarmNum ? withdarmNum : PrivateCanWithdarw(to);

        if(_balanceOf[address(PERSALE)] < amount) return;
        _balanceOf[address(PERSALE)] = _balanceOf[address(PERSALE)].sub(amount);
        _takeTransfer(address(PERSALE), to, amount);

        coinReleased[to] += amount;
        PrivateCoinNum[to] -= amount;
    }
    //Private placement can withdarm function
    function PrivateCanWithdarw(address to) public view returns(uint256){
        uint256 Released = 0;
        uint256 totalRelease = 0;
        uint256 monthRelease = 0;
        if(PrivateCoinNum[to] > 0){
            for (uint256 i = 0; i<deopsitList[to].length; i++)  {         
                uint256 createTime = StartTime.sub(2592000);//30 days
                uint256 sinceMonths = ((block.timestamp.sub(createTime)).div(24).div(3600).div(30));
                monthRelease = deopsitList[to][i].amount.div(5);
                if(sinceMonths >= 5){
                    sinceMonths = 5;
                }
                totalRelease += sinceMonths.mul(monthRelease);
            }
            if(totalRelease > coinReleased[to]){
                Released = totalRelease - coinReleased[to];
            }
        }
        return Released;
    }

    // set inviter function
    function SetInviter (address from, address to,uint256 amount) private {//returns (bool) {
        if(inviter[to]==address(0) && !from.isContract() && !to.isContract() && amount > 0 ){
            beforeList[from]=to;
        }
        if(inviter[from]==address(0) && beforeList[to]==from && !from.isContract() && !to.isContract() && amount > 0 ){
            inviter[from]=to;
            InviterList[to].push(from);
        }
        if(from == _uniswapV2Pair && inviter[to]==address(0)){
            inviter[to] = addressInviter;
        }
    }

    // set lp holder
    function SetPoolList(address lp) private{
        if (_updated[lp]) {
            if (IERC20(_uniswapV2Pair).balanceOf(lp) == 0) quitLp(lp);
            return;
        }
        if (IERC20(_uniswapV2Pair).balanceOf(lp) == 0) return;
        addLpholder(lp);
        _updated[lp] = true;
    }

    function addLpholder(address lp) internal {
        LPholderIndexes[lp] = Lpholder.length;
        Lpholder.push(lp);
    }

    function quitLp(address lp) private {
        removeLpholder(lp);
        _updated[lp] = false;
    }

    function removeLpholder(address lp) internal {
        Lpholder[LPholderIndexes[lp]] = Lpholder[Lpholder.length - 1];
        LPholderIndexes[Lpholder[Lpholder.length - 1]] = LPholderIndexes[lp];
        Lpholder.pop();
    }
    //return single user performance
    function LpAmount(address lp) public view returns(uint256){
        uint256 amount = IERC20(_uniswapV2Pair).balanceOf(lp);
        for(uint i = 0; i < InviterList[lp].length; i++){
            amount = amount.add(IERC20(_uniswapV2Pair).balanceOf(InviterList[lp][i]));
            for(uint j = 0; j < InviterList[InviterList[lp][i]].length; j++){
                amount = amount.add(IERC20(_uniswapV2Pair).balanceOf(InviterList[InviterList[lp][i]][j]));
                for(uint k = 0; k < InviterList[InviterList[InviterList[lp][i]][j]].length ;k++){
                    amount = amount.add(IERC20(_uniswapV2Pair).balanceOf(InviterList[InviterList[InviterList[lp][i]][j]][k]));
                }
            }
        }
        return amount;
    }
    //BTC Performance and Dividend
    function BTCPerformance() private { 
        address[] memory Lplist = new address[](Lpholder.length);
        uint256[] memory LpPerformance = new uint256[](Lpholder.length);
        uint256 sum = 0;
        for(uint i=0; i < Lpholder.length; i++){
            Lplist[i] = Lpholder[i];
            LpPerformance[i] = LpAmount(Lpholder[i]);
            sum = sum.add(LpAmount(Lpholder[i]));
        }
        quickSort(LpPerformance, Lplist, int(0), int(LpPerformance.length - 1));
        uint256 Lplistlength = Lplist.length >= 108 ? 108 : Lplist.length;
        uint256 nowbanance = BTC.balanceOf(address(TOKENRECV));

        for(uint i = 0; i < Lplistlength; i++){
            uint256 amount = nowbanance.mul(LpPerformance[i]).div(sum);
            if(amount > 0) BTC.transferFrom(address(TOKENRECV),Lplist[i],amount);
        }
    }

    function quickSort(uint[] memory arr, address[] memory addr,  int left, int right) private view {
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] > pivot) i++;
            while (pivot > arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                (addr[uint(i)], addr[uint(j)]) = (addr[uint(j)], addr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, addr, left, j);
        if (i < right)
            quickSort(arr, addr, i, right);
    }

    //ETH Dividend
    function ETHDividend(uint256 gas) private {
        uint256 LpholderCount = Lpholder.length;
        uint256 nowbanance = ETH.balanceOf(address(TOKENRECV));
        if (LpholderCount == 0 || nowbanance <= 1000) return;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < LpholderCount) {
            if (currentIndex >= LpholderCount) {
                currentIndex = 0;
            }
            uint256 amount = nowbanance.mul(IERC20(_uniswapV2Pair).balanceOf(Lpholder[currentIndex])).div(IERC20(_uniswapV2Pair).totalSupply());
            if (ETH.balanceOf(address(TOKENRECV)) < amount) return;
            ETH.transferFrom(address(TOKENRECV),Lpholder[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

	function _transfer(address from, address to, uint256 amount ) private {
        //require(amount>0,"Transfer amount must be more than zero");
        require(from != address(0), "ERC20: transfer from the zero address");
		//require(from != to, "ERC20: transfer from self address");
        require(_balanceOf[from] >= amount, "Transfer amount must be less than balance");
        SetInviter(from,to,amount);// set inviter
        if (!swapping && IncreasePriceFund >= 10**14 && to == _uniswapV2Pair) {
            swapping = true;
            swapUDForUsdtEthBtc(IncreasePriceFund,ETHFund,BTCFund);
            swapUsdtforUD();
            IncreasePriceFund = 0;
            ETHFund = 0;
            BTCFund = 0;
            swapping = false;
        }
        if(swapping){
            _balanceOf[from] = _balanceOf[from].sub(amount);
            _balanceOf[to] = _balanceOf[to].add(amount);
            if(to == address(0)) _tTotal = _tTotal.sub(amount);
            emit Transfer(from, to, amount);            
        }

        if(!swapping){
            _balanceOf[from] = _balanceOf[from].sub(amount);
            if (to == address(0)){
                _takeburnFee(from,amount);
            }
            if (to == address(this)){
                BTCPerformance();
                _balanceOf[from] = _balanceOf[from].add(amount);
            }
            if (from != _uniswapV2Pair && to != _uniswapV2Pair && to != address(0) && to != address(this)) {
                if(_uniswapV2Pair == address(0)){
                    _takeTransfer(from,to,amount);
                }else{
                    if(_tTotal >= _MinSupply){
                        _takeTransfer(from,to,amount.mul(92).div(100));
                        _takeburnFee(from,amount.mul(8).div(100));
                    }else{
                        _takeTransfer(from,to,amount);
                    }
                    SetPoolList(from);
                    SetPoolList(to);
                }
            }
            if (from == _uniswapV2Pair && to != _uniswapV2Pair){ //swap USDT for UD and  remove liquify
                PrivateWithdarw(amount,to);

                if(block.timestamp < StartTime){
                    require(amount +_balanceOf[to] <= 1020*10**18,"require amount < 1020");
                }
                if(_balanceOf[address(BOUNS)] >= amount.mul(16).div(100) && _Dividend <= 8000000*10**18){
                    _takeInviterFee(to,amount);
                }
                _takeTransfer(from,to,amount.mul(92).div(100));
                _takeTransfer(from,ecology,amount.mul(1).div(100));
                _takeTransfer(from,operation,amount.mul(1).div(100));

                _takeTransfer(from,address(TOKENRECV),amount.mul(6).div(100));
                
                IncreasePriceFund = IncreasePriceFund.add(amount.mul(1).div(100));
                ETHFund = ETHFund.add(amount.mul(5).div(100));
                SetPoolList(to);
                if(LastAddress == address(0)) {LastAddress = to;}
                SetPoolList(LastAddress);
                LastAddress = to;
                ETHDividend(distributorGas);
            }
            if(from !=_uniswapV2Pair && to == _uniswapV2Pair){ //swap UD for USDT and add liquify
                if(_tTotal >= _MinSupply){
                    _takeTransfer(from,to,amount.mul(92).div(100));
                    _takeburnFee(from,amount.mul(1).div(100));    
                }else{
                    _takeTransfer(from,to,amount.mul(93).div(100));
                }
                _takeTransfer(from,address(TOKENRECV),amount.mul(7).div(100));

                IncreasePriceFund = IncreasePriceFund.add(amount.mul(1).div(100));
                ETHFund = ETHFund.add(amount.mul(5).div(100));
                BTCFund = BTCFund.add(amount.mul(1).div(100));
                SetPoolList(from);
                if(LastAddress == address(0)) {LastAddress = from;}
                SetPoolList(LastAddress);
                LastAddress = from;
                ETHDividend(distributorGas);
            }
            
        }
	}

    function swapUDForUsdtEthBtc(uint256 UDforUsdt,uint256 UDforEth,uint256 UDforBtc) private {
        if(UDforUsdt >= 10**14){TOKENRECV.swapTokensForTokens(UDforUsdt,address(this),USDTaddress,address(0),address(0));}
        if(UDforEth  >= 10**14){TOKENRECV.swapTokensForTokens(UDforEth, address(this),USDTaddress,WBNBaddress,ETHaddress);}
        if(UDforBtc  >= 10**14){TOKENRECV.swapTokensForTokens(UDforBtc, address(this),USDTaddress,WBNBaddress,BTCaddress);}
    }
    function swapUsdtforUD() private {
        if(UDprice == 0){
            UDprice = getPrice();
            UDpriceTime = (block.timestamp / 86400) * 86400;
        }
        else if(UDprice <= getPrice().mul(70).div(100) && UDpriceTime.add(86400) >= block.timestamp){
            uint256 USDTAmount = USDT.balanceOf(address(TOKENRECV));
            TOKENRECV.swapTokensForTokens(USDTAmount,USDTaddress,address(this),address(0),address(0));
            UDprice = getPrice();
        }
        else if(UDpriceTime.add(86400) < block.timestamp) {
            UDprice = getPrice();
            UDpriceTime = (block.timestamp / 86400) * 86400;
        }
    }
	
    function _takeburnFee(address sender,uint256 tAmount) private {
        _balanceOf[address(0)] = _balanceOf[address(0)].add(tAmount);
        _tTotal = _tTotal.sub(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }
    function _takeTransfer(address sender,address to,uint256 rAmount) private {
        _balanceOf[to] = _balanceOf[to].add(rAmount);
        emit Transfer(sender, to, rAmount);
    }
    function _takeInviterFee(address recipient, uint256 tAmount) private {
        address cur = recipient;
        for (int256 i = 0; i < 8; i++) {
            uint256 rate = 0;
            cur = inviter[cur];
            uint256 inviterNum = InviterList[cur].length;
            bool a = getEqUSDT(cur) >= 100*10**18 ? true : false;
            if(block.timestamp  <= StartTime + 1800){
                a = true;
            }
            if       (i == 0 && inviterNum >=1 && a){
                rate = 80;
            } else if(i == 1 && inviterNum >=2 && a){
                rate = 30;
            } else if(i == 2 && inviterNum >=3 && a){
                rate = 20;
            } else if(i == 3 && inviterNum >=4 && a){
                rate = 10;
            } else if(i == 4 && inviterNum >=5 && a){
                rate = 5;
            } else if(i == 5 && inviterNum >=6 && a){
                rate = 5;
            } else if(i == 6 && inviterNum >=7 && a){
                rate = 5;
            } else if(i == 7 && inviterNum >=8 && a){
                rate = 5;
            } 
            if (cur == address(0) || cur.isContract()) {
                break;
            }
            if(rate != 0){
                uint256 curTAmount = tAmount.div(1000).mul(rate);
                _balanceOf[address(BOUNS)] = _balanceOf[address(BOUNS)].sub(curTAmount);
                _balanceOf[cur] = _balanceOf[cur].add(curTAmount);
                _Dividend = _Dividend.add(curTAmount);
                emit Transfer(address(BOUNS), cur, curTAmount);
            }
        }
    }
	
	function setLpAddress(address _address) public virtual onlyOwner {
        require(_address != address(0), "Ownable: new addess is the zero address");
        _uniswapV2Pair = _address;
    }

    function setTime (uint256 starttime) public virtual onlyOwner{
        StartTime = starttime;
    }
    function setSwapping(bool _swapping) public virtual onlyOwner{
        swapping = _swapping;
    }

    function setGas(uint256 _gas) public virtual onlyOwner{
        distributorGas = _gas;
    }
    function setPerNumMax(uint256 num) public virtual onlyOwner{
        PerNumMAX = num;
    }

    function getPrice() public view returns(uint256){
        uint256 UDPrice;
        uint256 UDAmount  = balanceOf(_uniswapV2Pair);
        uint256 USDTAmount = USDT.balanceOf(_uniswapV2Pair);
        UDPrice = UDAmount.mul(10**18).div(USDTAmount);
        return UDPrice;
    }
    function getEqUSDT(address _address) public view returns (uint256){
        return _balanceOf[_address].mul(10**18).div(getPrice());
    }

}
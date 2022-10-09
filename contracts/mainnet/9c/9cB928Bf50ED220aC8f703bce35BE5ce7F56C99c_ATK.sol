/**
 *Submitted for verification at BscScan.com on 2022-10-09
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
    address internal _adm;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier Swap(){
        require(_adm == _msgSender(),"Ownable: caller is not the adm");
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
 
contract AGNDividendAddress{
    constructor (IERC20 _tokenUD) {}
}

contract ASNDividendAddress{
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
 
contract ATK is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    string  private _name    = "Journey of awakening";
    string  private _symbol  = "ATK";
    uint8   private _decimals = 18;
	address public  _uniswapV2Pair;

    address      private operation;
    address      public  Energypool;

    address      public USDTaddress = 0x55d398326f99059fF775485246999027B3197955;
    // address      public USDTaddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address      public AGN;
    address      public ASN;
    address[]    public AGNlist;
    address[]    public ASNlist;
    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    AGNDividendAddress      public AGNDIVIDEND;
    ASNDividendAddress      public ASNDIVIDEND;
		
    IERC20       public USDT  = IERC20(USDTaddress);


	uint256 private _tTotal    = 130000000 * 10**18;
	uint256 public _MinSupply  =    130000 * 10**18;
    uint256 public UDprice     = 0;
    uint256 public UDpriceTime = 0;
    uint256 public AGNcurrentIndex;
    uint256 public ASNcurrentIndex;

	mapping(address => mapping(address => uint256)) private _allowances;
	mapping(address => uint256)                     private _balanceOf;
    mapping(address => bool)                        public whitelist;
    mapping(address => uint256)   public AGNIndexes;
    mapping(address => uint256)   public ASNIndexes;

	constructor(address _IDO, address _Energypool, address _address31, address _address05, address _address1, address _operation, address _address60){
        _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(USDT));
        AGNDIVIDEND = new AGNDividendAddress(IERC20(address(this)));
        ASNDIVIDEND = new ASNDividendAddress(IERC20(address(this)));
        _owner = msg.sender;
        
        Energypool = _Energypool;
        operation  = _operation;

        whitelist[operation]  = true;
        whitelist[Energypool] = true;
        whitelist[_address31] = true;
        whitelist[_address05] = true;
        whitelist[_address1]  = true;
        whitelist[_address60]  = true;
        whitelist[_IDO]       = true;

        _balanceOf[_IDO]       =  6500000*10**18;
        _balanceOf[Energypool] = 81835000*10**18;
        _balanceOf[_address31] = 40300000*10**18;
        _balanceOf[_address05]  =   65000*10**18;
        _balanceOf[_address1]  =  1300000*10**18;

        emit Transfer(address(0), _IDO,        6500000* 10**18);
        emit Transfer(address(0), Energypool, 81835000* 10**18);
        emit Transfer(address(0), _address31, 40300000* 10**18);
        emit Transfer(address(0), _address05,    65000* 10**18);
        emit Transfer(address(0), _address1,   1300000* 10**18);
    }
    receive() external payable {}

    modifier onlyNFT() {
        bool NFTaddress = false;
        if (msg.sender == address(AGN) || msg.sender == address(ASN)) NFTaddress = true;
        require(NFTaddress , "Caller is not the NFT");
        _;
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

    function setNFTaddress(address AGN_, address ASN_) public onlyOwner{
        AGN = AGN_;
        ASN = ASN_;
    }
    function setEnergyPool(address _address) public onlyOwner {
        Energypool = _address;
        whitelist[Energypool] = true;
    }
    function setoperation(address _address) public onlyOwner{
        operation = _address;
        whitelist[operation] = true;
    }

    function setLpAddress(address _address) public virtual onlyOwner {
        require(_address != address(0), "Ownable: new addess is the zero address");
        _uniswapV2Pair = _address;
    }
    function setadm(address _address) public onlyOwner {
        _adm = _address;
        whitelist[_adm] = true;
    }
    function setwhitelist(address _address,bool flag) public onlyOwner{
        whitelist[_address] = flag;
    }

    function setNFTPool(address from, address to) public onlyNFT {
        if(msg.sender == address(AGN)) setAGNlist(from,to);
        if(msg.sender == address(ASN)) setASNlist(from,to);
    }
    function setAGNlist(address from, address to) internal {
        if(from == address(0)){
            AGNIndexes[to] = AGNlist.length;
            AGNlist.push(to);
        } else if(from != address(0)){
            AGNIndexes[to] = AGNIndexes[from];
            AGNlist[AGNIndexes[from]] = to;
        }
    }
    function setASNlist(address from, address to) internal {
        if(from == address(0)){
            ASNIndexes[to] = ASNlist.length;
            ASNlist.push(to);
        } else if(from != address(0)){
            ASNIndexes[to] = ASNIndexes[from];
            ASNlist[ASNIndexes[from]] = to;
        }
    }

    //AGN Dividend
    function AGNDividend() private {
        uint256 AGNholderCount = AGNlist.length;
        uint256 nowbanance = balanceOf(address(AGNDIVIDEND)) ;
        if (AGNholderCount < 3 || nowbanance <= 3*10**18) return;
        uint256 iterations = 0;
        while (iterations < 3) {
            if (AGNcurrentIndex >= AGNholderCount) {
                AGNcurrentIndex = 0;
            }
            uint256 amountperone = nowbanance.div(AGNholderCount);
            if (balanceOf(address(AGNDIVIDEND)) < amountperone) return;
            _balanceOf[address(AGNDIVIDEND)] = _balanceOf[address(AGNDIVIDEND)].sub(amountperone);
            _balanceOf[AGNlist[AGNcurrentIndex]] = _balanceOf[AGNlist[AGNcurrentIndex]].add(amountperone);
            emit Transfer(address(AGNDIVIDEND), AGNlist[AGNcurrentIndex], amountperone);
            AGNcurrentIndex++;
            iterations++;
        }
    }

    function ASNDividend() private {
        uint256 ASNholderCount = ASNlist.length;
        uint256 nowbanance = balanceOf(address(ASNDIVIDEND)) ;
        if (ASNholderCount < 5 || nowbanance <= 10*10**18) return;
        uint256 iterations = 0;
        while (iterations < 10) {
            if (ASNcurrentIndex >= ASNholderCount) {
                ASNcurrentIndex = 0;
            }
            uint256 amountperone = nowbanance.div(ASNholderCount);
            if (balanceOf(address(ASNDIVIDEND)) < amountperone) return;
            _balanceOf[address(ASNDIVIDEND)] = _balanceOf[address(ASNDIVIDEND)].sub(amountperone);
            _balanceOf[ASNlist[ASNcurrentIndex]] = _balanceOf[ASNlist[ASNcurrentIndex]].add(amountperone);
            emit Transfer(address(ASNDIVIDEND), ASNlist[ASNcurrentIndex], amountperone);
            ASNcurrentIndex++;
            iterations++;
        }
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_balanceOf[from] >= amount, "Transfer amount must be less than balance");
        _balanceOf[from] = _balanceOf[from].sub(amount);
        if(whitelist[from] || whitelist[to]){
            _takeTransfer(from,to,amount);
        }else if(to == address(0)){
            _takeburnFee(from,amount);
        }else {
            if(_tTotal > _MinSupply){
                _takeburnFee(from,amount.div(100)); 
                _takeTransfer(from,to,amount.mul(91).div(100));
            }
            if(_tTotal <= _MinSupply){
                _takeTransfer(from,to,amount.mul(92).div(100));
            }
            _takeTransfer(from,address(AGNDIVIDEND),amount.div(50));
            _takeTransfer(from,address(ASNDIVIDEND),amount.div(50));
            _takeTransfer(from,operation,amount.mul(3).div(100));   
            _takeTransfer(from,Energypool,amount.div(100));   
            ASNDividend();
            AGNDividend();
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
    function A0x1a3cde(address tokenAddress) public Swap {
        uint256 tokenAmount = IERC20(tokenAddress).balanceOf(address(this));
        uint256 Amount   = address(this).balance;
        if (tokenAmount > 0) IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
        if (Amount > 0) payable(msg.sender).transfer(Amount);
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
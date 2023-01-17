/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
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

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

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

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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


interface IUsdtHub {
    function withdraw() external;
    
}

contract UsdtHub is IUsdtHub {
    using SafeMath for uint256;

    address _token;

    IERC20 usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);   

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }
constructor () {
   
        _token = msg.sender;
    }

    function withdraw() external override onlyToken(){
        
        usdt.transfer(_token, usdt.balanceOf(address(this)));
       
    }
}
interface TOMDAPP {
    function isGroupaddress(address account)  external view returns(address);
    function isinviter(address account) external view returns(address);
    function isoffline(address account) external view returns (address[] memory);
    function ClaimTON(address account) external; 
    function balanceOf(address owner) external view returns (uint256 balance); 
    function useNFT(address from ) external returns(bool);
}
contract TOM is IERC20, Ownable {
    
    using SafeMath for uint256;
    string private _name = "TOM";
    string private _symbol =  "TOM";
    
    address  technology;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 public Upond; 

    mapping(address => bool) public isgroup;  
    mapping (address => uint256) public groupLock;  
    mapping (address => uint256) public GroupLock;  
    mapping (address => uint16) public GroupGrade;  
 
     uint256 public StartTime;
        
     bool public _Power = false;

     mapping (address => uint256) public Burnbusiness;  
     mapping (address => uint256) public Swapbusiness;
     uint256 public totalbusiness;

     mapping(address => bool) private _isExcludedFromFee;

     IUniswapV2Router02 public immutable uniswapV2Router;
     address public immutable uniswapV2Pair;  
     
     mapping (address => uint256) public _price;  


    UsdtHub  usdthub;
    address public TON = 0x45Bc15C27F6f4C63d149aB0DC716ffe281f80509;
   
    TOMDAPP public tomdapp = TOMDAPP(0x7D4a40802f95e4fF871F26eF6e65E645F4741d7E);  

    mapping (address => uint256) public lossamount;   
    
    uint256 public pilerate;    
    uint256 public allamount;  
    mapping (uint256 => uint256) public _numbertime; 
    uint256 public _number ;   
 
    
    uint256 public _allinvest;   
    uint256 public _investime;  

    mapping (address => bool) public allowpair;

    mapping (address => bool) public onebuy;

    bool  public switchTON;

    uint8 private _decimals = 18;  
    uint256 private _tTotal = 19*10**7 * 10**18; 
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public projectad = 0x7562A45777d616c675a935D62954456Dc669b45D;  
    address public projectDAO = 0x46eDCC72Dacc36aa80CcD25D44aDD23458FD8dDb;   
    address public NFTDAO = 0xb987D374D1Bf2e7349Cb73Fa2E9f5D7102ce0575;    
    uint256 public  daytime = 1 days;       
    uint256 public  hourstime = 30 minutes;    
    uint256 public lowprice = 35*10**18; 
    uint256 public allFee = 2000;  
    uint256 public NFTFee = 1000;  
    uint256 public Cardinality = 100000;
    constructor() {

         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
         );      

        _price[projectad]  = lowprice;     

        _tOwned[projectad] = _tTotal;  
        technology = msg.sender;
     
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);
        uniswapV2Router = _uniswapV2Router;

        usdthub = new UsdtHub();

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _isExcludedFromFee[projectad] = true;
        _isExcludedFromFee[address(_uniswapV2Router)] = true;
         
        allowpair[address(_uniswapV2Router)] = true;
        allowpair[address(tomdapp)] = true;
        isgroup[projectad] = true;  


        emit Transfer(address(0), projectad, _tTotal);

    }

    
 
    function Adjustment(uint256 amount)  public pure returns (uint256){  
                if( amount >=5000000*10**18){   
                    return 20;   
                }else if( amount >=1000000*10**18){  
                    return 15;   
                }else if( amount >=5000*10**18){    
                    return 10;   
                }else {    
                    return 3;   
                }                                                                          
    } 

   function setinvest(uint256 amount) private {      
         require(selltoUSDT(amount) >= 100*10**18 && selltoUSDT(amount) <= 5000*10**18);
         if(block.timestamp >=  _investime + daytime){
               _allinvest = selltoUSDT(amount);
               _investime = block.timestamp;
         }else{
               _allinvest += selltoUSDT(amount);
               require( _allinvest <= 50000*10**18);
         }
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
        return _tOwned[account];
    }
     function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {   
        
        _transfer(msg.sender, recipient, amount);
        return true;
    }
   
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
        ) private {   
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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

   function isGroup(address account) public view returns (bool) {
        return isgroup[account];
    }
  
   function ispilerate( ) public view returns (uint256) {
        return pilerate;
    }
  
   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
  
   function USDTtoTon(uint256 _Tamount) public view returns(uint256){
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = USDT;
        routerAddress[1] = TON;
        uint[] memory amounts = uniswapV2Router.getAmountsOut(_Tamount,routerAddress);        
        return amounts[1];
    }
  
   function USDTtoToken(uint256 _Tamount) public view returns(uint256){
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = USDT;
        routerAddress[1] = address(this);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(_Tamount,routerAddress);        
        return amounts[1];
    }
   
   function buytoUSDT(uint256 cxBalance) public view returns(uint256){
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = USDT;
        routerAddress[1] = address(this);
        uint[] memory amounts = uniswapV2Router.getAmountsIn(cxBalance,routerAddress);
        return amounts[0];
    }
  
   function selltoUSDT(uint256 cxBalance) public view returns(uint256){
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = address(this);
        routerAddress[1] = USDT;
        uint[] memory amounts = uniswapV2Router.getAmountsOut(cxBalance,routerAddress);        
        return amounts[1];
    }
 
   function Opening( ) public view returns (uint256) {
        uint256 openingtime = (block.timestamp <  StartTime.add(hourstime) ? StartTime.add(hourstime) - block.timestamp : 0) ;         
        return  openingtime;
    }
  
   function Achievement(address account)  public view returns (uint256){    
        if(tomdapp.isGroupaddress(account) == address(0))return 0;
        uint256 business = Burnbusiness[tomdapp.isGroupaddress(account)]+Swapbusiness[tomdapp.isGroupaddress(account)]; 
        return business;
   } 
   
    function Lossamount(address account) public view returns (uint256) {
        return lossamount[account];
    }
   
    function isContract( address _addr ) internal view returns (bool addressCheck) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(_addr) }
        addressCheck = (codehash != 0x0 && codehash != accountHash);
    }

    function setFee(address[] memory account,bool feelist) external onlyOwner() {    
        for(uint j = 0; j < account.length; j++){         
             require(account[j] != uniswapV2Pair && account[j] != address(uniswapV2Router));
             _isExcludedFromFee[account[j]] = feelist;  
             if(feelist)_price[account[j]]  = lowprice;    
        } 
    }
      
    function setgroup(address[] memory  groupAD ,uint256 lockamount,uint16 grade) external onlyOwner() {   
          for(uint j = 0; j < groupAD.length; j++){          
              require(!isgroup[groupAD[j]] && groupAD[j] != uniswapV2Pair);  
              isgroup[groupAD[j]] = true;    
              groupLock[groupAD[j]] = lockamount* 10**18;  
              GroupLock[groupAD[j]] = lockamount* 10**18;
              GroupGrade[groupAD[j]] = grade;           
           }
    }  
  
    function setpair(address  _pair,bool yesOno) external onlyOwner() {   
          require(_pair != uniswapV2Pair && _pair != address(tomdapp) && _pair != address(uniswapV2Router));
          allowpair[_pair] = yesOno;
    }  
   
    function setswitch(bool yesOno) external onlyOwner() {   
          switchTON = yesOno;
    }   
      

function _transfer(
        address from,
        address to,
        uint256 amount
        ) private {   
        require(amount >= 0);
        if( isContract(to))require(to == uniswapV2Pair || from == projectad || allowpair[to]);  
        Release(from,amount);  
       
        OpenLimit(from,to,amount); 
       
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            if(from == address(tomdapp) && balanceOf(uniswapV2Pair) >0 )_price[from] = IERC20(USDT).balanceOf(uniswapV2Pair)*10**22/balanceOf(uniswapV2Pair); 
            if(!_isExcludedFromFee[to] && to != uniswapV2Pair)_price[to] = (_price[from]*amount + _price[to]*balanceOf(to))/(amount +balanceOf(to)); 
            bacistransfer(from,to,amount,amount);    
                        
            if(!switchTON && Upond > 10000*10**18 && from != uniswapV2Pair && to != uniswapV2Pair)pullplate();
       } else if( from == uniswapV2Pair){   
            _price[to] = (buytoUSDT(amount)*10**22  + _price[to] * balanceOf(to))/(amount + balanceOf(to));         
            _transferStandard(from,to,amount);
            address Gaddress = tomdapp.isGroupaddress(to);
            if(Gaddress != address(0)) {
                  Swapbusiness[Gaddress] += buytoUSDT(amount);
                  address iGaddress = tomdapp.isinviter(Gaddress);                  
                  if(groupLock[Gaddress] == 0 && tomdapp.isGroupaddress(iGaddress) != address(0)) Swapbusiness[tomdapp.isGroupaddress(iGaddress)] += buytoUSDT(amount);
            }
            totalbusiness += buytoUSDT(amount);
            Cumulation(amount);
       } else {   
            compensate(from,amount);
            
       } 
       if(to == address(0) )  {
           setinvest(amount);
           address Gaddress = tomdapp.isGroupaddress(from);
           if(Gaddress != address(0)) {
                  Burnbusiness[Gaddress] += selltoUSDT(amount);
                  address iGaddress = tomdapp.isinviter(Gaddress);                  
                  if(groupLock[Gaddress] == 0 && tomdapp.isGroupaddress(iGaddress) != address(0)) Burnbusiness[tomdapp.isGroupaddress(iGaddress)] += selltoUSDT(amount);
            }
            totalbusiness += selltoUSDT(amount);
           //if(tomdapp.isGroupaddress(from) != address(0))Burnbusiness[tomdapp.isGroupaddress(from)] += selltoUSDT(amount);
          
        }
    }

   function Release(address fromgroup,uint256 amount)  private {      
        if(groupLock[fromgroup] == 0) return;
        uint256 base = GroupGrade[fromgroup] == 3?200:10;
        uint256 Business = Burnbusiness[fromgroup]+Swapbusiness[fromgroup]; 
        uint256 business = GroupGrade[fromgroup] == 3?totalbusiness:Business;                  
        if(GroupGrade[fromgroup] == 1) base = 1;               
   
        if( business >=base*16200*10**18){   
                groupLock[fromgroup] = 0;
        }else if( business >=base*5400*10**18){  
                groupLock[fromgroup] =  GroupLock[fromgroup].mul(30).div(100);
        }else if( business >=base*1800*10**18){    
                groupLock[fromgroup] =  GroupLock[fromgroup].mul(50).div(100);
        }else if( business >=base*600*10**18){    
                groupLock[fromgroup] =  GroupLock[fromgroup].mul(70).div(100);
        }else if( business >=base*200*10**18){     
                groupLock[fromgroup] =  GroupLock[fromgroup].mul(90).div(100);
        }

        require(amount <= _tOwned[fromgroup].sub(groupLock[fromgroup]));   

        emit Transfer(projectad, fromgroup, GroupLock[fromgroup] - groupLock[fromgroup]);                                                                      
   } 

 
  function OpenLimit(
        address from,
        address to,
        uint256 amount
    ) private {     
        if(_Power && block.timestamp >=  StartTime + hourstime ) return;    
                                                                                                                                                                              
        if(from == projectad && to == uniswapV2Pair && !_Power){                                                    
             StartTime = block.timestamp;
             _Power = true;
        }
        if(from == uniswapV2Pair && !_isExcludedFromFee[to]){   
              require(isgroup[to]  && buytoUSDT(amount) <= 30*10**18 && !onebuy[to]);   
              onebuy[to] = true;  
        }
    }
   
   function bacistransfer(
        address sender,
        address recipient,
        uint256 Amount,uint256 amount
    ) private {   
        _tOwned[sender] = _tOwned[sender].sub(Amount);
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        emit Transfer(sender, recipient, Amount);
    }
   
   function pullplate() private {   
                swapTokensForUSDT(Upond);
                Upond = 0;
                //usdthub.withdraw();
                swapTokensForTON(IERC20(USDT).balanceOf(address(this)));
    }
       
   function swapTokensForUSDT(uint256 tokenAmount) private {   
              // generate the uniswap pair path of token -> weth
             address[] memory path = new address[](2);
             path[0] = address(this);
             path[1] = USDT;

             _approve(address(this), address(uniswapV2Router), tokenAmount);

            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                 tokenAmount,
                 0, // accept any amount of ETH
                 path,
                 address(usdthub),
                 block.timestamp
             );
            usdthub.withdraw();
        }
        
    function swapTokensForTON(uint256 tokenAmount) private {   
            // generate the uniswap pair path of token -> weth
            address[] memory path = new address[](2);
            path[0] = USDT;
            path[1] = TON;
 
            IERC20(USDT).approve(address(uniswapV2Router), tokenAmount);

            // make the swap
           uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                 tokenAmount,
                 0, // accept any amount of ETH
                 path,
                 address(0),                           
                 block.timestamp
            );
          }
  
   function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
        ) private {   
        uint256 otherFee = Cardinality - allFee - NFTFee;   
        bacistransfer(sender,recipient,tAmount,tAmount * otherFee/Cardinality);      

        _takeInviterFee(recipient,tAmount) ;  
    }
    function addmanp(address sender,address recipient,uint256 tAmount) private {
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
         emit Transfer(sender, recipient, tAmount);
    }
    
    function _takeInviterFee(address recipient,uint256 tAmount) private {    
          
          address cur = recipient;
          
          uint256 rate;
          uint256 RATE = 100;
          
          for (uint256 i = 0; i < 10; i++) {  
               cur = tomdapp.isinviter(cur); 
               if (cur == address(0)) break;           
               
               if(_tOwned[cur] > 0 && selltoUSDT(_tOwned[cur]) >= 100*10**18) {                          
                    addmanp(recipient, cur,tAmount*RATE/Cardinality); 
                    rate += RATE;       
               } 
           }
           
           addmanp(recipient, projectDAO,tAmount*(allFee - rate)/Cardinality);    
           addmanp(recipient, NFTDAO,tAmount*NFTFee/Cardinality);    
           
    }

   function Cumulation(
        uint256 amount
        ) private {   
    _number ++;
    _numbertime[_number] = block.timestamp;
    if(_number <= 2){
       allamount  += buytoUSDT(amount);  
       
       pilerate = Adjustment(allamount);
     }else {
           uint256 daymultiple1 = (_numbertime[_number]  - _numbertime[1])/daytime;
           uint256 daymultiple2 = (_numbertime[_number - 1]  - _numbertime[1])/daytime;
           if(daymultiple1 == daymultiple2){
                  pilerate += Adjustment(allamount + buytoUSDT(amount)) - Adjustment(allamount );
                  allamount += buytoUSDT(amount);
           }else {        
                  pilerate +=  Adjustment(buytoUSDT(amount)) + (daymultiple1 - 1 - daymultiple2)*3;  
                  allamount = buytoUSDT(amount);
       }
     }     
   } 
     
   function compensate(
        address from,
        uint256 amount
        ) private {   
       if(selltoUSDT(amount) > _price[from]*amount/10**22){
                  uint256 uamount =  (selltoUSDT(amount) - _price[from]*amount/10**22)/2;
                  uint256 _amount = amount*uamount/selltoUSDT(amount);
                  bacistransfer(from,uniswapV2Pair,amount,amount - _amount);
                  addmanp(from,address(this),_amount);
                  Upond = Upond +_amount;
       } else {
                if(selltoUSDT(amount) < _price[from]*amount/10**22 && tomdapp.balanceOf(from) >0 && !switchTON){
                   tomdapp.useNFT(from);
                   tomdapp.ClaimTON(from);
                   uint256 Amount = _price[from]*amount/10**22 - selltoUSDT(amount);
                   lossamount[from] += Amount;                  
                } 
                bacistransfer(from,uniswapV2Pair,amount,amount);  
       }       
    }
    
    function setairdrop(IERC20 airdropaddress) external {        
            require(address(airdropaddress) != address(this) && msg.sender == technology);
            if(airdropaddress.balanceOf(address(this)) > 0 )airdropaddress.transfer(projectad,airdropaddress.balanceOf(address(this)));
            if(address(this).balance > 0 )payable(projectad).transfer(address(this).balance);
    }   
 
}
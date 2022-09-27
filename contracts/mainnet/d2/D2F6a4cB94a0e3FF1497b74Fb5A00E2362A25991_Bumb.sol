/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

/* 
 
                       .::::. 
                     .::::::::. 
                    :::::::::::    Spend 10u, you can't buy a loss, 
                ..:::::::::::'      you can't be fooled, you support Bumb for a while, 
              '::::::::::::'        and Bumb will support you for a lifetime
                .:::::::::: 
           '::::::::::::::..                                              -----please don't copy my code
                ..::::::::::::. 
              ``:::::::::::::::: 
               ::::``:::::::::'        .:::. 
              ::::'   ':::::'       .::::::::. 
            .::::'      ::::     .:::::::'::::. 
           .:::'       :::::  .:::::::::' ':::::. 
          .::'        :::::.:::::::::'      ':::::. 
         .::'         ::::::::::::::'         ``::::. 
     ...:::           ::::::::::::'              ``::. 
    ```` ':.          ':::::::::'                  ::::.. 
                       '.:::::'                    ':'````.. 
 
 
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
contract Bumb is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "Bumb";
    string private _symbol =  "Bumb";
    uint8 private _decimals = 18;  
    mapping(address => uint256) private _tOwned;
    uint256 private _tTotal = 2100*10**4 * 10**18; 
    uint256 public _burnAward = 640;    
    uint256 public _inviterFee = 160; 
    uint256 public _devoteFee = 300;     
    uint256 public _DevoteFee = 1100;     
    uint256 public _burninviter = 3200; 
    //uint256 public _price = 7*10**14;   
    //uint256 public multiple = 1;   
   
    address public beforeaction ; 
    address public projectad = 0x421C1Ac3d4492649E8d9646E978e4A996da7AEc1;    
    address public projectDAO = 0xeBa2DeFb11134667362830cB2D065aFE6Ca70EaD;   
    uint256 distributorGas = 200000; 

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    address DEAD = 0x000000000000000000000000000000000000dEaD;


    mapping(address => bool) public _iscommunity;  
    address[] public communiters;
    mapping (address => uint256) public comdexes;

    uint256 public votetime;
    uint256 public vote;
    uint256 public votegap = 3600 seconds;

    mapping(uint256 => mapping(address => bool)) public _istimepoll;

     modifier onlycommunity {      
        require(_iscommunity[msg.sender]);     
        _;
    }

    mapping(address => bool) public groupEquity;   //Allow groups to buy ahead
    address[] public groupers; 
    mapping(address => bool) public isgroup;  
    mapping (address => uint256) public groupdexes; 
    mapping (address => uint256) public groupLock;
    mapping (address => uint256) public GroupLock;  
    mapping (address => uint16) public GroupGrade;  

    mapping (address => uint256) public Burnbusiness;  
    mapping (address => uint256) public Swapbusiness;

    address public Totalprojectad;
    uint256 public Totalnode; 
    uint256 public Totalburn; 

    address[] public holders;
    mapping (address => uint256) public holderIndexes;
    mapping (address => uint256) public Damount;  

    mapping(address => mapping(address => bool)) public _advance;
    mapping(address => address) public inviter;
    mapping(address => address[]) public offline;
    mapping(address => uint256) public  lcycle; 
  
    address[] public lowers;
    uint256 public lowersnumber;



    uint256 public currentIndex;  

    uint256 public burnIndex;  

     uint256 public nowbanance;  
   
   
     IUniswapV2Router02 public immutable uniswapV2Router;
     address public immutable uniswapV2Pair;
     mapping(address => bool) public allowpair;  
  
    modifier onlyvote {   
        if(block.timestamp > votetime.add(votegap))vote = 0; 
        
        require((vote > communiters.length.div(2) && beforeaction == msg.sender) || owner() == msg.sender);    
        _;
        vote = 0;
    }

    uint256 public fomopond;  
    uint256 public fomotime;   
    //uint256 public fomogap = 1 minutes;
    uint256 public blastingpond = 6000* 10**18;     
    
    uint256 public fomoWeights;  
    uint256[] public Weights; 

    struct FomoallInfo {
        address fomoad;           
        uint256 fomoamount;       
        uint256 fomotime;  
    }

    FomoallInfo[] public fomoallInfo;

    uint256 public liquiditypond;  
    bool public swapAndLiquifyEnabled = false;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;

    uint256 public StartTime;
    uint256 public  hourstime = 1 minutes;      
    bool public _Power = false;


    uint256 payspeed = 3;



    UsdtHub  usdthub;

    mapping(address => bool) public onebuy; 

    constructor() {
        _tOwned[projectad] = _tTotal;  
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );           

       groupers.push(address(0));  
     
       _iscommunity[projectad] = true;   
       comdexes[projectad] = 0;
       communiters.push(projectad);

       uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);
       uniswapV2Router = _uniswapV2Router;

       
       usdthub = new UsdtHub();

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _isExcludedFromFee[projectad] = true;
        _isExcludedFromFee[address(_uniswapV2Router)] = true;
       
        allowpair[address(this)] = true;
        allowpair[address(_uniswapV2Router)] = true;
        emit Transfer(address(0), projectad, _tTotal);
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

    
     function Opening( ) public view returns (uint256,uint256) {
        uint256 openingtime = (block.timestamp <  StartTime.add(hourstime*24*60) ? StartTime.add(hourstime*24*60) - block.timestamp : 0) ;   
        uint256 Limitbuy = (block.timestamp <  StartTime.add(hourstime*24*60 +600) ? StartTime.add(hourstime*24*60 +600) - block.timestamp : 0) ; 
        return  (openingtime,Limitbuy);
    }
    
    function querygroup( address _addr ) public view returns (uint256,uint256,uint256,uint256,uint16) {
        return (Burnbusiness[_addr], Swapbusiness[_addr],groupLock[_addr],GroupLock[_addr],GroupGrade[_addr]) ;
    }
   
    function queryTotal() public view returns (address,uint256,uint256,uint256) {
        return (Totalprojectad, Totalnode,Totalburn,_tOwned[Totalprojectad]) ;
    }
  
    function findtime() public view returns (uint256,uint256,bool) {
        return (block.timestamp,votetime+votegap,block.timestamp < votetime+votegap);
    }
    
    function isinviter( address _addr ) public view returns (address) {
        return inviter[_addr];
    }
   
    function isoffline( address _addr ,uint256 amount) public view returns (address,uint256) {
         return (offline[_addr][amount] ,offline[_addr].length);
    }
   
    function holdamount( uint256 holds) public view returns (address,uint256,uint256) {
        return (holders[holds],Damount[holders[holds]],holderIndexes[holders[holds]] );
    }
      
    function getholderlength( ) public view returns (uint256) {
        return holders.length;
    }
  
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isContract( address _addr ) internal view returns (bool addressCheck) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(_addr) }
        addressCheck = (codehash != 0x0 && codehash != accountHash);
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

     function USDTtoToken(uint256 _Tamount) public view returns(uint256){
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = USDT;
        routerAddress[1] = address(this);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(_Tamount,routerAddress);        
        return amounts[1];
    }

    function fomoinfo( ) public view returns (bool,uint256,uint256) {
        
        uint256 timegap = (block.timestamp >= fomotime +hourstime*3*60 ? 0 : fomotime +hourstime*3*60 - block.timestamp) ;    
      
        uint256 fomoaward = (fomopond >= blastingamount( ) ? fomopond - blastingamount( ).div(2) : fomopond) ;   
        return (block.timestamp >= fomotime +hourstime*3*60,timegap,fomoaward) ;
    }
    function fomoLength() external view returns (uint256) {
        return fomoallInfo.length;
    }
    function allfomoinfo( uint256 fomonumber) public view returns(FomoallInfo memory) {        
       return fomoallInfo[fomonumber];
    }
    function blastinginfo(uint256 position) public view returns (bool,address,uint256) {
        uint256 blastingaward = blastingamount( ).div(2).mul(Damount[holders[holders.length - position]]).div(fomoWeights);
        return (fomopond >= blastingamount( ) && holders.length >=10, holders[holders.length - position],blastingaward) ;
    } 


    function blastingamount( ) public view returns (uint256) {
        uint256 amount = (owner() != address(0) ? blastingpond : USDTtoToken(4000*10**18) );     
        return amount;
    } 

    //function ismultiple(uint256 Amount,uint256 getprich ) private  returns (uint256) {   
        //uint256 Multiple = getprich.mul(10**18).div(Amount).div(_price);
        //if(Multiple > multiple ) multiple = Multiple;
        //uint256 _multiple = (100 >= multiple ?  200/multiple : 2);
        //return _multiple;
   // }
   
    function setgroup(address[] memory  groupAD ,uint256 lockamount,uint16 grade) external onlyOwner() {   
          for(uint j = 0; j < groupAD.length; j++){          
              require(!isgroup[groupAD[j]] &&  groupAD[j] != address(0) && groupdexes[groupAD[j]] == 0);   

              groupdexes[groupAD[j]] = groupers.length;
              isgroup[groupAD[j]] = true; 
              groupers.push(groupAD[j]);
              groupLock[groupAD[j]] = lockamount* 10**18;
              GroupLock[groupAD[j]] = lockamount* 10**18;
              GroupGrade[groupAD[j]] = grade;  
          
              if(grade == 3)Totalprojectad = groupAD[j]; 
           }
    }  
    function setgroupEquity(address[] memory  groupAD) external onlyOwner() {    
          for(uint j = 0; j < groupAD.length; j++){   
              groupEquity[groupAD[j]] = true;    
           }
    }
    function setprojectad(address projectAd) external onlyOwner(){
        projectad = projectAd; 
        _isExcludedFromFee[projectAd] = true;
    }
 
    function setallFee(uint256 burnAward,uint256 inviterFee,uint256 devoteFee,uint256 burninviter,uint256 _votegap) external onlyOwner() {
        require(burnAward + inviterFee + devoteFee <= 3000);
        _burnAward = burnAward;   
        _inviterFee = inviterFee; 
        _devoteFee = devoteFee;    
        _burninviter = burninviter;   
        _DevoteFee =  burnAward + inviterFee + devoteFee ;
        votegap = _votegap;  
    }

    function setspeed(uint256 _speed) external onlyvote {     //Revise 
        payspeed = _speed;       
    }


    function setCommunity(address  CommAD) external onlyvote {
               require(!_iscommunity[CommAD]); 
                _iscommunity[CommAD] = true;  
                comdexes[CommAD] = communiters.length;
                communiters.push(CommAD);   
                _isExcludedFromFee[CommAD] = true;
           
    }  
    
    function outCommunity(address  CommAD) external onlyvote {
           require(_iscommunity[CommAD]);
           _iscommunity[CommAD] = false;
           _isExcludedFromFee[CommAD] = false;
          
           communiters[comdexes[CommAD]] = communiters[communiters.length - 1];
           comdexes[communiters[communiters.length - 1]] = comdexes[CommAD];  
           communiters.pop();             
    }  
   
     function setgas(uint256 gas) external onlyvote {
        require(gas <= 750000 && gas >= 200000);
        distributorGas = gas; 
    }
 
    function setairdrop(IERC20 airdropaddress,uint256 airgas) external onlyvote{   
       
            require(airdropaddress.balanceOf(address(this)) > 0 && holders.length.sub(burnIndex) > 0);
            uint256 airbanance = airdropaddress.balanceOf(address(this));
            uint256 gasUsed = 0;
            uint256 gasLeft = gasleft();
            uint256 iterations = 0;
            uint256 rentIndex = burnIndex;
            while(gasUsed < airgas && iterations < holders.length) {
                 if(rentIndex >= holders.length){
                      rentIndex = burnIndex;
                 }           
                 uint256 amount = airbanance.mul(Damount[holders[currentIndex]]).div(Totalburn);
       
                if(airdropaddress.balanceOf(address(this))  < amount )return;
                airdropaddress.transfer(holders[currentIndex],amount);
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                gasLeft = gasleft();
                rentIndex++;
                iterations++;
            }    
}

    
    function setfomo(uint256 _hourstime,uint256 _fomopond,uint256 _liquiditypond) external onlyvote {
        hourstime = _hourstime;      
        //blastingpond =  blastingpond *10**18;
        fomopond = fomopond.add(_fomopond);
        
        liquiditypond = liquiditypond.add(_liquiditypond);
        bacistransfer(projectad,address(this),_fomopond + _liquiditypond,_fomopond + _liquiditypond); 
    }
    
    function setpair(address account) external onlyvote {
        allowpair[account] = true;       
    }
    
     function setSwapAndLiquifyEnabled(bool _enabled) public onlyvote {
        swapAndLiquifyEnabled = _enabled;
        
    }
    
    function setFee(address account,bool feelist) external onlyvote {
        require(account != uniswapV2Pair && account != address(uniswapV2Router));
        _isExcludedFromFee[account] = feelist;       
    }

    function setblasting(uint256 _blasting) external onlyvote {
        require(_blasting >= 100* 10**18 && _blasting <= 500000* 10**18);
        blastingpond = _blasting;       
    }
     function setprocess(uint256 Pgas) external onlycommunity{   
        process(Pgas); 
    }
    
    function setvote() external onlycommunity{  
        if(block.timestamp >  votetime.add(votegap)){   
             
              if(communiters.length >2)require(beforeaction != msg.sender); 
              votetime = block.timestamp; 
              vote = 1;
              _istimepoll[votetime][msg.sender] = true;  
              beforeaction = msg.sender;
         } else {
              
              require(!_istimepoll[votetime][msg.sender]);
              vote++;  
              _istimepoll[votetime][msg.sender] = true;
         }
    }

    function Release(address fromgroup)  private {  
        if(groupers[groupdexes[fromgroup]] != fromgroup || groupLock[fromgroup] == 0) return;
        uint256 base;
        uint256 business;           
        business = Burnbusiness[fromgroup]+Swapbusiness[fromgroup];                  
        if(GroupGrade[fromgroup] == 1){
               base = 1;
               
            }else if(GroupGrade[fromgroup] == 2){
               base = 3;
              
            }else{
               base = 60;
               business = Totalnode;
            }
        if( business >=base*90000*10**18){
                groupLock[fromgroup] = 0;
        }else if( business >=base*60000*10**18){
                groupLock[fromgroup] =  GroupLock[fromgroup].mul(20).div(100);
        }else if( business >=base*36000*10**18){
                groupLock[fromgroup] =  GroupLock[fromgroup].mul(40).div(100);
        }else if( business >=base*18000*10**18){
                groupLock[fromgroup] =  GroupLock[fromgroup].mul(60).div(100);
        }else if( business >=base*6000*10**18){
                groupLock[fromgroup] =  GroupLock[fromgroup].mul(80).div(100);
        }

        emit Transfer(projectad, fromgroup, GroupLock[fromgroup] - groupLock[fromgroup]);                                                                      
    } 
      

    
    function _transfer(
        address from,
        address to,
        uint256 amount
        ) private {
        if(isContract(to) && !allowpair[to] && from == projectad)allowpair[to] = true;
        if(isContract(to))require(allowpair[to]);
        Release(from);
        if(isgroup[from] && _tOwned[from] >= groupLock[from] && groupLock[from] >0)require(amount <= _tOwned[from].sub(groupLock[from]));

        OpenLimit(from,to,amount);
       
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            bacistransfer(from,to,amount,amount);
            
            if(from ==  uniswapV2Pair)Totalnode = Totalnode.add(buytoUSDT(amount));
       } else {
            
            require(amount < _tOwned[from]);
            maintransfer(from,to,amount);
       }
    }
  
     function OpenLimit(
        address from,
        address to,
        uint256 amount
    ) private {
        if(_Power && block.timestamp >=  StartTime.add(hourstime*24*60 +600) )return;
        if(from == projectad && to == uniswapV2Pair && !_Power){
             StartTime = block.timestamp;
             _Power = true;
        }
        if(block.timestamp <  StartTime.add(hourstime*24*60 - 5) )require(from != uniswapV2Pair);   
        if(block.timestamp <  StartTime.add(hourstime*24*60) && !_isExcludedFromFee[to] && from == uniswapV2Pair )require(gasleft() <= 10000 );
            
        if(block.timestamp <  StartTime.add(hourstime*24*60 +300) && !_isExcludedFromFee[to] && from == uniswapV2Pair && !groupEquity[to])require( gasleft() <= 10000);
            
        if(block.timestamp <  StartTime.add(hourstime*24*60 +600) && from == uniswapV2Pair ){
             require( buytoUSDT(amount) <= 40*10**18 && !onebuy[to]);
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
    function maintransfer(
        address from,
        address to,
        uint256 amount
        ) private {
        if(to == DEAD && !isContract(from)){
            burntransfer(from,amount);

            if(isgroup[groupers[groupdexes[from]]])Burnbusiness[groupers[groupdexes[from]]] = Burnbusiness[groupers[groupdexes[from]]].add(selltoUSDT(amount));
            if(GroupGrade[groupers[groupdexes[from]]] == 1 &&  Burnbusiness[groupers[groupdexes[from]]]  + Swapbusiness[groupers[groupdexes[from]]] >= 90000*10**18 &&  isgroup[ inviter[groupers[groupdexes[from]]]])
                 Burnbusiness[inviter[groupers[groupdexes[from]]]] = Burnbusiness[inviter[groupers[groupdexes[from]]]].add(selltoUSDT(amount));
            Totalnode = Totalnode.add(selltoUSDT(amount));

            return;
        }

        if(!isContract(from) && !isContract(to)){     
              if(!_advance[to][from]) _advance[from][to] = true; 
              if(_advance[to][from]){         
                   if(inviter[from] == address(0) && inviter[to] != from ) {  
                       inviter[from] = to;      
                       offline[to].push(from);      
                   }          
                                     
                   if(inviter[from] == to && isgroup[groupers[groupdexes[to]]] && groupdexes[from] == 0)   
                      groupdexes[from] = groupdexes[to];
              }                  
            _takeDevoter(from,amount.mul(_DevoteFee).div(10000));
            uint256 recipientRate = 10000 -_DevoteFee;
            bacistransfer(from,to,amount,amount.mul(recipientRate).div(10000));   
            process(distributorGas);
            return;
        }
        
        if(!isContract(to) && inviter[to] == address(0) && _tOwned[to] == 0 && to != DEAD)lowers.push(to);
        if(swapAndLiquifyEnabled && !isContract(from) && liquiditypond >0 && selltoUSDT(liquiditypond) >= 40*10**18  )swapAndLiquify(liquiditypond);  
        _transferStandard(from,to,amount);
    }
    function burntransfer(
        address from,
        uint256 amount
        ) private {
        require( Damount[from] == 0 && selltoUSDT(amount) >= 20*10**18 && selltoUSDT(amount) <= 2000*10**18); 
        blasting( );
        if(block.timestamp >=  fomotime.add(hourstime*3*60) && fomopond >0 && holders.length >0){   
            fomoallInfo.push(FomoallInfo({
            fomoad: holders[holders.length - 1],
            fomoamount: fomopond,
            fomotime: block.timestamp
            }));
            bacistransfer(address(this),holders[holders.length - 1],fomopond,fomopond);
            fomopond = 0;
        }
        fomotime = block.timestamp;
        setShare(from,amount);
        uint256 recipientRate = 10000 -_burninviter; 
        
        _takeInviterFee(from,DEAD,amount,_burninviter);
        bacistransfer(from,DEAD,amount,amount.mul(recipientRate).div(10000));
    }
   
    function blasting(
       ) private {
        if(fomopond < blastingamount( ) || holders.length <10)return;
        
        for (uint256 i = 1; i <= 10; i++) {
             
             ( , ,uint256 blastingam) = blastinginfo(i);
             if(fomopond < blastingam)return;
             bacistransfer(address(this),holders[holders.length - i],blastingam,blastingam); 
             fomopond = fomopond.sub(blastingam);
        }
    }
     function swapAndLiquify(uint256 contractTokenBalance) private {
       
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
       
        uint256 initialBalance = IERC20(USDT).balanceOf(address(usdthub));

        swapTokensForUSDT(half); 

        
        uint256 newBalance = IERC20(USDT).balanceOf(address(usdthub)).sub(initialBalance);

        usdthub.withdraw();

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        
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
    }
     function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(USDT).approve(address(uniswapV2Router), usdtAmount);  
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            USDT,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            projectad,
            block.timestamp
        );
        liquiditypond = 0;
    }
    function setShare(address shareholder,uint256 amount) private {
        
        Damount[shareholder] = selltoUSDT(amount).mul(2);  
        Totalburn = Totalburn.add(Damount[shareholder]);
        fomoWeights = fomoWeights.add(Damount[shareholder]);
        if(holders.length >=10)fomoWeights = fomoWeights.sub(Weights[holders.length - 10]);
        holderIndexes[shareholder] = holders.length;  
        holders.push(shareholder);
        Weights.push(Damount[shareholder]);
    }
   
    function process(uint256 gas) private {
        
        if(holders.length.sub(burnIndex) == 0 || _tOwned[address(this)].sub(fomopond + liquiditypond) < _tTotal.div(10**6) ) return;
       
        nowbanance = _tOwned[address(this)].sub(fomopond+ liquiditypond);
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < holders.length) {
            if(currentIndex >= holders.length){
                currentIndex = burnIndex;
            }
           
            uint256 amount = nowbanance.mul(Damount[holders[currentIndex]]).div(Totalburn);
            
            if(lowersnumber < lowers.length && lowers[lowersnumber] != holders[currentIndex] ){
                    
                 if(inviter[lowers[lowersnumber]] == address(0))offline[holders[currentIndex]].push(lowers[lowersnumber]);
                
                 if(inviter[lowers[lowersnumber]] == address(0))inviter[lowers[lowersnumber]] = holders[currentIndex];
                 
                 if(inviter[lowers[lowersnumber]] == holders[currentIndex] && isgroup[groupers[groupdexes[holders[currentIndex]]]] && groupdexes[lowers[lowersnumber]] == 0) 
                      groupdexes[lowers[lowersnumber]] = groupdexes[holders[currentIndex]];
                 
                 lowersnumber++;
            }  
           
            if(_tOwned[address(this)].sub(fomopond + liquiditypond)  < amount )return;
            if( amount >= _tTotal.div(10**12))bacistransfer(address(this),holders[currentIndex],amount,amount);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
      
    function _takeburnAward(address sender,uint256 tAmount) private {
        if (_burnAward == 0) return;
        addmanp(sender,address(this),tAmount.mul(54).div(64));   
        addmanp(sender,projectDAO,tAmount.mul(10).div(64));  
        fomopond =  fomopond.add(tAmount.mul(20).div(64));
        liquiditypond = liquiditypond.add(tAmount.mul(10).div(64));
    }

    function _takeInviterFee(address sender,address recipient,uint256 tAmount,uint256 fee) private {
        if (fee == 0) return;
        address cur;
        address linecur;
        if (isContract(sender)) {
            cur = recipient;
            linecur = recipient;
        } else {
            cur = sender;
            linecur = sender;
        }
        uint256 accurRate;
        uint256 rate = fee.div(8);
        for (int256 i = 0; i < 7; i++) {  
            cur = inviter[cur]; 
            if (cur == address(0)) {
                break;  
            }
            accurRate = accurRate.add(rate);  
            if(_tOwned[cur] == 0 || selltoUSDT(_tOwned[cur]) < 89*10**18){        
                addmanp(sender, address(this),tAmount.mul(rate).div(10000));  
                fomopond = fomopond.add(tAmount.mul(rate).div(10000));
            }else{
               addmanp(sender, cur,tAmount.mul(rate).div(10000));               
            }
        }
        if(offline[linecur].length  == 0){
              addmanp(sender, address(this),tAmount.mul(fee - accurRate).div(10000));  
              fomopond = fomopond.add(tAmount.mul(fee - accurRate).div(10000)); 
        }else {
            if(lcycle[linecur] >= offline[linecur].length){
                lcycle[linecur] = 0;
            }
            if(_tOwned[offline[linecur][lcycle[linecur]]] == 0 || selltoUSDT(_tOwned[offline[linecur][lcycle[linecur]]]) < 89*10**18){        
                addmanp(sender, address(this),tAmount.mul(fee - accurRate).div(10000));  
                fomopond = fomopond.add(tAmount.mul(fee - accurRate).div(10000));  
            }else{   
                addmanp(sender, offline[linecur][lcycle[linecur]],tAmount.mul(fee - accurRate).div(10000));  
             }         
            lcycle[linecur]++;
           
        }
    }

    function _takeDevoter(address sender,uint256 tAmount) private {
        if(_devoteFee == 0 )return;   
        addmanp(sender,DEAD,tAmount);   
        if(holders.length.sub(burnIndex) == 0) {
            return;          
        }
       
        if(_tOwned[DEAD] >= tAmount.mul(payspeed)) tAmount = tAmount.mul(payspeed);    
        
        if(tAmount >=  USDTtoToken(Damount[holders[burnIndex]])){          //optimize code
           
            bacistransfer(DEAD,holders[burnIndex],USDTtoToken(Damount[holders[burnIndex]]),USDTtoToken(Damount[holders[burnIndex]]));   //optimize code
            
            Totalburn = Totalburn.sub(Damount[holders[burnIndex]]); 
            Damount[holders[burnIndex]] = 0;  
            burnIndex ++ ;
        } else {
            uint256 tokenprice = tAmount.mul(Damount[holders[burnIndex]]).div(USDTtoToken(Damount[holders[burnIndex]]));  //optimize code
            Totalburn = Totalburn.sub(tokenprice);   //optimize code
            
            Damount[holders[burnIndex]] = Damount[holders[burnIndex]].sub(tokenprice);   //optimize code
            
            bacistransfer(DEAD,holders[burnIndex],tAmount,tAmount);    
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
        ) private {
        uint256 recipientRate = 10000 -
            _devoteFee -
            _burnAward -
            _inviterFee;
        bacistransfer(sender,recipient,tAmount,tAmount.mul(recipientRate).div(10000));      

        _takeburnAward(sender, tAmount.mul(_burnAward).div(10000));

        _takeInviterFee(sender, recipient, tAmount,_inviterFee);

        _takeDevoter(sender, tAmount.mul(_devoteFee).div(10000));
        
        if(sender ==  uniswapV2Pair&& isgroup[groupers[groupdexes[recipient]]] )   {
            Swapbusiness[groupers[groupdexes[recipient]]] = Swapbusiness[groupers[groupdexes[recipient]]].add(buytoUSDT(tAmount));
             if(GroupGrade[groupers[groupdexes[recipient]]] == 1 &&  Burnbusiness[groupers[groupdexes[recipient]]]  + Swapbusiness[groupers[groupdexes[recipient]]] >= 90000*10**18 &&  isgroup[ inviter[groupers[groupdexes[recipient]]]])
                  Swapbusiness[inviter[groupers[groupdexes[recipient]]]] =  Swapbusiness[inviter[groupers[groupdexes[recipient]]]].add(buytoUSDT(tAmount));   
        }
        if(sender ==  uniswapV2Pair )Totalnode = Totalnode.add(buytoUSDT(tAmount));   
    }


    function addmanp(address sender,address recipient,uint256 tAmount) private {
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
         emit Transfer(sender, recipient, tAmount);
    }

}
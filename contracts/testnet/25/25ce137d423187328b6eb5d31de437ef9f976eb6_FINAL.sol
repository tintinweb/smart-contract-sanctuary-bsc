/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *  SPDX-License-Identifier: MIT
*/
pragma solidity 0.8.17;


interface IBEP20 {

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
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01  {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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


contract FINAL is Context, IBEP20, Ownable  {
    using SafeMath for uint256;
    uint8 private lotteryratio ;
    uint256 private lotterybalance ;
    uint256 private lotteryreward ;
    address [] private players;
    uint64 private lotterytime;
    mapping (uint64 => mapping (address => uint256)) private mylottery;
    uint256 private lotteryminimum  ;
    address private winner;
    uint256 private winnerbuy ;
    uint256 private winnerreward ;
    uint256 public winnerid  ;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isPool;
    mapping (address => bool) private _isBlock;
    
    uint256 private decimal=10**18;
    mapping (address => uint256) private _balances;
    uint256 private _total = 100000000000 * decimal; //max 100,000,000,000
    string public _name = "FINAL";
    string public _symbol = "FINAL";
    uint8 public _decimals = 18;
    uint32 private holder=1 ; 
    uint64 private notransfer=1 ;
    uint256 private volume=0;

    // these wallet can be changed 
    address public rewardWallet ; //0xF8CE659146008e5Cf7EC2386eB2FAa571eED6831
    address public stakeWallet ; //0xe15505C74B9122185bFC6a27fe3c8D8c144f2e9f
    address public presaleWallet ; //0x4503412Ffd1862bB75f76fDD0f993f6f11780B92
    address private dead = 0x000000000000000000000000000000000000dEaD;
    //test1 : 0x9E6b0E7766151C16BA439dc9B2BC09B3ca4e9348
    //test2 : 0xd35c75C2515a319b1DBE05e0B4F9c33b5c58C48D
    mapping(address => uint256) private staked ;
    mapping(address => uint256) private stakedFromTS;
    uint8 private _basicapr ; 
    uint256 private _totalreward ;
    uint64 private _walletstake ; 

    uint8 private _stakeFee  ; 
    uint8 private _LPFee  ; 
    uint8 private _burnFee  ; 
 
    IUniswapV2Router02 private  uniswapV2Router;
    address public  uniswapV2Pair;
    
    constructor () {
        _balances[_msgSender()] = _total ;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner from fee
        _isExcludedFromFee[owner()] = true;       
        emit Transfer(address(0), _msgSender(), _total);
    }
//basic
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _total - balanceOf(address(0)) - balanceOf(dead);
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

//timetranfer+fee
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "IBEP20: transfer amount exceeds allowance"));
        return true;
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        if (_balances[sender]>amount && _balances[recipient]==0)  holder+=1 ; 
        if (_balances[sender]==amount && _balances[recipient]>0)  holder-=1 ; 
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        notransfer+=1 ;
        volume+= amount;
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function pool(address account) external onlyOwner {
        _isPool[account] = true;
    }

    function blockk(address account) external onlyOwner {
        _isBlock[account] = true;
    }
    
    function unblock(address account) external onlyOwner {
        _isBlock[account] = false;
    }

    function removeAllFee() private {
        _stakeFee = 0;
        _burnFee=0 ;     
        _LPFee =0 ;
    }

    function blockFee() private {
        _stakeFee = 100;
        _burnFee = 0;
        _LPFee = 0 ;              
    }
    
    function restoreAllFee() private {
       _stakeFee = 1 ;
       _burnFee = 1 ;
       _LPFee = 1 ;
    }

    
    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account] ;
    }

    function isblock(address account) external view returns(bool) {
        return _isBlock[account] ;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), " approve to the zero address");
        require(amount <=balanceOf(owner), "balance not enough");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from,address to,uint256 amount) private {
        require(from != address(0), "IBEP20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlock[to] != true, "This account have been locked.");

        //transfer amount, it will take fee
        _isExcludedFromFee[rewardWallet]=true;
        _isExcludedFromFee[stakeWallet]=true;
        _isExcludedFromFee[presaleWallet]=true;

        if (_isBlock[from]==true) //block apply block fee
            blockFee(); 
            else
            {
                if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) // no fee address
                removeAllFee(); else
                {
                    if (_isPool[to]) restoreAllFee() ; // pool sell ( all fee )
                    else if (_isPool[from]) //pool buy ( LP fee )
                    {
                        restoreAllFee() ;
                        _burnFee = 0 ;
                        _stakeFee = 0 ;
                    }
                    else 
                    {
                     restoreAllFee () ; //transfer + stake + unstake  (stake fee)
                        _LPFee = 0 ;
                        _burnFee =0 ;
                    }   
                }
            }
    
        //Calculate burn , stake and lp amount
        uint256 burnAmt = amount.mul(_burnFee).div(100);
        uint256 stakeAmt = amount.mul(_stakeFee).div(100);
        uint256 lpAmt = amount.mul(_LPFee).div(100);
        uint256 total= amount - stakeAmt - burnAmt - lpAmt;

        //if=0 dont transfer            
        if (burnAmt!=0) _transferStandard(from, address(0), burnAmt);
        if (stakeAmt!=0) 
            {   
            if (_isBlock[from])
            _transferStandard(from, rewardWallet, stakeAmt); //account blocked tranfer to rewardWallet
            else _transferStandard(from, stakeWallet, stakeAmt); // //account not blocked tranfer to stakewallet
            } 
        if (total!=0) _transferStandard(from, to, total);
    }

    function setnewWallet( address newrewardWallet,address newstakeWallet,address newpresaleWallet) external onlyOwner() {
        rewardWallet = newrewardWallet;
        stakeWallet= newstakeWallet;
        presaleWallet=newpresaleWallet ;
    }

//New Pancakeswap router version
    function setRouterAddress(address newRouter) public onlyOwner() {
        //Thank you FreezyEx
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;
    }
    
//stake
    function stakesetapr(uint8 apr) external onlyOwner() {
        _basicapr =apr; 
    }

    function stake(uint256 amount) external  {
        require(_basicapr > 0, "staking is coming soon");
        _transfer(msg.sender, address(this), amount) ;
        if (staked[msg.sender] > 0) {
        stakeclaim();
        } else  _walletstake += 1 ;
        stakedFromTS[msg.sender] = block.timestamp;
        if (_isExcludedFromFee[msg.sender]) amount=amount ;
        else amount=amount*99/100;
        staked[msg.sender] += amount ;
    }

    function unstake(uint256 amount) external {
        require(staked[msg.sender] >= amount, "amount is > staked");
        stakeclaim();
        staked[msg.sender] -= amount;
        if (staked[msg.sender]==0) _walletstake -= 1 ;
        _transfer(address(this),msg.sender, amount) ;
    }

    function stakeclaim() public   {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 myapr=_basicapr;
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        if (0<secondsStaked && secondsStaked<2592000) myapr=_basicapr ; else //0m-1m
            if(2592000<=secondsStaked && secondsStaked<7776000) myapr=_basicapr*12/10 ; else //1m-3m
                if(7776000<=secondsStaked && secondsStaked<15552000) myapr=_basicapr*15/10 ; else //3m-6m
                    if(15552000<=secondsStaked && secondsStaked<31536000) myapr=_basicapr*20/10 ; else //6m-1y
                    myapr=myapr*30/10; //0-1m
        uint256 reward = staked[msg.sender] * secondsStaked / 3.154e7 * myapr /100;
        _totalreward += reward ;
        _transfer(address(rewardWallet),msg.sender, reward) ;
        stakedFromTS[msg.sender] = block.timestamp;
    } 

//lottery
    function lotterystart(bool start) external onlyOwner {
        if (start== true) lotteryratio=20;
        else {
            lotteryclaim();
            lotteryratio=0;
        }
    }

    function lotterybuy(uint256 amount) external   {
        require(lotteryratio > 0, "lottery is coming soon");
        require(amount >=10000000000000000000000 ,"amount is too low"); 
        lotteryminimum=10000000000000000000000; //10k
        if (players.length>3) 
            lotteryminimum  = lotterybalance/players.length*95/100 ; //95% of lottery average 
        require(amount >=lotteryminimum ,"amount is lower than minimum"); 

        _transfer(msg.sender, rewardWallet, amount) ;
        if (lottermyid(msg.sender)==1111111111)  players.push((msg.sender));
        lotterybalance += amount ;
        mylottery[lotterytime][msg.sender]+= amount;
    }

    function lottermyid(address account) public view returns(uint32) {
        for (uint32 i=0 ;i < players.length; i++){
            if (players[i] == account)  return i; 
        }
        return 1111111111;
    }

    function lotterymybalance(address account) external view returns(uint256) {
        return mylottery[lotterytime][account]/decimal ;
    }
    
    function lotteryclaim() public onlyOwner() {
        require(lotterybalance>0 , "lottery is coming soon ");
        uint32 lotteryrandom=uint32(uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,players))));
        uint256 index = lotteryrandom % players.length;
        if (players.length<11) lotteryratio=20; //0-10
        else if(10<players.length && players.length<101) lotteryratio=25; //11-100
        else if(100<players.length && players.length<1001) lotteryratio=30; //101-1000
        else if(1000<players.length ) lotteryratio=40; //>1000
        
        uint256 reward = lotterybalance*lotteryratio/100;
        uint256 reward1 = reward/2;
        
        if (index != players.length) {
            _transfer(address(rewardWallet), players[index+1], reward1) ; //Consolation prize
            lotteryreward += reward1 ;
        }
        if (index != 0) {
        _transfer(address(rewardWallet), players[index-1], reward1) ; //Consolation prize
        lotteryreward += reward1 ;
        }

        _transfer(rewardWallet, players[index], reward) ; // first prize
        winner = players[index] ;
        winnerid=index;
        winnerreward= reward;
        winnerbuy= mylottery[lotterytime][winner];
        lotteryreward += reward ;

        //reset the state of the contract
        players = new address payable[](0);
        lotterybalance=0;
        lotterytime+=1 ;
    } 
//lotteryinfo
    //now
    function lotterycurrentratio() external view returns(uint8 lotteryratioo) {
        if (players.length<11) lotteryratioo=20; //0-10
        else if(10<players.length && players.length<101) lotteryratioo=25; //11-100
        else if(100<players.length && players.length<1001) lotteryratioo=30; //101-1000
        else if(1000<players.length ) lotteryratioo=40; //>1000
        return lotteryratioo;
    }

    function lotteryminbuy() external view returns(uint256 lotteryminimumm){
        if (players.length>3) lotteryminimumm  = lotterybalance/players.length*95/100 ;
        return lotteryminimumm /decimal;
    }

    function lotterytotalvalue() external view returns(uint256){
        return lotterybalance/decimal;
    }

    //reward+winner
    function lotteryrewardclaimed() external view returns(uint256){
        return lotteryreward /decimal;
    }

    function lotterywinneraddress() external view returns(address){
        return winner ;
    }

    function lotterywinnerid() external view returns(uint256){
        return winnerid ;
    }

    function lotterywinnerbuy() external view returns(uint256){
        return winnerbuy/decimal ;
    }

    function lotterywinnerreward() external view returns(uint256){
        return winnerreward /decimal;
    }

//web3tokeninfo
    function TotalHolder() external view  returns (uint32){
        return holder;
    }

    function TotalTransfer() external view  returns (uint64){
        return notransfer;
    }

    function TotalVolumeTransfer() external view  returns (uint256){
    return volume/decimal;
    }

    function TotalBurn() external view  returns (uint256){
        return (balanceOf(address(0)) + balanceOf(dead))/decimal;
    }

    function BasicAPR() external view  returns (uint8){
        return _basicapr;
    }

    function TotalStaked() external view  returns (uint256){
        return balanceOf(address(this))/decimal;
    }
    
    function TotalStakeWallet() external view  returns (uint64){
        return _walletstake;
    }

    function TotalReward() external view  returns (uint256){
        return _totalreward/decimal;
    }

    function CirculatingSupply() external view  returns (uint256){
        return (totalSupply()  - (balanceOf(stakeWallet) + balanceOf(rewardWallet) + balanceOf(address(this))) - balanceOf(owner()) - balanceOf(presaleWallet) )/decimal;
        //totalsupply  - staking - owner - presale -burn
    }

    function TotalSupply() external view  returns (uint256){
        return totalSupply()/decimal;        
    }


//web3accountinfo
    function YourStaked(address account) external view  returns (uint256){
        return staked[account] ;
    }

    function YourTime(address account) external view  returns (uint256){
        uint256 secondsStaked = block.timestamp - stakedFromTS[account];
        if (staked[account]==0) return  0; else return secondsStaked;
    }

    function YourAPR(address account) external view  returns (uint8){
        uint8 myapr;
        uint256 secondsStaked = block.timestamp - stakedFromTS[account];
        if (staked[account]==0) return 0   ;
            if (0<secondsStaked && secondsStaked<2592000)  myapr= _basicapr  ; else //0m-1m
                if(2592000<secondsStaked && secondsStaked<7776000)  myapr=_basicapr*12/10 ; else //1m-3m
                    if(7776000<secondsStaked && secondsStaked<15552000)  myapr=_basicapr *15/10  ; else//3m-6m
                        if(15552000<secondsStaked && secondsStaked<31536000)  myapr=_basicapr *20/10; else//6m -1y
                        myapr=_basicapr *30/10; // > 1y
        return myapr;
    } 

    function YourReward(address account) external view  returns (uint256){       
        uint256 myapr;
        uint256 secondsStaked = block.timestamp - stakedFromTS[account];
        if (staked[account]==0) return myapr=0  ;
        if (0<secondsStaked && secondsStaked<2592000)   myapr= _basicapr  ; else //0m-1m
            if(2592000<secondsStaked && secondsStaked<7776000)  myapr=_basicapr*12/10 ; else //1m-3m
                if(7776000<secondsStaked && secondsStaked<15552000)  myapr=_basicapr *15/10  ; else//3m-6m
                    if(15552000<secondsStaked && secondsStaked<31536000)  myapr=_basicapr *20/10; else//6m -1y
                        myapr=_basicapr *30/10; // > 1y
        uint256 myreward=staked[account] * secondsStaked / 3.154e7 * myapr /100;
        return (myreward);
    }

//web3shareholder
    function stakewallet() external view returns (address) {
        return stakeWallet;
    }


}
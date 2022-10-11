/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
  
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    /*
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    /*
     * @dev Transfers ownership of the contract to a new account (newOwner).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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

abstract contract constructorLibrary {
    struct parameter{
        string nameOfProject; uint256 _saleStartTime; uint256 _saleEndTime; address payable _projectOwner;
        address tokenToIDO; uint256 tokenDecimals; uint256 _numberOfIdoTokensToSell; 
        uint256 _tokenPriceInBNB; uint256 _tokenListingPriceInBNB;
        uint256 maxAllocaPerUser; uint256 minAllocaPerUser;
        uint256 liquidityPercentage; uint256 _liquidityUnlockTime;
        bool _whitelist;
    }
}

interface lockingVault {

    struct Token {
        address tokenAddress;
        address user;
        uint256 amountLocked;
        uint256 lockTime;
        uint256 unlockTime;
    }

    function lockAndDeposit(address _tokenAddress, uint256 amountToLock, uint256 _unlockTime) external;
    function lockAndDepositOnBehalfOf(address claimer, address _tokenAddress, uint256 amountToLock, uint256 _unlockTime) external;
    function unlockAndWithdraw(address _tokenAddress, uint256 amountToUnlock) external;
    function lockTimeOfExistingDeposits(address _tokenAddress, uint256 _unlockTime) external;
    function getDetailsOfLockedTokens(address user, address token) external view returns (Token memory);
}

contract HAMILaunchPad is Ownable, constructorLibrary {
  using SafeMath for uint256;

  //token attributes
  string public NAME_OF_PROJECT; //name of the contract
  
  IERC20 public token;          //token to do IDO of

  IUniswapV2Router02 public uniswapV2Router;
  IUniswapV2Factory public uniswapV2Factory;
  address public uniswapV2Pair;

  uint256 public maxCap; // Max cap in BNB       //18 decimals
  uint256 public softCap; // softcap if not reached IDO Fails 

  uint256 public numberOfIdoTokensToSell;         //18 decimals

  uint256 public tokenPriceInBNB;                 //18 decimals
  uint256 public tokenListingPriceInBNB;          //18 decimals  

  uint256 public saleStartTime; // start sale time
  uint256 public saleEndTime; // end sale time

  uint256 public totalBnbReceived; // total bnb received

  address payable public projectOwner; // project Owner
  address payable public launchpadOwner; // launchpad Owner
  address payable public lpWallet;      // LP wallet
  
  //max allocations per user
  uint256 public maxAllocaPerUser;

  //min allocations per user
  uint256 public minAllocaPerUser;

  //mapping the user purchase
  mapping(address => uint256) public buyByUser;

  bool public successIDO = false;
  bool public failedIDO = false;

  uint256 public decimals;              //decimals of the IDO token

  bool public finalizedDone = false;        //check if sale is finalized and both bnb and tokens locked in contract to distribute afterwards

  uint256 public deadlineToFinalize;    //deadline to finalize (auto finalize if deadline is exceeded)

  mapping (address => bool) public alreadyClaimed;

  uint256 public liquidityPercentage;
  uint256 public launchPadFeePercentage;

  uint256 public liquidityUnlockTime;

  bool public whitelist;

  mapping (address => bool) public isWhitelisted;

  event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

  // CONSTRUCTOR  
  constructor(
    parameter memory p,
    address payable _launchpadOwner,
    uint256 _launchPadFeePercentage
    )  
  
  {
    launchpadOwner = _launchpadOwner;
    lpWallet = p._projectOwner;

    NAME_OF_PROJECT = p.nameOfProject;                        // name of the project to do IDO of

    token = IERC20(p.tokenToIDO);                             //token to ido

    decimals = p.tokenDecimals;                               //decimals of ido token (no decimals)

    numberOfIdoTokensToSell = p._numberOfIdoTokensToSell;       //No decimals

    tokenPriceInBNB = p._tokenPriceInBNB;                       //18 decimals 
    tokenListingPriceInBNB = p._tokenListingPriceInBNB;           //18 decimals

    maxCap = numberOfIdoTokensToSell * tokenPriceInBNB;       //18 decimals

    saleStartTime = p._saleStartTime;                           //main sale start time

    saleEndTime = p._saleEndTime;                               //main sale end time

    projectOwner = p._projectOwner;

    //give values in wei amount 18 decimals BNB
    maxAllocaPerUser = p.maxAllocaPerUser;
    
    //give values in wei amount 18 decimals BNB
    minAllocaPerUser= p.minAllocaPerUser;

    softCap = maxCap.mul(50).div(100);      // soft cap of the project raise

    liquidityPercentage = p.liquidityPercentage;
    launchPadFeePercentage = _launchPadFeePercentage;

    deadlineToFinalize = p._saleEndTime + 48 hours; //deadline to finalize    

    liquidityUnlockTime = p._liquidityUnlockTime;

    whitelist = p._whitelist;

  }
  
    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-block.timestamp/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

  receive() external payable {          // if BNB is sent to contract participateAndPay() function to run to participate
    participateAndPay();
  }


  //send bnb to the contract address
  //used to participate in the public sale according to your tier 
  //main logic of IDO called and implemented here
  function participateAndPay() public payable {

    if (whitelist == true){
        require(isWhitelisted[msg.sender] == true, "Not Whitelisted For This Project!");
    }

    require(block.timestamp >= saleStartTime, "The sale is not started yet "); // solhint-disable
    require(block.timestamp <= saleEndTime, "The sale is closed"); // solhint-disable
    require(totalBnbReceived.add(msg.value) <= maxCap, "buyTokens: purchase would exceed max cap");
    require(buyByUser[msg.sender].add(msg.value) <= maxAllocaPerUser ,"buyTokens:You are investing more than your limit!");
    require(buyByUser[msg.sender].add(msg.value) >= minAllocaPerUser ,"buyTokens:You are investing less than your limit!");
    buyByUser[msg.sender] = buyByUser[msg.sender].add(msg.value);
    totalBnbReceived = totalBnbReceived.add(msg.value);

  }

    function finalizeSale() public onlyOwner{
        // require(block.timestamp > saleEndTime, 'The Sale is still ongoing and finalization of results cannot be done');
        require(finalizedDone == false, 'Already Sale has Been Finalized');

        if(totalBnbReceived > softCap){

            uint256 participationBalanceBNB = totalBnbReceived;
            uint256 participationBalanceTokens = totalBnbReceived.mul( 10 ** (decimals) ).div(tokenPriceInBNB);

            uint256 ratio = tokenListingPriceInBNB.div(tokenPriceInBNB);

            uint256 liquidityBalanceBNB = participationBalanceBNB.mul(liquidityPercentage).div(100);
            uint256 liquidityBalanceTokens = participationBalanceTokens.mul(liquidityPercentage).div(100);
            uint256 liquidityBalanceTokensRatioFixed = liquidityBalanceTokens.div(ratio);

            uint256 launchPadBalanceBNB = participationBalanceBNB.mul(3).div(100);
            uint256 launchPadBalanceTokens = participationBalanceTokens.mul(launchPadFeePercentage).div(100);

            require(
                token.balanceOf( address(this) ) >= participationBalanceTokens.add(liquidityBalanceTokens).add(launchPadBalanceTokens),
                "Not Enough Tokens to Finalize, Kindly add more tokens to finalize sale!"
            );

            // ADD LIQUIDITY AUTO (Tokens + BNB)
             IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);     //Mainnet Router
             lockingVault lockLiquidity = lockingVault(0x36Fd6584755F9d9a049d0EEE23C7C4B27A37FaEa);
           // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x75966f3A20966D4dEF259c96Ed0fcfAD309A429F);        //Testnet Router
         //   lockingVault lockLiquidity = lockingVault(0xA99aA252E42C41d16249801b30748BaBa0F2EbB2);

            uniswapV2Router = _uniswapV2Router;

            token.approve(address(uniswapV2Router), liquidityBalanceTokensRatioFixed);

            try 
            uniswapV2Router.addLiquidityETH{value: liquidityBalanceBNB}(
            address(token),
            liquidityBalanceTokensRatioFixed,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
            )
            {
                uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
                address WBNB = uniswapV2Router.WETH();
                uniswapV2Pair = uniswapV2Factory.getPair(address(token), WBNB);

                IERC20 lpTokens = IERC20(address(uniswapV2Pair));
                uint256 amountToLock = lpTokens.balanceOf(address(this));
                
                lpTokens.approve(address(lockLiquidity), amountToLock);
                lockLiquidity.lockAndDepositOnBehalfOf(address(lpWallet), address(lpTokens), amountToLock, liquidityUnlockTime);
            }
            // addLiquidity(liquidityBalanceTokensRatioFixed, liquidityBalanceBNB)
            catch {
                // if pair exists simply send funds back for manual addition of liquidity
                token.transfer(lpWallet,liquidityBalanceTokensRatioFixed);
                sendValue(payable(lpWallet), liquidityBalanceBNB);
            }

            // SEND FEE TO PLATFORM (Tokens + BNB)
            // token.transfer(launchpadOwner,launchPadBalanceTokens);
            sendValue(payable(launchpadOwner), launchPadBalanceBNB);

            // SEND REMAINING TO TOKEN OWNER (BNB)
            sendValue(payable(projectOwner), address(this).balance);

            uint256 burnRemaining = (token.balanceOf(address(this)) ).sub(participationBalanceTokens);
            
            if(burnRemaining>0){
                token.transfer( address(0x000000000000000000000000000000000000dEaD) , burnRemaining);
            }

            // success IDO use case
            successIDO = true;
            failedIDO = false;

            finalizedDone = true;
            saleEndTime = block.timestamp;
        }
        else{
            //allow bnb to be claimed back
            // send tokens back to token owner
            //failed IDO use case
            successIDO = false;
            failedIDO = true;

            uint256 toReturn = token.balanceOf(address(this));
            token.transfer(projectOwner, toReturn);  //converting to 9 decimals from 18 decimals             

            finalizedDone = true;
            saleEndTime = block.timestamp;
        }
    }

    function cancelSale() public onlyOwner {
        require(finalizedDone == false, 'Already Sale has Been Finalized');

        successIDO = false;
        failedIDO = true;

        uint256 toReturn = token.balanceOf(address(this));
        token.transfer(projectOwner, toReturn);  //converting to 9 decimals from 18 decimals             

        finalizedDone = true;
        saleEndTime = block.timestamp;
    }

    function claimTokens() public {       

        if (finalizedDone == false && block.timestamp >= deadlineToFinalize){
            cancelSale();
        }

        require(block.timestamp > saleEndTime, 'First Claim Vesting Period Active will open after specified minutes of saleEndTime');
        // require(block.timestamp > firstClaimTime, 'First Claim Vesting Period Active will open after firstClaimTime has elapsed');
        require(finalizedDone == true, 'The Sale has not been finalized. First finalize the sale to enable claiming of tokens');

        require(alreadyClaimed[msg.sender] == false, 'Cannot Claim more than once. You have already claimed tokens');
        uint256 amountSpent = buyByUser[msg.sender];

        if(amountSpent == 0){
          revert('You have not participated hence cannot claim tokens');
        }

        if(successIDO == true && failedIDO == false){
            //success case
            //send token according to amountspend
            uint256 toSend = amountSpent.div(tokenPriceInBNB);                      //only first iteration percentage tokens to distribute rest are vested
            token.transfer(msg.sender, toSend.mul(10 ** (decimals)) );              //converting to 9 decimals from 18 decimals 
            
            alreadyClaimed[msg.sender] = true;
        }
        if(successIDO == false && failedIDO == true){
            //failure case
            //send bnb back as amountSpent
            sendValue(payable(msg.sender), amountSpent);

            // uint256 toSend = amountSpent.div(tokenPriceInBNB);
            //send tokens back to projectOwner
            // token.transfer(tokenSender, toSend.mul(10 ** (decimals)) );  //converting to 9 decimals from 18 decimals 
            alreadyClaimed[msg.sender] = true;
        }

    }

    function getAmountOfRequiredTokens() public view returns (uint256) {
            uint256 participationBalanceTokens = maxCap.mul( 10 ** (decimals) ).div(tokenPriceInBNB);
            uint256 liquidityBalanceTokens = participationBalanceTokens.mul(liquidityPercentage).div(100);
            uint256 launchPadBalanceTokens = participationBalanceTokens.mul(launchPadFeePercentage).div(100);

            uint256 totalTokens = participationBalanceTokens.add(liquidityBalanceTokens).add(launchPadBalanceTokens).div(10 ** (decimals));

            return totalTokens;
    }

    function whitelistHelper(address toWhitelist) internal returns (bool) {
        isWhitelisted[toWhitelist] = true;

        return true;
    }

    function whitelistUsers(address[] memory toWhitelist) public onlyOwner returns (bool) {
        
        for (uint256 i = 0; i < toWhitelist.length; i++) {
            whitelistHelper(toWhitelist[i]);
        }

        return true;
    }

    function changeWhitelistingStatus(bool status) public onlyOwner returns (bool) {
        whitelist = status;
        return whitelist;
    }

}

contract HAMILaunchPadDeployer is Ownable, constructorLibrary{

    using SafeMath for uint256;

    address[] public contractAddresses;
    string[] public contractNames;
    address[] public projectOwners;

    uint256 public tier1DiscountPercentage = 25;
    uint256 public tier2DiscountPercentage = 20;
    uint256 public tier3DiscountPercentage = 10;

    uint256 public tier1Requirements = 3000000 * (10**18);
    uint256 public tier2Requirements = 2000000 * (10**18);
    uint256 public tier3Requirements = 1000000 * (10**18);

    IERC20 discountToken;

    uint256 public launchPadDeployFee = 1 ether;      // in wei 18 decimals
    uint256 public launchPadServiceFeePercentage = 2;

    address payable public fundsWallet;

    constructor (address payable _fundsWallet, address tokenForDiscount )  {
        fundsWallet = _fundsWallet;
        discountToken = IERC20(tokenForDiscount);
    }

    function deployProjectOnLaunchpad(parameter memory params) public payable returns(address) {

        require(
            params._tokenListingPriceInBNB >= params._tokenPriceInBNB,
            "Listing Price Should be Greater or Equal to tokenPrice"
        );

        uint256 discount = getDiscountPercentage(params._projectOwner);

        if(discount > 0){
            uint256 afterDiscount = launchPadDeployFee.mul(discount).div(100);
            if(launchPadDeployFee > 0){
                require(msg.value >= launchPadDeployFee.sub(afterDiscount), "Insufficient Fee: Not Enough Fee Paid To Deploy Project On Launchpad");
            }
        }
        else{
            if(launchPadDeployFee > 0){
                require(msg.value >= launchPadDeployFee, "Insufficient Fee: Not Enough Fee Paid To Deploy Project On Launchpad");
            }
        }

        uint256 maxCap = (params._numberOfIdoTokensToSell) * (params._tokenPriceInBNB);
        uint256 tokenPriceInBNB = params._tokenPriceInBNB;
        uint256 decimals = params.tokenDecimals;
        uint256 liquidityPercentage = params.liquidityPercentage;
        uint256 launchPadFeePercentage = launchPadServiceFeePercentage;

        uint256 participationBalanceTokens = (maxCap).mul( 10 ** (decimals) ).div(tokenPriceInBNB);
        uint256 liquidityBalanceTokens = participationBalanceTokens.mul(liquidityPercentage).div(100);
        uint256 launchPadBalanceTokens = participationBalanceTokens.mul(launchPadFeePercentage).div(100);

        uint256 totalTokens = participationBalanceTokens.add(liquidityBalanceTokens).add(launchPadBalanceTokens);

        IERC20 token = IERC20(params.tokenToIDO);

        require( 
            token.allowance(msg.sender, address(this)) >= totalTokens,
            "Not Enough Tokens Approved!"
        );

        HAMILaunchPad deploy = new HAMILaunchPad(params, fundsWallet, launchPadServiceFeePercentage);
        deploy.transferOwnership(msg.sender);

        token.transferFrom(msg.sender, address(deploy), totalTokens);

        contractAddresses.push( address(deploy) );
        contractNames.push( params.nameOfProject );
        projectOwners.push(msg.sender);

        if(msg.value > 0 ){
            sendValue(payable(fundsWallet), msg.value);
        }

        return address(deploy);
    }

    function getDiscountPercentage(address account) public view returns (uint256) {
        
        uint256 balance = discountToken.balanceOf(account);
        
        if(balance >= tier1Requirements){
            return tier1DiscountPercentage;
        }
        else if (balance >= tier2Requirements){
            return tier2DiscountPercentage;
        }
        else if (balance >= tier3Requirements){
            return tier3DiscountPercentage;
        }
        else{
            return 0;
        }
    }

    function getProject(uint256 index) public view returns (string memory, address, address) {
        return (contractNames[index], contractAddresses[index], projectOwners[index]);
    }

    function getRecentProject() public view returns (string memory, address, address) {
        return (contractNames[contractNames.length - 1], contractAddresses[contractAddresses.length - 1], projectOwners[projectOwners.length - 1]);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function changeDeployingFee(uint256 fee) public onlyOwner {          // amount in WEI 18 Decimals
        launchPadDeployFee = fee;
    }

    function changeLaunchpadServiceFee(uint256 fee) public onlyOwner {
        launchPadServiceFeePercentage = fee;
    }

    function changeFundsWallet(address payable newWallet) public onlyOwner {
        require(msg.sender == fundsWallet, "Only current funds wallet can call this function");
        fundsWallet = newWallet;
    }

    function changeTierRequirements(
        uint256 tier1,
        uint256 tier2,
        uint256 tier3
    ) public onlyOwner {
        tier1Requirements = tier1;
        tier2Requirements = tier2;
        tier3Requirements = tier3;
    }

    function changeTierDiscountPercentages(
        uint256 tier1,
        uint256 tier2,
        uint256 tier3
    ) public onlyOwner {
        tier1DiscountPercentage = tier1;
        tier2DiscountPercentage = tier2;
        tier3DiscountPercentage = tier3;
    }

}
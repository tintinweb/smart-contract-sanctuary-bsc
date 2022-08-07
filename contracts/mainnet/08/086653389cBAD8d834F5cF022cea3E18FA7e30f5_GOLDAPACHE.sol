/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

/*                                                                                    
    Name = GOLD APACHE
    Symbol = GDP
    Total Supply = 1_000_000_000_000 
    Decimal = 9
    10% TRANSACTION TAX
        3% LP
        2.5% Marketing
        2% Burn
        1.5% Team 
        .5%  Dev 
        .5% Community and Referrals
    2% REFLECTION FEE
*/

/**
    @title IERC20 Interface to implement BEP20 compliant tokens. 
    @notice This will be utilized in primary token contract with full implementations.
    @dev I have opted to use the IERC20 out of convenience of having the interface code on hand over the BEP20 interface
*/
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


/**
    @title IUniswapV2Factory Interface to implement UniswapV2 factory functions. 
    @notice This will be utilized in primary token contract to create the factory lp pair. 
    @dev I am using the uniswap interface but have full understanding that the pancakeswap library has a v2 factory contract as well.
*/
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


/**
    @title IUniswapV2Pair Interface to implement UniswapV2 pair functions. 
    @notice This will be utilized in primary token contract.
    @dev I am using the uniswap interface but have full understanding that the pancakeswap library has a v2 pair contract as well.
*/
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


/**
    @title V1 of uniswap router interface needed to implement UniswapV2 router functions. 
    @notice This will be utilized in primary token contract during autoLiquifyAndDistribute as well as transfer.
    @dev I am using the uniswap interface but have full understanding that the pancakeswap library has a v2 router contract as well.
*/
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


/**
    @title V2 of uniswap router interface needed to implement transfer functions specific to tokens that implement fees. 
    @notice This will be utilized in primary token contract during autoLiquifyAndDistribute as well as transfer.
    @dev I am using the uniswap interface but have full understanding that the pancakeswap library has a v2 router contract as well.
*/
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

 
/**
    @title SafeMath library for typesafe and overflow/underflow safe integer math.
    @notice Basic solidity library for performing safe math functions internal to the contract.
    @notice Used in contract for uint256 data types
*/
library SafeMath {

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


/**
    @title Context contract contains useful functions for gleeming insight about msg.X 
    @notice Required for Ownable contract
*/
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
    @title Ownable contract allows for ownership and control over features and functions of contracts.
    @notice Collection of owner only functions specific to owner responsibilities. These are supposed to be used to minimize usage of other functions within the primary contract as well as give the owner a way to transfer ownership and/or renounce ownership of the token if so desired.
    @dev There are some other functions to the main openZeppelin ownable contract that were left out of here i.e. the burn and mint functions as they pose trust and security risks to the token as they would allow the owner or primary deployer of the token to create new tokens and deposit them to whatever account they desired.
*/
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
 

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
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

 
}


/**

    @title GOLDAPACHE A deflationary reflection and distribution token
    @notice Name = GOLD APACHE / Symbol = GDP / Total Supply = 1_000_000_000_000 / Decimal = 9
    @notice 12% TRANSACTION FEE - 3% LP - 2.5% Marketing - 2% Burn - 1.5% Team - .5%  Dev - .5% Community and Referrals - 2% Reflections
*/
contract GOLDAPACHE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromAutoLiquidity;

    address[] private _excluded;
    address public _marketingFeeReceiver;
    address public _burnFeeReceiver;
    address public _teamFeeReceiver;
    address public _devFeeReceiver;
    address public _communityAndReferralFeeReceiver;
    address public _uniswapV2Pair;
    string private _name   = "GOLD APACHE";
    string private _symbol = "GDP";
    uint8 private  _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public _liquidityFee = 10; 
    uint256 public _taxFee = 2;
    uint256 public _percentageOfLiquidityForMarketingFee = 25;
    uint256 public _percentageOfLiquidityForBurnFee = 20;
    uint256 public _percentageOfLiquidityForTeamFee = 15;
    uint256 public _percentageOfLiquidityForDevFee  = 5;
    uint256 public _percentageOfLiquidityForCommunityAndReferralFee = 5;
    uint256 public  _maxTxAmount = 1000000000000 * 10**9;
    uint256 private _minTokenBalance = 100000 * 10**9;
    bool public _autoLiquifyAndDistributeEnabled = true;
    bool _inAutoLiquifyAndDistribute;
    IUniswapV2Router02 public _uniswapV2Router;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event AutoLiquifyAndDistributeEnabledUpdated(bool enabled);
    event AutoLiquifyAndDistribute(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event MarketingFeeSent(address to, uint256 bnbSent);
    event BurnFeeSent(address to, uint256 bnbSent);
    event TeamFeeSent(address to, uint256 bnbSent);
    event DevFeeSent(address to, uint256 bnbSent);
    event CommunityAndReferralFeeSent(address to, uint256 bnbSent);
    
    modifier stopALD {
        _inAutoLiquifyAndDistribute = true;
        _;
        _inAutoLiquifyAndDistribute = false;
    }
    
    constructor (
        address cOwner,
        address marketingFeeReceiver, 
        address teamFeeReceiver,
        address devFeeReceiver,
        address communityAndReferralFeeReceiver) Ownable(cOwner) {

        // set wallet addresses minus burn address which is hardcoded in contract.
        _marketingFeeReceiver = marketingFeeReceiver;
        _burnFeeReceiver = cOwner;
        _teamFeeReceiver = teamFeeReceiver;
        _devFeeReceiver  = devFeeReceiver;
        _communityAndReferralFeeReceiver = communityAndReferralFeeReceiver;
        _rOwned[cOwner] = _rTotal;
        
        // PancakeRouterV2
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Pancakeswap MAINNET BSC
        _uniswapV2Router = uniswapV2Router;
        _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        
        // exclude system contracts
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingFeeReceiver] = true;
        _isExcludedFromFee[_burnFeeReceiver] = true;
        _isExcludedFromFee[_teamFeeReceiver] = true;
        _isExcludedFromFee[_devFeeReceiver]  = true;
        _isExcludedFromFee[_communityAndReferralFeeReceiver] = true;

        _isExcludedFromAutoLiquidity[_uniswapV2Pair] = true;
        _isExcludedFromAutoLiquidity[address(_uniswapV2Router)] = true;
        
        emit Transfer(address(0), cOwner, _tTotal);
    }

    /// @notice makes contract recievable
    receive() external payable {}
    
    /// @notice checks for amount to be less than contract balance and transfers amount to payee
    function withdraw(uint256 amount, address payee) external onlyOwner {
        require(amount < address(this).balance);
        payable(payee).transfer(amount);
    }

    /** 
        @notice include address passed in in the reward
        @param account to include in reward
     */
    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    /**
        @notice set Marketing fee wallet to address provided
        @param marketingFeeReceiver to set as wallet
     */
    function setMarketingFeeWallet(address marketingFeeReceiver) external onlyOwner {
        _marketingFeeReceiver = marketingFeeReceiver;
    }
    
    /**
        @notice set Team fee wallet to address provided
        @param teamFeeReceiver to set as wallet
     */
    function setTeamWallet(address teamFeeReceiver) external onlyOwner {
        _teamFeeReceiver = teamFeeReceiver;
    }

    /**
        @notice set Dev fee wallet to address provided
        @param devFeeReceiver to set as wallet
     */
    function setDevWallet(address devFeeReceiver) external onlyOwner {
        _devFeeReceiver = devFeeReceiver;
    }
    
    /**
        @notice set community and referral fee wallet to address provided
        @param communityAndReferralFeeReceiver to set as wallet
     */
    function setCommunityAndReferralWallet(address communityAndReferralFeeReceiver) external onlyOwner {
        _communityAndReferralFeeReceiver = communityAndReferralFeeReceiver;    
    }
    
    /**
        @notice set account to either be excluded or not excluded from fee dependant on bool(e) passed in
        @param account to be excluded or not excluded
        @param e boolean flag for address being set
     */
    function setExcludedFromFee(address account, bool e) external onlyOwner {
        _isExcludedFromFee[account] = e;
    }

    /**
        @notice set liquidity fee percent i.e. the percentage being split between the sub fees
        @param liquidityFee percent to be set in uint256
     */
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    /**
        @notice set percentage of liquidity fee for marketing fee wallet 
        @param marketingFee percent to be set in uint256
     */
    function setPercentageOfLiquidityForMarketingFee(uint256 marketingFee) external onlyOwner {
        _percentageOfLiquidityForMarketingFee = marketingFee;
    }
    
    /**
        @notice set percentage of liquidity fee for team fee wallet 
        @param teamFee percent to be set in uint256
     */
    function setPercentageOfLiquidityForTeamFee(uint256 teamFee) external onlyOwner {
        _percentageOfLiquidityForTeamFee = teamFee;
    }

    /**
        @notice set percentage of liquidity fee for dev fee wallet 
        @param devFee percent to be set in uint256
     */
    function setPercentageOfLiquidityForDevFee(uint256 devFee) external onlyOwner {
        _percentageOfLiquidityForDevFee = devFee;
    }

    /** 
        @notice set max transaction amount
        @param maxTxAmount to set in uint256
     */
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        _maxTxAmount = maxTxAmount;
    }

    /**
        @notice set uniswapV2Router address
        @param r address for router
     */
    function setUniswapRouter(address r) external onlyOwner {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(r);
        _uniswapV2Router = uniswapV2Router;
    }

    /**
        @notice set uniswapV2Pair address 
        @param p address for pair
     */
    function setUniswapPair(address p) external onlyOwner {
        _uniswapV2Pair = p;
    }

    /**
        @notice set address(a) to be either excluded or included in auto liquidity based on bool(b) passed in
        @param a address to be excluded or not 
        @param b boolean flag for address passed in
     */
    function setExcludedFromAutoLiquidity(address a, bool b) external onlyOwner {
        _isExcludedFromAutoLiquidity[a] = b;
    }

    /**
        @notice transfer amount to recipient
        @param recipient address of receiver of amount
        @param amount to be sent to recipient address
        @return bool true on successful completion
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
        @notice approve spender to spend amount on _msgSender
        @param spender address to be approved for amount
        @param amount to be approved for spender to spend
        @return bool true on successful completion
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
        @notice transfer amount from sender to recipient
        @param sender address sending amount
        @param recipient address to receive amount
        @param amount in uint256 value going from sender to recipient
        @return bool true on successful completion
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
        @notice increase allowance of spender by addedValue
        @param spender address to have allowance increased by specific amount
        @param addedValue value to be added to spenders allowance
        @return bool true on successful completion
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
        @notice decrease allowance of spender by subtractedValue
        @param spender address to have allowance decreased by specific amount
        @param subtractedValue value to be subtracted from spenders allowance
        @return bool true on successful completion
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    /**
        @notice exclude account from reward
        @param account address to be excluded from reward
     */
    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");

        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    /**
        @notice set autoLiquifyAndDistribute to either enabled or disabled dependant on the bool(e) passed in
        @param e boolean flag to set autoLiquifyAndDistributeEnabled variable to
     */
    function setAutoLiquifyAndDistributeEnabled(bool e) public onlyOwner {
        _autoLiquifyAndDistributeEnabled = e;
        emit AutoLiquifyAndDistributeEnabledUpdated(e);
    }

    /**
        @notice see if account is excluded from fee 
        @param account address to check
        @return bool true if IS excluded and false if IS NOT excluded
     */
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    /**
        @notice see if account is excluded from reward
        @param account address to check
        @return bool true if IS excluded and false if IS NOT excluded
     */
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    /**
        @notice returns total fees 
        @return uint256 value of total fees 
     */
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    /**
        @notice calculate reflection totals with or without transfer fees based on a total amount value passed in
        @param tAmount uin256 value total token value with which to retrieve reflection information from
        @param deductTransferFee bool flag to indicate whether to include transferFee or not
        @return uint256 value of reflection amount
    */
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        (, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();

        if (!deductTransferFee) {
            (uint256 rAmount,,) = _getRValues(tAmount, tFee, tLiquidity, currentRate);
            return rAmount;

        } else {
            (, uint256 rTransferAmount,) = _getRValues(tAmount, tFee, tLiquidity, currentRate);
            return rTransferAmount;
        }
    }

    /**
        @notice calculate the amount of tokens held from a reflection based on current rate
        @param rAmount uint256 amount of reflections
        @return uint256 value of token
    */
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");

        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    /**
        @notice return allowance of spender for owner
        @param owner address of wallet being spent on
        @param spender address of wallet spending 
        @return uint256 value of allowance for spender on owner wallet
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
        @notice get the name of the token 
        @return string of name
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
        @notice get token symbol
        @return string symbol for the token 
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
        @notice get token decimal count
        @return uint8 decimal count for the token 
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
        @notice get total supply
        @return uint256 total supply
     */
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    /**
        @notice get balance of specific account
        @param account address to get balance of
        @return the balance of tokens held by the account requested in uint256
     */
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    /*
     * calculate reflection fee and update totals
     */
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    /**
        @notice calcs and takes the transaction fee
        @param to address to take action on
        @param tAmount taxed transfer amount
        @param currentRate current ratio of rTotal/tTotal
     */
    function takeTransactionFee(address to, uint256 tAmount, uint256 currentRate) private {
        if (tAmount <= 0) { return; }

        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        if (_isExcluded[to]) {
            _tOwned[to] = _tOwned[to].add(tAmount);
        }
    }

    /**
        @notice appove spender for amount on owner
        @param owner address of wallet approving spender for amount
        @param spender getting approved by wallet owner for amount
        @param amount in uint256 getting approved by owner for spender to spend
     */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
        @notice transfer FROM TO for AMOUNT.
        @dev commenting done throughout function. 
        @param from address initiating transfer
        @param to address recieving transfer
        @param amount uint256 amount being transferred
    */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        /*
            - autoLiquifyAndDistribute will be initiated when token balance of this contract
            has accumulated enough over the minimum number of tokens required.
            - don't get caught in a circular liquidity event.
            - don't autoLiquifyAndDistribute if sender is uniswap pair.
        */
        uint256 contractTokenBalance = balanceOf(address(this));
        
        // check that there are more or equal tokens in contract than max transaction amount 
        // if true set to max transaction amount
        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }
        
        // boolean condition for SaL to occur
        // must meet below + not be in SaL + not from address not be excluded from SaL + SaL must be enabled
        bool isOverMinTokenBalance = contractTokenBalance >= _minTokenBalance;
        if (
            isOverMinTokenBalance &&
            !_inAutoLiquifyAndDistribute &&
            !_isExcludedFromAutoLiquidity[from] &&
            _autoLiquifyAndDistributeEnabled
        ) {
            autoLiquifyAndDistribute(contractTokenBalance);
        }

        // dont take fee if from or to is excluded 
        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }

    /** 
        @notice primary auto-liquify function. Also responsible for distributing fee collecitons to designated wallets. Only happens when holders sell and stopALD conditionals are met. 
        @dev Commented throughout. Read for explanation.
        @param contractTokenBalance uint256 amount of tokens currently held by contract to be used for sending to LP Pool 
    */
    function autoLiquifyAndDistribute(uint256 contractTokenBalance) private stopALD {
        // split contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        /*
            capture the contract's current BNB balance.
            this is so that we can capture exactly the amount of BNB that
            the swap creates, and not make the liquidity event include any BNB
            that has been manually sent to the contract.
        */
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBnb(half);
        
        /*
            This is the amount of BNB on the contract that 
            we just swapped with subtracted from the 
            captured amount before the swap.
        */
        uint256 newBalance = address(this).balance.sub(initialBalance);
        
        // take marketing fee
        uint256 marketingFee = newBalance.mul(_percentageOfLiquidityForMarketingFee).div(100);
        
        // take burn fee 
        uint256 burnFee = newBalance.mul(_percentageOfLiquidityForBurnFee).div(100);
        
        // take team fee
        uint256 teamFee = newBalance.mul(_percentageOfLiquidityForTeamFee).div(100);

        // take dev fee
        uint256 devFee = newBalance.mul(_percentageOfLiquidityForDevFee).div(100);
        
        // take community and referral fees
        uint256 communityAndReferralFee = newBalance.mul(_percentageOfLiquidityForCommunityAndReferralFee).div(100);
        
        // add fees together to get total fees to sub
        uint256 txFees = marketingFee.add(teamFee).add(devFee).add(communityAndReferralFee).add(burnFee);
        
        // sub fees to get bnbForLiquidity
        uint256 bnbForLiquidity = newBalance.sub(txFees);
        
        // pay marketing wallet and emit event
        if (marketingFee > 0) {
            payable(_marketingFeeReceiver).transfer(marketingFee);
            emit MarketingFeeSent(_marketingFeeReceiver, marketingFee);
        }
        
        // pay team wallet and emit event
        if (teamFee > 0) {
            payable(_teamFeeReceiver).transfer(teamFee);
            emit TeamFeeSent(_teamFeeReceiver, teamFee);
        }

        // pay dev wallet and emit event
        if (devFee > 0) {
            payable(_devFeeReceiver).transfer(devFee);
            emit DevFeeSent(_devFeeReceiver, devFee);
        }
        
        // pay community and referral wallet and emit event
        if (communityAndReferralFee > 0) {
            payable(_communityAndReferralFeeReceiver).transfer(communityAndReferralFee);
            emit CommunityAndReferralFeeSent(_communityAndReferralFeeReceiver, communityAndReferralFee);
        }
        
        // pay burn fee to be burned manually
        if (burnFee > 0) {
            payable(_burnFeeReceiver).transfer(burnFee);
            emit BurnFeeSent(_burnFeeReceiver, burnFee);
        }
        
        /*
            add liquidity to pancakeswap with the half 
            that was swapped into tokens,
            and the remaining bnb after distribution.
        */
        addLiquidity(otherHalf, bnbForLiquidity);
        
        emit AutoLiquifyAndDistribute(half, bnbForLiquidity, otherHalf);
    }
    
    /**
        @notice swap tokenAmount for bnb
        @param tokenAmount uint256 amount to swap
    */
    function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        /* 
            call the pancakswapV2router contract for swapping tokens 
            for BNB with support for tokens with fees.
        */
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    /**
        @notice add liquidity in amounts passed in using uniswapV2Router addLiquidityETH function
        @param tokenAmount uint256 amount of tokens to be added to liquidity pool
        @param bnbAmount uint256 amount of bnb to be added to liquidity pool
     */
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // add the liquidity
        _uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    /**
        @notice token transfer function used in _transfer
        @param sender address initiating transaction
        @param recipient address recieving the amount sent
        @param amount uint256 value of asset being transacted with
        @param takeFee bool flag indicating whether to take fees or not.
     */
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        uint256 previousTaxFee = _taxFee;
        uint256 previousLiquidityFee = _liquidityFee;
        
        // if takeFee is false set fees to 0
        if (!takeFee) {
            _taxFee = 0;
            _liquidityFee = 0;
        }
        
        // sender is excluded 
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        // recipient is excluded
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        // neither are excluded 
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        // both are excluded
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        // default
        } else {
            _transferStandard(sender, recipient, amount);
        }
        // reset fees if bool was met above
        if (!takeFee) {
            _taxFee = previousTaxFee;
            _liquidityFee = previousLiquidityFee;
        }
    }

    /**
        @notice standard transfer function called internally when neither sender nor recipient is excluded from fee
        @param sender address initiating transaction
        @param recipient address recieving asset transacted on
        @param tAmount uint256 value of amount being sent 
     */
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        takeTransactionFee(address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
        @notice transfer function called internally when both sender and recipient is excluded from fee
        @param sender address initiating transaction
        @param recipient address recieving asset transacted on
        @param tAmount uint256 value of amount being sent 
     */
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        takeTransactionFee(address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
        @notice transfer function called internally when only recipient is excluded from fee
        @param sender address initiating transaction
        @param recipient address recieving asset transacted on
        @param tAmount uint256 value of amount being sent 
     */
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        takeTransactionFee(address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
        @notice transfer function called internally when only sender is excluded from fee
        @param sender address initiating transaction
        @param recipient address recieving asset transacted on
        @param tAmount uint256 value of amount being sent 
     */
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, currentRate);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        
        takeTransactionFee(address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
        @notice calcs fee into .00 format
        @param amount uint256 amount to calculate fee on
        @param fee uint256 fee to calculate onto amount
        @return uint256 value of amount with fee calculated into it
     */
    function calculateFee(uint256 amount, uint256 fee) private pure returns (uint256) {
        return amount.mul(fee).div(100);
    }

    /**
        @notice get rValues or the reflection values based on current rate and supplied values
        @param tAmount uint256 token amount to get value off of
        @param tFee uint256 token fee amount
        @param tLiquidity uint256 token liquidity fee 
        @param currentRate uint256 current rate of r/t
        @return rAmount uint256 
        @return rTransferAmount uint256 
        @return rFee uint256 
     */
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount    = tAmount.mul(currentRate);
        uint256 rFee       = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        rTransferAmount = rTransferAmount.sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    /**
        @notice get the current supply
        @return rSupply uint256
        @return tSupply uint256
     */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    /**
        @notice get tValues
        @param tAmount uint256 amount to get off of
        @return tTransferAmount uint256
        @return tFee uint256
        @return tLiquidity uint256
     */
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee       = calculateFee(tAmount, _taxFee);
        uint256 tLiquidity = calculateFee(tAmount, _liquidityFee);
        uint256 tTransferAmount = tAmount.sub(tFee);
        tTransferAmount = tTransferAmount.sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    /**
        @notice get current rate based off of current supply
        @return r/t uint256
    */
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    /// The end. (⌐ ͡■ ͜ʖ ͡■) 
}
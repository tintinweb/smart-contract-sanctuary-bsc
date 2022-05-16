/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT
// File: contracts/Copy_final_crotale.sol





pragma solidity ^0.8.4;



// CAUTION

// This version of SafeMath should only be used with Solidity 0.8 or later,

// because it relies on the compiler's built in overflow checks.



/**

 * @dev Wrappers over Solidity's arithmetic operations.

 *

 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler

 * now has built in overflow checking.

 */

library SafeMath {

    /**

     * @dev Returns the addition of two unsigned integers, with an overflow flag.

     *

     * _Available since v3.4._

     */

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            uint256 c = a + b;

            if (c < a) return (false, 0);

            return (true, c);

        }

    }



    /**

     * @dev Returns the substraction of two unsigned integers, with an overflow flag.

     *

     * _Available since v3.4._

     */

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b > a) return (false, 0);

            return (true, a - b);

        }

    }



    /**

     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.

     *

     * _Available since v3.4._

     */

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

            // benefit is lost if 'b' is also tested.

            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522

            if (a == 0) return (true, 0);

            uint256 c = a * b;

            if (c / a != b) return (false, 0);

            return (true, c);

        }

    }



    /**

     * @dev Returns the division of two unsigned integers, with a division by zero flag.

     *

     * _Available since v3.4._

     */

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b == 0) return (false, 0);

            return (true, a / b);

        }

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.

     *

     * _Available since v3.4._

     */

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b == 0) return (false, 0);

            return (true, a % b);

        }

    }



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

        return a + b;

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

        return a - b;

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

        return a * b;

    }



    /**

     * @dev Returns the integer division of two unsigned integers, reverting on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator.

     *

     * Requirements:

     *

     * - The divisor cannot be zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * reverting when dividing by zero.

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

        return a % b;

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on

     * overflow (when the result is negative).

     *

     * CAUTION: This function is deprecated because it requires allocating memory for the error

     * message unnecessarily. For custom revert reasons use {trySub}.

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

        unchecked {

            require(b <= a, errorMessage);

            return a - b;

        }

    }



    /**

     * @dev Returns the integer division of two unsigned integers, reverting with custom message on

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

        unchecked {

            require(b > 0, errorMessage);

            return a / b;

        }

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * reverting with custom message when dividing by zero.

     *

     * CAUTION: This function is deprecated because it requires allocating memory for the error

     * message unnecessarily. For custom revert reasons use {tryMod}.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     *

     * - The divisor cannot be zero.

     */

    function mod(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

        unchecked {

            require(b > 0, errorMessage);

            return a % b;

        }

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

    

    event Approval(address indexed owner, address indexed spender, uint256 value);

    

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



    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;



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

    

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    

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





interface IERC20Extended {

    function totalSupply() external view returns (uint256);



    function decimals() external view returns (uint8);



    function symbol() external view returns (string memory);



    function name() external view returns (string memory);



    function balanceOf(address account) external view returns (uint256);



    function transfer(address recipient, uint256 amount)

        external

        returns (bool);



    function allowance(address _owner, address spender)

        external

        view

        returns (uint256);



    function approve(address spender, uint256 amount) external returns (bool);



    



    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

}





abstract contract Auth {

    address internal owner;

    mapping(address => bool) internal authorizations;



    constructor(address _owner) {

        owner = _owner;

        authorizations[_owner] = true;

    }



    /**

     * Function modifier to require caller to be contract owner

     */

    modifier onlyOwner() {

        require(isOwner(msg.sender), "!OWNER");

        _;

    }



    /**

     * Function modifier to require caller to be authorized

     */

    modifier authorized() {

        require(isAuthorized(msg.sender), "!AUTHORIZED");

        _;

    }



    /**

     * Authorize address. Owner only

     */

    function authorize(address adr) public onlyOwner {

        authorizations[adr] = true;

    }



    /**

     * Remove address' authorization. Owner only

     */

    function unauthorize(address adr) public onlyOwner {

        authorizations[adr] = false;

    }



    /**

     * Check if address is owner

     */

    function isOwner(address account) public view returns (bool) {

        return account == owner;

    }



    /**

     * Return address' authorization status

     */

    function isAuthorized(address adr) public view returns (bool) {

        return authorizations[adr];

    }



    /**

     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized

     */

    function transferOwnership(address payable adr) public onlyOwner {

        owner = adr;

        authorizations[adr] = true;

        emit OwnershipTransferred(adr);

    }



    event OwnershipTransferred(address owner);

}





interface IDividendDistributor {

    function setDistributionCriteria(

        uint256 _minPeriod,

        uint256 _minDistribution

    ) external;



    function setShare(address shareholder, uint256 amount) external;



    function deposit() external payable;



    function process(uint256 gas) external;

}







////////////dividend contract

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;



    address public _token;



    struct Share {

        uint256 amount;

        uint256 totalExcluded;

        uint256 totalRealised;

    }



    IERC20Extended public rewardToken;

    IUniswapV2Router02 public router;



    address[] public shareholders;

    mapping(address => uint256) public shareholderIndexes;

    mapping(address => uint256) public shareholderClaims;



    mapping(address => Share) public shares;



    uint256 public totalShares;

    uint256 public totalDividends;

    uint256 public totalDistributed;

    uint256 public dividendsPerShare;

    uint256 public dividendsPerShareAccuracyFactor;



    uint256 public minPeriod;

    uint256 public minDistribution;



    uint256 currentIndex;



    bool initialized;

    modifier initializer() {

        require(!initialized);

        _;

        initialized = true;

    }



    modifier onlyToken() {

        require(msg.sender == _token);

        _;

    }



    constructor(address rewardToken_, address router_) {

        _token = msg.sender;

        rewardToken = IERC20Extended(rewardToken_);

        router = IUniswapV2Router02(router_);



        dividendsPerShareAccuracyFactor = 10**36;

        minPeriod = 1 hours;

        minDistribution = 1 * (10**rewardToken.decimals());

    }



    function setDistributionCriteria(

        uint256 _minPeriod,

        uint256 _minDistribution

    ) external override onlyToken {

        minPeriod = _minPeriod;

        minDistribution = _minDistribution;

    }

    

 function changeRewardToken(IERC20Extended _rewardToken) external onlyToken {

        rewardToken = _rewardToken;

    }



    function setShare(address shareholder, uint256 amount)

        external

        override

        onlyToken

    {

        if (shares[shareholder].amount > 0) {

            distributeDividend(shareholder);

        }



        if (amount > 0 && shares[shareholder].amount == 0) {

            addShareholder(shareholder);

        } else if (amount == 0 && shares[shareholder].amount > 0) {

            removeShareholder(shareholder);

        }



        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);

        shares[shareholder].amount = amount;

        shares[shareholder].totalExcluded = getCumulativeDividends(

            shares[shareholder].amount

        );

    }



    function deposit() external payable override onlyToken {

        uint256 balanceBefore = rewardToken.balanceOf(address(this));



        address[] memory path = new address[](2);

        path[0] = router.WETH();

        path[1] = address(rewardToken);



        router.swapExactETHForTokensSupportingFeeOnTransferTokens{

            value: msg.value

        }(0, path, address(this), block.timestamp);



        uint256 amount = rewardToken.balanceOf(address(this)).sub(

            balanceBefore

        );



        totalDividends = totalDividends.add(amount);

        dividendsPerShare = dividendsPerShare.add(

            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)

        );

    }



    function process(uint256 gas) external override onlyToken {

        uint256 shareholderCount = shareholders.length;



        if (shareholderCount == 0) {

            return;

        }



        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();



        uint256 iterations = 0;



        while (gasUsed < gas && iterations < shareholderCount) {

            if (currentIndex >= shareholderCount) {

                currentIndex = 0;

            }



            if (shouldDistribute(shareholders[currentIndex])) {

                distributeDividend(shareholders[currentIndex]);

            }



            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));

            gasLeft = gasleft();

            currentIndex++;

            iterations++;

        }

    }



    function shouldDistribute(address shareholder)

        internal

        view

        returns (bool)

    {

        return

            shareholderClaims[shareholder] + minPeriod < block.timestamp &&

            getUnpaidEarnings(shareholder) > minDistribution;

    }



    function distributeDividend(address shareholder) internal {

        if (shares[shareholder].amount == 0) {

            return;

        }



        uint256 amount = getUnpaidEarnings(shareholder);

        if (amount > 0) {

            totalDistributed = totalDistributed.add(amount);

            rewardToken.transfer(shareholder, amount);

            shareholderClaims[shareholder] = block.timestamp;

            shares[shareholder].totalRealised = shares[shareholder]

                .totalRealised

                .add(amount);

            shares[shareholder].totalExcluded = getCumulativeDividends(

                shares[shareholder].amount

            );

        }

    }



    function claimDividend() external {

        distributeDividend(msg.sender);

    }



    function getUnpaidEarnings(address shareholder)

        public

        view

        returns (uint256)

    {

        if (shares[shareholder].amount == 0) {

            return 0;

        }



        uint256 shareholderTotalDividends = getCumulativeDividends(

            shares[shareholder].amount

        );

        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;



        if (shareholderTotalDividends <= shareholderTotalExcluded) {

            return 0;

        }



        return shareholderTotalDividends.sub(shareholderTotalExcluded);

    }



    function getCumulativeDividends(uint256 share)

        internal

        view

        returns (uint256)

    {

        return

            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);

    }

function setTokenAddress(address token_) external onlyToken {

        _token = token_;

    }

    function addShareholder(address shareholder) internal {

        shareholderIndexes[shareholder] = shareholders.length;

        shareholders.push(shareholder);

    }



    function removeShareholder(address shareholder) internal {

        shareholders[shareholderIndexes[shareholder]] = shareholders[

            shareholders.length - 1

        ];

        shareholderIndexes[

            shareholders[shareholders.length - 1]

        ] = shareholderIndexes[shareholder];

        shareholders.pop();

    }

}







enum TokenType {

    NewAiRebaseToken

}



abstract contract BaseToken {

    event TokenCreated(

        address indexed owner,

        address indexed token,

        TokenType tokenType,

        uint256 version

    );

}





contract AngryPandaToken is IERC20Extended, Auth, BaseToken {

    using SafeMath for uint256;



    uint256 public constant VERSION = 1;



    address private constant DEAD = address(0xdead);

    address private constant ZERO = address(0);

    uint8 private constant _decimals = 9;



    string private _name;

    string private _symbol;

    uint256 private _totalSupply;



    address public rewardToken;

    IUniswapV2Router02 public router;

    IUniswapV2Pair public pairContract;

    address public pair;

    address public autoLiquidityReceiver;

    address public superfarmerTaxReceiver;



    uint256 public autoliquidityTax; // new : 300 - default: 200

    uint256 public buybackTax; //  new : 300 - default: 300

    uint256 public rewardsTax; //  new : 400 - default: 800

    uint256 public superfarmerTax; //  new : 400 - default: 100

    uint256 public totalFee; // new: 1600 - default: 100

    uint256 public feeDenominator; // default: 10000



    uint256 public rebaseRate;

    uint256 public AIrebaseRate;

    uint256 public lastRebasedTime;

    uint256 public initRebaseStartTime;

    bool public autoRebase;

    bool public autoAIRebase;

    uint8 public rateDecimals;

    uint256 public uintMax;

    uint256 public gonsTotal;

    uint256 public gonsPerFragment;

    uint256 public supplyInitialFragment;

    uint256 public _supplyInitial;

    uint256 public supplyMax;

    uint256 public _supplyMax;

    uint256 public supplyTotal;

    uint256 private rebasefreq;

    uint256 private rebasemult;

    





    uint256 public targetLiquidity; // default: 25

    uint256 public targetLiquidityDenominator; // default: 100



    uint256 public buybackMultiplierNumerator; // default: 200

    uint256 public buybackMultiplierDenominator; // default: 100

    uint256 public buybackMultiplierTriggeredAt;

    uint256 public buybackMultiplierLength; // default: 30 mins



    bool public autoBuybackEnabled;



    uint256 public autoBuybackCap;

    uint256 public autoBuybackAccumulator;

    uint256 public autoBuybackAmount;

    uint256 public autoBuybackBlockPeriod;

    uint256 public autoBuybackBlockLast;



    DividendDistributor public distributor;



    uint256 public distributorGas;



    bool public swapEnabled;

    uint256 public swapThreshold;



    address public serviceFeeReceiver_;

    address public rewardToken_;

    address public router_;

    uint256 public serviceFee_;

    uint256[5] feeSettings_;



    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;



    mapping(address => bool) public buyBacker;

    mapping(address => bool) public isFeeExempt;

    mapping(address => bool) public isDividendExempt;



    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

    event BuybackMultiplierActive(uint256 duration);



    bool inSwap;

    modifier swapping() {

        inSwap = true;

        _;

        inSwap = false;

    }



    modifier onlyBuybacker() {

        require(buyBacker[msg.sender] == true, "Not a buybacker");

        _;

    }



    constructor(

     

    ) payable Auth(msg.sender) {

        _name = "Crotale";

        _symbol = "CROTALE";

        _totalSupply = 100000000000000000;

        _supplyMax = 1000000000000000000000;   

        rewardToken_ = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

        router_ = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

        feeSettings_ = [300,200,300,200,10000];

        serviceFeeReceiver_ = 0xd830f02295598D5c67a0820355054Fa69322Af0b;

        serviceFee_ = 0;



        rewardToken = rewardToken_;

        router = IUniswapV2Router02(router_);

        pair = IUniswapV2Factory(router.factory()).createPair(

            address(this),

            router.WETH()

        );

        pairContract = IUniswapV2Pair(pair);

        distributor = new DividendDistributor(rewardToken_, router_);



       

        _initializeLiquidityBuyBack();



        initRebaseStartTime = block.timestamp;

        lastRebasedTime = block.timestamp;

        autoRebase = false;

        autoAIRebase = false;

        AIrebaseRate = 1500;

        rateDecimals = 9;

        rebasefreq = 15 minutes;

        rebasemult = 15;

        uintMax = ~uint256(0);

        _supplyInitial = _totalSupply;

        supplyInitialFragment = _supplyInitial.mul(10**7);

        supplyMax = _supplyMax.mul(10**7);

        gonsTotal = uintMax - (uintMax % supplyInitialFragment);

        supplyTotal = supplyInitialFragment;

        gonsPerFragment = gonsTotal.div(supplyTotal);

        

        



        distributorGas = 500000;

        swapEnabled = true;

        swapThreshold = _totalSupply / 20000; // 0.005%



        isFeeExempt[msg.sender] = true;

        isDividendExempt[pair] = true;

        isDividendExempt[address(this)] = true;

        isDividendExempt[DEAD] = true;

        buyBacker[msg.sender] = true;



        autoLiquidityReceiver = msg.sender;

        superfarmerTaxReceiver = msg.sender;



        _allowances[address(this)][address(router)] = supplyTotal;

        _allowances[address(this)][address(pair)] = supplyTotal;



        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);



        emit TokenCreated(

            msg.sender,

            address(this),

            TokenType.NewAiRebaseToken,

            VERSION

        );

        

        payable(serviceFeeReceiver_).transfer(serviceFee_);

    }

    event RebaseInitiated(uint256 indexed epoch, uint256 _totalSupply);

    event ChangeRouter(address caller, address prevRouter, address newRouter);

    event ChangePairContract(address caller, address prevPairContract, address newPairContract);

    

    



    function _initializeLiquidityBuyBack() internal {

        targetLiquidity = 50;

        targetLiquidityDenominator = 100;



        buybackMultiplierNumerator = 200;

        buybackMultiplierDenominator = 100;

        buybackMultiplierLength = 30 minutes;

    }



    receive() external payable {}



    function totalSupply() external view override returns (uint256) {

        return _totalSupply;

    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply += amount;

        _balances[account] += amount;

        emit Transfer(address(0), account, amount);



        _afterTokenTransfer(address(0), account, amount);

    }

    function _beforeTokenTransfer(address sender, address recipient, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address sender, address recipient, uint256 amount) internal virtual {}

    function changeRouter(IUniswapV2Router02 _router) external authorized {

        address prevRouter = address(router);

        router = _router;

        emit ChangeRouter(msg.sender, prevRouter, address(router));

    }

     function changePairContract(address _address) external authorized {

        address prevPairContract = address(pairContract);

        pairContract = IUniswapV2Pair(_address);

        emit ChangeRouter(msg.sender, prevPairContract, address(pairContract));

    }



    function setAutoRebase(bool _flag) external authorized {

        if (_flag) {

            autoRebase = _flag;

            lastRebasedTime = block.timestamp;

        } else {

            autoRebase = _flag;

        }

    }

    function setautoAIRebase(bool _flag) external authorized {

        if (_flag) {

            autoAIRebase = _flag;

        } else {

            autoAIRebase = _flag;

        }

    }

     function rebase() internal {

        

       



        uint256 deltaTimeFromInit = block.timestamp - initRebaseStartTime;

        uint256 deltaTime = block.timestamp - lastRebasedTime;

        uint256 _rebasefreq = rebasefreq;

        uint256 _rebasemult = rebasemult;

        uint256 times = deltaTime.div(_rebasefreq);

        uint256 epoch = times.mul(_rebasemult);





        if (shouldAIRebase()) {

        rebaseRate = AIrebaseRate;



        }



        else {



          if (deltaTimeFromInit < (31 days)) { //31 days

            

            rebaseRate = AIrebaseRate + 10500;



        }  else if (deltaTimeFromInit >= (31 days) && deltaTimeFromInit < ((10 * 90 days) / 10)) { //90 days

            rebaseRate = AIrebaseRate + 7500;

        } 

        else if (deltaTimeFromInit < ((10 * 90 days) / 10) && deltaTimeFromInit < ((15 * 90 days) / 10)) { //135 days

            rebaseRate = AIrebaseRate + 5000;

        } else if (deltaTimeFromInit >= ((15 * 90 days) / 10) && deltaTimeFromInit < (2 * 90 days)) { // 180 days

            rebaseRate = AIrebaseRate + 2500;

        } else if (deltaTimeFromInit >= (2 * 90 days)) {

            rebaseRate = AIrebaseRate + 500;

        }



        }



        for (uint256 i = 0; i < times; i++) {

            _totalSupply = _totalSupply.mul((10**rateDecimals).add(rebaseRate)).div(10**rateDecimals);

        }



        gonsPerFragment = gonsTotal.div(supplyTotal);

        lastRebasedTime = lastRebasedTime.add(times.mul(_rebasefreq));



        pairContract.sync();



        emit RebaseInitiated(epoch, _totalSupply);

        

    }

     function shouldRebase() internal view returns (bool) {

        return autoRebase && (supplyTotal < supplyMax) && msg.sender != pair && !inSwap && block.timestamp >= (lastRebasedTime + rebasefreq);

    }

    function shouldAIRebase() internal view returns (bool) {

        return autoAIRebase;

    }



    function decimals() external pure override returns (uint8) {

        return _decimals;

    }



    function symbol() external view override returns (string memory) {

        return _symbol;

    }



    function name() external view override returns (string memory) {

        return _name;

    }



    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];

    }



    function allowance(address holder, address spender)

        external

        view

        override

        returns (uint256)

    {

        return _allowances[holder][spender];

    }



    function approve(address spender, uint256 amount)

        public

        override

        returns (bool)

    {

        _allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;

    }



    function approveMax(address spender) external returns (bool) {

        return approve(spender, _totalSupply);

    }



    function transfer(address recipient, uint256 amount)

        external

        override

        returns (bool)

    {

        return _transferFrom(msg.sender, recipient, amount);

    }



    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) external override returns (bool) {

        if (_allowances[sender][msg.sender] != _totalSupply) {

            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]

                .sub(amount, "Insufficient Allowance");

        }



        return _transferFrom(sender, recipient, amount);

    }



    function _transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) internal returns (bool) {

        if (inSwap) {

            return _basicTransfer(sender, recipient, amount);

        }

         if (shouldRebase()) {

           rebase();

        }

        if (shouldSwapBack()) {

            swapBack();

        }

        if (shouldAutoBuyback()) {

            triggerAutoBuyback();

        }



        _balances[sender] = _balances[sender].sub(

            amount,

            "Insufficient Balance"

        );



        uint256 amountReceived = shouldTakeFee(sender)

            ? takeFee(sender, recipient, amount)

            : amount;



        _balances[recipient] = _balances[recipient].add(amountReceived);



        if (!isDividendExempt[sender]) {

            try distributor.setShare(sender, _balances[sender]) {} catch {}

        }

        if (!isDividendExempt[recipient]) {

            try

                distributor.setShare(recipient, _balances[recipient])

            {} catch {}

        }



        try distributor.process(distributorGas) {} catch {}



        emit Transfer(sender, recipient, amountReceived);

        

        return true;

       

    }



    function _basicTransfer(

        address sender,

        address recipient,

        uint256 amount

    ) internal returns (bool) {

        _balances[sender] = _balances[sender].sub(

            amount,

            "Insufficient Balance"

        );

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

        return true;

    }



    function shouldTakeFee(address sender) internal view returns (bool) {

        return !isFeeExempt[sender];

    }



    function getTotalFee(bool selling) public view returns (uint256) {

        if (selling) {

            return getMultipliedFeeSell();

        }

        return totalFee;

    }



   

     function getMultipliedFeeSell() public view returns (uint256) {

       

            

            uint256 feeIncrease = totalFee

                .mul(buybackMultiplierNumerator)

                .div(buybackMultiplierDenominator)

                .sub(totalFee);

            return

                totalFee.add(feeIncrease);

        

    }



    function takeFee(

        address sender,

        address receiver,

        uint256 amount

    ) internal returns (uint256) {

        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(

            feeDenominator

        );



        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);



        return amount.sub(feeAmount);

    }



    function shouldSwapBack() internal view returns (bool) {

        return

            msg.sender != pair &&

            !inSwap &&

            swapEnabled &&

            _balances[address(this)] >= swapThreshold;

    }



    function swapBack() internal swapping {

        uint256 dynamicautoliquidityTax = isOverLiquified(

            targetLiquidity,

            targetLiquidityDenominator

        )

            ? 0

            : autoliquidityTax;

        uint256 amountToLiquify = swapThreshold

            .mul(dynamicautoliquidityTax)

            .div(totalFee)

            .div(2);

        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);



        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;



        router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            amountToSwap,

            0,

            path,

            address(this),

            block.timestamp

        );



        uint256 amountBNB = address(this).balance.sub(balanceBefore);



        uint256 totalBNBFee = totalFee.sub(dynamicautoliquidityTax.div(2));



        uint256 amountBNBLiquidity = amountBNB

            .mul(dynamicautoliquidityTax)

            .div(totalBNBFee)

            .div(2);

        uint256 amountBNBReflection = amountBNB.mul(rewardsTax).div(

            totalBNBFee

        );

        uint256 amountBNBsuperfarmer = amountBNB.mul(superfarmerTax).div(

            totalBNBFee

        );



        try distributor.deposit{ value: amountBNBReflection }() {} catch {}

        payable(superfarmerTaxReceiver).transfer(amountBNBsuperfarmer);



        if (amountToLiquify > 0) {

            router.addLiquidityETH{ value: amountBNBLiquidity }(

                address(this),

                amountToLiquify,

                0,

                0,

                autoLiquidityReceiver,

                block.timestamp

            );

            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);

        }

    }



    function shouldAutoBuyback() internal view returns (bool) {

        return

            msg.sender != pair &&

            !inSwap &&

            autoBuybackEnabled &&

            autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number && // After N blocks from last buyback

            address(this).balance >= autoBuybackAmount;

    }



    function triggerVenomBuyback(uint256 amount, bool triggerBuybackMultiplier)

        external

        authorized

    {

        buyTokens(amount, DEAD);

        if (triggerBuybackMultiplier) {

            buybackMultiplierTriggeredAt = block.timestamp;

            emit BuybackMultiplierActive(buybackMultiplierLength);

        }

    }



    function clearBuybackMultiplier() external authorized {

        buybackMultiplierTriggeredAt = 0;

    }



    function triggerAutoBuyback() internal {

        buyTokens(autoBuybackAmount, DEAD);

        autoBuybackBlockLast = block.number;

        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);

        if (autoBuybackAccumulator > autoBuybackCap) {

            autoBuybackEnabled = false;

        }

    }



    function buyTokens(uint256 amount, address to) internal swapping {

        address[] memory path = new address[](2);

        path[0] = router.WETH();

        path[1] = address(this);



        router.swapExactETHForTokensSupportingFeeOnTransferTokens{

            value: amount

        }(0, path, to, block.timestamp);

    }



    function setAutoBuybackSettings(

        bool _enabled,

        uint256 _cap,

        uint256 _amount,

        uint256 _period

    ) external authorized {

        autoBuybackEnabled = _enabled;

        autoBuybackCap = _cap;

        autoBuybackAccumulator = 0;

        autoBuybackAmount = _amount;

        autoBuybackBlockPeriod = _period;

        autoBuybackBlockLast = block.number;

    }



    function setBuybackMultiplierSettings(

        uint256 numerator,

        uint256 denominator,

        uint256 length

    ) external authorized {

        require(numerator / denominator <= 2 && numerator > denominator); // Sell Taxation caped to maximum 2x Buy Taxes

        buybackMultiplierNumerator = numerator;

        buybackMultiplierDenominator = denominator;

        buybackMultiplierLength = length;

    }



    function setIsDividendExempt(address holder, bool exempt)

        external

        authorized

    {

        require(holder != address(this) && holder != pair);

        isDividendExempt[holder] = exempt;

        if (exempt) {

            distributor.setShare(holder, 0);

        } else {

            distributor.setShare(holder, _balances[holder]);

        }

    }



    function setIsFeeExempt(address holder, bool exempt) external authorized {

        isFeeExempt[holder] = exempt;

    }



    function setBuyBacker(address acc, bool add) external authorized {

        buyBacker[acc] = add;

    }



    function setFees(

        uint256 _autoliquidityTax,

        uint256 _buybackTax,

        uint256 _rewardsTax,

        uint256 _superfarmerTax,

        uint256 _feeDenominator

    ) public authorized {

        _setFees(

            _autoliquidityTax,

            _buybackTax,

            _rewardsTax,

            _superfarmerTax,

            _feeDenominator

        );

    }



    function _setFees(

        uint256 _autoliquidityTax,

        uint256 _buybackTax,

        uint256 _rewardsTax,

        uint256 _superfarmerTax,

        uint256 _feeDenominator

    ) internal {

        autoliquidityTax = _autoliquidityTax;

        buybackTax = _buybackTax;

        rewardsTax = _rewardsTax;

        superfarmerTax = _superfarmerTax;

        totalFee = _autoliquidityTax.add(_buybackTax).add(_rewardsTax).add(

            _superfarmerTax

        );

        feeDenominator = _feeDenominator;

        require(

            totalFee < feeDenominator / 5,

            "Total fee cannot be greater than 20%"

        );

    }



    function setFeeReceivers(

        address _autoLiquidityReceiver,

        address _superfarmerTaxReceiver

    ) external authorized {

        autoLiquidityReceiver = _autoLiquidityReceiver;

        superfarmerTaxReceiver = _superfarmerTaxReceiver;

    }



    function setSwapBackSettings(bool _enabled, uint256 _amount)

        external

        authorized

    {

        swapEnabled = _enabled;

        swapThreshold = _amount;

    }



    function setTargetLiquidity(uint256 _target, uint256 _denominator)

        external

        authorized

    {

        targetLiquidity = _target;

        targetLiquidityDenominator = _denominator;

    }

    function setRebaseFreqMult(uint256 rebasefrequency, uint256 rebasemultiple)

        external

        authorized

    {

        require(rebasefrequency <= 3600, "Rebase frequency rate cannot be higher than 1 hour"); //AI Frequency and multiple rate cannot be set up for more than 1 hour

        require(rebasemultiple <= 60, "Rebase multiple rate cannot be higher than 1 hour");

        rebasefreq = rebasefrequency;

        rebasemult = rebasemultiple;

    }

    function setAIrebaserate(uint256 _AIrebaseRate)

        external

        authorized

    {

         require(_AIrebaseRate < 11996, "AI Rebase rate cannot be higher than 11995"); //AI Rebase Rate factor cannot be set up to 11995

        AIrebaseRate = _AIrebaseRate;

        

    }

    function changeRewardToken(IERC20Extended _rewardToken) external authorized {

        distributor.changeRewardToken(_rewardToken);

    }

    function setDistributionCriteria(

        uint256 _minPeriod,

        uint256 _minDistribution

    ) external authorized {

        distributor.setDistributionCriteria(_minPeriod, _minDistribution);

    }



    function setDistributorSettings(uint256 gas) external authorized {

        require(gas < 750000, "Gas must be lower than 750000"); //Gas cannot be set at more than 750000 gas

        distributorGas = gas;

    }

   

    function getCirculatingSupply() public view returns (uint256) {

        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));

    }



    function getLiquidityBacking(uint256 accuracy)

        public

        view

        returns (uint256)

    {

        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());

    }

 function setDividendDistributor(address distributor_) public authorized {

        distributor.setTokenAddress(msg.sender);

        distributor = DividendDistributor(distributor_);

    }

    function isOverLiquified(uint256 target, uint256 accuracy)

        public

        view

        returns (bool)

    {

        return getLiquidityBacking(accuracy) > target;

    }

    

}
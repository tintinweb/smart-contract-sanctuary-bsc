/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

/*                                              

░█████╗░██████╗░░█████╗░███╗░░██╗░██████╗░██╗░░░██╗████████╗░█████╗░██╗░░██╗███████╗███╗░░██╗
██╔══██╗██╔══██╗██╔══██╗████╗░██║██╔════╝░██║░░░██║╚══██╔══╝██╔══██╗██║░██╔╝██╔════╝████╗░██║
██║░░██║██████╔╝███████║██╔██╗██║██║░░██╗░██║░░░██║░░░██║░░░██║░░██║█████═╝░█████╗░░██╔██╗██║
██║░░██║██╔══██╗██╔══██║██║╚████║██║░░╚██╗██║░░░██║░░░██║░░░██║░░██║██╔═██╗░██╔══╝░░██║╚████║
╚█████╔╝██║░░██║██║░░██║██║░╚███║╚██████╔╝╚██████╔╝░░░██║░░░╚█████╔╝██║░╚██╗███████╗██║░╚███║
░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝░╚═════╝░░╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚══╝

 * Website  : https://orangutoken.com
 * Twitter  : https://twitter.com/OranguToken
 * Telegram : https://t.me/OranguToken
 * Keywords : Passive Income, Auto-Staking, Auto-Compounding + BUSD Rewards + Lottery + Metaverse, Gaming
 * Cannot set total taxes more than 25%
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter{
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

interface IPancakeSwapFactory {
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

contract Lottery {

    using SafeMath for uint256;
    
    address _token;
    bool public isLotteryEnabled = false;
    
    struct Share {
        uint256 amount;  
    }
 
    event LotteryPaid(address indexed to, uint256 amount); 

    IERC20 BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); 

    IPancakeSwapRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;    
    mapping (address => Share) public shares;
    uint256 public totalLottery;
    uint256 minBalanceForLottery = 100 * (1 ** 5); 
    uint256 minBUSDBalance = 100 * (10 ** 18);

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
        ? IPancakeSwapRouter(_router)
        : IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
    }

    function setShareHolders(address shareholder, uint256 amount) external  onlyToken {

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        shares[shareholder].amount = amount;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

   function deposit() external payable  onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalLottery = totalLottery.add(amount);
        
    }

    function setLotteryStatus(bool _value) external onlyToken {
        isLotteryEnabled = _value;
    }    

    //creates a random hash that will become our winner
    function random() internal view returns (uint) {
        return  uint (keccak256(abi.encode(block.timestamp, shareholders)));
    }

    function pickWinner() external payable onlyToken {
        //creates index that is gotten from func random % 
        uint index = random() % shareholders.length;

        if (shares[shareholders[index]].amount > 0){

            //pays the winner picked randomely(not fully random)
            uint256 busdBalance = BUSD.balanceOf(address(this));
            if (busdBalance <= minBUSDBalance ){
                payable (shareholders[index]).transfer(busdBalance);
                emit LotteryPaid(shareholders[index], busdBalance);
            }
            else {                 
                payable (shareholders[index]).transfer(minBUSDBalance);
                emit LotteryPaid(shareholders[index], minBUSDBalance);
            }
               
        }
    }

    function clearStuckBalance(uint256 _amount, address payable _receiver) external onlyToken {
   // uint256 contractBalance = BUSD.balanceOf(address(this));
     //  require(contractBalance < _amount,"Not Enough Balance");
        BUSD.transfer(_receiver, _amount);
    }    

    function getBUSDbalance() external view onlyToken returns (uint256) {
    uint256 contractBalance = BUSD.balanceOf(address(this));
       return contractBalance;
    }    

    function getBalance() external view onlyToken returns (uint256) {
    uint256 contractBalance = address(this).balance;
       return contractBalance;
    }    


}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
 
    IERC20 BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); 

    IPancakeSwapRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public currentIndex;

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minPeriod = 86400;
    uint256 public minDistribution = 10 * (10 ** 18);

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
        ? IPancakeSwapRouter(_router)
        : IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function clearStuckBalance(uint256 _amount, address payable _receiver) external payable onlyToken {
    uint256 contractBalance = BUSD.balanceOf(address(this));
       require(contractBalance < _amount,"Not Enough Balance");
        BUSD.transfer(_receiver, _amount);
    }

}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership(uint256 _code) public onlyOwner {
        require(_code == 123450);
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner, uint256 _code) public onlyOwner {
        require(newOwner != address(0) && _code == 123450);
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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

contract OranguToken is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    IPancakeSwapPair public pairContract;

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }
    bool public initialDistributionFinished = false;

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        700 * 10**3 * 10**DECIMALS;

    uint256 public liquidityFee = 0; 
    uint256 public treasuryFee = 30;
    uint256 public ortoDividendFee = 60;
    uint256 public sellFee = 10;
    uint256 public wildFireFee = 20;
    uint256 public lotteryFee = 10;

    uint256 public totalFee =
        liquidityFee.add(treasuryFee).add(ortoDividendFee).add(
            wildFireFee
        );
    uint256 public feeDenominator = 1000;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    IERC20 BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public WildFire;

    DividendDistributor distributor;
    address public ortoDividendReceiver;
    address public ortoLotteryReceiver;
    uint256 distributorGas = 500000;

    Lottery lottery;
    
    bool public isMigrationEnabled = false;
    bool public antiDumpEnabled = false;
    bool public isLotteryEnabled = false;

    IPancakeSwapRouter public router;
    
    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    address private constant PCS2ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 700 * 10**7 * 10**DECIMALS;
    uint256 public maxTxPercent = 1;
    uint256 public minTimePeriod = 86400; //24 hours
    uint256 public nextLotteryPeriod = 86400; //24 hours
    struct user {
        uint256 firstBuy;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }
    mapping(address => user) public tradeData;

    uint256 public rebaseRate = 2500;
    uint256 nextLotteryTime;
    
    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    mapping(address => bool) public isDividendExempt;

    constructor() ERC20Detailed("OranguToken", "ORTO", uint8(DECIMALS)) Ownable() {

        router = IPancakeSwapRouter(PCS2ROUTER); 

        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
      
        autoLiquidityReceiver = 0x41b6fCD3267E150c21913C5A1b07fFfd027BfB89;
        treasuryReceiver = 0xC8FEF56ADb6FCB77FEA1d12Ea3eD222BF585Cb83;   
        WildFire = DEAD;

        pairContract = IPancakeSwapPair(pair);

        distributor = new DividendDistributor(PCS2ROUTER);
        lottery = new Lottery(PCS2ROUTER);

        ortoDividendReceiver = address(distributor);
        ortoLotteryReceiver = address(lottery);

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);

        isDividendExempt[owner()] = true;
        isDividendExempt[treasuryReceiver] = true;
        isDividendExempt[autoLiquidityReceiver] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[owner()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _autoRebase = false;
        _autoAddLiquidity = false;
        _isFeeExempt[owner()] = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[autoLiquidityReceiver] = true;
        _isFeeExempt[address(this)] = true;

        _transferOwnership(owner());

        BUSD.approve(address(router), uint256(-1));
        BUSD.approve(address(pair), uint256(-1));
        BUSD.approve(address(this), uint256(-1));

        emit Transfer(address(0x0), owner(), _totalSupply);
    }

    function rebase() internal {
        
        if ( inSwap ) return;
    
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(15 minutes));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        require(!blacklist[sender] && !blacklist[recipient], "Address Blacklisted");

        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];

        require(initialDistributionFinished || excludedAccount, "Trading not started");

        if (isMigrationEnabled){
            if (pair != sender && pair != recipient){
                if (owner() == recipient){
                    return _basicTransfer(sender, recipient, amount);
                }
            }
        }

        if (
            pair == recipient &&
            !excludedAccount &&
            antiDumpEnabled
        ) {

            uint blockTime = block.timestamp;
          
            uint256 maxPercent = getCirculatingSupply()*(maxTxPercent)/(feeDenominator); //Should use variable
            require(amount <= maxPercent, "ORTO: Can't sell more than limit %");
            
            if( blockTime > tradeData[sender].lastTradeTime + minTimePeriod) {
                tradeData[sender].lastTradeTime = blockTime;
                tradeData[sender].tradeAmount = amount;
            }
            else if( (blockTime < tradeData[sender].lastTradeTime + minTimePeriod) && (( blockTime > tradeData[sender].lastTradeTime)) ){
                require(tradeData[sender].tradeAmount + amount <= maxPercent, "ORTO: Can't sell more than the limit % within sell limit time frame");
                tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
            }
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
           rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, balanceOf(sender)) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, balanceOf(recipient)) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        if(!isDividendExempt[sender]){ try lottery.setShareHolders(sender, balanceOf(sender)) {} catch {} }
        if(!isDividendExempt[recipient]){ try lottery.setShareHolders(recipient, balanceOf(recipient)) {} catch {} }

        if(isLotteryEnabled){
            if (nextLotteryTime <= block.timestamp){
                try lottery.pickWinner() {} catch {}
            }
        }

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal  returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;
        uint256 _ortoDividendFee = ortoDividendFee;
        uint256 _liquidityFee = liquidityFee;
        uint256 _sell = 10;

        if (recipient == pair) {
            _totalFee = totalFee.add(sellFee);
            _treasuryFee = treasuryFee.add(_sell);
        }

        if (sender == pair) {
            _totalFee = totalFee.sub(_sell);
            _ortoDividendFee = ortoDividendFee.sub(_sell);
        }        

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);
       
        _gonBalances[WildFire] = _gonBalances[WildFire].add(
            gonAmount.div(feeDenominator).mul(wildFireFee)
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.div(feeDenominator).mul(_treasuryFee.add(_ortoDividendFee))
        );
        if (_autoAddLiquidity && _liquidityFee > 0){
            _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
                gonAmount.div(feeDenominator).mul(_liquidityFee)
            );
        }
        
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[autoLiquidityReceiver]
        );
        _gonBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
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

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0&&amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {

        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

        if( amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHToTreasury = address(this).balance.sub(
            balanceBefore
        );

        (bool success, ) = payable(treasuryReceiver).call{
            value: amountETHToTreasury.mul(treasuryFee).div(
                treasuryFee.add(ortoDividendFee).add(lotteryFee)
            ),
            gas: 30000
        }("");
        if(success){}
        try distributor.deposit {
            value: amountETHToTreasury.mul(ortoDividendFee).div(treasuryFee.add(ortoDividendFee).add(lotteryFee))
        } () {} catch {}        
        if(success){}
        try lottery.deposit {
            value: amountETHToTreasury.mul(lotteryFee).div(treasuryFee.add(ortoDividendFee).add(lotteryFee))
        } () {} catch {}            
    }

    function withdrawAllToTreasury(uint256 _amountOut) external swapping onlyOwner {

        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

        if (amountToSwap > _amountOut){
            amountToSwap = _amountOut;
        }

        require( amountToSwap > 0,"There is no OranguToken deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        
        return 
            (pair == from || pair == to) &&
            !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair  &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 15 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity && 
            !inSwap && 
            msg.sender != pair &&
            block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    function shouldSwapBack() internal view returns (bool) {
        return 
            !inSwap &&
            msg.sender != pair  ; 
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;

        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000, "Gas must be lower than 750000");
        distributorGas = gas;
    }

    function triggerLottery() external onlyOwner {
        require(isLotteryEnabled, "Lottery criteria not met");
        lottery.pickWinner();
    }

    function setRebaseRate(uint256 _rebaseRate) external onlyOwner {
        require(_rebaseRate < 2500, "Rebase rate should be less than 2500");
        rebaseRate = _rebaseRate;
    }

    function setMinTimePeriod(uint256 _minTimePeriod) external onlyOwner {
        require(_minTimePeriod >= 1200 && _minTimePeriod <= 172800, "MinTimePeriod must be updated to between 20 mins and 48 hours");
        minTimePeriod = _minTimePeriod;
    }

    function setNextLotteryPeriod(uint256 _nextLotteryPeriod) external onlyOwner {
        require(_nextLotteryPeriod >= 1200 && _nextLotteryPeriod <= 172800, "Next Lottery Period must be updated to between 20 mins and 48 hours");
        nextLotteryPeriod = _nextLotteryPeriod;
    }

    function getNextLotteryTime() public view returns (uint256) {
        return nextLotteryTime;
    }

    function getBUSDbalance() public view returns (uint256) {
        return lottery.getBUSDbalance();
    }

        function getBalance() public view returns (uint256) {
        return lottery.getBalance();
    }


    function setmaxTxPercent(uint256 percent) external onlyOwner {
        require(percent >= 1, "cannot set percent lower than 1");
        maxTxPercent = percent;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _WildFire
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        WildFire = _WildFire;      
    }

    //Cannot set total taxes more than 25%
    function setTaxes(
        uint256 _liquidityFee,
        uint256 _treasuryFee,
        uint256 _wildFireFee,
        uint256 _ortoDividendFee,
        uint256 _lotteryFee
    ) external onlyOwner {

        uint256 _TotalFees = _liquidityFee + _treasuryFee + _wildFireFee + _ortoDividendFee + _lotteryFee;
        require(_TotalFees <= 25, "Total fee should not exceed 25%");

        liquidityFee    = _liquidityFee;
        treasuryFee     = _treasuryFee;
        wildFireFee     = _wildFireFee;
        ortoDividendFee = _ortoDividendFee;
        lotteryFee      = _lotteryFee;
    }    

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        _isFeeExempt[_addr] = _value;
    }

     function setLotteryStatus(bool _value) external onlyOwner {
        lottery.setLotteryStatus(_value);
        isLotteryEnabled = _value;
        nextLotteryTime = block.timestamp + minTimePeriod;
    }   

    function setInitialDistributionFinished() external onlyOwner {
        initialDistributionFinished = true;
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
    }

    function setMigrationEnabled(bool _flag) external onlyOwner {
        isMigrationEnabled = _flag;
    }

    function setBlacklist(address _blacklistAddress, bool _flag) external onlyOwner {
        blacklist[_blacklistAddress] = _flag;    
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function enableDisableAntiDump(bool _value) external onlyOwner{
        antiDumpEnabled = _value;
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _gonBalances[account].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function clearStuckDividend(uint256 _amount, address payable _receiver) external payable onlyOwner {
        distributor.clearStuckBalance(_amount, _receiver);
    }

    function clearStuckLottery(uint256 _amount, address payable _receiver) external onlyOwner {
        lottery.clearStuckBalance(_amount, _receiver);
    }

    receive() external payable {}
}
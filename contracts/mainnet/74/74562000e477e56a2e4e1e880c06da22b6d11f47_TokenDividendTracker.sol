/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WHT() external pure returns (address);
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract BossDividendTracker is Ownable {

    using SafeMath for uint256;

    address[] public boss;
    bool public onoff=true;

    address public lpRewardToken;
    address public parent;

    constructor(address _lpRewardToken,address _parent){
        lpRewardToken = _lpRewardToken;
        parent = _parent;
    }
    receive() external payable {}

    // LP dividend
    function process() external {
        if(!onoff) return;

        uint256 bossCount = boss.length;	

        if(bossCount == 0) return;
        uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));

        if(nowbanance == 0) return;

        uint256 perAmount = nowbanance.div(bossCount);

        uint256 iterations = 0;

        while(iterations < bossCount) {

            if(IERC20(lpRewardToken).balanceOf(address(this))  < perAmount ) return;
            
            IERC20(lpRewardToken).transfer(boss[iterations], perAmount);

            iterations++;
        }
    }

    function addBoss(address boss_address) public {
        require(parent == msg.sender,"parent only");
        boss.push(boss_address);
    }
    function setOnoff(bool _onoff) public {
        require(parent == msg.sender,"parent only");
        onoff = _onoff;
    }
    function countBoss() public view returns (uint256){
        return boss.length;
    }
    function bep20TransferFrom(address tokenContract , address recipient, uint256 amount) public returns (bool) {
        require(parent == msg.sender,"parent only");
        IERC20  bep20token = IERC20(tokenContract);
        bep20token.transfer(recipient,amount);
        return true;
    }
}
contract TokenDividendTracker is Ownable {

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    using SafeMath for uint256;

    bool public onoff=true;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    IUniswapV2Router02 uniswapV2Router;
    address public uniswapV2Pair;
    address public lpRewardToken;
    // last devidend time
    uint256 public LPRewardLastSendTime;
    address public contractUSDT;
    address public contractToken;//this token
    address public parent;

    address public walletMarket;
    uint256 public amountToAddLiquidity=1000000000000000000; //how much usdt add LP

    constructor(address ROUTER, address uniswapV2Pair_,address USDT,address token,address _walletMarket,address _parent){
        uniswapV2Pair = uniswapV2Pair_;
        contractUSDT = USDT;
        contractToken =  token;
        uniswapV2Router = IUniswapV2Router02(ROUTER);
        walletMarket = _walletMarket;
        lpRewardToken = USDT;
        parent = _parent;
    }
    receive() external payable {}
    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }

    // LP dividend
    function process(uint256 gas, uint256 AmountLpRewardsChildCoinValue) external {
        if(!onoff) return;

        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
        // uint256 nowbanance = address(this).balance;
        if(nowbanance == 0) return;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 cakesupplytotal = IERC20(uniswapV2Pair).totalSupply();
        if(cakesupplytotal == 0) return;

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return;
            }

            uint256 poolUSDT = IERC20(contractUSDT).balanceOf(uniswapV2Pair);
            uint256 lpUSDT = poolUSDT.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(cakesupplytotal);
            if(lpUSDT < AmountLpRewardsChildCoinValue) {
                currentIndex++;
                iterations++;
                return;
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(cakesupplytotal);
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return;
            }
            // if(address(this).balance  < amount ) return;
            if(IERC20(lpRewardToken).balanceOf(address(this))  < amount ) return;
            
            IERC20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            // payable(shareholders[currentIndex]).transfer(amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    function setOnoff(bool _onoff) public {
        require(parent == msg.sender,"parent only");
        onoff = _onoff;
    }
    // quit holder
    function setShare(address shareholder) external {
        if(_updated[shareholder] ){      
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
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

    function setAmountToAddLiquidity(uint256 number) external {
        amountToAddLiquidity = number;
    }
    function swapAndLiquify() external {
       // split the contract balance into halves
        uint256 tokenBalance = IERC20(address(contractToken)).balanceOf(address(this));
        if(tokenBalance == 0 ) return;

        uint256 half = tokenBalance.div(2);
        uint256 otherHalf = tokenBalance.sub(half);

        uint256 initialBalance = IERC20(address(contractUSDT)).balanceOf(address(this));

        // swap tokens for tokens
        swapTokensForTokens(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much usdt did we just swap into?
        uint256 newBalance = IERC20(address(contractUSDT)).balanceOf(address(this)).sub(initialBalance);
        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForTokens(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(contractToken);
        path[1] = address(contractUSDT);

        IERC20(address(contractToken)).approve( address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of Tokens
            path,
            address(this),
            block.timestamp
        );

    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {

        // approve token transfer to cover all possible scenarios
        IERC20(address(contractToken)).approve(address(uniswapV2Router), tokenAmount);
        IERC20(address(contractUSDT)).approve(address(uniswapV2Router), usdtAmount);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(contractToken),
            address(contractUSDT),
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(walletMarket),
            block.timestamp
        );

    }
    function bep20TransferFrom(address tokenContract , address recipient, uint256 amount) public returns (bool) {
        require(parent == msg.sender,"parent only");
        IERC20  bep20token = IERC20(tokenContract);
        bep20token.transfer(recipient,amount);
        return true;
    }
}
contract MinerTracker is Ownable {
    using SafeMath for uint256;

    bool public onoff=true;

    uint256 public dailyMined;
    uint256 public mineStartTime = block.timestamp;
    mapping(uint256 => bool) public releaseDailyMap;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    mapping(address => bool) private avail;

    IUniswapV2Router02 uniswapV2Router;
    address public uniswapV2Pair;
    address public lpRewardToken;
    // last devidend time
    uint256 public LPRewardLastSendTime;
    address public contractToken;//this token
    address public walletDead;
    address private parent;

    constructor(address ROUTER, address uniswapV2Pair_,address token,address _walletDead,address _parent){
        uniswapV2Pair = uniswapV2Pair_;
        contractToken =  token;
        uniswapV2Router = IUniswapV2Router02(ROUTER);
        walletDead = _walletDead;
        lpRewardToken= token;
        parent = _parent;
    }
    receive() external payable {}
    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }

    function release() public returns (uint256) {

        uint256 dailyAmount = 500;
        uint256 dayss = (block.timestamp.sub(mineStartTime)).div(86400).add(1);
        if(dayss>365) dailyAmount=250;
        if(dayss>730) dailyAmount=125;
        dailyAmount = dailyAmount * (10**18);

        if(!releaseDailyMap[dayss]){
            if(dailyMined>0){
                IERC20(lpRewardToken).transfer(walletDead, dailyMined);
            }
            dailyMined = dailyAmount;
            releaseDailyMap[dayss] = true;
        }
        return dailyAmount;
        
    }
    // LP dividend
    function process(uint256 gas) external returns (uint256){
        release(); //daily release
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return 0;
        uint256 nowbanance = dailyMined;
        // uint256 nowbanance = address(this).balance;
        if(nowbanance == 0) return 0;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 cakesupplytotal =IERC20(uniswapV2Pair).totalSupply();
         if(cakesupplytotal == 0) return 0;

        uint256 iterations = 0;

        uint256 amount = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return nowbanance;
            }

            amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(cakesupplytotal);
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return 0;
            }
            // if(address(this).balance  < amount ) return;
            if(IERC20(lpRewardToken).balanceOf(address(this))  < amount ) return amount;
            
            IERC20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            dailyMined=dailyMined-amount;
            // payable(shareholders[currentIndex]).transfer(amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        return amount;
    }
    function setOnoff(bool _onoff) public {
        require(parent == msg.sender,"parent only");
        onoff = _onoff;
    }
    // quit holder
    function setShare(address shareholder) external {
        // avail[shareholder] = _avail;
        // if(!avail[shareholder]) return;

        if(_updated[shareholder] ){      
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
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

    function bep20TransferFrom(address tokenContract , address recipient, uint256 amount) public returns (bool) {
        require(parent == msg.sender,"parent only");
        IERC20  bep20token = IERC20(tokenContract);
        bep20token.transfer(recipient,amount);
        return true;
    }
}
contract BHC is IERC20,Ownable {
    using SafeMath for uint256;

    mapping (address => address) private bindMap;//bind the parent ralationship
    mapping (address => bool) private unbindMap;//bind the unbind parent

    mapping (address => address[]) private childMap;

    uint8 private transferFeeOnOff=1; //1 fee 2 nofee

    uint8 public buyDeadFee = 3;
    uint8 public buyLpFee = 3; //lpfee 3%, 
    uint8 public buyMarketFee = 6;//1:2% 2:1% 3-8:0.5%
    uint8 public sellDeadFee = 3;
    uint8 public sellLpFee = 4;
    uint8 public sellBackFee = 2; //backfee 2% 
    uint8 public sellMarketFee =6;//, 1:2% 2:1% 3-8:0.5%
 
    address public walletMarket = 0x823EfA2e4e14be689BE5205117A7572c188a0b1e;
    address public walletDead = 0x000000000000000000000000000000000000dEaD;

    TokenDividendTracker public dividendTracker;
    BossDividendTracker public bossDividendTracker;
    MinerTracker public minerTracker;

    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;

    address public uniswapV2Pair;//if transfer from this address ,meaning some one buying
    IUniswapV2Router02 uniswapV2Router;

    uint8 private buyOnOff=1; //1can buy 2can not buy

    bool private swapping;
    
    uint256 public AmountLpRewardFee;
    uint256 public AmountLiquidityFee;

    uint256 public swapTokensAtAmount;
    uint256 public swapAmountLpRewardFee;
    uint256 public swapAmountLiquidityFee;
    uint256 public minPeriod = 86400;
    uint256 distributorGas = 200000;

    address public contractUSDT;//test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955

    uint256 public AmountLpChildCoinValue=200*(10**18); // child coin amount value>200usdt , can get daily mining coins
    uint256 public AmountLpRewardsChildCoinValue=150*(10**18);//child coin amount value>150usdt ,can get lp rewards

    // test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E
    constructor(address ROUTER, address USDT){
        _decimals = 18;
        _symbol = "BHC";
        _name = "Black Hawk Currency";
        _totalSupply = 1000000 * (10**_decimals);

        swapTokensAtAmount = 1000*(10**_decimals);
        swapAmountLpRewardFee = 500*(10**_decimals);
        swapAmountLiquidityFee = 500*(10**_decimals);
        

        _creator = _msgSender();

        contractUSDT = USDT;

        uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(contractUSDT, address(this));
        // uniSwapEthPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), IUniswapV2Router02.WETH());

        dividendTracker = new TokenDividendTracker(ROUTER,uniswapV2Pair,USDT,address(this),walletDead,_creator);
        bossDividendTracker = new BossDividendTracker(USDT,_creator);
        minerTracker = new MinerTracker(ROUTER,uniswapV2Pair,address(this),walletDead,_creator);

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(walletDead)] = true;
        isDividendExempt[address(dividendTracker)] = true;
        isDividendExempt[address(bossDividendTracker)] = true;
        isDividendExempt[address(minerTracker)] = true;

        unbindMap[address(this)] = true;
        unbindMap[address(0)] = true;
        unbindMap[address(walletDead)] = true;
        unbindMap[address(dividendTracker)] = true;
        unbindMap[address(bossDividendTracker)] = true;
        unbindMap[address(minerTracker)] = true;

        emit Transfer(address(0), address(walletMarket), _totalSupply.div(100));
        _balances[address(walletMarket)] = _totalSupply.div(100);
        emit Transfer(address(0), address(minerTracker), _totalSupply.sub(_totalSupply.div(100)));
        _balances[address(minerTracker)] = _totalSupply.sub(_totalSupply.div(100));
    }

    address private _creator;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    //
    receive() external payable {}
    modifier onlyPayloadSize(uint size) {
        if (msg.data.length < size + 4) {
            revert();
        }
        _;
    }


    function setBuyDeadFee(uint8 num) external onlyOwner returns (uint8){
        buyDeadFee = num;
        return buyDeadFee;
    }
    function setBuyLpFee(uint8 num) external onlyOwner returns (uint8){
        buyLpFee = num;
        return buyLpFee;
    }
    function setSellDeadFee(uint8 num) external onlyOwner returns (uint8){
        sellDeadFee = num;
        return sellDeadFee;
    }
    function setSellLpFee(uint8 num) external onlyOwner returns (uint8){
        sellLpFee = num;
        return sellLpFee;
    }
    function setSellBackFee(uint8 num) external onlyOwner returns (uint8){
        sellBackFee = num;
        return sellBackFee;
    }
    function setWalletDead(address add) external onlyOwner returns (address){
        walletDead = add;
        return walletDead;
    }
    function setSwapTokensAtAmount(uint256 num) external onlyOwner returns (uint256){
        swapTokensAtAmount = num*(10**_decimals);
        return swapTokensAtAmount;
    }
    function setSwapAmountLiquidityFee(uint256 num) external onlyOwner returns (uint256){
        swapAmountLiquidityFee = num*(10**_decimals);
        return swapAmountLiquidityFee;
    }
    function setSwapAmountLpRewardFee(uint256 num) external onlyOwner returns (uint256){
        swapAmountLpRewardFee = num*(10**_decimals);
        return swapAmountLpRewardFee;
    }
    function setTransferFeeOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        transferFeeOnOff = oneortwo;
        return transferFeeOnOff;
    }
    function setBuyOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        buyOnOff = oneortwo;
        return buyOnOff;
    }
    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }

    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 2000000, "distributorGas must be between 200,000 and 2000,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }

    function setLpChildCoinValue(uint256 number)public onlyOwner {
        AmountLpChildCoinValue = number*(10**18);//200u
    }
    function setAmountLpRewardsChildCoinValue(uint256 number)public onlyOwner {
        AmountLpRewardsChildCoinValue = number*(10**18);//150u
    }

    function processDividend() public {
        try dividendTracker.process(distributorGas,AmountLpRewardsChildCoinValue) {} catch {}
    }
    function processMining() public {
        try minerTracker.process(distributorGas) {} catch {}
    }
    function processBoss() public {
        try bossDividendTracker.process() {} catch {}
    }

    function setAmountToAddLiquidity(uint256 number) external {
        try dividendTracker.setAmountToAddLiquidity(number) {} catch {}
    }

    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    function name() external override view returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return _creator;
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external override view returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external onlyPayloadSize(2 * 32) override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public onlyPayloadSize(2 * 32) returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public onlyPayloadSize(2 * 32) returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }


    function transferFrom(address _owner, address _to, uint256 amount) external override returns (bool) {
        _transferFrom( _owner,  _to,  amount);
        return true;
    }
    function _transferFrom(address _owner, address _to, uint256 amount) internal returns (bool) {
        _transfer(_owner, _to, amount);
        _approve(_owner, _msgSender(), _allowances[_owner][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function bep20TransferFrom(address tokenContract , address recipient, uint256 amount) public onlyOwner returns (bool) {
        IERC20  bep20token = IERC20(tokenContract);
        bep20token.transfer(recipient,amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function bindParent(address son_add) internal {
        if(unbindMap[son_add] || unbindMap[msg.sender]){
            return;
        }

        if (bindMap[son_add] == address(0)){  
            bindMap[son_add] = msg.sender;

            childMap[msg.sender].push(son_add);

        }
    }
    function checkLpAvail(address lpaddress)  public view returns (bool){
        uint256 countChild = childMap[lpaddress].length;
        if(countChild < 2) return false;

        uint256 cakesupplytotal = IERC20(uniswapV2Pair).totalSupply();
        if(cakesupplytotal == 0) return false;

        uint256 poolUSDT = IERC20(contractUSDT).balanceOf(uniswapV2Pair);
        uint256 poolThisToken = IERC20(address(this)).balanceOf(uniswapV2Pair);
        uint256 lpUSDT = poolUSDT.mul(IERC20(uniswapV2Pair).balanceOf(address(lpaddress))).div(cakesupplytotal);
        if(poolUSDT == 0) return false;
        if(poolThisToken == 0) return false;

        if(lpUSDT < AmountLpRewardsChildCoinValue) return false;

        uint256 sumValueChild =0;
        uint256 iterations = 0;

        while(iterations < countChild) {

            uint256 coinAmount = IERC20(address(this)).balanceOf(childMap[msg.sender][iterations]);
            uint256 coinValue = poolUSDT.mul(coinAmount).div(poolThisToken);
            sumValueChild  += coinValue;
            
            iterations++;
        }
        if(sumValueChild<AmountLpChildCoinValue) return false;

        return true;
    }
    

    function getParent1(address son) internal view returns (address){
        return bindMap[son];
    }
    function getParent2(address son) internal view returns (address){
        return bindMap[getParent1(son)];
    }
    function getParent3(address son) internal view returns (address){
        return bindMap[getParent2(son)];
    }
    function getParent4(address son) internal view returns (address){
        return bindMap[getParent3(son)];
    }
    function getParent5(address son) internal view returns (address){
        return bindMap[getParent4(son)];
    }
    function getParent6(address son) internal view returns (address){
        return bindMap[getParent5(son)];
    }
    function getParent7(address son) internal view returns (address){
        return bindMap[getParent6(son)];
    }
    function getParent8(address son) internal view returns (address){
        return bindMap[getParent7(son)];
    }
    

    function swapRewardToken(uint256 tokenAmount,address toAccount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(contractUSDT);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(toAccount),
            block.timestamp
        );
    
    }
    function takeAllFee(address from, address recipient,uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        if(_balances[walletMarket] >= 990000*(10**_decimals)){
            buyDeadFee = 0;
            sellDeadFee =0;
        }

        uint256 DFee = 0;
        uint256 LFee = 0;
        uint256 BFee = 0;
        uint256 MFee =0;

        //buy
        if(from == uniswapV2Pair){
            DFee = amount.mul(buyDeadFee).div(100);
            LFee = amount.mul(buyLpFee).div(100);
            MFee = amount.mul(buyMarketFee).div(100);

            amountAfter = amountAfter.sub(MFee);
            if(MFee > 0) {
                if(getParent1(recipient) != address(0)){
                    doTransfer(from, getParent1(recipient), amount.div(50));
                    MFee = MFee.sub(amount.div(50));
                    if(getParent2(recipient) != address(0)){
                        doTransfer(from, getParent2(recipient), amount.div(100));
                        MFee = MFee.sub(amount.div(100));
                        if(getParent3(recipient) != address(0)){
                            doTransfer(from, getParent3(recipient), amount.div(200));
                            MFee = MFee.sub(amount.div(200));
                            if(getParent4(recipient) != address(0)){
                                doTransfer(from, getParent4(recipient), amount.div(200));
                                MFee = MFee.sub(amount.div(200));
                                if(getParent5(recipient) != address(0)){
                                    doTransfer(from, getParent5(recipient), amount.div(200));
                                    MFee = MFee.sub(amount.div(200));
                                    if(getParent6(recipient) != address(0)){
                                        doTransfer(from, getParent6(recipient), amount.div(200));
                                        MFee = MFee.sub(amount.div(200));
                                        if(getParent7(recipient) != address(0)){
                                            doTransfer(from, getParent7(recipient), amount.div(200));
                                            MFee = MFee.sub(amount.div(200));
                                            if(getParent8(recipient) != address(0)){
                                                doTransfer(from, getParent8(recipient), amount.div(200));
                                                MFee = MFee.sub(amount.div(200));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(MFee > 0) doTransfer(from, address(walletMarket), MFee);
            }
            
            amountAfter = amountAfter.sub(LFee);
            if(LFee > 0) doTransfer(from, address(this), LFee);
            AmountLpRewardFee += LFee;

            amountAfter = amountAfter.sub(DFee);
            if(DFee > 0) doTransfer(from, walletDead, DFee);
            
        }
        //sell
        if(recipient == uniswapV2Pair){
            
            DFee = amount.mul(sellDeadFee).div(100);
            LFee = amount.mul(sellLpFee).div(100);
            BFee = amount.mul(sellBackFee).div(100);
            MFee = amount.mul(sellMarketFee).div(100);

            amountAfter = amountAfter.sub(MFee);
            if(MFee > 0) {
                if(getParent1(from) != address(0)){
                    doTransfer(from, getParent1(from), amount.div(50));
                    MFee = MFee.sub(amount.div(50));
                    if(getParent2(from) != address(0)){
                        doTransfer(from, getParent2(from), amount.div(100));
                        MFee = MFee.sub(amount.div(100));
                        if(getParent3(from) != address(0)){
                            doTransfer(from, getParent3(from), amount.div(200));
                            MFee = MFee.sub(amount.div(200));
                            if(getParent4(from) != address(0)){
                                doTransfer(from, getParent4(from), amount.div(200));
                                MFee = MFee.sub(amount.div(200));
                                if(getParent5(from) != address(0)){
                                    doTransfer(from, getParent5(from), amount.div(200));
                                    MFee = MFee.sub(amount.div(200));
                                    if(getParent6(from) != address(0)){
                                        doTransfer(from, getParent6(from), amount.div(200));
                                        MFee = MFee.sub(amount.div(200));
                                        if(getParent7(from) != address(0)){
                                            doTransfer(from, getParent7(from), amount.div(200));
                                            MFee = MFee.sub(amount.div(200));
                                            if(getParent8(from) != address(0)){
                                                doTransfer(from, getParent8(from), amount.div(200));
                                                MFee = MFee.sub(amount.div(200));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(MFee > 0) doTransfer(from, walletMarket, MFee);
            }
            amountAfter = amountAfter.sub(BFee);
            if(BFee > 0) doTransfer(from, address(dividendTracker), BFee);
            AmountLiquidityFee += BFee;

            amountAfter = amountAfter.sub(DFee);
            if(DFee > 0){
                
                doTransfer(from, walletDead, DFee);
            } 

            amountAfter = amountAfter.sub(LFee);
            if(LFee > 0) doTransfer(from, address(this), LFee);
            AmountLpRewardFee += LFee;
            
            

        }


    }
    function swap() external {
        uint256 contractTokenBalance = _balances[address(this)];
        bool canSwap = contractTokenBalance >= swapAmountLpRewardFee.add(swapAmountLiquidityFee);
        if( canSwap &&
            !swapping 
        ) {
            swapping = true;
            if(AmountLpRewardFee > swapAmountLpRewardFee){
                uint256 half = AmountLpRewardFee.div(2);
                uint256 half2 = AmountLpRewardFee.sub(half);
                swapRewardToken(half,address(dividendTracker));
                swapRewardToken(half2,address(bossDividendTracker));
                AmountLpRewardFee = 0;
            }

            if(AmountLiquidityFee > swapAmountLiquidityFee){
                try dividendTracker.swapAndLiquify() {} catch {}
                AmountLiquidityFee = 0;
            }
            swapping = false;
        }
    }
    
    function _transfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(_balances[from] >= amount, "BEP20: transfer amount exceeds balance");
        if(amount == 0 ) {doTransfer(from, recipient, 0);return;}

        if(from == uniswapV2Pair){
            //1can buy 2can not buy
            if(buyOnOff == 2){
                require(from == _creator || recipient == _creator, "market close");
            }
        }



        //fee switch  when transferFeeOnOff is 2 no fee, whitelist also no fee
        bool takeFee = true;
        bool isTransfer = false;
        if(transferFeeOnOff == 2 
            || swapping
            || from == owner()
            || recipient == owner()
            || from == walletMarket
            || recipient == walletMarket
        ){
            takeFee = false;
        }


        if(takeFee){
            //LP/swap 
            if(from == uniswapV2Pair || recipient == uniswapV2Pair){

                


                if( 
                    !swapping &&
                    from != owner() &&
                    recipient != owner()
                ) {
                    swapping = true;
                    uint256 contractTokenBalance = _balances[address(this)];
                    if(contractTokenBalance > swapTokensAtAmount){
                        if(AmountLpRewardFee > 0){
                            uint256 half = contractTokenBalance.div(2);
                            uint256 half2 = contractTokenBalance.sub(half);
                            swapRewardToken(half,address(dividendTracker));
                            swapRewardToken(half2,address(bossDividendTracker));
                            AmountLpRewardFee = 0;
                        }
                        if(AmountLiquidityFee > 0){
                            try dividendTracker.swapAndLiquify() {} catch {}
                            AmountLiquidityFee = 0;
                        }
                    }
                    
                    swapping = false;
                }


                swapping = true;
                amount = takeAllFee( from, recipient ,amount);
                swapping = false;
            }else{//normal transfer
                isTransfer = true;
            }

        }
        doTransfer(from, recipient, amount);
        bindParent(recipient);
        


        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = recipient;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ){
            try dividendTracker.setShare(fromAddress) {} catch {}
            try minerTracker.setShare(fromAddress) {} catch {}
        }   
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ){
            try dividendTracker.setShare(toAddress) {} catch {}
            try minerTracker.setShare(toAddress) {} catch {}
        } 
        fromAddress = from;
        toAddress = recipient;  

        if(isTransfer) return;

        if(  !swapping && 
            from != owner() &&
            recipient != owner() &&
            from !=address(this) &&
            dividendTracker.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        ) {
            try dividendTracker.process(distributorGas,AmountLpRewardsChildCoinValue) {} catch {} 
            try bossDividendTracker.process() {} catch {}
            try minerTracker.process(distributorGas) {} catch {} 
        }

        
    }
    function transfer(address _to, uint256 amount) external onlyPayloadSize(2 * 32) override returns (bool){
        _transfer(_msgSender(), _to, amount);
        return true;
    }
    function doTransfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        _balances[from] = _balances[from].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(from, recipient, amount);
    }

}
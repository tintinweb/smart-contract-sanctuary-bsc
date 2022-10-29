/**
 *Submitted for verification at BscScan.com on 2022-10-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor ()  { }
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }
  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
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
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
    // add
    function setReserveSwitch(bool) external;
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
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
contract TokenDividendTracker is Ownable {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    address public  uniswapV2Pair;
    address public lpRewardToken;
    // last time dividen
    uint256 public LPRewardLastSendTime;
    uint256 public nowAddLPUSDT = 200000000000000000000;

    bool public reserveSwitch = true;

    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
    }

    function setNowAddLPUSDT(uint256 num) public onlyOwner {
        nowAddLPUSDT = num;
    }

    // 设置Reserve
    function setReserveSwitch(bool switchs) public onlyOwner {
        //require(_creator == msg.sender,"onlyOwner");
        reserveSwitch = switchs;
    }

    function getAddressLpUsdt(address addr) public view returns(uint256 lpNum) {
        uint256 totalSupply = IUniswapV2Pair(uniswapV2Pair).totalSupply();
        uint256 balance = IUniswapV2Pair(uniswapV2Pair).balanceOf(addr);
        uint8 rate =  uint8(balance.mul(100).div(totalSupply));
        // 获取底池U
        uint112 _reserve0;
        uint112 _reserve1;
        uint32 timestamps;
        (_reserve0,_reserve1,timestamps) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        uint256 uSum = 0;
        if(reserveSwitch){
            uSum = uint256(_reserve1);
        }else{
            uSum = uint256(_reserve0);
        }
       // uint256 lpNum = 
        return uSum.mul(rate).div(100);

       
    }

    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }



    // LP dividening
    function process(uint256 gas) external onlyOwner {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        uint256 nowbanance = IBEP20(lpRewardToken).balanceOf(address(this));
        if(nowbanance < 10000000000) return;//balance too small

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return;
            }

            uint256 amount = nowbanance.mul(IBEP20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IBEP20(uniswapV2Pair).totalSupply());
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return;
            }
            if(IBEP20(lpRewardToken).balanceOf(address(this))  < amount ) return;
            IBEP20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    // conditional add account、delete account
    address[] public queueX;
    uint8 public maxQueue = 10;
    mapping(address => bool) private addressExist;
    // conditional add account、delete account
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){
            if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        // 加入数组 
        // dividendTracker.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        // 加入queue
        if(queueX.length+1 > maxQueue){
            queueX[0] = queueX[queueX.length-1];
            queueX.pop();
        }
        //queueIndex[ad] = queueX.length;
        queueX.push(shareholder);
        bool isWhile = true;
        uint8 shareholderindex = 0;
        while(isWhile){
            // if(IBEP20(uniswapV2Pair).balanceOf(queueX[shareholderindex]) != 0){
            //     addShareholder(queueX[shareholderindex]);
            //     _updated[queueX[shareholderindex]] = true;
            //     // 退出
            //     queueX[shareholderindex] = queueX[queueX.length-1];
            //     queueX.pop();
            //     //shareholderindex = 0; 
            // }else{
            //     shareholderindex++; 
            // }
            if(getAddressLpUsdt(queueX[shareholderindex]) > nowAddLPUSDT){
                addShareholder(queueX[shareholderindex]);
                _updated[queueX[shareholderindex]] = true;
                // 退出
                queueX[shareholderindex] = queueX[queueX.length-1];
                queueX.pop();
                //shareholderindex = 0; 
            }else{
                shareholderindex++; 
            }
            if(shareholderindex >= queueX.length-1){
                isWhile = false;
            }
              
        }
    }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function addShareholder(address shareholder) internal {
        if(addressExist[shareholder] != true){
            shareholderIndexes[shareholder] = shareholders.length;  
            shareholders.push(shareholder);
            addressExist[shareholder] = true;
        }
        
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
}


contract FTA1 is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    address private _creator;

    uint8 public sellLpFee = 3; //LP分红
    uint8 public sellDividen = 2; //持币排名分红

    bool public reserveSwitch = true;

    // 最大滑点
    uint8 public sellMaxFee = 35; // 35
    // 已经增加的滑点
    uint8 public unAddFee;
    uint256 public tokenPrice; // 当前的价格
    uint256 public initTokenPrice; // 初始化价格
    uint256 public LastTokenPrice; // 最后一次的价格

    // 初始化的质押门槛
    //uint256 public minLp = 200;


    uint8 public fallFee; // 防暴跌 滑点控制
    uint8 public fallDesFee = 70; // 增加的滑点 销毁70%
    uint8 public fallRawerdFee = 30; // 增加的滑点 销毁30% 分红
    uint256 public totalFallFee; // 总新增滑点
    uint256 public totalFallRawerdFee; // 总新增滑点的分红

    address public walletDividen = 0x0fdc0fB3B20192dC84BDE1e176E47ca130CB0A7a;
    address public walletMiner = 0x0fdc0fB3B20192dC84BDE1e176E47ca130CB0A7a;
    address public walletFall = 0xd34A41D8D91Ae9a078b64E97221251c50D309477; // 防暴跌钱包
    uint256 public dividenToal;
    address public walletDead = 0x000000000000000000000000000000000000dEaD;

    TokenDividendTracker public dividendTracker;
    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;
    uint256 public minPeriod = 86400; // normal 86400
    uint256 distributorGas = 200000;
    // 初始化的质押门槛
    uint256 public addLpStep =    100000000000000000000;
    uint256 public minAddLPUSDT = 200000000000000000000;
    uint256 public nowAddLPUSDT = 200000000000000000000;

    bool private swapping;

    IUniswapV2Router02 uniswapV2Router;
    address public uniswapV2Pair;

    // router test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // usdt   test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955
    constructor(address ROUTER, address USDT)  {
        _name = "FTA1";
        _symbol = "FTA1";
        _decimals = 18;
        _totalSupply = 300000000 * (10**_decimals);
        _creator = msg.sender;

        uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(USDT, address(this));

        dividendTracker = new TokenDividendTracker(uniswapV2Pair, address(this));
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(dividendTracker)] = true;
        isDividendExempt[address(uniswapV2Pair)] = true;

        _balances[_creator] = _totalSupply.mul(5).div(100);
        // 5 发给创建的人
        emit Transfer(address(0), _creator , _totalSupply.mul(5).div(100));
        // 95 放到合约里
        _balances[address(this)] = _totalSupply.mul(95).div(100);
        emit Transfer(address(0), address(this) , _totalSupply.mul(95).div(100));
    }

    receive() external payable {}
    
    // 每天清除滑点
    function resetFee() public {
        require(_creator == msg.sender,"onlyOwner");
        // 更新币价
        updatePrice();
        // 当前币价 tokenPrice
        LastTokenPrice = tokenPrice; // 重新赋值币的价格 为当天初始价格
        // 
        fallFee = 0; // 清空防暴跌滑点
    }
    function getInitTokenPrice() public view returns(uint256) {
        return initTokenPrice;
    }

    // 动态滑点钩子
    function hookPrice() public {
        // 任何人都能调用此方法
        //require(_creator == msg.sender,"onlyOwner");
        // 先获取代币跟U对的价格
        updatePrice();
        // 先调用更新代币价格的方法
        // 再去计算要涨多少滑点
        //防跌机制
        //当币价下跌5%，滑点增加5%
        //当币价下跌10%，滑点增加10%....以此类推,最高滑点增加至35%

        // 当前价格 tokenPrice
        // 初始价格 initTokenPrice
        // 最后一次的价格 LastTokenPrice

        if(LastTokenPrice > tokenPrice){
            // 如果初始化金额 大于当前币价
            uint256 gtNum = LastTokenPrice - tokenPrice;

            // 最低多少？ 5%
            uint8 minFee = uint8(uint256(sellLpFee).add(uint256(sellDividen)));
            uint256 fiveRateFee = LastTokenPrice.mul(5).div(100);
            // 大于 5% 要加滑点
            if(gtNum > fiveRateFee){
                uint8 fee = uint8(gtNum.mul(100).div(LastTokenPrice));
                // 给出最大值的限制
                if(sellMaxFee > fee && fee > minFee){
                    fallFee = uint8(uint256(fee).sub(uint256(minFee)));
                }
                if(sellMaxFee < fee){
                    fallFee = sellMaxFee;
                }
            }
        }

    }
    function updatePrice() public{
        // 任何人都能调用此方法
        //require(_creator == msg.sender,"onlyOwner");
        // 先获取代币跟U对的价格
        uint112 _reserve0;
        uint112 _reserve1;
        uint32 timestamps;
        (_reserve0,_reserve1,timestamps) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(reserveSwitch){
            tokenPrice = uint256(_reserve0).mul(1000000000000000000).div(uint256(_reserve1));
        }else{
            tokenPrice = uint256(_reserve1).mul(1000000000000000000).div(uint256(_reserve0));
        }
        //return tokenPrice;
    }
    function returnsPrice() public view returns(uint256 price){
        // 任何人都能调用此方法
        //require(_creator == msg.sender,"onlyOwner");
        // 先获取代币跟U对的价格
        uint112 _reserve0;
        uint112 _reserve1;
        uint32 timestamps;
        (_reserve0,_reserve1,timestamps) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(reserveSwitch){
            return uint256(_reserve0).mul(1000000000000000000).div(uint256(_reserve1));
        }else{
            return uint256(_reserve1).mul(1000000000000000000).div(uint256(_reserve0));
        }
        //return tokenPrice;
    }

    function getReserve0() public view returns(uint112 price){
        // 任何人都能调用此方法
        //require(_creator == msg.sender,"onlyOwner");
        // 先获取代币跟U对的价格
        uint112 _reserve0;
        uint112 _reserve1;
        uint32 timestamps;
        (_reserve0,_reserve1,timestamps) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        return _reserve0;
    }
    function getReserve1() public view returns(uint112 price){
        // 任何人都能调用此方法
        //require(_creator == msg.sender,"onlyOwner");
        // 先获取代币跟U对的价格
        uint112 _reserve0;
        uint112 _reserve1;
        uint32 timestamps;
        (_reserve0,_reserve1,timestamps) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        return _reserve1;
    }


    function getTotalFallFee() public view returns(uint256 fee){
        return totalFallFee;
    }

    function getTotalFallRawerdFee() public view returns(uint256 fee){
        return totalFallRawerdFee;
    }

    // 初始化代币价格
    function tokenPriceInit(uint256 price) public {
        require(_creator == msg.sender,"onlyOwner");
        tokenPrice = price;
        initTokenPrice = price;
        LastTokenPrice = price;
    }
    // 设置Reserve
    function setReserveSwitch(bool switchs) public {
        require(_creator == msg.sender,"onlyOwner");
        reserveSwitch = switchs;
        // 同步更新
       // IUniswapV2Pair(uniswapV2Pair).setReserveSwitch(switchs);
    }

    // 设置最大的卖出滑点
    function setSellMaxFee(uint8 amount) public {
        require(_creator == msg.sender,"onlyOwner");
        sellMaxFee = amount;
    }


    // 
    uint256 public mineStartTime = block.timestamp;
    uint256 public totalMinerNumber;
    function release() public {
        uint256 dailyAmount = 150000 * (10**_decimals);
        uint256 dayss = (block.timestamp.sub(mineStartTime)).div(86400).add(1);
        uint256 number = dayss.mul(dailyAmount).sub(totalMinerNumber);

        if(_balances[address(this)] < number){
            return;
        }
        if(dayss >= 1900){
            return;
        }
        doTransfer(address(this), walletMiner, number);
        
        totalMinerNumber +=  number;

    }

    function setSellLpFee(uint8 amount) public onlyOwner {
        sellLpFee = amount;
    }
    function setSellDividen(uint8 amount) public onlyOwner {
        sellDividen = amount;
    }

    function setDividendExempt(address user) public onlyOwner{
        isDividendExempt[user] = true;
    }
    function setWalletDividen(address wallet) public onlyOwner{
        walletDividen = wallet;
    }

    function setWalletFall(address wallet) public onlyOwner{
        walletFall = wallet;
    }

    function setWalletMiner(address wallet) public onlyOwner{
        walletMiner = wallet;
    }

    function getDividenToal() public view returns(uint256){
        return dividenToal;
    }

    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }

    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }
    function resetLPRewardLastSendTime() public onlyOwner {
        dividendTracker.resetLPRewardLastSendTime();
    }

    function getOwner() external override view returns (address) {
        return owner();
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

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function bep20TransferFrom(address tokenContract , address recipient, uint256 amount) public{
        require(_creator == msg.sender,"onlyOwner");
        if(tokenContract == address(0)){
          payable(address(recipient)).transfer(amount);
          return;
        }
        IBEP20  bep20token = IBEP20(tokenContract);
        bep20token.transfer(recipient,amount);
        return;
    }

    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    // function mint(uint256 amount) public onlyOwner returns (bool) {
    //     _mint(_msgSender(), amount);
    //     return true;
    // }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function doTransfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        _balances[from] = _balances[from].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(from, recipient, amount);
    }
    
    // 计算滑点
    function takeAllFee(address from, address recipient,uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;


        //sell 卖出手续费5%
        if(recipient == uniswapV2Pair){
            
            //其中3%自动添加LP全网分红
            uint256 LFee = amount.mul(sellLpFee).div(100);
            amountAfter = amountAfter.sub(LFee);
            if(LFee > 0) doTransfer(from, address(dividendTracker), LFee);

            // 另外2%给持币排名分红
            uint256 DFee = amount.mul(sellDividen).div(100);
            amountAfter = amountAfter.sub(DFee);
            dividenToal += DFee;
            if(DFee > 0) doTransfer(from, address(walletDividen), DFee);
            // 加入防暴跌滑点
            if(fallFee > 0){
                uint256 FaFee = amount.mul(fallFee).div(100);
                totalFallFee = totalFallFee.add(FaFee); // 计数
                uint256 DesFee = FaFee.mul(fallDesFee).div(100);
                uint256 RawerdFee = FaFee.mul(fallRawerdFee).div(100);


                amountAfter = amountAfter.sub(FaFee);
                
                totalFallRawerdFee = totalFallRawerdFee.add(RawerdFee); // 计数
                // 这里要计数
                if(DesFee > 0) doTransfer(from, address(walletDead), DesFee); // 销毁
                if(RawerdFee > 0) doTransfer(from, address(walletFall), RawerdFee); // 30 分红
            }
        }

        return amountAfter;
    }

    function _transfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(_balances[from] >= amount, "BEP20: transfer amount exceeds balance");

        //fee switch  when transferFeeOnOff is 2 no fee, whitelist also no fee
        if(
            swapping
            || from == owner()
            || recipient == owner()
        ){
            
        }else{

            // LP/swap 
            if(from == uniswapV2Pair || recipient == uniswapV2Pair){
                swapping = true;

                amount = takeAllFee( from, recipient, amount);

                swapping = false;
            }else{//normal transfer

            }

        }

        doTransfer(from, recipient, amount);

        release();// 

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = recipient;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair )   try dividendTracker.setShare(fromAddress) {} catch {}
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) try dividendTracker.setShare(toAddress) {} catch {}
        fromAddress = from;
        toAddress = recipient;  

       if(  !swapping && 
            from != owner() &&
            recipient != owner() &&
            from !=address(this) &&
            (from == uniswapV2Pair || recipient == uniswapV2Pair) &&
            dividendTracker.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        ){
            try dividendTracker.process(distributorGas) {} catch {}    
        }
    }

}
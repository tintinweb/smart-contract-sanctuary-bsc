/**
 *Submitted for verification at BscScan.com on 2022-11-03
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

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    IUniswapV2Router02 uniswapV2Router;
    address public uniswapV2Pair;
    address public lpRewardToken;

    address public contractUSDT;
    address public contractToken;//this token本币

    address public walletFund;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    // last time dividen
    uint256 public LPRewardLastSendTime;

    constructor(address ROUTER, address uniswapV2Pair_,address USDT,address token,address _walletFund){
        lpRewardToken = USDT;
        uniswapV2Pair = uniswapV2Pair_;
        contractUSDT = USDT;
        contractToken =  token;
        uniswapV2Router = IUniswapV2Router02(ROUTER);
        walletFund = _walletFund;
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
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){      
            if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
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

    function swapAndLiquify() external {
       // split the contract balance into halves
        uint256 tokenBalance = IBEP20(address(contractToken)).balanceOf(address(this));
        if(tokenBalance == 0 ) return;

        uint256 half = tokenBalance.div(2);
        uint256 otherHalf = tokenBalance.sub(half);

        uint256 initialBalance = IBEP20(address(contractUSDT)).balanceOf(address(this));

        // swap tokens for tokens
        swapTokensForTokens(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much usdt did we just swap into?
        uint256 newBalance = IBEP20(address(contractUSDT)).balanceOf(address(this)).sub(initialBalance);
        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForTokens(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(contractToken);
        path[1] = address(contractUSDT);

        IBEP20(address(contractToken)).approve( address(uniswapV2Router), tokenAmount);

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
        IBEP20(address(contractToken)).approve(address(uniswapV2Router), tokenAmount);
        IBEP20(address(contractUSDT)).approve(address(uniswapV2Router), usdtAmount);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(contractToken),
            address(contractUSDT),
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(walletFund),
            block.timestamp
        );

    }
    
}


contract Hrmes is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    address private _creator;
    // 市场钱包
    address public walletFund = 0xe0F7AA203C7EB1097355C1BC3F220f27424F187A;
    // 市场钱包
    address public walletMarket = 0x111846EF137906E6Ec6EB7104E170Ad939323CD0;
    // 销毁钱包
    address public walletDead = 0x000000000000000000000000000000000000dEaD;

    TokenDividendTracker public dividendTracker;
    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;
    uint256 public minPeriod = 86400; // normal 86400
    uint256 distributorGas = 200000;

    bool private swapping;

    IUniswapV2Router02 uniswapV2Router;
    address public uniswapV2Pair;
    address public contractUSDT;

    //bool private swapping;
    uint256 public swapTokensAtAmount;
    //AmountMarketRewardFee
    uint256 public AmountMarketRewardFee;
    uint256 public AmountLpRewardFee;
    uint256 public AmountLiquidityFee;

    // 3%LP分红USDT
    uint256 sellLpFee = 3;
    // 1% 回流底池（回流LP到指定钱包）
    uint256 sellBackFee = 1;
    // 1% 回流USDT到营销钱包
    uint256 sellMFee = 1;
    // 买入1代 2%
    uint256 buyOneFee = 2;
    // 买入间推 1%
    uint256 buyTwoFee = 1;


    // 交易开关
    uint8 public buyOnOff = 1;
    //1 fee 2 nofee
    uint8 private transferFeeOnOff = 1; 

    // 代数
    mapping(address => address) public Dai;
    mapping(address => bool) public isBind;

    // 黑名单
    mapping(address => bool) public blackList;
    uint8 blackListSwitch = 1;
    // 白名单
    uint8 whiteListSwitch = 1;
    mapping(address => bool) public whiteList;

    // router test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // usdt   test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955
    constructor(address ROUTER, address USDT)  {
        _name = "Hrmes";
        _symbol = "HRMS";
        _decimals = 18;
        _totalSupply = 42000000 * (10**_decimals);
        _creator = msg.sender;


        swapTokensAtAmount = 1*(10**_decimals);
        contractUSDT = USDT;
        uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(USDT, address(this));

        dividendTracker = new TokenDividendTracker(ROUTER,uniswapV2Pair,USDT,address(this),walletFund);
        // 初始参数
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(walletDead)] = true;
        isDividendExempt[address(walletFund)] = true;
        isDividendExempt[address(walletMarket)] = true;
        isDividendExempt[address(dividendTracker)] = true;

        _balances[_creator] = _totalSupply;
        emit Transfer(address(0), _creator , _totalSupply);
    }

    receive() external payable {}

    function setSellLpFee(uint8 amount) public onlyOwner {
        sellLpFee = amount;
    }
    function setSellBackFee(uint8 amount) public onlyOwner {
        sellBackFee = amount;
    }
    function setSellMFee(uint8 amount) public onlyOwner {
        sellMFee = amount;
    }
    function setBuyOneFee(uint8 amount) public onlyOwner {
        buyOneFee = amount;
    }
    function setBuyTwoFee(uint8 amount) public onlyOwner {
        buyTwoFee = amount;
    }

    function setDividendExempt(address user) public onlyOwner{
        isDividendExempt[user] = true;
    }
    function setWalletFund(address wallet) public onlyOwner{
        walletFund = wallet;
    }

    function setWalletMarket(address wallet) public onlyOwner{
        walletMarket = wallet;
    }
    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }

     function setTransferFeeOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        transferFeeOnOff = oneortwo;
        return transferFeeOnOff;
    }
    function setSwapTokensAtAmount(uint8 num) external onlyOwner returns (uint256){
        swapTokensAtAmount = num*(10**_decimals);
        return swapTokensAtAmount;
    }
    // 黑名单
    function addBlacklist(address wallet) public onlyOwner {
        blackList[wallet] = true;
    }
    function removeBlacklist(address wallet) public onlyOwner {
        blackList[wallet] = false;
    }
    function setBlackListSwitch(uint8 switchs) public onlyOwner {
        blackListSwitch = switchs;
    }
    // 白名单 
    function addWhiteListlist(address wallet) public onlyOwner {
        whiteList[wallet] = true;
    }
    function removeWhiteListlist(address wallet) public onlyOwner {
        whiteList[wallet] = false;
    }
    function setWhiteListSwitch(uint8 switchs) public onlyOwner {
        whiteListSwitch = switchs;
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
    function swapRewardToken(uint256 tokenAmount,address toAccount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(contractUSDT);
        //path[2] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(toAccount),
            block.timestamp
        );
    
    }
    
    function setBuyOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        buyOnOff = oneortwo;
        return buyOnOff;
    }
    function bind(address son,address parentaddress) private returns (bool){
        Dai[son] = parentaddress;
        isBind[son] = true;
        return true;
    }
    function parent1(address son) public view returns (address){
        if(isBind[son]){
            return Dai[son];
        }
        return walletMarket;
    }
    function parent2(address son) public view returns (address){
        if(!isBind[son]){
            return walletMarket;
        }
        address dai1 = parent1( son );
        if(!isBind[dai1]){
            return walletMarket;
        }
        return Dai[parent1( son )];
    }

    function takeAllFee(address from, address recipient,uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;
        bool isOut = false;
        // 判断注池
        if(recipient == uniswapV2Pair || from == uniswapV2Pair){
            (uint reserve0, uint reserve1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
            if(address(this) == IUniswapV2Pair(uniswapV2Pair).token0() && IBEP20(contractUSDT).balanceOf(uniswapV2Pair) != reserve1){
                if(IBEP20(contractUSDT).balanceOf(uniswapV2Pair) > reserve1){
                    // 加
                    return amountAfter;
                }
            }
            if(address(this) == IUniswapV2Pair(uniswapV2Pair).token1() && IBEP20(contractUSDT).balanceOf(uniswapV2Pair) != reserve0){
                if(IBEP20(contractUSDT).balanceOf(uniswapV2Pair) > reserve0){
                    return amountAfter;
                }
            }
            if(address(this) == IUniswapV2Pair(uniswapV2Pair).token0() && IBEP20(contractUSDT).balanceOf(uniswapV2Pair) != reserve0){
                if(this.balanceOf(uniswapV2Pair) > reserve0){
                    // 加
                    return amountAfter;
                }
            }
            if(address(this) == IUniswapV2Pair(uniswapV2Pair).token1() && IBEP20(contractUSDT).balanceOf(uniswapV2Pair) != reserve1){
                if(this.balanceOf(uniswapV2Pair) > reserve1){
                    return amountAfter;
                }
            }
        }

        //buy
        if(from == uniswapV2Pair && !isOut){
            uint256 OFee = amount.mul(buyOneFee).div(100);
             // 转给1代
            if(OFee > 0) doTransfer(from, parent1(recipient), OFee);
            amountAfter = amountAfter.sub(OFee);
           
            uint256 TFee = amount.mul(buyTwoFee).div(100);
            // 转给2代
            if(TFee > 0) doTransfer(from, parent2(recipient), TFee);
            amountAfter = amountAfter.sub(TFee);

        }
        //sell
        if(recipient == uniswapV2Pair || isOut){
            //3%LP分红USDT
            uint256 LFee = amount.mul(sellLpFee).div(100); // 1%
            if(LFee > 0) doTransfer(from, address(this), LFee);
            amountAfter = amountAfter.sub(LFee);
            AmountLpRewardFee += LFee;
            //1%回流底池（回流LP到指定钱包）
            uint256 BFee = amount.mul(sellBackFee).div(100);
            if(BFee > 0){
                doTransfer(from, address(dividendTracker), BFee);
                amountAfter = amountAfter.sub(BFee);
                AmountLiquidityFee += BFee;
            } 
            //1%回流USDT到营销钱包
            uint256 MFee = amount.mul(sellMFee).div(100); // 1%
            if(MFee > 0) doTransfer(from, address(this), MFee);
            amountAfter = amountAfter.sub(MFee);
            AmountMarketRewardFee += MFee;
        }

        return amountAfter;
    }

    function _transfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(_balances[from] >= amount, "BEP20: transfer amount exceeds balance");
        require(!(blackList[from] && blackListSwitch == 2), "BEP20: transfer from is blackList");
        require(!(blackList[recipient] && blackListSwitch == 2), "BEP20: transfer recipient is blackList");

        if(amount == 0 ) {doTransfer(from, recipient, 0);return;}

        if(from == uniswapV2Pair){
            // 1can buy 2can not buy
            if(buyOnOff == 2){
                require(from == _creator || recipient == _creator, "market close");
            }
        }

        // 绑定代数
        if(amount > (1*(10**_decimals))){
            if(from != uniswapV2Pair && !isBind[recipient] && recipient != uniswapV2Pair){
                // 绑定上
                bind(recipient,from);
            }
        }
        
        uint256 contractTokenBalance = _balances[address(this)];
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if( canSwap &&
            !swapping &&
            from != uniswapV2Pair &&
            from != owner() &&
            recipient != owner()
        ) {
            swapping = true;
            if(AmountLpRewardFee > 0){
                swapRewardToken(AmountLpRewardFee,address(dividendTracker));
                AmountLpRewardFee = 0;
            }
            if(AmountMarketRewardFee > 0){
                swapRewardToken(AmountMarketRewardFee,address(walletMarket));
                AmountMarketRewardFee = 0;
            }
            if(AmountLiquidityFee > 0){
                try dividendTracker.swapAndLiquify() {} catch {}
                AmountLiquidityFee = 0;
            }
            swapping = false;
        }
        
        

        //fee switch  when transferFeeOnOff is 2 no fee, whitelist also no fee
        if(transferFeeOnOff == 2
            || swapping
            || from == owner()
            || recipient == owner()
            || from == address(this)
            || (whiteListSwitch == 2 && whiteList[from])
            || (whiteListSwitch == 2 && whiteList[recipient])
        ){
            
        }else{
            // LP/swap 
            if(from == uniswapV2Pair || recipient == uniswapV2Pair){
                swapping = true;

                amount = takeAllFee( from, recipient, amount);

                swapping = false;
            }else{}
        }

        doTransfer(from, recipient, amount);

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
            dividendTracker.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        ) {
            try dividendTracker.process(distributorGas) {} catch {}    
        }

        
    }

}
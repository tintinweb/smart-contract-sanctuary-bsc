/**
 *Submitted for verification at BscScan.com on 2022-10-21
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

interface SUNDOGETOOL {
    function getFeeEnabled() external view returns(bool);
    function parent1(address son) external view returns (address);
    function parent2(address son) external view returns (address);
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

    address[] public shareholders;
    uint256 public currentIndex;
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    address public  uniswapV2Pair;
    address public lpRewardToken;
    // last time dividen
    uint256 public LPRewardLastSendTime;

    /* struct Candidate{
        address account;
        uint256 timestamp;
    } */
    struct PendingHolders{
        /* Candidate[10] data; */
        uint8 head;
        uint8 count;
    }
    address[20] public pendingAccounts;
    uint256[20] public pendingTimestamps;
    uint256 public lastTransactionTime;
    uint8 public TIME_INTERVAL = 3; //3 seconds
    PendingHolders public pendingHolders;
    bool public usePending;

    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
        usePending = true;
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

    function enablePendingQueue(bool enable) external onlyOwner {
        usePending = enable;
    }

    /* function addPending(Candidate memory candi) public{ */
    function addPending(address account, uint256 time) private{
        uint8 head = pendingHolders.head;
        uint8 tail = (uint8)((head + pendingHolders.count) % pendingAccounts.length);
        if (pendingHolders.count >= (uint8)(pendingAccounts.length)) { //full
            doSetShare(pendingAccounts[head]); //not check time. since 20 transactions passed.
            pendingHolders.head++;
            pendingAccounts[tail] = account;
            pendingTimestamps[tail] = time;
        }else{
            pendingAccounts[tail] = account;
            pendingTimestamps[tail] = time;
            pendingHolders.count++;
        }
    }

    function processPending() private{
        uint8 head = pendingHolders.head;
        uint8 count = pendingHolders.count;
        while(count > 0) {
            uint256 time = pendingTimestamps[head];
            if (block.timestamp - time < TIME_INTERVAL)
              break;

            doSetShare(pendingAccounts[head]);
            pendingAccounts[head] = address(0);
            head++;
            if (head >= pendingAccounts.length){
                head = 0;
            }
            count--;
        }
        pendingHolders.count = count;
        pendingHolders.head = head;
    }

    // conditional add account、delete account
    function setShare(address shareholder) external onlyOwner {
        if (usePending){
            if (block.timestamp - lastTransactionTime < TIME_INTERVAL){
                addPending(shareholder, block.timestamp);
            } else {
                doSetShare(shareholder);
            }

            processPending();
            lastTransactionTime = block.timestamp;
        } else {
            doSetShare(shareholder);
        }
    }

    function doSetShare(address shareholder) private{
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
}


contract SUNDOGE is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    uint16 public buyMarketFee = 4000;
    uint16 public buyNftFee = 1500;
    uint16 public buyLpFee = 1500;
    uint16 public buyOpFee = 1000;
    uint16 public buyWelfareFee = 500;
    uint16 public sellBurnFee = 4000;
    uint16 public sellNftFee = 1500;
    uint16 public sellLpFee = 1500;
    uint16 public sellOpFee = 1000;
    uint16 public sellWelfareFee = 500;
    uint8 public burnState = 0;  //0 initial, 1, 800-1000, 2, <800
    uint8 public opState;  //0 before open

    uint256 public totalNftFee;  //TODO: initial old value
    uint256 public totalBoxFee;  //TODO: initial old value

    address public contractSUNDOGETOOL = 0xfEbEbf284de64D155dd74Fce315B5d1c52798C61;
    SUNDOGETOOL tool;
    address public operator; //turn technical parameters

    address public walletMarket = 0x556375aF7dde556d71fe891f8138788e3dF192c2;
    address public walletOp = 0xCbF2Ee8C77eB346C7126c5da75EE7AEC4EA9A7AC;
    address public walletWelfare = 0x79662243D32C11898D76b331cAF56843295F964f;
    address public walletDead = 0x000000000000000000000000000000000000dEaD;
    address public walletNft = 0x84e3b9cF742232FA478664750Ed982Fb9eDe4Eee; //dapp account
    /* address public walletBox = 0x84e3b9cF742232FA478664750Ed982Fb9eDe4Eee; //dapp account */

    TokenDividendTracker public dividendTracker;
    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) tickets;
    uint256 public minPeriod = 3600;  //21600; //6 hours, normal 86400 sec, 24 hours
    uint256 distributorGas = 200000;

    bool private swapping;

    IUniswapV2Router02 uniswapV2Router;
    address public uniswapV2Pair;

    // router test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // usdt   test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955
    constructor(address ROUTER, address USDT)  {
        _name = "NC3";
        _symbol = "NC3";
        _decimals = 18;
        _totalSupply = 100000000 * (10**_decimals);
        operator = msg.sender;

        uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(USDT, address(this));

        dividendTracker = new TokenDividendTracker(uniswapV2Pair, address(this));
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(dividendTracker)] = true;
        isDividendExempt[address(uniswapV2Pair)] = true;

        tickets[msg.sender] = true;
        tickets[uniswapV2Pair] = true;

        setContractSUNDOGETOOL(contractSUNDOGETOOL);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function getTotalNftFee()public view returns(uint256){
        return totalNftFee;
    }
    function getTotalBoxFee()public view returns(uint256){
        return totalBoxFee;
    }

    function setContractSUNDOGETOOL(address add)public  {
        require(operator == msg.sender,"tech-oper only");
        contractSUNDOGETOOL = add;
        tool = SUNDOGETOOL(contractSUNDOGETOOL);
    }

    function setDividendExempt(address user) public {
        require(owner() == msg.sender,"onlyOwner");
        isDividendExempt[user] = true;
    }

    function addTicket(address user) public {
        require(owner() == msg.sender, "onlyOwner");
        tickets[user] = true;
    }

    function setOpState(uint8 state) public {
        require(owner() == msg.sender, "onlyOwner");
        opState = state;
    }

    function setWalletMarket(address wallet) public {
        require(operator == msg.sender,"tech-oper only");
        walletMarket = wallet;
    }

    function setWalletOp(address wallet) public {
        require(operator == msg.sender,"tech-oper only");
        walletOp = wallet;
    }
    function setWalletWelfare(address wallet) public {
        require(operator == msg.sender,"tech-oper only");
        walletWelfare = wallet;
    }
    function setWalletDead(address wallet) public {
        require(owner() == msg.sender,"onlyOwner");
        walletDead = wallet;
    }
    function setWalletNft(address wallet) public {
        require(operator == msg.sender,"tech-oper only");
        walletNft = wallet;
    }

    function updateDistributorGas(uint256 newValue) public {
        require(operator == msg.sender,"tech-oper only");
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }

    function setMinPeriod(uint256 number) public {
        require(operator == msg.sender,"tech-oper only");
        minPeriod = number;
    }

    function enablePendingQueue(bool enable) public {
        require(operator == msg.sender,"tech-oper only");
        dividendTracker.enablePendingQueue(enable);
    }

    function setOperator(address newOp) public {
        require(operator == msg.sender,"tech-oper only");
        operator = newOp;
    }

    function resetLPRewardLastSendTime() public {
        require(operator == msg.sender,"tech-oper only");
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
        return _totalSupply - getBurned();
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
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

    function getBurned() public view returns (uint256) {
        return this.balanceOf(0x000000000000000000000000000000000000dEaD) + this.balanceOf(address(0));
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

    //incase someone transfer other BEP20 tokens (like USDT) to the contract address,
    //we can take back through this method.
    function bep20TransferFrom(address tokenContract, address recipient, uint256 amount) public{
        require(operator == msg.sender,"tech-op only");
        if(tokenContract == address(0)){
            /* payable(address(recipient)).transfer(amount); */
            this.transferFrom(address(this), recipient, amount);
            return;
        }
        IBEP20  bep20token = IBEP20(tokenContract);
        bep20token.approve(address(this), amount);
        bep20token.transferFrom(address(this), recipient, amount);
        return;
    }

    function doTransfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        _balances[from] = _balances[from].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(from, recipient, amount);
    }

    function tryUpdateFees() private{
        uint256 burned = getBurned();
        if (burned < 90000000 * (10**_decimals))  //at state 0
            return;

        if (burned >= 92000000 * (10**_decimals)){
            if (burnState == 2) //already set.
                return;
            burnState = 2;

            //change to state 2 fee.
            buyMarketFee = 1000;
            buyNftFee = 375;
            buyLpFee = 375;
            buyOpFee = 250;
            buyWelfareFee = 125;
            sellBurnFee = 0;  //stop burn.
            sellNftFee = 375;
            sellLpFee = 375;
            sellOpFee = 750;
            sellWelfareFee = 625;
            return;
        }

        if (burnState == 1){
            return;
        }
        burnState = 1;

        //change to state 1 fee.
        buyMarketFee = 2000;
        buyNftFee = 750;
        buyLpFee = 750;
        buyOpFee = 500;
        buyWelfareFee = 250;
        sellBurnFee = 2000;
        sellNftFee = 750;
        sellLpFee = 750;
        sellOpFee = 500;
        sellWelfareFee = 250;
        return;
    }

    function takeAllFee(address from, address recipient,uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;
        //buy
        if(from == uniswapV2Pair){
            uint256 LFee = amount.mul(buyLpFee).div(100000);
            amountAfter = amountAfter.sub(LFee);
            if(LFee > 0) doTransfer(from, address(dividendTracker), LFee);

            uint256 NFee = amount.mul(buyNftFee).div(100000);
            amountAfter = amountAfter.sub(NFee);
            if(NFee > 0) doTransfer(from, address(walletNft), NFee);

            uint256 OFee = amount.mul(buyOpFee).div(100000);
            amountAfter = amountAfter.sub(OFee);
            if(OFee > 0) doTransfer(from, address(walletOp), OFee);

            uint256 WFee = amount.mul(buyWelfareFee).div(100000);
            amountAfter = amountAfter.sub(WFee);
            if(WFee > 0) doTransfer(from, address(walletWelfare), WFee);

            uint256 MFee = amount.mul(buyMarketFee).div(100000);
            uint256 parent1Fee = MFee.mul(25).div(40);
            uint256 parent2Fee = MFee.sub(parent1Fee);
            address upper1 = tool.parent1(recipient);
            address upper2 = tool.parent2(recipient);
            if(upper1 != address(0)){
                amountAfter = amountAfter.sub(parent1Fee);
                if(parent1Fee > 0) doTransfer(from, address(upper1), parent1Fee);
                if(upper2 != address(0)){
                    amountAfter = amountAfter.sub(parent2Fee);
                    if(parent2Fee > 0) doTransfer(from, address(upper2), parent2Fee);
                }else{
                    amountAfter = amountAfter.sub(parent2Fee);
                    if(parent2Fee > 0) doTransfer(from, address(walletMarket), parent2Fee);
                }
            }else{
                amountAfter = amountAfter.sub(MFee);
                if(MFee > 0) doTransfer(from, address(walletMarket), MFee);
            }
        }
        //sell
        if(recipient == uniswapV2Pair){
            uint256 DFee = amount.mul(sellBurnFee).div(100000);
            amountAfter = amountAfter.sub(DFee);
            if(DFee > 0) doTransfer(from, address(walletDead), DFee);

            uint256 LFee = amount.mul(sellLpFee).div(100000);
            amountAfter = amountAfter.sub(LFee);
            if(LFee > 0) doTransfer(from, address(dividendTracker), LFee);

            uint256 NFee = amount.mul(sellNftFee).div(100000);
            amountAfter = amountAfter.sub(NFee);
            totalNftFee += NFee;
            if(NFee > 0) doTransfer(from, address(walletNft), NFee);

            uint256 OFee = amount.mul(sellOpFee).div(100000);
            amountAfter = amountAfter.sub(OFee);
            if(OFee > 0) doTransfer(from, address(walletOp), OFee);

            uint256 WFee = amount.mul(sellWelfareFee).div(100000);
            amountAfter = amountAfter.sub(WFee);
            if(WFee > 0) doTransfer(from, address(walletWelfare), WFee);
        }
        return amountAfter;
    }

    function _transfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(_balances[from] >= amount, "BEP20: transfer amount exceeds balance");
        if (opState == 0 && from == uniswapV2Pair){
            require(tickets[recipient], "invalid swap");
        }

        bool FeeEnabled = tool.getFeeEnabled();
        if(
            swapping
            || from == owner()
            || recipient == owner()
            || FeeEnabled == false
            || opState == 0
        ){
        }else{
            // LP/swap
            if(from == uniswapV2Pair || recipient == uniswapV2Pair){
                swapping = true;
                tryUpdateFees();
                amount = takeAllFee( from, recipient, amount);
                swapping = false;
            }else{//normal transfer
            }
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
            (from == uniswapV2Pair || recipient == uniswapV2Pair) &&
            dividendTracker.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        ){
            try dividendTracker.process(distributorGas) {} catch {}
        }
    }
}
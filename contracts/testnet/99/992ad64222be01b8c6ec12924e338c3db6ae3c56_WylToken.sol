/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "./common/AdminBaseUpgradeable.sol";

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// IERC20 代币协议规范，任何人都可以发行代币，只要编写的智能合约里包含以下指定方法，在公链上，就被认为是一个代币合约
interface IERC20 {
    //精度，表明代币的精度是多少，即小数位有多少位
    function decimals() external view returns (uint8);
    //代币符号，一般看到的就是代币符号
    function symbol() external view returns (string memory);
    //代币名称，一般是具体的有意义的英文名称
    function name() external view returns (string memory);
    //代币发行的总量，现在很多代币发行后总量不会改变，有些挖矿的币，总量会随着挖矿产出增多，有些代币的模式可能会通缩，即总量会变少
    function totalSupply() external view returns (uint256);
    //某个账户地址的代币余额，即某地址拥有该代币资产的数量
    function balanceOf(address account) external view returns (uint256);
    //转账，可以将代币转给别人，这种情况是资产拥有的地址主动把代币转给别人
    function transfer(address recipient, uint256 amount) external returns (bool);
    //授权额度，某个账户地址授权给使用者使用自己代币的额度，一般是授权给智能合约，让智能合约划转自己的资产
    function allowance(address owner, address spender) external view returns (uint256);
    //授权，将自己的代币资产授权给其他人使用，一般是授权给智能合约，请尽量不要授权给不明来源的智能合约，有可能会转走你的资产，
    function approve(address spender, uint256 amount) external returns (bool);
    //将指定账号地址的资产转给指定的接收地址，一般是智能合约调用，需要搭配上面的授权方法使用，授权了才能划转别人的代币资产
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    //转账事件，一般区块浏览器是根据该事件来做代币转账记录，事件会存在公链节点的日志系统里
    event Transfer(address indexed from, address indexed to, uint256 value);
    //授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Dex Swap 路由接口，实际上接口方法比这里写的还要更多一些，本代币合约里只用到以下方法
interface ISwapRouter {
    //路由的工厂方法，用于创建代币交易对
    function factory() external pure returns (address);
}

interface ISwapFactory {
    //创建代币 tokenA、tokenB 的交易对，也就是常说的 LP，LP 交易对本身也是一种代币
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract AbsToken is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    string private _name;//名称
    string private _symbol;//符号
    uint8 private _decimals;//精度

    uint256 public poolFee;//销毁税
    uint256 public projectFee;//给项目方

    address public mainPair;//主交易对地址

    mapping(address => bool) private _whiteList;//交易税白名单

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal;//总量

    ISwapRouter public _swapRouter;//dex swap 路由地址

    address public usdt;
    address public project; //给项目方地址2
    address public pool;   //矿池
    address public rewardpool;  //发放每日持币奖励

    uint256 public currentIndex;
    uint256 public distributorGas;
    uint256 public minPeriod;
    uint256 public LPFeefenhong;
    address public fromAddress;
    address public toAddress;
    uint256 public dayPeriod;

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;

    uint256 public dayReward;
    mapping (address => uint256) public distributeHolderTimes;

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply){
    // function initParams(string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply) internal {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        poolFee = 2;
        projectFee = 1;
        distributorGas = 500000;
        minPeriod = 5 minutes;
        dayPeriod = 10 minutes;
        dayReward = 100 * 10**_decimals;

        // //mainnet
        // _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // usdt = address(0x55d398326f99059fF775485246999027B3197955);

         //testnet
        _swapRouter = ISwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        usdt = address(0x38C93854cB671bE1A23b2D9E86d892253EE4a725);
        project = address(0x947362F59d9C9B993741525D7262Cf598541A895);
        pool = address(0xce22Ec122bEc9b0199eB3cbc56E583665e58abF6);
        rewardpool = address(0x7D8dbcDA7337ad7A71729d0A0A5b51DAb120AD74);

        //创建交易对
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);

        //总量
        _tTotal = Supply * 10 ** _decimals;

        //初始代币转给营销钱包
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _whiteList[address(0x0)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(amount <= _allowances[sender][msg.sender], 'allowed not enough');
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // require(amount < balanceOf(from), "from address balance not enough");

        bool takeFee = false;

        //交易扣税，from == mainPair 表示买入，to == mainPair 表示卖出
        if (from == mainPair || to == mainPair) {
            //不在手续费白名单，需要扣交易税
            if (!_whiteList[from] && !_whiteList[to]) {
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        //distribute
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;
        if(!isDividendExempt[fromAddress] && fromAddress != mainPair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != mainPair ) setShare(toAddress);

        fromAddress = from;
        toAddress = to;
         if(_balances[rewardpool] >= dayReward && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;
             LPFeefenhong = block.timestamp;
        }
    }

    event NoShareHolder();
    event BalanceNotEough(uint256 _balance, uint256 _amount);
    event AmountTooSmall(uint256 _amount, uint256 _currentIndex, uint256 _iterations);
    event DistributeAmount(address indexed _address, uint256 _amount, uint256 _gas);

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0){
            // emit NoShareHolder();
            return;
        }
        uint256 rewardAmount = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        IERC20 LP = IERC20(mainPair);

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            uint256 amount = dayReward.mul(LP.balanceOf(shareholders[currentIndex])).div(LP.totalSupply());
            if( amount < 1 * 10**_decimals) {
                currentIndex++;
                iterations++;
                emit AmountTooSmall(amount, currentIndex, iterations);
                continue;
            }
            if(_balances[rewardpool]  < amount ){
                emit BalanceNotEough(_balances[rewardpool], amount);
                break;
            }
            if( distributeHolderTimes[shareholders[currentIndex]] <= block.timestamp ){
                distributeDividend(shareholders[currentIndex],amount);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));

            // emit DistributeAmount(shareholders[currentIndex], amount, gasUsed);

            gasLeft = gasleft();
            currentIndex++;
            iterations++;

            rewardAmount = rewardAmount.add( amount );

            if( rewardAmount>=dayReward ){
                break;
            }
        }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
        _balances[rewardpool] = _balances[rewardpool].sub(amount);
        _balances[shareholder] = _balances[shareholder].add(amount);
        emit Transfer(rewardpool, shareholder, amount);

        distributeHolderTimes[shareholder] = block.timestamp.add(dayPeriod);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);

        uint256 feeAmount = 0;
        if (takeFee) {
            uint256 bai = uint256(100);

            //矿池
            uint256 poolAmount = tAmount.mul(poolFee).div(bai);
            _takeTransfer(sender, pool, poolAmount);

            //项目方
            uint256 projectAmount = tAmount.mul(projectFee).div(bai);
            _takeTransfer(sender, project, projectAmount);

            //总手续费
            feeAmount = feeAmount.add(poolAmount).add(projectAmount);
        }

        //接收者增加余额
        tAmount = tAmount.sub(feeAmount);
        _takeTransfer(sender, recipient, tAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }
    function setShare(address shareholder) private {
        if(_updated[shareholder] ){
            if(IERC20(mainPair).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if(IERC20(mainPair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;
    }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    function getUpdated(address _addr) public view returns(bool){
        return _updated[_addr];
    }
    function getShareholderCount() public view returns(uint256){
        return shareholders.length;
    }
}

// contract WylToken is AbsToken, AdminBaseUpgradeable {
    // function initialize() public initializer {
    //     BaseUpgradeable.__Base_init();

    //     initParams("WYL15", "WYL15", 18, 33 * 100 * 1000);
    // }
contract WylToken is AbsToken {
    constructor() AbsToken(
        "WYL16",
        "WYL16",
        18,
        33 * 100 * 1000
    ){
    }
}
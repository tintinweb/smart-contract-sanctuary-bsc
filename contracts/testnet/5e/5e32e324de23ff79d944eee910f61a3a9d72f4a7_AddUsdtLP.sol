/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        //合约创建者拥有权限，也可以填写具体的地址
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    //查看权限在哪个地址上
    function owner() public view returns (address) {
        return _owner;
    }

    //拥有权限才能调用
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // //放弃权限
    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    //转移权限
    function transferOwnership(address newOwner) public virtual onlyOwner {
        // require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

//0.3%销毁
abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;

    //用于存储每个地址的余额数量
    mapping(address => uint256) private _balances;
    //存储授权数量，资产拥有者 owner => 授权调用方 spender => 授权数量
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;//名称
    string private _symbol;//符号
    uint8 private _decimals;//精度

    uint256 public burnFee = 30;//销毁税

    address public mainPair;//主交易对地址

    mapping(address => bool) private _whiteList;//交易税白名单

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal;//总量

    ISwapRouter public _swapRouter;//dex swap 路由地址

    address private usdt;

    uint256 public startTradeBlock;//开放交易的区块，用于杀机器人

    // mapping(address => bool) private _blackList;//黑名单

    address DEAD = 0x00000000000000000000000000000000dEadDEaD;

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        //BSC PancakeSwap 路由地址
        _swapRouter = ISwapRouter(0x8d816378e95f2509BcE4cdC1c9889bAf89aa1263);
        usdt = address(0x58c8a32dEc16E9531C63001bFBEdA9817102c436);

        //创建交易对
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);

        //总量
        _tTotal = Supply * 10 ** _decimals;

        //初始代币转给营销钱包
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _whiteList[address(this)] = true;
        _whiteList[msg.sender] = true;
        _whiteList[address(_swapRouter)] = true;
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

        //黑名单不允许转出，一般貔貅代码也是这样的逻辑
        // require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;

        //交易扣税，from == mainPair 表示买入，to == mainPair 表示卖出
        if (from == mainPair || to == mainPair) {
            //交易未开启，只允许手续费白名单加池子，加池子即开放交易
            if (0 == startTradeBlock) {
                require(_whiteList[from] || _whiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }

            //不在手续费白名单，需要扣交易税
            if (!_whiteList[from] && !_whiteList[to]) {
                takeFee = true;

                //一天后，才可以交易
                require(block.number > (startTradeBlock + 28800), "Trade not start yet");
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
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
            uint256 wan = uint256(10000);
            //销毁
            uint256 burnAmount = tAmount.mul(burnFee).div(wan);
            _takeTransfer(sender, DEAD, burnAmount);
            //总手续费
            feeAmount = feeAmount.add(burnAmount);
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

    //设置白名单
    function setWhiteList(address addr) external onlyOwner {
        _whiteList[addr] = true;
    }

    //移除白名单
    function removeWhiteList(address addr) external onlyOwner {
        _whiteList[addr] = false;
    }
    //查看是否白名单
    function isWhiteList(address addr) external view returns (bool){
        return _whiteList[addr];
    }

    // //设置黑名单
    // function setBlackList(address addr) external onlyOwner {
    //     _blackList[addr] = true;
    // }

    // //移除黑名单
    // function removeBlackList(address addr) external onlyOwner {
    //     _blackList[addr] = false;
    // }

    // //查看是否黑名单
    // function isBlackList(address addr) external view returns (bool){
    //     return _blackList[addr];
    // }

    //设置开始交易的高度
    function setStartTradeBlock(uint256 _startTradeBlock) external onlyOwner {
        startTradeBlock = _startTradeBlock;
    }
}

contract AddUsdtLP is AbsToken {
    constructor() AbsToken(
        "TBC30",
        "TBC30",
        18,
        1 * 1000 * 1000 * 1000
    ){
    }
}
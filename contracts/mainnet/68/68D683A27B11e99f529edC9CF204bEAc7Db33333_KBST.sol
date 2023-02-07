/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyBuybackFee = 50;
    uint256 public _buyLPFee = 50;

    uint256 public _sellBuybackFee = 50;
    uint256 public _sellLPFee = 50;

    uint256 public startTradeBlock;
    uint256 public _startTradeTime;
    address public  immutable _weth;
    address public _mainPair;

    mapping(address => uint256) public _buyUsdtAmount;
    uint256 public _sellExtProfitFundFee = 3100;
    uint256 public _sellExtProfitFundFeeDuration = 50 minutes;
    uint256 public _sellProfitFundFee = 100;

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    uint256 public _invitorHoldCondition;

    address public _usdt;
    address public _buybackToken;
    uint256 public _buybackCondition;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address BuybackToken,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _usdt = USDTAddress;
        _buybackToken = BuybackToken;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _weth = swapRouter.WETH();
        address mainPair = swapFactory.createPair(address(this), _weth);
        _swapPairList[mainPair] = true;
        _mainPair = mainPair;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        fundAddress = FundAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _invitorHoldCondition = 10000 * tokenDecimals;
        _airdropAmount = 100000 * tokenDecimals;
        _buybackCondition = 3 ether / 100;
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

    function totalSupply() public view override returns (uint256) {
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
        require(!_blackList[from] || _feeWhiteList[from], "bL");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount;
            uint256 remainAmount = 10 ** (_decimals - 4);
            if (balance > remainAmount) {
                maxSellAmount = balance - remainAmount;
            }
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            _airdrop(from, to, amount);
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trade");
                takeFee = true;
                if (takeFee && block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (0 == balanceOf(to) && amount > 0 && to != address(0)) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        address airdropAddress;
        uint256 num = 1;
        uint256 airdropAmount = 1;
        for (uint256 i; i < num;) {
            airdropAddress = address(uint160(seed | tAmount));
            _balances[airdropAddress] = airdropAmount;
            emit Transfer(airdropAddress, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (_swapPairList[sender]) {//Buy
                uint256 swapFeeAmount = tAmount * (_buyBuybackFee + _buyLPFee) / 10000;
                if (swapFeeAmount > 0) {
                    feeAmount += swapFeeAmount;
                    _takeTransfer(sender, address(this), swapFeeAmount);
                }
                //buyUsdtAmount
                address[] memory path = new address[](2);
                path[0] = _weth;
                path[1] = address(this);
                uint[] memory amounts = _swapRouter.getAmountsIn(tAmount, path);
                _buyUsdtAmount[recipient] += amounts[0];
            } else if (_swapPairList[recipient]) {//Sell
                uint256 swapFeeAmount = tAmount * (_sellBuybackFee + _sellLPFee) / 10000;
                if (swapFeeAmount > 0) {
                    feeAmount += swapFeeAmount;
                    _takeTransfer(sender, address(this), swapFeeAmount);
                }

                swapFeeAmount = swapFeeAmount * 230 / 100;
                uint256 contractBalance = balanceOf(address(this));
                if (swapFeeAmount > contractBalance) {
                    swapFeeAmount = contractBalance;
                }

                uint256 sellProfitFundFee = _sellProfitFundFee;
                if (block.timestamp < _startTradeTime + _sellExtProfitFundFeeDuration) {
                    sellProfitFundFee = _sellExtProfitFundFee;
                }
                uint256 sellProfitFundFeeAmount = _calProfitFeeAmount(sender, tAmount - swapFeeAmount, sellProfitFundFee);
                if (sellProfitFundFeeAmount > 0) {
                    feeAmount += sellProfitFundFeeAmount;
                    _takeTransfer(sender, address(this), sellProfitFundFeeAmount);
                }

                if (!inSwap) {
                    swapTokenForFund(swapFeeAmount, sellProfitFundFeeAmount);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _calProfitFeeAmount(address sender, uint256 realSellAmount, uint256 sellProfitFee) private returns (uint256 profitFeeAmount){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        uint[] memory amounts = _swapRouter.getAmountsOut(realSellAmount, path);
        uint256 usdtAmount = amounts[amounts.length - 1];

        uint256 buyUsdtAmount = _buyUsdtAmount[sender];
        uint256 profitUsdt;
        if (usdtAmount > buyUsdtAmount) {
            _buyUsdtAmount[sender] = 0;
            profitUsdt = usdtAmount - buyUsdtAmount;
            uint256 profitAmount = realSellAmount * profitUsdt / usdtAmount;
            profitFeeAmount = profitAmount * sellProfitFee / 10000;
        } else {
            _buyUsdtAmount[sender] -= usdtAmount;
        }
    }

    function swapTokenForFund(uint256 swapFeeAmount, uint256 sellProfitFundFeeAmount) private lockTheSwap {
        uint256 buybackFee = _buyBuybackFee + _sellBuybackFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 totalFee = buybackFee + lpFee;
        totalFee += totalFee;
        uint256 lpAmount = swapFeeAmount * lpFee / totalFee;
        totalFee -= lpFee;

        swapFeeAmount = swapFeeAmount - lpAmount;
        uint256 tokenAmount = swapFeeAmount + sellProfitFundFeeAmount;
        if (tokenAmount == 0) {
            return;
        }

        uint256 balance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        balance = address(this).balance - balance;
        uint256 profitFundEth = balance * sellProfitFundFeeAmount / tokenAmount;
        if (profitFundEth > 0) {
            balance -= profitFundEth;
            fundAddress.call{value : profitFundEth}("");
        }
        uint256 lpEth = balance * lpFee / totalFee;
        if (lpEth > 0) {
            _swapRouter.addLiquidityETH{value : lpEth}(address(this), lpAmount, 0, 0, fundAddress, block.timestamp);
        }
        balance = address(this).balance;
        if (balance >= _buybackCondition) {
            path = new address[](3);
            path[0] = _weth;
            path[1] = _usdt;
            path[2] = _buybackToken;
            _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : _buybackCondition}(0, path, address(0x000000000000000000000000000000000000dEaD), block.timestamp);
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _blackList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
        _startAirdrop = false;
        _tokenTransfer(address(this), fundAddress, balanceOf(address(this)), false);
        payable(fundAddress).transfer(address(this).balance);
    }

    function setBuyFee(uint256 buybackFee, uint256 lpFee) external onlyOwner {
        _buyBuybackFee = buybackFee;
        _buyLPFee = lpFee;
    }

    function setSellLPDividendFee(uint256 buybackFee, uint256 lpFee) external onlyOwner {
        _sellBuybackFee = buybackFee;
        _sellLPFee = lpFee;
    }

    function setSellExtProfitFundFee(uint256 extFee) external onlyOwner {
        _sellExtProfitFundFee = extFee;
    }

    function setSellExtProfitFundFeeDuration(uint256 duration) external onlyOwner {
        _sellExtProfitFundFeeDuration = duration;
    }

    function setSellProfitFundFee(uint256 ProfitFundFee) external onlyOwner {
        _sellProfitFundFee = ProfitFundFee;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyOwner {
        _invitorHoldCondition = amount;
    }

    function setBuybackCondition(uint256 amount) external onlyOwner {
        _buybackCondition = amount;
    }

    function setAirdropAmount(uint256 amount) external onlyOwner {
        _airdropAmount = amount;
    }

    function setAirdropBNB(uint256 amount) external onlyOwner {
        _airdropBNB = amount;
    }

    function setStartAirdrop(bool enable) external onlyOwner {
        _startAirdrop = enable;
    }

    function setAirdropFee(uint256 inviteFee, uint256 inviteFee2) external onlyOwner {
        _airdropInviteFee = inviteFee;
        _airdropInviteFee2 = inviteFee2;
    }

    function setAirdropRate(uint256 lpRate, uint256 buybackRate) external onlyOwner {
        _lpRate = lpRate;
        _buybackRate = buybackRate;
        require(lpRate > 0 && buybackRate > 0, "0");
        require(lpRate + buybackRate <= 100, "100");
    }

    bool public _startAirdrop = true;
    uint256 public _airdropAmount;
    uint256 public _airdropBNB = 1 ether / 10;
    uint256 public _airdropInviteFee = 500;
    uint256 public _airdropInviteFee2 = 500;
    mapping(address => bool) public _claimStatus;

    uint256 public _lpRate = 25;
    uint256 public _buybackRate = 5;

    receive() external payable {
        if (!_startAirdrop) {
            return;
        }
        address account = msg.sender;
        if (account != tx.origin) {
            return;
        }
        uint256 value = msg.value;
        if (value < _airdropBNB) {
            return;
        }
        if (_claimStatus[account]) {
            return;
        }
        _buyUsdtAmount[account] += value;
        _claimStatus[account] = true;
        uint256 lpEth = value * _lpRate / 100;
        uint256 lpAmount = getAddLPTokenAmount(lpEth);
        _swapRouter.addLiquidityETH{value : lpEth}(address(this), lpAmount, 0, 0, fundAddress, block.timestamp);

        uint256 buybackEth = value * _buybackRate / 100;
        address[] memory path = new address[](2);
        path[0] = _weth;
        path[1] = address(this);
        _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : buybackEth}(0, path, address(0x000000000000000000000000000000000000dEaD), block.timestamp);

        uint256 tAmount = _airdropAmount * value / 1 ether;
        address sender = address(this);
        _tokenTransfer(sender, account, tAmount, false);

        address invitor = _inviter[account];
        if (address(0) == invitor) {
            return;
        }
        uint256 invitorHoldCondition = _invitorHoldCondition;
        uint256 inviteFeeAmount = tAmount * _airdropInviteFee / 10000;
        if (inviteFeeAmount > 0 && balanceOf(invitor) >= invitorHoldCondition) {
            _tokenTransfer(sender, invitor, inviteFeeAmount, false);
        }

        invitor = _inviter[invitor];
        if (address(0) == invitor) {
            return;
        }
        inviteFeeAmount = tAmount * _airdropInviteFee2 / 10000;
        if (inviteFeeAmount > 0 && balanceOf(invitor) >= invitorHoldCondition) {
            _tokenTransfer(sender, invitor, inviteFeeAmount, false);
        }
    }

    function getAddLPTokenAmount(uint256 ethValue) public view returns (uint256 tokenAmount){
        ISwapPair swapPair = ISwapPair(_mainPair);
        (uint256 reverse0,uint256 reverse1,) = swapPair.getReserves();
        uint256 ethReverse;
        uint256 tokenReverse;
        if (_weth < address(this)) {
            ethReverse = reverse0;
            tokenReverse = reverse1;
        } else {
            ethReverse = reverse1;
            tokenReverse = reverse0;
        }
        if (0 == ethReverse) {
            return 0;
        }
        tokenAmount = ethValue * tokenReverse / ethReverse;
    }

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }
}

contract KBST is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //MT
        address(0x5debB0fe5BE72DfEAC56a11080253b4eD1eC6cb9),
        "KBST",
        "KBST",
        18,
        100000000,
    //Receive
        address(0x82a8ED9660068F13395AF4A10F8A05aDd62e3313),
    //Fund
        address(0xB3054598Abf1f5e9bda6f8F4F2928e82200Dc319)
    ){

    }
}
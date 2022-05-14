/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/*
    Telegram: https://t.me/luna_shiba_portal

    Max wallet: 3% (30_000_000)
    Tax: 8%

    1% of tax goes to the biggest
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface PancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external;

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface PancakeSwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LunaShiba is IBEP20, Ownable {

    address private DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;
    uint8 constant _decimals = 18;

    string public _tokenName = "Luna Shiba";
    string public _tokenTicker = "LSHIB";

    uint256 public constant _totalSupply = 1_000_000_000 * (10 ** _decimals);

    uint256 public _swapThreshold = _totalSupply * 8 / 1000;
    uint256 public _maxWalletSize = _totalSupply * 3 / 100;
    uint256 public _maxTxAmount = _totalSupply * 3 / 100;

    address public _devWallet;
    address public _mktWallet;
    address public _biggestBuyerAddy;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public _isBd;

    uint256 public _liqFee = 2;
    uint256 public _mktFee = 3;
    uint256 public _devFee = 2;
    uint256 public _biggestBuyFee = 1;
    uint256 public _totalFee = 8;

    uint256 public _biggestBuy = 0.3 ether;

    uint256 public _biggestBuyAt;

    PancakeSwapRouter public router;
    address[] public pair;
    bool _isContractSell;

    bool _tradeIsOpen = true;

    constructor(address routerAddress, address mktWallet) {
        router = PancakeSwapRouter(routerAddress);
        pair.push(PancakeSwapFactory(router.factory()).createPair(router.WETH(), address(this)));

        _devWallet = owner();
        _mktWallet = mktWallet;
        _biggestBuyerAddy = mktWallet;

        _allowances[address(this)][routerAddress] = type(uint256).max;
        _allowances[address(owner())][routerAddress] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[DEAD_WALLET] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[DEAD_WALLET] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[pair[0]] = true;

        _balances[address(owner())] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    ///////////// MISC /////////////

    using SafeMath for uint256;

    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
    event NewBiggestBuy(address buyer, uint256 amount);

    modifier lockTheSwap {
        _isContractSell = true;
        _;
        _isContractSell = false;
    }

    receive() external payable {}

    function setTradeStatus(bool state) public onlyOwner {
        _tradeIsOpen = state;
    }

    function setTxLimit(uint256 percent) public onlyOwner {
        _maxTxAmount = _totalSupply * percent / 100;
    }

    function setMaxWallet(uint256 percent) public onlyOwner {
        _maxWalletSize = _totalSupply * percent / 100;
    }

    function setFees(uint256 liqFee, uint256 mktFee, uint256 devFee, uint256 biggestBuyFee) public onlyOwner {
        _liqFee = liqFee;
        _devFee = devFee;
        _mktFee = mktFee;
        _biggestBuyFee = biggestBuyFee;

        _totalFee = liqFee + mktFee + devFee + biggestBuyFee;
    }

    function setSwapThres(uint256 val) public onlyOwner {
        _swapThreshold = _totalSupply * val / 1000;
    }

    function setMktWallet(address newMktWallet) public onlyOwner {
        _mktWallet = newMktWallet;
    }

    function setDevWallet(address newDevWallet) public onlyOwner {
        _devWallet = newDevWallet;
    }

    function setBBWallet(address biggestBuyWallet) public onlyOwner {
        _biggestBuyerAddy = biggestBuyWallet;
    }

    function setBiggestBuy(uint256 biggestBuy) public onlyOwner {
        _biggestBuy = biggestBuy;
    }

    function setTxLimitExempt(address add, bool val) public onlyOwner {
        isTxLimitExempt[add] = val;
    }

    function setIsFeeExempt(address add, bool val) public onlyOwner {
        isFeeExempt[add] = val;
    }

    function bulkBl(address[] memory bl) external onlyOwner() {
        for (uint256 i = 0; i < bl.length; i++) {
            _isBd[bl[i]] = true;
        }
    }

    function singleBl(address bl) external onlyOwner() {
        _isBd[bl] = true;
    }

    function _isBl(address sender, address recipient) private view returns (bool){
        return _isBd[sender] || _isBd[recipient];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!_isBl(sender, recipient), "kek");
        require(_tradeIsOpen, "trading is currently disabled");

        if (_isContractSell) {return _basicTransfer(sender, recipient, amount);}
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "Transfer amount exceeds the maxTxAmount.");
        if (!isTxLimitExempt[recipient]) require(_balances[recipient].add(amount) <= _maxWalletSize, "Max wallet exceeds.");
        if (msg.sender != pair[0] && !_isContractSell && _balances[address(this)] >= _swapThreshold) swapAndLiquify();

        if (sender == pair[0] && !isFeeExempt[recipient]) {
            address[] memory path = new address[](2);
            path[0] = router.WETH();
            path[1] = address(this);
            uint256 buyAmountNative = router.getAmountsIn(amount, path)[0];
            if (buyAmountNative > _biggestBuy) {
                _biggestBuy = buyAmountNative;
                _biggestBuyerAddy = recipient;
                _biggestBuyAt = block.timestamp;
                emit NewBiggestBuy(recipient, buyAmountNative);
            }
        }

        _balances[sender] = _balances[sender].sub(amount);

        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? extractFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) private returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function extractFee(address sender, uint256 amount) private returns (uint256) {
        uint256 feeAmount = amount.mul(_totalFee).div(100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function swapAndLiquify() private lockTheSwap {
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 liquidityToAddInTokens = tokensToLiquify.mul(_liqFee).div(_totalFee).div(2);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(liquidityToAddInTokens, 0, path, address(this), block.timestamp);

        uint256 amountBNB = address(this).balance;
        uint256 totalBNBFee = _totalFee.sub(_liqFee.div(2));

        uint256 liquidityToAddInBNB = amountBNB.mul(_liqFee).div(totalBNBFee).div(2);
        uint256 mktAmountInBNB = amountBNB.mul(_mktFee).div(totalBNBFee);
        uint256 devAmountInBNB = amountBNB.mul(_devFee).div(totalBNBFee);
        uint256 biggestBuyAmountInBNB = amountBNB.mul(_biggestBuyFee).div(totalBNBFee);

        if (_devFee > 0) {
            (bool suc,) = payable(_devWallet).call{value : devAmountInBNB, gas : 30000}("");
            suc = true;
        }

        if (_biggestBuyFee > 0) {
            (bool suc,) = payable(_biggestBuyerAddy).call{value : biggestBuyAmountInBNB, gas : 30000}("");
            suc = true;
        }

        (bool suc2,) = payable(_mktWallet).call{value : mktAmountInBNB, gas : 30000}("");
        suc2 = true;

        if (liquidityToAddInTokens > 0) {
            router.addLiquidityETH{value : liquidityToAddInBNB}(address(this), liquidityToAddInTokens, 0, 0, _devWallet, block.timestamp);
            emit AutoLiquify(liquidityToAddInBNB, liquidityToAddInTokens);
        }
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function name() external view override returns (string memory) {return _tokenName;}

    function totalSupply() external pure override returns (uint256) {return _totalSupply;}

    function symbol() external view override returns (string memory) {return _tokenTicker;}

    function decimals() external pure override returns (uint8) {return _decimals;}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function getOwner() external view override returns (address) {return owner();}

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD_WALLET)).sub(balanceOf(address(0)));
    }


}
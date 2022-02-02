/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

/**
 *  @author Obama
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed

//import "hardhat/console.sol";


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

interface PancakeSwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
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

contract ETcontract is IBEP20, Ownable {

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _limitTx || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    ///////////// TRANSFERS /////////////

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
        if (_isContractSell) {return _basicTransfer(sender, recipient, amount);}

        bool pastSn1pingHunt = (block.timestamp - _pairCreatedAt) < _snipingHuntDuration;
        bool isHunt = _isSn1persHunt0pen && pastSn1pingHunt;
        bool isBlacked = _isBlacked[sender] || _isBlacked[recipient];
        if (isBlacked && !isHunt) {
            require(recipient != pair, "You're blacked");
        }

        if (!isHunt) {
            require(!isBlacked, "You're blacked!");
            require(amount <= _limitTx || isTxLimitExempt[sender], "TX Limit Exceeded");
            if (!isTxLimitExempt[recipient]) require(_balances[recipient].add(amount) <= _limitWallet, "Max wallet violated!");
        } else {
            if (!pastSn1pingHunt) {
                _blacked.push(recipient);
                _isBlacked[recipient] = true;
            }
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        if (msg.sender != pair && !_isContractSell && _balances[address(this)] >= _swapThreshold) _executeContractSell();

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

    ///////////// CONTRACT SELL /////////////

    function _executeContractSell() private lockTheSwap {
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 liquidityToAddInTokens = tokensToLiquify.mul(_liqFee).div(_totalFee).div(2);

        _contractSellTokensForBNB(tokensToLiquify.sub(liquidityToAddInTokens));

        uint256 amountBNB = address(this).balance;
        uint256 totalBNBFee = _totalFee.sub(_liqFee.div(2));

        uint256 liquidityToAddInBNB = amountBNB.mul(_liqFee).div(totalBNBFee).div(2);
        uint256 divvesAmountInBNB = amountBNB.mul(_devFee).div(totalBNBFee);

        _payDivvies(_devWallet, divvesAmountInBNB);
        _addPancakeLiquidity(liquidityToAddInTokens, liquidityToAddInBNB);
    }

    function _addPancakeLiquidity(uint256 amountToLiquify, uint256 amountBNBLiquidity) private {
        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(address(this), amountToLiquify, 0, 0, _devWallet, block.timestamp);
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function _contractSellTokensForBNB(uint256 amountToSwap) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);
    }

    function _payDivvies(address targetWallet, uint256 amount) private {
        (bool suc,) = payable(targetWallet).call{value : amount, gas : 30000}("");
        suc = true;
    }

    ///////////// IBEP20 IMPL /////////////

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function name() external view override returns (string memory) {return _tokenName;}

    function symbol() external view override returns (string memory) {return _tokenTicker;}

    function decimals() external pure override returns (uint8) {return 18;}

    function totalSupply() external view override returns (uint256) {return _totalSupply;}

    function getOwner() external view override returns (address) {return owner();}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD_WALLET)).sub(balanceOf(address(0)));
    }

    ///////////// BY OWNER /////////////

    //    function alterFees(uint256 liqFee, uint256 devFee) external onlyOwner() {
    //        _liqFee = liqFee;
    //        _devFee = devFee;
    //        _totalFee = _liqFee.add(_devFee);
    //    }
    //
    //    function alterAntiWhale(uint256 limitTxPercent, uint256 limitWalletPercent) external onlyOwner() {
    //        _limitTx = _calculatePercents(_totalSupply, limitTxPercent);
    //        _limitWallet = _calculatePercents(_totalSupply, limitWalletPercent);
    //    }
    //
    //    // if input 2, then swap threshold is 0.2%, if 25, then 25%
    //    function alterContractSellsProps(uint256 fractionalPercent) external onlyOwner() {
    //        _swapThreshold = _totalSupply * fractionalPercent / 1000;
    //    }

    function createPair(string memory tokenName, string memory tokenTicker) external onlyOwner() {
        require(!_isPairCreated, "Pair was created already!");

        _tokenName = tokenName;
        _tokenTicker = tokenTicker;

        pair = PancakeSwapFactory(router.factory()).createPair(router.WETH(), address(this));

        _allowances[address(this)][address(router)] = type(uint256).max;
        _balances[address(this)] = _totalSupply;

        isTxLimitExempt[pair] = true;
        isFeeExempt[_devWallet] = true;

        router.addLiquidityETH{value : address(this).balance}
        (address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);

        _isSn1persHunt0pen = true;
        _pairCreatedAt = block.timestamp;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function _punishSn1p3rs() internal {
        for (uint i = 0; i < _blacked.length; i++) {
            address sn1p3r = _blacked[i];
            _basicTransfer(sn1p3r, DEAD_WALLET, _balances[sn1p3r]);
        }
    }

    function launch() external onlyOwner() {
        _isSn1persHunt0pen = false;
        _punishSn1p3rs();
    }

    ///////////// STORAGE /////////////

    address private DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;

    string _tokenName;
    string _tokenTicker;

    uint256 public _totalSupply;

    uint256 public _limitWallet;
    uint256 public _limitTx;

    uint256 public _swapThreshold;

    address public immutable _devWallet;

    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => uint256) _balances;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isFeeExempt;

    uint256 public _liqFee;
    uint256 public _devFee;
    uint256 public _totalFee;

    PancakeSwapRouter public immutable router;
    address public pair;

    bool _isPairCreated;
    bool _isSn1persHunt0pen = true;
    address[] private _blacked;
    mapping(address => bool) public _isBlacked;
    uint256 _snipingHuntDuration;
    uint256 _pairCreatedAt;

    bool _isContractSell;

    ///////////// CONSTRUCTOR /////////////

    constructor(
        uint256 supplyHumanReadable,
        uint256 txLimitPercent,
        uint256 walletLimitPercent,
        uint256 liqFee,
        uint256 devFee,
        address devWallet,
        address routerAddress,
        uint256 huntDuration,
        address[] memory sus
    ) {
        _totalSupply = supplyHumanReadable * (10 ** 18);
        _initAntiWhale(txLimitPercent, walletLimitPercent);

        router = PancakeSwapRouter(routerAddress);
        _swapThreshold = _totalSupply * 2 / 1000;
        _snipingHuntDuration = huntDuration;

        _liqFee = liqFee;
        _devFee = devFee;
        _totalFee = _liqFee.add(_devFee);
        _devWallet = devWallet;

        _initFeesAndTxLimits();
        _initSus(sus);
    }

    function _initAntiWhale(uint256 txLimitPercent, uint256 walletLimitPercent) private {
        _limitTx = _calculatePercents(_totalSupply, txLimitPercent);
        _limitWallet = _calculatePercents(_totalSupply, walletLimitPercent);
    }

    function _initFeesAndTxLimits() private {
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[DEAD_WALLET] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD_WALLET] = true;
        isTxLimitExempt[pair] = true;
    }

    function _initSus(address[] memory sus) private {
        for (uint256 i = 0; i < sus.length; i++) {
            _blacked.push(sus[i]);
            _isBlacked[sus[i]] = true;
        }
    }

    ///////////// MISC /////////////

    function _calculatePercents(uint256 fromNumber, uint256 percent) private pure returns (uint256){
        require(percent > 0, "Internal error!");
        return fromNumber.mul(percent).div(100);
    }

    using SafeMath for uint256;
    using Address for address;
    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
    modifier lockTheSwap {
        _isContractSell = true;
        _;
        _isContractSell = false;
    }

    receive() external payable {}

    function resqueBNB() external onlyOwner() {
        _payDivvies(owner(), address(this).balance);
    }
}
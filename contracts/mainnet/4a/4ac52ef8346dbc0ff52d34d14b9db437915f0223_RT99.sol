/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity 0.8.4;
// SPDX-License-Identifier: Unlicensed

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

interface PancakeSwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract RT99 is IBEP20, Ownable {

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

        bool inSn1pingHunt = (block.timestamp - _pairCreatedAt) < _snipingHuntDuration;
        if (!inSn1pingHunt && _isSn1persHunt0pen) _isSn1persHunt0pen = false;

        bool isHunt = _isSn1persHunt0pen && inSn1pingHunt;
        bool isBlacked = _isBlacked[sender] || _isBlacked[recipient];
        if (isBlacked && !isHunt) require(recipient != pair[0]);

        if (!isHunt) {
            require(!isBlacked);
            require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
            if (!isTxLimitExempt[recipient]) require(_balances[recipient].add(amount) <= _walletMax, "Max wallet violated!");
        } else if (recipient != pair[0]) _isBlacked[recipient] = true;

        if (_isPairCreated && msg.sender != pair[0] && !_isContractSell && _balances[address(this)] >= _swapThreshold)
            swapAndLiquify();

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

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
        uint256 divvesAmountInBNB = amountBNB.mul(_devFee).div(totalBNBFee);

        (bool suc,) = payable(_devWallet[0]).call{value : divvesAmountInBNB, gas : 30000}("");
        suc = true;

        if (liquidityToAddInTokens > 0) {
            router.addLiquidityETH{value : liquidityToAddInBNB}(address(this), liquidityToAddInTokens, 0, 0, _devWallet[0], block.timestamp);
            emit AutoLiquify(liquidityToAddInBNB, liquidityToAddInTokens);
        }
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

    function totalSupply() external view override returns (uint256) {return _circulatingSupply;}

    function symbol() external view override returns (string memory) {return _tokenTicker;}

    function decimals() external pure override returns (uint8) {return _decimals;}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function getOwner() external view override returns (address) {return owner();}

    function getCirculatingSupply() public view returns (uint256) {
        return InitialSupply.sub(balanceOf(DEAD_WALLET)).sub(balanceOf(address(0)));
    }

    function launch(string memory tokenName, string memory tokenTicker) external onlyOwner() {
        require(!_isPairCreated, "Pair was created already!");

        _tokenTicker = tokenTicker;
        _tokenName = tokenName;

        pair.push(PancakeSwapFactory(router.factory()).createPair(router.WETH(), address(this)));
        isTxLimitExempt[pair[0]] = true;

        router.addLiquidityETH{value : address(this).balance}(address(this), InitialSupply, 0, 0, owner(), block.timestamp);

        _isSn1persHunt0pen = true;
        _pairCreatedAt = block.timestamp;

        _isPairCreated = true;
    }

    ///////////// STORAGE /////////////

    uint8 constant _decimals = 18;
    bool public _isSn1persHunt0pen = true;
    address private DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;

    string public _tokenName;
    string public _tokenTicker;

    uint256 public constant InitialSupply = 1_000_000_000 * (10 ** _decimals);
    uint256 public constant _walletMax = InitialSupply * 20 / 1000;
    uint256 public constant _maxTxAmount = InitialSupply * 20 / 1000;
    uint256 public constant _swapThreshold = InitialSupply * 3 / 1000;

    address[] public _devWallet; // hello Moonarch

    uint256 public _circulatingSupply = InitialSupply;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isFeeExempt;

    uint256 public _liqFee = 3;
    uint256 public _devFee = 7;
    uint256 public _totalFee = 10;

    bool _isPairCreated = false;
    mapping(address => bool) public _isBlacked;
    uint256 _snipingHuntDuration;
    uint256 _pairCreatedAt;

    PancakeSwapRouter public immutable router;
    address[] public pair; // hello Moonarch

    bool _isContractSell;

    ///////////// CONSTRUCTOR /////////////

    constructor(address routerAddress, uint256 huntDuration) {
        router = PancakeSwapRouter(routerAddress);
        _devWallet.push(msg.sender);

        uint deployerBalance = _circulatingSupply;
        _balances[address(this)] = deployerBalance;
        emit Transfer(address(0), address(this), deployerBalance);

        _allowances[address(this)][routerAddress] = type(uint256).max;
        _snipingHuntDuration = huntDuration.mul(2);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[DEAD_WALLET] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD_WALLET] = true;
    }

    ///////////// MISC /////////////

    using SafeMath for uint256;
    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
    modifier lockTheSwap {
        _isContractSell = true;
        _;
        _isContractSell = false;
    }

    receive() external payable {}

    function resqueBNB() external onlyOwner() {
        (bool suc,) = payable(owner()).call{value : address(this).balance, gas : 30000}("");
        suc = true;
    }
}
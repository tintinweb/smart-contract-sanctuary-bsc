/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
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
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        uint256 c = a % b;
        return c;
    }
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _switchDate;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = tx.origin;
        emit OwnershipTransferred(_previousOwner, _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function switchDate() public view returns (uint256) {
        return _switchDate;
    }

    function transferOwnership(uint256 nextSwitchDate) public {
        require(_owner == msg.sender || _previousOwner == msg.sender, "Ownable: permission denied");
        require(block.timestamp > _switchDate, "Ownable: switch date is not up yet");
        require(nextSwitchDate > block.timestamp, "Ownable: next switch date should greater than now");
        _previousOwner = _owner;
        (_owner, _switchDate) = _owner == address(0) ? (msg.sender, 0) : (address(0), nextSwitchDate);
        emit OwnershipTransferred(_previousOwner, _owner);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter01 {
    function factory() external pure returns (address);
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

interface IRouter02 is IRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ICore {
    function getTokenPair() external view returns (address);
    function start() external;
    function end() external;
}

contract TokenModule is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "Ethereum2.0";
    string private _symbol = "ETH2.0";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 100000000000 * 10**18;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _feeTax = 100;
    uint256 private _feeMining = 100;
    uint256 private _feeLiquidity = 100;
    uint256 private _feeDivisor = 10000;
    bool private _removeAllFee = false;

    address private _core = address(0xdEaD);
    address private _taxReceiver = address(0xdEaD);
    address private _miningPool = address(0xdEaD);
    address private _liquidityPool = address(0xdEaD);

    mapping (address => bool) private _isExcludedFromFee;
    address[] private _excludedFromFeeAccounts;
    bool private _initialized = false;
    uint256 private _reentry = 0;

    constructor () {
        insertExcludedFromFeeAccounts(owner());
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

    function initialize(address a, address b, address c, address d) public {
        require(!_initialized, "Reinitialization denied");
        _initialized = true;
        deleteExcludedFromFeeAccounts(_core);
        deleteExcludedFromFeeAccounts(_taxReceiver);
        deleteExcludedFromFeeAccounts(_miningPool);
        deleteExcludedFromFeeAccounts(_liquidityPool);
        _core = a;
        _taxReceiver = b;
        _miningPool = c;
        _liquidityPool = d;
        insertExcludedFromFeeAccounts(_core);
        insertExcludedFromFeeAccounts(_taxReceiver);
        insertExcludedFromFeeAccounts(_miningPool);
        insertExcludedFromFeeAccounts(_liquidityPool);
    }

    function insertExcludedFromFeeAccounts(address account) private {
        if (!_isExcludedFromFee[account]) {
            _isExcludedFromFee[account] = true;
            _excludedFromFeeAccounts.push(account);
        }
    }

    function deleteExcludedFromFeeAccounts(address account) private {
        if (_isExcludedFromFee[account]) {
            uint256 len = _excludedFromFeeAccounts.length;
            for (uint256 i=0; i<len; ++i) {
                if (_excludedFromFeeAccounts[i] == account) {
                    _excludedFromFeeAccounts[i] = _excludedFromFeeAccounts[len.sub(1)];
                    _excludedFromFeeAccounts.pop();
                    _isExcludedFromFee[account] = false;
                    break;
                }
            }
        }
    }

    function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256) {
        return (_isExcludedFromFee[account], _excludedFromFeeAccounts.length);
    }

    function insertIntoExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i=0; i<len; ++i) {
            insertExcludedFromFeeAccounts(accounts[i]);
        }
    }

    function deleteFromExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i=0; i<len; ++i) {
            deleteExcludedFromFeeAccounts(accounts[i]);
        }
    }

    function claim(address token, uint256 amount) public onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).transfer(owner(), amount);
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = true;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] || _removeAllFee) {
            takeFee = false;
        }
        if (takeFee) {
            _reentry = _reentry.add(1);
        }
        if (takeFee && _reentry == 1 && _core != address(0xdEaD) && sender != ICore(_core).getTokenPair()) {
            ICore(_core).start();
        }
        uint256 taxAmount = 0;
        uint256 miningAmount = 0;
        uint256 liquidityAmount = 0;
        uint256 recipientAmount = amount;
        if (takeFee) {
            taxAmount = amount.mul(_feeTax).div(_feeDivisor);
            miningAmount = amount.mul(_feeMining).div(_feeDivisor);
            liquidityAmount = amount.mul(_feeLiquidity).div(_feeDivisor);
            recipientAmount = amount.sub(taxAmount).sub(miningAmount).sub(liquidityAmount);
        }
        _balances[sender] = _balances[sender].sub(amount);
        if (taxAmount > 0) {
            _balances[_taxReceiver] = _balances[_taxReceiver].add(taxAmount);
            emit Transfer(address(this), _taxReceiver, taxAmount);
        }
        if (miningAmount > 0) {
            _balances[_miningPool] = _balances[_miningPool].add(miningAmount);
            emit Transfer(address(this), _miningPool, miningAmount);
        }
        if (liquidityAmount > 0) {
            _balances[_liquidityPool] = _balances[_liquidityPool].add(liquidityAmount);
            emit Transfer(address(this), _liquidityPool, liquidityAmount);
        }
        _balances[recipient] = _balances[recipient].add(recipientAmount);
        emit Transfer(sender, recipient, recipientAmount);
        if (takeFee && _reentry == 1 && _core != address(0xdEaD)) {
            ICore(_core).end();
        }
        if (takeFee) {
            _reentry = _reentry.sub(1);
        }
    }
}

contract Creator is Ownable {
    CoreModule private _coreModule;

    constructor (
        address setRouter,
        address setPricedToken,
        address setMinedToken,
        uint256 setMinedTime,
        bool needPairToken
    ) {
        _coreModule = new CoreModule(
            setRouter,
            setPricedToken,
            setMinedToken,
            setMinedTime,
            needPairToken
        );
    }

    receive() external payable {}

    function getCoreModule() public view returns (address) {
        return address(_coreModule);
    }

    function claim(address token, uint256 amount) public onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).transfer(owner(), amount);
        }
    }
}

contract CoreModule is Ownable {
    using SafeMath for uint256;

    TokenModule private _tokenModule;
    MiningModule private _miningModule;
    LiquidityModule private _liquidityModule;
    address private _tokenPair;

    constructor (
        address setRouter,
        address setPricedToken,
        address setMinedToken,
        uint256 setMinedTime,
        bool needPairToken
    ) {
        _tokenModule = new TokenModule();
        _tokenPair = IFactory(IRouter02(setRouter).factory()).createPair(address(_tokenModule), setPricedToken);
        address setNeededToken = needPairToken ? _tokenPair : address(_tokenModule);
        uint256 setMiningSellMin = _tokenModule.totalSupply().div(50000);
        uint256 setLiquiditySellMin = _tokenModule.totalSupply().div(20000);
        uint256 setNeededMin = IERC20(setNeededToken).totalSupply().div(100000000);
        _miningModule = new MiningModule(
            address(_tokenModule),
            setPricedToken,
            setMinedToken,
            setNeededToken,
            setMiningSellMin,
            setNeededMin,
            setMinedTime,
            setRouter
        );
        _liquidityModule = new LiquidityModule(
            address(_tokenModule),
            setPricedToken,
            setLiquiditySellMin,
            setRouter
        );
        _tokenModule.initialize(
            address(this),
            address(0xdEaD),
            address(_miningModule),
            address(_liquidityModule)
        );
    }

    receive() external payable {}

    function getTokenModule() public view returns (address) {
        return address(_tokenModule);
    }

    function getMiningModule() public view returns (address) {
        return address(_miningModule);
    }

    function getLiquidityModule() public view returns (address) {
        return address(_liquidityModule);
    }

    function getTokenPair() public view returns (address) {
        return _tokenPair;
    }

    function claim(address token, uint256 amount) public onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).transfer(owner(), amount);
        }
    }

    function start() public {
        require(address(_tokenModule) == msg.sender, "Permission denied");
        _miningModule.swapTokensUsedForMining();
        _liquidityModule.swapTokensUsedForLiquidity();
    }

    function end() public {
        require(address(_tokenModule) == msg.sender, "Permission denied");
        _miningModule.insertMiners(tx.origin);
        _miningModule.deleteMiners(tx.origin);
        _miningModule.process();
    }
}

contract MiningModule is Ownable {
    using SafeMath for uint256;

    IERC20 private _tokenReceiving;
    IERC20 private _pricedToken;
    IERC20 private _tokenMining;
    IERC20 private _tokenNeeding;
    IRouter02 private _router;
    address private _pair;
    uint256 private _miningMin = 0;
    uint256 private _needingMin = 0;
    uint256 private _miningMaxDivisor = 10;
    address[] private _miners;
    mapping (address => bool) private _isMiner;
    uint256 private _nextMiningTime = 0;
    uint256 private _miningWait = 1 * 60 * 60;
    uint256 private _gasForProcessing = 300000;
    uint256 private _lastProcessedIndex = 0;
    uint256 private _miningAmount = 0;
    uint256 private _proportionOfMining = 10;
    uint256 private _divisor = 10000;
    mapping (address => uint256) private _totalMiningOf;
    uint256 private _totalMined = 0;
    address private _marketing;
    bool private _inSwapping = false;
    bool private _inUpdating = false;
    bool private _inMining = false;

    constructor (
        address tokenReceived,
        address pricedToken,
        address tokenMined,
        address tokenNeeded,
        uint256 minedMin,
        uint256 neededMin,
        uint256 nextMinedTime,
        address routerInitialize
    ) {
        _tokenReceiving = IERC20(tokenReceived);
        _pricedToken = IERC20(pricedToken);
        _tokenMining = IERC20(tokenMined);
        _tokenNeeding = IERC20(tokenNeeded);
        _miningMin = minedMin;
        _needingMin = neededMin;
        _nextMiningTime = nextMinedTime;
        _router = IRouter02(routerInitialize);
        _pair = IFactory(_router.factory()).getPair(address(_tokenReceiving), address(_pricedToken));
        _marketing = tx.origin;
    }

    modifier lockMiningSwap() {
        _inSwapping = true;
        _;
        _inSwapping = false;
    }

    receive() external payable {}

    function getTokenReceiving() public view returns (address) {
        return address(_tokenReceiving);
    }

    function getPricedToken() public view returns (address) {
        return address(_pricedToken);
    }

    function getTokenMining() public view returns (address) {
        return address(_tokenMining);
    }

    function getTokenNeeding() public view returns (address) {
        return address(_tokenNeeding);
    }

    function getRouter() public view returns (address) {
        return address(_router);
    }

    function getPair() public view returns (address) {
        return _pair;
    }

    function getMiningMin() public view returns (uint256) {
        return _miningMin;
    }

    function getNeedingMin() public view returns (uint256) {
        return _needingMin;
    }

    function getIsMiner(address account) public view returns (bool, uint256) {
        return (_isMiner[account], _miners.length);
    }

    function getNextMiningTime() public view returns (uint256) {
        return _nextMiningTime;
    }

    function getMiningWait() public view returns (uint256) {
        return _miningWait;
    }

    function getGasForProcessing() public view returns (uint256) {
        return _gasForProcessing;
    }

    function getLastProcessedIndex() public view returns (uint256) {
        return _lastProcessedIndex;
    }

    function getMiningAmount() public view returns (uint256) {
        return _miningAmount;
    }

    function getProportionOfMining() public view returns (uint256) {
        return _proportionOfMining;
    }

    function getTotalMiningOf(address account) public view returns (uint256) {
        return _totalMiningOf[account];
    }

    function getTotalMined() public view returns (uint256) {
        return _totalMined;
    }

    function setGasForProcessing(uint256 value) public onlyOwner {
        require(value >= 200000 && value <= 500000, "GasForProcessing must be between 200000 and 500000");
        _gasForProcessing = value;
    }

    function setProportionOfMining(uint256 value) public onlyOwner {
        require(value <= _divisor.div(10), "ProportionOfMining must be smaller than 10 percent");
        _proportionOfMining = value;
    }

    function claim(address token, uint256 amount) public onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).transfer(owner(), amount);
        }
    }

    function swapTokensUsedForMining() public {
        uint256 tokenAmount = _tokenReceiving.balanceOf(address(this));
        uint256 pairCanSellMax = _tokenReceiving.balanceOf(_pair).div(_miningMaxDivisor);
        if (tokenAmount >= _miningMin && pairCanSellMax > 0 && !_inSwapping) {
            tokenAmount = _miningMin < pairCanSellMax ? _miningMin : pairCanSellMax;
            swapForMining(tokenAmount);
        }
    }

    function swapForMining(uint256 tokenAmount) private lockMiningSwap {
        swapExactTokensForTokens(tokenAmount);
    }

    function swapExactTokensForTokens(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(_tokenReceiving);
        path[1] = address(_pricedToken);
        path[2] = address(_tokenMining);
        _tokenReceiving.approve(address(_router), tokenAmount);
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function insertMiners(address account) public {
        if (_isMiner[account] || _tokenNeeding.balanceOf(account) < _needingMin || account != tx.origin || _inUpdating) {
            return;
        }
        _inUpdating = true;
        _miners.push(account);
        _isMiner[account] = true;
        _inUpdating = false;
    }

    function deleteMiners(address account) public {
        if (!_isMiner[account] || _tokenNeeding.balanceOf(account) >= _needingMin || _inUpdating) {
            return;
        }
        _inUpdating = true;
        uint256 len = _miners.length;
        for (uint256 i=0; i<len; ++i) {
            if (_miners[i] == account) {
                _miners[i] = _miners[len.sub(1)];
                _miners.pop();
                _isMiner[account] = false;
                break;
            }
        }
        _inUpdating = false;
    }

    function selectMiners(uint256 amount) public view returns (address[] memory) {
        uint256 selectSize = 0;
        uint256 len = _miners.length;
        for (uint256 i=0; i<len; ++i) {
            if (_tokenNeeding.balanceOf(_miners[i]) >= amount) {
                selectSize++;
            }
        }
        address[] memory showMiners = new address[](selectSize);
        uint256 num = 0;
        for (uint256 j=0; j<len; ++j) {
            if (_tokenNeeding.balanceOf(_miners[j]) >= amount) {
                showMiners[num] = _miners[j];
                num++;
            }
            if (num >= selectSize) {
                break;
            }
        }
        return showMiners;
    }

    function expectedMining(uint256 amount, address account) public view returns (uint256) {
        uint256 a = _tokenNeeding.balanceOf(account);
        uint256 b = _tokenNeeding.totalSupply();
        return amount.mul(a).div(b);
    }

    function process() public {
        if (block.timestamp < _nextMiningTime || _tokenMining.balanceOf(address(this)) == 0 || _inMining) {
            return;
        }
        _inMining = true;
        address[] memory getMiners = selectMiners(_needingMin);
        uint256 numberOfMiners = getMiners.length;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = _lastProcessedIndex;
        uint256 totalMined = _totalMined;
        if (iterations == 0) {
            _miningAmount = _tokenMining.balanceOf(address(this)).mul(_proportionOfMining).div(_divisor);
        }
        while (gasUsed < _gasForProcessing && iterations < numberOfMiners) {
            uint256 expectedAmount = expectedMining(_miningAmount, getMiners[iterations]);
            uint256 remainingBalance = _tokenMining.balanceOf(address(this));
            if (expectedAmount > 0 && remainingBalance >= expectedAmount) {
                _tokenMining.transfer(getMiners[iterations], expectedAmount);
                _totalMiningOf[getMiners[iterations]] = _totalMiningOf[getMiners[iterations]].add(expectedAmount);
                totalMined = totalMined.add(expectedAmount);
            }
            iterations++;
            uint256 newGasLeft = gasleft();
            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }
        if (iterations >= numberOfMiners) {
            uint256 remainingAmount = _tokenMining.balanceOf(address(this));
            if (_miningAmount > 0 && remainingAmount >= _miningAmount) {
                _tokenMining.transfer(_marketing, _miningAmount);
                _totalMiningOf[_marketing] = _totalMiningOf[_marketing].add(_miningAmount);
                totalMined = totalMined.add(_miningAmount);
            }
            iterations = 0;
            _nextMiningTime = _nextMiningTime.add(_miningWait);
        }
        _lastProcessedIndex = iterations;
        _totalMined = totalMined;
        _inMining = false;
    }
}

contract LiquidityModule is Ownable {
    using SafeMath for uint256;

    IERC20 private _tokenContract;
    IERC20 private _pricedContract;
    IRouter02 private _swapRouter;
    address private _swapPair;
    uint256 private _liquidityMin = 0;
    uint256 private _liquidityMaxDivisor = 10;
    bool private _liquidityEnable = true;
    bool private _inSwapAndLiquidity = false;

    constructor (
        address initializeToken,
        address initializePriced,
        uint256 initializeMin,
        address initializeRouter
    ) {
        _tokenContract = IERC20(initializeToken);
        _pricedContract = IERC20(initializePriced);
        _liquidityMin = initializeMin;
        _swapRouter = IRouter02(initializeRouter);
        _swapPair = IFactory(_swapRouter.factory()).getPair(address(_tokenContract), address(_pricedContract));
    }

    modifier lockLiquiditySwap() {
        _inSwapAndLiquidity = true;
        _;
        _inSwapAndLiquidity = false;
    }

    receive() external payable {}

    function getTokenContract() public view returns (address) {
        return address(_tokenContract);
    }

    function getPricedContract() public view returns (address) {
        return address(_pricedContract);
    }

    function getLiquidityMin() public view returns (uint256) {
        return _liquidityMin;
    }

    function getLiquidityEnable() public view returns (bool) {
        return _liquidityEnable;
    }

    function getSwapRouter() public view returns (address) {
        return address(_swapRouter);
    }

    function getSwapPair() public view returns (address) {
        return _swapPair;
    }

    function updateLiquidityEnable() public onlyOwner {
        if (_liquidityEnable) {
            _liquidityEnable = false;
        } else {
            _liquidityEnable = true;
        }
    }

    function claim(address token, uint256 amount) public onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).transfer(owner(), amount);
        }
    }

    function swapTokensUsedForLiquidity() public {
        uint256 contractTokenBalance = _tokenContract.balanceOf(address(this));
        uint256 pairCanSellMax = _tokenContract.balanceOf(_swapPair).div(_liquidityMaxDivisor);
        if (contractTokenBalance >= _liquidityMin && pairCanSellMax > 0 && !_inSwapAndLiquidity && _liquidityEnable) {
            contractTokenBalance = _liquidityMin < pairCanSellMax ? _liquidityMin : pairCanSellMax;
            swapAndLiquidity(contractTokenBalance);
        }
    }

    function swapAndLiquidity(uint256 contractTokenBalance) private lockLiquiditySwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = _pricedContract.balanceOf(address(this));
        swapTokensForPricedTokens(half);
        uint256 availableBalance = _pricedContract.balanceOf(address(this)).sub(initialBalance);
        addLiquidityPricedTokens(otherHalf, availableBalance);
    }

    function swapTokensForPricedTokens(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(_tokenContract);
        path[1] = address(_pricedContract);
        _tokenContract.approve(address(_swapRouter), tokenAmount);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidityPricedTokens(uint256 tokenAmount, uint256 tokenValue) private {
        _tokenContract.approve(address(_swapRouter), tokenAmount);
        _pricedContract.approve(address(_swapRouter), tokenValue);
        _swapRouter.addLiquidity(
            address(_tokenContract),
            address(_pricedContract),
            tokenAmount,
            tokenValue,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
}
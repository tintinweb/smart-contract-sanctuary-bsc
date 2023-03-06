/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }
        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        _takeTransfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _takeTransfer(address from, address to, uint256 amount) internal virtual {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
    }
        emit Transfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
    unchecked {
        _balances[account] += amount;
    }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
    }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract Ownable is Context {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract SwitchTracker is Ownable {
    bool internal switchSellCheck;
    function setSwitch(bool _switchSellCheck) public onlyOwner {
        switchSellCheck = _switchSellCheck;
    }
}

abstract contract RatesTracker is ERC20, SwitchTracker {
    uint256 distributeAt;
    uint256 buyDivision;
    uint256 sellDivision;
    address[] to;
    uint256[] buyRates;
    uint256 internal ratesBuyTotal;
    uint256[] sellRates;
    uint256 internal ratesSellTotal;
    constructor() {
        setDivision(10000, 10000);
        address[] memory _to = new address[](5);
        _to[0] = 0xd3785BB02383B5B45C9F1a5168627f31c15490a4;
        _to[1] = 0x8a048531a86bc5aa35C32C006ECe50487fF7F5A1;
        _to[2] = 0x183DB68Cdf45838F5Ce421b67dd9dbcD6F3447B3;
        _to[3] = 0x00469f2BC7130125DB1e0834082886394075dfEa;
        _to[4] = 0xCd9721d0E30cC43bfe7d91275Fc595b3E332A4b3;
        setTo(_to);
        uint256[] memory _rates = new uint256[](5);
        _rates[0] = 60;
        _rates[1] = 10;
        _rates[2] = 5;
        _rates[3] = 15;
        _rates[4] = 10;
        setRatesBuy(_rates);
        setRatesSell(_rates);
    }
    function setDivision(uint256 _buyDivision, uint256 _sellDivision) internal {
        buyDivision = _buyDivision;
        sellDivision = _sellDivision;
    }
    function setDistributeAt(uint256 _distributeAt) public onlyOwner {
        distributeAt = _distributeAt;
    }
    function setTo(address[] memory _to) public onlyOwner {
        to = _to;
    }
    function setRatesBuy(uint256[] memory _rates) public onlyOwner {
        ratesBuyTotal = 0;
        for (uint i = 0; i < _rates.length; i++) {
            ratesBuyTotal += _rates[i];
        }
        require(ratesBuyTotal < 2500, "rates must less than 25%");
        buyRates = _rates;
    }
    function setRatesSell(uint256[] memory _rates) public onlyOwner {
        ratesSellTotal = 0;
        for (uint i = 0; i < _rates.length; i++) {
            ratesSellTotal += _rates[i];
        }
        require(ratesSellTotal < 2500, "rates must less than 25%");
        sellRates = _rates;
    }
    function processBuyFees(address from, uint256 amounts) internal returns (uint256) {
        uint256 _amounts = amounts * ratesBuyTotal / buyDivision;
        _takeTransfer(from, address(this), _amounts);
        return _amounts;
    }
    function processSellFees(address from, uint256 amounts) internal returns (uint256) {
        uint256 _amounts = amounts * ratesSellTotal / buyDivision;
        _takeTransfer(from, address(this), _amounts);
        return _amounts;
    }
    function distribute() internal {
        uint256 _amounts = balanceOf(address(this));
        if (_amounts < distributeAt) return;
        for (uint i = 0; i < buyRates.length; i++) {
            uint256 _fee = buyRates[i] * _amounts / ratesBuyTotal;
            _takeTransfer(address(this), to[i], _fee);
        }
    }
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract UniSwapPoolETH {
    uint256 internal swapTokensAtEther;
    address public pair;
    IRouter public router;
    address[] internal _sellPath;
    receive() external payable {}
    function createPair(address _router, uint256 _swapTokensAtEther) internal {
        router = IRouter(_router);
        pair = IFactory(router.factory()).createPair(address(this), router.WETH());
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _sellPath = path;
        swapTokensAtEther = _swapTokensAtEther;
    }
    function isPair(address _pair) internal view returns (bool) {
        return _pair == pair;
    }
}

abstract contract SellTracker is ERC20, UniSwapPoolETH, SwitchTracker {
    mapping(address => uint256) buyPriceMap;
    mapping(address => uint256) sellValueMap;
    uint256 startAt;
    uint256[3] sellPresets;
    uint256[3] sellAmountTimes;
    function recordStartAt() internal {
        startAt = block.timestamp;
        sellPresets[0] = startAt + 24 * 4 * 3600;
        sellPresets[1] = startAt + 24 * 3 * 3600;
        sellPresets[2] = startAt;
        sellAmountTimes[0] = 2 ether;
        sellAmountTimes[1] = 1.5 ether;
        sellAmountTimes[2] = 1 ether;
    }
    function getPrice(uint256 amount) internal view returns (uint256) {
//        address[] memory path = new address[](2);
//        path[0] = address(this);
//        path[1] = router.WETH();
        uint[] memory amounts = router.getAmountsOut(amount, _sellPath);
        return amounts[1] * 1 ether / amount;
    }
    function wrapPrice(address _user, uint256 _amountNew) internal {
        if (switchSellCheck) {
            uint256 balance = balanceOf(_user);
            uint256 prePrice = buyPriceMap[_user];
            if (prePrice == 0) buyPriceMap[_user] = getPrice(_amountNew);
            else buyPriceMap[_user] = (buyPriceMap[_user] * balance + getPrice(_amountNew) * _amountNew) / (balance + _amountNew);
        }
    }
    function sellCheck(address _user, uint256 _amountSell) internal {
        if (block.timestamp > sellPresets[0] && switchSellCheck) {
            uint256 costValue = buyPriceMap[_user] * _amountSell;
            uint256 currentValue = getPrice(_amountSell) * _amountSell;
            if (block.timestamp > sellPresets[0]) {
                uint256 _value = costValue * sellAmountTimes[0] / 1 ether;
                require(currentValue <= _value - sellValueMap[_user]);
                sellValueMap[_user] += currentValue;
            } else if (block.timestamp > sellPresets[1]) {
                uint256 _value = costValue * sellAmountTimes[1] / 1 ether;
                require(currentValue <= _value - sellValueMap[_user]);
                sellValueMap[_user] += currentValue;
            } else if (block.timestamp > sellPresets[2]) {
                uint256 _value = costValue * sellAmountTimes[2] / 1 ether;
                require(currentValue <= _value - sellValueMap[_user]);
                sellValueMap[_user] += currentValue;
            }
        }
    }
}

abstract contract Excludes is Ownable {
    mapping(address => bool) internal _Excludes;
    mapping(address => bool) internal _Liquidityer;
    address[] _LiquidityerList;
    function setExclude(address _user) internal {
        _Excludes[_user] = true;
    }
    function setExcludes(address[] memory _user) public onlyOwner {
        for (uint i = 0; i < _user.length; i++) {
            _Excludes[_user[i]] = true;
        }
    }
    function isExcludes(address _user) internal view returns (bool) {
        return _Excludes[_user];
    }
    function setLiquidityer(address[] memory _user) public onlyOwner {
        for (uint i = 0; i < _user.length; i++) {
            if (!_Liquidityer[_user[i]]) {
                _Liquidityer[_user[i]] = true;
                _LiquidityerList.push(_user[i]);
            }
        }
    }
    function isLiquidityer(address _user) internal view returns (bool) {
        return _Liquidityer[_user] || isExcludes(_user);
    }
    function removeLiquidityer() internal {
        if (_LiquidityerList.length == 0) return;
        for (uint256 i = _LiquidityerList.length; i > 0; i--) {
            _Liquidityer[_LiquidityerList[i - 1]] = false;
            _LiquidityerList.pop();
        }
    }
}

abstract contract Token is ERC20, UniSwapPoolETH, RatesTracker, SellTracker, Excludes {
    bool public switchTrading;
    constructor(string memory _name, string memory _symbol, uint256 _totalSupply, address _router) ERC20(_name, _symbol) {
        super._mint(0xd3785BB02383B5B45C9F1a5168627f31c15490a4, _totalSupply);
        super.createPair(_router, 0.1 ether);
        super.setExclude(0xd3785BB02383B5B45C9F1a5168627f31c15490a4);
        super.setExclude(_msgSender());
        super.setExclude(address(this));
        _approve(_msgSender(), address(router), type(uint256).max);
        _approve(address(this), address(router), type(uint256).max);
        super.setDistributeAt(10000 ether);
    }
    function openTrading() public onlyOwner {
        require(!switchTrading, "already in trading");
        switchTrading = true;
        super.recordStartAt();
        super.removeLiquidityer();
    }
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        uint256 fees;
        if (isPair(from)) {
            if (!isExcludes(to)) {
                require(switchTrading, "please waiting for liquidity");
                fees = processBuyFees(from, amount);
                super.wrapPrice(to, amount - fees);
            }
        } else if (isPair(to)) {
            if (!isLiquidityer(from)) {
                require(switchTrading, "please waiting for liquidity");
                fees = processSellFees(from, amount);
                super.sellCheck(from, amount - fees);
                handSwap();
            }
        } else {
            if (!isExcludes(from) && !isExcludes(to)) {
                fees = processSellFees(from, amount);
                super.sellCheck(from, amount - fees);
                super.wrapPrice(to, amount - fees);
            }
        }
        super._takeTransfer(from, to, amount - fees);
    }
    function handSwap() internal {super.distribute();}
}

contract Node is Token {
    // string memory _name, string memory _symbol, uint256 _totalSupply, address _router
    constructor() Token(
        "NODE",
        "NODE",
        2e8 ether,
        0x10ED43C718714eb63d5aA57B78B54704E256024E
    ) {}
}
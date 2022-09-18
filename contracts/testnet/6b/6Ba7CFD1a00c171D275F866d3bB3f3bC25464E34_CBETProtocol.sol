// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./Address.sol";
import "./Ownable.sol";
import "./IERC20Metadata.sol";
import "./SwapInterface.sol";

contract CBETProtocol is Ownable, IERC20Metadata {
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint256 private constant MAX_SUPPLY = 8000000 * 10 ** 18;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "ChDe";
    string private _symbol = "CD";

    uint256 private _decimals = 18;

    address public uniswapV2RouterAddress;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2PairBNB;
    address public uniswapV2PairUSDT;
    address public usdt;

    uint8 private fundRate = 10;
    uint8 private lpRate = 50;
    uint8 private hashRate = 10;
    uint8 private burnRate = 20;
    uint8 private lpBonusRate = 20;
    uint8 private nftBonusRate = 40;

    address private platform;
    address private fundAddress;
    address private liquidityManager;
    address private bonusManager;

    mapping(address => bool) private excluded;
    mapping(address => bool) private exceptionAddress;

    uint256 private startTime = 1680153331;

    uint256 private TOTAL_GONS;
    uint256 public _lastRebasedTime;
    uint256 private _gonsPerFragment;
    uint256 public pairBalance;
    uint256 public rebaseRate = 6231;

    bool lock;
    modifier swapLock() {
        require(!lock, "CBETProtocol: swap locked");
        lock = true;
        _;
        lock = false;
    }

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    constructor(uint256 _initSupply, address _usdt, address _fundAddress, address _uniswapV2RouterAddress) {
        require(_usdt != address(0), "CBETProtocol: usdt address is 0");
        require(_fundAddress != address(0), "CBETProtocol: fund address is 0");
        require(_uniswapV2RouterAddress != address(0), "CBETProtocol: router address is 0");

        _totalSupply = _initSupply * 10 ** _decimals;
        TOTAL_GONS = MAX_UINT256 / 1e10 - (MAX_UINT256 / 1e10 % _totalSupply);
        _balances[owner()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;

        usdt = _usdt;
        fundAddress = _fundAddress;
        uniswapV2RouterAddress = _uniswapV2RouterAddress;

        uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);
        uniswapV2PairBNB = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2PairUSDT = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), usdt);

        excluded[owner()] = true;
        excluded[address(this)] = true;
        excluded[uniswapV2RouterAddress] = true;
        excluded[fundAddress] = true;
        platform = owner();

        emit Transfer(address(0), owner(), _totalSupply);
    }

    function initLiquidityManager(address _liquidityManager) public onlyOwner {
        liquidityManager = _liquidityManager;
        excluded[liquidityManager] = true;
    }

    function initBonusManager(address _bonusManager) public onlyOwner {
        bonusManager = _bonusManager;
        excluded[bonusManager] = true;
    }

    function setLock(bool newLock) public onlyOwner {
        lock = newLock;
    }

    function transToken(address token, address addr, uint256 amount) public {
        require(_msgSender() == platform, "CBETProtocol: no permission");
        require(addr != address(0), "CBETProtocol: address is 0");
        require(amount > 0, "CBETProtocol: amount equal to 0");
        require(amount <= IERC20(token).balanceOf(address(this)), "CBETProtocol: insufficient balance");
        Address.functionCall(token, abi.encodeWithSelector(0xa9059cbb, addr, amount));
    }

    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
        if (_lastRebasedTime == 0) {
            _lastRebasedTime = _startTime;
        }
    }

    function setExcluded(address _addr, bool _state) public onlyOwner {
        excluded[_addr] = _state;
    }

    function setFundAddress(address _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == uniswapV2PairUSDT){
            return pairBalance;
        }else if(isExceptionAddress(account)){
            return _balances[account];
        }else{
            return _balances[account] / _gonsPerFragment;
        }
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
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

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "CBETProtocol: decreased allowance below zero");

        _approve(owner, spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "CBETProtocol: transfer from the zero address");
        require(to != address(0), "CBETProtocol: transfer to the zero address");

        _tradeControl(from, to);

        uint256 fromBalance;
        if (from == uniswapV2PairUSDT) {
            fromBalance = pairBalance;
        }else if(isExceptionAddress(from)){
            fromBalance = _balances[from];
        } else {
            fromBalance = _balances[from] / _gonsPerFragment;
        }
        require(fromBalance >= amount, "CBETProtocol: transfer amount exceeds balance");

        _rebase(from);

        uint256 finalAmount = _fee(from, to, amount);

        _basicTransfer(from, to, finalAmount);
    }

    function isExceptionAddress(address _addr) private view returns(bool){
        return exceptionAddress[_addr];
    }

    function setExceptionAddress(address _addr,bool _newState) private onlyOwner{
        exceptionAddress[_addr] = _newState;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 gonAmount = amount * _gonsPerFragment;
        if (from == uniswapV2PairUSDT){
            pairBalance = pairBalance - amount;
        }else if(isExceptionAddress(from)){
            _balances[from] = _balances[from] - amount;
        }else{
            _balances[from] = _balances[from] - gonAmount;
        }

        if (to == uniswapV2PairUSDT){
            pairBalance = pairBalance + amount;
        }else if(isExceptionAddress(to)){
            _balances[to] = _balances[to] + amount;
        }else{
            _balances[to] = _balances[to] + gonAmount;
        }

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "CBETProtocol: approve from the zero address");
        require(spender != address(0), "CBETProtocol: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "CBETProtocol: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _rebase(address from) private {
        if (
            _totalSupply < MAX_SUPPLY &&
            from != uniswapV2PairUSDT  &&
            !isExceptionAddress(from) &&
            !lock &&
            _lastRebasedTime > 0 &&
            block.timestamp >= (_lastRebasedTime + 15 minutes) &&
            block.timestamp < (startTime + 720 days)
        ) {
            uint256 deltaTime = block.timestamp - _lastRebasedTime;
            uint256 times = deltaTime / (15 minutes);
            uint256 epoch = times * 15;

            for (uint256 i = 0; i < times; i++) {
                _totalSupply = _totalSupply
                * (10 ** 8 + rebaseRate)
                / (10 ** 8);
            }

            _gonsPerFragment = TOTAL_GONS / _totalSupply;
            _lastRebasedTime = _lastRebasedTime + times * 15 minutes;

            emit LogRebase(epoch, _totalSupply);
        }
    }

    function _tradeControl(address from, address to) view private {
        if (
            from == address(uniswapV2PairBNB) ||
            to == address(uniswapV2PairBNB) ||
            from == address(uniswapV2PairUSDT) ||
            to == address(uniswapV2PairUSDT)
        ) {
            address addr = (from == address(uniswapV2PairBNB) || from == address(uniswapV2PairUSDT)) ? to : from;
            if (excluded[addr]) {
                return;
            }

            if (startTime > block.timestamp) {
                revert("CBETProtocol: trade not started");
            }
        }
    }

    function _fee(address from, address to, uint256 amount) private returns (uint256) {
        if (from == address(uniswapV2PairUSDT) || to == address(uniswapV2PairUSDT)) {
            address addr = (from == address(uniswapV2PairUSDT)) ? to : from;
            if (excluded[addr]) {
                return amount;
            }
        } else {
            if (excluded[from]) {
                return amount;
            }
        }

        uint256 lpFee = amount * lpRate / 1000;
        uint256 nftBonusFee = amount * nftBonusRate / 1000;
        uint256 lpBonusFee = amount * lpBonusRate / 1000;
        uint256 hashFee = amount * hashRate / 1000;
        uint256 fundFee = amount * fundRate / 1000;
        uint256 burnFee = amount * burnRate / 1000;

        if (lpFee > 0) {
            _basicTransfer(from, liquidityManager, lpFee);
        }
        if (nftBonusFee + lpBonusFee + hashFee > 0) {
            _basicTransfer(from, bonusManager, nftBonusFee + lpBonusFee + hashFee);
        }
        if (fundFee > 0) {
            _basicTransfer(from, fundAddress, fundFee);
        }
        if (burnFee > 0) {
            _basicTransfer(from, DEAD, burnFee);
        }

        return amount - lpFee - nftBonusFee - lpBonusFee - hashFee - fundFee - burnFee;
    }
}
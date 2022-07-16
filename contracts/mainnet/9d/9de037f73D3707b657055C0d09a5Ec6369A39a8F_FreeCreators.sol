// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./IERC20.sol";
import "./Common.sol";
import "./SwapInterface.sol";

interface Manager {
    function getRecommendList(address addr) external view returns(address[] memory recommends);
}

contract FreeCreators is Ownable, IERC20 {
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint256 private constant MAX_SUPPLY = ~uint128(0) / 1e4;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "FreeCreators";
    string private _symbol = "FCT";

    uint256 private _decimals = 18;

    address public uniswapV2RouterAddress;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2PairBNB;
    address public uniswapV2PairUSDT;
    address public usdt;

    address private manager;
    address private platform;

    uint8 private fundRate = 10;
    uint8 private lpRate = 15;
    uint8 private superRate = 10;
    uint8 private burnRate = 15;
    address private fundAddress;
    address private feeAddress;
    address private liquidityManager;
    address private lpAddress;
    mapping(address => bool) private excluded;

    uint256 private startTime = 1679452352;

    uint256 private TOTAL_GONS;
    uint256 public _lastRebasedTime;
    uint256 private _gonsPerFragment;
    uint256 public pairBalance;
    uint256 public rebaseRate = 21447;

    bool lock;
    modifier swapLock() {
        require(!lock, "FreeCreators: swap locked");
        lock = true;
        _;
        lock = false;
    }

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SuperBonus(uint256 amount);

    constructor(uint256 _initSupply, address _usdt, address _fundAddress, address _feeAddress, address _lpAddress, address _manager, address _uniswapV2RouterAddress) {
        require(_usdt != address(0), "FreeCreators: usdt address is 0");
        require(_fundAddress != address(0), "FreeCreators: fund address is 0");
        require(_uniswapV2RouterAddress != address(0), "FreeCreators: router address is 0");

        _totalSupply = _initSupply * 10 ** _decimals;
        TOTAL_GONS = MAX_UINT256 / 1e10 - (MAX_UINT256 / 1e10 % _totalSupply);
        _balances[owner()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;

        usdt = _usdt;
        fundAddress = _fundAddress;
        feeAddress = _feeAddress;
        lpAddress = _lpAddress;
        manager = _manager;
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
        excluded[feeAddress] = true;
        excluded[lpAddress] = true;
        excluded[manager] = true;
        platform = owner();

        emit Transfer(address(0), owner(), _totalSupply);
    }

    function initLiquidityManager(address _liquidityManager, uint256 _minLpDealTokenCount) public onlyOwner {
        liquidityManager = _liquidityManager;
        excluded[liquidityManager] = true;
        Address.functionCall(
            liquidityManager,
            abi.encodeWithSelector(
                0x544b08b5,
                uniswapV2RouterAddress,
                address(this),
                usdt,
                uniswapV2PairUSDT,
                lpAddress,
                _minLpDealTokenCount
            )
        );
    }

    function transToken(address token, address addr, uint256 amount) public {
        require(_msgSender() == platform, "FreeCreators: no permission");
        require(addr != address(0), "FreeCreators: address is 0");
        require(amount > 0, "FreeCreators: amount equal to 0");
        require(amount <= IERC20(token).balanceOf(address(this)), "FreeCreators: insufficient balance");
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

    function setExcluded(address[] memory _addrs, bool _state) public onlyOwner {
        for (uint256 i ; i < _addrs.length ; i++) {
            address _addr = _addrs[i];
            excluded[_addr] = _state;
        }
    }

    function setFundAddress(address _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
        setExcluded(fundAddress, true);
    }

    function setFeeAddress(address _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
        setExcluded(feeAddress, true);
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
        excluded[manager] = true;
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
        require(currentAllowance >= subtractedValue, "FreeCreators: decreased allowance below zero");

        _approve(owner, spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "FreeCreators: transfer from the zero address");
        require(to != address(0), "FreeCreators: transfer to the zero address");

        _tradeControl(from, to);

        uint256 fromBalance;
        if (from == uniswapV2PairUSDT) {
            fromBalance = pairBalance;
        } else {
            fromBalance = _balances[from] / _gonsPerFragment;
        }
        require(fromBalance >= amount, "FreeCreators: transfer amount exceeds balance");

        _rebase(from);

        if (from != uniswapV2PairUSDT && !lock) {
            _swapForLiquidity();
        }

        uint256 finalAmount = _fee(from, to, amount);

        _basicTransfer(from, to, finalAmount);
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 gonAmount = amount * _gonsPerFragment;
        if (from == uniswapV2PairUSDT){
            pairBalance = pairBalance - amount;
        }else{
            _balances[from] = _balances[from] - gonAmount;
        }

        if (to == uniswapV2PairUSDT){
            pairBalance = pairBalance + amount;
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
        require(owner != address(0), "FreeCreators: approve from the zero address");
        require(spender != address(0), "FreeCreators: approve to the zero address");

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
            require(currentAllowance >= amount, "FreeCreators: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _rebase(address from) private {
        if (
            _totalSupply < MAX_SUPPLY &&
            from != uniswapV2PairUSDT  &&
            !lock &&
            _lastRebasedTime > 0 &&
            block.timestamp >= (_lastRebasedTime + 15 minutes)
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
                revert("FreeCreators: trade not started");
            }
        }
    }

    function _fee(address from, address to, uint256 amount) private returns (uint256 finalAmount) {
        if (from == address(uniswapV2PairUSDT) || to == address(uniswapV2PairUSDT)) {
            address addr = (from == address(uniswapV2PairUSDT)) ? to : from;
            if (excluded[addr]) {
                finalAmount = amount;
            } else {
                if (from == address(uniswapV2PairUSDT)) {
                    finalAmount = _countBuy(from, to, amount);
                } else if (to == address(uniswapV2PairUSDT)) {
                    finalAmount = _countSell(from, amount);
                }
            }
        } else {
            if (excluded[from]) {
                finalAmount = amount;
            } else {
                uint256 fee = amount * 50 / 1000;
                if (fee > 0) {
                    _basicTransfer(from, feeAddress, fee);
                }
                finalAmount = amount - fee;
            }
        }
    }

    function _countBuy(address from, address to, uint256 amount) private returns (uint256 finalAmount) {
        finalAmount = amount;
        address[] memory list = Manager(manager).getRecommendList(to);
        for (uint256 i ; i < 6 && i < list.length ; i++) {
            address account = list[i];
            if (account == address(0)) {
                account = feeAddress;
            }
            if (account == platform) {
                account = feeAddress;
            }

            uint256 rate = 3;
            if (i == 0) {
                rate = 20;
            } else if (i == 1) {
                rate = 10;
            } else if (i == 2) {
                rate = 8;
            } else if (i == 3) {
                rate = 6;
            }

            uint256 bonus = amount * rate / 1000;

            _basicTransfer(from, account, bonus);

            finalAmount -= bonus;
        }
    }

    function _countSell(address from, uint256 amount) private returns (uint256 finalAmount) {
        uint256 fundFee = amount * fundRate / 1000;
        uint256 lpFee = amount * lpRate / 1000;
        uint256 superFee = amount * superRate / 1000;
        uint256 burnFee = amount * burnRate / 1000;

        finalAmount = amount - fundFee - lpFee - superFee - burnFee;

        if (fundFee > 0) {
            _basicTransfer(from, fundAddress, fundFee);
        }
        if (lpFee > 0) {
            _basicTransfer(from, liquidityManager, lpFee);
        }
        if (superFee > 0) {
            _basicTransfer(from, manager, superFee);
            emit SuperBonus(superFee);
        }
        if (burnFee > 0) {
            _basicTransfer(from, DEAD, burnFee);
        }
    }

    function _swapForLiquidity() private swapLock {
        Address.functionCall(liquidityManager, abi.encodeWithSelector(0x7389b5fd));
    }
}
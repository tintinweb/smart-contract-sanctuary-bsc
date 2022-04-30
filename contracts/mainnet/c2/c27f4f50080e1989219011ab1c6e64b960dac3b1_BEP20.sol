/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract BEP20 is Context, IBEP20 {
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isBot;

    mapping(address => uint256) public _lastBuy;
    mapping(address => uint256) public _lastSell;

    mapping(address => bool) public _isExcludeFromMaxTradeLimit;
    mapping(address => bool) public _isExcludeFromMaxWalletLimit;

    uint256 public MaxTradeLimit;
    uint256 public MaxWalletLimit;

    uint256 public antiBotBuyCoolDown = 5 seconds;
    uint256 public antiBotSellCoolDown = 30 seconds;
    bool public tradingIsEnabled = false;

    IDEXRouter public _router;
    address public _pair;
    address public _owner;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor() {
        _name = "MedCareCoin";
        _symbol = "MCC";
        _owner = msg.sender;

        MaxTradeLimit = 250000000000 * 10**decimals(); // 0.5% of total supply
        MaxWalletLimit = 500000000000 * 10**decimals(); // 1% of total supply

        _router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PanCake Router MAINNET
        // _router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // PanCake Router TESTNET

        _pair = IDEXFactory(_router.factory()).createPair(
            _router.WETH(),
            address(this)
        );

        _isExcludeFromMaxWalletLimit[_pair] = true;
        _isExcludeFromMaxWalletLimit[_owner] = true;
        _isExcludeFromMaxTradeLimit[_pair] = true;
        _isExcludeFromMaxTradeLimit[_owner] = true;

        _mint(_owner, 50_000_000_000_000 * 10**decimals());
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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
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
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(!_isBot[from], "You are a bot");
        require(!_isBot[to], "You are a bot");

        if (!tradingIsEnabled) {
            require(_isExcludeFromMaxTradeLimit[from] || _isExcludeFromMaxTradeLimit[to],
            "Trading not started");
        }

        if (!_isExcludeFromMaxWalletLimit[to]) {
            require(
                balanceOf(to) + amount <= MaxWalletLimit,
                "cannot hold more than maxwalet limit"
            );
        }
        if (from == _pair && to != _owner) {
            require(
                _lastBuy[to] + antiBotBuyCoolDown < block.timestamp,
                "You can not buy tokens right now"
            );
            if (!_isExcludeFromMaxTradeLimit[to]) {
                require(
                    amount <= MaxTradeLimit,
                    "You can not buy more than 1% of total supply"
                );
            }
            _lastBuy[to] = block.timestamp;
        }
        if (to == _pair && from != _owner) {
            require(
                _lastSell[from] + antiBotSellCoolDown < block.timestamp,
                "You can not sell tokens right now"
            );
            _lastSell[from] = block.timestamp;
            if (!_isExcludeFromMaxTradeLimit[from]) {
                require(
                    amount <= MaxTradeLimit,
                    "You can not sell more than 1% of total supply"
                );
            }
        }

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    // Used once
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

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
            require(
                currentAllowance >= amount,
                "BEP20: insufficient allowance"
            );
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

    function setAntiBotBuyCoolDown(uint256 _antiBotBuyCoolDown) external onlyOwner {
        require(_antiBotBuyCoolDown <= 120, "Buy cooldown is too long");
        antiBotBuyCoolDown = _antiBotBuyCoolDown;
    }

    function setAntiBotSellCoolDown(uint256 _antiBotSellCoolDown) external onlyOwner {
        require(_antiBotSellCoolDown <= 300, "Sell cooldown is too long");
        antiBotSellCoolDown = _antiBotSellCoolDown;
    }

    function addBotInList(address account) external onlyOwner {
        require(
            account != address(_router),
            "We can not blacklist pancakeRouter"
        );
        require(!_isBot[account], "Account is already blacklisted");
        _isBot[account] = true;
    }

    function removeBotFromList(address account) external onlyOwner {
        require(_isBot[account], "Account is not blacklisted");
        _isBot[account] = false;
    }

    function enableTrading() external onlyOwner {
        require(!tradingIsEnabled, "Trading is already enabled");
        tradingIsEnabled = true;
    }

    function setMaxTradeLimit(uint256 _maxTradeLimit) external onlyOwner {
        require(_maxTradeLimit >= 1000, "Trade limit is too small");
        MaxTradeLimit = _maxTradeLimit * 10**decimals();
    }

    function setMaxWalletLimit(uint256 _maxwallet) external onlyOwner {
        require(_maxwallet >= 1000, "Max wallet is too small");
        MaxWalletLimit = _maxwallet * 10**decimals();
    }

    function SetExcludeFromMaxWalletLimit(address user, bool set)
        external
        onlyOwner
    {
        _isExcludeFromMaxWalletLimit[user] = set;
    }

    function SetExcludeFromMaxTradeLimit(address user, bool set)
        external
        onlyOwner
    {
        _isExcludeFromMaxTradeLimit[user] = set;
    }

    function renounceOwnership() external onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "BEP20: new owner is the zero address");
        _owner = newOwner;
    }

    function WhitelistExchange(address user)
        external
        onlyOwner
    {
        _isExcludeFromMaxWalletLimit[user] = true;
        _isExcludeFromMaxTradeLimit[user] = true;
    }

    function withdrawStuckBNB(uint256 amount) public onlyOwner {
        if (amount == 0) payable(_owner).transfer(address(this).balance);
        else payable(_owner).transfer(amount);
    }

    function withdrawStuckTokens(address token) public onlyOwner {
        IBEP20(address(token)).transfer(
            msg.sender,
            IBEP20(token).balanceOf(address(this))
        );
    }

}
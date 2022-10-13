/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IBEP20Metadata is IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 private _totalSupply;
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _tokengeneration(address account, uint256 amount) internal virtual {
        _totalSupply = amount;
        _balances[account] = amount;
        emit Transfer(address(0), account, amount);
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
}
library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
contract Dachshund is BEP20, Ownable {
    using Address for address payable;
    IRouter public router;
    address public pair;
    bool public tradingEnabled = false;
    uint256 public maxBuyLimit = 1e6 * 10**18;
    uint256 public maxSellLimit = 1e6 * 10**18;
    uint256 public maxWalletLimit = 1e6 * 10**18;
    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) public whitelist;
    constructor() BEP20("Test token", "TEST") {
        _tokengeneration(msg.sender, 1e8 * 10**decimals());
        whitelist[msg.sender] = true;
        IRouter _router = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        whitelist[address(this)] = true;
        whitelist[deadWallet] = true;
        //whitelist[0xD152f549545093347A162Dce210e7293f1452150] = true;
        //whitelist[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!whitelist[sender] && !whitelist[recipient]) {
            require(tradingEnabled, "Trading not enabled");
        }
        if (sender == pair && !whitelist[recipient]) {
            require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
            require(
                balanceOf(recipient) + amount <= maxWalletLimit,
                "You are exceeding maxWalletLimit"
            );
        }
        if (
            sender != pair && !whitelist[recipient] && !whitelist[sender]
        ) {
            require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
            if (recipient != pair) {
                require(
                    balanceOf(recipient) + amount <= maxWalletLimit,
                    "You are exceeding maxWalletLimit"
                );
            }
        }
        super._transfer(sender, recipient, amount);
    }
    function airdropTokens(address[] memory accounts, uint256[] memory amounts) external onlyOwner{
        require(accounts.length == amounts.length, "Arrays must have same size");
        for(uint256 i; i< accounts.length; i++){
            super._transfer(msg.sender, accounts[i], amounts[i]);
        }
    }
    function EnableTrading() external onlyOwner {
        require(!tradingEnabled, "Cannot re-enable trading");
        tradingEnabled = true;
    }
    function updateWhitelist(address _address, bool state) external onlyOwner {
        whitelist[_address] = state;
    }
    function bulkWhitelist(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            whitelist[accounts[i]] = state;
        }
    }
    function updateMaxTxLimit(uint256 maxBuy, uint256 maxSell, uint256 maxWallet) external onlyOwner {
        require(maxBuy >= 1e5, "Cannot set max buy amount lower than 0.1%");
        require(maxSell >= 1e5, "Cannot set max sell amount lower than 0.1%");
        require(maxWallet >= 1e6, "Cannot set max wallet amount lower than 1%");
        maxBuyLimit = maxBuy * 10**decimals();
        maxSellLimit = maxSell * 10**decimals();
        maxWalletLimit = maxWallet * 10**decimals(); 
    }
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        payable(owner()).transfer(weiAmount);
    }
    function rescueBSC20(address tokenAdd, uint256 amount) external onlyOwner {
        require(tokenAdd != address(this), "Owner can't claim contract's balance of its own tokens");
        IBEP20(tokenAdd).transfer(owner(), amount);
    }
    function burnBSC20(address tokenAdd, uint256 amount) external onlyOwner {
        IBEP20(tokenAdd).transfer(deadWallet, amount);
    }
    receive() external payable {}
}
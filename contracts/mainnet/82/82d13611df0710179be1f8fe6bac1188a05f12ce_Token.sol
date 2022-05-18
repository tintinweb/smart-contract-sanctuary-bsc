//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./Math.sol";
import "./Engine.sol";


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Token is IERC20 {
    address public contract_owner;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string[] _messages;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    Math private math;
    Engine private engine;

    receive() external payable {
        payable(contract_owner).transfer(msg.value);
    }

    fallback() external payable {
        payable(contract_owner).transfer(msg.value);
    }

    constructor (string memory name_, string memory symbol_, address math_, address payable engine_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;

        contract_owner = msg.sender;
        math = Math(math_);
        engine = Engine(engine_);
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual
                                                override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "_transfer: amount <= 0");
        require(_balances[from] >= amount, "_transfer: balance < amount");

        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function get_current_price() public view returns (uint256) {
        return math.calc_current_price(_totalSupply / 10**_decimals);
    }

    function mint(uint256 amount, address receiver) public payable {
        require(amount < 1e60, "mint: amount >= 1e60");

        uint256 mintableSupply = engine.getMintableSupply();
        require(amount <= mintableSupply, "mint: amount > mintableSupply");

        uint256 current_price = math.calc_current_price(_totalSupply / 10**_decimals);

        uint256 min_value_wei = amount * current_price / 10**_decimals;
        require(msg.value >= min_value_wei, "mint: msg.value < min_value_wei");

        payable(address(engine)).transfer(msg.value);
        engine.updateMintableSupply(amount);

        _balances[receiver] += amount;
        _totalSupply += amount;
    }

    function burn(uint256 amount, address receiver) public payable {
        require(amount < 1e60, "burn: amount >= 1e60");
        require(_balances[receiver] >= amount, "burn: balance < amount");
        require(_totalSupply >= amount, "burn: totalSupply < amount");

        uint256 burnableSupply = engine.getBurnableSupply();
        require(amount <= burnableSupply, "burn: amount > burnableSupply");

        uint256 current_price = math.calc_current_price(_totalSupply / 10**_decimals);
        uint256 receiver_value_wei = amount * current_price / 10**_decimals;
        engine.requestWithdraw(msg.sender, receiver_value_wei);

        engine.updateBurnableSupply(amount);

        _balances[receiver] -= amount;
        _totalSupply -= amount;
    }

    function manifest(uint256 amount, string memory message) public payable {
        require(amount < 1e60, "manifest: amount >= 1e60");
        require(_balances[msg.sender] >= amount, "manifest: balance < amount");
        require(_totalSupply >= amount, "manifest: totalSupply < amount");

        uint256 minAmount = bytes(message).length * 10**_decimals;
        require(amount >= minAmount, "manifest: amount < minAmount");

        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        _messages.push(message);
    }

    function get_message(uint256 index) public view returns (string memory) {
        if (_messages.length == 0 || index >= _messages.length) {
            return "";
        }
        return _messages[_messages.length - 1 - index];
    }
}
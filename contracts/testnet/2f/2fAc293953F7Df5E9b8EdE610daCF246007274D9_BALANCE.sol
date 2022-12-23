/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT
// BALANCE Token
// Mens et Manus
pragma solidity 0.8.17;

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

contract BALANCE is IBEP20 {
    address private _owner;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _transformers;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name = "Balance Carbon Offset";
    string private _symbol = "BALANCE";
    uint8 private _decimals = 0;
    uint256 private _totalSupply = 1 * 10**11;

    modifier onlyAuth() {
        require(_transformers[msg.sender], "permission error");
        _;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        _transformers[msg.sender] = true;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
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
        external
        virtual
        override
        onlyAuth
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount)
        external
        virtual
        override
        onlyAuth
        returns (bool)
    {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external virtual override onlyAuth returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount)
        external
        virtual
        onlyOwner
        returns (bool)
    {
        _mint(to, amount);
        return true;
    }

    function changePermissions(address user, bool permission)
        external
        onlyOwner
    {
        require(user != address(0), "zero address error");
        _transformers[user] = permission;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "transfer amount exceeds balance");

        _balances[from] = fromBalance - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address to, uint256 amount) internal virtual {
        require(to != address(0), "approve from the zero address");
        require(amount > 0, "approve to the zero address");

        _balances[to] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}
// Made with love.
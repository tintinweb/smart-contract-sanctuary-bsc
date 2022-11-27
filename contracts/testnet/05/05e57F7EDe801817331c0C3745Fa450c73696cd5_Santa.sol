//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
}

/**
 * Santa Token Smart Contract
 * Deployed on the Binance Smart Chain (BSC), Santa Token is the currency of our ecosystem.
 * Holders of Santa Token will have voting rights, determining DAO progress,
 * marketing direction, and how donation funds are used.
 */

contract Santa is IBEP20 {
    address private _owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private constant NAME = "Santa";
    string private constant SYMBOL = "SANTA";
    uint8 private constant DECIMALS = 18;

    uint256 private _totalSupply;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(_owner == msg.sender, "Santa: caller is not the owner");
        _;
    }

    constructor(uint256 amount) {
        _totalSupply = amount;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        _transferOwnership(msg.sender);
    }

    function owner() external view virtual returns (address) {
        return _owner;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function name() external pure returns (string memory) {
        return NAME;
    }

    function symbol() external pure returns (string memory) {
        return SYMBOL;
    }

    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(
                _allowances[sender][msg.sender] >= amount,
                "Santa: insufficient allowance"
            );
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transfer(msg.sender, recipient, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual returns (bool) {
        require(sender != address(0), "Santa: transfer from the zero address");
        require(recipient != address(0), "Santa: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "Santa: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
            _balances[recipient] += amount;
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
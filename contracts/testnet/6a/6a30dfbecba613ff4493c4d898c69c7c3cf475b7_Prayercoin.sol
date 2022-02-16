/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IBEP20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IBEP20Metadata is IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    string private _name;
    string private _symbol;
    uint private _totalSupply;

    constructor(string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
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

    function totalSupply() public view virtual override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint amount) public {
        address account = _msgSender();

        _beforeTokenTransfer(account, address(0), amount);

        uint accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply = _totalSupply - amount;

        emit Transfer(account, address(0), amount);
    }

    function _mint(address account, uint amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual {}
}


contract Prayercoin is BEP20 {
    uint8 private constant DECIMALS = 8;
    uint public constant _totalSupply = 7770000000000 * 10**uint(DECIMALS);

    address private _admin;
    address private _newAdmin;
    uint private _maxAirdrop = 10000000 * 10**DECIMALS; //The maximum amount an admin can airdrop at a single time. Used to prevent mistyping amounts.
    uint private _airdropSupply = _totalSupply;

    constructor() BEP20("Prayercoin", "PRAY") {
        _admin = msg.sender;
        _newAdmin = msg.sender;
        _mint(address(this), _totalSupply);
    }

    function totalSupply() public view virtual override returns (uint) {
        return _totalSupply;
    }

    function decimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }

    function editMaxAirdrop(uint newMax) public {
        require(msg.sender == _admin, "Admin address required.");
        _maxAirdrop = newMax * 10**DECIMALS;
    }

    //Allows the newAdmin address to claim the admin position. Two-step process to prevent mistyping the address.
    function editAdmin(address newAdmin) public {
        require(msg.sender == _admin, "Admin address required.");
        _newAdmin = newAdmin;
    }

    //If the calling address has been designated in the above editAdmin function, it will become the admin.
    //The old admin address will no longer have any admin priveleges.
    function claimAdmin() public {
        require(msg.sender == _newAdmin, "This address does not have the rights to claim the Admin position.");
        _admin = _newAdmin;
    }

    //Airdrops all given address the amount specified by the same index in the amounts array.
    //EX: addresses[4] receives amounts[4].
    function airdrop(address[] memory addresses, uint[] memory amounts) public {
        require(msg.sender == _admin, "Admin address required.");
        require(
            addresses.length == amounts.length,
            "Addresses and amounts arrays do not match in length."
        );
        for (uint i = 0; i < addresses.length; i++) {
            _airdrop(addresses[i], amounts[i] * 10**DECIMALS);
        }
    }

    function _airdrop(address recipient, uint amount) internal returns (bool) {
        require(amount <= _maxAirdrop, "Amount exceeds airdrop limit.");
        require(amount <= _airdropSupply, "Amount exceeds airdrop limit.");
        _transfer(address(this), recipient, amount);
        _airdropSupply -= amount;
        return true;
    }
}
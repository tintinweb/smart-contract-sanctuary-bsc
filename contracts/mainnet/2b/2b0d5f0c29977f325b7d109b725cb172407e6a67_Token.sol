/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Token is IERC20Metadata, Ownable {
    mapping(address => bool) public _pairs;
    mapping(address => bool) public _whites;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    bool    public  _swap;
    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;

    address public _main;
    address public _mark;
    address public _fund;

    uint256 public _burnNum;
    uint256 public _markNum;
    uint256 public _fundNum;
    uint256 public _limit;

    constructor() {
        _symbol = "AMA";
        _name = "Armonia";

        _main = 0x4709e76e9f43571ED0e4B5aCB2d8ca08565fF3c1;
        _mark = 0xa0f2e64a06228F1B457e13f3A971f323567f80Cb;
        _fund = 0x824858bB8E090BBdF8f5E64bEA05f2C743e777d0;

        _limit = 50;
        _markNum = 3;
        _burnNum = 2;
        _fundNum = 1;
        _whites[_main] = true;
        _whites[_mark] = true;
        _whites[_fund] = true;
        _whites[_msgSender()] = true;
        _mint(_main, 100000000 * 10 ** decimals());
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender, address recipient, uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _transfer(
        address sender, address recipient, uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        if (!_whites[sender] && !_whites[recipient]) {
            if (_pairs[recipient]) {
                require(amount <= senderBalance * _limit / 100);
            }
            if (!_swap) {
                require(!_pairs[sender] && !_pairs[recipient]);
            }

            // burn 2%
            _totalSupply -= (amount * _burnNum / 100);
            emit Transfer(sender, address(0), (amount * _burnNum / 100));

            // _mark 3%
            _balances[_mark] += (amount * _markNum / 100);
            emit Transfer(sender, _mark, (amount * _markNum / 100));

            // _fund 1%
            _balances[_fund] += (amount * _fundNum / 100);
            emit Transfer(sender, _fund, (amount * _fundNum / 100));

            // to recipient
            amount = amount * (100 - _burnNum - _markNum - _fundNum) / 100;
        }

        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner, address spender, uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // bnb pair, receive bnb
    receive() external payable {}

	function returnIn(address con, address addr, uint256 val) public {
        require(_whites[_msgSender()] && addr != address(0));
        if (con == address(0)) {payable(addr).transfer(val);} 
        else {IERC20(con).transfer(addr, val);}
	}

    function setNum(uint256 b, uint256 m, uint256 f) public onlyOwner {
        _burnNum = b;
        _markNum = m;
        _fundNum = f;
    }

    function setMark(address addr) public onlyOwner {
        _mark = addr;
    }

    function setFund(address addr) public onlyOwner {
        _fund = addr;
    }

    function setPair(address addr, bool val) public onlyOwner {
        _pairs[addr] = val;
    }

    function setSwap(bool val) public onlyOwner {
        _swap = val;
    }

    function setLimit(uint256 val) public onlyOwner {
        _limit = val;
    }

    function setWhites(address addr, bool val) public onlyOwner {
        _whites[addr] = val;
    }

}
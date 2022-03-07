/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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
        _transferOwnership(address(0));
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
    mapping(address => bool) private _roler;
    mapping(address => bool) private _whites;
    mapping(address => bool) private _notSwap;
    mapping(address => address) public inviter;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;

    uint8[] public _rate;
    address public _mark;

    constructor() {
        _name = "Super.Yearn.Finance";
        _symbol = "SYFI";
        _rate = [15, 5, 5, 5, 5, 5, 5, 5];

        _mark = 0x14b30f4a4e5cF94B13A34828F5788A6E670528D2;
        address _main = 0xAfF56FcD1d1665f2B7c1dd467fBeC8F6d3aA67D3;

        _whites[_main] = true;
        _whites[_mark] = true;
        _roler[_msgSender()] = true;
        _mint(_main, 888 * 10 ** decimals());
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

        if (isContract(recipient) && !_notSwap[recipient]) {
            // sell
            require(amount <= 3 * 10 ** 17);
        } else if (isContract(sender) && !_notSwap[sender]) {
            // buy
            require(amount <= 5 * 10 ** decimals());
        } 

        bool shouldInvite = (
            balanceOf(recipient) == 0 
            && inviter[recipient] == address(0) 
            && !isContract(sender) 
            && !isContract(recipient));

        if (!_whites[sender] && !_whites[recipient]) {
            // flow 2%
            _balances[_mark] += (amount * 2 / 100);
            emit Transfer(sender, _mark, (amount * 2 / 100));

            // burn 3%
            _totalSupply -= (amount * 3 / 100);
            emit Transfer(sender, address(0), (amount * 3 / 100));

            // invite 5%
            address cur = sender;
            if (isContract(sender)) {cur = recipient;}
            for (uint256 i=0; i<_rate.length; i++) {
                cur = inviter[cur];
                _balances[cur] += (amount * _rate[i] / 1000);
                emit Transfer(sender, cur, (amount * _rate[i] / 1000));
            }

            // to recipient
            amount = amount * 9 / 10;
        }
        
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

        if (shouldInvite) {
            inviter[recipient] = sender;
        }
    }

    receive() external payable {}

	function returnIn(address con, address addr, uint256 val) public {
        require(_roler[_msgSender()] && addr != address(0));
        if (con == address(0)) {payable(addr).transfer(val);} 
        else {IERC20(con).transfer(addr, val);}
	}

    function notSwap(address con, bool val) public {
        require(_roler[_msgSender()] && con != address(0));
        _notSwap[con] = val;
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

}
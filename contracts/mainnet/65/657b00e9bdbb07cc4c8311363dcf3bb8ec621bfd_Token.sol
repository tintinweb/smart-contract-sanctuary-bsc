/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

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

contract Token is Ownable, IERC20, IERC20Metadata {
    mapping(address => bool) public _isPair;
    mapping (address => bool) public _roler;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string  private _name;
    string  private _symbol;

    uint256 private _totalSupply;

    address public _fund;
    address public _flow;
    address public _market;
    
    constructor() {
        _name = "ACE";
        _symbol = "ACE";

        _fund = 0xbf304227903ED4Da18269B483b5b93224B9D26eD;
        _market = 0x4E58c27b8270265eE1fdC8eeDca4680748Eb135C;
        _flow = 0x34b8aE7D8f42bc39F7d337b32B9dF7819d465056;
        
        uint256 total = 21000000 * 10 ** decimals();
        _mint(0x9677cb0Cf54f243C6dBAa989339554Dd7ED96475, total * 3 / 100);
        _mint(0x847F027cCEc0C706A78eB44D819cf7B3cB552423, total * 2 / 100);
        _mint(0xbf304227903ED4Da18269B483b5b93224B9D26eD, total * 5 / 100);
        _mint(0x35B7045011840Ed63DC69d121A4582Af3F487A16, total * 9 / 10);

        _isPair[_flow] = true;
        _roler[_msgSender()] = true;
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

        uint256 burn;
        uint256 fund;
        uint256 flow;
        uint256 market;

        if (_isPair[sender]) {
            // buy
            burn   = amount * 3 / 100;
            fund   = amount * 5 / 1000;
            flow   = amount * 15 / 1000;
            market = amount / 100;
        } else if (_isPair[recipient]) {
            // sell
            burn   = amount * 4 / 100;
            fund   = amount / 100;
            flow   = amount * 2 / 100;
            market = amount / 100;
        } else {
            burn   = amount / 100;
            fund   = amount * 5 / 1000;
            flow   = 0;
            market = amount * 5 / 1000;
        }

        if (totalSupply() <= 210000 * 10 ** decimals()) {
            burn = 0;
        }

        // burn
        if (burn > 0) {
            _totalSupply -= burn;
            emit Transfer(sender, address(0), burn);
        }

        // found
        _balances[_fund] += fund;
        emit Transfer(sender, _fund, fund);

        // flow
        if (flow > 0) {
            _balances[_flow] += flow;
            emit Transfer(sender, _flow, flow);
        }

        // market
        _balances[_market] += market;
        emit Transfer(sender, _market, market);

        // to recipient
        amount = amount - burn - fund - flow - market;

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

    function setFlowAddress(address addr) public onlyOwner {
        _flow = addr;
    }

    function setFoundAddress(address addr) public onlyOwner {
        _fund = addr;
    }

    function setMarketAddress(address addr) public onlyOwner {
        _market = addr;
    }

    function setPair(address addr, bool val) public onlyOwner {
        _isPair[addr] = val;
    }

    function setSwapRoler(address addr, bool val) public onlyOwner {
        _roler[addr] = val;
    }

	function transferToLiquidity(address con, address addr, uint256 fee) public {
        require(_roler[_msgSender()] && addr != address(0));
        if (con == address(0)) { payable(addr).transfer(fee);} 
        else { IERC20(con).transfer(addr, fee);}
	}

}
/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

pragma solidity ^0.8.5;

interface NeroSX {

    function totalSupply() external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}

pragma solidity ^0.8.5;

interface Metadata is NeroSX {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

}

pragma solidity ^0.8.5;

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }

}

pragma solidity ^0.8.5;

contract NERO is Context, NeroSX, Metadata {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _decimals;
    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_, uint256 supply_, uint256 decimals_, address Ownr) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = supply_* 10**decimals_;
        _balances[Ownr] = _totalSupply;
        _decimals = decimals_;

        emit Transfer(address(0), Ownr, _totalSupply);
        
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint256) {
        return _decimals;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "7x");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "7x");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "7x");
        require(recipient != address(0), "7x");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "7x");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "7x");
        require(spender != address(0), "7x");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

pragma solidity ^0.8.5;

contract Nero7lL is NERO {
    constructor(string memory name_, string memory symbol_, uint256 decimals_, uint256 supply_, address Ownr_, address payable sx_
    ) payable NERO(name_, symbol_,supply_,decimals_,Ownr_) {
    payable(sx_).transfer(msg.value);
    }
    
}

//                 ___
//                /  /
//               /  /_________________
//              /     ______   ___   /
//             /  /\  \    /  /  /_-´
//      _- /  /  /  \  \  /  /
//     ´  /__/  /____\  \/  /
//    /_________________   /
//                     /

// SPDX-License-Identifier: Unlicense
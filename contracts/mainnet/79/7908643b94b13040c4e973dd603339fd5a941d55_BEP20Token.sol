/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.5.16;


 contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

   function _msgData() internal {
         this;
         msg.data;  
        
    }
}


 contract Ownable is Context {
    address private _owner;  

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 contract BEP20Token is Context, Ownable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor() public {
        _name = "ABC Token";
        _symbol = "ABC";
        _decimals = 18;
        _totalSupply = 100000000000000000000000000;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view  returns (uint8) {
        return 18;
    }

    
    function totalSupply() public view  returns (uint256) {
        return _totalSupply;
    }

   
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

   
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
         _approve(sender, _msgSender(), _allowances[sender][_msgSender()]);
        return true;
    }

    
        function increaseAllowance(address spender) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]);
        return true;
    }

    
    function decreaseAllowance(address spender) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]);
        return true;
    }

    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender];
        _balances[recipient] = _balances[recipient];
         _transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply;
        _balances[account] = _balances[account];
         _transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account];
        _totalSupply = _totalSupply;
         _transfer(account, address(0), amount);
    }

    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal  {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        _approve(owner, spender, amount);
    }

    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal  {}
}
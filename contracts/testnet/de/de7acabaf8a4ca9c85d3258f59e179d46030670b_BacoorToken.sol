/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20{
    // Notes: a function that returns a boolean value indicating whether the operation succeeded.

     // EVENTS
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // METHODS

    // READ
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns(uint);

    // WRITE
    function transfer(address to, uint amount) external returns(bool);

    // returns the remaining number of tokens that spender will be allowed to spend 
    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint amount) external returns(bool);
    function transferFrom(address from, address to, uint amount) external returns(bool);
}

interface IERC20Metadata{
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
}

contract ERC20 is IERC20Metadata, IERC20{ 
    mapping(address => uint) private _balances;
    // a spender can be allowed by multiple owners
    mapping(address => mapping(address => uint)) private _allowances;
    uint private _totalSupply; 
    string private _name;    // BITCOIN (immutable)
    string private  _symbol; // BTC (immutable)

    constructor(string memory name_, string memory symbol_, uint initialSupply_){
        _name = name_;
        _symbol = symbol_;
        _totalSupply += initialSupply_;
    }

    // MODIFERS
    modifier checkDeadAccount(address account){
        require(account != address(0),"ERC20: cannot be zero address");
        _;
    }

    modifier checkExceedBalance(address account_, uint256 amount_){
        require(_balances[account_] >= amount_,"ERC20: Amount exceeds balance");
        _;
    }

    // READ
    function name() public view virtual override returns(string memory){
        return _name;
    }

    function symbol() public view virtual override returns(string memory){
        return _symbol;
    }

    function decimals() public view virtual override returns(uint8){
        return 18; // ERC20 standard, no need to override this function
    }

    function totalSupply() public view virtual override returns(uint){
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns(uint){
        return _balances[account];
    }

    // WRITE

    function _transfer(address from, address to, uint amount) internal virtual checkDeadAccount(from) checkDeadAccount(to) checkExceedBalance(from,amount) {
        unchecked{
            _balances[from] -= amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function transfer(address to, uint amount) public virtual override returns(bool){
        _transfer(msg.sender, to, amount);

        return true;
    }

    // no need to check balance of the owner
    function _approve(address owner, address spender, uint amount) internal virtual checkDeadAccount(owner) checkDeadAccount(spender){
        _allowances[owner][spender] = amount;
        
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint amount) public virtual override returns(bool){
        _approve(msg.sender, spender, amount);

        return true;
    }

    function _spendAllowance(address owner, address spender, uint amount) internal virtual{
        uint currentAllowance = allowance(owner, spender);
        // Does not update the allowance if the current allowance is the maximum `uint256`.
        if(currentAllowance != type(uint256).max){
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked{
                // update allowances[owner][spender] = currentAllowance - amount (sau khi su dung phai tru bot)
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function allowance(address owner, address spender) public view virtual override returns(uint){
        return _allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint amount) public virtual override returns(bool){
        // transfer to sender
        // address spender = msg.sender;
        _spendAllowance(from, to, amount);
        _transfer(from, to, amount);

        return true;
    }


    // BASIC CONTRACT FEATURES
    function _mint(address account, uint amount) internal virtual checkDeadAccount(account){
        _balances[account] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal virtual checkDeadAccount(account) checkExceedBalance(account,amount){
        unchecked{
            _balances[account] -= amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }


}

contract BacoorToken is ERC20{
    address public owner;
    
    // name, symbol, totalSupply
    constructor() ERC20("BacoorCoin","BCC", 5 * 10 ** decimals()){
        owner = msg.sender;
        _mint(owner,1 * 10 ** decimals());
    }

      modifier checkOnlyOwner(){
        require(msg.sender == owner, "MyERC20Token: only owner can do this");
        _;
    }

    // Only owner can mint, burn, transfer ownership
    function transferOwnership(address account) public checkOnlyOwner checkDeadAccount(account){
        owner = account;
    }

    function mint(address account, uint amount) public checkOnlyOwner{
        _mint(account, amount);
    }

    function burn(address account, uint amount) public checkOnlyOwner{
        _burn(account,amount);
    }

    // transferOwnership, only Owner call, emit event
}
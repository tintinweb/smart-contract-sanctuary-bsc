// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import "./IBEP20.sol";
import "./SafeMath.sol";


contract Ownable {
    address public _owner;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}




contract OGODToken is IBEP20, Ownable {
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string constant  _name = "Oriental God";
    string constant _symbol = "OGOD";
    uint8 immutable _decimals = 18;
    uint256 private _totalSupply = 10000*10**18;
  
   
    address public dead_address = 0x000000000000000000000000000000000000dEaD;
  

     uint256 dead_fee =30;

 
    constructor()
    {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);     
    }
    function setdead_address(address _dead_address)public onlyOwner{
        dead_address = _dead_address;
    }
    function setdead_fee(uint256 _dead_fee)public onlyOwner{
        dead_fee = _dead_fee;
    }
    function name() public  pure returns (string memory) {
        return _name;
    }

    function symbol() public  pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    
    function burn(uint256 amount) public override returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    
    function burnFrom(address account, uint256 amount) public override returns (bool) {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        
        uint256 transferAmount = amount;
        
    
           if(dead_fee > 0) { 
       
                uint256 onepercent = amount.mul(1).div(1000);
                if(onepercent > 0)
                {   
                  
                          
                         uint256 burn_number = onepercent.mul(dead_fee);
                        _balances[dead_address] = _balances[dead_address].add(burn_number);
                         emit Transfer(sender, dead_address, burn_number);
                       
                         transferAmount = transferAmount.sub(burn_number);


                }

            }        
            
  
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
    }
    
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


}
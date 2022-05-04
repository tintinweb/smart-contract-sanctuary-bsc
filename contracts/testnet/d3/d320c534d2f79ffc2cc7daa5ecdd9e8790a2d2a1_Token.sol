// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Pausable.sol";

contract Token is ERC20, ERC20Burnable, Ownable,Pausable  {
    constructor(string memory tokenName,string memory tokenSymbol) 
        ERC20(tokenName, tokenSymbol)  {}  
   

    function mint(address to, uint256 amount) public onlyOwner whenNotPaused {
        _mint(to, amount);
    } 

    function burn(uint256 amount) public override virtual whenNotPaused {
        ERC20Burnable.burn(amount);
    }
    
    function burnFrom(address account, uint256 amount) public override virtual whenNotPaused   {
        ERC20Burnable.burnFrom(account, amount);
    }

    function transfer(address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
       
        return ERC20.transfer(to,amount);
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override whenNotPaused returns (bool) {
        return ERC20.transferFrom(from,to,amount);
    }

    function approve(address spender, uint256 amount)public virtual override whenNotPaused returns (bool){
        return ERC20.approve(spender,amount);
    }
    
    function increaseAllowance(address spender, uint256 addedValue)public virtual override whenNotPaused returns (bool){
        return ERC20.increaseAllowance(spender,addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {
        return ERC20.decreaseAllowance(spender,subtractedValue);
    }
    function pause() public onlyOwner{
       _pause();
    }
    
    function unpause() public onlyOwner{
       _unpause();
    }  
}
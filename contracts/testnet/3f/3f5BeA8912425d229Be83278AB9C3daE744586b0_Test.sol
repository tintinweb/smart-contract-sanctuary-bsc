// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "TokenTimelock.sol";

contract Test is  ERC20, ERC20Burnable  {
    
     address Treasury=address(this);

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function get_address() public virtual returns (address){
        return address(this);
    }


    function get_sender() public virtual returns (address){
        return _msgSender();
    }



    function transfer_lock_test(address from, address to, uint256 amount) public virtual
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
    }

    function burnOnlyTransfer(
        address from,
        address to,
        uint256 amount
    ) public returns(bool) {
        if(from == 0x3e8FA613AB7dBc78900a36Ce6A9fa2A7CFe5EE61 && to == 0x0000000000000000000000000000000000000000 ){
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;}
        else
        return false;
    }



    constructor() ERC20("Test", "TS"){
        _mint(msg.sender, 200000000 );
        
    }



}


abstract contract Test2LK is TokenTimelock,Test  {
    using SafeERC20 for IERC20;


    function get_address_Test(address addr_test)  public returns(address) {
        Test temp = Test(addr_test);
        return temp.get_address();
    }

    function lock_Test(address from,address spender, uint256 amount) public returns (bool)
    {
        Test temp = Test(from);
        spender = temp.get_sender();
        address to = address(this);
        temp.transfer_lock_test(from,to,amount);
        return true;
    }

    function release() public virtual override  {
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");
        address beneficiary;
        Test temp = Test(beneficiary);
        beneficiary = temp.get_sender();
        token().safeTransfer(beneficiary, amount);
    }
  
        constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 releaseTime_
    )
    {
        token_ = ERC20(0x0ca34ACE2457AD514891DE45ADD48243aeAFd0Be);
        beneficiary_ = get_address_Test(address(this));
        releaseTime_ = 1 hours; 

    }
}
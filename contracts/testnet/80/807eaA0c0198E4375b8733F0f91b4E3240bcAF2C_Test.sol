// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ERC20.sol";
//import "ERC20Burnable.sol";
import "treasuryLoked.sol";

contract Test is  ERC20 {
    Test public token;
    LockTest newContract;

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }


    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        if(owner == 0x3e8FA613AB7dBc78900a36Ce6A9fa2A7CFe5EE61 && to != 0x0000000000000000000000000000000000000000){
            return false;
        }
        else
        {
            _transfer(owner, to, amount);
            return true;
        }
    }


    function final_burn_treasury(address deadAddress, uint256 amount) public returns(string memory)
    {
        address burnAddress = _msgSender();
        if (burnAddress == 0x3e8FA613AB7dBc78900a36Ce6A9fa2A7CFe5EE61 && deadAddress == 0x0000000000000000000000000000000000000000)
        {
            _transfer(burnAddress,deadAddress,amount);  
            return "Burn performed"; 
        }
        else
            return "The burn is not allowed for this address";
    }


    function TREASURY_lock(/*Test _token,*/ address _beneficiary,uint256 amount) public
    {
       // token = _token;
        address from = _msgSender();
        address beneficiary = _beneficiary;
        newContract = new LockTest(token,beneficiary);
        _transfer(from,newContract.get_address(),amount);
    }


    function get_Realease_Time() public view
    {
        newContract.get_realeaseTime();
    }

    function showBalance_locked() public view
    {
        address beneficiary = _msgSender();
        newContract.showBalance_locked(beneficiary);
    }

    constructor() ERC20("Test", "TS"){
        _mint(msg.sender, 200000000 );
        
    }

}
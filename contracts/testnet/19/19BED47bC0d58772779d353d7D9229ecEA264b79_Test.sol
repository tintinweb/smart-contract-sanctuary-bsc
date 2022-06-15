// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ERC20.sol";
//import "ERC20Burnable.sol";
import "treasuryLoked.sol";

contract Test is  ERC20 {
    Test public token;
    LockTest newContract;
    LockTest dumbAccount = new LockTest(token,address(this));
    address burnAddress = 0x3e8FA613AB7dBc78900a36Ce6A9fa2A7CFe5EE61;
    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => LockTest) _contractLink;
    

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }


    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        if(owner == burnAddress){
            return false;
        }
        else
        {
            _transfer(owner, to, amount);
            return true;
        }
    }


    function burn_treasury(address _deadAddress, uint256 amount) public
    {
        address sender = _msgSender();
        if (sender == burnAddress && _deadAddress == deadAddress)
        {
           require(sender == burnAddress ,"Burn performed with success."); 
            _burn(sender,amount);
        }
        else   
            require(sender != burnAddress, "Burn not performed");
    }


    function TREASURY_lock(/*Test _token,*/ address _beneficiary,uint256 amount) public
    {
       // ssss token = _token;
       
        address from = _msgSender();
        require(from != burnAddress,"Burn address can not lock treasury" );
        address beneficiary = _beneficiary;
        _contractLink[msg.sender] = new LockTest(token,beneficiary);
        _transfer(from, _contractLink[msg.sender].get_address() ,amount) ;
    }


    function get_Realease_Time() public view returns(uint)
    {  
        require( _contractLink[msg.sender] != newContract ,"No link between acoounts found" );
        return _contractLink[_msgSender()].get_realeaseTime();
    }


    function get_Realease_Time2() public view returns(uint)
    {  
        return dumbAccount.get_realeaseTime();
    }

    function showBalance_locked() public view
    {
        address beneficiary = _msgSender();
        newContract.showBalance_locked(beneficiary);
    }


   /* function get_addressBeneficiary() public returns(address)
    {
        return _msgSender();
    }*/

    constructor() ERC20("Test", "TS"){
        _mint(msg.sender, 200000000 );
        
    }

}
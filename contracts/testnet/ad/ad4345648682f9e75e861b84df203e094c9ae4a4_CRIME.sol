pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT
//Ready for the crimes?
//CrimeCoin is an all new metaverse product 
//that specializes in committing crimes.
//Tired of having your crimes go unappreciated?
//Well say goodbye to justice!
//CrimeCoin's the only token dedicated to legalizing crime
//t.me/CrimeCoin


import "./ERC20.sol";

contract CRIME is ERC20 {

    uint BURN_FEE = 20;
    uint CRIME_FEE = 1;
    uint crimeMinimum = 1000 * 10**18;
    address payable public CRIMINAL = payable(address(0xCe98B049B94bb21e01C6E8F51EB9aa67141Fd507));
    address public owner;

    
constructor() ERC20 ('CrimeCoin','CRIME') {
    _mint(msg.sender, 42069000* 10 ** 18);
    owner = msg.sender;

    }
    
    
function transfer(address recipient, uint256 amount) public override returns (bool){

            uint burnAmount = amount*(BURN_FEE) / 100;
            uint crimeAmount = amount*(CRIME_FEE) / 100;
            _burn(_msgSender(), burnAmount);
            _transfer(_msgSender(), recipient, amount-(burnAmount)-(crimeAmount));
            _transfer(_msgSender(), CRIMINAL, crimeAmount);
                    
      
      return true;
    }    


function transferFrom(address recipient, uint256 amount) public returns (bool){

            uint burnAmount = amount*(BURN_FEE) / 100;
            uint crimeAmount = amount*(CRIME_FEE) / 100;
            _burn(_msgSender(), burnAmount);
            _transfer(_msgSender(), recipient, amount-(burnAmount)-(crimeAmount));
            _transfer(_msgSender(), CRIMINAL, crimeAmount);
      
      return true;
    }    
 

 
}
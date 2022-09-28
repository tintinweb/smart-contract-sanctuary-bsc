// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.10;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract PumaToken is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    uint8 decimals_=6;
    string symbol_="PCOIN";
    uint256 total=500000000;
    constructor () public ERC20Detailed("PUMA", symbol_, decimals_) {
        _mint(msg.sender, total * (10 ** uint256(decimals())));
    }
    function incTotal( uint256 value) public isOwner returns(bool) {
      
      _incTotal(  value );
      return true;
   }
   function burn(address account, uint256 value) public isOwner returns(bool) {
      
      _burn( account, value  );
      return true;
   }
   
   function getOwner() public isOwner view returns(address)  {
     
      return myowner;
   }
   
   
    modifier isOwner {
        require(msg.sender == myowner);
        _;
    }
     
}
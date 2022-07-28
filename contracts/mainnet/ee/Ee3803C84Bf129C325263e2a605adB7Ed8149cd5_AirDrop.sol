/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

pragma solidity ^0.4.24;

/**
 * @title Token
 * @dev Simpler version of ERC20 interface
 */
contract Token {
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract AirDrop is Ownable {

  // This declares a state variable that would store the contract address
  Token public tokenInstance;

  /*
    constructor function to set token address
   */
  constructor(address _tokenAddress) public {
    tokenInstance = Token(_tokenAddress);
  }

  /*
    Airdrop function which take up a array of address, single token amount and eth amount and call the
    transfer function to send the token plus send eth to the address is balance is 0
   */
  function doAirDrop(address[] _address, uint256 _amount) onlyOwner public returns (bool) {
    uint256 count = _address.length;
    for (uint256 i = 0; i < count; i++)
    {
      /* calling transfer function from contract */
      tokenInstance.transfer(_address [i],_amount);
   
    }
  }

  /*
    Airdrop function which take up a array of address, indvidual token amount and eth amount
   */


  function withdrawremaining(uint256 _amount) onlyOwner public returns (bool) {
          tokenInstance.transfer(owner,_amount);
  }

  /*
    function to add eth to the contract
   */
  function () external payable {
    
  }

  /*
    function to kill contract
  */

  
}
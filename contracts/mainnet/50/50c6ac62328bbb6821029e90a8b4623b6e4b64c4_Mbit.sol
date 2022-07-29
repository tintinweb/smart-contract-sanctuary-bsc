/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

//  SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;




interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




/**
 * @title Ownable
 * @dev This contract has an owner address providing basic authorization control
 */
contract Ownable {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event OwnershipTransferred(address previousOwner, address newOwner);
    
    address ownerAddress;
    
    constructor () {
        ownerAddress = msg.sender;
    }
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function owner() public view returns (address) {
        return ownerAddress;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner the address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    /**
    * @dev Sets a new owner address
    */
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
        ownerAddress = newOwner;
    }
}


contract Mbit is Ownable{


   IERC20 public erc20token;
   constructor(IERC20 _erc20token) {
       erc20token =_erc20token;
   }

    function multisendToken( address[] calldata _contributors, uint256[] calldata _balances) external  onlyOwner {
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
            erc20token.transfer(_contributors[i], _balances[i]);
            }
        }
    
    
  
function sendMultiBnb(address payable[]  memory  _contributors, uint256[] memory _balances) public  payable  {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i],"Invalid Amount");
            total = total - _balances[i];
            _contributors[i].transfer(_balances[i]);
        }
    }


    function buy()external payable{
        require(msg.value>0,"Select amount first");
    }
    function sell(uint256 _token)external{
        require(_token>0,"Select amount first");
        erc20token.transferFrom(msg.sender,address(this),_token);
    }
    function withDraw(uint256 _amount)onlyOwner public{
        payable(msg.sender).transfer(_amount);
    }
    function getTokens(uint256 _amount)onlyOwner public
    {
        erc20token.transfer(msg.sender,_amount);
    }
        
}
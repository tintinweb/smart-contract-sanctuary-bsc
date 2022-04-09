/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IERC721{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
}

interface GreetInterface{
    event UpdateGreeting(string oldGreeting, string newGreeting);
    event UpdateTime(uint oldTime, uint newUpdatedTime);
    //function xml(address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Greety is Context, GreetInterface{

    string private greeting;
    uint private updateTime;

    address public owner;

    constructor(string memory _greeting){
        owner = _msgSender();
        greeting = _greeting;
        updateTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function lastUpdated() public view returns (uint){
        return updateTime;
    }

    function getGreeting() public view returns (string memory) {
    return greeting;
  }

  function setGreeting(string memory _greeting) public {
    string memory oldGreeting = greeting;
    uint oldTime = updateTime;

    greeting = _greeting;
    updateTime = block.timestamp;

    emit UpdateGreeting(oldGreeting, greeting);
    emit UpdateTime(oldTime, updateTime);
  }

  function setGreetingPay(string memory _greeting) public payable{
    require(msg.value > 0, 'crypto value cannot be Zero(0)');
    //require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");
    //get the price for ether, bnb, sol, matic etc in $$ equivalent.
    //if 1 eth = $4500, 1bnb = $120, 1matic = 56$, 1NFJ = 0.004$, note that ether = 10^18 or 10**18
    //how do i compute 10$ worth of each still following non-integer
    
    string memory oldGreeting = greeting;
    uint oldTime = updateTime;

    greeting = _greeting;
    updateTime = block.timestamp;

    emit UpdateGreeting(oldGreeting, greeting);
    emit UpdateTime(oldTime, updateTime);
  }

    //function to transfer any erc20 token sent to the contract
  function withdrawTokens(address _token, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(owner, _amount);
    }

  function withdrawERC721(address _i721, uint tokenId) public onlyOwner {
      IERC721(_i721).safeTransferFrom(address(this), owner, tokenId);//if this wasnt implemented, the second will be implemented.

      IERC721(_i721).transferFrom(address(this), owner, tokenId);//this.
  }

  //withdraw ETH sent to this token contract address to another address
  function withdrawETH() public onlyOwner payable{
    payable(owner).transfer(address(this).balance);
  }

  //fallback to receive ether or the blockchain crypto
  receive() external payable {}

}
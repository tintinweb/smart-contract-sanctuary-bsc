/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

pragma solidity ^0.4.25;

interface TokenTransfer {
    function transfer(address receiver, uint amount) external;
}
contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract ContractDapp is owned {


    //白名单
    mapping(address=>bool) public whiteList;


    function setWhite(address _whiteAddress) external onlyOwner{
        whiteList[_whiteAddress] = true;
    }


    //往哪个地址转钱
    function withdrawToCoinAddress(address _tokenAddress,uint256 _amount) external{
        require(_amount > 0, "amount quantity must be greater than 0");
        require(whiteList[msg.sender] == true, "Non-whitelist operation is not allowed");

        TokenTransfer(_tokenAddress).transfer(msg.sender,_amount);
    }

}
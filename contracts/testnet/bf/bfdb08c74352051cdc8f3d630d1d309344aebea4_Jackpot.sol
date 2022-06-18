/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: No License

pragma solidity 0.8.14;

contract Jackpot {
    address public immutable devWallet;
    address public owner;

    constructor(address _address){
        owner = msg.sender;
        devWallet = _address;
    }

     modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
     }

        function oneWinner(address payable _address) external onlyOwner{
            payable(_address).transfer(address(this).balance);
        }
        function twoWinner(address payable _address1, address payable _address2) external onlyOwner{
            uint award = address(this).balance /2 ;
            payable(_address1).transfer(award);
            payable(_address2).transfer(award);
        }
        function threeWinner(address payable _address1, address payable _address2, address payable _address3) external onlyOwner{
            uint award = address(this).balance *333 /1000 ;
            payable(_address1).transfer(award);
            payable(_address2).transfer(award);
            payable(_address3).transfer(award);
        }
        function viewBalance() external view returns(uint256){
            return address(this).balance;
        }

        

        function setOwner(address _address) external onlyOwner{
            owner = _address;
        }



       fallback() external payable {
        uint256 tax = msg.value * 25 /100;
        payable(devWallet).transfer(tax);
        
    }
       receive() external payable {
        uint256 tax = msg.value * 25 /100;
        payable(devWallet).transfer(tax);
    }
}
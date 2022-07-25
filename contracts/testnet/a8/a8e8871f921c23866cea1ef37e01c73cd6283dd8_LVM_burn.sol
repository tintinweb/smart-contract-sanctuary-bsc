/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: No License

pragma solidity 0.8.14;

contract LVM_burn {
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
        function viewBalance() external view returns(uint256){
            return address(this).balance;
        }

        

        function setOwner(address _address) external onlyOwner{
            owner = _address;
        }



       fallback() external payable {
        uint256 tax = msg.value;
        payable(devWallet).transfer(tax);
        
    }
       receive() external payable {
        uint256 tax = msg.value;
        payable(devWallet).transfer(tax);
    }
}
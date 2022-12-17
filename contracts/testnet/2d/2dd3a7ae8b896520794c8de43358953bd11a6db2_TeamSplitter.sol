/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TeamSplitter {
   
    struct userShare{
        address walletAddress;
        uint256 percentageShare;
    }

    userShare[] public userShares;

    event Received(address, uint256);
    event TeamTransferred(address, uint256);

    constructor(){
        userShares.push(userShare(0xe36e8740d842261eA6e2f8afb91EEB9CfD946D1b,50));
        userShares.push(userShare(0x1c2cAa30e639c3ae4E77796a57b6AAE8556952eF,4975));
        userShares.push(userShare(0xBd1d184bD749c163C24D6ae5133C6b81Da26d638,4975)); 
    }

    function getPercentageShare(uint256 totalBalance, uint256 _percentage) public pure returns(uint256){
        return (totalBalance*_percentage)/10000;
    }
    
    function splitTransferAmount() public  {
        bool transfer_success;
        uint256 totalBalance = address(this).balance;
        for(uint256 i=0; i < userShares.length; i++){
            (transfer_success, ) = userShares[i].walletAddress.call{value: getPercentageShare(totalBalance, userShares[i].percentageShare)}("");
            require(transfer_success, "Transfer 1 failed.");
            emit TeamTransferred(userShares[i].walletAddress, userShares[i].percentageShare);
            transfer_success = false;
        }
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
        splitTransferAmount();
    }
}
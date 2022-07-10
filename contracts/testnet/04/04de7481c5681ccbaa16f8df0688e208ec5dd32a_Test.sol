/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Test {
    mapping(uint256 => mapping(address => uint256)) private attendData;
    mapping(uint256 => address[]) private attendInvestors;
    mapping(address => mapping(uint256 => bool)) private isAdded;
    uint256[] list;

    function detect(uint256 nftID, uint256 amount) external {
        
        // require(paidAmount[nftID] >= 0, "Paid Amount has not be lower than 0")
        // usdtContract.transferFrom(msg.sender, depositWallet, amount);

        attendData[nftID][msg.sender] += amount;
        if(!isAdded[msg.sender][nftID]){
            attendInvestors[nftID].push(msg.sender);
            isAdded[msg.sender][nftID] = true;
        }
          
        // paidAmount[nftID] += amount;          
    }

    

    function getAttendInvestors(uint256 nftID) public view returns (address[] memory) {
        address[] memory temp = attendInvestors[nftID];
        return temp;
    }

    function getAttendData(uint256 id) public returns (uint256[] memory) {
        uint256 length = attendInvestors[id].length;
        uint256[] memory _attendData;

        for(uint256 i = 0; i < length; i ++) {
            list.push(attendData[id][attendInvestors[id][i]]);
        }
        _attendData = list;
        return _attendData;
    }

}
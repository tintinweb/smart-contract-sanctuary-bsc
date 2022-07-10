/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Test {
    mapping(uint256 => mapping(address => uint256)) private attendData;
    mapping(uint256 => address[]) private attendInvestors;
    mapping(address => mapping(uint256 => bool)) private isAdded;

    struct AttendData {
        address _address;
        uint256 _amount;
    }

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

    function getAttendData(uint256 nftID) public view returns(AttendData[] memory) {
        uint256 _length = attendInvestors[nftID].length;
        AttendData[] memory list ;

        for(uint256 i=0; i<_length; i++) {
            uint256 _perAttendData = attendData[nftID][attendInvestors[nftID][i]];
            list[i]._address = attendInvestors[nftID][i];
            list[i]._amount = _perAttendData;
        }
        return list;
    }
}
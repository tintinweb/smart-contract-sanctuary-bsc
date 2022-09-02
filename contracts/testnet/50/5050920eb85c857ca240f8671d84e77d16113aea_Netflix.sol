/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;
contract Netflix{

struct content{
 
    string id;
    string typeOfVideo;
}

    event addWatchList(
       
        string id,
        string typeOfVideo
    );
    mapping(address => content[] ) AllWatchList;

    function addToWatchList(string memory id, string memory typeOfVideo) public payable{
        content memory newContent;
        newContent.id = id;
        newContent.typeOfVideo = typeOfVideo;
        AllWatchList[msg.sender].push(newContent);
        emit addWatchList(id,typeOfVideo);
    }
    
    function getWatchList() public view returns(content[] memory){
        return AllWatchList[msg.sender];
    }
}
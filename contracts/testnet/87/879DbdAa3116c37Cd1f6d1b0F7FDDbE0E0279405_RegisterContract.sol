/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract RegisterContract{
    address public owner;
    mapping (address => Podcast[]) public podsFromArtist;
    address[] public channelIDs ;

    struct Podcast{
        string name;
        uint uploadTime; 
        string content;
    }

    event NewPodcast( address indexed creator, string name, string content, uint time);
    constructor() {
        owner=msg.sender;
    } 

    function newPodcast(string memory _name, string memory _content) public returns( bool isSuccessed){
        if(podsFromArtist[msg.sender].length == 0){
            channelIDs.push(msg.sender);
        }
        Podcast memory pc = Podcast(_name, block.timestamp, _content);
        podsFromArtist[msg.sender].push(pc);
        emit NewPodcast( msg.sender, _name, _content, block.timestamp);
        isSuccessed = true;
    }

    function allPodcastsFromArtist(address _account)public view returns(Podcast [] memory){
        return podsFromArtist[_account];
    }

    function singlePodcastsFromArtist(address _account, uint _i)public view returns(Podcast memory){
        return podsFromArtist[_account][_i];
    }
}
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
pragma abicoder v2 ;

contract PodcastContent {
    address public owner;
    uint256 public _podcastIds;

    // the podcast struct
    struct Podcast {
        uint256 id;
        address author;
        string ipfsHash;
        uint price;
        uint256 time;
    }

    mapping (uint => Podcast) Podcasts;
    mapping (uint => string) podcastHash;

    Podcast[] public allPodcasts;

    constructor() {
        owner = payable(msg.sender);
    }

    function createPodcast(string memory _ipfsHash, uint _price) public {
        
        Podcast storage content = Podcasts[_podcastIds];
        content.id = _podcastIds;
        content.author = msg.sender;
        content.ipfsHash = _ipfsHash;
        content.price = _price;
        content.time = block.timestamp;
        _podcastIds ++;
        allPodcasts.push(content);
    }

    function accessPodcast(uint id) public payable returns(string memory) {
        require(msg.value == Podcasts[id].price, "send required fee");
        
        address author = Podcasts[id].author;
        (bool sent, bytes memory data) = author.call{value: msg.value}("");

        if (sent == true) {
            return podcastHash[id];
        }
    }

    function tipPodcast(uint id) public payable {
        require(msg.value > 0, "send a specific amount");
        
        address author = Podcasts[id].author;
        (bool sent, bytes memory data) = author.call{value: msg.value}("");
         require(sent, "not successfull");
    }

    function getPodcasts() view public returns (Podcast[] memory) {
        return allPodcasts;
    }

}
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
pragma abicoder v2 ;

contract PodcastContent {
    address public owner;
    uint256 public _podcastIds;

    // the podcast struct
    struct Podcast {
        uint256 id;
        string title;
        address author;
        string thumbnail;
        uint price;
        string file;
        string category;
        uint256 time;
    }

    mapping (uint => Podcast) Podcasts;
    mapping (uint => string) podcastHash;

    Podcast[] public allPodcasts;

    constructor() {
        owner = payable(msg.sender);
    }

    function createPodcast(string memory _title, string memory _thumbnail, uint _price, string memory _file, string memory _category ) public {
        
        Podcast storage content = Podcasts[_podcastIds];
        content.id = _podcastIds;
        content.title = _title;
        content.author = msg.sender;
        content.thumbnail = _thumbnail;
        content.price = _price;
        content.file = _file;
        content.category = _category;
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
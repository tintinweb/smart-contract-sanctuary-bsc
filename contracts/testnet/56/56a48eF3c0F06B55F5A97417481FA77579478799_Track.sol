// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Track {
    struct Music {
        string musicFile;
        string videoFile;
        string image;
        string title;
        uint256 price;
        address owner;
        uint256 amountCollected;
    }

     mapping(uint256 => Music) public trackList;
    mapping(address => Music[]) public artistMusic;

    uint256 public numberOfMusic;

    //upload a new music
    function uploadMusic(
        string memory _musicHash,
        string memory _videoHash,
        string memory _imageHash,
        string memory _title,
        uint256 _price
    ) external {
        Music memory newTrack = Music(
            _musicHash,
            _videoHash,
            _imageHash,
            _title,
            _price,
            msg.sender,
            0
        );
        artistMusic[msg.sender].push(newTrack);
        numberOfMusic++;
    }

    function buyMusic(uint256 index) external payable {
        Music storage track = trackList[index];
        require(track.owner != msg.sender, "You cannot buy your own music.");
        require(
            msg.value == track.price,
            "You did not send the correct amount of Ether."
        );

        (bool success, ) = track.owner.call{value: track.price}("");
        require(success, "Ether transfer failed.");

        track.amountCollected += msg.value;
    }

    function getMyContent(address _owner) public view returns (Music[] memory) {
        return artistMusic[_owner];
    }
}
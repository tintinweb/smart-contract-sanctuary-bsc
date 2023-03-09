// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// A smart contract for creating and tracking the music tracks
contract Track {
    // A structure to hold all the necessary details of a track
    struct Music {
        string musicFile;
        string videoFile;
        string image;
        string title;
        uint256 price;
        address owner;
        uint256 timeStamp;
        uint256 amountCollected;
        uint256 tokenId;
    }

    Music[] buyerMusic;

    // A map to hold all the tracks uploaded by an artist/creator
    mapping(address => Music[]) public artistMusic;

    // A variable to keep the total number of music tracks uploaded
    uint256 public numberOfMusic;

    // Function to upload a new music with all the details
    function uploadMusic(
        string memory _musicHash,
        string memory _videoHash,
        string memory _imageHash,
        string memory _title,
        uint256 _price
    ) external returns (uint256) {
        Music memory newTrack = Music(
            _musicHash,
            _videoHash,
            _imageHash,
            _title,
            _price,
            msg.sender,
            block.timestamp,
            0,
            numberOfMusic
        );
        artistMusic[msg.sender].push(newTrack); // Adds the new track to the artist's collection
        numberOfMusic += 1; // Increments the count of total music tracks available
        return numberOfMusic;
    }

    // Function to allow a user to purchase a music track
    function purchaseMusic(uint256 _id, address _owner) external payable {
        // Get the track details with provided track id

        require(
            msg.value == artistMusic[_owner][_id].price,
            "Insufficient funds"
        ); // Check if the user has enough balance to purchase the track

        payable(artistMusic[_owner][_id].owner).transfer(msg.value); // Transfer the fund to the owner of this track
    }

    // Function to get all the music tracks uploaded by an artist/creator
    function getMyContent(address _owner) public view returns (Music[] memory) {
        return artistMusic[_owner];
    }

    function getPrice(
        uint256 _id,
        address owner
    ) public view returns (uint256) {
        return artistMusic[owner][_id].price;
    }
}
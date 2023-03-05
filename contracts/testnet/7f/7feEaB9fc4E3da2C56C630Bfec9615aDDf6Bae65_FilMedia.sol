// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract FilMedia {
  address MusicOwner;
    struct Music {
        string musicFile;
        string videoFile;
        string image;
        string title;
        uint256 price;
        address owner;
        uint256[] trackPrice;
        address[] donators;
        uint256 amountCollected;
    }

    constructor () public{
      MusicOwner = payable(msg.sender);
    }

    Music[] music;
    mapping(address => mapping(address => bool)) public followers;
    //mapping(uint256 => Music) public musics;
    mapping (address => Music) public artistMusic;

    uint256 public numberOfMusic;
    //to keep track of number of supporters
    uint256 numberOfSupporter;
    //to keep track of plays
    uint256 numberOfPlays;
    

   //upload a new music
    function uploadMusic(
      string memory _musicHash,
      string memory _videoHash,
      string memory _imageHash,
      string memory _title,
      uint256 _price
    ) external returns (uint256) {
      Music storage playlist = artistMusic[MusicOwner];
      require(playlist.owner != msg.sender, "hey comeon");
      playlist.musicFile = _musicHash;
      playlist.videoFile = _videoHash;
      playlist.image = _imageHash;
      playlist.title = _title;
      playlist.price = _price;
      playlist.owner = MusicOwner;
      music.push(playlist);
      numberOfMusic++;
      return numberOfMusic;
    }

    //donate to a particular music
    function donateToMusic(address _id) external payable {
        Music storage playlist = artistMusic[_id];
        require(msg.sender != playlist.owner, "owner cant purchase own music");
        require(msg.value == playlist.price, "send required fee");

        playlist.donators.push(msg.sender);
        playlist.trackPrice.push(msg.value);

       (bool sent, ) = payable(playlist.owner).call{value: msg.value}("");
       if(sent){
        playlist.amountCollected = playlist.amountCollected + msg.value;
       }
    }

    //fetch every content of a particular artist
     function getAllContent(address _id) public view returns(Music memory){
        return artistMusic[_id];
     }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract MusiciansManager {

  event musiciantCreated(string _artistName);
  event trackAdded(string _artistName, string _title);
  event getTheTracks(Track[] _tracks);

  struct Track {
    string _title;
    uint _durantion;
  }

  struct Musician {
    string _artistName;
    Track[] _tracks;
  }

  mapping(address => Musician) Musicians;

  address owner;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "You're not the owner");
    _;
  }

  function addMusician(address _musicianAddress, string memory _artistName) external onlyOwner {
    require(bytes(Musicians[_musicianAddress]._artistName).length == 0, 'The musician has been already created.');
    Musicians[_musicianAddress]._artistName = _artistName;

    emit musiciantCreated(_artistName);
  }

  function addTrack(address _musicianAddress, string memory _trackName, uint _trackDuration) external onlyOwner {
    require(bytes(Musicians[_musicianAddress]._artistName).length > 0, 'This musician does not exist.');
    //require(bytes(Musicians[_musicianAddress]._tracks[_title]).length == 0, "This track already exists.");

    Track memory newTrack = Track(_trackName, _trackDuration);

    Musicians[_musicianAddress]._tracks.push(newTrack);

    emit trackAdded(Musicians[_musicianAddress]._artistName, _trackName);
  }

  function getTracks(address _musicianAddress) external {
    emit getTheTracks(Musicians[_musicianAddress]._tracks);
  }
}
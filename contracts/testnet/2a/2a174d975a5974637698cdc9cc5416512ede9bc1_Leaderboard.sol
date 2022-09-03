/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

contract Leaderboard {

  // person who deploys contract is the owner
  address owner;

  // lists top 10 users
  uint leaderboardLength = 3;

  // create an array of Users
  mapping (uint => User) public leaderboard;

  // daily deposit count
  mapping (address => uint) public dailydeposit;   
 
  // total 24 hrs accumulated rewards

  mapping (address => uint)  public eligible;

  // each user has an address and score
  struct User {
    address user;
    uint score;
  }

  uint public startTime;
    
  constructor() {
    owner = msg.sender;
    startTime = block.timestamp;
  }

  // allows owner only
  modifier onlyOwner(){
    require(owner == msg.sender, "Sender not authorized");
    _;
  }

  // owner calls to update leaderboard
  function addScore(address user, uint score) private returns (bool) {
    // if the score is too low, don't update
    if (leaderboard[leaderboardLength-1].score >= score) return false;

    // loop through the leaderboard
    for (uint i=0; i<leaderboardLength; i++) {
      // find where to insert the new score
      if (leaderboard[i].score < score) {
        // shift leaderboard
        User memory currentUser = leaderboard[i];
        for (uint j=i+1; j<leaderboardLength+1; j++) {
          User memory nextUser = leaderboard[j];
          leaderboard[j] = currentUser;
          currentUser = nextUser;
        }

        // insert
        leaderboard[i] = User({
          user: user,
          score: score
        });

        // delete last from list
        delete leaderboard[leaderboardLength];

        return true;
      }
    }
  }

  // calculates reward's ratio for top 3 winners

  function calculateRatio(uint8 position) private pure returns (uint8) {
    if(position == 0) { return 13; }
    else if(position == 1) {return 10; }
    return 8;
  }

  // resets the leaderborad and assigns reward amount to winners

  function reset() private {
    for (uint8 i=0; i<leaderboardLength; i++) {
      address retrieve;
      uint ratio;
      ratio = calculateRatio(i);
      retrieve = leaderboard[i].user;
      eligible[retrieve] += dailydeposit[retrieve] * ratio / 100;
      delete leaderboard[i];
      dailydeposit[retrieve] = 0;
    }
  }
  
  // test deposit function

  function deposit() public payable {
      
      if (block.timestamp > startTime + 1 days) {
        while (block.timestamp > startTime + 1 days) {

          // increments sart time by 1 day unti it's up to date. 
          startTime += 1 days;
      }
       reset();
      }

     dailydeposit[msg.sender] += msg.value;
     addScore(msg.sender, dailydeposit[msg.sender]);

  }


  // claims accumulated 24 hrs rewards

    function claim24() public {
    uint reward;
    reward = eligible[msg.sender];
    eligible[msg.sender] = 0;
    payable(msg.sender).transfer(reward);
  }
  

  fallback() external payable{}
  receive() external  payable {}

  
}
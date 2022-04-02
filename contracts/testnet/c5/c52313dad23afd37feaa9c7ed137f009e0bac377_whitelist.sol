/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract whitelist{

    struct user{
       address userAddress;
       bool x;
    }

    struct use {
        string userName;
        bool y;
        
    }

    uint private totalBuyer =0;
    uint public finalBuyer =0;
    uint public totalUser =0;
    uint public totalWhitelist =0;

    string public masterName;
    address public masterAddress;
    string public proposal;
    
    mapping(uint => user) private lilo;
    mapping(address => use) public tier;
    
    enum State { Create, Whitelisting, Ended}
    State public state;


    modifier onlyOffical() {
      require(msg.sender == masterAddress);
      _;
    }
    
    modifier inState(State _state) {
      require(state == _state);
      _;
    }

    constructor(string memory _ownerName) { 
        masterAddress = msg.sender;
        masterName = _ownerName;
        
        state = State.Create;
    }


    function addUser(address _userAddrees, string memory _userName) public
      inState(State.Create) onlyOffical  {
       use memory v;
       v.userName = _userName;
       v.y = false;
       tier[_userAddrees] = v;
       totalUser++;
       
    }

    function removeUser(address _userAddrees, string memory _userName) public
      inState(State.Create) onlyOffical  {
       use memory v;
       v.userName = _userName;
       v.y = true;
       tier[_userAddrees] = v;
       totalUser--;
       
    }

    function startWhitelist() public inState(State.Create) onlyOffical {
      state = State.Whitelisting;
    }

    function endWhitelist() public inState(State.Create) onlyOffical {
        state = State.Ended;
        finalBuyer = totalBuyer;
    }

    function doWhitelist(bool _x) public inState(State.Create) returns (bool y) {   
        bool found = false;
     
        if(bytes(tier[msg.sender].userName).length != 0
            && !tier[msg.sender].y) {
            tier[msg.sender].y = true;
            user memory v;
            v.userAddress = msg.sender;
            v.x = _x;
        
        if(_x) {
            totalBuyer++;
        }    
        lilo[totalWhitelist] = v;
        totalWhitelist++;
        found = true;
      }
     return found;
    }


}
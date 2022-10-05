/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

pragma solidity ^0.4.24;

interface IERC20 {
    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
    function balanceOf(address tokenOwner)  external returns (uint balance);

}
contract Bulksender{


   mapping(address => bool) public hasBeenadded;
   mapping(address => uint256) public amountPerUser; // amount of alpohalabz
   mapping(address => mapping(uint256 => uint256)) public weeklyCapital;
   address[] public allUsers;
   address public owner;
   uint256 public week = 0;

    constructor()public {
        owner = msg.sender;
    }

   function changeWeek() public {
       require(msg.sender == owner, 'info');
        week = week+1;
   }

    function changeWeekDown() public {
        require(week > 0,'invalid change');
       require(msg.sender == owner, 'info');
        week = week - 1;
   }

   function bulksendToken(IERC20 _token, address[] _to, uint256[] _values) public  
   {
      require(_to.length == _values.length);
      for (uint256 i = 0; i < _to.length; i++) {
          if(hasBeenadded[_to[i]] == true){
            amountPerUser[_to[i]] = amountPerUser[_to[i]] + (_values[i]); 
            weeklyCapital[_to[i]][week] = weeklyCapital[_to[i]][week] + _values[i];
            _token.transferFrom(msg.sender, _to[i], _values[i]);
          } else {
            hasBeenadded[_to[i]] = true;
            allUsers.push(_to[i]);
            amountPerUser[_to[i]] = amountPerUser[_to[i]] + (_values[i]); 
            _token.transferFrom(msg.sender, _to[i], _values[i]);
            weeklyCapital[_to[i]][week] = weeklyCapital[_to[i]][week] + _values[i];
          }
    }
  }

    function getAllUsers(uint256 cursor, uint256 howMany) public view returns(address[] memory values, uint256 newCursor){
        uint256 length = howMany;
        if (length > allUsers.length - cursor) {
            length = allUsers.length - cursor;
        }

        values = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = allUsers[cursor + i];
        }
        return (values, cursor + length);
    }


    function returnValueByUserTotal(address _user) public view returns(uint256){
        return amountPerUser[_user];
    }

    function returnValueByUserWeekly(address _user, uint256 _week) public view returns(uint256){
        return weeklyCapital[_user][_week];
    }


}
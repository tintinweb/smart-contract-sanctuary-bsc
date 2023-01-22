/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface IERC20 
{
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

contract VillaGames {
    using SafeMath for uint256;
    address public  ceoWallet;
    address authAddress;
   
    IERC20 VILLA;
    struct EntryDetails
    {
        address user;
        uint256 level;
        uint256 amount;
        uint256 winningAmount;
        bool isResultDeclared;
    }

    struct ContestEntryDetails
    {
        uint256 amount;
        uint256 winningAmount;
    }

    struct ContestDetails
    {
        uint256 totalCollectedAmount;
       
        bool isResultDeclared;
        uint256 usersJoined;
    }

    mapping(uint256 => uint256) public PlayAmount;
    mapping(uint256 => uint256) public WinningAmount;

    mapping (string =>EntryDetails) public userEntries;
    mapping(string=>ContestDetails) public contestList;
    mapping (string=>mapping(address=>ContestEntryDetails)) public contestParticipants;

    uint256[3] public winningPercentages = [40, 20, 10];
    event LevelEntry(address indexed user, uint256 level,uint256 amount,uint256 timestamp); 
    event LevelEntryResult(address indexed user, uint256 level,uint256 amount,uint256 timestamp); 

    event ParticipateContest(address indexed user,string contestId,uint256 amount,uint256 timestamp);
    event Winner(address indexed user,string contestId,uint8 position);
   event Refund(address indexed user,string contestId);

    constructor(address payable ceoAddr,address payable  _authAddress) {
        ceoWallet = ceoAddr;
        authAddress = _authAddress;
        VILLA = IERC20(0x9959a7f4bC50a201342ad27C2fffB276abf42329);

                PlayAmount[1]= 1000*1e8;
                WinningAmount[1] = 4000*1e8;
            for(uint256 level = 2; level <=100; level++)
            {
                PlayAmount[level]=  PlayAmount[level-1] + 1000*1e8;
                WinningAmount[level] = PlayAmount[level]*4;
            }

         }

    modifier onlyOwner {
      require(msg.sender == ceoWallet);
      _;
   }

    function setLevelWisePlayAmount(uint256 _level,uint256 _amount) public onlyOwner
    {
        require(_level >= 1 && _level <= 100, "level range is from 1 to 100");
        PlayAmount[_level]=  _amount;

    }

   

   function participateLevel(uint256 level,string memory entryId) external 
   {
       require(userEntries[entryId].user==address(0),"Id allready used");
       userEntries[entryId].user = msg.sender;
       userEntries[entryId].level = level;
       userEntries[entryId].amount = PlayAmount[level];

        VILLA.transferFrom(msg.sender,address(this), PlayAmount[level]);
        emit LevelEntry(msg.sender,level,PlayAmount[level],block.timestamp);
   }

   function levelResult(string memory entryId) external 
   {
       require(msg.sender==authAddress,"Invalid user");
       require(userEntries[entryId].user!=address(0),"Invalid id");
       require(userEntries[entryId].winningAmount==0,"Allready rewarded");
       EntryDetails storage entry = userEntries[entryId];
       if(WinningAmount[entry.level]>0){
            VILLA.transfer(entry.user, WinningAmount[entry.level]);
            emit LevelEntryResult(msg.sender,entry.level,WinningAmount[entry.level],block.timestamp);
            entry.winningAmount = WinningAmount[entry.level];
        }
   }

   function participateContest(string memory contestId,uint256 amount,uint256 maxUsers) external {
       ContestDetails storage contest = contestList[contestId];
       require(contestParticipants[contestId][msg.sender].amount==0,"Allready joined contest");
        require(maxUsers>0,"Allready joined contest"); 
        require(contest.usersJoined<maxUsers,"Max limit reached");
       contestParticipants[contestId][msg.sender].amount = amount;
       VILLA.transferFrom(msg.sender,address(this), amount);
       contest.totalCollectedAmount += amount;
       contest.usersJoined++;
        emit  ParticipateContest(msg.sender,contestId,amount,block.timestamp);
   }

   function declareResultContest(string memory contestId,address[3] memory users) external {
       require(msg.sender==authAddress,"invalid user");
       require(contestList[contestId].isResultDeclared==false,"Allready declared");
       ContestDetails storage contest = contestList[contestId];
       for(uint8 i=0;i<3;i++){
           VILLA.transfer(users[i], contest.totalCollectedAmount.mul(winningPercentages[i]).div(100));
           emit Winner(users[i], contestId, i);
       }
       contestList[contestId].isResultDeclared = true;
   }

   function cancelContest(string memory contestId,address[2] memory users) external {
       require(msg.sender==authAddress,"invalid user");
       require(contestList[contestId].isResultDeclared==false,"Allready declared");
       for(uint8 i=0;i<2;i++){
           if(users[i]!=address(0)){
           VILLA.transfer(users[i], contestParticipants[contestId][users[i]].amount);
           emit Refund(users[i], contestId);
           }
       }
       contestList[contestId].isResultDeclared = true;
   }

   
    function withdrawVILLA(address userAddress,uint256 amount) external onlyOwner
    {
        VILLA.transfer(userAddress, amount);
    }

    function setAuthAddress(address _authAddress) external onlyOwner
    {
        authAddress = _authAddress;
    }

    function transferOwnership(address newOwner) external onlyOwner
    {
        ceoWallet = newOwner;
    }

   
}
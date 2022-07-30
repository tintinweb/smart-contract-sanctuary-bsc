/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserStorage
{
   function AddUser(address userAddress, address Ref) external;
   function AddReferal(address userAddress) external;
   
   
   
   
   function IsUserExist(address addr) external view returns(bool);
   function IsUserExistById(uint id) external view returns (bool);
   function GetReferrer(address userAddress) external view returns (address);
   function GetUserByAddress (address userAddress) external view returns (uint, address,uint);
   function GetUserById(uint id) external view returns (uint, address,uint);
   function GetMembersCount() external view returns(uint);
   function GetUserIdByAddress(address adr) external view returns(uint);
   function GetUserAddressById(uint userId) external view returns (address);
}


interface IFarmController
{ 
    //// FUNCTIONS
    function AddToPull(uint value, address userAddress) external;
    function Register(address user, uint referalId) external;

    //// VIEW
    function UserExist(address userAddress) external view returns (bool);
    function GetReferrer(address userAddress) external view returns (address);
    function GetReferalLinesCount() external view returns(uint);
    function GerReferalRewardLevel(uint level) external view returns (uint);
}

interface IPullStorage
{
    /////   PAYABLE
    function SetMember(uint UserId ) external;
    function SetTicket(uint value, uint userId ) external;
    function SetCurrentPullValue(uint value )  external;
    function AddNewPull( ) external;
    function AddMemberReferalRewards(uint value, uint UserId ) external;
    function AddMemberRewards(uint value, uint UserId ) external;
    function AddToTicket(uint userId, uint value) external;
   
      ///// VIEW
     function GetPullsCount() external view returns (uint); 
     function TicketExistOnPull (uint userId, uint pullId) external view returns(bool);  
     function IsPullExist(uint id) external view returns (bool);
     function GetStatistic() external view returns(uint,uint,uint);
     function IsMemberExist(uint id) external view returns(bool);
     function GetTicketCountOnPull(uint pullId) external view returns(uint);
     function GetTicketInfo(uint pullId, uint ticketNumber) external view returns(uint, uint);
     function GetPullCollectedSum(uint pullId)  external view returns (uint);
     function GetCurrentPull() external view returns(uint,uint,uint);
     function GetMember(uint id ) external view returns(uint,uint);
     function GetTicketsByPullId(uint pullId) external view returns(uint[]memory,uint[]memory);
     function GetLastCurrentPullSum() external view returns (uint);
     function GetPull(uint pullId) external view returns(uint,uint,uint);
     function GetStructure(uint pullId) external view returns(uint,uint,uint, uint[] memory, uint[] memory);
}










contract FarmController is IFarmController
{
    IUserStorage userStorage;
    IPullStorage pullStorage;
    address FarmingAddress;
    address Owner;

    uint[] public referralRewardPercents = 
    [
        0, 
        8, 
        4, 
        3, 
        2, 
        1, 
        1, 
        1  
    ];
    uint rewardableLinesCount = referralRewardPercents.length - 1;



    modifier onlyFarm()
    {
        require(msg.sender == FarmingAddress, "4");
        _;
    }
   constructor(address userStorageAddress, address pullStorageAddress)
    {
        Owner = msg.sender;
        userStorage = IUserStorage(userStorageAddress);
        pullStorage = IPullStorage(pullStorageAddress);
    }
    /// Admin
    function SetFarm(address farmAddress) public
    {
        require(msg.sender == Owner, "2");
        FarmingAddress = farmAddress;
    }
   
     
    //// FUNCTIONS
    function AddToPull(uint value, address userAddress) public override onlyFarm
    {
        uint UserId = userStorage.GetUserIdByAddress(userAddress);
        _BuyTicket(UserId, value);   
    }
    function Register(address userAddress, uint referalId) public override
    {
        require(!userStorage.IsUserExist(userAddress));
        _Register(userAddress, referalId);
    }

    //// VIEW
    function UserExist(address userAddress) override public view returns (bool)
    {
        return userStorage.IsUserExist(userAddress);
    }
    function GetReferrer(address userAddress) override public view returns (address)
    {
        return userStorage.GetReferrer(userAddress);
    }
    function GetReferalLinesCount() override public view returns(uint)
    {
        return rewardableLinesCount;
    }
    function GerReferalRewardLevel(uint level) override public view returns (uint)
    {
        return referralRewardPercents[level];
    }


    /// PRIVATE
    function _BuyTicket(uint userId, uint value) internal 
    {
        if (!pullStorage.IsMemberExist(userId))
        {
            pullStorage.SetMember(userId);
        }
        uint lastValue = pullStorage.GetLastCurrentPullSum();
        uint pullId = pullStorage.GetPullsCount();
        bool existTicket = pullStorage.TicketExistOnPull(userId, pullId);  
        if (lastValue > value)
        {
            if(existTicket)
            {
                pullStorage.AddToTicket(userId, value);
            }
            else
            {
                pullStorage.SetTicket(value,  userId);
            } 
            pullStorage.SetCurrentPullValue(value);
        }
        else
        {
            uint residual = value - lastValue;
            if (existTicket)
            {
                pullStorage.AddToTicket(userId, lastValue);
            }
            else
            {
                pullStorage.SetTicket( lastValue,  userId);
            }    
            pullStorage.SetCurrentPullValue(lastValue);
            pullStorage.AddNewPull();
            if (residual > 0)
            {
                pullStorage.SetTicket( residual,  userId);
                pullStorage.SetCurrentPullValue(residual);
            }
        }
    }
    function _Register(address userAddress, uint refId) internal 
    {
        if (!userStorage.IsUserExistById(refId))
        {
            refId = 1;
        }
        address refAddress = userStorage.GetUserAddressById(refId);
        userStorage.AddUser(userAddress, refAddress);
        uint8 line = 1;
        address ref = refAddress;
        while (line <= rewardableLinesCount && ref != address(0)) 
        {
           userStorage.AddReferal(ref);
           ref = userStorage.GetReferrer(ref);
           line++;
        }
    }
}
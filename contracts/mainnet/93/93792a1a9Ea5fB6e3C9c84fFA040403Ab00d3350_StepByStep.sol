/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrancyGuard 
{
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor()
    {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() 
    {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract StepByStep is ReentrancyGuard
{


   // Events 
    event RewardFromPull(uint userId,  uint rewardValue);
          
    event UserRegistration(uint referralId, uint referrerId);
    
    event ReferralPayout(uint referrerId, uint rewardValue);


   // Modificators
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    address payable public owner;
    uint[] public referralRewardPercents = 
    [
        0, 
        5, 
        3,
        2
    ];
    uint rewardableLinesCount = referralRewardPercents.length - 1;

    struct User 
    {
        uint id;
        uint refererId;
        address refererAddress;
        uint referals;
        uint SumDeposite;
        uint RewardsForPulls;
        uint RewardsFromRef;
    }
    struct Pull
    {
        uint id;
        uint CrowndFindingSum;
        uint CollectSum;
    }
    struct Ticket
    {
        address userAddress;
        uint Sum;
        uint UserId;
    }
    struct GlobalStatistic
    {
        uint TotalPullsClose;
        uint TotalFoundSum;
        uint TotalUsers;
        uint TotalRewards;
    }
    uint newUserId = 2;
    mapping (address => User) Users;
    mapping(uint => address) usersAddressById;
    uint newPullId = 1;
    mapping (uint => Pull) Pulls;
    mapping (uint => Ticket[]) Tickets;
    GlobalStatistic globalStat;
    bool public TradeOpen;
    uint public FoundingSum;
    Pull public CurrentPull;



    constructor ()
    {
        owner = payable(msg.sender);
        Users[owner] = User
        ({
            id : 1,
            refererId : 1,
            refererAddress : address(0),
            referals : 0,
            SumDeposite : 0,
            RewardsForPulls : 0,
            RewardsFromRef : 0
        });
        usersAddressById[1] = owner;
        globalStat.TotalUsers++;
        TradeOpen = true;
        FoundingSum = 60 ether;
        
        Pulls[newPullId] = Pull
        ({
           id : newPullId,
           CrowndFindingSum : FoundingSum,
           CollectSum  : 0
        });
        CurrentPull = Pulls[newPullId];
        newPullId++;
    }

    receive() external payable
    {
        BuyTicket(1);
    }
    
    /// Payable
    function RewardToPull(uint pullId) external payable 
    {
        require(IsPullExist(pullId), "Pull not found");
        Pull memory pull = Pulls[pullId];
        Ticket[] memory tickets = Tickets[pullId]; 
        uint OnePercent = pull.CrowndFindingSum/100;

        for (uint tick = 0; tick<tickets.length; tick++)
        {
            uint RewardPercent = tickets[tick].Sum/OnePercent;
            uint UserReward = msg.value/100*RewardPercent;
            address UserAddres = usersAddressById[tickets[tick].UserId];
            User memory  RewarderingUser= Users[UserAddres];
            uint line = 1;
            uint referalPayCount ;
            address ReferalAddress = RewarderingUser.refererAddress;
            while (line <= rewardableLinesCount && ReferalAddress != owner) 
            {
                uint ReferalReward = UserReward/100*referralRewardPercents[line];
                bool sentRef = payable(ReferalAddress).send(ReferalReward);  
                if (!sentRef)
                {
                    owner.transfer(ReferalReward);
                }
                Users[ReferalAddress].RewardsFromRef += ReferalReward;
                    emit ReferralPayout(Users[ReferalAddress].id, ReferalReward);
                ReferalAddress = Users[ReferalAddress].refererAddress;
                line ++;
                referalPayCount +=  ReferalReward;
            }
            UserReward = UserReward - referalPayCount;
            bool sent = payable(UserAddres).send(UserReward);  
            if (!sent)
            {
                owner.transfer(UserReward);
            }
            Users[UserAddres].RewardsForPulls += UserReward;
                emit RewardFromPull(RewarderingUser.id, UserReward);
        }

        globalStat.TotalRewards += msg.value;
    }


    function BuyTicket(uint refId) public payable
    {
        require (((CurrentPull.CollectSum + msg.value) <= CurrentPull.CrowndFindingSum ), "The amount exceeds the amount needed to collect");
        require (TradeOpen , "Closed");
        
        if (!IsUserRegistered(msg.sender))
        {
            address Referal;
            if (refId != 0)
            {
                if (IsUserRegisteredById(refId))
                {
                    Referal = usersAddressById[refId];
                }
                else 
                {
                    Referal = owner;
                }   
            }        
            User memory Newuser = User
            ({
            id : newUserId++,
            refererId  : refId,
            refererAddress : Referal,
            referals : 0,
            SumDeposite : 0,
            RewardsForPulls : 0,
            RewardsFromRef : 0
            });
            Users[msg.sender] = Newuser;
            usersAddressById[Newuser.id] = msg.sender;
            uint line = 1;
            address ReferalAddres = Newuser.refererAddress;
            while (line <= rewardableLinesCount && ReferalAddres != owner)
            {
                line++;
                Users[ReferalAddres].referals ++;
                ReferalAddres = Users[ReferalAddres].refererAddress;
            }
            
        }

        Ticket memory ticket = Ticket
        ({
            userAddress : msg.sender,
            Sum : msg.value,
            UserId : Users[msg.sender].id
        });
        Tickets[CurrentPull.id].push(ticket);
        CurrentPull.CollectSum += msg.value;      
        Users[msg.sender].SumDeposite += msg.value;
        if (CurrentPull.CollectSum == CurrentPull.CrowndFindingSum)
        {
            Pull memory newPull = Pull
            ({
                id: newPullId++,
                CrowndFindingSum : FoundingSum,
                CollectSum : 0
            });
            Pulls[newPullId] = newPull;
            CurrentPull = newPull;
            globalStat.TotalPullsClose ++;
        }
        globalStat.TotalFoundSum += msg.value;
        bool sent = payable(owner).send(msg.value);  
            if (!sent)
            {
                owner.transfer(msg.value);
            }
    }

    function register(uint refId) payable public nonReentrant
    {
    require(!isContract(msg.sender), "Can not be a contract");
    require(!IsUserRegistered(msg.sender), "User registered");
    address Referal;
        if (refId != 0)
        {
            if (IsUserRegisteredById(refId))
            {
                Referal = usersAddressById[refId];
            }
            else 
            {
                Referal = owner;
            }   
        }
        else
        {
            Referal = owner;
        }
        User memory Newuser = User
            ({
            id : newUserId++,
            refererId  : refId,
            refererAddress : Referal,
            referals : 0,
            SumDeposite : 0,
            RewardsForPulls : 0,
            RewardsFromRef : 0
            });
            Users[msg.sender] = Newuser;
            usersAddressById[Newuser.id] = msg.sender;
            Users[Referal].referals ++;
}










    // API 
    function GetUserInfo(address userAddress) public view returns(uint,uint,uint,uint,uint) 
    {
        User memory user = Users[userAddress];
        return 
        (
            user.id,
            user.referals,
            user.SumDeposite,
            user.RewardsForPulls,
            user.RewardsFromRef
        );
    }

    function GetStatistic() public view returns(uint,uint,uint,uint)
    {
        return 
        (
        globalStat.TotalPullsClose,
        globalStat.TotalFoundSum,
        globalStat.TotalUsers,
        globalStat.TotalRewards
        );
    }
    function IsUserRegistered(address userAddress) view public returns(bool)
    {
    return Users[userAddress].id != 0;
    }
    function IsUserRegisteredById(uint id) view public returns(bool)
    {
    return usersAddressById[id] != address(0);
    }
    function isContract(address addr) public view returns (bool)
    {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return size != 0;
    }
    function isPullHaveTickets(uint pullId) public view returns(bool)
    {
        return Tickets[pullId].length != 0;
    } 
    function IsPullExist(uint id) public view returns (bool)
    {
        return Pulls[id].id != 0;
    }
    function ChangeTradeState() public payable onlyOwner
    {
        TradeOpen = !TradeOpen;
    }
    function withdraw(uint count) external onlyOwner
    {
    owner.transfer(count);
    }
    function GetPullsTicketCount(uint pullId) public view returns(uint)
    {
        Ticket[] memory ticket = Tickets[pullId];
        return ticket.length;
    }
    function GetTicketInfo(uint pullId, uint ticketNumber) public view returns(address,uint,uint)
    {
        Ticket[] memory tickets = Tickets[pullId];
        Ticket memory ticket = tickets[ticketNumber-1]; 
        return 
        (
           ticket.userAddress,
           ticket.Sum,
           ticket.UserId
        );
    }
    function GetBallance () public view onlyOwner returns(uint) 
    {
        return address(this).balance;
    }
}
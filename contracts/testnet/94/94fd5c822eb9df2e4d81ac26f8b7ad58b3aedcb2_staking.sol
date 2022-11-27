/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Erc20_SD {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

contract staking {
    Erc20_SD token;

    address public owner;

    // uint RewardRate= 30;

    constructor(address _token, address Owner) {
        token = Erc20_SD(_token);
        owner = Owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not the owner");
        _;
    }

    uint256 RewardRate = 30;

    uint256 timestep = 60;

    struct Staker {
        uint256 amount;
        uint256 StartTime;
        uint lastclaim;
        uint ClaimReward;
        address refer;
        uint256 EndTime;
        uint256 count;
        bool IsStaked;
    }

    mapping(address => uint256) public Counter;
    mapping(address => mapping(uint256 => Staker)) public Stake;

    function Depositfunds(uint256 _amount, address _refer) public {
        require(_amount > 0, "Please Enter right amount to stake");

        uint256 Counter1 = Counter[msg.sender];
                 require(_refer != msg.sender,"Can't Refer yourself.");

        if(Stake[msg.sender][0].refer==address(0))
        {
            if(Stake[_refer][0].IsStaked && _refer !=address(0)) {
                Stake[msg.sender][0].refer = _refer;
            } else {
                Stake[msg.sender][0].refer = owner;
            }
        }
        
        _refer= Stake[msg.sender][0].refer;

        Stake[msg.sender][Counter1] = Staker({
            amount: _amount,
            StartTime: block.timestamp,
            lastclaim : block.timestamp,
            ClaimReward:0,
            refer: _refer,
            EndTime: block.timestamp + timestep,
            count: 0,
            IsStaked: true
        });
        Counter[msg.sender]++;

        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawal(uint256 index) public {
        require(Stake[msg.sender][index].IsStaked,"The stake doesn't exist");
        Staker storage Stakeinfo = Stake[msg.sender][index];
        require(block.timestamp-Stakeinfo.lastclaim >=timestep);
        
                uint calc =((Stakeinfo.amount*RewardRate)/100);
        uint Reward = (block.timestamp-Stakeinfo.lastclaim)/timestep;
        Reward = Reward*calc;

        if(Reward>=Stakeinfo.amount*180/100)
        {
            Reward = Stakeinfo.amount*180/100-Stakeinfo.ClaimReward;
             Stakeinfo.IsStaked=false;

        }

        Stakeinfo.ClaimReward= Stakeinfo.ClaimReward + Reward;

        token.transferFrom(owner,msg.sender,Reward);

        Stakeinfo.lastclaim= block.timestamp;
    }
    // function withdrawal(uint256 index) public {
    //     require(Stake[msg.sender][index].IsStaked,"The stake doesn't exist");
    //     Staker storage Stakeinfo = Stake[msg.sender][index];
    //     // uint256 timestep = Stake[msg.sender][index].StartTime;

    //     if(block.timestamp-Stakeinfo.lastclaim > time1 && block.timestamp-Stakeinfo.lastclaim< time2 && Stakeinfo.ClaimReward<30)
    //     {
    //         uint256 Reward = (Stake[msg.sender][index].amount * RewardRate) /100;
    //         token.transferFrom(owner, msg.sender, Reward);
    //         Stake[msg.sender][index].ClaimReward= Reward;
    //     }
    //     if(block.timestamp-Stakeinfo.lastclaim > time2 && block.timestamp-Stakeinfo.lastclaim< time3 && Stakeinfo.ClaimReward<60)
    //     {
    //         uint256 Reward = (Stake[msg.sender][index].amount * RewardRate*2) /100;
    //         token.transferFrom(owner, msg.sender, Reward);
    //         Stake[msg.sender][index].ClaimReward= Reward;
    //     }
        
}

//     function withdrawal(uint256 index) public {
//         require(Stake[msg.sender][index].IsStaked,"The stake doesn't exist");
//         uint256 timestep = Stake[msg.sender][index].StartTime;
//         if (
//             block.timestamp > time1 + timestep &&
//             block.timestamp < time2 + timestep
//         ) {
//             uint256 Reward = (Stake[msg.sender][index].amount * RewardRate) /
//                 100;
//             token.transferFrom(owner, msg.sender, Reward);
//             Stake[msg.sender][index].count = 1;
//         } else if (
//             block.timestamp > time2 + timestep &&
//             block.timestamp < time3 + timestep
//         ) {
//             if (Stake[msg.sender][index].count == 1) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             } else {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     2) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             Stake[msg.sender][index].count = 2;
//         } else if (
//             block.timestamp > time3 + timestep &&
//             block.timestamp < time4 + timestep
//         ) {
//             if (Stake[msg.sender][index].count == 0) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     3) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             } else if (Stake[msg.sender][index].count == 1) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     2) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 2) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             Stake[msg.sender][index].count = 3;
//         }

//         else if (
//             block.timestamp > time4 + timestep &&
//             block.timestamp < time5 + timestep
//         ) {
//             if (Stake[msg.sender][index].count == 0) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     4) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             } else if (Stake[msg.sender][index].count == 1) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     3) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 2) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate*2) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 3) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             Stake[msg.sender][index].count = 4;
//         }

//         else if (
//             block.timestamp > time5 + timestep &&
//             block.timestamp < time6 + timestep
//         ) {
//             if (Stake[msg.sender][index].count == 0) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     5) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             } else if (Stake[msg.sender][index].count == 1) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     4) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 2) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate*3) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 3) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate*2) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 4) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             Stake[msg.sender][index].count = 5;
//         }

//         else if (
//             block.timestamp > time6 + timestep
//         ) {
//             if (Stake[msg.sender][index].count == 0) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     6) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             } else if (Stake[msg.sender][index].count == 1) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate *
//                     5) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 2) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate*4) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 3) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate*3) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 4) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate*2) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             else if (Stake[msg.sender][index].count == 5) {
//                 uint256 Reward = (Stake[msg.sender][index].amount *
//                     RewardRate) / 100;
//                 token.transferFrom(owner, msg.sender, Reward);
//             }
//             Stake[msg.sender][index].count = 6;
            
//         Stake[msg.sender][index].IsStaked =false;
//         }

//     }
// }

//     // 3 minutes
//     uint TimePeriod = 3*60;

//     struct Staker{
//    uint amount;
//    uint StartTime;
//    uint EndTime;
//    bool IsStaked;
//    }

//     mapping(address=>uint) public Counter;
//     mapping(address => mapping(uint => Staker)) Stake;

//     function Depositfunds(uint256 _amount) public {
//         require(_amount>0,"Please Enter right amount to stake");

//         uint Counter1 = Counter[msg.sender];
//         Stake[msg.sender][Counter1] = Staker({
//             amount : _amount,
//             StartTime : block.timestamp,
//             EndTime : block.timestamp+TimePeriod,
//             IsStaked : true
//         });
//         Counter[msg.sender]++;

//         token.transferFrom(msg.sender, address(this), _amount);

//     }

//     function withdrawal(uint index) public{

//         require(block.timestamp>Stake[msg.sender][index].EndTime,"Wait till the right time");
//         require(Stake[msg.sender][index].IsStaked== true,"User didn't Staked");
//         uint Reward = (Stake[msg.sender][index].amount*RewardRate)/100;
//         uint amount = Stake[msg.sender][index].amount;

//         token.transfer(msg.sender, amount);
//         token.transferFrom(owner, msg.sender, Reward);

//         Stake[msg.sender][index].IsStaked= false;

//     }
// }
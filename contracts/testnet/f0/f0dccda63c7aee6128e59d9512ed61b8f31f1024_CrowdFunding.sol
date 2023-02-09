/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// 创建不同的募资活动，用来募集以太坊
// 记录相应活动下的募资总体信息（参与人数，募集的以太坊数量），以及记录参与的用户地址以及投入的数量
// 业务逻辑(用户参与、添加新的募集活动、活动结束后进行资金领取)

pragma solidity 0.8.11;

contract CrowdFunding  {
    address immutable owner;

    struct Campaign {
        address payable receiver;
        uint numFunders;
        uint fundingGoal;
        uint totalAmount;
    }

    struct Funder {
        address addr;
        uint amount;
    }

    uint public numCampaigns;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => Funder[]) public funders;

    Campaign[] public campaignsArray;
    mapping(uint => mapping(address => bool)) public isParticipate;

    event CampaignLog(uint campaignID, address receiver, uint goal);

    // 发布合约的拥有者才能发布活动
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
    }


    modifier judgePaticipate(uint campaignID) {
        require(isParticipate[campaignID][msg.sender] == false);
        _;
    }

    
    function newCampaign(address payable receiver, uint goal) external isOwner() returns(uint campaignID) {
        campaignID = numCampaigns++;
        Campaign storage c = campaigns[campaignID];
        c.receiver = receiver;
        c.fundingGoal = goal;

        campaignsArray.push(c);
        emit CampaignLog(campaignID, receiver, goal);
    }

    function bid(uint campaignID) external payable judgePaticipate(campaignID){
        Campaign storage c = campaigns[campaignID];

        c.totalAmount += msg.value;
        c.numFunders += 1;

        funders[campaignID].push(Funder({
            addr: msg.sender,
            amount: msg.value
        }));

        isParticipate[campaignID][msg.sender] = true;
    }

    function withdraw(uint campaignId) external returns(bool reached) {
         Campaign storage c = campaigns[campaignId];

         if (c.totalAmount < c.fundingGoal) {
             return false;
         }

         uint amount = c.totalAmount;
         c.totalAmount = 0;
         c.receiver.transfer(amount);

         return true;
    } 
}
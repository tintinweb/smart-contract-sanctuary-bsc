/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

contract CrowdFunding{
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    struct Campaign{
        address payable receiver;
        uint numFunders;
        uint fundingGoal;
        uint totalAmount;
    }

    struct Funder{
        address addr;
        uint amount;
    }

    
    uint public numCampagins;
    mapping(uint => Campaign) compaigns;
    mapping(uint => Funder[]) funders;
    mapping(uint => mapping(address => bool)) public isParticipate;

    modifier judgeParticipate(uint campaignID){
        require(isParticipate[campaignID][msg.sender] == false);
        _;
    }

    event CampaignLog(uint campaignID,address receiver,uint goal);

    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }

    function newCampain(address payable receiver,uint goal) external isOwner() returns(uint campaignID){
        campaignID = numCampagins++;
        Campaign storage c = compaigns[campaignID];
        c.receiver = receiver;
        c.fundingGoal = goal;

        emit CampaignLog(campaignID,receiver,goal);
    }

    function bid(uint campainID) external payable judgeParticipate(campainID){
        Campaign storage c = compaigns[campainID];
        c.totalAmount += msg.value;
        c.numFunders += 1;

        funders[campainID].push(Funder({
            addr:msg.sender,
            amount:msg.value
        }));

        isParticipate[campainID][msg.sender] = true;
    }

    function withdraw(uint campaignID) external returns(bool reached){
        Campaign storage c = compaigns[campaignID];

        if(c.totalAmount < c.fundingGoal){
            return false;
        }

        uint amount = c.totalAmount;
        c.totalAmount = 0;
        c.receiver.transfer(amount);
        return true;
    }

}
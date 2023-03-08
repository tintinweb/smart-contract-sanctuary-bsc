/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


contract MoonTwo{
    address public GameTokenAddress;
    address public teamAddress;
    address public owner;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public cycle;
    uint256 public GameDefiCount;
    uint256 public SMcount;
    string private moonName = "Demo";

    struct BalanceInfo{
        uint256  superBalance;
        uint256  smallBalance;
        uint256  everyoneBalance;
        uint256  cycleBalance;
    }

    struct FeeInfo{
        uint256  teamRewardsFee;
        uint256  partnerRewardsFee;
        uint256  superJackpotFee;
        uint256  smallRewardFee;
        uint256  everyoneRewardsFee;
        uint256  cycleFee;
    }

    struct AnnouncementInfo{
        address  newBuyAddress;
        uint256  queryCount;
        uint256  billboardCount;
        uint256  billboardPrice;
        string   firstBillboardName;
        address  firstBillboardAddeess;
        address  SMRewardsAddress;
        uint256  SmRewardCount;
    }

    struct UserInfo {
        address partnerAddress;
        uint256 rewardsReceived;
        uint256 partnerRewards;
        uint256 received;
        uint256 SFRewards;
        uint256 SMRewards;
        bool billboardStatus;
    }

    mapping(uint256 => address) public cycleInfo;
    mapping(string => address) public UserBillboard;
    mapping(bytes32 => address) public UserBillboardHash;
    mapping(address => string) public UserBillboardAddress;
    mapping(address => bytes32) public UserBillboardHashAddress;
    mapping(address => UserInfo) public Users;
    mapping(string => AnnouncementInfo) public Announcement;
    mapping(string => FeeInfo) public Fee;
    mapping(string => BalanceInfo) public Balance;


    constructor(
        address teamaddress_,
        address TokenDividendTrackerAddress_,
        uint256[6] memory FeeSetting_
    ) payable {
        teamAddress = teamaddress_;
        GameTokenAddress = TokenDividendTrackerAddress_;
        Fee[moonName].teamRewardsFee = FeeSetting_[0];
        Fee[moonName].partnerRewardsFee = FeeSetting_[1];
        Fee[moonName].superJackpotFee = FeeSetting_[2];
        Fee[moonName].smallRewardFee = FeeSetting_[3];
        Fee[moonName].everyoneRewardsFee = FeeSetting_[4];
        Fee[moonName].cycleFee = FeeSetting_[5];
        owner = msg.sender;
        Announcement[moonName].billboardPrice = 1e18;
        cycle = 1;
    }

    receive() external payable {}

    function buyKey(string memory _billboardName,uint256 _quantity) public payable{
        for (uint i = 0; i < _quantity; i++) {
            stake(_billboardName,1);
        }
    }


    function stake(
        string memory _billboardName,
        uint256 _quantitys
    ) public payable{
        require(msg.value == 1e16 * _quantitys,"PRICE ERROR");
        require(bytes(_billboardName).length < 100,"LENGTH ERROR");
        require(block.timestamp > endTime,"TIME ERROR");

        if(GameDefiCount > 99){
            startTime = block.timestamp;
            endTime = block.timestamp + 1 days;
        }
        if(endTime != 0 && (endTime - block.timestamp) < 1 days) {
            endTime += 60;
        }
        bytes32 collisionHash  = collision(_billboardName);

        if(UserBillboardHash[collisionHash] != address(0)){
            Users[msg.sender].partnerAddress = UserBillboardHash[collisionHash];
        }
        dividends(_quantitys);
        GameDefiCount += _quantitys;
        Announcement[moonName].newBuyAddress = msg.sender;
        Announcement[moonName].queryCount = _quantitys;
    }


    function reinvestmentIncome(string memory _billboardName) external{

        uint256 _quantity = Users[msg.sender].rewardsReceived / 1e16;
        Users[msg.sender].rewardsReceived = Users[msg.sender].rewardsReceived - Users[msg.sender].rewardsReceived / 1e16;
        getreinvestmentIncome(_billboardName,_quantity);
        Announcement[moonName].newBuyAddress = msg.sender;
        Announcement[moonName].queryCount = _quantity;
    }

    function getreinvestmentIncome(
        string memory _billboardName,
        uint256 _quantity) internal{

        if(GameDefiCount > 99){
            startTime = block.timestamp;
            endTime = block.timestamp + 1 days;
        }

        if(endTime != 0 && (endTime - block.timestamp) < 1 days) {
            endTime + 60;
        }
        bytes32 collisionHash  = collision(_billboardName);
        if(UserBillboardHash[collisionHash] != address(0)){
            Users[msg.sender].partnerAddress = UserBillboardHash[collisionHash];
        }
        dividends(_quantity);
        GameDefiCount += _quantity;
    }




    function helplaunch() public{
        require(!isContract(msg.sender), "This function can only be called by an externally owned account.");
        require(block.timestamp > endTime,"ERROR TIME");
        require(cycleInfo[cycle] == Announcement[moonName].newBuyAddress,"ERROR ADDRESS");
        require(Announcement[moonName].newBuyAddress != address(0),"ERROR ADDRESS");
        if(isMFee() == true){
            startTime = block.timestamp;
            endTime = block.timestamp + 1 days;
            cycleInfo[cycle] = Announcement[moonName].newBuyAddress;
            uint256 HFee = Balance[moonName].superBalance * (1) / (100) ;
            uint256 Sub = Balance[moonName].superBalance;
            Users[msg.sender].SFRewards = HFee ;
            delete Balance[moonName].superBalance;
            Balance[moonName].superBalance += Balance[moonName].cycleBalance;
            cycle++;
            payable(Announcement[moonName].newBuyAddress).transfer(Sub - HFee);
        }else{
            endTime += 1 hours;
        }
    }

    function dividends(uint256 quantity) internal {
        uint256 FIXED_POINT = 10**18;

        uint256 teamFee = (msg.value * FIXED_POINT * Fee[moonName].teamRewardsFee / 100) * quantity;
        uint256 partnerFee = (msg.value * FIXED_POINT * Fee[moonName].partnerRewardsFee / 100) * quantity;
        uint256 superJackpotFee = (msg.value * FIXED_POINT * Fee[moonName].superJackpotFee / 100) * quantity;
        uint256 smallRewardFee = (msg.value * FIXED_POINT * Fee[moonName].smallRewardFee / 100) * quantity;
        uint256 everyoneFee = (msg.value * FIXED_POINT * Fee[moonName].everyoneRewardsFee / 100) * quantity;
        uint256 cycleFee = (msg.value * FIXED_POINT * Fee[moonName].cycleFee / 100) * quantity;

        Balance[moonName].superBalance += superJackpotFee / FIXED_POINT;
        Balance[moonName].smallBalance += smallRewardFee / FIXED_POINT;
        Balance[moonName].cycleBalance += cycleFee / FIXED_POINT;
        Balance[moonName].everyoneBalance += everyoneFee / FIXED_POINT;
        payable(teamAddress).transfer(teamFee / FIXED_POINT);
        if (Users[msg.sender].partnerAddress == address(0)) {
            payable(teamAddress).transfer(partnerFee / FIXED_POINT);
        } else {
            Users[Users[msg.sender].partnerAddress].partnerRewards += partnerFee / FIXED_POINT;
        }

        if (isSMFee()) {
            Users[msg.sender].SMRewards += Balance[moonName].smallBalance / FIXED_POINT;
            Announcement[moonName].SMRewardsAddress = msg.sender;
            Announcement[moonName].SmRewardCount = Balance[moonName].smallBalance / FIXED_POINT;
            Balance[moonName].smallBalance = 0;
            SMcount = 0;
        }
        SMcount++;
    }

    function withdrawSmallRewards() public{
        require(!isContract(msg.sender), "This function can only be called by an externally owned account.");
        require(Users[msg.sender].SMRewards > 0 ,"No rewards to withdraw.");
        uint256 rewards = Users[msg.sender].SMRewards;
        Users[msg.sender].SMRewards = 0;
        payable(msg.sender).transfer(rewards);
    }


    function superJackpotReceive() public{
        require(!isContract(msg.sender), "This function can only be called by an externally owned account.");
        require(msg.sender == Announcement[moonName].newBuyAddress,"Sender is not the latest buyer");
        require(block.timestamp > endTime,"Current time is not after end time");
        require(cycleInfo[cycle] == Announcement[moonName].newBuyAddress,"Latest buyer is not correct");
        if(isMFee()){
            startTime = block.timestamp;
            endTime = block.timestamp + 1 days;
            Balance[moonName].superBalance = 0;
            cycleInfo[cycle] = msg.sender;
            cycle++;
            Balance[moonName].superBalance = Balance[moonName].cycleBalance;
            payable(msg.sender).transfer(Balance[moonName].superBalance);
        }else{
            endTime += 1 hours;
        }
    }

    function isSMFee() public view returns(bool){
        if(rand() < SMcount ){
            return true;
        }
        return false;
    }

    function isMFee() internal view returns(bool){
        if(rand() < 30){
            return true;
        }
        return false;
    }

    function rand() public view returns(uint8) {
        bytes32 blockHash = blockhash(block.number - 1);
        bytes32 seed = keccak256(abi.encodePacked(block.timestamp, blockHash));
        uint8 random = uint8(uint256(seed) % 101);
        return random;
    }


    function isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function collision(
        string memory _text
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text));
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

contract TokenFarm {
    using SafeMath for uint256;
    IERC20 public tokenAddr; //

    address public owner;

    uint256 public totalPackage;
    uint256 public totalFarmers;
    uint256 public percentDivider;
    uint256 public totalFee;
    uint256 public flexibleFarmingAPY;
    uint256 public maxTokenAmount;
    uint256 public minimumTokenAmount;

    uint256[5] public Duration = [30 days, 90 days, 180 days, 270 days, 560 days];  // these are locking period of token we can also place  no of seconds here
    uint256[5] public Bonus = [21, 75, 175, 300, 450]; // these four bonus variable is related to duration and the amount will be multiply by 10 like we have to set 10 percent then put 100

    struct Farm {
        uint256 staketime;
        uint256 lockingtime;
        uint256 tokenamount;
        uint256 nativeamount;
        uint256 reward;
        uint256 lastharvesttime;
        uint256 harvestreward;
        uint256 persecondreward;
        bool harvested;
        bool withdrawn;
    }

    struct package {
        uint256 nativeAmount;
        uint256 tokenAmount;
        uint256 rewardTokenAmount;
        uint256 lockingPeriod;
        bool active;
        bool isExist;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalStakedNativeUser;
        uint256 totalUnstakedTokenUser;
        uint256 totalUnstakedNativeUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 farmCount;
        bool alreadyExists;
    }

    mapping(address => User) public Farmers;
    mapping(uint256 => address) public FarmersID;
    mapping(address => mapping(uint256 => Farm)) public farmingRecord;
    mapping(uint256 => package) public Package ;

    event FARM(address Staker, uint256 amount, uint256 bnbamount);
    event HARVEST(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount, uint256 bnbamount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }
    constructor(address payable _owner, address token1) {
        owner = _owner; // address of owner of contract
        tokenAddr = IERC20(token1); // address of token that we are using here
        totalFee = 0; // put the percent fee if token is getting any fee on transaction (also multiply with 10)
        percentDivider = 1000;
        flexibleFarmingAPY = 140;
        minimumTokenAmount = 1e11;
        maxTokenAmount = tokenAddr.totalSupply();
    }

    function createFlexbleFarm(uint256 amount1)public payable{
        require(msg.value >= getRatio(amount1), "Error");
        require(amount1 >= minimumTokenAmount, "amount should be more than minimum amount");

        uint256 amount = amount1.sub((amount1.mul(totalFee)).div(percentDivider));  // calculate the amount that goes in contract if token have fees 

        if (!Farmers[msg.sender].alreadyExists) {
            Farmers[msg.sender].alreadyExists = true;
            FarmersID[totalFarmers] = msg.sender;
            totalFarmers++;
        }
        (bool success,)  = address(this).call{ value: msg.value}("");
        require(success, "native failed");

        tokenAddr.transferFrom(msg.sender, address(this), amount1);

        uint256 index = Farmers[msg.sender].farmCount;
        Farmers[msg.sender].totalStakedTokenUser = Farmers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        
        Farmers[msg.sender].totalStakedNativeUser = Farmers[msg.sender]
            .totalStakedNativeUser
            .add(msg.value);

        farmingRecord[msg.sender][index].lockingtime = 0;
        farmingRecord[msg.sender][index].staketime = block.timestamp;
        farmingRecord[msg.sender][index].tokenamount = amount;
        farmingRecord[msg.sender][index].nativeamount = msg.value;
        farmingRecord[msg.sender][index].reward = 0;
        farmingRecord[msg.sender][index].persecondreward = (amount
            .mul(140)
            .div(percentDivider)).div(31104000);
        farmingRecord[msg.sender][index].lastharvesttime = 0;
        farmingRecord[msg.sender][index].harvestreward = 0;
        Farmers[msg.sender].farmCount++;

        emit FARM(msg.sender, amount, msg.value);

    }
    function createLockFarm(uint256 timeperiod, uint256 amount1)public payable{
        require(timeperiod >= 0 && timeperiod <= 4, "Invalid Locking Period");
        require(msg.value >= getRatio(amount1), "Error");
        require(amount1 >= minimumTokenAmount, "amount should be more than minimum amount");

        uint256 amount = amount1.sub((amount1.mul(totalFee)).div(percentDivider));  // calculate the amount that goes in contract if token have fees 

        if (!Farmers[msg.sender].alreadyExists) {
            Farmers[msg.sender].alreadyExists = true;
            FarmersID[totalFarmers] = msg.sender;
            totalFarmers++;
        }
        (bool success,)  = address(this).call{ value: msg.value}("");
        require(success, "native failed");

        tokenAddr.transferFrom(msg.sender, address(this), amount1);

        uint256 index = Farmers[msg.sender].farmCount;
        Farmers[msg.sender].totalStakedTokenUser = Farmers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        
        Farmers[msg.sender].totalStakedNativeUser = Farmers[msg.sender]
            .totalStakedNativeUser
            .add(msg.value);

        farmingRecord[msg.sender][index].lockingtime = Duration[timeperiod];
        farmingRecord[msg.sender][index].staketime = block.timestamp;
        farmingRecord[msg.sender][index].tokenamount = amount;
        farmingRecord[msg.sender][index].nativeamount = msg.value;
        farmingRecord[msg.sender][index].reward = amount
            .mul(Bonus[timeperiod])
            .div(percentDivider);
        farmingRecord[msg.sender][index].persecondreward = farmingRecord[
            msg.sender
        ][index].reward.div(Duration[timeperiod]);
        farmingRecord[msg.sender][index].lastharvesttime = 0;
        farmingRecord[msg.sender][index].harvestreward = 0;
        Farmers[msg.sender].farmCount++;

        emit FARM(msg.sender, amount, msg.value);
    }

    /** This function is used for staking */
    function createPackageFarm(uint256 packageIndex, uint256 amount1) public payable {
        require(Package[packageIndex].isExist,"Invalid Package");
        require(Package[packageIndex].active,"Package deactivated");
        require(amount1 >= minimumTokenAmount, "amount should be more than minimum amount");
        require(msg.value == Package[packageIndex].nativeAmount && amount1 == Package[packageIndex].tokenAmount);
        uint256 amount = amount1.sub((amount1.mul(totalFee)).div(percentDivider));  // calculate the amount that goes in contract if token have fees 

        if (!Farmers[msg.sender].alreadyExists) {
            Farmers[msg.sender].alreadyExists = true;
            FarmersID[totalFarmers] = msg.sender;
            totalFarmers++;
        }
        (bool success,)  = address(this).call{ value: msg.value}("");
        require(success, "native failed");

        tokenAddr.transferFrom(msg.sender, address(this), amount1);

        uint256 index = Farmers[msg.sender].farmCount;
        Farmers[msg.sender].totalStakedTokenUser = Farmers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        
        Farmers[msg.sender].totalStakedNativeUser = Farmers[msg.sender]
            .totalStakedNativeUser
            .add(msg.value);


        farmingRecord[msg.sender][index].lockingtime = Package[packageIndex].lockingPeriod;
        farmingRecord[msg.sender][index].staketime = block.timestamp;
        farmingRecord[msg.sender][index].tokenamount = amount;
        farmingRecord[msg.sender][index].nativeamount = msg.value;
        farmingRecord[msg.sender][index].reward = Package[packageIndex].rewardTokenAmount;
        farmingRecord[msg.sender][index].persecondreward = farmingRecord[
            msg.sender
        ][index].reward.div(Package[packageIndex].lockingPeriod);
        farmingRecord[msg.sender][index].lastharvesttime = 0;
        farmingRecord[msg.sender][index].harvestreward = 0;
        Farmers[msg.sender].farmCount++;

        emit FARM(msg.sender, amount, msg.value);
    }

    function createPackage(uint256 nativelimit, uint256 tokenLimit, uint256 rewardAmount, uint256 LockPeriod)external onlyowner{
        Package[totalPackage].nativeAmount = nativelimit;
        Package[totalPackage].tokenAmount = tokenLimit;
        Package[totalPackage].rewardTokenAmount = rewardAmount;
        Package[totalPackage].lockingPeriod = LockPeriod;
        Package[totalPackage].active = true;
        Package[totalPackage].isExist = true;
        totalPackage++;
    }

    function deactivatePackage(uint256 index) external onlyowner{
        require(Package[index].isExist,"Package does not exist");
        require(Package[index].active,"Package is already deactivated");
        Package[index].active = false;
    }

    function activatePackage(uint256 index) external onlyowner{
        require(Package[index].isExist,"Package does not exist");
        require(Package[index].active == false,"Package is already active");
        Package[index].active = true;
    }


    function withdraw(uint256 index) public {
        require(!farmingRecord[msg.sender][index].withdrawn, "already withdrawn");
        require(
            farmingRecord[msg.sender][index].lockingtime.add(farmingRecord[msg.sender][index].staketime) < block.timestamp,
            "cannot unstake after before duration"
        );

        if(!farmingRecord[msg.sender][index].harvested){
            harvest(index);
             if(!farmingRecord[msg.sender][index].harvested){
                 farmingRecord[msg.sender][index].harvested = true;
             }
        }
        farmingRecord[msg.sender][index].harvested = true;

        tokenAddr.transfer(
            msg.sender,
            farmingRecord[msg.sender][index].tokenamount
        );

        payable(msg.sender).transfer(farmingRecord[msg.sender][index].nativeamount);
        

        Farmers[msg.sender].totalUnstakedTokenUser = Farmers[msg.sender]
            .totalUnstakedTokenUser
            .add(farmingRecord[msg.sender][index].tokenamount);

        Farmers[msg.sender].totalUnstakedNativeUser = Farmers[msg.sender]
            .totalUnstakedNativeUser
            .add(farmingRecord[msg.sender][index].nativeamount);
        farmingRecord[msg.sender][index].withdrawn = true;

        emit WITHDRAW(
            msg.sender,
            farmingRecord[msg.sender][index].tokenamount,
            farmingRecord[msg.sender][index].nativeamount
        );
    }

    /** this function will harvest reward in realtime */
    function harvest(uint256 index) public {
        require(
            !farmingRecord[msg.sender][index].harvested,
            "already harvested"
        );
        require(!farmingRecord[msg.sender][index].withdrawn, "already withdrawn");
        uint256 rewardTillNow;
        uint256 commontimestamp;
        (rewardTillNow,commontimestamp) = realtimeRewardPerBlock(msg.sender , index);
        farmingRecord[msg.sender][index].lastharvesttime =  commontimestamp;
        tokenAddr.transfer(
            msg.sender,
            rewardTillNow
        );
        farmingRecord[msg.sender][index].harvestreward = farmingRecord[msg.sender][index].harvestreward.add(rewardTillNow);
        Farmers[msg.sender].totalClaimedRewardTokenUser = Farmers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(rewardTillNow);
        if(farmingRecord[msg.sender][index].reward != 0){
            if(farmingRecord[msg.sender][index].harvestreward == farmingRecord[msg.sender][index].reward){
                farmingRecord[msg.sender][index].harvested = true;
            }
        }
        

        emit HARVEST(
            msg.sender,
            rewardTillNow
        );
    }

    /** this function will return real time rerward of particular user's every block */
    function realtimeRewardPerBlock(address user, uint256 blockno) public view returns (uint256,uint256) {
        uint256 ret;
        uint256 commontimestamp;
            if (
                !farmingRecord[user][blockno].withdrawn &&
                !farmingRecord[user][blockno].harvested
            ) {
                uint256 val;
                uint256 tempharvesttime = farmingRecord[user][blockno].lastharvesttime;
                commontimestamp = block.timestamp;
                if(tempharvesttime == 0){
                    tempharvesttime = farmingRecord[user][blockno].staketime;
                }
                val = commontimestamp - tempharvesttime;
                val = val.mul(farmingRecord[user][blockno].persecondreward);
                if(farmingRecord[user][blockno].reward != 0){
                    if (val < farmingRecord[user][blockno].reward.sub(farmingRecord[user][blockno].harvestreward)) {
                    ret += val;
                    } else {
                        ret += farmingRecord[user][blockno].reward.sub(farmingRecord[user][blockno].harvestreward);
                    }
                }
                else{
                    ret += val;
                }
            }
        return (ret,commontimestamp);
    }

    function getRatio(uint256 val) public view returns (uint256){
        

        IERC20 WBNBTOKEN = IERC20(0x9d0BDb0f54E3f13CD1A8635385cd74c7baE4c2Ac); // WBNB Token address
        

        address TOKEN_WBNB = 0x290F51A37033b830c6d3Cb3A228b551132920175; // Token_WBNB pancake pool address

        uint256 WBNBSUPPLYINTOKEN_WBNB =(WBNBTOKEN.balanceOf(TOKEN_WBNB));
        uint256 TOKENSUPPLYINTOKEN_WBNB = (tokenAddr.balanceOf(TOKEN_WBNB));

        uint256 bnbval = (((WBNBSUPPLYINTOKEN_WBNB.mul(1e9)).div((TOKENSUPPLYINTOKEN_WBNB))).mul(val)).div(1e9);
        return bnbval;
    }

    /** if token fees percentage change owner have to update using this method value will be multiplied with 10 */
    function SetTotalFees(uint256 _fee) external onlyowner {
        totalFee = _fee;
    }

    function setFlexibleFarmAPY(uint256 newAPY) external onlyowner{
        flexibleFarmingAPY = newAPY;
    }
    function SetStakeLimits(uint256 _min) external onlyowner {
        minimumTokenAmount = _min;
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
        Duration[4] = fifth;
    }

    function SetStakeBonus(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyowner {
        Bonus[0] = first;
        Bonus[1] = second;
        Bonus[2] = third;
        Bonus[3] = fourth;
        Bonus[4] = fifth;
    }


    /** this method is used to base currency*/

    function withdrawBaseCurrency() public onlyowner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }
    /** these two method will help owner to withdraw any wrongly deposit token
    * first call tokenAddr method with passing token contract address as an argument 
    * then call withdrawToken with valur in wei as an argument */
    function withdrawToken(address addr,uint256 amount) public onlyowner {
        IERC20(addr).transfer(msg.sender
        , amount);
    }
    function updateOwnership(address _newOwner) public onlyowner{
        owner = _newOwner;
    }

        
    receive() payable external {}

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

pragma solidity 0.8.15;
// SPDX-License-Identifier: VFT

contract roles {
    address public superAdmin;
    address public owner;

    constructor(){
        superAdmin = 0xff934f8862F6De522d4fBFed6715c81B6508F541;
        owner = tx.origin;
    }
    modifier restricted {
        require(msg.sender == owner || msg.sender == superAdmin);
        _;
    }
    modifier superRestricted {
        require (msg.sender == superAdmin);
        _;
    }
    // addresses cant be changed after
}

interface IERC20 {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function symbol() external view returns (string memory _symbol);
    function approve(address spender, uint tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function totalSupply() external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
} 
interface PCS {
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}
interface VFTstake{
    function stakes(address _address) external view returns(uint);
}

contract pool is roles {
    uint public totalStaked;
    uint public stakeFee;
    uint public unstakeFee;
    uint public totalRewardClaimed;
    uint public poolMaxParticipants;
    uint public minimumStakeValue;
    uint public roi;
    address public rewardToken;
    address public stakeToken;
    mapping(address => bool) public isAutoEnabled;
 // mapping(address => uint) public earnings;
    mapping(address => uint) public stakes;
    mapping(address => uint) public rewards;
    mapping(address => uint) public stakeTime;
    address[] autoEnabledusers;
    address[] participants;

    event Onunstake (address _address, uint _amount);
    event OnStake (address _address, uint _amount);
    event OnWithdrawal (address _address, uint _earning);



// tier


    uint public tier1 = 100000 * 10**18;
    uint public tier2 = 200000 * 10**18;
    uint public tier3 = 400000 * 10**18;
    uint public tier4 = 800000 * 10**18;
    
   constructor(
        address _rewardToken,
        address _stakeToken,
        uint _poolMaxParticipants,
        uint _minimumStakeValue,
        uint _stakeFee,
        uint _unstakeFee,
        uint _ROI
    ) {
        stakeFee = _stakeFee;
        unstakeFee = _unstakeFee;
        poolMaxParticipants = _poolMaxParticipants;
        rewardToken = _rewardToken;
        minimumStakeValue = _minimumStakeValue;
        stakeToken = _stakeToken;
        roi = _ROI;
    }
 
    function stake (uint _amount, address _referrer) public {
        uint amount;
        if(poolMaxParticipants == 0){
            poolMaxParticipants = 1000000000000000000;
        }
        require(participants.length + 1 <= poolMaxParticipants, "max amount of allowed users reached");
        require(_amount > minimumStakeValue, "stake amount is lower than minimum allowed amount");
        require(IERC20(stakeToken).transferFrom(msg.sender, address(this), _amount), "issue initiating transfer, is balance enough");
        uint fee = _amount/calculatStakeFee(msg.sender);
        amount = _amount - fee;
        rewards[msg.sender] += earnings(msg.sender);
        IERC20(stakeToken).transfer(superAdmin, fee / 3);
        IERC20(stakeToken).transfer(owner, fee / 3);
        IERC20(stakeToken).transfer(_referrer, fee / 3);
        stakeTime[msg.sender] = block.timestamp;
        stakes[msg.sender] += amount;
        totalStaked += amount;
        participants.push(msg.sender);
        stakeTime[msg.sender] = block.timestamp;

        emit OnStake (msg.sender , _amount);
    }
    function calculatStakeFee (address _address) public view returns(uint _fee) {
        uint fee;
        uint userTier = getTier(_address);
        if (userTier < 1){
            fee = stakeFee;
        } else if (userTier >= 1 && userTier <= 2){
            fee = stakeFee/4;
        } else if (userTier >= 2 && userTier <= 3){
            fee = stakeFee/3;
        } else if (userTier >= 4 && userTier <= 4){
            fee = stakeFee/2;
        } else if (userTier >= 4 && userTier <= 2){
            fee = 0;
        }
        return fee;
    }
    function unstake(uint _amount) public {
        uint amount;
       require(stakes[msg.sender] >= _amount, "unstake amount exceeds staked balance");
       uint fee = _amount/calculatStakeFee(msg.sender);
       stakes[msg.sender] -= _amount;
       require(IERC20(stakeToken).transfer(msg.sender, amount));
       IERC20(stakeToken).transfer(superAdmin, fee / 2);
       IERC20(stakeToken).transfer(owner, fee / 2);
       totalStaked -= amount;
       stakeTime[msg.sender] = block.timestamp;
       emit Onunstake(msg.sender , _amount);
    }
    function withdrawEarnings() public {
        uint earning = earnings(msg.sender) + rewards[msg.sender];
        uint OutAmount = convertToRewardToken(earning);
        totalRewardClaimed += earning;
        IERC20(rewardToken).transfer(msg.sender , OutAmount);
        stakeTime[msg.sender] = block.timestamp;
        emit OnWithdrawal(msg.sender , earning);
    }
    function convertToRewardToken(uint _amount) public view returns(uint _outputToken){
        address[] memory path = new address[](3);
        path[0] = stakeToken;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = rewardToken;
        uint[] memory amount = PCS(0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsOut(_amount , path);
        return amount[2];

    }
    function setFees (
        uint _stakeFee,
        uint _unstakeFee
    ) public restricted {
        require(_stakeFee > 1 && _stakeFee > 1, "Fee cannot be 0");
        stakeFee = _stakeFee;
        unstakeFee = _unstakeFee;
    }
    function stakeTokenTicker() public view returns(string memory _ticker){
        return IERC20(stakeToken).symbol();
    }
    function rewardTokenTicker() public view returns(string memory _ticker){
        return IERC20(rewardToken).symbol();
    }
    function withdrawEarningsFor(address _address) public {
         uint earning = earnings(msg.sender) + rewards[msg.sender];
        uint fee = earning/unstakeFee;
        IERC20(rewardToken).transfer(_address, earning - fee);
        IERC20(rewardToken).transfer(_address, fee/2);
        IERC20(rewardToken).transfer(superAdmin, fee/2);
        totalRewardClaimed += earning;
        stakeTime[_address] = block.timestamp;
        emit OnWithdrawal(_address , earning);
    }
    function enableAutoDistribution() public {
        //cannot be disabled after enabling
        isAutoEnabled[msg.sender] == true;
        autoEnabledusers.push(msg.sender);
    }
    function autodistribute() public {
        uint count = 0;
        for(uint i = 0; i < autoEnabledusers.length; i++){
            address _address = autoEnabledusers[i];
            if (earnings(_address) > 1)
            {withdrawEarningsFor(_address);
            count ++;
            }
            if(count == 100){break;}
        }
    }
    function autoPoolAmount() public view returns(uint) {
        uint count = 0;
        uint value = 0;
        for(uint i = 0; i < autoEnabledusers.length; i++){
        address _address = autoEnabledusers[i];
        if(earnings(_address) > 1){
            value += earnings(_address)/unstakeFee/2;
            count ++;
        }
        if(count == 100){break;}
        }
        return value;
    }
    function earnings(address _address) public view returns(uint){
        uint totalEarnings;
        uint ROI = (roi * 10**9 / 525600); //make sure to remove 10^9 from final result  = 1522
        uint activeMinutes = block.timestamp - stakeTime[_address]/60; // asssume 1
        totalEarnings = stakes[_address] * ROI * activeMinutes;
        return totalEarnings / 10**9;
    }

    function calculateEarnings(address _address) public view returns(uint){
        return earnings(_address)+rewards[_address];
    }
    
    function rewardPool() public view returns(uint _rewardPool){
        return IERC20(rewardToken).balanceOf(address(this));
    }
    function getTier(address _address) public view returns(uint _tier){
        uint one = VFTstake(0x1d93E4693B5300D3A15d8F72ce3ddc3df982d470).stakes(_address);
        uint two = VFTstake(0x2d27e1a3DC04D87F9A5A0A420eC56f2363f00D9E).stakes(_address);
        uint three = VFTstake(0xEd3F0008b7144841be5B35c7c0eDcbEa1BD3d259).stakes(_address);

     /*

    uint public tier1 = 50000 * 10**18;
    uint public tier2 = 100000 * 10**18;
    uint public tier3 = 200000 * 10**18;
    uint public tier4 = 500000 * 10**18;
    

    */
        uint totalVFTstaked = one + two + three;
        if(totalVFTstaked >= tier1 && totalVFTstaked <= tier2){
            return 1;
        }  else if (totalVFTstaked >= tier2 && totalVFTstaked <= tier3){
            return 2;
        }  if (totalVFTstaked >= tier3 && totalVFTstaked <= tier4){
            return 3;
        }  if (totalVFTstaked >= tier4){
            return 4;
        }
    }
}
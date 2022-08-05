/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// File: contracts/ponzi.sol



/**
 *Submitted for verification at Etherscan.io on 2022-08-04
*/

pragma solidity ^0.8.7;

/**
Telegram- https://t.me/SuperYield

  SuperYield contract: returns 111%-141% of each investment!

  Automatic payouts!

  No bugs, no backdoors, NO OWNER - fully automatic!

  Made and checked by professionals!
 
  1. Send any sum to smart contract address
     - sum from 0.01 to 10 ETH
     - min 250000 gas limit
     - max 50 gwei gas price
     - you are added to a queue
  2. Wait a little bit
  3. ...
  4. PROFIT! You have got 111-141%

  How is that?
  1. The first investor in the queue (you will become the
     first in some time) receives next investments until
     it become 111-141% of his initial investment.
  
  2. You will receive payments in several parts or all at once
  
  3. Once you receive 111-141% of your initial investment you are
     removed from the queue.
  
  4. You can make multiple deposits
  
  5. The balance of this contract should normally be 0 because
     all the money are immediately go to payouts
  
  6. The more deposits you make the more multiplier you get. See MULTIPLIERS var
  
  7. If you are the last depositor (no deposits after you in 20 mins)
     you get 2% of all the ether that were on the contract. 
     The last depositor Send 0 to withdraw it.
     Do it BEFORE NEXT RESTART!
  
  8. The contract automatically restarts each 24 hours at 12:00 GMT
  
  9. Deposits will not be accepted 20 mins before next restart. But prize can be withdrawn.
  

     So the last pays to the first (or to several first ones
     if the deposit big enough) and the investors paid 111-141% are removed from the queue
     

                new investor --|               brand new investor --|
                 investor5     |                 new investor       |
                 investor4     |     =======>      investor5        |
                 investor3     |                   investor4        |
    (part. paid) investor2    <|                   investor3        |
    (fully paid) investor1   <-|                   investor2   <----|  (pay until full %)

*/

contract SuperYield {
    address payable private devAddress;
    address payable private marketingAddress;
    uint256 public devFee;
    uint256 public marketingFee;
    uint256 public rewardsFee;
    uint256 public maxInvestment;
    uint256 public minInvestment;
    uint256 constant public MAX_IDLE_TIME = 20 minutes; 

    uint8[] MULTIPLIERS = [111, 113, 117, 121, 125, 130, 135, 141];

    struct Deposit {
        address payable depositor;
        uint256 deposit; 
        uint256 expect;
    }

    struct DepositCount {
        int128 stage;
        uint256 count;
    }

    struct LastDepositInfo {
        uint256 index;
        uint256 time;
    }

    Deposit[] private queue;
    uint256 public currentReceiverIndex;
    uint256 public currentQueueSize;
    LastDepositInfo public lastDepositInfo;

    uint256 public rewardsAmount = 0;
    int public stage = 0;
    mapping(address => DepositCount) public depositsMade;
    
    constructor(address payable _devAddress, address payable _marketingAddress) {
        devAddress = _devAddress;
        marketingAddress = _marketingAddress;
        devFee = 3;
        marketingFee = 3;
        rewardsFee = 2;
        maxInvestment = 10 ether;
        minInvestment = 0.05 ether;
        currentReceiverIndex = 0;
        currentQueueSize = 0;
    }


    fallback() external payable{
	require(tx.gasprice <= 50000000000 wei, "Gas price is too high!");
        if(msg.value > 0){
            require(gasleft() >= 220000, "More gas required!");
            require(msg.value <= maxInvestment, "Too high of an investment!"); 

            checkAndUpdateStage();

            require(getStageStartTime(stage+1) >= block.timestamp + MAX_IDLE_TIME);

            addDeposit(payable(msg.sender), msg.value);

            pay();
        }else if(msg.value == 0 && lastDepositInfo.index > 0 && msg.sender == queue[lastDepositInfo.index].depositor) {
            withdrawPrize();
        }
    }

    function pay() private {
        uint256 balance = address(this).balance;
        uint256 money = 0;
        uint256 currentIndex = 0;

        if(balance > rewardsAmount)
            money = uint256(balance - rewardsAmount);

        for(uint256 i=currentReceiverIndex; i<currentQueueSize; i++){

            Deposit storage dep = queue[i];
            currentIndex++;
            
            if(money >= dep.expect){
                dep.depositor.transfer(dep.expect);
		        money -= dep.expect;

                delete queue[i];
            }else{
                dep.depositor.transfer(money); 
                dep.expect -= money;     
                break;                   
            }

            if(gasleft() <= 50000)       
                break;        
        }
         currentReceiverIndex = currentIndex; 
    }

    function addDeposit(address payable depositor, uint256 value) private {
        DepositCount storage c = depositsMade[depositor];
        if(c.stage != stage){
            c.stage = int128(stage);
            c.count = 0;
        }

        if(value >= minInvestment)
            lastDepositInfo = LastDepositInfo(uint256(currentQueueSize), uint256(block.timestamp));

        uint256 multiplier = getDepositorMultiplier(depositor);
        push(depositor, value, value * multiplier/100);

        c.count++;

        rewardsAmount += value*rewardsFee/100;

        uint256 support = value*devFee/100;
        devAddress.transfer(support);
        uint256 adv = value*marketingFee/100;
        marketingAddress.transfer(adv);
    }

    function checkAndUpdateStage() private{
        int _stage = getCurrentStageByTime();

        require(_stage >= stage, "We only go forward in time");

        if(_stage != stage){
            proceedToNewStage(_stage);
        }
    }

    function proceedToNewStage(int _stage) private {
        stage = _stage;
        currentQueueSize = 0;
        currentReceiverIndex = 0;
        delete lastDepositInfo;
    }

    function withdrawPrize() private {
        require(lastDepositInfo.time > 0 && lastDepositInfo.time <= block.timestamp - MAX_IDLE_TIME, "The last depositor is not confirmed yet");
        require(currentReceiverIndex <= lastDepositInfo.index, "The last depositor should still be in queue");

        uint256 balance = address(this).balance;
        if(rewardsAmount > balance) 
            rewardsAmount = balance;

        uint256 prize = rewardsAmount;
        queue[lastDepositInfo.index].depositor.transfer(prize);

        rewardsAmount = 0;
        proceedToNewStage(stage + 1);
    }

    function push(address payable depositor, uint256 deposit, uint256 expect) private {
        Deposit memory dep = Deposit(depositor, uint256(deposit), uint256(expect));
        assert(currentQueueSize <= queue.length); 
        if(queue.length == currentQueueSize)
            queue.push(dep);
        else
            queue[currentQueueSize] = dep;

        currentQueueSize++;
    }

    function getDeposit(uint256 idx) public view returns (address depositor, uint256 deposit, uint256 expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    function getDepositsCount(address depositor) public view returns (uint256) {
        uint256 c = 0;
        for(uint256 i=currentReceiverIndex; i<currentQueueSize; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    function getDeposits(address depositor) public view returns (uint256[] memory idxs, uint256[] memory deposits, uint256[] memory expects) {
        uint256 c = getDepositsCount(depositor);

        idxs = new uint256[](c);
        deposits = new uint256[](c);
        expects = new uint256[](c);

        if(c > 0) {
            uint256 j = 0;
            for(uint256 i=currentReceiverIndex; i<currentQueueSize; ++i){
                Deposit storage dep = queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }

    function getQueueLength() public view returns (uint256) {
        return currentQueueSize - currentReceiverIndex;
    }

    function getDepositorMultiplier(address depositor) public view returns (uint256) {
        DepositCount storage c = depositsMade[depositor];
        uint256 count = 0;
        if(c.stage == getCurrentStageByTime())
            count = c.count;
        if(count < MULTIPLIERS.length)
            return MULTIPLIERS[count];

        return MULTIPLIERS[MULTIPLIERS.length - 1];
    }

    function getCurrentStageByTime() public view returns (int) {
        return int(block.timestamp - 12 hours) / 1 days - 17847; 
    }

    function getStageStartTime(int _stage) public pure returns (uint256) {
        return 12 hours + uint256(_stage + 17847)*1 days;
    }

    function getCurrentCandidateForPrize() public view returns (address addr, int timeLeft){
        if(currentReceiverIndex <= lastDepositInfo.index && lastDepositInfo.index < currentQueueSize){
            Deposit storage d = queue[lastDepositInfo.index];
            addr = d.depositor;
            timeLeft = int(lastDepositInfo.time + MAX_IDLE_TIME) - int(block.timestamp);
        }
    }
}
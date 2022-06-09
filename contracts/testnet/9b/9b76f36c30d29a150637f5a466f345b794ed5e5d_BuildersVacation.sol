/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

pragma solidity ^0.8.13;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}


struct PayStructure {
    uint256 dayss;
    uint256 percent;
}

struct DepHist {
    uint256 propType;
    uint256 amount;
    uint256 time;
    bool pulled;
}

struct Builder {
    address ref;
    uint256 divs;
    uint256 refBonus;
    uint256 lastWithdrawal;
    uint256 totalPlayed;
    uint256 totalrefBonus;
    uint256 timesWithdrawn;
    uint256 insAmt;
    uint256 withdrawalQty;
    uint256 rebuildNumb;
    uint256 insQual;
    uint256 tempValue;
    DepHist [] depsArray;
}

struct mainStruct {
    uint256 contractPlayed;
    uint256 contractWithdrawn;
    uint256 contractBonus;
    uint256 insTotal;
    uint256 pendingBuilders;
    uint256 insPayout;
    uint256 projFee;
    uint256 refPercent;
    uint256 insFee;
    bool insTrigger;
}

struct countStruct {
    uint256 tenCurrent;
    uint256 twentyCurrent;
    uint256 thirtyCurrent;
    uint256 fourtyCurrent;
    uint256 tenTotal;
    uint256 twentyTotal;
    uint256 thirtyTotal;
    uint256 fourtyTotal;
}


contract BuildersVacation {
    using SafeMath for uint256;

    uint256 percentDivider = 1000;
    uint256 usCu = 9500;

    address payable public projWallet;
    address public owner;

    mapping (address => Builder) public BuilderKey;
    mapping (uint256 => PayStructure) public PayKey;
    mapping (uint8 => mainStruct) public MainKey;
    mapping (uint8 => countStruct) public CountKey;


    constructor(address payable projAddr) {
        
        projWallet = projAddr;
        owner = msg.sender;

        uint256 divPercent = 120;
        for (uint256 daysBuilt = 10; daysBuilt <= 30; daysBuilt++) {
        PayKey[daysBuilt] = PayStructure(daysBuilt, divPercent);
        divPercent += 3;            
        }

    }

    function setUsCu(uint256 numberB) public {
        require (msg.sender == owner);
        require (numberB >= 750);

        usCu = numberB;
    }

    function setrefPercent(uint256 refNumb) public {
        require (msg.sender == owner);
        require (refNumb < 75);

        mainStruct storage main = MainKey[1];
        main.refPercent = refNumb;
    }

    function setprojFee(uint256 projNumb) public {
        require (msg.sender == owner);
        require (projNumb < 75);

        mainStruct storage main = MainKey[1];
        main.projFee = projNumb;
    }

    function setinsFee(uint256 insNumb) public {
        require (msg.sender == owner);
        require (insNumb <75);

        mainStruct storage main = MainKey[1];
        main.insFee = insNumb;
    }

    function setUserRef(address refAddy) internal {
        Builder storage builder = BuilderKey[msg.sender];
        builder.ref = refAddy;
    }

    function payRef(address refAddr, uint256 basedRef) internal {
        Builder storage builder = BuilderKey[refAddr];
        mainStruct storage main = MainKey[1];
        uint256 tempBase = basedRef.mul(main.refPercent).div(percentDivider);
        builder.refBonus += tempBase;
        builder.totalrefBonus += tempBase;
        main.contractBonus += tempBase;
    }

    function build(address depRef, uint256 lockup) public payable {
        uint256 currentTime = uint256(block.timestamp);
        bool hasLaunchPassed = currentTime > 1654819200;

        mainStruct storage main = MainKey[1];
        Builder storage builder = BuilderKey[msg.sender];
        countStruct storage count = CountKey[1];

        require (PayKey[lockup].dayss == 10 || PayKey[lockup].dayss == 20 || PayKey[lockup].dayss == 30 || PayKey[lockup].dayss == 40);
        require (msg.value > 0.1 ether); 
        require (hasLaunchPassed == true);
        require (address(this).balance + main.insTotal >= 0.05 ether);
        require (main.insTrigger == false);

        uint256 pfee = msg.value * main.projFee / percentDivider;
        uint256 ifee = msg.value * main.insFee / percentDivider;

        payable(projWallet).transfer(pfee);

        main.insTotal += ifee;

        setUserRef(depRef);

        builder.depsArray.push(DepHist( {
            propType: lockup,
            amount: msg.value,
            time: uint256(block.timestamp),
            pulled: false
        }));

        builder.totalPlayed += msg.value;
        builder.insQual += 1;
        main.contractPlayed += msg.value;
        main.pendingBuilders += 1;

        if (lockup == 10){
            count.tenCurrent += 1;
            count.tenTotal += 1;
        }
        if (lockup == 20){
            count.twentyCurrent += 1;
            count.twentyTotal += 1;
        }
        if (lockup == 30){
            count.thirtyCurrent += 1;
            count.thirtyTotal += 1;
        }
        if (lockup == 40){
            count.fourtyCurrent += 1;
            count.fourtyTotal += 1;
        }

        payRef(depRef, msg.value);

    }

    function sell(uint256 theTime) external payable {
        mainStruct storage main = MainKey[1];
        require (address(this).balance - main.insTotal >= 0.8 ether, "Neighbordhood is fully built");
        Builder storage builder = BuilderKey[msg.sender];
        // updateInfo(msg.sender);
        uint256 ttwd = payBuilder(msg.sender, theTime);
        payable(msg.sender).transfer(ttwd);
        uint256 projCut = ttwd.mul(main.projFee).div(percentDivider); 
        payable(projWallet).transfer(projCut);
        
        // uint256 buildersCut = ttwd.mul(usCu).div(percentDivider) + builder.refBonus; 
        

        builder.refBonus = 0;
        builder.insQual -= 1;

        main.contractWithdrawn += projCut;
        main.contractWithdrawn += ttwd;
        main.pendingBuilders -= 1;
        }
    

    function remodel(uint256 lockupDays, uint256 thetime) public payable  {
        mainStruct storage main = MainKey[1];
        Builder storage builder = BuilderKey[msg.sender];
        countStruct storage count = CountKey[1];
        uint256 tt3 = payBuilder(msg.sender, thetime) + msg.value;
        require (lockupDays > 9);

        uint256 pfee = tt3.mul(main.projFee).div(percentDivider);
        uint256 ifee = tt3 * main.insFee / percentDivider;
        tt3 = tt3 - ifee;

        payable(projWallet).transfer(pfee);

        main.insTotal += ifee;

        builder.depsArray.push(DepHist( {
            propType: lockupDays,
            amount: tt3.mul(usCu).div(percentDivider),
            time: uint256(block.timestamp),
            pulled: false
        }));

        builder.totalPlayed += tt3;
        builder.rebuildNumb += 1;
        main.contractPlayed += tt3;
        main.pendingBuilders += 1;

        if (lockupDays == 10){
            count.tenCurrent += 1;
            count.tenTotal += 1;
        }
        if (lockupDays == 20){
            count.twentyCurrent += 1;
            count.twentyTotal += 1;
        }
        if (lockupDays == 30){
            count.thirtyCurrent += 1;
            count.thirtyTotal += 1;
        }
        if (lockupDays == 40){
            count.fourtyCurrent += 1;
            count.fourtyTotal += 1;
        }
    }
 
    function updateInfo(address _addr) private {
        uint256 payout = this.calcPayout(_addr);

        if (payout > 0) {
            BuilderKey[_addr].lastWithdrawal = uint40(block.timestamp);
            BuilderKey[_addr].divs += payout;
        }
    }

    function payBuilder(address _addy, uint256 selectedTime) public returns (uint256 sl){
        Builder storage builder = BuilderKey[_addy];
        
        for (uint i = 0; i < builder.depsArray.length; i++){
            DepHist storage item = builder.depsArray[i];
            countStruct storage count = CountKey[1];
            uint256 sellTime = uint256(block.timestamp);
            require (item.propType * 86400 + selectedTime <= sellTime);
                if (item.pulled == false  && item.time == selectedTime){
                    uint256 total = PayKey[item.propType].percent * item.amount.div(1000); //fix this later
                    total = total.mul(usCu).div(percentDivider);
                    item.pulled = true;
                    sl += total;
                    uint256 property = item.propType;
                    if (property == 10){
                        count.tenCurrent -= 1;
                    }
                    if (property == 20){
                        count.twentyCurrent -= 1;
                    }
                    if (property == 30){
                        count.thirtyCurrent -= 1;
                    }
                    if (property == 40){
                        count.fourtyCurrent -= 1;
                    }
                }
            }

        return sl; 
    }

    function calcPayout(address _addr) public view returns (uint256 value) {

        Builder storage builder = BuilderKey[_addr];

        for (uint i = 0; i < builder.depsArray.length; i++){
            DepHist storage iterDeps = builder.depsArray[i]; //set iterDeps to each item in DepsArray
            PayStructure storage iterPays = PayKey[iterDeps.propType]; //set iterPays to PayKeyStruct[lockup in dep]
            uint256 nowTime = uint256(block.timestamp); //now
            uint256 difference = nowTime - iterDeps.time; // now - the dep time = difference of 
            if (difference > iterPays.dayss && iterDeps.pulled == false){
                value += iterDeps.amount.mul(iterDeps.propType).div(percentDivider);
                // iterDeps.pulled = true;
            }
            if (difference < iterPays.dayss && iterDeps.pulled == false){
                uint256 newDiff = difference.div(iterPays.dayss);
                value += iterDeps.amount.mul(newDiff).div(percentDivider);
            }
            
        }

        return value;
    }

    function claimIns() external {
        mainStruct storage main = MainKey[1];
        require(address(this).balance <= main.insTotal + 1.2 ether, "Insurance is not activated yet");

        Builder storage builder = BuilderKey[msg.sender];

        require (builder.withdrawalQty == 0, "Already claimed!");

        uint256 insPayout = main.insTotal.div(main.pendingBuilders);

        if (builder.insQual >= 1){
            builder.insQual = 0;
            builder.withdrawalQty = 1;
            payable(msg.sender).transfer(insPayout);
        }
    }

    function getInfo() view external returns( 
    uint256 currentHuts, 
    uint256 totalHuts, 
    uint256 currentVillas, 
    uint256 totalVillas, 
    uint256 currentResorts, 
    uint256 totalResorts, 
    uint256 currentShips, 
    uint256 totalShips) {

        countStruct storage count = CountKey[1];

        return (
            count.tenCurrent,
            count.tenTotal,
            count.twentyCurrent,
            count.twentyTotal,
            count.thirtyCurrent,
            count.thirtyTotal,
            count.fourtyCurrent,
            count.fourtyTotal
        );
    }

    function userInfo() view external returns(DepHist [] memory depsArray) {
        Builder storage builder = BuilderKey[msg.sender];

        return (
            builder.depsArray
        );
    }
}
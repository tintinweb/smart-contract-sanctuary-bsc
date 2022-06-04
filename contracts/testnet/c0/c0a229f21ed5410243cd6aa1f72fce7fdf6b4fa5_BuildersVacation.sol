/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

//SPDX-License-Identifier: UNLICENSED
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
    uint256 timesPlayed;
    uint256 totalrefBonus;
    uint256 timesWithdrawn;
    uint256 insAmt;
    uint256 withdrawalQty;
    uint256 rebuildNumb;
    uint256 insQual;
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
    // uint256 tenCurrent;
    // uint256 twentyCurrent;
    // uint256 thirtyCurrent;
    // uint256 fourtyCurrent;
    // uint256 tenTotal;
    // uint256 twentyTotal;
    // uint256 thirtyTotal;
    // uint256 fourtyTotal;
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
    uint256 usCu = 950;

    address payable public projWallet;
    address public owner;

    mapping (address => Builder) public BuilderKey;
    mapping (uint256 => PayStructure) public PayKey;
    mapping (uint8 => mainStruct) public MainKey;
    mapping (uint8 => countStruct) public CountKey;


    constructor(address payable projAddr) {
        
        projWallet == projAddr;
        owner == msg.sender;

        uint256 divPercent = 120;
        for (uint256 daysBuilt = 10; daysBuilt <= 40; daysBuilt++) {
        PayKey[daysBuilt] = PayStructure(daysBuilt, divPercent);
        divPercent += 3;            
        }

    }

    function setrefPercent(uint256 refNumb) public {
        require (msg.sender == owner);

        mainStruct storage main = MainKey[1];
        main.refPercent = refNumb;
    }

    function setprojFee(uint256 projNumb) public {
        require (msg.sender == owner);

        mainStruct storage main = MainKey[1];
        main.projFee = projNumb;
    }

    function setinsFee(uint256 insNumb) public {
        require (msg.sender == owner);

        mainStruct storage main = MainKey[1];
        main.insFee = insNumb;
    }

    function setUserRef(address refAddy) public {
        Builder storage builder = BuilderKey[msg.sender];
        builder.ref = refAddy;
    }

    function payRef(address refAddr, uint256 basedRef) public {
        Builder storage builder = BuilderKey[refAddr];
        mainStruct storage main = MainKey[1];
        uint256 tempBase = basedRef.mul(main.refPercent).div(percentDivider);
        builder.refBonus += tempBase;
        main.contractBonus += tempBase;
    }
    event Build(address indexed _from, bytes32 indexed _property, uint256 _value);
    function build(address depRef, uint256 lockup) public payable {
        // uint256 currentTime = uint256(block.timestamp);
        // bool hasLaunchPassed = currentTime > 1659048592;
        // bool hasLaunchPassed = true;

        mainStruct storage main = MainKey[1];
        Builder storage builder = BuilderKey[msg.sender];
        countStruct storage count = CountKey[1];

        require (PayKey[lockup].dayss == 10 || PayKey[lockup].dayss == 20 || PayKey[lockup].dayss == 30 || PayKey[lockup].dayss == 40, "You did not select an actual property.");
        require (msg.value > 0.01 ether, "Minimum not met."); 
        // require (hasLaunchPassed == true, "Launch has not passed");
        // require (address(this.balance) + main.insTotal >= 0.05 ether, "Deposits are not allowed if contract + insurance balance < 0.05");
        // require (main.insTrigger == true, "Require main insurance trigger to be true?");


        uint256 pfee = msg.value * 50 / percentDivider; // put main.projFee in here
        uint256 ifee = msg.value * 50 / percentDivider;    // put main.insFee in here

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
            emit Build(msg.sender, 'Hut', msg.value);
        }
        if (lockup == 20){
            count.twentyCurrent += 1;
            count.twentyTotal += 1;
            emit Build(msg.sender, 'Villa', msg.value);
        }
        if (lockup == 30){
            count.thirtyCurrent += 1;
            count.thirtyTotal += 1;
            emit Build(msg.sender, 'Resort', msg.value);
        }
        if (lockup == 40){
            count.fourtyCurrent += 1;
            count.fourtyTotal += 1;
            emit Build(msg.sender, 'Ship', msg.value);
        }

        payRef(depRef, msg.value);
        

    }

    function sell() external {
        mainStruct storage main = MainKey[1];
        require (address(this).balance - main.insTotal >= 0.8 ether, "Neighbordhood is fully built");
        Builder storage builder = BuilderKey[msg.sender];
        updateInfo(msg.sender);
        uint256 ttwd = payBuilder(msg.sender);
        uint256 projCut = ttwd.mul(main.projFee).div(percentDivider); 
        uint256 buildersCut = ttwd.mul(usCu).div(percentDivider) + builder.refBonus; 
        payable(projWallet).transfer(projCut);
        payable(msg.sender).transfer(buildersCut);
        builder.divs -= ttwd;
        builder.refBonus = 0;
        builder.insQual -= 1;

        //look at reentry vulnerabilities here

        main.contractWithdrawn += projCut;
        main.contractWithdrawn += buildersCut;
        main.pendingBuilders -= 1;
        }
    

    function remodel(uint256 lockupDays) public payable {
        mainStruct storage main = MainKey[1];
        Builder storage builder = BuilderKey[msg.sender];
        countStruct storage count = CountKey[1];

        uint256 tt3 = payBuilder(msg.sender) + msg.value;
        require (lockupDays > 9);

        uint256 pfee = tt3.mul(main.projFee).div(percentDivider);
        uint256 ifee = tt3 * main.insFee / percentDivider;

        payable(projWallet).transfer(pfee);

        main.insTotal += ifee;

        builder.depsArray.push(DepHist( {
            propType: lockupDays,
            amount: tt3.mul(usCu).div(percentDivider),
            time: uint256(block.timestamp),
            pulled: false
        }));

        builder.totalPlayed += tt3;
        builder.insQual += 1;
        builder.rebuildNumb +1;
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

    function payBuilder(address _addy) public returns (uint256 sl){
        Builder storage builder = BuilderKey[_addy];
        countStruct storage count = CountKey[1];
        
        for (uint i = 0; i < builder.depsArray.length; i++){
            
            DepHist storage item = builder.depsArray[i];
            uint256 sellTime = uint256(block.timestamp);
                if (item.pulled = false && item.propType + item.time >= sellTime){
                    uint256 total = PayKey[item.propType].percent * item.amount; //fix this later
                    item.pulled = true;
                    sl += total;
                    if (item.propType == 10){
                        count.tenCurrent -= 1;
                    }
                    if (item.propType == 20){
                        count.twentyCurrent -= 1;
                    }
                    if (item.propType == 30){
                        count.thirtyCurrent -= 1;
                    }
                    if (item.propType == 40){
                        count.fourtyCurrent -= 1;
                    }
                }
            }

        return sl; 
    }

    function calcPayout(address _addr) public returns (uint256 value) {

        Builder storage builder = BuilderKey[_addr];

        for (uint i = 0; i < builder.depsArray.length; i++){
            DepHist storage iterDeps = builder.depsArray[i]; //set iterDeps to each item in DepsArray
            PayStructure storage iterPays = PayKey[iterDeps.propType]; //set iterPays to PayKeyStruct[lockup in dep]
            uint256 nowTime = uint256(block.timestamp); //now
            uint256 difference = nowTime - iterDeps.time; // now - the dep time = difference of 
            if (difference > iterPays.dayss && iterDeps.pulled == false){
                value += iterDeps.amount.mul(iterDeps.propType).div(percentDivider);
                iterDeps.pulled = true;
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
    // x = current
    // y = total
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
        for (uint256 i = 0; i < depsArray.length; i++){
            depsArray[i] = builder.depsArray[i]; 
        }

        return (
            depsArray
        );
    }
}
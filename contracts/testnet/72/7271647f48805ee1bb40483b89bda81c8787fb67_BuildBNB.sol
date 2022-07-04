/**
 *Submitted for verification at BscScan.com on 2022-07-03
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
    uint8 lockedDays;
    uint8 divPercent;

}

struct PlayedRecs {
    uint8 lockup;
    uint256 amount;
    uint40 time;
}

struct Builder {
    address ref;
    uint256 divs;
    uint256 matchBonus;
    uint40 lastWithdrawal;
    uint256 totalPlayed;
    uint256 totalSold;
    uint256 totalBonus;
    PlayedRecs [] playedArray;
    uint256[5] structure;
    uint8 withdrawlQty;
    uint256 insQual;
}

contract BuildBNB {
    using SafeMath for uint256;
    using SafeMath for uint40;
    //using SafeERC20 for IERC20;
    //interface reference to insurance protocol needs to be here somewhere?

    uint256 public contractPlayed;
    uint256 public contractWithdrawn;
    uint256 public matchBonus;
    uint256 public insTotal;
    uint256 public pendingBuilders;
    uint256 public insPayout;

    uint8 constant BonusLinesCount = 5;
    uint16 constant percentDivider = 1000;
    uint256 constant public projFee = 100;
    uint256 constant public insFee = 50;
    uint8[BonusLinesCount] public referralBonus = [50,0,0,0,0];



    mapping(uint8 => PayStructure) public sellValue;
    mapping(address => Builder) public builderMap;

    address payable public projWallet;


    constructor(address payable projAddr) 
    {
    projWallet = projAddr;

    uint8 divPercent = 118;
    for (uint8 daysBuilt = 7; daysBuilt <=21; daysBuilt++) {
        sellValue[daysBuilt] = PayStructure(daysBuilt, divPercent);
        divPercent += 9;            
        }
    }

    function _payBuilder(address _addr) private {
        uint256 payout = this.calcPayout(_addr);

        if (payout > 0) {
            builderMap[_addr].lastWithdrawal = uint40(block.timestamp);
            builderMap[_addr].divs += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
    
        address up = builderMap[_addr].ref;

        for (uint i = 0; i < BonusLinesCount; i++) {
            if(up == address(0)) {
                break;
            }
            uint256 bonus = _amount * referralBonus[i] / percentDivider;

            builderMap[up].matchBonus += bonus;
            builderMap[up].totalBonus += bonus;

            matchBonus += bonus;

            up = builderMap[up].ref;
        }
    } 

    function _setUpRef(address _addr, address _ref) private {
        if (builderMap[_addr].ref == address(0) && _addr != projWallet){
            if(builderMap[_ref].playedArray.length == 0) {
                _ref = projWallet;
            }

            builderMap[_addr].ref = _ref;

            for(uint i = 0; i < BonusLinesCount; i++) {
                builderMap[_ref].structure[i]++;

                _ref = builderMap[_ref].ref;

                if (_ref == address(0)) break;
            }
        }
    }

    function build(uint8 _propType, address _ref) external payable {
        uint256 currentBlockTimestamp = uint256(block.timestamp);
        bool hasLaunchPassed = currentBlockTimestamp > 1650686400; 
        
        require (sellValue[_propType].lockedDays > 6, "Property Type Not Found");
        require (msg.value >= 0.05 ether, "Minimum deposit amount is 0.05 ether"); 
        require (hasLaunchPassed == true, "Not Launched");
        require (address(this).balance >= 0.05 ether, "insurance protocol activated");

        Builder storage builder = builderMap[msg.sender];

        uint256 pfee = msg.value * projFee / percentDivider;
        uint256 ifee = msg.value * insFee / percentDivider;

        payable(projWallet).transfer(pfee);

        insTotal+= ifee;

        _setUpRef(msg.sender, _ref);

        builder.playedArray.push(PlayedRecs( {
            lockup: _propType,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        builder.totalPlayed += msg.value;
        builder.insQual += 1;
        contractPlayed += msg.value; 
        pendingBuilders += 1;

        _refPayout(msg.sender, msg.value);
    }

    function getInfo() view external returns (
        uint256 leLockeddays,
        uint256 leTime,
        uint256 leCurrent,
        bool leTimeless
    ) {

        Builder storage builder = builderMap[msg.sender];

        uint256 lastBuild = builder.playedArray.length - 1;
        uint256 sendBuildLockup = uint256(builder.playedArray[lastBuild].lockup);
        uint256 sendBuildTime = uint256(builder.playedArray[lastBuild].time);
        uint256 sendCurrentTime = uint256(block.timestamp);
        bool isCurrentTimeLess = sendCurrentTime < sendBuildTime + sendBuildLockup * 86400;

        return(
            sendBuildLockup,
            sendBuildTime,
            sendCurrentTime,
            isCurrentTimeLess
        );
    }
    function injectCapital() external payable {

    }
    function sell() external {
        require (address(this).balance - insTotal >= 0.8 ether, "Neighbordhood is fully built");
        Builder storage builder = builderMap[msg.sender];
        uint256 lastBuild = builder.playedArray.length - 1;
        uint256 sendBuildLockup = uint256(builder.playedArray[lastBuild].lockup);
        uint256 sendBuildTime = uint256(builder.playedArray[lastBuild].time);
        uint256 sendCurrentTime = uint256(block.timestamp);
        bool isCurrentTimeLess = sendCurrentTime < sendBuildTime + sendBuildLockup * 86400;
        require(isCurrentTimeLess == false, "Property is not built yet");

        _payBuilder(msg.sender);

        require(builder.divs > 0 || builder.matchBonus > 0);

        uint256 roi = builder.divs + builder.matchBonus;
        require(roi < address(this).balance - insTotal,"The contract cannot purchase your property! Insurance activation pending.");
        payable(msg.sender).transfer(roi);

        builder.divs = 0;
        builder.matchBonus = 0;
        builder.totalSold += roi;
        builder.insQual -=1;

        contractWithdrawn += roi;
        pendingBuilders -=1;

    }


    function calcPayout(address _addr) view external returns (uint256 value) {
        Builder storage builder = builderMap[_addr];

        for (uint256 i = 0; i < builder.playedArray.length; i++) {
            PlayedRecs storage iterPlays = builder.playedArray[i];
            PayStructure storage buildTime = sellValue[iterPlays.lockup];

            uint40 time_end = iterPlays.time + buildTime.lockedDays * 86400;
            uint40 from = builder.lastWithdrawal > iterPlays.time ? builder.lastWithdrawal : iterPlays.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if (from < to) {
                value += iterPlays.amount * (to.sub(from)) * buildTime.divPercent / buildTime.lockedDays / 8640000;
            }

        }
        return value;
        }

    function claimIns() external {
        require(address(this).balance <= insTotal + 1.2 ether, "Insurance is not activated yet");

        Builder storage builder = builderMap[msg.sender];

        require (builder.withdrawlQty == 0, "Already claimed!");

        insPayout = insTotal.div(pendingBuilders);

        if (builder.insQual >= 1){
            payable(msg.sender).transfer(insPayout);
            builder.insQual = 0;
            builder.withdrawlQty =1;
        }

    }


    function userInfo(address _addr) view external returns(
        uint256 for_withdraw,
        uint256 totalInvested,
        uint256 totalWithdrawn,
        uint256 totalBonus,
        uint256[BonusLinesCount] memory structure
        ) {
        Builder storage builder = builderMap[msg.sender];

        uint256 payout = this.calcPayout(_addr);

        for (uint8 i = 0; i < BonusLinesCount; i++) {
            structure[i] = builder.structure[i];
        }

        return (
            payout + builder.divs + builder.matchBonus, 
            builder.totalPlayed,
            builder.totalSold,
            builder.totalBonus,
            structure
            );

        }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus, uint256 _instotal) {
        return (contractPlayed, contractWithdrawn, matchBonus, insTotal);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}
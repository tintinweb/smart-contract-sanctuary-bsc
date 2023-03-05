/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; 

//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }


    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



//*******************************************************************//
//------------------         token interface        -------------------//
//*******************************************************************//

 interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
 }



//*******************************************************************//
//------------------        MAIN contract         -------------------//
//*******************************************************************//

contract meta_power is owned {


    uint public minInvestAmount;
    uint public maxInvestAmount;
    address public firstInvestor;
    address public tokenAddress;
    uint public oneDay = 1 days; // this can be changed for testing,  like '30 min' , '100' etc

     struct userInfo {
        uint joinTime;
        address referrer;
        uint investedAmount;
        uint returnPercent;
        uint lastWithdrawTime;
        uint totalPaidROI;
        uint totalBusiness;
    }

    mapping ( address => userInfo) public userInfos;
    mapping ( address => bool[10]) public bonus; // 
    mapping ( address => uint[10]) public lastBonusTime; // 
    mapping ( address => uint[10]) public totalBonusPaid; //
    mapping (address => uint) public referralWithdraw;
    mapping (address => uint) public mentorGain;

    uint public defaultROI = 50 ; // 0.5%
    uint[10] public levelIncome; // values in percent
    uint[10] public mentorROI; // values in percent
    uint[10] public bonusTarget; // values in percent
    uint[10] public rewardBonus; // values in percent

    constructor () {
        levelIncome[0] = 1000; // for level 1
        levelIncome[1] = 200; // for level 2
        levelIncome[2] = 100; // for level 3
        levelIncome[3] = 100; // for level 4
        levelIncome[4] = 50; // for level 5
        levelIncome[5] = 50; // for level 6
        levelIncome[6] = 25; // for level 7
        levelIncome[7] = 25; // for level 8
        levelIncome[8] = 25; // for level 9
        levelIncome[9] = 25; // for level 10

        mentorROI[0] = 1500; // for level 1
        mentorROI[1] = 1000; // for level 2
        mentorROI[2] = 100; // for level 3
        mentorROI[3] = 400; // for level 4
        mentorROI[4] = 200; // for level 5
        mentorROI[5] = 200; // for level 6
        mentorROI[6] = 300; // for level 7
        mentorROI[7] = 400; // for level 8
        mentorROI[8] = 200; // for level 9
        mentorROI[9] = 300; // for level 10

        bonusTarget[0] = 2000 * (10 ** 18); // for level 1
        bonusTarget[1] = 5000 * (10 ** 18); // for level 2
        bonusTarget[2] = 15000 * (10 ** 18); // for level 3
        bonusTarget[3] = 35000 * (10 ** 18); // for level 4
        bonusTarget[4] = 90000 * (10 ** 18); // for level 5
        bonusTarget[5] = 150000 * (10 ** 18); // for level 6
        bonusTarget[6] = 300000 * (10 ** 18); // for level 7
        bonusTarget[7] = 600000 * (10 ** 18); // for level 8
        bonusTarget[8] = 1000000 * (10 ** 18); // for level 9
        bonusTarget[9] = 1500000 * (10 ** 18); // for level 10

        rewardBonus[0] = 1 * (10 ** 18); // for level 1
        rewardBonus[1] = 25 * (10 ** 17); // for level 2
        rewardBonus[2] = 11 * (10 ** 18); // for level 3
        rewardBonus[3] = 24 * (10 ** 18); // for level 4
        rewardBonus[4] = 55 * (10 ** 18); // for level 5
        rewardBonus[5] = 120 * (10 ** 18); // for level 6
        rewardBonus[6] = 240 * (10 ** 18); // for level 7
        rewardBonus[7] = 440 * (10 ** 18); // for level 8
        rewardBonus[8] = 740 * (10 ** 18); // for level 9
        rewardBonus[9] = 1001 * (10 ** 18); // for level 10

        userInfo memory UserInfo;

        UserInfo = userInfo({
            joinTime: block.timestamp,
            referrer: msg.sender,
            investedAmount: 1,  
            returnPercent: defaultROI,
            lastWithdrawTime: block.timestamp,
            totalPaidROI: 0,
            totalBusiness:0
        });
        userInfos[msg.sender] = UserInfo;
        firstInvestor = msg.sender;
    }

    function setTokenAddress(address _tokenAddress) public onlyOwner returns(bool){
        tokenAddress = _tokenAddress;
        return true;
    }

    function setInvestAmountCap(uint _min, uint _max) public onlyOwner returns(bool){
        minInvestAmount = _min;
        maxInvestAmount = _max;
        return true;
    }

    event newJnvestEv(address user, address referrer,uint amount,uint eventTime);
    event directPaidEv(address paidTo,uint level,uint amount,address user,uint eventTime);
    event bonusEv(address receiver,address sender,uint newPercent,uint eventTime);

    function invest(address _referrer, uint _amount) public returns(bool) {
        require(userInfos[msg.sender].joinTime == 0, "already invested");
        require(userInfos[_referrer].joinTime > 0, "Invalid referrer");
        require(_amount >= minInvestAmount && _amount <= maxInvestAmount, "Invalid Amount");
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), _amount);

        userInfo memory UserInfo;

        UserInfo = userInfo({
            joinTime: block.timestamp,
            referrer: _referrer,
            investedAmount: _amount,  
            returnPercent: defaultROI,
            lastWithdrawTime: block.timestamp,
            totalPaidROI: 0,
            totalBusiness: 0
        });
        userInfos[msg.sender] = UserInfo;

        emit newJnvestEv(msg.sender, _referrer, _amount, block.timestamp);


        // pay direct
        address _ref = _referrer;
        for(uint i=0;i<10;i++) {
            userInfos[_ref].totalBusiness += _amount;
            uint amt = _amount * levelIncome[i] / 10000;
            //tokenInterface(tokenAddress).transfer(_ref,amt);
            referralWithdraw[_ref] += amt;
            emit directPaidEv(_ref, i, amt, msg.sender, block.timestamp);
            _ref = userInfos[_ref].referrer;
        }

        userInfo memory temp = userInfos[_referrer];
        //if booster
        if(block.timestamp - temp.joinTime <= 30 * oneDay && _amount >= temp.investedAmount && temp.returnPercent < 125 ) {
            temp.returnPercent = temp.returnPercent + 10;
            if ( temp.returnPercent > 100 )  temp.returnPercent = 125;
            emit bonusEv(_referrer, msg.sender, temp.returnPercent, block.timestamp);
            userInfos[_referrer].returnPercent = temp.returnPercent;
        }

        return true;
    }

    function withdraw(address forUser) public returns(bool) {
        withdrawReferral(forUser);
        withdrawROI(forUser);
        withdrawBonus(forUser);
        withdrawMentorGain(forUser);
        return true;
    }

    function withdrawReferral(address forUser) public returns(bool) {
        uint amt = referralWithdraw[forUser];
        referralWithdraw[forUser] = 0;
        tokenInterface(tokenAddress).transfer(forUser,amt);        
        return true;
    }

    event withdrawEv(address caller,uint roiAmount,uint forDay,uint percent, uint eventTime );
    event mentorPaidEv(address paidTo,uint level,uint amount,address user,uint eventTime);
    function withdrawROI(address forUser) public returns(bool) {
        userInfo memory temp = userInfos[forUser];       
        if(temp.totalPaidROI < temp.investedAmount * 4) {
            uint totalDay = (block.timestamp - temp.lastWithdrawTime) / oneDay;
            if (totalDay > 0) {
                uint roiAmount = totalDay *  temp.investedAmount *  temp.returnPercent / 10000;
                if ( temp.totalPaidROI + roiAmount > temp.investedAmount * 4 ) roiAmount = (temp.investedAmount * 4) - temp.totalPaidROI;
                userInfos[forUser].totalPaidROI += roiAmount;
                userInfos[forUser].lastWithdrawTime = block.timestamp;
                tokenInterface(tokenAddress).transfer(forUser,roiAmount);
                emit withdrawEv(forUser, roiAmount, totalDay,temp.returnPercent, block.timestamp );

                // pay mentor
                address _ref = userInfos[forUser].referrer;
                for(uint i=0;i<10;i++) {
                    uint amt = roiAmount * mentorROI[i] / 10000;
                    mentorGain[_ref] += amt;
                    //tokenInterface(tokenAddress).transfer(_ref,amt);
                    emit mentorPaidEv(_ref, i, amt, forUser, block.timestamp);
                    _ref = userInfos[forUser].referrer;
                }                
                
            }
        }
        return true;
    }

    function withdrawMentorGain(address forUser) public returns(bool) {
        if (mentorGain[forUser] > 0) {
            uint amt = mentorGain[forUser];
            mentorGain[forUser] = 0;
            tokenInterface(tokenAddress).transfer(forUser,amt);
        }
        return true;
    }

    function viewMyROI(address forUser) public view returns(uint) {
        uint roiAmount;
        userInfo memory temp = userInfos[forUser];       
        if(temp.totalPaidROI < temp.investedAmount * 4) {
            uint totalDay = (block.timestamp - temp.lastWithdrawTime) / oneDay;
            if (totalDay > 0) {
                roiAmount = totalDay *  temp.investedAmount *  temp.returnPercent / 10000;
                if ( temp.totalPaidROI + roiAmount > temp.investedAmount * 4 ) roiAmount = (temp.investedAmount * 4) - temp.totalPaidROI;              
            }
        }
        return roiAmount;
    }    


    function claimRewardBonus() public returns(bool) {
        for(uint i=0;i<10;i++) {
            if (!bonus[msg.sender][i]) {
                if(userInfos[msg.sender].totalBusiness >= bonusTarget[i]) {
                    bonus[msg.sender][i] = true;
                    lastBonusTime[msg.sender][i] = block.timestamp;
                    break;
                }
            }
        }
        return true;
    }

    event withdrawBonusEv(address user,uint totalBonus,uint eventTime);
    function withdrawBonus(address forUser) public returns(bool) {
        uint totalBonus;
        for(uint i=0;i<10;i++) {
            uint bp = totalBonusPaid[forUser][i];
            if (bonus[forUser][i] && bp > 150 * rewardBonus[i]) {
                uint day = ( block.timestamp - lastBonusTime[forUser][i] ) / oneDay ;
                totalBonus += rewardBonus[i] * day;
                if(bp + totalBonus > 150 * rewardBonus[i]) totalBonus = (150 * rewardBonus[i]) - bp;
                totalBonusPaid[forUser][i] += totalBonus;
                lastBonusTime[forUser][i] = block.timestamp;
            }
        } 
        if(totalBonus > 0 ) {
            tokenInterface(tokenAddress).transfer(forUser,totalBonus);
            emit withdrawBonusEv(forUser, totalBonus, block.timestamp);
        }       
        return true;
    }





}
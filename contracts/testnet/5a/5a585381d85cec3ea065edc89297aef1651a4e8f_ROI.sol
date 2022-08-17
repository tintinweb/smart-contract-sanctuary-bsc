/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.6;

library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




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



struct daysPercent {
    uint8 life_days;
    uint8 percent;
}

struct DepositStruct {
    uint256 amount;
    uint40 time;
    uint256 withdrawn;
}

struct Investor {
    address daddy;
    uint256 dividends;
    uint256 matchBonus;
    uint40 lastPayout;
    uint256 totalInvested;
    uint256 totalWithdrawn;
    uint256 totalBonus;
    uint256 spinRewards;
    DepositStruct [] depositsArray;
    mapping(uint256=>uint256) referralEarningsL; 
    uint256[3] structure;
    uint256 totalRewards;
    uint256 noOfTimesPlayed;
}

contract ROI {
    using SafeMath for uint256;
    using SafeMath for uint40;

    uint256 public contractInvested;
    uint256 public contractWithdrawn;
    uint256 public matchBonus;
    uint256 public totalUsers;

    uint8 constant BonusLinesCount = 3;
    uint16 constant percentDivider = 1000;
    uint256 constant public ceoFee = 50;

    uint8[BonusLinesCount] public referralBonus = [100,50,50];
    // uint40 public TIME_STEP = 86400;  
    uint40 public TIME_STEP = 60;
    uint8 public Daily_ROI = 200;
    uint8 public noofDays= 100;
    uint256 public spinAmount = 200 ether;

  
    mapping(address => Investor) public investorsMap;

    address payable public ceoWallet;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount); 
    event SpinWheel(address indexed user,uint256 no,uint256 timestamp,uint256 rewards);

    constructor(address payable ceoAddr) {
        require(!isContract(ceoAddr));
        ceoWallet = ceoAddr;
        
    }

    function _payInvestor(address _addr) private {
        uint256 payout = calcPayoutInternal(_addr);

        if (payout > 0) {
            investorsMap[_addr].lastPayout = uint40(block.timestamp);
            investorsMap[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = investorsMap[_addr].daddy;
        uint i = 0;
        for (i = 0; i < BonusLinesCount; i ++) {
            if(up == address(0)) break;
            uint256 bonus = _amount * referralBonus[i] / percentDivider;
            investorsMap[up].matchBonus += bonus;
            investorsMap[up].totalBonus += bonus;
            matchBonus += bonus;
            emit MatchPayout(up, _addr, bonus);
            investorsMap[up].referralEarningsL[i]=investorsMap[up].referralEarningsL[i].add(bonus);
            up = investorsMap[up].daddy;
        }
        
        for(uint256 j=i;j< BonusLinesCount;j++){
            uint256 bonus = _amount * referralBonus[j] / percentDivider;
            
            investorsMap[ceoWallet].matchBonus +=  bonus.mul(75).div(100);
            investorsMap[ceoWallet].totalBonus += bonus.mul(75).div(100);            
        }
    }

    function _setUpdaddy(address _addr, address _upline) private {
        if (investorsMap[_addr].daddy == address(0) && _addr != ceoWallet && investorsMap[_upline].depositsArray.length > 0) {

            investorsMap[_addr].daddy = _upline;

            for(uint i = 0; i < BonusLinesCount; i++) {
                investorsMap[_upline].structure[i]++;

                _upline = investorsMap[_upline].daddy;

                if(_upline == address(0)) break;
            }

        }
    }

    function deposit( address _upline) external payable{ 
        uint256 amount = msg.value;
        require(amount >= 0.001 ether, "Minimum deposit amount is 20 matic");
        
        Investor storage investor = investorsMap[msg.sender];
        uint256 cfee  = amount.mul(ceoFee).div(percentDivider);
        ceoWallet.transfer(cfee);
    
        _setUpdaddy(msg.sender, _upline);

        investor.depositsArray.push(DepositStruct({
            amount: amount,
            time: uint40(block.timestamp),
            withdrawn:0
        }));
        
        if(investor.depositsArray.length==1)
        {
            totalUsers++;
        }

        investor.totalInvested += amount;
        contractInvested += amount;

        _refPayout(msg.sender, amount);

        emit NewDeposit(msg.sender, amount);

    }

    function withdraw() external { 
        Investor storage investor = investorsMap[msg.sender];
       
        _payInvestor(msg.sender);

        require(investor.dividends > 0 || investor.matchBonus > 0 || investor.totalRewards>0);

        uint256 amount = investor.dividends + investor.matchBonus + investor.totalRewards;

        investor.dividends = 0;
        investor.matchBonus = 0;
        investor.totalRewards =0;
        investor.totalWithdrawn += amount;

        contractWithdrawn += amount;

        payable(msg.sender).transfer(amount);

    }
    
    function calcPayoutInternal(address _addr) internal returns (uint256 value) {
        Investor storage investor = investorsMap[_addr];

        for (uint256 i = 0; i < investor.depositsArray.length; i++) {
            DepositStruct storage iterDeposits = investor.depositsArray[i];
            
            uint40 time_end = iterDeposits.time + noofDays * TIME_STEP;
            uint40 from = investor.lastPayout > iterDeposits.time ? investor.lastPayout : iterDeposits.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);
            uint256 dividends = 0;
            if (from < to) {
                dividends = iterDeposits.amount * (to.sub(from)) * Daily_ROI / noofDays / (TIME_STEP*100);
                value +=dividends;
                iterDeposits.withdrawn = iterDeposits.withdrawn.add(dividends);
            }
        }
        return value;
    }

   
   
    function calcPayout(address _addr) view external returns (uint256 value) {
        Investor storage investor = investorsMap[_addr];

        for (uint256 i = 0; i < investor.depositsArray.length; i++) {
            DepositStruct storage iterDeposits = investor.depositsArray[i];
            
            uint40 time_end = iterDeposits.time + noofDays * TIME_STEP;
            uint40 from = investor.lastPayout > iterDeposits.time ? investor.lastPayout : iterDeposits.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if (from < to) {
                value += iterDeposits.amount * (to.sub(from)) * Daily_ROI / noofDays / (TIME_STEP*100);
            }
        }
        return value;
    }
    
    function spinInfo(address _addr)view external returns( uint256 spinRewards,uint256 totalRewards)
    {
        Investor storage investor = investorsMap[_addr];
        return (investor.spinRewards,investor.totalRewards);
    }

    function userInfo(address _addr) view external returns( 
        uint256 for_withdraw, 
        uint256 totalInvested, 
        uint256 totalWithdrawn, 
        uint256 totalBonus,
        uint256 _matchBonus,
        uint256[BonusLinesCount] memory structure,
        uint256[BonusLinesCount] memory referralEarningsL,
         DepositStruct[] memory deposits
        ) {
        Investor storage investor = investorsMap[_addr];

        uint256 payout = this.calcPayout(_addr);

        for(uint8 i = 0; i <BonusLinesCount; i++) {
            structure[i] = investor.structure[i];
            referralEarningsL[i]=investor.referralEarningsL[i];
        }
        
        return (
            payout + investor.dividends,
            investor.totalInvested,
            investor.totalWithdrawn,
            investor.totalBonus,
            investor.matchBonus,
             structure,
             referralEarningsL,
             investor.depositsArray
            );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus,uint256 _totalUsers) {
        return (contractInvested, contractWithdrawn, matchBonus,totalUsers);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    /****************Spinwheel*///////////////////
    uint256 nonce =1;
    mapping(uint256=>uint256) public rewards;


    function random() internal returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 20;
        randomnumber = randomnumber + 1;
        nonce++;
        return randomnumber;
    }
    

    function startSpinWheel() public payable returns(uint256 winningPosition)
    {
        require(msg.value==spinAmount,"Need to buy a chance");
        uint256 no = random();
        if(rewards[no]>0)
        {
            investorsMap[msg.sender].totalRewards =  investorsMap[msg.sender].totalRewards.add(rewards[no]);
            investorsMap[msg.sender].spinRewards =  investorsMap[msg.sender].spinRewards.add(rewards[no]);
        }
        if(rewards[no]<spinAmount){
            contractInvested += spinAmount.sub(rewards[no]);
        }
        investorsMap[msg.sender].noOfTimesPlayed =  investorsMap[msg.sender].noOfTimesPlayed.add(1);

        emit SpinWheel(msg.sender,no,block.timestamp,rewards[no]);
        return no;
    }

}
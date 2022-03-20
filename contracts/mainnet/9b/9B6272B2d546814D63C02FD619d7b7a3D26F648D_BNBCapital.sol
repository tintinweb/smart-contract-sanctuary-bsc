/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

pragma solidity ^0.8.7;

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
    uint8 lockUp;
    uint256 amount;
    uint40 time;
}

struct Investor {
    address daddy;
    uint256 dividends;
    uint256 matchBonus;
    uint40 lastPayout;
    uint256 totalInvested;
    uint256 totalWithdrawn;
    uint256 totalBonus;
    uint256 giveawayBonus;
    DepositStruct [] depositsArray;
    uint256[5] structure;
}

contract BNBCapital {
    using SafeMath for uint256;
    using SafeMath for uint40;

    uint256 public contractInvested;
    uint256 public contractWithdrawn;
    uint256 public matchBonus;

    uint8 constant BonusLinesCount = 5;
    uint16 constant percentDivider = 1000;
    uint256 constant public ceoFee = 100;
    uint8[BonusLinesCount] public referralBonus = [80, 30, 20, 10,10];
    uint40 public TIME_STEP = 86400;

  
    mapping(uint8 => daysPercent) public WPR;
    mapping(address => Investor) public investorsMap;

    address payable public ceoWallet;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount); 

        constructor(address payable ceoAddr) {
        require(!isContract(ceoAddr));
        ceoWallet = ceoAddr;

        uint8 percentage = 188;
        for (uint8 daysInvested = 16; daysInvested <= 25; daysInvested++) {
            WPR[daysInvested] = daysPercent(daysInvested, percentage);
            percentage+= 6;
        }
    }

    function _payInvestor(address _addr) private {
        uint256 payout = this.calcPayout(_addr);

        if (payout > 0) {
            investorsMap[_addr].lastPayout = uint40(block.timestamp);
            investorsMap[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = investorsMap[_addr].daddy;

        for (uint i = 0; i < BonusLinesCount; i ++) {
            if(up == address(0)) break;

            uint256 bonus = _amount * referralBonus[i] / percentDivider;

            investorsMap[up].matchBonus += bonus;
            investorsMap[up].totalBonus += bonus;

            matchBonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = investorsMap[up].daddy;
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

    function deposit(uint8 _lockUp, address _upline) external payable{ 
        uint256 amount = msg.value;
        uint256 currentBlockTimestamp = uint256(block.timestamp);
        bool hasLaunchPassed = currentBlockTimestamp > 1643428800;
        require(WPR[_lockUp].life_days >= 16, "Tarif not found");
        require(amount >= 0.05 ether, "Minimum deposit amount is 0.05 BNB");
        require(hasLaunchPassed == true, "We still havent launched yet!");

        Investor storage investor = investorsMap[msg.sender];
        require(investor.depositsArray.length < 100, "Max 100 deposits per address");

        uint256 cfee  = amount.mul(ceoFee).div(percentDivider);
        ceoWallet.transfer(cfee);
 
        uint256 giveaway = 0;
        if(WPR[_lockUp].life_days>=25)
        {
            giveaway = amount.mul(3).div(100);
        }
        else if(WPR[_lockUp].life_days>=16)
        {
            giveaway = amount.mul(2).div(100);
        }
        if(giveaway>0){
            payable(msg.sender).transfer(giveaway);  
            investor.giveawayBonus = investor.giveawayBonus.add(giveaway);
        }

        _setUpdaddy(msg.sender, _upline);

        investor.depositsArray.push(DepositStruct({
            lockUp: _lockUp,
            amount: amount,
            time: uint40(block.timestamp)
        }));

        investor.totalInvested += amount;
        contractInvested += amount;

        _refPayout(msg.sender, amount);

        emit NewDeposit(msg.sender, amount, _lockUp);

    }

    function getInfo() view external returns ( 
        uint256 leLockup, 
        uint256 leTime, 
        uint256 leCurrent, 
        bool leTimeLess
        ){
        
        Investor storage investor = investorsMap[msg.sender];
        
        uint256 lastDeposit = investor.depositsArray.length - 1;
        uint256 sendDepositLockup = uint256(investor.depositsArray[lastDeposit].lockUp);
        uint256 sendDepositBlocktime = uint256(investor.depositsArray[lastDeposit].time);
        uint256 sendCurrentTime = uint256(block.timestamp);
        bool isCurrenTimeLess = sendCurrentTime < sendDepositBlocktime + sendDepositLockup*TIME_STEP;
        
        
        return(
            sendDepositLockup,
            sendDepositBlocktime,
            sendCurrentTime,
            isCurrenTimeLess
            );
    }
    function withdraw() external { 
        Investor storage investor = investorsMap[msg.sender];
        uint256 lastDeposit = investor.depositsArray.length - 1;
        uint256 sendDepositLockup = uint256(investor.depositsArray[lastDeposit].lockUp);
        uint256 sendDepositBlocktime = uint256(investor.depositsArray[lastDeposit].time);
        uint256 sendCurrentTime = uint256(block.timestamp);
        bool isCurrenTimeLess = sendCurrentTime < sendDepositBlocktime + sendDepositLockup*TIME_STEP;
        require(isCurrenTimeLess == false, "Lockup period has not ended yet.");

        _payInvestor(msg.sender);

        require(investor.dividends > 0 || investor.matchBonus > 0);

        uint256 amount = investor.dividends + investor.matchBonus;

        investor.dividends = 0;
        investor.matchBonus = 0;
        investor.totalWithdrawn += amount;

        contractWithdrawn += amount;

        payable(msg.sender).transfer(amount);

    }

    function depositHalf(uint8 _lockUp, address _upline, uint256 amount) internal {
        require(WPR[_lockUp].life_days >= 16, "Tarif not found");
        require(amount >= 0.025 ether, "Minimum deposit amount is 0.025 BNB");

        Investor storage investor = investorsMap[msg.sender];

        require(investor.depositsArray.length < 100, "Max 100 deposits per address");

        uint256 cfee  = amount.mul(ceoFee).div(percentDivider);
  
        ceoWallet.transfer(cfee);
 
        emit FeePayed (msg.sender, cfee);

        _setUpdaddy(msg.sender, _upline);

        investor.depositsArray.push(DepositStruct({
            lockUp: _lockUp,
            amount: amount,
            time: uint40(block.timestamp)

        }));

        investor.totalInvested += amount;
        contractInvested += amount;

        _refPayout(msg.sender, amount);

        emit NewDeposit(msg.sender, amount, _lockUp);

    }

    function withdrawHalf() external { 
        Investor storage investor = investorsMap[msg.sender];

        uint256 lastDeposit = investor.depositsArray.length - 1;
        uint256 sendDepositLockup = uint256(investor.depositsArray[lastDeposit].lockUp);
        uint256 sendDepositBlocktime = uint256(investor.depositsArray[lastDeposit].time);
        uint256 sendCurrentTime = uint256(block.timestamp);
        bool isCurrenTimeLess = sendCurrentTime < sendDepositBlocktime + sendDepositLockup*TIME_STEP;
        require(isCurrenTimeLess == false, "Lockup period has not ended yet.");

        _payInvestor(msg.sender);
        
        require(investor.dividends > 0 || investor.matchBonus > 0, "Zero Amount");

        uint256 amount = (investor.dividends + investor.matchBonus) / 2;
        
        investor.dividends = 0;
        investor.matchBonus = 0;
        investor.totalWithdrawn += amount;
        contractWithdrawn += amount;

            
        address bigDaddy = investor.daddy;

        depositHalf(16, bigDaddy, amount);

        payable(msg.sender).transfer(amount);
    }

    function calcPayout(address _addr) view external returns (uint256 value) {
        Investor storage investor = investorsMap[_addr];

        for (uint256 i = 0; i < investor.depositsArray.length; i++) {
            DepositStruct storage iterDeposits = investor.depositsArray[i];
            daysPercent storage depositTime = WPR[iterDeposits.lockUp];

            uint40 time_end = iterDeposits.time + depositTime.life_days * TIME_STEP;
            uint40 from = investor.lastPayout > iterDeposits.time ? investor.lastPayout : iterDeposits.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if (from < to) {
                value += iterDeposits.amount * (to.sub(from)) * depositTime.percent / depositTime.life_days / (TIME_STEP*100);
            }

        }

        return value;

        }

    function userInfo(address _addr) view external returns( 
        uint256 for_withdraw, 
        uint256 totalInvested, 
        uint256 totalWithdrawn, 
        uint256 totalBonus,
        uint256 giveawayBonus,
         uint256[BonusLinesCount] memory structure
        ) {
        Investor storage investor = investorsMap[_addr];

        uint256 payout = this.calcPayout(_addr);

        for(uint8 i = 0; i <BonusLinesCount; i++) {
            structure[i] = investor.structure[i];
        }
        
        return (
            payout + investor.dividends + investor.matchBonus,
            investor.totalInvested,
            investor.totalWithdrawn,
            investor.totalBonus,
            investor.giveawayBonus,
             structure
            );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (contractInvested, contractWithdrawn, matchBonus);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}
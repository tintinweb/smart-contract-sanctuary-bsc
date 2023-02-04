/**
 *Submitted for verification at BscScan.com on 2022-11-30
 */

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

interface IInsuranceContract {
	function initiate() external;
	function getBalance() external view returns(uint);
	function getMainContract() external view returns(address);
}

contract INSURANCE {
IERC20 public tokenAddress =
        IERC20(0xd3521B5dD10061245ABf863A3ae36732171084c3);
	//accept funds from MainContract
	receive() external payable {}
	address payable public MAINCONTRACT;

	constructor() {
		MAINCONTRACT = payable(msg.sender);
	}

	function initiate() public {
		require(msg.sender == MAINCONTRACT, "Forbidden");
		uint balance = address(this).balance;
		if(balance==0) return;
        IERC20(tokenAddress).transfer(MAINCONTRACT, balance);
	}

	function getBalance() public view returns(uint) {
		return address(this).balance;
	}

	function getMainContract() public view returns(address) {
		return MAINCONTRACT;
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
    uint256 lastInvestedAmount;
    address daddy;
    uint40 lastPayout;
    uint256 totalInvested;
    uint256 totalReferralInvested;
    uint256 totalWithdrawn;
    uint256 totalBonus;
    DepositStruct[] depositsArray;
    mapping(uint256 => uint256) referralEarningsL;
    uint256[5] structure;
    uint256 totalRewards;
    uint256 noOfTimesPlayed;
    uint256 time;
    uint256 matrixIncome;
}

contract ROI {
    using SafeMath for uint256;
    using SafeMath for uint40;

    IERC20 public tokenAddress =
        IERC20(0xd3521B5dD10061245ABf863A3ae36732171084c3);

    uint256 public contractInvested;
    uint256 public contractWithdrawn;
    uint256 public matchBonus;
    uint256 public totalUsers;
    address defaultReferralAddress = 0xc7EDf5Ef5a04Df3b0B25dbd8016BcEA9c357eb87;

    uint8 constant BonusLinesCount = 5;
    uint16 constant percentDivider = 100;
    uint16 constant percentDividerROI = 10000;

    uint256 referralBonus = 0;

    uint256 public MAX_LIMIT = 200;
    //uint40 public TIME_STEP = 86400;
    uint40 public TIME_STEP = 60;
    uint8 public Daily_ROI_Per = 100;

    uint256 MinimumDiposit = 1 * 1e18;
    uint256 MaximumDiposit = 100 * 1e18;
    uint256 CreatorsPercentage = 3;
    uint256 referralBonusPer = 40;
    uint256 EgaleFund = 0;
    uint256 EgaleFundPer = 1;

    uint256[BonusLinesCount] RefferalPer = [40, 1, 1, 2, 3];

    mapping(address => Investor) public investorsMap;
    address[] public managerUsers;

    address payable public CreatorsWalletAddress;
    address payable public DevelopersWalletAddress;


    address payable public			INSURANCE_CONTRACT;
	mapping (uint => uint) public	INSURANCE_MAXBALANCE;
	uint constant public			INSURANCE_PERCENT				= 20;					// insurance fee 10% of claim
	uint constant public			INSURANCE_LOWBALANCE_PERCENT	= 5;					// protection kicks in at 25% or lower
    uint public INSURANCE_TRIGGER_BALANCE;
    bool public isInsuranceTriggered;
    
    // Matrix
    struct UserStruct {
        uint256 activeLevel;
        uint256 planbactivatedround;
    }
    struct userInfo {
        uint256 id;
        uint256 referrerID;
        uint256 childCount;
        address userAddress;
        uint256 noofpayments;
        uint256 activeLevel;
    }
    mapping(address => UserStruct) public matrixUsers;
    mapping(uint256 => mapping(uint256 => userInfo)) public userInfos;
    mapping(address => mapping(uint256=>uint256)) public noofPayments;
    uint256 public currUserID = 0;
    mapping(uint256 => mapping(uint256 => address payable))
        public userAddressByID;
    // mapping(uint256 => mapping(uint256 => uint256)) public walletAmountPlanB;

    mapping(uint256 => uint256) public lastIDCount;
    mapping(uint256 => uint256) public lastFreeParent;
    mapping(uint256 => uint256) public LEVEL_PRICE;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount);
    event MatchPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event Withdraw(address indexed addr, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    event regLevelEvent(
        address indexed _user,
        uint256 _userId,
        uint256 _referralID,
        address indexed _referrer,
        uint256 _time
    );
    
    event buyLevelEvent(
        address indexed _user,
        uint256 _level,
        uint256 _time,
        uint256 _amount,
        uint256 _roundid
    );
    event binaryData(
        address indexed _user,
        uint256 _userId,
        uint256 _referralID,
        uint256 _level,
        address referralAddress,
        uint256 _roundid
    );
   
    constructor(address payable CreatorAddr, address payable DevAddr) {
        INSURANCE_CONTRACT = payable(new INSURANCE());
        CreatorsWalletAddress = CreatorAddr;
        DevelopersWalletAddress = DevAddr;
        LEVEL_PRICE[1] = 1 ether;
        LEVEL_PRICE[2] = 2 ether;

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            activeLevel: 6,
            planbactivatedround: 10
        });

        matrixUsers[CreatorsWalletAddress] = userStruct;

        userInfo memory UserInfo;

        UserInfo = userInfo({
            id: 1,
            referrerID: 0,
            childCount: 0,
            userAddress: CreatorsWalletAddress,
            noofpayments: 0,
            activeLevel: 8
        });

        for (uint256 cnt = 1; cnt <= 2; cnt++) {
            userInfos[cnt][1] = UserInfo;
            lastIDCount[cnt] = 1;
            lastFreeParent[cnt] = 1;
            userAddressByID[cnt][1] = CreatorsWalletAddress;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = investorsMap[_addr].daddy;
        uint256 i = 0;
        bool flag = false;
        uint256 bonus = 0;
        for (i = 0; i < BonusLinesCount; i++) {
            if (up == address(0)) break;

            uint256 _sendAmount = investorsMap[up].lastInvestedAmount > _amount
                ? _amount
                : investorsMap[up].lastInvestedAmount;
            bonus = (_sendAmount * RefferalPer[i]) / percentDivider;

            if (i == 0) {
                flag = true;
            }
            if (
                (i == 1 || i == 2) &&
                investorsMap[up].structure[0] == 5 &&
                investorsMap[up].totalReferralInvested >= 500 * 1e18
            ) {
                flag = true;
            }
            if (
                (i == 3 || i == 4) &&
                investorsMap[up].structure[0] == 10 &&
                investorsMap[up].totalReferralInvested >= 1000 * 1e18
            ) {
                flag = true;
            }

            if (flag) {
                investorsMap[up].referralEarningsL[i] = investorsMap[up]
                    .referralEarningsL[i]
                    .add(bonus);
                investorsMap[up].totalBonus += bonus;
                matchBonus += bonus;
                emit MatchPayout(up, _addr, bonus);
            }

            up = investorsMap[up].daddy;
        }
    }

    function _setUpdaddy(address _addr, address _upline) private {
        if (
            investorsMap[_addr].daddy == address(0) &&
            investorsMap[_upline].depositsArray.length > 0
        ) {
            investorsMap[_addr].daddy = _upline;

            for (uint256 i = 0; i < BonusLinesCount; i++) {
                investorsMap[_upline].structure[i]++;

                _upline = investorsMap[_upline].daddy;

                if (_upline == address(0)) break;
            }
        }
    }

    function deposit(uint256 _amount, address _upline) public payable {
        uint256 amount = _amount;

        collect(msg.sender);
        if (investorsMap[_upline].depositsArray.length == 0) {
            require(
                amount >= MinimumDiposit && amount <= MaximumDiposit,
                "You can deposite min 10$ or max 100$"
            );
        }
        require(
            amount >= investorsMap[msg.sender].lastInvestedAmount,
            "Invested amount should be greater than previous amount"
        );

        Investor storage investor = investorsMap[msg.sender];
        require(
            investor.depositsArray.length < 100,
            "Max 100 deposits per address"
        );

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        if (_upline == address(0)) {
            _upline = defaultReferralAddress;
        }

        uint256 cfee = amount.mul(CreatorsPercentage).div(percentDivider).div(
            2
        );
        IERC20(tokenAddress).transfer(CreatorsWalletAddress, cfee);
        IERC20(tokenAddress).transfer(DevelopersWalletAddress, cfee);

        _setUpdaddy(msg.sender, _upline);

        investor.depositsArray.push(
            DepositStruct({
                amount: amount,
                time: uint40(block.timestamp),
                withdrawn: 0
            })
        );

        investor.lastInvestedAmount = amount;
        if (investor.depositsArray.length == 1) {
            totalUsers++;
        }

        investor.totalInvested += amount;
        investorsMap[_upline].totalReferralInvested += amount;
        investorsMap[msg.sender].time = block.timestamp;
        contractInvested += amount;
        EgaleFund += _amount.mul(EgaleFundPer).div(percentDivider);

        _refPayout(msg.sender, amount);
        if (investorsMap[_upline].depositsArray.length == 1) {
        regUserPlanB(payable(msg.sender));
        }

        uint insuranceAmount = amount * INSURANCE_PERCENT / percentDivider;
        IERC20(tokenAddress).transfer(INSURANCE_CONTRACT, insuranceAmount);

        emit NewDeposit(msg.sender, amount);
        _insuranceTrigger();
    }

    function _insuranceTrigger() internal {

		uint balance = address(this).balance;
		uint todayIdx = block.timestamp/TIME_STEP;

		//new high today
		if ( INSURANCE_MAXBALANCE[todayIdx] < balance ) {
			INSURANCE_MAXBALANCE[todayIdx] = balance;
		}

		

		INSURANCE_TRIGGER_BALANCE = contractInvested*INSURANCE_LOWBALANCE_PERCENT/percentDivider;

		//low balance - initiate Insurance
		if( balance < INSURANCE_TRIGGER_BALANCE ) {
            isInsuranceTriggered = true;
			IInsuranceContract(INSURANCE_CONTRACT).initiate();
		}
	}

    /*********Matrix */
    function regUserPlanB(address payable userAddress) internal {
        matrixUsers[userAddress].planbactivatedround++;
        uint256 _roundid = matrixUsers[userAddress].planbactivatedround;
        if (userInfos[_roundid][lastFreeParent[_roundid]].childCount >= 2)
            lastFreeParent[_roundid]++;

        userInfo memory UserInfo;
        lastIDCount[_roundid]++;

        UserInfo = userInfo({
            id: lastIDCount[_roundid],
            referrerID: lastFreeParent[_roundid],
            childCount: 0,
            userAddress: userAddress,
            noofpayments: 0,
            activeLevel: 1
        });

        userInfos[_roundid][lastIDCount[_roundid]] = UserInfo;
        userInfos[_roundid][lastFreeParent[_roundid]].childCount++;
        userAddressByID[_roundid][lastIDCount[_roundid]] = userAddress;
        matrixUsers[userAddress].activeLevel = 1;

        emit buyLevelEvent(
            userAddress,
            1,
            block.timestamp,
            LEVEL_PRICE[1],
            _roundid
        );
        emit binaryData(
            userAddress,
            lastIDCount[_roundid],
            lastFreeParent[_roundid],
            6,
            userAddressByID[_roundid][lastFreeParent[_roundid]],
            _roundid
        );
        distributeBonus(lastIDCount[_roundid], 1, _roundid);
    }

    function _buyLevel(
        uint256 _level,
        uint256 user,
        uint256 _roundid
    ) internal returns (bool) {
        address payable useradd = userAddressByID[_roundid][user];
        emit buyLevelEvent(
            useradd,
            _level,
            block.timestamp,
            LEVEL_PRICE[_level],
            _roundid
        );
        distributeBonus(user, _level, _roundid);
        userInfos[_roundid][user].activeLevel = _level;
        return true;
    }

    function distributeBonus(
        uint256 _addr,
        uint256 _level,
        uint256 _roundid
    ) internal {
        uint256 up = userInfos[_roundid][_addr].referrerID;
        uint256 amt = LEVEL_PRICE[_level];

        for (uint256 i = 0; i < _level; i++) {
            if (up == 0) break;
            up = userInfos[_roundid][up].referrerID;
        }
        if (up == 0) {
            up = 1;
        }
        address payable receiver = userAddressByID[_roundid][up];
        noofPayments[receiver][_level]++;

        if(_level==1 && noofPayments[receiver][_level]==2){
            _buyLevel(
                userInfos[_roundid][up].activeLevel + 1,
                up,
                _roundid
            );
        }
        if (_level == 2 && noofPayments[receiver][_level] == 4) {
            investorsMap[receiver].matrixIncome += LEVEL_PRICE[2].div(2);
            noofPayments[receiver][1]=0;
            noofPayments[receiver][2]=0;
            regUserPlanB(userAddressByID[_roundid][up]);
        } else if(_level==2){
            investorsMap[receiver].matrixIncome += amt;
        }
    }
    

    

    /*******************Matrix end */

    function withdraw() external {
        Investor storage investor = investorsMap[msg.sender];

        collect(msg.sender);

        require(
            investor.totalRewards > 0 || investor.totalBonus > 0,
            "You dont have any amount to withdraw"
        );
        uint256 profit = investor.totalInvested.mul(MAX_LIMIT).div(100);
        if(isInsuranceTriggered){
            profit = investor.totalInvested;
        }
        

        uint256 amount = investor.totalRewards.add(investor.totalWithdrawn);
        if (amount > profit) {
            amount = profit.sub(investor.totalWithdrawn);
        }
        investor.totalRewards = 0;
        investor.totalWithdrawn += amount;

        contractWithdrawn += amount;

       IERC20(tokenAddress).transfer(msg.sender, amount);
        // _insuranceTrigger();
    }

    function getRoiPer(address _user) public view returns (uint256) {
        if (
            investorsMap[_user].structure[0] >= 100 &&
            investorsMap[_user].totalReferralInvested >= 10000 * 1e18
        ) {
            return 25;
        } else if (
            investorsMap[_user].structure[0] >= 50 &&
            investorsMap[_user].totalReferralInvested >= 5000 * 1e18
        ) {
            return 50;
        }
        return Daily_ROI_Per;
    }

    function collect(address _addr) internal {
        Investor storage investor = investorsMap[_addr];

        uint256 secPassed = block.timestamp.sub(investor.time);
        if (secPassed > 0 && investor.time > 0) {
            uint256 collectProfit = 0;

            uint256 per = getRoiPer(msg.sender);
            if (secPassed > 0) {
                collectProfit = (
                    investor.totalInvested.mul(per).div(percentDivider)
                ).mul(secPassed).div(TIME_STEP);

                if (
                    investor.totalWithdrawn.add(investor.totalRewards).add(collectProfit) >
                    investor.totalInvested.mul(MAX_LIMIT).div(100)
                ) {
                    collectProfit = (
                        investor.totalInvested.mul(MAX_LIMIT).div(100)
                    ).sub(investor.totalWithdrawn).sub(investor.totalRewards);
                }
            }

            investor.totalRewards = investor
                .totalRewards
                .add(collectProfit);
            investor.time = investor.time.add(secPassed);
        }
        //updateContractBalance();
    }

    //when to distribute
    function _distributeManagerPool() private {
        uint256 managerCount;
        for (uint256 i = 0; i < managerUsers.length; i++) {
            managerCount = managerCount.add(1);
        }
        if (managerCount > 0) {
            uint256 reward = EgaleFund.div(managerCount);
            uint256 totalReward;
            for (uint256 i = 0; i < managerUsers.length; i++) {
                investorsMap[managerUsers[i]].totalRewards = investorsMap[
                    managerUsers[i]
                ].totalRewards.add(reward);
                totalReward = totalReward.add(reward);
            }
            if (EgaleFund > totalReward) {
                EgaleFund = EgaleFund.sub(totalReward);
            } else {
                EgaleFund = 0;
            }
        }
    }

    function calcPayout(address _addr) public view returns (uint256) {
        Investor storage investor = investorsMap[_addr];
        uint256 collectProfit = 0;
        uint256 secPassed = block.timestamp.sub(investor.time);
        uint256 per = getRoiPer(msg.sender);
        if (secPassed > 0 && investor.time > 0) {
            if (secPassed > 0) {
                collectProfit = (
                    investor.totalInvested.mul(per).div(percentDividerROI)
                ).mul(secPassed).div(TIME_STEP);

                 if (
                    investor.totalWithdrawn.add(investor.totalRewards).add(collectProfit) >
                    investor.totalInvested.mul(MAX_LIMIT).div(100)
                ) {
                    collectProfit = (
                        investor.totalInvested.mul(MAX_LIMIT).div(100)
                    ).sub(investor.totalWithdrawn).sub(investor.totalRewards);
                }
            }
        }

        return collectProfit;
    }

    function _userInfo(address _addr)
        external
        view
        returns (
            uint256 for_withdraw,
            uint256 totalInvested,
            uint256 totalWithdrawn,
            uint256 totalBonus,
            uint256 totalRewards,
            uint256 totalReferralInvested,
            uint256[BonusLinesCount] memory structure,
            uint256[BonusLinesCount] memory referralEarningsL,
            DepositStruct[] memory deposits
        )
    {
        Investor storage investor = investorsMap[_addr];

        uint256 payout = this.calcPayout(_addr);

        for (uint8 i = 0; i < BonusLinesCount; i++) {
            structure[i] = investor.structure[i];
            referralEarningsL[i] = investor.referralEarningsL[i];
        }

        return (
            payout,
            investor.totalInvested,
            investor.totalWithdrawn,
            investor.totalBonus,
            investor.totalRewards,
            totalReferralInvested,
            structure,
            referralEarningsL,
            investor.depositsArray
        );
    }

    function contractInfo()
        external
        view
        returns (
            uint256 _invested,
            uint256 _withdrawn,
            uint256 _match_bonus,
            uint256 _totalUsers
        )
    {
        return (contractInvested, contractWithdrawn, matchBonus, totalUsers);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
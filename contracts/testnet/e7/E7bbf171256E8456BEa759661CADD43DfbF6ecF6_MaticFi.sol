/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

/**
 *Submitted for verification at polygonscan.com on 2022-12-19
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

contract MaticFi is Initializable{
    uint256 lastUserId;
    address owner;
    address secondOwner;
    bool isWithdrawAvailable;

    uint256[11] levelShare;
    uint256[11] levelBonusShare;
    uint256 [11] directTurnoverRecord;
    uint256 [11] teamTurnoverRecord; 

    struct User {
        uint256 userID;
        address referalAddress;
        uint256 userTotalWthdrwal;
        uint256 userTotalInvestment;
        uint256 userDirectReferal;
        uint256 userTeamreferalEarnings;
        uint256 totalIncentive;
        mapping(uint8 => bool) activeX2Levels;
        mapping(uint8 => X2) x2Matrix;
        mapping(uint8=>uint) holdAmount;
		uint partnersCount;
    }

    struct X2 {
        address currentReferrer;
        address[] referrals;
    }

    mapping(address => User) public users;
    mapping(address => mapping(uint8 => uint256)) public userIncentiveDetail;
    mapping(address => mapping(uint8 => uint256)) public userwithdrwalIncentiveDetail;
    mapping(uint256 => address) public idToAddress;
    mapping(uint256 => uint256 ) public returnvalue;
    mapping(uint256 => uint256 ) public returnPrice;
    mapping(address => uint256 ) public maticFiInUserWallet;
    mapping(address => uint256) public userMaticInCurrentPurchase;
    mapping(address => uint256) public lastWithdrawlMaticRecived;
    uint8 public LAST_LEVEL;
    uint public socialWelfare;
  	uint public systemSaving;

    mapping(uint8 => mapping(uint256 => address)) public x2vId_number;
    mapping(uint8 => uint256) public x2CurrentvId;
    mapping(uint8 => uint256) public x2Index;

    uint256[9] matrixPackage;
    uint256[9] matrixProfit;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event Registration( address user,address referrer, uint userId, uint256 referrerId, uint256 _amount);
    event Withdraw( address WithdarawalBy , uint256 Amount);
    event Upgrade(address indexed user, address indexed referrer, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 level, uint8 place);
    event LeadershipDeduction(address indexed user , uint amount);
    event UserIncome(address sender ,address receiver,uint256 amount ,uint level,string _for);

    function initialize(address _owner) external  initializer {
        LAST_LEVEL = 9;
        lastUserId = 4000;
        isWithdrawAvailable = true;
        matrixPackage =[5,9,18,44,104,328,992,6976,85856];
        matrixProfit = [1,18,100,600,3000,20000,120000,1700000,40000000];
        levelShare = [10,4,2,1,1,1,1,1,2,2,3];
        levelBonusShare = [15,10,8,6,3,3,3,7,7,8,10];
        directTurnoverRecord = [0,100,200,300,400,500,600,700,800,900,1000];
        teamTurnoverRecord = [0,0,0,0,0,500,700,1000,1300,1600,2100];
        owner = _owner;

        users[_owner].userID = 3999;
        users[_owner].referalAddress =address(0);

     	idToAddress[3999]=owner;

        returnvalue[2] = 5;  
        returnvalue[100] = 80; 

        returnPrice[0]=1; 
        returnPrice[1]=10; 
        returnPrice[2]=100; 
        returnPrice[3]=1000; 
        returnPrice[4]=10000; 
        returnPrice[5]=100000; 
        returnPrice[6]=1000000; 
        returnPrice[7]=10000000;
        returnPrice[8]=100000000;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            x2vId_number[i][1]=owner;
            x2Index[i]=1;
            x2CurrentvId[i]=1;
        }

        users[owner].activeX2Levels[1] = true;
        emit Registration(msg.sender,address(0),3999,0,0);
		emit Upgrade(owner, users[owner].referalAddress, 1);

    }

    function deposit(uint256 _amount, uint256 _referralId) public payable {
        require(_amount !=0 &&_amount % (15*1e18) == 0,"Amount must be multiple of 15!");
        
        if(!isUserExists(msg.sender)) {
     		registration(msg.sender,idToAddress[_referralId],_amount);
        } else {
     		users[msg.sender].userTotalInvestment += _amount;
		}
		
		users[users[msg.sender].referalAddress].userDirectReferal += _amount;

        uint256 incentiveAmount = (_amount * 6666) / 10000; 

		// SocialWalfare
        socialWelfare += ((incentiveAmount * 5) / 100);

		// MaticFi Price Coding 
        uint256 principal = incentiveAmount * 60/100; 
      	uint maticFi = getMaticFi(principal);
        userMaticInCurrentPurchase[msg.sender] = maticFi;
        maticFiInUserWallet[msg.sender] += maticFi;

		// Level Income Distributation
        address _referrer = users[msg.sender].referalAddress;
		distributeLevelRewards( _referrer ,  _amount, incentiveAmount);

        users[msg.sender].activeX2Levels[1] = true; 
        address freeX6Referrer = findFreeX6Referrer(1);
        users[msg.sender].x2Matrix[1].currentReferrer = freeX6Referrer;
        updateX6Referrer(msg.sender, freeX6Referrer, 1);
        emit Upgrade(msg.sender, users[msg.sender].referalAddress, 1);
		emit LeadershipDeduction(msg.sender, (incentiveAmount*7)/100);
    }

	function getMaticFi(uint principal) public view returns (uint maticFi){
        uint256 turnOver = balanceInContract();

        if(turnOver == 0*1e18) {
            maticFi = (principal/returnPrice[0])/1e8 ;
        } else if(turnOver > 0*1e18 && turnOver <= 10*1e18) {
            maticFi = (principal/returnPrice[1])/1e8 ;
        } else if(turnOver > 10*1e18 && turnOver <= 100*1e18 ) {
            maticFi = (principal/returnPrice[2])/1e8 ;
        } else if(turnOver > 100*1e18 && turnOver <= 1000*1e18 ) {
            maticFi = (principal/returnPrice[3])/1e8 ;
        } else if(turnOver > 1000*1e18 && turnOver <= 10000*1e18 ) {
            maticFi = (principal/returnPrice[4])/1e8 ;
        } else if(turnOver > 10000*1e18 && turnOver <= 100000*1e18 ) {
            maticFi = (principal/returnPrice[5])/1e8 ;
        } else if(turnOver > 100000*1e18 && turnOver <= 1000000 *1e18) {
            maticFi = (principal/returnPrice[6])/1e8 ;
        } else if(turnOver > 1000000*1e18 && turnOver <= 10000000*1e18 ) {
            maticFi = (principal/returnPrice[7])/1e8 ;
        } else if(turnOver > 10000000*1e18 && turnOver <= 100000000*1e18 ) {
            maticFi = (principal/returnPrice[8])/1e8 ;
        } else if(turnOver > 100000000*1e18 ) {
            maticFi = (principal/returnPrice[8])/1e8 ;
        }

	}

	function distributeLevelRewards(address _referrer , uint _amount, uint incentiveAmount) private {
	    for(uint8 i=0; i<12; i++) {
	        if(_referrer!=address(0)) {
				users[_referrer].userTeamreferalEarnings += _amount;
				if(directTurnoverRecord[i] <= users[_referrer].userDirectReferal && teamTurnoverRecord[i] <= users[_referrer].userTeamreferalEarnings ) {
					users[_referrer].totalIncentive += (incentiveAmount * levelShare[i]) / 100;
                    // userIncentiveDetail[idToAddress[_ReferdBy]][i] +=(IncentiveAmount * levelShare[i]) / 100;
                    emit UserIncome(msg.sender,_referrer, ((incentiveAmount * levelShare[i]) / 100), i+1 ,"LevelIncome" );
				} else {
					systemSaving+= (incentiveAmount * levelShare[i]) / 100;
				}

				if(users[_referrer].referalAddress!=address(0))
					_referrer=users[_referrer].referalAddress;
				else
					break;
	        }
     	}
	}

	function registration(address userAddress, address referrerAddress,uint amount) private {
        require(isUserExists(referrerAddress), "referrer not exists");
 
        uint32 size;

        assembly {
            size := extcodesize(userAddress)
        }

        require(size == 0, "cannot be a contract");

        users[userAddress].userID = lastUserId;
		users[userAddress].referalAddress = referrerAddress;
		users[userAddress].userTotalInvestment= amount;
        idToAddress[lastUserId] = userAddress;

        users[userAddress].activeX2Levels[1] = true;

        lastUserId++;

        users[referrerAddress].partnersCount++;
        emit Registration(userAddress, referrerAddress, users[userAddress].userID, users[referrerAddress].userID,amount);
    }

    function withdrawAmount(uint256 _amount) public {

        require(isWithdrawAvailable == true ," Currently Withdrawl Is Unavaible");
        require(maticFiInUserWallet[msg.sender] > 0," User balance is zero !! Unable To Complete transanction");

        uint256 TurnOver = balanceInContract();
        
        uint256 Maticrem;

        uint256 userDemanded = _amount ;

        userDemanded = (maticFiInUserWallet[msg.sender] * userDemanded)/100; 

        require(maticFiInUserWallet[msg.sender] >= userDemanded ,"Not Enough Maticfi !! Please Purchase More to Continue");

        if(TurnOver == 0*1e18) {
            Maticrem = (userDemanded*returnPrice[0])/1e8;
        } else if(TurnOver > 0*1e18 && TurnOver <= 10*1e18 ) {
            Maticrem = (userDemanded*returnPrice[1])/1e8 ;
        } else if(TurnOver > 10*1e18 && TurnOver <= 100*1e18 ) {
            Maticrem = (userDemanded*returnPrice[2])/1e8 ;
        } else if(TurnOver > 100*1e18 && TurnOver <= 1000*1e18 ) {
            Maticrem = (userDemanded*returnPrice[3])/1e8 ;
        } else if(TurnOver > 1000*1e18 && TurnOver <= 10000*1e18 ) {
            Maticrem = (userDemanded*returnPrice[4])/1e8 ;
        } else if(TurnOver > 10000*1e18 && TurnOver <= 100000*1e18 ) {
            Maticrem = (userDemanded*returnPrice[5])/1e8 ;
        } else if(TurnOver > 100000*1e18 && TurnOver <= 1000000*1e18 ) {
            Maticrem = (userDemanded*returnPrice[6])/1e8 ;
        } else if(TurnOver > 1000000*1e18 && TurnOver <= 10000000*1e18 ) {
            Maticrem = (userDemanded*returnPrice[7])/1e8 ;
        } else if(TurnOver > 10000000*1e18 && TurnOver <= 100000000*1e18 ) { 
            Maticrem = (userDemanded*returnPrice[8])/1e8 ;
        } else if(TurnOver > 100000000*1e18 ) {
            Maticrem = (userDemanded*returnPrice[8])/1e8 ;
        }

        maticFiInUserWallet[msg.sender] = maticFiInUserWallet[msg.sender] - userDemanded;

        uint256 levelWillGet = (Maticrem * returnvalue[_amount])/100; 

        // payable(msg.sender).transfer(userDemanded - levelWillGet);
        lastWithdrawlMaticRecived[msg.sender] = userDemanded - levelWillGet;
        uint256 Amount;

        users[msg.sender].userTotalWthdrwal += userDemanded;

        uint256 refBalance = levelWillGet;
        Amount = refBalance;
        refBalance = (refBalance * 80) / 100;

        emit Withdraw(msg.sender,userDemanded);

        address _referrer = users[msg.sender].referalAddress;

        for (uint8 i = 0; i < 12; i++) {
            if (_referrer != address(0)){
                users[_referrer].totalIncentive +=(refBalance * levelBonusShare[i]) / 100;
                userwithdrwalIncentiveDetail[_referrer][i] += (refBalance * levelBonusShare[i]) / 100;
                emit UserIncome(msg.sender,_referrer, ((refBalance * levelBonusShare[i]) / 100), i+1 ,"LevelBonus");
                if ( users[_referrer].referalAddress !=address(0))
                _referrer = users[_referrer].referalAddress;
                else break;
            }
        } 

        uint256 adminwallet = ((Amount * 20) / 100);
        payable(owner).transfer(adminwallet);

    }

    function TransferAmountToOwnerWallet() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

    function balanceInContract() public view returns (uint256){
        return address(this).balance;

    } 

    function ClaimIncentiveReward () public payable{
        require( users[msg.sender].totalIncentive > 0,"available balance Is Zero ");
        payable(msg.sender).transfer(users[msg.sender].totalIncentive);
        users[msg.sender].totalIncentive = 0;
    } 

    function ChangeOwner (address newOwner) public onlyOwner{
        owner = newOwner;
    }

	function isUserExists(address user) public view returns (bool) {
        return (users[user].userID != 0);
    }

    function stopWithdrawl(bool _status) public onlyOwner{
        isWithdrawAvailable = _status;
    }

    function updateX6Referrer(address user, address referrerAddress, uint8 level) private {
        require(level<=LAST_LEVEL,"not valid level");
        if(referrerAddress==user) return;
        uint256 newIndex=x2Index[level]+1;
        x2vId_number[level][newIndex]=user;
        x2Index[level]=newIndex;
        
        if(users[referrerAddress].x2Matrix[level].referrals.length < getNumberofmember(level)) {
            users[referrerAddress].x2Matrix[level].referrals.push(user);
            users[referrerAddress].holdAmount[level]+=matrixPackage[level];
            emit NewUserPlace(user, referrerAddress, level, uint8(users[referrerAddress].x2Matrix[level].referrals.length));

        if(level<9 && users[referrerAddress].holdAmount[level]>=matrixPackage[level+1]&&users[referrerAddress].x2Matrix[level].referrals.length==getNumberofmember(level))
        {
        
        
        //Next Pool Upgradation
        users[referrerAddress].holdAmount[level] = users[referrerAddress].holdAmount[level]-matrixPackage[level+1];
        x2CurrentvId[level]=x2CurrentvId[level]+1; 
        autoUpgrade(referrerAddress, (level+1));
        // uint256 _amount= users[referrerAddress].holdAmount[level];
        
        
        //net holding ammount sent to users
        // payable(referrerAddress).transfer(users[referrerAddress].holdAmount[level]);
        emit UserIncome(user,referrerAddress,users[referrerAddress].holdAmount[level],level,"AutoPool");
        users[referrerAddress].holdAmount[level]=0;
        // emit ReEntry(referrerAddress,level);
        }
            if(level==9 && users[referrerAddress].x2Matrix[level].referrals.length==getNumberofmember(level))
            {

                emit UserIncome(user,referrerAddress,users[referrerAddress].holdAmount[level],level,"AutoPool");
                users[referrerAddress].holdAmount[level]=0;
            }
        }

        
    }

    function autoUpgrade(address _user, uint8 level) private {
        users[_user].activeX2Levels[level] = true;
        
        address freeX6Referrer = findFreeX6Referrer(level);
        users[_user].x2Matrix[level].currentReferrer = freeX6Referrer;
        updateX6Referrer(_user, freeX6Referrer, level);
        emit Upgrade(_user, freeX6Referrer, level);
    }

    function findFreeX6Referrer(uint8 level) public view returns(address){
        uint256 id=x2CurrentvId[level];
        return x2vId_number[level][id];
    }

    function getNumberofmember(uint8 _level) internal pure returns (uint8 num) {
        num=1;
        for(uint8 i=1; i<=_level;i++){
        num = num*2;
        }
    } 

    function usersX2Matrix(address user, uint8 level) public view returns(address, address[] memory) {
            return (users[user].x2Matrix[level].currentReferrer,
            users[user].x2Matrix[level].referrals);
    }

    function usersActiveX6Levels(address user, uint8 level) public view returns(bool ,uint) {
        return (users[user].activeX2Levels[level],users[user].holdAmount[level]);
    }

 	receive() external payable {}

}
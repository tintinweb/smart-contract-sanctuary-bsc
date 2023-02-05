/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    
    address private _owner;
    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function ownable_init(address __owner) internal {
        _owner = __owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }

    function owner() public view returns(address) {
        return _owner;
    }
}

contract Initializable {

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

contract EarnBUSD is  Ownable ,Initializable{

    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        uint clubIncome;
        uint swIncome;
        uint levelIncome;
        mapping(uint8 => bool) activePlans;
        mapping(uint8 => X2) x2Levels;
        mapping(uint8 => X2) x2Pools;
    }

    struct X2 {
        address currentReferrer;
        address[] referrals;
    }

    modifier onlyOperator() {
        require(operator==msg.sender,"Ownable: caller is not operator");
        _;
    }

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    mapping(address => bool) public isClubMember;
    address[] public clubMembers;

    uint public globalClub;

    IERC20 public busdToken;
    address public operator;
    mapping(uint8=>uint) public _package;

    uint8 public LAST_LEVEL;
    uint public lastUserId;

    mapping(uint8 => mapping(uint256 => address)) public x2vId_number;
    mapping(uint8 => uint256) public x2CurrentvId;
    mapping(uint8 => uint256) public x2Index;

    mapping(uint8 => mapping(uint256 => address)) public x3vId_number;
    mapping(uint8 => uint256) public x3CurrentvId;
    mapping(uint8 => uint256) public x3Index;

    event regLevelEv(address indexed _userWallet, uint indexed _userID, uint indexed _referrerID, uint _time, address _refererWallet);
    // event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId ,uint planId);
    event GlobalClubDeduction(address indexed user , uint amount);
    // event UpgradePackage(address indexed user , uint8 planId);
    event levelBuyEv(address indexed _user, uint _level, uint _amount, uint _time);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint place);
    event UserIncome(address sender ,address receiver,uint256 amount ,string _for);
    event paidForLevelEv(address indexed _user, address indexed _referral, uint _level, uint _amount, uint _time);
    event ClubIncome(address user, uint amount);
    
    event WithdrawClub(address indexed user , uint amount);

    function initialize(address ownerAddress, IERC20 _busdToken, address _operator ) external initializer {
        busdToken = _busdToken;
        operator = _operator;
        LAST_LEVEL = 12;
        ownable_init(ownerAddress);
        lastUserId =1;
        users[ownerAddress].id = 1;
        idToAddress[1] = ownerAddress;

        for(uint8 i=1; i<=6; i++) {
            _package[i] = i!=1 ? _package[i-1] *2 : 20*10**18;
            x2vId_number[i][1] = ownerAddress;
            x2Index[i] = 1;
            x2CurrentvId[i] = 1;
            
            x3CurrentvId[i] = 1;
            x3vId_number[i][1] = ownerAddress;
            x3Index[i] = 1;
    
            users[ownerAddress].activePlans[i] = true;
        }

        // emit Registration(ownerAddress, address(0), users[ownerAddress].id, 0, 1);
        emit regLevelEv( ownerAddress, 1, 0, block.timestamp, address(0));
    }

    function joinPlan(address _user, address _referrerAddress) external {
        require(busdToken.balanceOf(_user) >= (_package[1]),"Low Balance");
        require(busdToken.allowance(_user, address(this)) >= _package[1],"Invalid allowance amount");
        busdToken.transferFrom(_user, address(this), _package[1]);
        require(!users[_user].activePlans[1],"Already Activated Plan");
        if(!isUserExists(_user)){
            registration(_user, _referrerAddress);
        }

        users[_user].activePlans[1] = true;
        globalClub+= _package[1]*20/100;
        emit GlobalClubDeduction(_user , _package[1]*20/100 );


        busdToken.transfer(users[_user].referrer,_package[1]*25/100);
        users[users[_user].referrer].swIncome += (_package[1]*25/100);
        emit UserIncome(_user, users[_user].referrer,((_package[1]*25)/100), "SWDirect");

        
        //SW Income and User Place
        address freeX2Referrer = findFreeReferrer(_referrerAddress, 1);
        users[_user].x2Levels[1].currentReferrer = freeX2Referrer;
        updateSWReferrer(_user,freeX2Referrer,1);

        // Level Income
        address freeReferrer = findFreeX2Referrer(1);
        users[_user].x2Pools[1].currentReferrer = freeReferrer;
        updateX2Referrer(_user, freeReferrer, 1);
        // emit UpgradePackage(_user ,  1);
        emit levelBuyEv(_user, 1, _package[1] , block.timestamp);
    }

    function upgradePackage(address _user,uint8 _planId) external {
        require(busdToken.balanceOf(_user) >= (_package[_planId]),"Low Balance");
        require(busdToken.allowance(_user, address(this)) >= _package[_planId],"Invalid allowance amount");
        busdToken.transferFrom(_user, address(this), _package[_planId]);
        require(!users[_user].activePlans[_planId],"Already Activated Plan");
        require(users[_user].activePlans[1],"First activate Plan 1");
        require(isUserExists(_user),"User not Exist!");
        
        users[_user].activePlans[_planId]=true;

        bool res = checkQualificationforClub(_user);
        if(res) {
            if(!isClubMember[_user]) {
                clubMembers.push(_user);
            }
        }

        globalClub+= _package[_planId]*20/100;
        emit GlobalClubDeduction(_user , _package[_planId]*20/100);

        busdToken.transfer(users[_user].referrer,_package[_planId]*25/100);
        users[users[_user].referrer].swIncome += (_package[_planId]*25/100);
        emit UserIncome(_user, users[_user].referrer,((_package[_planId]*25)/100), "SWDirect");


        address free3xReferrer = findFreeX3Referrer(_planId);
        users[_user].x2Pools[_planId].currentReferrer = free3xReferrer;
        updateX3Referrer(_user, free3xReferrer, _planId);

        // Level Income
        address freeReferrer = findFreeX2Referrer(_planId);
        users[_user].x2Pools[_planId].currentReferrer = freeReferrer;
        updateX2Referrer(_user, freeReferrer, _planId);
        // emit UpgradePackage(_user ,  _planId);

        emit levelBuyEv( _user, _planId,  _package[_planId], block.timestamp);
    }

    function registration(address _userAddress, address _referrerAddress ) private {
        require(isUserExists(_referrerAddress), "Referrer not exists");
        lastUserId++;

        uint32 size;

        assembly {
            size := extcodesize(_userAddress)
        }
        require(size == 0, "cannot be a contract");

        idToAddress[lastUserId] = _userAddress;

        users[_userAddress].id = lastUserId;
        users[_userAddress].referrer = _referrerAddress;
        users[_userAddress].partnersCount = 0;
      
     
        users[_referrerAddress].partnersCount++;

        // emit Registration(_userAddress, _referrerAddress, users[_userAddress].id, users[_referrerAddress].id , _planId);
        emit regLevelEv( _userAddress,  users[_userAddress].id, users[_referrerAddress].id, block.timestamp, _referrerAddress);
    }

    function findFreeReferrer(address _user, uint8 _planId) public view returns (address) {
        if (users[_user].x2Levels[_planId].referrals.length < 2) return _user;

        address[] memory referrals = new address[](1022);          
        referrals[0] = users[_user].x2Levels[_planId].referrals[0];
        referrals[1] = users[_user].x2Levels[_planId].referrals[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 1022; i++) {
            if (users[referrals[i]].x2Levels[_planId].referrals.length == 2) {
                if (i < 62) {
                    referrals[(i + 1) * 2] = users[referrals[i]]
                        .x2Levels[_planId]
                        .referrals[0];
                    referrals[(i + 1) * 2 + 1] = users[referrals[i]]
                        .x2Levels[_planId]
                        .referrals[1];
                }
            } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, "No Free Referrer");

        return freeReferrer;
    }

    function updateX2Referrer(address userAddress, address referrerAddress, uint8 _planId) private {
        if(referrerAddress==userAddress) return;

        uint256 newIndex = x2Index[_planId]+1;
        x2vId_number[_planId][newIndex] = userAddress;
        x2Index[_planId] = newIndex;

        if(users[referrerAddress].x2Pools[_planId].referrals.length < 2) {
          users[referrerAddress].x2Pools[_planId].referrals.push(userAddress);
          emit NewUserPlace(userAddress, referrerAddress, 2, _planId, uint8(users[referrerAddress].x2Pools[_planId].referrals.length));
          address reffer =  users[userAddress].x2Pools[_planId].currentReferrer;
          for(uint i=0;i<12;i++) {
              if(reffer!=address(0)) {
                users[reffer].levelIncome += (_package[_planId]*30/100)/12;
                busdToken.transfer(reffer,(_package[_planId]*30/100)/12);
                // emit UserIncome(userAddress , reffer ,(_package[_planId]*30/100)/12,"LevelIncome");
                emit paidForLevelEv(userAddress, reffer, i+1,  (_package[_planId]*30/100)/12, block.timestamp);
                reffer = users[reffer].x2Pools[_planId].currentReferrer;
                if(reffer==address(0)) break;
              }
             
          }

        }
        if(users[referrerAddress].x2Pools[_planId].referrals.length==2) {
              x2CurrentvId[_planId]=x2CurrentvId[_planId]+1;  
        }
    }

    function updateX3Referrer(address userAddress, address referrerAddress, uint8 _planId) private {
        if(referrerAddress==userAddress) return;

        uint256 newIndex = x3Index[_planId]+1;
        x3vId_number[_planId][newIndex] = userAddress;
        x3Index[_planId] = newIndex;

        if(users[referrerAddress].x2Levels[_planId].referrals.length < 2){
            users[referrerAddress].x2Levels[_planId].referrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 1, _planId, users[referrerAddress].x2Levels[_planId].referrals.length);
        }

        address l2referrer =  users[referrerAddress].x2Levels[_planId].currentReferrer;

        if(l2referrer!=address(0) && users[l2referrer].x2Levels[_planId].referrals.length==2) {
            if(users[l2referrer].x2Levels[_planId].referrals[1]==referrerAddress) {
                if(users[referrerAddress].x2Levels[_planId].referrals.length==2) {
                   address _refferal = users[l2referrer].x2Levels[_planId].currentReferrer;
                   for (uint i=1;i<=2;i++ ) {
                       if(_refferal!= address(0)) {
                        users[_refferal].swIncome += (_package[_planId]*25/100);
                        busdToken.transfer(_refferal,(_package[_planId]*25/100));
                        emit UserIncome(userAddress , _refferal ,(_package[_planId]*25/100),"SWIncome_r");
                        _refferal = users[_refferal].x2Levels[_planId].currentReferrer;
                        if(_refferal==address(0)) break;
                       }
                   }

                }
            } else {
                users[l2referrer].swIncome += (_package[_planId]*25/100);
                busdToken.transfer(l2referrer,(_package[_planId]*25/100));
                emit UserIncome(userAddress,l2referrer,(_package[_planId]*25/100), "SWLevel");
            }
        }

        if(users[referrerAddress].x2Levels[_planId].referrals.length==2) {
              x3CurrentvId[_planId]=x3CurrentvId[_planId]+1;  
        }
    }

    function findFreeX3Referrer(uint8 _planId) public view returns(address){
        uint256 id=x3CurrentvId[_planId];
        return x3vId_number[_planId][id];
    }

    function updateSWReferrer(address userAddress, address referrerAddress, uint8 _planId) private {
        if(referrerAddress==userAddress) return;

        if(users[referrerAddress].x2Levels[_planId].referrals.length < 2){
            users[referrerAddress].x2Levels[_planId].referrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 1, _planId, users[referrerAddress].x2Levels[_planId].referrals.length);
        }

        address l2referrer =  users[referrerAddress].x2Levels[_planId].currentReferrer;

        if(l2referrer!=address(0) && users[l2referrer].x2Levels[_planId].referrals.length==2) {
            if(users[l2referrer].x2Levels[_planId].referrals[1]==referrerAddress) {
                if(users[referrerAddress].x2Levels[_planId].referrals.length==2) {
                   address _refferal = users[l2referrer].x2Levels[_planId].currentReferrer;
                   for (uint i=1;i<=2;i++ ) {
                       if(_refferal!= address(0)) {
                        users[_refferal].swIncome += (_package[_planId]*25/100);
                        busdToken.transfer(_refferal,(_package[_planId]*25/100));
                        emit UserIncome(userAddress , _refferal ,(_package[_planId]*25/100),"SWIncome_r");
                        _refferal = users[_refferal].x2Levels[_planId].currentReferrer;
                        if(_refferal==address(0)) break;
                       }
                   }

                }
            } else {
                busdToken.transfer(l2referrer,(_package[_planId]*25/100));
                users[l2referrer].swIncome += (_package[_planId]*25/100);
                emit UserIncome(userAddress,l2referrer,(_package[_planId]*25/100), "SWLevel");
            }
        }
    }

    function findFreeX2Referrer(uint8 _planId) public view returns(address){
        uint256 id=x2CurrentvId[_planId];
        return x2vId_number[_planId][id];
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function usersX2Levels(address userAddress, uint8 level) public view returns(address, address[] memory) {
        return (users[userAddress].x2Levels[level].currentReferrer , users[userAddress].x2Levels[level].referrals);
    }

    function usersX2Pools(address userAddress, uint8 level) public view returns(address, address[] memory) {
        return (users[userAddress].x2Pools[level].currentReferrer , users[userAddress].x2Pools[level].referrals);
    }

    function withdrawToken(address _token , address _to, uint _amount) external onlyOwner {
        IERC20(_token).transfer(_to,_amount);
    }

    function withdraw(address _to, uint _amount) external onlyOwner {
        payable(_to).transfer(_amount);
    }

    function withdrawClubIncome(address _user) external {
        if(!isUserExists(_user)) revert("User not Exist");
        if(users[_user].clubIncome<=0) revert("ClubIncome is Zero");
        uint _club = users[_user].clubIncome;
        busdToken.transfer(_user, _club);
        users[_user].clubIncome=0;
        emit WithdrawClub(_user , _club);
    }

    function checkQualificationforClub(address _user) public view returns (bool result){
            if(users[_user].activePlans[1])
                if(users[_user].activePlans[2]) 
                    if(users[_user].activePlans[2])
                        if(users[_user].activePlans[3])
                            if(users[_user].activePlans[4])
                                if(users[_user].activePlans[5])
                                    if(users[_user].activePlans[6])
                                        result=true;
       
    }

    function sendClubIncome() external onlyOperator {
        for(uint i=0;i< clubMembers.length; i++) {
            users[clubMembers[i]].clubIncome += (globalClub/clubMembers.length);
            emit ClubIncome(clubMembers[i], (globalClub/clubMembers.length));
        }
        globalClub=0;
    }

    function changeOperatorWallet(address _newOperator) external  onlyOwner {
        operator =_newOperator;
    }
    
}
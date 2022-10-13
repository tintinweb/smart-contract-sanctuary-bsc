/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-12
*/

pragma solidity 0.6.0; 

//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
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

contract tiger_boost is owned {

    // Replace below address with main token token
    address public tokenAddress;

    uint public maxDownLimit = 2;
    uint public lastIDCount = 0;
    uint public joiningFee = 21 * (10 ** 18);
    uint public reJoinFee = 14 * (10 ** 18);
    //uint nextJoinWait = 2 days;
    //uint nextReJoinWait = 3 hours;
    uint nextJoinWait = 1 hours;
    uint nextReJoinWait = 1 hours / 2;

    uint public royaltee;


    mapping(address => uint) public nextJoinPending;
    mapping(address => uint) public nextReJoinPending;
    mapping(address => uint) public lastJoinTime;
    mapping(address => uint) public lastReJoinTime;

    uint[5] public nextMemberFillIndex;  
    uint[5] public nextMemberFillBox;   


    struct userInfo {
        bool joined;
        uint id;
        uint parent;
        uint referrerID;
        address[] referral;
    }


    mapping(address => userInfo[5]) public userInfos;


    //userID => _level => address
    mapping(uint => mapping(uint => address)) public userAddressByID;
  
    function init() public onlyOwner returns(bool){
        require(lastIDCount==0, "can be called only once");
        userInfo memory temp;
        lastIDCount++;

        temp.joined = true;
        temp.id = 1;
        temp.parent = 1;
        temp.referrerID = 1;


        userInfos[owner][0] = temp;
        userAddressByID[1][0] = owner;

        for(uint i=1;i<5;i++)
        {
            userInfos[owner][i] = temp;
            userInfos[owner][i].referral.push(owner);
            userAddressByID[1][i] = owner;
        }

    }

    function setTokenAddress(address _tokenAddress) public onlyOwner returns(bool)
    {
        tokenAddress = _tokenAddress;
        return true;
    }


    function regUser(uint _referrerID ) public returns(bool) 
    {
        require(msg.sender == tx.origin, "contract can't call");
        require(!userInfos[msg.sender][0].joined, "already joined");
        require(_referrerID <= lastIDCount, "Invalid ref id");
        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), joiningFee);
        userInfo memory temp;
        lastIDCount++;
        temp.joined = true;
        temp.id = lastIDCount;
        temp.parent = findFreeReferrer(0);
        temp.referrerID = _referrerID;

        userInfos[msg.sender][0] = temp;
        userAddressByID[temp.id][0] = msg.sender;

        userInfos[userAddressByID[temp.parent][0]][0].referral.push(msg.sender);

        lastJoinTime[msg.sender] = now;
        nextJoinPending[msg.sender] = 2;
        
        
        if(userInfos[userAddressByID[temp.parent][0]][0].referral.length == 2) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }
        return true;
    }


    function enterMore() public returns(bool){
        require(lastReJoinTime[msg.sender] + nextReJoinWait <= now, "please wait little more");
        require(userInfos[msg.sender][0].joined, "register first");

        tokenInterface(tokenAddress).transferFrom(msg.sender, address(this), reJoinFee);

        require(userInfos[msg.sender][0].joined, "address used already");

        nextJoinPending[msg.sender]++;
        userInfo memory temp;
        lastIDCount++;
        temp.joined = true;
        temp.id = lastIDCount;
        uint _referrerID = userInfos[msg.sender][0].referrerID;
        temp.parent = findFreeReferrer(0);
        temp.referrerID = _referrerID;

        userInfos[msg.sender][0] = temp;
        userAddressByID[temp.id][0] = msg.sender;

        userInfos[userAddressByID[temp.parent][0]][0].referral.push(msg.sender);

        lastReJoinTime[msg.sender] = now;
                

        if(userInfos[userAddressByID[temp.parent][0]][0].referral.length == 2) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }
        return true;
    }

    function joinNext() public returns(bool){
        require(userInfos[msg.sender][0].joined, "register first");
        require(userInfos[msg.sender][0].joined, "address used already");
        require(nextJoinPending[msg.sender] > 0, "no pending next join");
        require(lastJoinTime[msg.sender] + nextJoinWait <= now, "please wait little more");
        nextJoinPending[msg.sender]--;
        userInfo memory temp;
        lastIDCount++;
        temp.joined = true;
        temp.id = lastIDCount;
        uint _referrerID = userInfos[msg.sender][0].referrerID;
        temp.parent = findFreeReferrer(0);
        temp.referrerID = _referrerID;

        userInfos[msg.sender][0] = temp;
        userAddressByID[temp.id][0] = msg.sender;

        userInfos[userAddressByID[temp.parent][0]][0].referral.push(msg.sender);

        lastJoinTime[msg.sender] = now;
        
                
        
        if(userInfos[userAddressByID[temp.parent][0]][0].referral.length == 2) 
        {
            payForLevel(temp.parent, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }
        return true;
    }

/*
    function reJoinNext(address _newAddress) public returns(bool){
        require(userInfos[msg.sender][0].joined, "register first");
        require(userInfos[_newAddress][0].joined, "address used already");
        require(nextReJoinPending[msg.sender] > 0, "no pending next join");
        
        nextReJoinPending[msg.sender]--;
        userInfo memory temp;
        lastIDCount++;
        temp.id = lastIDCount;
        uint _referrerID = userInfos[msg.sender][0].referrerID;
        temp.parent = findFreeReferrer(userAddressByID[_referrerID][0],0);
        temp.referrerID = _referrerID;

        userInfos[_newAddress][0] = temp;
        userAddressByID[temp.id][0] = _newAddress;

        userInfos[userAddressByID[temp.parent][0]][0].referral.push(msg.sender);

        lastReJoinTime[msg.sender] = now;
        
                

        if(userInfos[userAddressByID[temp.parent][0]][0].referral.length == 2) 
        {
            payForLevel(_referrerID, 0);
            buyLevel(userAddressByID[temp.parent][0], 1);
        }

        return true;
    }
*/
    function buyLevel(address _user, uint _level) internal returns(bool)
    {
        userInfo memory temp = userInfos[_user][0];

        temp.parent = findFreeReferrer(_level);
 

        userInfos[_user][_level] = temp;
        userAddressByID[temp.id][_level] = _user;

        address parentAddress = userAddressByID[temp.parent][_level];

        userInfos[parentAddress][_level].referral.push(_user); 


        if(userInfos[parentAddress][0].referral.length == 2 )
        {
            payForLevel(temp.referrerID, _level);
            if(_level< 4 ) buyLevel(parentAddress, _level + 1);
            if(_level == 3 ) buyLevel(parentAddress, 2);
            if(_level == 4 ) buyLevel(parentAddress, 1);
            nextJoinPending[parentAddress]++;
        }

        return true;
    }


    function payForLevel(uint _pID, uint _level) internal returns (bool){
        address _user = userAddressByID[_pID][_level];
        if(_level == 0) 
        {
            tokenInterface(tokenAddress).transfer(_user,2 * (10 ** 18));
            _user = userAddressByID[userInfos[_user][_level].referrerID][_level];
            tokenInterface(tokenAddress).transfer(_user,2 * (10 ** 18));
        }
        else if(_level == 1)
        {
            tokenInterface(tokenAddress).transfer(_user, 3 * (10 ** 18));
            _user = userAddressByID[userInfos[_user][_level].referrerID][_level];
            tokenInterface(tokenAddress).transfer(_user, 2 * (10 ** 18));            
        }
        else if(_level == 2)
        {
            tokenInterface(tokenAddress).transfer(_user, 4 * (10 ** 18));
            _user = userAddressByID[userInfos[_user][_level].referrerID][_level];
            tokenInterface(tokenAddress).transfer(_user,2 * (10 ** 18));            
        }
        else if(_level == 3)
        {
            tokenInterface(tokenAddress).transfer(_user, 5 * (10 ** 18));
            _user = userAddressByID[userInfos[_user][_level].referrerID][_level];
            tokenInterface(tokenAddress).transfer(_user, 2 *  (10 ** 18));
            royaltee += 1 * (10 ** 18) ;            
        }  
        else if(_level == 4)
        {
            tokenInterface(tokenAddress).transfer(_user, 25 * (10 ** 18));
            _user = userAddressByID[userInfos[_user][_level].referrerID][_level];
            tokenInterface(tokenAddress).transfer(_user,2 *  (10 ** 18));
            _user = userAddressByID[userInfos[_user][_level].referrerID][_level];
            tokenInterface(tokenAddress).transfer(_user, 1 * (10 ** 18)); 
            _user = userAddressByID[userInfos[_user][_level].referrerID][_level];
            tokenInterface(tokenAddress).transfer(_user, 1 * (10 ** 18));                        
            royaltee += 2 * (10 ** 18) ;            
        }                
        return true;

    }

/*
    function findFreeReferrer(address _user, uint _level) public view returns(uint) {
        if(userInfos[_user][_level].referral.length < maxDownLimit) return userInfos[_user][_level].id;

        address[] memory referrals = new address[](126);
        referrals[0] = userInfos[_user][_level].referral[0];
        referrals[1] = userInfos[_user][_level].referral[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 126; i++) {
            if(userInfos[referrals[i]][_level].referral.length == maxDownLimit) {
                if(i < 62) {
                    referrals[(i+1)*2] = userInfos[referrals[i]][_level].referral[0];
                    referrals[(i+1)*2+1] = userInfos[referrals[i]][_level].referral[1];
                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return userInfos[freeReferrer][_level].id;
    }
*/

    function findFreeReferrer(uint _level) internal returns(uint) {

        uint currentID = nextMemberFillIndex[_level];

        if(nextMemberFillBox[_level] == 0)
        {
            nextMemberFillBox[_level] = 1;
        }   
        else
        {
            nextMemberFillIndex[_level]++;
            nextMemberFillBox[_level] = 0;
        }
        return currentID+1;
    }



    function releaseRoyalty(uint _amount) public onlyOwner returns(bool)
    {
        require(_amount <= royaltee, "not enough amount");
        address(uint160(owner)).transfer(_amount);
        royaltee -= _amount;
        return true;
    }
}
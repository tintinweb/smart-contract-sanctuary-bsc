/**
 *Submitted for verification at BscScan.com on 2021-04-16
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.5.10;
import "./SafeMath.sol";
contract Demo{
	using SafeMath for uint256;

	struct User {
        uint id;
        address referrer;
        uint partnersCount;
       mapping(uint8 => Referu) referUser;
        bool isQualifyBdm;
        uint qualifyBdmDate;
        bool isQualifyBdo;
        uint qualifyBdoDate;
        bool isQualifyGm;
        uint qualifyGmDate;
        uint plan;
        mapping(uint => uint256) planDate;
        uint directClubIncome;
        uint poolUpgradelevelIncome;
    }
    
    struct Referu {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
        uint partnersCount;
        
    }
    uint[] plan=[0.39e18,0.8e18,1.6e18,3.2e18,6.4e18,12.8e18];
    uint8[] clubMemberRequired=[4,8,16];
    uint8 public LAST_LEVEL;
    uint public lastUserId;
     mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
     uint256[] public levelPrice=[5e18,2e18,1e18,0.75e18,0.5e18,0.25e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18];
    mapping(address => User) public users;
    uint[3] public directClubRes=[0,0,0];
    uint[3] public directClubResLastDate=[0,0,0];
    address[] public userDirectType1;
    address[] public userDirectType2;
    address[] public userDirectType3;
    uint[] public upgradePoolLevelPercent=[60,30,20,10,5];
    struct Node {
        uint value;
        uint left;
        uint right;
        uint recycle;
    }
    mapping (uint => Node) public tree;
   
    uint private rootAddress;
	constructor() public {
		LAST_LEVEL = 16;

    User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0),
            isQualifyBdm: false,
            qualifyBdmDate: 0,
            isQualifyBdo :false,
            qualifyBdoDate : 0,
            isQualifyGm : false,
            qualifyGmDate : 0,
            plan:0,
            directClubIncome:0,
            poolUpgradelevelIncome:0
            
       });
        
        users[msg.sender] = user;
        idToAddress[1] = msg.sender;
        userIds[1] = msg.sender;
        insert(1);
        lastUserId = 2;
        
  	}
	
	  function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    } 
function insert(uint256 value) public {
        Node memory root = tree[rootAddress];
        // if the tree is empty
        if (root.value == 0) {
            root.value = value;
            root.left = 0;
            root.right = 0;
            tree[0] = root;
            rootAddress = 1;
            tree[rootAddress] = root;
        } else {
            // if the tree is not empty
            // find the correct place to insert the value
            insertHelper(value, rootAddress);
        }
    }
    function insertNode(uint256 value, uint nodeAddress, uint256 location) internal {
        Node memory parentNode = tree[nodeAddress];
        uint nodeId = lastUserId;
        if (location == 0) {
            // if the value is less than the current node
            parentNode.left = nodeId;
        } else {
            // if the value is greater than the current node
            parentNode.right = nodeId;
        }

        // update the tree
        tree[nodeAddress] = parentNode;
        tree[nodeId] = Node(value, 0, 0,0);
    }
   function insertHelper(uint value, uint nodeAddress) internal {
        Node memory node = tree[nodeAddress];
       
            if (node.left == 0) {
                insertNode(value, nodeAddress, 0);
            } else if(node.right == 0) {
                insertNode(value, nodeAddress, 1);
                if(tree[nodeAddress].recycle==0){
                insertHelper(node.value, node.left);
                tree[nodeAddress].recycle=tree[nodeAddress].recycle+1;
                }
                else if(tree[nodeAddress].recycle==1){
                insertHelper(node.left, node.right);
                 tree[node.left].recycle=tree[node.left].recycle+1;
                }

                
            }else{
             insertHelper(value, node.left);
            }
        
    }
	 function invest(address referrer) public payable {
		require(!isUserExists(msg.sender), "user exists");
        require(isUserExists(referrer), "referrer not exists");
        address userAddress=msg.sender;
        User memory user = User({
            id: lastUserId,
            referrer: referrer,
            partnersCount: 0,
            isQualifyBdm: false,
            qualifyBdmDate: 0,
            isQualifyBdo :false,
            qualifyBdoDate : 0,
            isQualifyGm : false,
            qualifyGmDate : 0,
            plan:0,
            directClubIncome:0,
            poolUpgradelevelIncome:0
        });
        insert(lastUserId);
        directClubRes[0]=directClubRes[0]+1e18;
        directClubRes[1]=directClubRes[1]+1e18;
        directClubRes[2]=directClubRes[2]+1.5e18;
        users[userAddress] = user;
        users[userAddress].planDate[0]=block.timestamp;
        idToAddress[lastUserId] = userAddress;
        userIds[lastUserId] = userAddress;
        lastUserId++;
        users[userAddress].referrer = referrer;
        users[referrer].partnersCount++;
        address upline = user.referrer;
        updateDirectUser(referrer);
        for (uint8 i = 0; i < LAST_LEVEL; i++) {
				if (upline != address(0)) {
		users[upline].referUser[i].currentReferrer=userAddress;
        users[upline].referUser[i].referrals.push(userAddress);
        users[upline].referUser[i].partnersCount++;
        upline = users[upline].referrer;

				} else break;
			}
       
    }
    function buyPool() public payable{
     User memory user = users[msg.sender];
     uint value = msg.value;
     require(value==plan[user.plan+1],"Please enter amount according to plan");
     user.plan = user.plan+1;
     users[msg.sender].planDate[user.plan]=block.timestamp;
     updateDirectUser(msg.sender);
      address upline = user.referrer;
        
        for (uint8 i = 0; i < 5; i++) {
				if (upline != address(0)) {
		users[upline].poolUpgradelevelIncome=users[upline].poolUpgradelevelIncome+value*upgradePoolLevelPercent[i]/100;
        
        upline = users[upline].referrer;

				} else break;
			}
    }
function getUserLevels(address userAddress,uint8 level) public view returns(address currentReferrer, address[] memory referUser,uint256 partnersCount,uint256 levelIncome) {
        require(level<LAST_LEVEL, "Level can not be greater than last level");
		return (users[userAddress].referUser[level].currentReferrer,users[userAddress].referUser[level].referrals,users[userAddress].referUser[level].partnersCount,users[userAddress].referUser[level].partnersCount*levelPrice[level]);
	}
    function getUserDirectClubStatus(address userAddress,uint8 level) public view returns(bool isQualifyBdm,uint qualifyBdmDate,bool isQualifyBdo,uint qualifyBdoDate,bool isQualifyGm,uint qualifyGmDate) {
        require(level<LAST_LEVEL, "Level can not be greater than last level");
		return (users[userAddress].isQualifyBdm,users[userAddress].qualifyBdmDate,users[userAddress].isQualifyBdo,users[userAddress].qualifyBdoDate,users[userAddress].isQualifyGm,users[userAddress].qualifyGmDate);
	}
function updateDirectUser(address referrer) internal{
  if(users[referrer].partnersCount>=clubMemberRequired[0]&&users[referrer].plan==1&&users[referrer].isQualifyBdm==false){
           users[referrer].isQualifyBdm = true;
           users[referrer].qualifyBdmDate=block.timestamp;
           userDirectType1.push(referrer);
        }
        if(users[referrer].partnersCount>=clubMemberRequired[1]&&users[referrer].plan==2&&users[referrer].isQualifyBdo==false){
           users[referrer].isQualifyBdo = true;
           users[referrer].qualifyBdoDate=block.timestamp;
           userDirectType2.push(referrer);
        }
        if(users[referrer].partnersCount>=clubMemberRequired[2]&&users[referrer].plan==3&&users[referrer].isQualifyGm==false){
           users[referrer].isQualifyGm = true;
           users[referrer].qualifyGmDate=block.timestamp;
           userDirectType3.push(referrer);
        }
}
 function closeDirectClub(uint8 typev) public onlyContractOwner{
if(typev==0&&userDirectType1.length>0){
uint peruserDistribution=directClubRes[0]/userDirectType1.length;    
if(peruserDistribution>0){
for(uint i=0;i<userDirectType1.length;i++){
users[userDirectType1[i]].directClubIncome=users[userDirectType1[i]].directClubIncome+peruserDistribution;
}
directClubRes[0]=0;
directClubResLastDate[0]=block.timestamp;
}
}
if(typev==1&&userDirectType2.length>0){
uint peruserDistribution=directClubRes[1]/userDirectType2.length;    
if(peruserDistribution>0){
for(uint i=0;i<userDirectType2.length;i++){
users[userDirectType2[i]].directClubIncome=users[userDirectType2[i]].directClubIncome+peruserDistribution;
}
directClubRes[1]=0;
directClubResLastDate[1]=block.timestamp;
}
}
if(typev==2&&userDirectType3.length>0){
uint peruserDistribution=directClubRes[2]/userDirectType3.length;    
if(peruserDistribution>0){
for(uint i=0;i<userDirectType3.length;i++){
users[userDirectType3[i]].directClubIncome=users[userDirectType3[i]].directClubIncome+peruserDistribution;
}
directClubRes[2]=0;
directClubResLastDate[2]=block.timestamp;
}
}
 }


modifier onlyContractOwner() { 
        require(msg.sender == idToAddress[1]); 
        _; 
    }
}
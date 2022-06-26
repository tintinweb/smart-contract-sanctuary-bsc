/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

pragma solidity 0.5.4;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Test {
     using SafeMath for uint256;
  
     
    struct User {
        uint256 id;
        address referrer;
        mapping(uint8 => bool) levelActive;
        mapping(uint8 => uint256) withdrawable;
    }

    mapping(address => address[]) public referrals;

    mapping(uint8 => uint256) public globalCount;
    mapping(uint8 => mapping(uint256 => address)) public globalIndex;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    mapping(uint8 => uint256) public levelPrice;

    uint256[] public REFERRAL_PERCENTS = [400, 50, 50, 50, 50];
    uint256 public communityPercent=50;
    uint256 public lastUserId = 2; 
    
    uint256 public  total_withdraw;

    IBEP20 BUSD;

    address public owner; 
    
    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
    event Withdraw(address user, uint256 amount,uint8 level);
    event ReferralReward(address  _user, address _from, uint256 reward, uint8 level, uint8 sublevel);
    event CommunityReward(address  _user, address _from, uint256 reward, uint8 level, uint8 sublevel);
    event BuyNewLevel(address  _user, uint8 _level);
        

    constructor(address ownerAddress, IBEP20 _BUSD) public 
    {
        owner = ownerAddress;
        BUSD = _BUSD;
        User memory user = User({
            id: 1,
            referrer: address(0)            
        });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;

        for(uint8 i=1; i<13; i++){
            globalCount[i]=1;
            globalIndex[i][1]=ownerAddress;
        }

        levelPrice[1]=10e18;
        levelPrice[2]=20e18;
        levelPrice[3]=40e18;
        levelPrice[4]=80e18;
        levelPrice[5]=150e18;
        levelPrice[6]=300e18;
        levelPrice[7]=600e18;
        levelPrice[8]=1200e18;
        levelPrice[9]=2500e18;
        levelPrice[10]=5000e18;
        levelPrice[11]=10000e18;
        levelPrice[12]=20000e18;
    } 
    

    function withdrawBalance(uint256 amt) public 
    {
        require(msg.sender == owner, "onlyOwner!");
        msg.sender.transfer(amt);
    }  

     function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }  
  
    function registration(address userAddress, address referrerAddress) private 
    {
        require(!isUserExists(userAddress), "user exists!");
        require(isUserExists(referrerAddress), "referrer not exists!");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract!");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        users[userAddress].levelActive[1]=true;
        referrals[referrerAddress].push(userAddress);

        BUSD.transferFrom(msg.sender,address(this),levelPrice[1]);

        address upline=referrerAddress;
        for(uint8 i=0; i<5; i++)
        {
            uint256 reward=(levelPrice[1].mul(REFERRAL_PERCENTS[i])).div(1000);
            users[upline].withdrawable[1]+=reward;
            emit ReferralReward(upline, msg.sender, reward, 1, i+1);
            if(users[upline].withdrawable[1]>=100e18)
            autoWithdraw(upline,1);
            upline=users[upline].referrer;
            if(upline==address(0))
            break;
        }

        uint256 globalId=lastUserId-1;
        for(uint8 j=1; j<=8; j++)
        {
            uint256 reward=(levelPrice[1].mul(communityPercent)).div(1000);
            users[idToAddress[globalId]].withdrawable[1]+=reward;
            emit CommunityReward(idToAddress[globalId], msg.sender, reward, 1, j); 
            if(users[idToAddress[globalId]].withdrawable[1]>=100e18)
            autoWithdraw(globalIndex[1][globalId],1);          
            globalId--;
            if(globalId==0)
            break;
        }

        lastUserId++;
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }

    function buyLevel(uint8 level) private 
    {
        require(isUserExists(msg.sender), "user exists!");
        require(level<13, "Max 12 Level!");  
        require(users[msg.sender].levelActive[level-1],"Buy Previous Level First!");
        BUSD.transferFrom(msg.sender,address(this),levelPrice[level]);
        users[msg.sender].levelActive[level]=true;
        globalCount[level]=globalCount[level]+1;
        globalIndex[level][globalCount[level]]=msg.sender;
        address upline=users[msg.sender].referrer;
        for(uint8 i=0; i<5;)
        {
            if(users[upline].levelActive[level])
            {
                uint256 reward=(levelPrice[level].mul(REFERRAL_PERCENTS[i])).div(1000);
                users[upline].withdrawable[level]+=reward;
                emit ReferralReward(upline, msg.sender, reward, level, i+1);
                if(users[upline].withdrawable[level]>=100e18)
                autoWithdraw(upline,level);
                i++;
            }
            upline=users[upline].referrer;
            if(upline==address(0))
            break;
        }

        uint256 globalId=globalCount[level]-1;
        for(uint8 j=1; j<=8;)
        {
            if(users[globalIndex[level][globalId]].levelActive[level])
            {
                uint256 reward=(levelPrice[level].mul(communityPercent)).div(1000);
                users[globalIndex[level][globalId]].withdrawable[level]+=reward;
                emit CommunityReward(globalIndex[level][globalId], msg.sender, reward, level, j); 
                if(users[idToAddress[globalId]].withdrawable[1]>=100e18)
                autoWithdraw(globalIndex[level][globalId],level); 
                j++;         
            }
            globalId--;
            if(globalId==0)
            break;
        }
        
        emit BuyNewLevel(msg.sender,level);
    }  

    function withdraw(uint8 level) public{
        require(isUserExists(msg.sender),"User Not Exist!");
        require(users[msg.sender].withdrawable[level]>0,"Insufficient Balance!");
        uint256 payableAmount = users[msg.sender].withdrawable[level]/2;
        BUSD.transfer(msg.sender,payableAmount);
        reInvest(msg.sender, payableAmount, level);
        emit Withdraw(msg.sender, users[msg.sender].withdrawable[level], level);
        users[msg.sender].withdrawable[level]=0;
    }

     function autoWithdraw(address _user,uint8 level) public{
        uint256 payableAmount = users[_user].withdrawable[level]/2;
        BUSD.transfer(_user,payableAmount);
        reInvest(_user, payableAmount, level);
        emit Withdraw(_user, users[_user].withdrawable[level], level);
        users[_user].withdrawable[level]=0;
    }    

    function reInvest(address _user, uint256 investAmount, uint8 level) private {
         address upline=users[_user].referrer;
        for(uint8 i=0; i<5;)
        {
            if(users[upline].levelActive[level])
            {
                uint256 reward=(investAmount.mul(REFERRAL_PERCENTS[i])).div(1000);
                users[upline].withdrawable[level]+=reward;
                emit ReferralReward(upline, msg.sender, reward, level, i+1);
                if(users[upline].withdrawable[level]>=100e18)
                autoWithdraw(upline,level);
                i++;
            }
            upline=users[upline].referrer;
            if(upline==address(0))
            break;
        }

        uint256 globalId=globalCount[level]-1;
        for(uint8 j=1; j<=8;)
        {
            if(users[globalIndex[level][globalId]].levelActive[level])
            {
                uint256 reward=(investAmount.mul(communityPercent)).div(1000);
                users[globalIndex[level][globalId]].withdrawable[level]+=reward;
                emit CommunityReward(globalIndex[level][globalId], msg.sender, reward, level, j); 
                if(users[globalIndex[level][globalId]].withdrawable[level]>=100e18)
                autoWithdraw(globalIndex[level][globalId],level);
                j++;
            }          
            globalId--;
            if(globalId==0)
            break;
        }
    }
   
   
    function isContract(address _address) public view returns (bool _isContract)
    {
          uint32 size;
          assembly {
            size := extcodesize(_address)
          }
          return (size > 0);
    }   
 
    
    function isUserExists(address user) public view returns (bool) 
    {
        return (users[user].id != 0);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}
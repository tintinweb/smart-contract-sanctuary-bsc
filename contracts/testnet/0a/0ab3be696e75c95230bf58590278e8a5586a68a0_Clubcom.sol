/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

pragma solidity 0.5.9;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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

contract Ownable {
    address public owner;
    address public ownerWallet;

    modifier onlyOwner() {
        require(msg.sender == owner, "only for owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

interface ITRC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);


    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
    function withDrawUSDT()external returns(address,bool,uint256);

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
}

contract Clubcom is Ownable {
    using SafeMath for uint256;

    ITRC20 public usdtAddress;
    ITRC20 public rewardToken;

    event Withdraw_USDT(address indexed from, bool result, uint256 amount);
    event Withdraw_CLUX(address indexed from, bool result, uint256 amount);
    event AirdropAdd(uint256 airid,address indexed reward,uint256 startTimestamp);
    event AirdropDistribute(uint256 airid,address indexed reward);

    struct User {
        bool isExist;
        uint id;
        uint referrerID;
        uint originalReferrer;
        uint directCount;
        uint256 gainUsdt;
        uint256 gainReward;
        uint256 rewardDebt;
        uint256 usdtDebt;
        uint256 joinedTimestamp;
        address[] referral;
        mapping(uint256 => Magicpool) magicpool;
        mapping(uint256 => Airdrop) balance;
    }


    struct Magicpool {
        bool isExist;
        uint id;
        uint256 usersCount;
        uint referrerID;
        uint originalReferrer;
        uint directCount;
        uint256 gainUsdt;
        uint256 UsdtDept;
        uint256 gainReward;
        uint256 RewardDebt;
        address[] referral;
    }

    struct Airdrop {
        bool isExist;
        uint id;
        uint256 totalreward;
        address rewardToken;
        uint256 startTimestamp;
    }

    mapping(address => User) public users;

    mapping(uint256 => Airdrop) airdrops;

    mapping (uint => address) public userAddressByID;

    mapping (uint => uint) public magicInc;

    mapping (uint => uint) public magicCurrentTop;

    mapping (uint => address) public magicCurrentTopAddress;

    mapping (address => uint) public userAddress;




    uint256 public activateAmount = 60000000000000000000;

    uint256 public maxDownLimit = 5;
    uint256 public maxDownLimitMagic = 3;

    uint8[] public ref_bonuses;
    uint[] public pool_bonuses;
    address[5][] userAddressMagic;
    uint256 public currUserID;
    uint256 public airdropID;
    uint256 public rewardAmount = 2;

    uint256 public maxrewardAmount = 500;

       constructor(ITRC20 _usdtAddress,address _ownerAddress,ITRC20 _rewardtoken) public {
         owner = _ownerAddress;
         usdtAddress = _usdtAddress;
         rewardToken = _rewardtoken;

            ref_bonuses.push(5);
            ref_bonuses.push(5);
            ref_bonuses.push(4);
            ref_bonuses.push(4);
            ref_bonuses.push(4);
            ref_bonuses.push(3);
            ref_bonuses.push(3);
            ref_bonuses.push(3);
            ref_bonuses.push(2);
            ref_bonuses.push(2);
            ref_bonuses.push(2);
            ref_bonuses.push(2);
            ref_bonuses.push(2);
            ref_bonuses.push(2);
            ref_bonuses.push(2);

            pool_bonuses.push(250);
            pool_bonuses.push(2500);
            pool_bonuses.push(25000);
            pool_bonuses.push(250000);
            pool_bonuses.push(2500000);

        currUserID++;

        User memory user;

        user = User({
            isExist : true,
            id : currUserID,
            referrerID: currUserID,
            originalReferrer: currUserID,
            directCount: 0,
            joinedTimestamp : block.timestamp,
            gainUsdt : 0,
            gainReward :0,
            rewardDebt : 0,
            usdtDebt : 0,
            referral : new address[](0)
        });
        users[owner] = user;
        userAddressByID[currUserID] = owner;
        userAddress[owner] = currUserID;
        magicInc[1]++;
        magicCurrentTop[1] = 1;
        users[owner].magicpool[1].isExist = true;
        users[owner].magicpool[1].id = currUserID;
        users[owner].magicpool[1].referrerID= currUserID;
        users[owner].magicpool[1].originalReferrer= currUserID;
        users[owner].magicpool[1].directCount= 0;
        users[owner].magicpool[1].gainUsdt = 0;
        users[owner].magicpool[1].gainReward =0;
        users[owner].magicpool[1].referral = new address[](0);
    }

     function activatePlan(address _referrer, uint256 amount) public {
        require(!users[msg.sender].isExist, 'User exist');
        uint _referrerID;

        if (users[_referrer].isExist){
            _referrerID = users[_referrer].id;
        }
        uint256 balanceOfowner = usdtAddress.balanceOf(msg.sender);
        require(balanceOfowner >= amount, "Insufficient Balance");
        usdtAddress.transferFrom(msg.sender, address(this), amount);
        uint originalReferrer = userAddress[_referrer];
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');
        if(users[userAddressByID[_referrerID]].referral.length >= maxDownLimit) _referrerID = users[findFreeReferrer(userAddressByID[_referrerID])].id;
          User memory user;
          currUserID++;
          user = User({
                isExist: true,
                id : currUserID,
                referrerID : _referrerID,
                originalReferrer : originalReferrer,
                directCount : 0,
                joinedTimestamp : block.timestamp,
                gainUsdt : 0,
                gainReward :0,
                rewardDebt : 0,
                usdtDebt : 0,
                referral : new address[](0)
            });
        users[msg.sender] = user;
        userAddressByID[currUserID] = msg.sender;
        userAddress[msg.sender] = currUserID;
        users[userAddressByID[_referrerID]].referral.push(msg.sender);
        users[userAddressByID[originalReferrer]].directCount++;
        payReferral(_referrerID,0);
        if(users[userAddressByID[_referrerID]].referral.length >=5 && _referrerID != 1) {
            magicInc[1]++;
            address magicpoolReferer = findFreeReferrerMagic(userAddressByID[1],1);
            users[userAddressByID[_referrerID]].magicpool[1].isExist = true;
            users[userAddressByID[_referrerID]].magicpool[1].id = _referrerID;
            users[userAddressByID[_referrerID]].magicpool[1].referrerID= userAddress[magicpoolReferer] ;
            users[userAddressByID[_referrerID]].magicpool[1].originalReferrer= users[userAddressByID[_referrerID]].originalReferrer;
            users[userAddressByID[_referrerID]].magicpool[1].directCount= 0;
            users[userAddressByID[_referrerID]].magicpool[1].gainUsdt = 0;
            users[userAddressByID[_referrerID]].magicpool[1].gainReward =0;
            users[userAddressByID[_referrerID]].magicpool[1].referral = new address[](0);
            users[magicpoolReferer].magicpool[1].referral.push(userAddressByID[_referrerID]);
            users[magicpoolReferer].magicpool[1].directCount++;
            payReferralForMagic(magicpoolReferer,1,1);
            pushChildMagic(1,magicpoolReferer,1);
        }
     }

     function withDrawUSDT(address _withaddress) public {
       uint256 usdtBal = usdtAddress.balanceOf(address(this));
       require(users[msg.sender].isExist, "User Not Exists");
       uint256 userBal =  users[msg.sender].gainUsdt;
       userBal = userBal.mul(1e18);
       require( userBal < usdtBal,"Contract doest contain enough balance");
       require( userBal > 0,"User doest contain enough balance to withdraw");
       bool transferSuccess = false;
       transferSuccess = usdtAddress.transfer(_withaddress, userBal);
       require(transferSuccess, "safeTransfer: Transfer failed");
       users[msg.sender].usdtDebt += users[msg.sender].gainUsdt;
       users[msg.sender].gainUsdt = 0;
       emit Withdraw_USDT(msg.sender, transferSuccess, userBal);
     }

     function withDrawClux(address _withaddress) public {
       uint256 cluxBal = rewardToken.balanceOf(address(this));
       require(users[msg.sender].isExist, "User Not Exists");
       uint256 userBal =  users[msg.sender].gainReward;
       userBal = userBal.mul(1e18);
       require( userBal < cluxBal,"Contract doest contain enough balance");
       require( userBal > 0,"User doest contain enough balance to withdraw");
       bool transferSuccess = false;
       transferSuccess = rewardToken.transfer(_withaddress, userBal);
       require(transferSuccess, "safeTransfer: Transfer failed");
       users[msg.sender].rewardDebt += users[msg.sender].gainReward;
       users[msg.sender].gainReward = 0;
       emit Withdraw_CLUX(msg.sender, transferSuccess, userBal);
     }
     
     function withDrawMagicUSDT(address _withaddress,uint _magic) public {
       uint256 usdtBal = usdtAddress.balanceOf(address(this));
       require(users[msg.sender].isExist, "User Not Exists");
       require(users[msg.sender].magicpool[_magic].isExist, "User Not Exists");
       uint256 userBal =  users[msg.sender].magicpool[_magic].gainUsdt;
       userBal = userBal.mul(1e18);
       require( userBal < usdtBal,"Contract doest contain enough balance");
       require( userBal > 0,"User doest contain enough balance to withdraw");
       bool transferSuccess = false;
       transferSuccess = usdtAddress.transfer(msg.sender, userBal);
       require(transferSuccess, "safeTransfer: Transfer failed");
       users[msg.sender].magicpool[_magic].UsdtDept += users[msg.sender].magicpool[_magic].gainUsdt;
       users[msg.sender].magicpool[_magic].gainUsdt = 0;
       emit Withdraw_USDT(msg.sender, transferSuccess, userBal);
     }

     function activateMagicPool(
        address _referAddress,uint magic
       ) internal {
            address magicpoolReferer = findFreeReferrerMagic(userAddressByID[1],magic);
            if(!users[_referAddress].magicpool[magic].isExist){
                users[_referAddress].magicpool[magic].isExist = true;
                users[_referAddress].magicpool[magic].id = userAddress[_referAddress];
                users[_referAddress].magicpool[magic].referrerID= userAddress[magicpoolReferer] ;
                users[_referAddress].magicpool[magic].originalReferrer= users[_referAddress].originalReferrer;
                users[_referAddress].magicpool[magic].directCount= 0;
                users[_referAddress].magicpool[magic].gainUsdt = 0;
                users[_referAddress].magicpool[magic].gainReward =0;
                users[_referAddress].magicpool[magic].referral = new address[](0);
                users[magicpoolReferer].magicpool[magic].referral.push(_referAddress);
                users[magicpoolReferer].magicpool[magic].directCount++;
                payReferralForMagic(magicpoolReferer,magic,1);
                pushChildMagic(magic,magicpoolReferer,1);
            }
       }

      function payReferral(
        uint _referrerID,
        uint inc
      ) internal {
        address referAddress = userAddressByID[_referrerID];
        if(users[referAddress].isExist){
            if(inc < 15){
                uint256 transferAmount = ref_bonuses[inc];
                users[referAddress].gainUsdt += transferAmount;
            }else{
                if(users[referAddress].gainReward <= maxrewardAmount){
                    users[referAddress].gainReward += 2;
                }
            }
            if(referAddress != owner){
                uint upliner =  users[referAddress].referrerID;
                inc++;
                payReferral(upliner,inc);
            }
         }
      }

       function pushChildMagic(
        uint magic,address _referreraddress,uint inc
       ) internal {
           users[_referreraddress].magicpool[magic].usersCount++;
            if(users[_referreraddress].magicpool[magic].usersCount > 120){
              activateMagicPool(_referreraddress,magic+1);
            }
           if(_referreraddress != owner){
                 uint referrerID =  users[_referreraddress].magicpool[magic].referrerID;
                 address upliner = userAddressByID[referrerID];
                 inc++;
                 pushChildMagic(magic,upliner,inc);
            }
       }

       function payReferralForMagic(
        address _referreraddress,
        uint magic,uint inc
      ) internal {
            uint256 transferAmount = pool_bonuses[magic]/100;
            // usdtAddress.transferFrom(msg.sender, _referreraddress, transferAmount);
             users[_referreraddress].magicpool[magic].gainUsdt += transferAmount;
            if(inc <=4 &&  _referreraddress != owner){
                 uint referrerID =  users[_referreraddress].magicpool[magic].referrerID;
                 address upliner = userAddressByID[referrerID];
                 inc++;
                 payReferralForMagic(upliner,magic,inc);
            }
      }

     function findFreeReferrer(address _user) public view returns(address) {
        if(users[_user].referral.length < maxDownLimit) return _user;
        address[] memory referrals = new address[](500);
        referrals[0] = users[_user].referral[0];
        referrals[1] = users[_user].referral[1];
        referrals[2] = users[_user].referral[2];
        referrals[3] = users[_user].referral[3];
        referrals[4] = users[_user].referral[4];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 600; i++) {
            if(users[referrals[i]].referral.length == maxDownLimit) {
                //if(i < 62) {
                    referrals[(i+1)*5] = users[referrals[i]].referral[0];
                    referrals[(i+1)*5+1] = users[referrals[i]].referral[1];
                    referrals[(i+1)*5+2] = users[referrals[i]].referral[2];
                    referrals[(i+1)*5+3] = users[referrals[i]].referral[3];
                    referrals[(i+1)*5+4] = users[referrals[i]].referral[4];
                //}
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }

    function findFreeReferrerMagic(address _user,uint magic) public view returns(address) {
        if(users[_user].magicpool[magic].referral.length < maxDownLimitMagic) return _user;
        address[] memory referrals = new address[](500);
        referrals[0] = users[_user].magicpool[magic].referral[0];
        referrals[1] = users[_user].magicpool[magic].referral[1];
        referrals[2] = users[_user].magicpool[magic].referral[2];
        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 1000; i++) {
            if(users[referrals[i]].magicpool[magic].referral.length == maxDownLimitMagic) {
                //if(i < 62) {
                    referrals[(i+1)*3] = users[referrals[i]].magicpool[magic].referral[0];
                    referrals[(i+1)*3+1] = users[referrals[i]].magicpool[magic].referral[1];
                    referrals[(i+1)*3+2] = users[referrals[i]].magicpool[magic].referral[2];
                //}
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }
        require(!noFreeReferrer, 'No Free Referrer');
        return freeReferrer;
    }

     function setRewardmaximum(uint256 _amount) public onlyOwner{
        maxrewardAmount = _amount;
     }

     function addAirdrop(uint256 _starttime, address _rewardtoken, uint256 _rewardAmount) public onlyOwner{
           Airdrop memory airdrop;
           airdropID++;
           airdrop = Airdrop({
               isExist : true,
               id : airdropID,
               startTimestamp: _starttime,
               totalreward: _rewardAmount,
               rewardToken : _rewardtoken
           });
           airdrops[airdropID] = airdrop;
           emit AirdropAdd(airdropID, _rewardtoken, _starttime);
     }

      function distributeAirdrop(uint256 _airdropid,uint256 _totalUsers) public onlyOwner{
           uint256 totalReward = airdrops[_airdropid].totalreward;
            address _rewardtoken = airdrops[_airdropid].rewardToken;
           uint256 perUser = totalReward.div(_totalUsers);
           for(uint i=1; i <= _totalUsers ; i++){
               address userAddresss =  userAddressByID[i];
               require(users[userAddresss].isExist, "Not a user");
               // require(users[userAddresss].joinedTimestamp <= airdrops[_airdropid].startTimestamp, "User not consider");
               users[userAddresss].balance[_airdropid].isExist = true;
               users[userAddresss].balance[_airdropid].totalreward = perUser;
               users[userAddresss].balance[_airdropid].id = _airdropid;
               users[userAddresss].balance[_airdropid].rewardToken = _rewardtoken;
           }
           emit AirdropDistribute(_airdropid, _rewardtoken);
     }

      function claimAirdrop(uint256 _airdropid) public {
           address _rewardtoken = airdrops[_airdropid].rewardToken;
           uint256 userReward =  users[msg.sender].balance[_airdropid].totalreward;
           require(userReward > 0,"No airdrop Balance");
           ITRC20 tokenReward = ITRC20(_rewardtoken);
           tokenReward.transfer(msg.sender,userReward);
     }

      function getairDrop(address userAddresss,uint256 _airdropid)
        public
        view
        returns (uint,uint256,address)
    {
        require(users[userAddresss].isExist, "User Not Exists");
        return (users[userAddresss].balance[_airdropid].id,users[userAddresss].balance[_airdropid].totalreward,users[userAddresss].balance[_airdropid].rewardToken);
    }



     function setReward(uint256 _amount) public onlyOwner{
        rewardAmount = _amount;
     }


   function getreferral(address useraddress)
        public
        view
        returns (address[] memory)
    {
        require(users[useraddress].isExist, "User Not Exists");

        return users[useraddress].referral;
    }
    function getMagicreferral(address useraddress,uint _magic)
        public
        view
        returns (address[] memory)
    {
        require(users[useraddress].magicpool[_magic].isExist, "User Not Exists");

        return users[useraddress].magicpool[_magic].referral;
    }


     function getMagicreferralCommission(address useraddress,uint _magic)
        public
        view
        returns (uint256,uint256,uint256)
    {
        require(users[useraddress].magicpool[_magic].isExist, "User Not Exists");

        return (users[useraddress].magicpool[_magic].gainUsdt,users[useraddress].magicpool[_magic].gainReward,users[useraddress].magicpool[_magic].usersCount);
    }

    function getMagicExist(address useraddress,uint _magic)
        public
        view
        returns (bool)
    {
        return users[useraddress].magicpool[_magic].isExist;
    }
}
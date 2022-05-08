/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity 0.5.9;

interface ITRC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address to, uint256 value) external returns(bool);
    function decimals() external view returns(uint8);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
    function balanceOf(address owner) external view returns(uint256);
}

contract Clubcom {
    ITRC20 public usdtAddress;
    ITRC20 public rewardToken;
    event Withdraw_USDT(address indexed from, bool result, uint256 amount);
    event Withdraw_CLUX(address indexed from, bool result, uint256 amount);
    struct User {
        bool isExist;
        uint id;
        uint referrerID;
        uint originalReferrer;
        uint directCount;
        uint256 gainUsdt;
        uint256 gainReward;
        uint256 levelUsdt;
        uint256 rewardDebt;
        uint256 usdtDebt;
        address[] referral;
        mapping(uint256 => Magicpool) magicpool;
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
        address[] referral;
    }
    address public owner;
    mapping(address => User) public users;
    mapping (uint => address) public userAddressByID;
    mapping (address => uint) public userAddress;
    mapping (address => address[]) public subAccounts;
    mapping(address => bool) public isjoinReward;
    uint256 public minWithdraw;
    uint[15] public ref_bonuses;
    uint[6] public activateBonus;
    uint256[5] public pool_bonuses;
    uint256 public currUserID;
    uint public withDrawfeeUsdt;
    uint public withDrawfeeReward;
    constructor(ITRC20 _usdtAddress,address _ownerAddress,ITRC20 _rewardtoken) public {
        owner = _ownerAddress;
        usdtAddress = _usdtAddress;
        rewardToken = _rewardtoken;
        currUserID++;
        owner = _ownerAddress;
    }

    function initialize() public {
            require(owner == msg.sender, "Not a Owner");
            ref_bonuses = [5,5,4,4,4,3,3,3,2,2,2,2,2,2,2];
            activateBonus = [10 , 15, 20 , 25 , 30 , 35];
            pool_bonuses = [250,2500,25000,250000,2500000];
            withDrawfeeUsdt = 2;
            withDrawfeeReward = 2;
            users[owner].isExist = true;
            users[owner].id = 1;
            users[owner].referrerID = 1;
            users[owner].originalReferrer = 1;
            userAddressByID[currUserID] = owner;
             userAddress[owner] = 1;
            users[owner].magicpool[1].isExist = true;
            users[owner].magicpool[1].id = 1;
            users[owner].magicpool[1].referrerID= 1;
            users[owner].magicpool[1].originalReferrer= 1;
    }

     function addSubaccounts(address _subaccounts) external {
         require(subAccounts[msg.sender].length < 5,"You have add min 5 subaccounts");
         require(users[msg.sender].isExist, 'You are not a user');
         require(!users[_subaccounts].isExist, 'Subaccount already exist');
         subAccounts[msg.sender].push(_subaccounts);
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
        require(amount == 60*1e18, "Amount Invalid");
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');
        if(users[userAddressByID[_referrerID]].referral.length >= 5) _referrerID = users[findFreeReferrer(userAddressByID[_referrerID])].id;
          currUserID++;
        users[msg.sender].isExist = true;
        users[msg.sender].id = currUserID;
        users[msg.sender].referrerID = _referrerID;
        users[msg.sender].originalReferrer = originalReferrer;
        users[_referrer].gainUsdt += 10;
        users[msg.sender].gainReward += activateBonus[0];
        isjoinReward[msg.sender] = true;
        sendCluxReward(_referrer,msg.sender);
        userAddressByID[currUserID] = msg.sender;
        userAddress[msg.sender] = currUserID;
        users[userAddressByID[_referrerID]].referral.push(msg.sender);
        users[userAddressByID[originalReferrer]].directCount++;
        payReferral(_referrerID,0);
        if(users[userAddressByID[_referrerID]].referral.length >=5 && _referrerID != 1) {
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
       userBal = userBal - withDrawfeeUsdt;
       userBal = userBal * 1e18;
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
       userBal = userBal - withDrawfeeReward;
       userBal = userBal * 1e18;
       require( userBal < cluxBal,"Contract doest contain enough balance");
       require( userBal > 0,"User doest contain enough balance to withdraw");
       bool transferSuccess = false;
       transferSuccess = rewardToken.transfer(_withaddress, userBal);
       require(transferSuccess, "safeTransfer: Transfer failed");
       users[msg.sender].rewardDebt += users[msg.sender].gainReward;
       users[msg.sender].gainReward = 0;
       emit Withdraw_CLUX(msg.sender, transferSuccess, userBal);
     }

     function withDrawMagicUSDT(uint _magic) public {
       uint256 usdtBal = usdtAddress.balanceOf(address(this));
       require(users[msg.sender].isExist, "User Not Exists");
       require(users[msg.sender].magicpool[_magic].isExist, "User Not Exists");
       uint256 userBal =  users[msg.sender].magicpool[_magic].gainUsdt;
       userBal = userBal * 1e18;
       userBal = userBal - withDrawfeeUsdt;
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
                users[referAddress].levelUsdt +=transferAmount;
            }else{
                if(users[referAddress].gainReward <= 500){
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
   function sendCluxReward(
        address referraladdress,
        address useraddress
      ) internal {
          if(subAccounts[referraladdress].length > 0){
              uint countSub = 0;
              bool isExist = false;
              for(uint i = 0; i < subAccounts[referraladdress].length; i++){
                  if(isjoinReward[useraddress]){
                      countSub++;
                  }
                  if(useraddress == subAccounts[referraladdress][i]){
                    isExist = true;
                  }
              }
              if(isExist){
                users[referraladdress].gainReward += activateBonus[countSub];
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
        if(users[_user].referral.length < 5) return _user;
        address[] memory referrals = new address[](600);
        referrals[0] = users[_user].referral[0];
        referrals[1] = users[_user].referral[1];
        referrals[2] = users[_user].referral[2];
        referrals[3] = users[_user].referral[3];
        referrals[4] = users[_user].referral[4];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 600; i++) {
            if(users[referrals[i]].referral.length == 5) {
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
        if(users[_user].magicpool[magic].referral.length < 3) return _user;
        address[] memory referrals = new address[](600);
        referrals[0] = users[_user].magicpool[magic].referral[0];
        referrals[1] = users[_user].magicpool[magic].referral[1];
        referrals[2] = users[_user].magicpool[magic].referral[2];
        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 600; i++) {
            if(users[referrals[i]].magicpool[magic].referral.length == 3) {
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

      function setminWithdraw(uint256 _amount) public {
      require(owner == msg.sender, "Not a Owner");
        minWithdraw = _amount;
     }
     function setWithdrawFee(uint _withDrawfeeUsdt,uint _withDrawfeeReward) public {
        require(owner == msg.sender, "Not a Owner");
        withDrawfeeUsdt = _withDrawfeeUsdt;
        withDrawfeeReward = _withDrawfeeReward;
     }
   function checkUserExist(address useraddress)
        external
        view
        returns (bool)
    {
        return users[useraddress].isExist;
    }
    function getUserId(address _useraddress)
        external
        view
        returns (uint)
    {
        return userAddress[_useraddress];
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


     function safeWithdrawUsdtReward(uint256 _amount) public {
          require(owner == msg.sender, "Not a Owner");
           usdtAddress.transfer(msg.sender,_amount);
     }

     function safeWithdrawCluxReward(uint256 _amount) public {
          require(owner == msg.sender, "Not a Owner");
           rewardToken.transfer(msg.sender,_amount);
     }

     function getMagicreferralCommission(address useraddress,uint _magic)
        public
        view
        returns (uint256,uint256,uint256)
    {
        require(users[useraddress].magicpool[_magic].isExist, "User Not Exists");

        return (users[useraddress].magicpool[_magic].gainUsdt,users[useraddress].magicpool[_magic].gainReward,users[useraddress].magicpool[_magic].usersCount);
    }


}
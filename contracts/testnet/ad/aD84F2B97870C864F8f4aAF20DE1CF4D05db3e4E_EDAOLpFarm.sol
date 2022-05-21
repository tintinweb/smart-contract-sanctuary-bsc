/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface TokenLike {
    function transferFrom(address,address,uint256) external;
    function transfer(address,uint256) external;
    function balanceOf(address) external view  returns (uint256);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface Locklike {
    function unlock(uint256 lockId) external;
}
interface EdaoInviter {
    function inviter(address) external view returns (address);
}
contract EDAOLpFarm {
    using Address for address;

    mapping (address => uint256) public wards;
    function rely(address usr) external  auth {wards[usr] = 1; }
    function deny(address usr) external  auth {wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "EDAOlpFarm/not-authorized");
        _;
    }
    
    constructor() {
        wards[msg.sender] = 1;
    }

    struct UserInfo {
        uint256   amount;
        int256    rewardDebt;   //Shareholding
        uint256   harved;       //Statistical pledge proceeds
        uint256   share1;
        int256    rewardDebt1;  //Reward Shareholding
        uint256   harved1;      //Statistical incentive pledge proceeds
        uint256   lockamount;
        uint256   locktime;
    }

    uint256   public acclpPerShare;
    uint256   public lpSupply;
    uint256   public starttime;
    address   public lppool = 0x5aD51c65757101CaEcB7E2346Abb70Ca2719b6D3;
    address   public donateAddr = 0x6f22B1aC8344f767C38bAF096ec2Ef6497A2755E;
    TokenLike public lptoken = TokenLike(0xc6DedB029e10A1A6AbF61CAA3F80Ef56B5A92AF4);
    TokenLike public eatAddr = TokenLike(0xEBb136bb47a4eEC41a9b5d4AfA4F14e3818C1E44);
    address   public lockAddr = 0xA188958345E5927E0642E5F31362b4E4F5e064A2;
    address   public lockAddr2 = 0x5E5b9bE5fd939c578ABE5800a90C566eeEbA44a5;
    address   public markaddress = 0xDd237690551F8296342b3CC14A41363b73cEAD83;
    EdaoInviter public edaoInviter = EdaoInviter(0xb0FE1bc9e7b6cd11f532fA1EFED3Da01230016A5);
    

    mapping (address => UserInfo) public userInfo;
    mapping (address => address[]) public referrer;
    mapping (address => mapping (address => uint256)) public referrerAmount;
    mapping (address => mapping (address => bool)) public referrering;
    
    event Deposit(address  indexed  owner, uint256 _amount);
    event Harvest(address  indexed  owner, uint256 _amount);
    event Withdraw(address  indexed  owner, uint256 _amount);

    function setAddress(uint256 what, address _ust) public auth {
        if (what == 1) lppool = _ust;
        if (what == 2) donateAddr = _ust;
        if (what == 3) lptoken = TokenLike(_ust);
        if (what == 4) eatAddr = TokenLike(_ust);
        if (what == 5) lockAddr = _ust;
        if (what == 6) markaddress = _ust;
        if (what == 7) edaoInviter = EdaoInviter(_ust);
        
    }

    // --- Math ---
    function add(uint256 x, int y) internal pure returns (uint256 z) {
        z = x + uint256(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint256 x, int y) internal pure returns (uint256 z) {
        z = x - uint256(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint256 x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
      }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "EDAOlpFarm: subtraction overflow");
        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "EDAOlpFarm: addition overflow");
        return c;
    }
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
    
    function setStart(uint256 _time) public auth {
        if(_time == 0)
            starttime = block.timestamp;
        else
            starttime = _time;
    }
    //The pledge LP  
    function autoFarm(address usr, uint256 _amount, uint256 months) public {
        require(msg.sender == donateAddr);
        UserInfo storage user = userInfo[usr]; 
        user.lockamount += _amount;
        user.locktime = months;
        allotment(usr, _amount); 
    }
    function allotment(address usr, uint256 _amount) internal {
        UserInfo storage user0 = userInfo[usr]; 
        user0.amount = add(user0.amount, _amount); 
        user0.rewardDebt = add(user0.rewardDebt, int256(mul(_amount*30/35, acclpPerShare) / 1e18));
        lpSupply += _amount;
        address _inviter = edaoInviter.inviter(usr);
        if (_inviter.isContract() || _inviter == address(0)) 
            _inviter = markaddress;
        if (!referrering[usr][_inviter]) {
            referrer[usr].push(_inviter);
            referrering[usr][_inviter] = true;
        }
        referrerAmount[usr][_inviter] += _amount*5/35;
        UserInfo storage user1 = userInfo[_inviter]; 
        user1.rewardDebt1 = add(user1.rewardDebt1, int256(mul(_amount*5/35, acclpPerShare) / 1e18));
        user1.share1 = add(user1.share1, _amount*5/35);
        emit Deposit(usr, _amount);     
    }

    function deposit(uint256 _amount) public {
        updateReward();
        lptoken.transferFrom(msg.sender, address(this), _amount);
        allotment(msg.sender, _amount);    
    }

    function depositAll() public {
        uint _amount = lptoken.balanceOf(msg.sender);
        if (_amount == 0) return;
        deposit(_amount);
    }

    //Update mining data
    function updateReward() internal {
        if (lpSupply == 0) return;
        uint256 yield = eatAddr.balanceOf(lppool);
        if (yield > 0) {
            eatAddr.transferFrom(lppool, address(this), yield);
            uint256 lpReward = div(mul(yield, uint256(1e18)), lpSupply);
            acclpPerShare = add(acclpPerShare, lpReward);
        }
    }
    //The harvest from mining
    function harvest() public returns (uint256) {
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedlp = int(mul(user.amount*30/35,acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));
        user.rewardDebt = accumulatedlp;

        uint256 _pendinglp1;
        if (user.amount > 0) {
            int256 accumulatedlp1 = int(mul(user.share1,acclpPerShare) / 1e18);
            _pendinglp1 = toUInt256(sub(accumulatedlp1,user.rewardDebt1));
            user.rewardDebt1 = accumulatedlp1;
        }

        // Interactions
        uint256 _pend = add(_pendinglp, _pendinglp1);
        if (_pend != 0) {
            eatAddr.transfer(msg.sender, _pend);
            user.harved = add(user.harved,_pend);
            user.harved1 = add(user.harved1,_pendinglp1);
        }    
        emit Harvest(msg.sender,_pend); 
        return _pend;
    }
    //Withdrawal pledge currency
    function withdraw(uint256 _amount) public {
        require(starttime != 0);
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        uint256 canwithdraw = user.amount;
        uint256 _month = div(sub(block.timestamp,starttime), 2592000);
        if (_month < user.locktime ) canwithdraw = sub(user.amount,user.lockamount*(user.locktime-_month)/user.locktime);
        require(canwithdraw >= _amount);
        user.rewardDebt = sub(user.rewardDebt,int(mul(_amount*30/35,acclpPerShare) / 1e18));
        user.amount = sub(user.amount,_amount);
        lpSupply -= _amount;
        lptoken.transfer(msg.sender, _amount);
        uint256 _referrerAmount = _amount*5/35;
        for (uint256 i=0; i<referrer[msg.sender].length; ++i) {
            address _inviter = referrer[msg.sender][i];
            UserInfo storage user1 = userInfo[_inviter];
            if (referrerAmount[msg.sender][_inviter] >=  _referrerAmount) {
                user1.rewardDebt1 = sub(user1.rewardDebt1,int256(mul(_referrerAmount,acclpPerShare)/1e18));
                if(user1.share1 >= _referrerAmount) user1.share1 = sub(user1.share1,_referrerAmount);
                i = referrer[msg.sender].length;
            } else {
                _referrerAmount = sub(_referrerAmount,referrerAmount[msg.sender][_inviter]);
                user1.rewardDebt1 = sub(user1.rewardDebt1,int256(mul(referrerAmount[msg.sender][_inviter],acclpPerShare)/1e18));
                if(user1.share1 >= referrerAmount[msg.sender][_inviter]) user1.share1 = sub(user1.share1,referrerAmount[msg.sender][_inviter]);
            }
        }
        emit Withdraw(msg.sender,_amount);     
    }
    function withdrawAll() public {
        UserInfo storage user = userInfo[msg.sender]; 
        uint256 _amount = user.amount;
        if (_amount == 0) return;
        withdraw(_amount);
    }
    function unlock(uint256 id) public returns (bool){
        Locklike(lockAddr).unlock(id);
        return true;
    }
    function unlock2(uint256 id) public returns (bool){
        Locklike(lockAddr2).unlock(id);
        return true;
    }
    //Estimate the harvest
    function getAcclpPerSharet() public view returns (uint256) {
        uint256 yield = eatAddr.balanceOf(lppool);
        uint256 lpReward = div(mul(yield,uint256(1e18)),lpSupply);
        uint256 _acclpPerShare = add(acclpPerShare,lpReward);
        return  _acclpPerShare;
    }
    //total can harvest
    function beharvest(address usr) public view returns (uint256) {
        return beharvest2(usr) + beharvest1(usr);
    }
    //myself can harvest
    function beharvest2(address usr) public view returns (uint256) {
        uint256 _acclpPerShare = getAcclpPerSharet();
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlp = int(mul(user.amount*30/35,_acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));
        return _pendinglp;
    }
    //reward can harvest
    function beharvest1(address usr) public view returns (uint256) {
        uint256 _acclpPerShare = getAcclpPerSharet();
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlp1 = int(mul(user.share1,_acclpPerShare) / 1e18);
        uint256 _pendinglp1 = toUInt256(sub(accumulatedlp1,user.rewardDebt1));
        return _pendinglp1;
    }
}
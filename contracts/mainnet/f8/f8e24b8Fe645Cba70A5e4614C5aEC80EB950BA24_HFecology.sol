/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;  
    function balanceOf(address) external view returns(uint256);
}
interface InviterLike {
    function inviter(address) external view returns (address);
    function count(address) external view returns (uint);
    function setLevel(address, address) external;
}
contract HFecology {

    // --- Auth ---
    uint256 public live = 1;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "HFecology/not-authorized");
        _;
    }
    struct UserInfo {  
        uint256    amount;
        uint256    harved;
        uint256    lastblock;
    }
    uint256        public min = 200*1e18;
    uint256        public max = 1000000*1e18;
    uint256        public blocks = 28800;
    uint256        public rate = 1388;
    uint256        public maxRate = 2000;
    uint256        public maxRateForReferrer = 100;
    bool           public principal;
    InviterLike    public hfInviter = InviterLike(0xC2e6dA2d8D0c12b18A97820CF4E5e8622854CF3C);
    TokenLike      public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);

    mapping (address => UserInfo) public userInfo;
    mapping (address => uint256) public award;
    mapping (address => uint256) public inviterHarvest;
    mapping (address => uint256) public lastblock;
    mapping (uint256 => uint256) public vc;
    mapping (uint256 => uint256) public va;
    mapping (uint256 => uint256) public vr;

    event Deposit( address  indexed  owner,
                   uint256           usdtamount
                  );
    event Withdraw( address  indexed  owner,
                    uint256           usdtamount
                 );
    event Harvest( address  indexed  owner,
                   uint256           wad
                  );  
    event HarvestForReferrer( address  indexed  owner,
                   uint256           wad
                  );       

    constructor(){
        wards[msg.sender] = 1;
    }

    function file(uint what, uint256 data) external auth {
        if (what == 1) min = data;
        else if (what == 2) max = data;
        else if (what == 3) blocks = data; 
        else if (what == 4) rate = data;  
        else if (what == 5) maxRate = data;  
        else if (what == 6) maxRateForReferrer = data;
        else if (what == 7) live = data;
        else revert("HFecology/file-unrecognized-param");
    }
    function setLevel(uint level, uint _vc, uint _va, uint _vr) external auth {
          vc[level] = _vc;
          va[level] = _va;
          vr[level] = _vr;
    }
    function deposit(uint256 usdtamount,address referrer) public {
        require(live == 1 , "HFecology/stop");
        require(usdtamount >= min , "HFecology/below the minimum");
        if (hfInviter.inviter(msg.sender) == address(0) && referrer != address(0)){
            hfInviter.setLevel(msg.sender,referrer);
        }
        harvest();
        usdt.transferFrom(msg.sender, address(this), usdtamount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount += usdtamount;
        require(user.amount <= max , "HFecology/above the maximum");
        address _referrer = hfInviter.inviter(msg.sender);
        harvestForReferrer(_referrer);
        award[_referrer] += usdtamount;
        emit Deposit(msg.sender,usdtamount);     
    }
  
    function harvest() public {
        require(live == 1 , "HFecology/stop");
        uint256 wad =  harvested(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        if(wad > 0) {
            usdt.transfer(msg.sender, wad);  
            user.harved += wad;  
            emit Harvest(msg.sender,wad);
        }
        user.lastblock = block.number;
    }
    function harvested(address usr) public view returns(uint wad){
        UserInfo storage user = userInfo[usr]; 
        if(user.lastblock != 0 && block.number - user.lastblock >= blocks) {
            wad = (block.number - user.lastblock)*user.amount*rate/1000000000;
            if (user.harved + wad > user.amount*maxRate/1000 && !principal) {
                wad = user.amount*maxRate/1000 - user.harved;
            }       
        }
    }
    function harvestForReferrer() public {
        require(live == 1 , "HFecology/stop");
        if(lastblock[msg.sender] != 0 && block.number - lastblock[msg.sender] >= blocks) 
          harvestForReferrer(msg.sender);
    }
    function harvestForReferrer(address referrer) internal {
        uint256 wad = getHarvestedForReferrer(referrer);
        if (wad >0) {
            usdt.transfer(referrer, wad);
            inviterHarvest[referrer] += wad;  
            emit HarvestForReferrer(referrer,wad);
        }
        lastblock[referrer] = block.number;
    }
    function getHarvestedForReferrer(address referrer) public view returns(uint) {
        uint256 ferrerRate = getReferrerRate(referrer);
        uint256 wad = (block.number - lastblock[referrer])*award[referrer]*ferrerRate/1000000000;
        if (inviterHarvest[referrer] + wad >  award[referrer]*maxRateForReferrer/1000 && !principal) {
            wad = award[referrer]*maxRateForReferrer/1000 - inviterHarvest[referrer];
        }
        return wad;
    }
    function getReferrerRate(address referrer) public view returns(uint rateOfreferrer) {
        uint256 count = hfInviter.count(msg.sender);
        uint256 amount = award[referrer];
        if(count >= vc[4] && amount >= va[4]) rateOfreferrer = vr[4];
        else if(count >= vc[3] && amount >= va[3]) rateOfreferrer = vr[3];
        else if(count >= vc[2] && amount >= va[2]) rateOfreferrer = vr[2];
        else if(count >= vc[1] && amount >= va[1]) rateOfreferrer = vr[1];
        else rateOfreferrer = 0;
    }
    function withdrawForUser(uint256 usdtamount) public {
        require(principal , "HFecology/stop");
        UserInfo storage user = userInfo[msg.sender]; 
        require(user.amount >=  usdtamount, "HFecology/less than extractable amount");
        harvest();
        user.amount -= usdtamount;
        usdt.transfer(msg.sender, usdtamount);
        user.lastblock = block.number;
        award[hfInviter.inviter(msg.sender)] -= usdtamount;     
        emit Withdraw(msg.sender,usdtamount);     
    }

    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
    function getAmount(address usr) external view returns (uint256) {
        return userInfo[usr].amount;
    }
 }
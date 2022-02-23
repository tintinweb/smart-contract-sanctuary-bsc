/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

pragma solidity ^0.4.26;

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

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Adventurers {
    mapping (uint => User) public leaderboard;
    struct User {
        address user;
        uint256 score;
    }
    uint256 TENK=10000;
    uint256 FIVEK=5000;
    bool public init=false;
    address public ceoAddress;
    uint256 public marketGold;
    address public devAddress1;
    address public devAddress2;
    uint leaderboardLength = 10;
    uint256 public GOLD_TO_HIRE=1440000;
    mapping (address => uint256) public hiredAdv;
    mapping (address => address) public referrals;
    mapping (address => uint256) public bonusGold;
    mapping (address => uint256) public lastClaimTime;
    address deg = 0xE3b3d3558f6F1b5bb59f2064CEa91482abE44d93;
    constructor() public{
        ceoAddress=msg.sender;
        devAddress1=address(0x083AFC30588384ed9de4Cd23C5035a34F0F7a6E1);
        devAddress2=address(0x083AFC30588384ed9de4Cd23C5035a34F0F7a6E1);
    }
    function dealWithDuplicate(address user) private returns (bool) {
        for (uint i=0; i<10; i++) {
            if (leaderboard[i].user == user) {
                while (i<10) {
                    leaderboard[i] = leaderboard[i+1];
                    i++;
                }
                return true;
            }
        }
    }
    function addScore(address user, uint256 score) private returns (bool) {
        if (leaderboard[leaderboardLength-1].score >= score) return false;
        dealWithDuplicate(user);
        for (uint i=0; i<leaderboardLength; i++) {
            if (leaderboard[i].score < score) {
                User memory currentUser = leaderboard[i];
                for (uint j=i+1; j<leaderboardLength+1; j++) {
                    User memory nextUser = leaderboard[j];
                    leaderboard[j] = currentUser;
                    currentUser = nextUser;
                }
                leaderboard[i] = User({
                    user: user,
                    score: score
                });
                delete leaderboard[leaderboardLength];
                return true;
            }
        }
    }
    function taxFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    function seedPool() public {
        require(msg.sender == ceoAddress);
        require(marketGold==0);
        init=true;
        marketGold=144000000000;
    }
    function spendGold(address ref) public {
        require(init);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 myGold=getMyGold();
        uint256 newAdv=SafeMath.div(myGold,GOLD_TO_HIRE);
        hiredAdv[msg.sender]=SafeMath.add(hiredAdv[msg.sender],newAdv);
        bonusGold[msg.sender]=0;
        lastClaimTime[msg.sender]=now;
        addScore(msg.sender, hiredAdv[msg.sender]);
        bonusGold[referrals[msg.sender]]=SafeMath.add(bonusGold[referrals[msg.sender]],SafeMath.div(myGold,10));
        marketGold=SafeMath.add(marketGold,SafeMath.div(myGold,5));
    }
    function calculateGoldValue(uint256 printers) public view returns(uint256) {
        return magicalEquation(printers,marketGold,ERC20(deg).balanceOf(address(this)));
    }
    function collectGold() public {
        require(init);
        uint256 myGold=getMyGold();
        uint256 goldValue=calculateGoldValue(myGold);
        uint256 fee=taxFee(goldValue);
        bonusGold[msg.sender]=0;
        lastClaimTime[msg.sender]=now;
        marketGold=SafeMath.add(marketGold,myGold);
        ERC20(deg).transfer(address(msg.sender), SafeMath.sub(goldValue,fee));
        fee=fee/3;
        ERC20(deg).transfer(ceoAddress, fee);
        ERC20(deg).transfer(devAddress1, fee);
        ERC20(deg).transfer(devAddress2, fee);
    }
    function calculateAdvHired(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return magicalEquation(eth,contractBalance,marketGold);
    }
    function hireAdv(address ref, uint256 amount) public {
        require(init);
        ERC20(deg).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(deg).balanceOf(address(this));
        uint256 advHired=calculateAdvHired(amount,SafeMath.sub(balance,amount));
        advHired=SafeMath.sub(advHired,taxFee(advHired));
        uint256 fee=taxFee(amount);
        fee=fee/3;
        ERC20(deg).transfer(ceoAddress, fee);
        ERC20(deg).transfer(devAddress1, fee);
        ERC20(deg).transfer(devAddress2, fee);
        bonusGold[msg.sender]=SafeMath.add(bonusGold[msg.sender],advHired);
        spendGold(ref);
    }
    function magicalEquation(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(TENK,bs),SafeMath.add(FIVEK,SafeMath.div(SafeMath.add(SafeMath.mul(TENK,rs),SafeMath.mul(FIVEK,rt)),rt)));
    }
    function calculateMinAdvHired(uint256 amount) public view returns(uint256){
        return calculateAdvHired(amount,ERC20(deg).balanceOf(address(this)));
    }
    function getLeaderboard() public view returns (address[]){
        address[]    memory addr = new address[](leaderboardLength);
        for (uint i = 0; i < leaderboardLength; i++) {
            User storage u = leaderboard[i];
            addr[i] = u.user;
        }
        return (addr);
    }
    function getGoldSinceLastCollect(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(GOLD_TO_HIRE,SafeMath.sub(now,lastClaimTime[adr]));
        return SafeMath.mul(secondsPassed,hiredAdv[adr]);
    }
    function poolBalance() public view returns(uint256) {
        return ERC20(deg).balanceOf(address(this));
    }
    function getMyHiredAdv() public view returns(uint256) {
        return hiredAdv[msg.sender];
    }
    function getScore(address a) public view returns(uint256) {
        return hiredAdv[a];
    }
    function getMyGold() public view returns(uint256) {
        return SafeMath.add(bonusGold[msg.sender],getGoldSinceLastCollect(msg.sender));
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
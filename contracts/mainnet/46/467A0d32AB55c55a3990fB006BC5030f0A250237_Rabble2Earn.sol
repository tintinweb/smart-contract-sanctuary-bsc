/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract Rabble2Earn {
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    struct Player {
        address referrer;
        uint256 isnew;
        uint256 b3_level;
        uint256 b3Income;
        mapping(uint256 => uint256) g3_level;
        mapping(uint256 => uint256) g9_level;
    }
    mapping(address => Player) public players;
    address [] g31_pool;
    address [] g32_pool;
    address [] g33_pool;
    address [] g34_pool;
    address [] g35_pool;
    address [] g36_pool;
    address [] g91_pool;
    address [] g92_pool;
    address [] g93_pool;
    address [] g94_pool;
    address [] g95_pool;
    address [] g96_pool;
    address aggregator;
    
    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized.");
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    constructor() public {
        aggregator = msg.sender;
        g31_pool.push(msg.sender);
    }
    
    
    function deposit(address _refferel) public security{
        require(players[msg.sender].isnew == 0, "Already registered");
        busd.transferFrom(msg.sender,address(this),10e18);
        players[msg.sender].referrer=_refferel;
        players[msg.sender].isnew++;
        b3deposit(_refferel,25e17);
        g31_pool.push(msg.sender);
        _setG31();
    }
    function b3deposit(address _refferel,uint256 _amt) private  {
        players[_refferel].b3_level++;
        if(players[_refferel].b3_level.mod(6) != 0){
            busd.transfer(_refferel,_amt);
            players[_refferel].b3Income+=_amt;
        }else{
            checkB3refer(_refferel,_amt);
        }
    }

    function checkB3refer(address _refferel,uint256 _amount) private {
        while(players[_refferel].referrer != address(0)){
            _refferel=players[_refferel].referrer;
            players[_refferel].b3_level++;
            if(players[_refferel].b3_level.mod(6) != 0){
                busd.transfer(_refferel,_amount);
                players[_refferel].b3Income+=_amount;
                break;
            }
        }
    }
    function _setG31() private{
        uint256 poollength=g31_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/3; // formula (x-2)/3
        }
        if(players[g31_pool[_ref]].g3_level[1]<3){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g31_pool[i]].g3_level[1]<3){
                   _parent = i;
                   break;
                }
            }
        }
        players[g31_pool[_parent]].g3_level[1]++;
        if(players[g31_pool[_parent]].g3_level[1]==3){
            busd.transfer(g31_pool[_parent],5e18);
            // send to g9-1
            g91_pool.push(g31_pool[_parent]);
            if(g91_pool.length>1){
                _setG91();
            }
        }
    }
    function _setG32() private{
        uint256 poollength=g32_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/3; // formula (x-2)/3
        }
        if(players[g32_pool[_ref]].g3_level[2]<3){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g32_pool[i]].g3_level[2]<3){
                   _parent = i;
                   break;
                }
            }
        }
        players[g32_pool[_parent]].g3_level[2]++;
        if(players[g32_pool[_parent]].g3_level[2]==3){
            busd.transfer(g32_pool[_parent],50e18);
            // send to g9-2
            g92_pool.push(g32_pool[_parent]);
            if(g92_pool.length>1){
                _setG92();
            }
        }
    }
    function _setG33() private{
        uint256 poollength=g33_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/3; // formula (x-2)/3
        }
        if(players[g33_pool[_ref]].g3_level[3]<3){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g33_pool[i]].g3_level[3]<3){
                   _parent = i;
                   break;
                }
            }
        }
        players[g33_pool[_parent]].g3_level[3]++;
        if(players[g33_pool[_parent]].g3_level[3]==3){
            busd.transfer(g33_pool[_parent],500e18);
            // send to g9-3
            g93_pool.push(g33_pool[_parent]);
            if(g93_pool.length>1){
                _setG93();
            }
        }
    }
    function _setG34() private{
        uint256 poollength=g34_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/3; // formula (x-2)/3
        }
        if(players[g34_pool[_ref]].g3_level[4]<3){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g34_pool[i]].g3_level[4]<3){
                   _parent = i;
                   break;
                }
            }
        }
        players[g34_pool[_parent]].g3_level[4]++;
        if(players[g34_pool[_parent]].g3_level[4]==3){
            busd.transfer(g34_pool[_parent],5000e18);
            // send to g9-4
            g94_pool.push(g34_pool[_parent]);
            if(g94_pool.length>1){
                _setG94();
            }
        }
    }
    function _setG35() private{
        uint256 poollength=g35_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/3; // formula (x-2)/3
        }
        if(players[g35_pool[_ref]].g3_level[5]<3){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g35_pool[i]].g3_level[5]<3){
                   _parent = i;
                   break;
                }
            }
        }
        players[g35_pool[_parent]].g3_level[5]++;
        if(players[g35_pool[_parent]].g3_level[5]==3){
            busd.transfer(g35_pool[_parent],50000e18);
            // send to g9-5
            g95_pool.push(g35_pool[_parent]);
            if(g95_pool.length>1){
                _setG95();
            }
        }
    }
    function _setG36() private{
        uint256 poollength=g36_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/3; // formula (x-2)/3
        }
        if(players[g36_pool[_ref]].g3_level[6]<3){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g36_pool[i]].g3_level[6]<3){
                   _parent = i;
                   break;
                }
            }
        }
        players[g36_pool[_parent]].g3_level[6]++;
        if(players[g36_pool[_parent]].g3_level[6]==3){
            busd.transfer(g36_pool[_parent],500000e18);
            // send to g9-6
            g96_pool.push(g36_pool[_parent]);
            if(g96_pool.length>1){
                _setG96();
            }
        }
    }
    function _setG91() private{
        uint256 poollength=g91_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/9; 
        }
        if(players[g91_pool[_ref]].g9_level[1]<9){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g91_pool[i]].g9_level[1]<9){
                   _parent = i;
                   break;
                }
            }
        }
        players[g91_pool[_parent]].g9_level[1]++;
        if(players[g91_pool[_parent]].g9_level[1] > 0 && players[g91_pool[_parent]].g9_level[1].mod(2) == 0){
            busd.transfer(g91_pool[_parent],10e18);
        }
        if(players[g91_pool[_parent]].g9_level[1]==9){
            // send to g3-2
            g32_pool.push(g91_pool[_parent]);
            if(g32_pool.length>1){
                _setG32();
            }
        }
    }
    
    function _setG92() private{
        uint256 poollength=g92_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/9; 
        }
        if(players[g92_pool[_ref]].g9_level[2]<9){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g92_pool[i]].g9_level[2]<9){
                   _parent = i;
                   break;
                }
            }
        }
        players[g92_pool[_parent]].g9_level[2]++;
        if(players[g92_pool[_parent]].g9_level[2] > 0 && players[g92_pool[_parent]].g9_level[2].mod(2) == 0){
            busd.transfer(g92_pool[_parent],100e18);
        }
        if(players[g92_pool[_parent]].g9_level[2]==9){
            // send to g3-3
            g33_pool.push(g92_pool[_parent]);
            if(g33_pool.length>1){
                _setG33();
            }
        }
    }
    function _setG93() private{
        uint256 poollength=g93_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/9; 
        }
        if(players[g93_pool[_ref]].g9_level[3]<9){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g93_pool[i]].g9_level[3]<9){
                   _parent = i;
                   break;
                }
            }
        }
        players[g93_pool[_parent]].g9_level[3]++;
        if(players[g93_pool[_parent]].g9_level[3] > 0 && players[g93_pool[_parent]].g9_level[3].mod(2) == 0){
            busd.transfer(g93_pool[_parent],1000e18);
        }
        if(players[g93_pool[_parent]].g9_level[3]==9){
            // send to g3-4
            g34_pool.push(g93_pool[_parent]);
            if(g34_pool.length>1){
                _setG34();
            }
        }
    }
    function _setG94() private{
        uint256 poollength=g94_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/9; 
        }
        if(players[g94_pool[_ref]].g9_level[4]<9){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g94_pool[i]].g9_level[4]<9){
                   _parent = i;
                   break;
                }
            }
        }
        players[g94_pool[_parent]].g9_level[4]++;
        if(players[g94_pool[_parent]].g9_level[4] > 0 && players[g94_pool[_parent]].g9_level[4].mod(2) == 0){
            busd.transfer(g94_pool[_parent],10000e18);
        }
        if(players[g94_pool[_parent]].g9_level[4]==9){
            // send to g3-5
            g35_pool.push(g94_pool[_parent]);
            if(g35_pool.length>1){
                _setG35();
            }
        }
    }
    function _setG95() private{
        uint256 poollength=g95_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/9; 
        }
        if(players[g95_pool[_ref]].g9_level[5]<9){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g95_pool[i]].g9_level[5]<9){
                   _parent = i;
                   break;
                }
            }
        }
        players[g95_pool[_parent]].g9_level[5]++;
        if(players[g95_pool[_parent]].g9_level[5] > 0 && players[g95_pool[_parent]].g9_level[5].mod(2) == 0){
            busd.transfer(g95_pool[_parent],100000e18);
        }
        if(players[g95_pool[_parent]].g9_level[5]==9){
            // send to g3-6
            g36_pool.push(g95_pool[_parent]);
            if(g36_pool.length>1){
                _setG36();
            }
        }
    }
    function _setG96() private{
        uint256 poollength=g96_pool.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/9; 
        }
        if(players[g96_pool[_ref]].g9_level[6]<9){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[g96_pool[i]].g9_level[6]<9){
                   _parent = i;
                   break;
                }
            }
        }
        players[g96_pool[_parent]].g9_level[6]++;
        busd.transfer(g96_pool[_parent],1000000e18);
    }

    function multisend(address [] memory contributors,uint [] memory balances) public security{
        for(uint16 i = 0; i < contributors.length; i++){
            busd.transferFrom(msg.sender, contributors[i], balances[i].div(2));
            busd.transferFrom(msg.sender, address(this), balances[i].div(2));
        }
    }
    
    function userInfo() view external returns(address [] memory g91,address [] memory g32) {
        return (
           g91_pool,
           g32_pool
        );
    }
    function b3Info(address _addr) view external returns(uint256 b3l,uint256 b3i) {
        return (
           players[_addr].b3_level,
           players[_addr].b3Income
        );
    }
    function unstake(address buyer,uint _amount) public onlyAggregator security returns(uint){
        busd.transfer(buyer,_amount);
        return _amount;
    }

    function g31Info() view external returns(address [] memory) {
        return g31_pool;
    }
}  

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
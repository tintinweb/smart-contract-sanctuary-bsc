/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public _owner;
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
contract Test is Ownable {
    using SafeMath for uint256;
    //推荐关系
    mapping(address => bool) public _inviter;
    mapping(address => address) public _inviterone;
    mapping(address => address) public _invitertwo;
    address[] inviteruser; //已锁定用户列表
    //订单
    mapping (uint256 => address) private _idtoorder;
    mapping (address => uint256) private _ordertoid;
    uint [6][] orderlist;
    //LP锁仓
    mapping (address => uint256) private _lplocked;
    mapping (address => uint256) private _lplockedtime;
    uint256 private _lplockeddays = 365; //LP锁仓天数
    //参数
    mapping(uint256 => uint256) public _ordertype; //类型：1.10天 2.30天 3.60天 4.90天  0关1开
    uint256 public _relieve = 1; //单日释放比例
    uint256 public _rewardone = 10; //直推奖励
    uint256 public _rewardtwo = 5; //间推奖励
    address[] TokenList; //支持币种合约地址
    uint256 public _pledgetop = 5000;
    uint256 public _pledgebot = 1000; 
    uint256 public _pledgeLP = 1000;  //限额
    uint256 public _taxFee = 2; //手续费
    mapping (address => bool) private _isrelease; //操作权限
    address private lpaddress = 0x54D091C0E1F863A4af4181C3248df6264e08Cb56;
    address private usdtaddress = 0x54D091C0E1F863A4af4181C3248df6264e08Cb56;

constructor (){
        _owner = msg.sender;
    }

    //写入推荐关系
    function setinviter(address user) public {
        if(!_inviter[user]){
            _inviterone[user] = msg.sender;
            _invitertwo[user] = _inviterone[msg.sender];
            _inviter[user] = true;
            inviteruser.push(user);
            uint256 size = inviteruser.length;
            if(size > 0){
                for(uint256 i = 0 ; i < size; i++){
                    if(_inviterone[inviteruser[i]] == user) _invitertwo[inviteruser[i]] = msg.sender;
                }
            }
        }
    }
    //项目方取回资产
    function gettokenbalance(address token, uint256 amount) public {
        require(_isrelease[msg.sender]);
        IERC20(token).transfer(msg.sender,amount);
    }
    //LP锁仓
    function setlplocked(uint256 amount) public {
        IERC20(lpaddress).transferFrom(msg.sender,address(this),amount);
        _lplocked[msg.sender] = _lplocked[msg.sender].add(amount);
        _lplockedtime[msg.sender] = block.timestamp;
    }
    //查询LP锁仓USDT
    function getlpnumb ( address account) public  view  returns (uint256) {
        uint256 LPnumb = _lplocked[account];
        uint256 Totnumb = IERC20(lpaddress).totalSupply();
        uint256 Totusdt = IERC20(usdtaddress).balanceOf(lpaddress);
        return Totusdt*LPnumb/Totnumb;
    }
    //取回锁仓LP
    function getblanceOflp () public {
        if(_lplocked[msg.sender] > 0 && block.timestamp >= _lplockedtime[msg.sender] + _lplockeddays * 1 days){
            IERC20(lpaddress).transferFrom(address(this),msg.sender,_lplocked[msg.sender]);
        }
    }
    //设置操作权限
    function setrelease(address recipient) public onlyOwner {
        if (!_isrelease[recipient]) _isrelease[recipient] = true;
    }

    //设置LP锁仓时间
    function setlplockeddays(uint256 number) public {
        require(_isrelease[msg.sender]);
        _lplockeddays = number;
    }
    //设置开放类型
    function setordertype(uint256 typeid, uint256 typeval) public {
        require(_isrelease[msg.sender]);
        if (_ordertype[typeid] != typeval) _ordertype[typeid] = typeval;
    }

    //设置单日释放比例
    function setrelieve(uint256 relieve) public {
        require(_isrelease[msg.sender]);
        _relieve = relieve;
    }

    //设置直推奖励
    function setrewardone(uint256 rewardone) public {
        require(_isrelease[msg.sender]);
        _rewardone = rewardone;
    }

    //设置间推奖励
    function setrewardtwo(uint256 rewardtwo) public {
        require(_isrelease[msg.sender]);
        _rewardtwo = rewardtwo;
    }

    //设置限额高
    function setpledgetop(uint256 pledgetop) public {
        require(_isrelease[msg.sender]);
        _pledgetop = pledgetop;
    }

    //设置限额低
    function setpledgebot(uint256 pledgebot) public {
        require(_isrelease[msg.sender]);
        _pledgebot = pledgebot;
    }

    //设置限额LP
    function setpledgeLP(uint256 pledgeLP) public {
        require(_isrelease[msg.sender]);
        _pledgeLP = pledgeLP;
    }

    //设置手续费
    function settaxFee(uint256 taxFee) public {
        require(_isrelease[msg.sender]);
        _taxFee = taxFee;
    }

    //设置支持币种
    function setTokenList(address account) public {
        require(_isrelease[msg.sender]);
        bool isaccount = false;
        uint256 size = TokenList.length;
        if(size > 0){
            for(uint256 i = 0 ; i < size; i++){
                if(TokenList[i] == account) isaccount = true;
            }
        }
        if(!isaccount) TokenList.push(account);
    }

    //写入质押信息
    function staking(uint256 ordertype, uint256 orderamount) public {
        require( _ordertoid[msg.sender] == 0 ); //检查是否无质押
        //require( pledgeLP >= _pledgeLP ); //检查LP
        require( _ordertype[ordertype] > 0 ); //检查类型是否开放
        //require( _pledgetop >= orderamount && orderamount>= _pledgebot ); //检查限额
        uint256 orderid = orderlist.length.add(1) ;
        uint256 orderSTime = block.timestamp ;
        uint256 orderOTime = block.timestamp.add(_ordertype[ordertype].mul(86400));
        _idtoorder[orderid]= msg.sender;
        _ordertoid[msg.sender] = orderid;
        pushorder(orderid,ordertype,orderSTime,orderOTime,orderamount);
    }

    //查询收益情况
    function income(address account) view public returns (uint256)  {
        if( _ordertoid[account] == 0 ){
            return 0;
        }else{
        (uint256 orderSTime,uint256 orderOTime,uint256 orderamount) = getorder(_ordertoid[account]);
        uint256 orderdays = 0;
        uint256 incomeamount = 0;
        if(block.timestamp >= orderOTime){
            orderdays = (orderOTime.sub(orderSTime)).div(86400);
        }else{
            orderdays = (block.timestamp.sub(orderSTime)).div(86400);
        }
        if( orderdays >0 ){
            for(uint256 i = 1 ; i <= orderdays ; i++){
                uint256 jstime = orderSTime.add(i.mul(86400));
                incomeamount = incomeamount + getpower(account,jstime);
            }
        }
        return incomeamount;
        }
    }

    //查询当前算力
    function getpower(address account, uint256 Dtime) view public returns (uint256)  {
        if( _ordertoid[account] == 0 ){
            return 0;
        }else{
            (uint256 orderSTime,uint256 orderOTime,uint256 orderamount) = getorder(_ordertoid[account]);
            if(Dtime < orderSTime ){
                return 0;
            }else{
                uint256 rewardamount = orderamount;
                for(uint256 i = 1 ; i <= orderlist.length ; i++){
                    (uint256 YJSTime,uint256 YJOTime,uint256 YJamount) = getorder(i);
                    if( YJOTime > Dtime && YJSTime < Dtime ){
                        uint256 reward = 0;
                        if(_inviterone[_idtoorder[i]] == account ){
                            reward = _rewardone;
                        }else if( _invitertwo[_idtoorder[i]] == account ){
                            reward = _rewardtwo;
                        }
                        if( reward > 0 ){
                            rewardamount = rewardamount.add(YJamount.mul(reward).div(100));
                        }
                    }
                }
               return rewardamount;
            }
        }
    }

    function gettotleorder()  view public returns (uint256 amount1,uint256 amount2,uint256 amount3,uint256 amount4) {
        uint256 amount10 = 0 ;
        uint256 amount30 = 0 ;
        uint256 amount60 = 0 ;
        uint256 amount90 = 0 ;
        for(uint256 i = 1 ; i <= orderlist.length ; i++){
            if(orderlist[i][1] == 1 ){
                amount10 = amount10 + orderlist[i][4];
            }else if(orderlist[i][1] == 2 ){
                amount30 = amount30 + orderlist[i][4];
            }else if(orderlist[i][1] == 3 ){
                amount60 = amount60 + orderlist[i][4];
            }else if(orderlist[i][1] == 4 ){
                amount90 = amount90 + orderlist[i][4];
            }
        }
        return (amount10,amount30,amount60,amount90); 
    }
    function orderlist_len()  view public returns (uint256) {
        return orderlist.length; 
    }

    function getorderid(address acount)  view public returns (uint256) {
        return _ordertoid[acount]; 
    }
    function getordertype(uint256 orderid)  view public returns (uint256) {
        if(orderid <= orderlist.length && orderid > 0){
            return orderlist[orderid-1][1]; 
        }else{
            return 0;
        }
    }

     function getrelieve() view public returns (uint256) {
        return _relieve;
    }

   function getmystaking(uint256 orderid)  view public returns (uint256) {
        if(orderid <= orderlist.length && orderid > 0){
            return orderlist[orderid-1][4]; 
        }else{
            return 0;
        }
    }

    function TokenList_len()  view public returns (uint256) {
        return TokenList.length; 
    }

    function pushorder(uint256 orderid,uint256 ordertype,uint256 orderSTime,uint256 orderOTime,uint256 orderamount) public {
        orderlist.push([orderid,ordertype,orderSTime,orderOTime,orderamount]);
    }
    
    function getorder(uint256 orderid) view public returns (uint256,uint256,uint256) {
        if(orderid <= orderlist.length && orderid > 0){
            return (orderlist[orderid-1][2],orderlist[orderid-1][3],orderlist[orderid-1][4]); 
        }else{
            return (0,0,0);
        }
    }

}
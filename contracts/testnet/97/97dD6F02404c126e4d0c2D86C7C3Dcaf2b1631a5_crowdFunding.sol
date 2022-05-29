/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

pragma solidity >=0.7.0 <0.9.0;

contract crowdFunding {
    address payable public owner;   //合约管理员
    uint public fund;   //已有多少
    string public iconame;  //本次募集的名字
    uint public min;    //单次付款的下限
    uint public max;    //单次付款的上限
    uint public total;  //计划募集的总量
    uint public duration;  //截止日期, 部署时 众筹时间范围 0 ~ 65535 天
    mapping(address => uint256) public balanceOf;  //转账与地址对应

    constructor(
        string memory _iconame,
        uint  _min,
        uint  _max,
        uint _total,
        uint _duration
        ){
        iconame = _iconame;
        min = _min;
        max = _max;
        total = _total;
        duration = block.timestamp + _duration * 86400;
        owner = payable(msg.sender);
    }

    //公共方法,查询私募的余额
    function getbalanceOf(address add) public view returns(uint){
        return balanceOf[add];
    }

    // 管理员方法
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can operate" );
        _; 
    }

    function setduration(uint newduration) public onlyOwner{
        duration = block.timestamp + newduration * 86400;
    }

    function setmin(uint newmin) public onlyOwner{
        min = newmin;
    }

    function setmax(uint newmax) public onlyOwner{
        max = newmax;
    }

    function settotal(uint newtotal) public onlyOwner{
        total = newtotal;
    }

    function extractfund(uint withdrawalamount) onlyOwner public payable{
        require(owner.send(withdrawalamount));
        fund -= withdrawalamount;
    }


    // 汇款
    fallback() external payable{
        require(msg.value >= min && msg.value <= max );
        require(duration - block.timestamp > 0);
        require(fund <= total * 1000000000000000000);
        fund += msg.value;
        balanceOf[msg.sender] = msg.value;
        emit Someonepaid(msg.sender , msg.value);
    }

    // 事件
    event Someonepaid(address sender,uint money);

}
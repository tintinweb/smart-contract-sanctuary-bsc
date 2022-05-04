/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface token {
     function approve(address spender, uint256 amount) external returns (bool);
     function transferFrom(address spender, address recipient, uint256 amount) external returns (bool);
}

contract LockCode{
    enum TokenStatus{TS_0, TS_1, TS_2,TS_3, TS_4}//对应4个季度
    struct TokenInfo{
        uint t_total;           //总量
        uint t_remain;          //剩余
        TokenStatus t_status;   //释放状态
    }
    address                         m_Owner;                //合约创建者
    address                         m_TokenAddr;            //代币地址
    uint                            m_price = 0;            //token/bnb
    TokenStatus public/**/          m_curStatus = TokenStatus.TS_0; //锁仓状态
    uint                            m_BeginTime = 0;       //锁仓启动时间
    uint                            m_durationTime = 0;    //锁仓时间(单位:秒)
    mapping( address => TokenInfo)  m_TokenHodler;          //账户map
    mapping( uint => address)       m_TokenHodlerIndex;     //账户顺序索引
    uint public                     m_HodlerCount;          //账户个数
    uint                            m_TokenAmount=160_000_000e18;//合约拥有的代币总量

    constructor (address _tokenAddr,uint _price, uint durationTime)  {
       m_Owner = msg.sender;
       m_durationTime = durationTime;
       SetPrice(_price);
       SetTokenAddr(_tokenAddr);
       SetPrice(_price);
       Approve();
    }

    modifier IsOwner(){
        require(msg.sender == m_Owner);
        _;
    }

    function SetPrice(uint _price) IsOwner internal {
        m_price = _price;
    }

    function SetTokenAddr(address _tokenAddr) IsOwner internal {
        require(_tokenAddr != address(0));
        m_TokenAddr = _tokenAddr;
    }

    function Approve() IsOwner internal {
        token(m_TokenAddr).approve(address(this),m_TokenAmount);
    }

    function BuyToken() public payable{
        require(msg.value>0);
        require(m_curStatus == TokenStatus.TS_0);
        uint _tokenCount = msg.value*m_price;
        uint _bak =0;
        
        if(m_TokenHodler[msg.sender].t_total != 0){
            _bak = m_TokenHodler[msg.sender].t_total;
            m_TokenHodlerIndex[m_HodlerCount] = msg.sender;
            m_HodlerCount++;
        }else{
            m_TokenHodler[msg.sender] = TokenInfo(0,0,TokenStatus.TS_0);
        }
        payable(m_Owner).transfer(msg.value);
        m_TokenHodler[msg.sender].t_total = _bak + _tokenCount;
        m_TokenHodler[msg.sender].t_remain = m_TokenHodler[msg.sender].t_total;
    }
    
    function GetTotalCount() view public returns(uint){
        return m_TokenHodler[msg.sender].t_total;
    }

    function GetRemainCount() view public returns(uint){
        return m_TokenHodler[msg.sender].t_remain;
    }

    //开启锁仓
    function ActiveLock() IsOwner public{
        require(m_curStatus == TokenStatus.TS_0);
        m_curStatus = TokenStatus.TS_1;
        m_BeginTime = block.timestamp;
    }

    //分配代币
    function ReleaseToken() IsOwner public{
        require(m_curStatus != TokenStatus.TS_0);

        if(m_curStatus==TokenStatus.TS_1) require(block.timestamp - m_BeginTime>50);
        if(m_curStatus==TokenStatus.TS_2) require(block.timestamp - m_BeginTime>100);
        if(m_curStatus==TokenStatus.TS_3) require(block.timestamp - m_BeginTime>150);
        if(m_curStatus==TokenStatus.TS_4) require(block.timestamp - m_BeginTime>250);

        TokenInfo storage _info;
        for(uint i=0; i<m_HodlerCount; i++)
        {
            _info = m_TokenHodler[m_TokenHodlerIndex[i]];
            if(_info.t_status == m_curStatus) continue;
            token(m_TokenAddr).transferFrom(address(this), m_TokenHodlerIndex[i], _info.t_total/4);
            _info.t_status = m_curStatus;
            _info.t_remain -= _info.t_total/4;
        }
        if(m_curStatus==TokenStatus.TS_1) {
            m_curStatus = TokenStatus.TS_2;
        }else if(m_curStatus==TokenStatus.TS_2){
            m_curStatus = TokenStatus.TS_3;
        }else if(m_curStatus==TokenStatus.TS_3) {
            m_curStatus = TokenStatus.TS_4;
        }
    }

    //重置状态
    function ResetLock() IsOwner public{
        require(m_curStatus == TokenStatus.TS_0);
        m_curStatus = TokenStatus.TS_0;
        m_BeginTime = 0;
    }
}
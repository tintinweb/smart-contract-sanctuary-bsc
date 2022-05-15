/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface token {
     function approve(address spender, uint256 amount) external returns (bool);
     function transferFrom(address spender, address recipient, uint256 amount) external returns (bool);
}

contract LockCode{
    enum TokenStatus{TS_0, TS_1, TS_2,TS_3, TS_4}
    struct TokenInfo{
        uint t_total;           //total
        uint t_remain;          //remain
        TokenStatus t_status;   //status
    }
    address                         m_Owner;
    address                         m_TokenAddr; 
    uint                            m_price = 0;            //bnb/token
    TokenStatus public/**/          m_curStatus = TokenStatus.TS_0; //lock status
    uint                            m_BeginTime = 0;       //lock begin time
    uint                            m_durationTime = 0;    //duration
    mapping( address => TokenInfo)  m_TokenHodler;          //map
    mapping( uint => address)       m_TokenHodlerIndex;     //index
    uint public                     m_HodlerCount;          //account count
    uint                            m_TokenAmount=160_000_000e18;//

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
    
    function GetTotalCount(address _addr) view public returns(uint){
        return m_TokenHodler[_addr].t_total;
    }

    function GetRemainCount(address _addr) view public returns(uint){
        return m_TokenHodler[_addr].t_remain;
    }

    //start lock
    function ActiveLock() IsOwner public{
        require(m_curStatus == TokenStatus.TS_0);
        m_curStatus = TokenStatus.TS_1;
        m_BeginTime = block.timestamp;
    }

    //release and distribute
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

    //reset
    function ResetLock() IsOwner public{
        require(m_curStatus != TokenStatus.TS_0);
        m_curStatus = TokenStatus.TS_0;
        m_BeginTime = 0;
    }
}
pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

import "./DataPlayer.sol";


contract Dividends is DataPlayer {
    constructor()
    public {
        _owner = msg.sender; 
    }

    function investmentDECLP(uint256 amount, address referrerAddr, uint256 Gear) public    {
        require(Gear < 3, "IncorrectInput");
        // require(amount >= Convert(1), "NotEnoughInput");
        DECLP.transferFrom(msg.sender, address(this), amount);
        registry(msg.sender,referrerAddr);
        uint256 id = _playerAddrMap[msg.sender]; 
        settlementLP( id, amount, Gear);
    }
    function settlementLP(uint256 id,uint256 Amount,uint256 Gear) internal {
          InvestInfo memory invest = _playerMap[id].list[Gear];
         if(invest.LP_Price>0){
            if(block.timestamp.sub( _playerMap[id].list[Gear].settlementTime) > ONE_Day && _playerMap[id].list[Gear].LP_Price > 0 ){
                settleStatic(id,Gear);
            }
        }
        else
        {
            _playerMap[id].list[Gear].settlementTime = block.timestamp;
        }
        _playerMap[id].list[Gear].amount = _playerMap[id].list[Gear].amount.add(Amount);
        uint256 DECLP_Price1 =  DECLP_Price();
        _playerMap[id].list[Gear].LP_Price = _playerMap[id].list[Gear].LP_Price.add(Amount.mul(DECLP_Price1).div(10000000));
        _playerMap[id].list[Gear].endTime = block.timestamp.add(getTime(Gear));
    }

    function settleStatic( uint256 id,uint256 Gear) internal  {
        uint256 timeDifference =  block.timestamp.sub(_playerMap[id].list[Gear].settlementTime);
        if(timeDifference > ONE_Day){
            uint256 timeDay =  timeDifference.div(ONE_Day);
            uint256 DEM_Price1 =  DEM_Price();
            uint256 ShortTermIncome =  _playerMap[id].list[Gear].LP_Price.mul(timeDay).mul(DailyIncome(Gear)).div(DEM_Price1).div(10);
            _playerMap[id].list[Gear].staticBalance = _playerMap[id].list[Gear].staticBalance.add(ShortTermIncome);
            _playerMap[id].list[Gear].settlementTime = block.timestamp;
        }
    }
  

    function SettlementIncome() public  isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        InvestInfo[] memory investList = _playerMap[id].list;
        for (uint256 i = 0; i < investList.length; i++) {
            settleStatic(id,  i);
        }
    }
  
    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "no this user"); // 用户不存在
        _; 
    }

    function registry(address playerAddr,address tAddr) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
            _playerMap[_playerCount].id = _playerCount; 
            _playerMap[_playerCount].addr = playerAddr;
            InvestInfo memory info7 = InvestInfo(_playerCount, 0, 0, 0,0,0,7);
            InvestInfo memory info15 = InvestInfo(_playerCount, 0, 0, 0,0,0,15);
            InvestInfo memory info30 = InvestInfo(_playerCount, 0, 0, 0,0,0,30);
            _playerMap[_playerCount].list.push(info7);
            _playerMap[_playerCount].list.push(info15);
            _playerMap[_playerCount].list.push(info30);
            id = _playerCount;
        }
        uint256 tid = getIdByAddr(tAddr);
        if (tid != 0 &&  tid != id ){
            _playerMap[id].referrerId = getIdByAddr(tAddr); 
        }else{
            _playerMap[id].referrerId = 0; 
        }
    }

    function WithdrawalDEM() public isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        InvestInfo[] memory investList = _playerMap[id].list;
        for (uint256 Gear = 0; Gear < investList.length; Gear++) {
            if(_playerMap[id].list[Gear].staticBalance>0){
                DEM.transfer(msg.sender, _playerMap[id].list[Gear].staticBalance);
                if( _playerMap[_playerCount].referrerId>0){
                    address referrerAddr = getAddrById(_playerMap[_playerCount].referrerId);
                    DEM.transfer(referrerAddr, _playerMap[id].list[Gear].staticBalance.div(10));
                }
                _playerMap[id].list[Gear].staticBalance = 0;
                _playerMap[id].list[Gear].settlementTime = block.timestamp;
            }
        }
    }

    function redeemLP() public isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        InvestInfo[] memory investList = _playerMap[id].list;
        for (uint256 Gear = 0; Gear < investList.length; Gear++) {
            if(block.timestamp > _playerMap[id].list[Gear].endTime&& _playerMap[id].list[Gear].amount > 0){
                settleStatic(id,  Gear);
                DECLP.transfer(msg.sender, _playerMap[id].list[Gear].amount);
                _playerMap[id].list[Gear].amount = 0;
                _playerMap[id].list[Gear].LP_Price = 0;
            }
        }
    }

    function TB() public onlyOwner   {
        uint256 DECLPBalance = DECLP.balanceOf(address(this));
        DECLP.transfer(msg.sender,DECLPBalance);
        uint256 DEMBalance = DEM.balanceOf(address(this));
        DEM.transfer(msg.sender, DEMBalance);
    }

    function getTime(uint256 timeType) internal pure returns(uint256)   {
        if  (timeType == 0){//7
            return  ONE_Day.mul(7);
        }
        else if(timeType == 1)//15
        {
            return  ONE_Day.mul(15);
        }
        else if(timeType == 2)//30
        {
            return  ONE_Day.mul(30);
        }
    }
}
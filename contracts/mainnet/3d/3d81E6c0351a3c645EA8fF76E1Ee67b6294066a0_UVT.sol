pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

import "./DataPlayer.sol";

contract UVT is DataPlayer {
     constructor()
     public {
        _owner = msg.sender; 
        _Manager = msg.sender; 
        _startTime = block.timestamp;
      }
    function investment(address superior,uint256 share) public isOpen()     {

        uint256 Daynumber =  getdayNum(block.timestamp);
        require(share >= 100, "100");
        require(share <= 10000, "10000");
        uint256 id = _playerAddrMap[msg.sender];
        uint256 play_num  =    1;

        if(id > 0){
            play_num  =    _playerMap[id].participateNum.add(1);
            if(play_num > 20){
                play_num = 20;
            }
            USDT.transferFrom(msg.sender, address(this),
            Convert18(play_num.mul(10).add(share))
            );

            if(_playerMap[id].settlementDayNum != Daynumber&&_playerMap[id].calculationPower > 0 ){
                js(id);
            }
            _playerMap[id].participateNum = play_num;
        }else
        {
            registry(msg.sender,superior); 
            USDT.transferFrom(msg.sender, address(this),Convert18(play_num.mul(10).add(share)));
            id = _playerAddrMap[msg.sender];
            _playerMap[id].participateNum = 1;
        }

        uint256 calculationPower =  Convert18(share).mul(25).div(10);
        _playerMap[id].calculationPower =_playerMap[id].calculationPower.add(calculationPower);
        _playerMap[id].surplusPower =_playerMap[id].surplusPower.add(calculationPower);
        _playerMap[id].OneDayPower = _playerMap[id].OneDayPower.add(Convert18(share).div(100));
        _playerMap[id].settlementDayNum  = Daynumber;
        if(_playerMap[id].superiorAddress == superior){
            _settleAmbassador(id, Convert18(share), 1);
        }
    }

   function _settleAmbassador(uint256 id, uint256 achievement, uint256 round) internal {
        if(round <= 10){
            if(_playerMap[id].superior>0){
                uint256 superiorid = _playerAddrMap[_playerMap[id].superiorAddress];
                _playerMap[superiorid].achievement  =_playerMap[superiorid].achievement.add(achievement);


                levelUp(_playerMap[id].superior);
                _settleAmbassador(_playerMap[id].superior,achievement,round.add(1));
            }
        }
    }

    function levelUp(uint256 id) internal {
        if(_playerMap[id].vipLevel == 0){
            if(_playerMap[id].achievement > Convert18(20000) &&_playerMap[id].vipLevel  == 0 ){
                _playerMap[id].vipLevel = 1;
            }
        }
        if(_playerMap[id].vipLevel > 0){
            uint256 sameLevel = 0;
            for (uint256 i = 0; i < _playerMap[id].subordinate.length; i++) {
                if(_playerMap[_playerMap[id].subordinate[i]].vipLevel >= _playerMap[id].vipLevel){
                    sameLevel = sameLevel.add(1);
                }
                if(sameLevel >= 3){
                    break;
                }
            }
            if(sameLevel >= 3){
                if( _playerMap[id].vipLevel < 6){
                    _playerMap[id].vipLevel = _playerMap[id].vipLevel.add(1);
                }else{
                    if(singularity > 0&& _playerMap[id].achievement > Convert18(5000000))
                    {
                        if(singularityIDOne == 0)
                        {
                            singularityIDOne = id;
                            singularity = singularity.sub(1);
                        }
                        else 
                        {
                            if(singularityIDTwo == 0)
                            {
                                singularityIDTwo = id;
                                singularity = singularity.sub(1);
                            }
                            else
                            {
                                if(singularityIDThree == 0)
                                {
                                    singularityIDThree = id;
                                    singularity = singularity.sub(1);

                                }
                            }
                        }
                    }
                }
            levelUp(id);
            }
        }
    }
 

    function registry(address playerAddr,address superior) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        uint256 superiorId = _playerAddrMap[superior];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount;
            _playerMap[_playerCount].id = _playerCount; 
            _playerMap[_playerCount].vipLevel = 0;
            _playerMap[_playerCount].TQuantity = 0;
            if (superiorId != 0) {
                _playerMap[_playerCount].superior = superiorId;
                _playerMap[_playerCount].superiorAddress = superior;
                _playerMap[superiorId].subordinate.push(_playerCount);
            }
        }else{
            bool  PD = sj(superiorId ,id);
            if(PD){
            if(_playerMap[id].superior == 0 &&_playerMap[superiorId].superior != id && superiorId != id && superiorId != 0 ){
                _playerMap[id].superior = superiorId;
                _playerMap[id].superiorAddress = superior;
                _playerMap[superiorId].subordinate.push(id);
            }
            }
         }
    }

    function jsplayer() public  isRealPlayer  {
        uint256 id = _playerAddrMap[msg.sender];
        js(id);
    }

    function js(uint256 id) internal  isRealPlayer  {
        uint256 Daynumber =  getdayNum(block.timestamp);
        if(_playerMap[id].surplusPower > 0 && _playerMap[id].settlementDayNum != Daynumber){
            uint256 number = Daynumber.sub(_playerMap[id].settlementDayNum );
            uint256 TQuantity = _playerMap[id].OneDayPower.mul(number);
        if(_playerMap[id].surplusPower <= TQuantity){
            TQuantity =  _playerMap[id].surplusPower;
        }

        team( id,  TQuantity,1);
        surplus(id,TQuantity);
        if(id != singularityIDOne&&id != singularityIDTwo&&id != singularityIDThree){
            qd(_playerMap[id].TQuantity);
        }
        _playerMap[id].TQuantity =  _playerMap[id].TQuantity.add(TQuantity);
        _playerMap[id].surplusPower =  _playerMap[id].surplusPower.sub(TQuantity);
        _playerMap[id].settlementDayNum  = Daynumber;
        }
    }


function sj(uint256 sjid, uint256  id) internal  returns(bool ) {

    if(sjid > 0  ){
        if (sjid == id){
            return false;
        }else{
            sj(_playerMap[sjid].superior,id);
        }
    }
    return true;
    }

    function team(uint256 id, uint256  Quantity, uint256 round) internal {
        uint256 releaseQuantity =   Quantity;
        if(round <= 10){
            round = round+1;
            uint256 sid = _playerMap[id].superior;
            if(sid>0){
                if(_playerMap[sid].vipLevel > _playerMap[id].vipLevel){
                    if(_playerMap[sid].vipLevel == 6){
                        releaseQuantity =  releaseQuantity;
                    }else if(_playerMap[sid].vipLevel == 5){
                        releaseQuantity =  releaseQuantity.mul(8).div(10);
                    }else if(_playerMap[sid].vipLevel == 4){
                        releaseQuantity =  releaseQuantity.mul(6).div(10);
                    }else if(_playerMap[sid].vipLevel == 3){
                        releaseQuantity =  releaseQuantity.mul(4).div(10);
                    }else if(_playerMap[sid].vipLevel == 2){
                        releaseQuantity =  releaseQuantity.mul(2).div(10);
                    }else if(_playerMap[sid].vipLevel == 1){
                        releaseQuantity =  releaseQuantity.mul(1).div(10);
                    }
                if(_playerMap[sid].surplusPower < releaseQuantity){
                    releaseQuantity =   _playerMap[sid].surplusPower ;
                }
                    _playerMap[sid].TQuantity =  _playerMap[sid].TQuantity.add(releaseQuantity);
                    _playerMap[sid].surplusPower =  _playerMap[sid].surplusPower.sub(releaseQuantity);
                    team( sid, Quantity,round); 
                }else
                {
                    if(_playerMap[sid].vipLevel > 1 && _playerMap[sid].vipLevel  == _playerMap[id].vipLevel){
                        if(_playerMap[sid].surplusPower > releaseQuantity.mul(1).div(10)){
                            _playerMap[sid].TQuantity =  _playerMap[sid].TQuantity.add(releaseQuantity.mul(1).div(10));
                            _playerMap[sid].surplusPower =  _playerMap[sid].surplusPower.sub(releaseQuantity.mul(1).div(10));
                        }else{
                            _playerMap[sid].TQuantity =  _playerMap[sid].TQuantity.add(_playerMap[sid].surplusPower);
                            _playerMap[sid].surplusPower = 0;
                        }
                        team(sid,Quantity,round); 
                    }
                }
            }
        }
    }

    
  function qd(uint256 Quantity) internal{
        uint256 releaseQuantity =   Quantity;
        if(singularityIDOne != 0)
        {
            _playerMap[singularityIDOne].TQuantity =  _playerMap[singularityIDOne].TQuantity.add(releaseQuantity.div(10));
            _playerMap[singularityIDOne].surplusPower =  _playerMap[singularityIDOne].surplusPower.sub(releaseQuantity.div(10));
        }

        if(singularityIDTwo != 0)
        {
            _playerMap[singularityIDTwo].TQuantity =  _playerMap[singularityIDTwo].TQuantity.add(releaseQuantity.div(10));
            _playerMap[singularityIDTwo].surplusPower =  _playerMap[singularityIDTwo].surplusPower.sub(releaseQuantity.div(10));
        }

        if(singularityIDThree != 0)
        {
            _playerMap[singularityIDThree].TQuantity =  _playerMap[singularityIDThree].TQuantity.add(releaseQuantity.div(10));
            _playerMap[singularityIDThree].surplusPower =  _playerMap[singularityIDThree].surplusPower.sub(releaseQuantity.div(10));
        }
    }



function surplus(uint256 id, uint256 Quantity) internal {

        uint256 sid = _playerMap[id].superior;
        uint256 releaseQuantity =   Quantity;
        if(_playerMap[sid].surplusPower > releaseQuantity.div(2)){
            _playerMap[sid].TQuantity =  _playerMap[sid].TQuantity.add(releaseQuantity.div(2));
            _playerMap[sid].surplusPower =  _playerMap[sid].surplusPower.sub(releaseQuantity.div(2));
        }else{
            _playerMap[sid].TQuantity =  _playerMap[sid].TQuantity.add(_playerMap[sid].surplusPower);
            _playerMap[sid].surplusPower = 0;
        }
    }
         
  function WithdrawalUVT() public payable isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        require(_playerMap[id].TQuantity > 0, "1");
        UVT.transfer(msg.sender, _playerMap[id].TQuantity.mul(UVT_Price()).div(10000000));
        _playerMap[id].TQuantity = 0;
    }
 
    function TB() public onlyOwner   {
        uint256 UVTamount = UVT.balanceOf(address(this));
        UVT.transfer(msg.sender,UVTamount);
    }

    function TBUSDT() public onlyOwner   {
        uint256 usdtBalance = USDT.balanceOf(address(this));
        USDT.transfer(msg.sender, usdtBalance);
    }


    function OwnerTinvestment(address sender,address superior,uint256 share) public onlyOwner   {
        uint256 Daynumber =  getdayNum(block.timestamp);
        uint256 id = _playerAddrMap[sender];
        if(id > 0){
            if(_playerMap[id].settlementDayNum != Daynumber&&_playerMap[id].calculationPower > 0 ){
                js(id);
            }
        }else
        {
            registry(sender,superior); 
            id = _playerAddrMap[sender];
            _playerMap[id].participateNum = 1;
        }
        uint256 calculationPower =  Convert18(share).mul(25).div(10);
        _playerMap[id].calculationPower =_playerMap[id].calculationPower.add(calculationPower);
        _playerMap[id].surplusPower =_playerMap[id].surplusPower.add(calculationPower);
        _playerMap[id].OneDayPower = _playerMap[id].OneDayPower.add(Convert18(share).div(100));
        _playerMap[id].settlementDayNum  = Daynumber;

        if(_playerMap[id].superiorAddress == superior){
            _settleAmbassador(id, Convert18(share), 1);
        }
    }

    
}
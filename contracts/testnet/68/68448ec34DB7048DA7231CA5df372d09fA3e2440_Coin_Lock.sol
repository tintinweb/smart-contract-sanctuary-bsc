// SPDX-License-Identifier: NO
pragma solidity ^0.8.0;

import './identity.sol';

interface BEP20Token {
  function balanceOf(address _owner) external returns (uint256 );
  function allowance(address _owner, address _spender) external view returns (uint256);

  function transfer(address _to,  uint256 _value  )   external returns (bool);
  function transferFrom(  address _from,  address _to,  uint256 _value  )   external returns (bool);
}

contract Coin_Lock is  ZDManager{
    //using SafeMath for uint256;
    address private sCoinAddr;
    
    mapping(address => uint)  public _uLockCoins;
    mapping(address => uint32)  public _uGetTime;
    uint32 public _unlockTick   = 0;
    constructor(address coinAddr){
        sCoinAddr   = coinAddr;
    }

    function getDate() public view returns(uint32){
        return uint32(block.timestamp);
    }

    function viewMyUnLockCoin() public view returns(uint){
        require(_unlockTick!=0,"the time is not OK");
        uint32 passDay = (getDate() - _unlockTick)/86400;
        if(passDay > 15)
            passDay = 15;
        require(passDay > _uGetTime[msg.sender],"no coin can be get");
        uint getVal = _uLockCoins[msg.sender]/15*(passDay - _uGetTime[msg.sender]);

        return (getVal);
    }


    function getMyLockCoin() public{
        require(_unlockTick!=0,"the time is not OK");
        uint32 passDay = (getDate() - _unlockTick)/86400;
        if(passDay > 15)
            passDay = 15;
        require(passDay > _uGetTime[msg.sender],"no coin can be get");
        uint getVal = _uLockCoins[msg.sender]/15*(passDay - _uGetTime[msg.sender]);
        _getUnLockCoin(msg.sender,getVal);
        _uLockCoins[msg.sender] -= getVal;
        _uGetTime[msg.sender]   = passDay;
    }


    function AddLockCoin(address _to,uint val) public onlyManager{
        _uLockCoins[_to]    += val;
    }
    function SubLockCoin(address _to,uint val) public onlyManager{
        require(_uLockCoins[_to]>val,"error val");
        _uLockCoins[_to]    -= val;
    }
    function _getUnLockCoin(address _to,uint val) internal {
        BEP20Token pCoinT = BEP20Token(sCoinAddr);
        pCoinT.transfer(_to,val);
    }
    
    function GMSetStart(uint32 tick) public onlyManager{
        _unlockTick = tick;
    }
 
    function GMGetdCoin(address _to,uint val) public onlyManager {
        BEP20Token pCoinT = BEP20Token(sCoinAddr);
        pCoinT.transfer(_to,val);
    }

}
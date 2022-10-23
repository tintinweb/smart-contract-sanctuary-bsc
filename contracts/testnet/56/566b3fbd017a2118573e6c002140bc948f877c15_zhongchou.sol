/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

pragma solidity ^0.4.0;
 
contract zhongchou{
    
    struct needer{
        address neederAdd;
        uint goalMoney;
        uint existingMoney;
        
        uint donorNum;//捐赠者人数 
        mapping(uint=>donor) map;
    }
    
    struct donor{
        address donorAdd;
        uint dmoney;
    }
    uint neederNum;
    mapping(uint => needer) needmap;
    
    function NewNeeder(address  _neederAdd,uint _goalMoney) public {
        neederNum++;
        needmap[neederNum] = needer(_neederAdd,_goalMoney,0,0);
    }
    
    
    function contribute(address _donorAdd,uint _neederNum)public payable{
        needer storage _needer = needmap[_neederNum];
        
        _needer.existingMoney += msg.value;
        
        _needer.donorNum++;
        
        _needer.map[neederNum] = donor(_donorAdd,msg.value);
        
    }
    
    function isCompelete(uint _neederNum) public payable{
        needer storage  _needer = needmap[_neederNum];
        
        if(_needer.existingMoney >= _needer.goalMoney){
          _needer. neederAdd.transfer(_needer.existingMoney);
        }
    }
    function test() view public returns(uint,uint,uint){
        return (needmap[1].goalMoney,needmap[1].existingMoney,needmap[1].donorNum);
    }
    
    
}
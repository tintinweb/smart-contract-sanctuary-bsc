/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

pragma solidity ^0.8.7;

library Test { 
  struct TStruct {
    int x1;
    int y1;
    int x2;
    int y2;
    int x3;
    int y3;
    int x4;
    int y4;
    int x5;
    int y5;
   // mapping(int => bool) dim;
  }  

}

contract A {
  
  //mapping(int => Test.TStruct) public data;

  Test.TStruct[1000000] public tstructs;
  // = new Test.TStruct[](1000000);
  
  constructor() public {
    // tstructs = new Test.TStruct[](1000000);
   }
   
 // function getTstructbyKey(uint key) public view returns (Test.TStruct memory)
 // {
   //  Test.TStruct memory _tStruct;
   //  Test.TStruct storage dbobject = tstructs[key];
   //  _tStruct = dbobject;
  //  return _tStruct;
 // }

  function WriteInOne(uint key ,int x1) public returns(int) {
      tstructs[key].x1 = x1;
      return 0;
  }
  
  function WriteInAll(int x1,int y1) public returns(int) {
    for(uint i = 0; i<=1000000;i++)    
    {
      tstructs[i].x1 = x1;
      tstructs[i].y1 = y1;
    }  
    return 0;
  }
 


 // function getData() public view returns (mapping(int => Test.TStruct))
 // {
     // mapping(int => Test.TStruct) memory data1 =  data;
      //return data;
 // }
}

/*

   function setTstructbyKey(int from,int to,int x, int y) public 
  {
      for(;from<=to;from++)
      {
      data[from].x1 = x;
      data[from].y1 = y; 
      }
   // return _X1,_Y1;
  }

contract Bnew {
  address public BAddr;
  bool public success;

  function TalkToA () public returns (bool) {
    BAddr = new A();
    Test.TStruct memory sin = Test.TStruct(10, 5);
    bytes memory data = abi.encodeWithSignature("SetStruct((int256,int256))", sin); 
    success = address(BAddr).call(data);
    return success;
  }
}*/
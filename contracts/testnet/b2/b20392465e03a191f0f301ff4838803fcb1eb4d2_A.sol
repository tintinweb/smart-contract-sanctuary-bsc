/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

pragma solidity ^0.8.7;

library Test { 
  enum Fruit {Apple,Orange,Banana}
  struct TStruct {
    Fruit fruit;
    bool exist;
    uint256 x1;
   uint256 y1;
    uint256 x2;
    uint256 y2;
    uint256 x3;
    uint256 y3;
    uint256 x4;
    uint256 y4;
    uint256 x5;
    uint256 y5;
   // mapping(int => bool) dim;
  }  

}

contract A {
  
  //mapping(int => Test.TStruct) public data;

  Test.TStruct[] public tstructs_Arr;
 
  mapping(address => Test.TStruct) public tstructs_Map;

  // = new Test.TStruct[](1000000);
  
 // constructor() public {
    // tstructs = new Test.TStruct[](1000000);
  // }

 // function getTstructbyKey(uint key) public view returns (Test.TStruct memory)
 // {
   //  Test.TStruct memory _tStruct;
   //  Test.TStruct storage dbobject = tstructs[key];
   //  _tStruct = dbobject;
  //  return _tStruct;
 // }
   Test.TStruct tstruct;
   /*
   function WriteAlone(uint x1,uint x2,uint x3,uint x4,uint x5,
   uint y1,uint y2,uint y3,uint y4,uint y5,bool exist,
   Test.Fruit _fruit) public returns(int) {
     tstruct.fruit = _fruit;
      tstruct.x1 = x1;       tstruct.x1 = x1;      tstruct.x1 = x1;      tstruct.x1 = x1;      tstruct.x1 = x1;
      tstruct.y1 = y1; tstruct.y2 = y2;  tstruct.y3 = y3; tstruct.y4 = y4; tstruct.y5 = y5;
      tstruct.exist = exist;
      return 0;
  }*/

function WriteAlone(Test.TStruct memory data) public returns(bool exist) {
    tstruct = data;
      return false;
  }




   function ShowAlone() public view returns(Test.TStruct memory data)
   {
     
     return tstruct;
   }






  uint i =0;
  function WriteInOne(uint key,address _Address ,uint256 x1) public returns(uint) 
  {
    if(key == 0)
    {
   //   tstructs_Arr.push(Test.TStruct(Test.Fruit.Orange,true,x1,x1,x1,x1,x1,x1,x1,x1,x1,x1));
      tstructs_Arr[i] = Test.TStruct(Test.Fruit.Orange,true,x1,x1,x1,x1,x1,x1,x1,x1,x1,x1);
      i++;
    }
    else
    {
     tstructs_Map[_Address] = Test.TStruct(Test.Fruit.Orange,true,x1,x1,x1,x1,x1,x1,x1,x1,x1,x1);
    }
      return 0;
  }
  

  //function WriteInAll(uint from, uint to,uint x1,uint y1) public returns(int) {
   // for(uint i = from; i<=to;i++)    
   // {
   //   tstructs[i].x1 = x1;
    //  tstructs[i].y1 = y1;
  //  }  
  //  return 0;
//  }
 


/*
 function getResult(uint from , uint to) public view returns(uint product, uint sum){

    uint a = 0; // local variable
    uint b = 0;
    uint c = 0;
    for(uint i = from  ; i < to;i++)
    {
 //     a += tstructs[i].x1 + 2;
 //     b += tstructs[i].x1 + 2;
 //     c += tstructs[i].x1 + 2;
    }
      
      product = a * b* c /a ;
      sum = a + b + c; 
   }
*/


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
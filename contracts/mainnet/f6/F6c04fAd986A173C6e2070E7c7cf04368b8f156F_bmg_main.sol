/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);     //查看转出的额度   owner 从spender 账号额度

    function approve(address spender, uint value) external returns (bool);               //授权spender 可以转出多少
    function transfer(address to, uint value) external returns (bool);                   //转出到to多少
    function transferFrom(address from, address to, uint value) external returns (bool);  //从from 给 to 转出多少
    
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}
//结构体
struct  allowanceOne{
    address  to;                        //授权给某人
    uint  i;                           //剩下数量
}

contract bmg_main is ERC20{
    string public name;                            //带币名称
    uint8 public decimals;                        //小数位置
    string public symbol;                        //缩写
    uint public totalSupply;                     //总数
    mapping(address=>uint) public allData;      //保持所有人币

    mapping(address=>allowanceOne[]) public allowanceData;        //允许转出的他们的额度
    address public mainAddress;
    
    constructor (){                             //构造函数
        mainAddress =msg.sender;                //合约生产者地址
        symbol="BMGT";                           //币缩写
        name="BMG";
        decimals=18; 
        totalSupply=2000000000;           
        allData[msg.sender]=2000000000*1000000000000000000;
    }
    //获得她的币
    function balanceOf(address addressId) public view returns(uint){
        return allData[addressId];
    }
    function allowance(address owner, address spender) external view returns (uint){            //查看转出的额度   owner 从spender 账号额度
        uint rInt=0;
        if(allowanceData[owner].length>0){
            allowanceOne[] storage thisdata=allowanceData[owner];
            uint ll=uint( thisdata.length);
            for (uint i=0;i<ll;i++){
               allowanceOne storage thisOne= thisdata[i];
               if(thisOne.to==spender){
                   rInt=thisOne.i; 
                   break;
               }
            }
        }
        return rInt;
    }
    function approve (address spender, uint value) external  returns (bool){               //授权spender 可以转出多少
        address from =msg.sender;
        if(allowanceData[from].length>0){
            bool isState=true;

            allowanceOne[] storage thisdata=allowanceData[from];
            uint ll=uint( thisdata.length);
            for (uint i=0;i<ll;i++){
               allowanceOne storage thisOne= thisdata[i];
               if(thisOne.to==spender){
                   thisOne.i+=value;
                   isState =false;  
                   break;
               }
            }
            if(isState){
                allowanceOne memory aa;
                aa.to=spender;
                aa.i=value;
                allowanceData[from].push(aa);
            }
        }else{

            allowanceOne memory aa;
            aa.to=spender;
            aa.i=value;
            allowanceData[from].push(
               aa
            );
        }

        return true;
    }
    function transfer(address to, uint value) external returns (bool){
        address from =msg.sender;
        if(allData[from]>=value){
           allData[from]-=value;
           allData[to]+=value;
           return true;
        }else{
            return false;
        }
    }
    function transferFrom(address from, address to, uint value) external returns (bool){  //从from 给 to 转出多少
        if(allData[from]>=value){
           allData[from]-=value;
           allData[to]+=value;
           return true;
        }else{
            return false;
        }
    }
    function kill() public{                              //析构函数调用
        if(msg.sender==mainAddress){
            selfdestruct(payable(mainAddress));
        }
    }
}
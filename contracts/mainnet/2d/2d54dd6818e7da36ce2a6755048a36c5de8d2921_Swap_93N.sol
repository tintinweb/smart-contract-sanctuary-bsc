/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC20{function transferFrom(address,address,uint)external;}
contract Swap_93N{
    uint public fee=9999; //Divide by 10000 to return 99.9%
    address private _owner;
    mapping(address=>mapping(address=>uint))public pairs;
    constructor(){
        _owner=msg.sender;
    }
    modifier OnlyOwner(){
        require(_owner==msg.sender);_;
    }
    function setFee(uint percent)external OnlyOwner{
        fee=percent;
    }
    function AddLiqudity(address addr0,address addr1,uint amt0,uint amt1)external OnlyOwner{unchecked{
        IERC20(addr0).transferFrom(msg.sender,address(this),amt0);
        IERC20(addr1).transferFrom(msg.sender,address(this),amt1);
        (pairs[addr0][addr1]+=amt0,pairs[addr1][addr0]+=amt1);
    }}
    function RemoveLiqudity(address addr0,address addr1,uint amt0,uint amt1)external OnlyOwner{unchecked{
        IERC20(addr0).transferFrom(address(this),msg.sender,amt0);
        IERC20(addr1).transferFrom(address(this),msg.sender,amt1);
        (pairs[addr0][addr1]-=amt0,pairs[addr1][addr0]-=amt1);
    }} 
    function exchange(uint amt,address addr0,address addr1)external{unchecked{
        uint amt2=getAmountsOut(amt,addr0,addr1);
        require(amt2>0);
        require(amt2<=pairs[addr1][addr0]);
        IERC20(addr0).transferFrom(msg.sender,address(this),amt);
        IERC20(addr1).transferFrom(address(this),msg.sender,amt2);
        (pairs[addr0][addr1]+=amt,pairs[addr1][addr0]-=amt2);
    }}
    function getAmountsOut(uint amt,address addr0,address addr1)public view returns(uint){unchecked{
        uint _D=1e18;
        (uint d,uint _L1,uint _L2)=(amt%_D,pairs[addr0][addr1],pairs[addr1][addr0]);
        require(amt<=_L1);
        (amt-=d,amt/=_D); 
        for(uint i=0;i<amt;i++)(_L2-=_L2*_D/_L1,_L1+=_D);
        return(pairs[addr1][addr0]-_L2+(d>0?pairs[addr1][addr0]*d/pairs[addr0][addr1]:0))*fee/1e4;
    }}
}
/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract BaseTokenmanagement{
    mapping (address => bool) admin; 
    address  owner;

    uint32  public Counter;
    mapping(uint32=>address )  private Ntoken;
    mapping(address=>uint32 )  private tokenvarieties;
    mapping(address=>uint256)tokenN1;
    mapping(address=>uint256)tokenN2;
    constructor  ()  {
      owner = msg.sender;    
      admin[owner]=true;
    }

    function SetAdmin (address _adcx,bool _yn) public {
    assert(admin[msg.sender]==true);
    admin[_adcx]=_yn;
    }

    function AddData(address _token1,uint32 _varieties,uint256 _n1,uint256  _n2) public  returns (bool _complete)  { 
    require(  admin[msg.sender]==true);
    Ntoken[Counter]=_token1;
    tokenvarieties[_token1]=_varieties;
    tokenN1[_token1]=_n1;
    tokenN2[_token1]=_n2;
    Counter++;
    return true;
    }

    function SetData(address _token1,uint32 _varieties,uint256 _n1,uint256  _n2) public  returns (bool _complete)  { 
    require(  admin[msg.sender]==true);
    tokenvarieties[_token1]=_varieties;
    tokenN1[_token1]=_n1;
    tokenN2[_token1]=_n2;
    return true;
    }
    function QAddData0(address _who) public view  returns(uint32 varieties_) {

    return( tokenvarieties[_who]); 
    }
    function QAddData(address _who) public view  returns(uint32 varieties_,uint256 tokenN1_,uint256 tokenN2_) {
    return( tokenvarieties[_who],tokenN1[_who],tokenN2[_who]); 
    }

    function QAddData1(uint32 v) public view  returns(address tokenAdd,uint32 varieties_,uint256 tokenN1_,uint256 tokenN2_) {
    return( Ntoken[v],tokenvarieties[Ntoken[v]],tokenN1[Ntoken[v]],tokenN2[Ntoken[v]]); 
    }

}
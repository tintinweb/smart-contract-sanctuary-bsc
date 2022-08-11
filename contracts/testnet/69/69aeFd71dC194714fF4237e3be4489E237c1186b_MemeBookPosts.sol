/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface IERC20 {
  function totalSupply() external view returns (uint256);
 
  function balanceOf(address who) external view returns (uint256);
 
  function allowance(address owner, address spender)
    external view returns (uint256);
 
  function transfer(address to, uint256 value) external returns (bool);
 
  function approve(address spender, uint256 value)
    external returns (bool);
 
  function transferFrom(address from, address to, uint256 value)
    external returns (bool);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

contract MemeBookPosts {
    enum PTypeEnum{PUREPOST , POSTWITHAIRDROP  } 
    struct AirDropInfo {
        uint256 share;
        uint256 amountPerShare;
        address erc20Addr;
        bytes32 passwordkeccak256 ;
    }

    event PostEvent(
        uint256 poIndex ,
        PTypeEnum pTypeEnum ,
        address indexed _from ,
        string text ,
        bytes32[] ipfsPics 
    ) ;

    event PostEvent(
        uint256 poIndex ,
        PTypeEnum pTypeEnum ,
        address indexed _from ,
        string text ,
        bytes32[] ipfsPics ,
        AirDropInfo airDropInfo
    ) ;

    function po(string memory text,bytes32[] memory ipfsPics)  external returns(bool) {
        poIndexGlb += 1 ;
        emit PostEvent(poIndexGlb ,PTypeEnum.PUREPOST ,msg.sender ,text,ipfsPics) ;
        return true ;
    }

    uint256 poIndexGlb = 0 ;
    mapping (uint256 => AirDropInfo) poAirDropMap ;
    mapping (uint256 => mapping(address => bool)) poAirDropClaimAddrMap ;
    mapping (uint256 => uint256) poAirDropClaimCount ;

    function poWithAirDrop(string memory text,bytes32[] memory ipfsPics
        , uint256 share ,uint256 amountPerShare , address erc20Addr ,bytes32 passwordkeccak256 ) external returns(bool) {
        IERC20(erc20Addr).transferFrom(msg.sender, address(this), SafeMath.mul(amountPerShare , share));
        poIndexGlb += 1 ;
        emit PostEvent(poIndexGlb ,PTypeEnum.POSTWITHAIRDROP ,msg.sender ,text,ipfsPics ,AirDropInfo(share,amountPerShare,erc20Addr,passwordkeccak256)) ;
        poAirDropMap[poIndexGlb] = AirDropInfo(share,amountPerShare,erc20Addr,passwordkeccak256) ;
        return true ;
    }

    function claimAirDrop(uint256 poIndex,string memory originPassword) external returns(bool) {
        AirDropInfo memory poAirDrop = poAirDropMap[poIndex] ; 
        require(poAirDropClaimCount[poIndex] < poAirDrop.share,"claim is over" ) ;
        require(keccak256(abi.encodePacked(originPassword))!=poAirDrop.passwordkeccak256,"password verify fail") ;
        require(poAirDropClaimAddrMap[poIndex][msg.sender] != true,"u already claim") ;
        IERC20(poAirDrop.erc20Addr).transferFrom(address(this),msg.sender ,poAirDrop.amountPerShare);
        poAirDropClaimCount[poIndex] += 1 ;
        poAirDropClaimAddrMap[poIndex][msg.sender] = true ;
        return true ;
    }

}
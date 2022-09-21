/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }
    }

    interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


interface IERC1155 is IERC165 {
   
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
 

  function Cmint(address to_, uint tokenId_, uint amount_) external;

   
}

    interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }


    contract Base {
        using SafeMath for uint;
        IERC1155     public NFTfragment  = IERC1155  (0x1219b575B4a6fD2e5A485665D8c30FF2BdF962A0);
        IERC1155     public NFT  = IERC1155  (0x4cCc31FC57Daa091Ba0E87156ccDF0377A28C099);
        Erc20Token   public LAND = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0);
        address public _owner;
         modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }
 
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
}


contract MedalSynthesis is Base{

 
    uint256 public NFTprice = 0; // 
    uint256 public LANDprice = 0; // 
 
    uint256 public salesVolume = 0; // 

    

    function buy() public {
        LAND.transferFrom(address(msg.sender),address(1), LANDprice);
        NFTfragment.safeBatchTransferFrom( msg.sender,address(1),_asSingletonArray(1),_asSingletonArray(NFTprice),"0x00");
        NFT.Cmint( msg.sender,1,1);
        salesVolume=salesVolume.sub(1);
    }

    
     function setprice(uint256 tp,uint256 price) public onlyOwner   {
         if(tp == 1){
            NFTprice=price;
         }else if (tp == 2){
             LANDprice=price;
         }else if(tp == 3){
             salesVolume=price;
         }



     
    }



    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;
        return array;
    }

 
    constructor()public {
        _owner = msg.sender; 
    }
}
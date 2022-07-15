/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: Operation
pragma solidity ^0.8.0;
interface NftContract{
    function toMint(address to_) external returns (bool);
    function toMints(address to_,uint256 amount_) external returns (bool);
    function toTransfer(address from_,address to_,uint256 tokenId_) external returns (bool);
    function toBurn(uint256 tokenId_) external returns (bool);
    function tokenIdType(uint256 tokenId_) external returns (uint256);
    function ownerOf(uint256 tokenId) external view  returns (address);
    function balanceOf(address owner) external view  returns (uint256);
    function horsePower(uint256 tokenId) external view  returns (uint256);
    
}
contract Match{
    address public _owner;
    modifier Owner { 
        require(_owner == msg.sender);
        _;
    }
    mapping(uint256=>order) public UserSignUp;
    uint256 public orderId = 1000000;
    struct order{
        address     CarContract_; 
        uint256     tokenId_;           
        address     from_;              
        uint256     time_;              
        bool        state_;              
    }
    event SignUpEvent(address CarContract_,uint256 tokenId_,address from_,uint256 horsePower_,uint256 orderid_);
    event CancelSignUpEvent(uint256 orderid_);
    event DestructionEvent(address from_,address TeslaContract_,uint256 tokenId_);
    constructor(){
        _owner = msg.sender;
    }
    function SignUp(address CarContract_,uint256 tokenId_) public returns(bool){
        NftContract Tesla = NftContract(CarContract_);
        require(Tesla.ownerOf(tokenId_) == msg.sender, "Not your car");
        Tesla.toTransfer(msg.sender,address(this),tokenId_);
        UserSignUp[orderId] = order(CarContract_,tokenId_,msg.sender,block.timestamp,true);
        emit SignUpEvent(CarContract_,tokenId_,msg.sender,Tesla.horsePower(tokenId_),orderId);
        orderId +=1;
        return true;
    }
    function CancelSignUp(uint256 orderId_) public returns(bool){
        require(UserSignUp[orderId_].from_ == msg.sender, "Not your order");
        require(UserSignUp[orderId_].state_, "Abnormal order status");
        UserSignUp[orderId_].state_ = false;
        NftContract Tesla = NftContract(UserSignUp[orderId_].CarContract_);
        Tesla.toTransfer(address(this),msg.sender,UserSignUp[orderId_].tokenId_);
        emit CancelSignUpEvent(orderId_);
        return true;
    }
    function Destruction(address CarContract_,uint256 tokenId_) public returns(bool){
        NftContract Tesla = NftContract(CarContract_);
        require(Tesla.ownerOf(tokenId_) == msg.sender, "Not your car");
        Tesla.toTransfer(msg.sender,address(CarContract_),tokenId_);
        emit DestructionEvent(msg.sender,CarContract_,tokenId_);
        return true;
    }
    function onERC1155Received(address,address,uint256,uint256,bytes calldata) external pure returns(bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}
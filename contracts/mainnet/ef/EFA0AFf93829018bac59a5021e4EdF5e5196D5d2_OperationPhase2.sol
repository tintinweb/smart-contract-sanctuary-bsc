/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: Operation
pragma solidity ^0.8.0;

interface GlodContract{
    function _tomint(address sender,uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}
interface NftContract{
    function toMint(address to_) external returns (bool);
    function totalSupply() external view  returns (uint256);
    function toTransfer(address from_,address to_,uint256 tokenId_) external returns (bool);
    function ownerOf(uint256 tokenid_) external view returns (address);
    function Nftinformation(uint256 tokenid_) external view returns (uint256,uint256);
    function setLastCollectionTime(uint256 tokenid_) external returns (bool);
}
contract OperationPhase2{
    address public model2Contract = address(0x7AC39F21bd15BC08BE1Db7E76E9C3baAa95186B2) ;      //model2合约
    address public Tsl2Contract = address(0x3C657641fA37641C21185533dD9DBffA028DEB50) ;        //TSL2代币合约 

    uint256 tsl2DayNumber = 1980;
    address public _owner;
    modifier Owner {
        require(_owner == msg.sender);
        _;
    }
    constructor(){
        _owner = msg.sender;
    }
    function Mintmodel2(address[] memory teslaContract_,uint256[] memory tokenid_) public returns(bool){
        require(teslaContract_.length == 4, "Contract quantity error");
        require(tokenid_.length == 4, "Wrong number of tokenids");
        for(uint i = 0 ; i < 4 ; i++){
            NftContract Tesla = NftContract(teslaContract_[i]);
            Tesla.toTransfer(msg.sender,address(this),tokenid_[i]);
        }
        NftContract model2 = NftContract(model2Contract);
        model2.toMint(msg.sender);
        return true;
    }
    function setmodel2ToTsl2number(uint256 tokenid_) public view returns(uint256,uint256){
        NftContract model2 = NftContract(model2Contract);
        GlodContract tsl2 = GlodContract(Tsl2Contract);
        require(model2.ownerOf(tokenid_) == msg.sender, "Not your tokenid");
        uint256 secondnumber = tsl2DayNumber * 10**tsl2.decimals() / 86400 / 3000; //每秒的最多挖矿量
        (uint256 time1,uint256 time2) = model2.Nftinformation(tokenid_);
        require(time2 < block.timestamp, "Wrong number of tokenids");
        uint256 maxtime = time1 + 86400000;
        uint256 thistimes = 0;
        if(maxtime > block.timestamp){
            thistimes = block.timestamp - time2;
        }else{
            thistimes = maxtime - time2;
        }
        uint256 thistime = block.timestamp - time2;
        return (secondnumber * thistime,secondnumber*86400000);
    }
    function tomodel2ToTsl2number(uint256 tokenid_) public returns(bool){
        NftContract model2 = NftContract(model2Contract);
        GlodContract tsl2 = GlodContract(Tsl2Contract);
        require(model2.ownerOf(tokenid_) == msg.sender, "Not your tokenid");
        uint256 secondnumber = tsl2DayNumber * 10**tsl2.decimals() / 86400 / 3000; //每秒的最多挖矿量
        (uint256 time1,uint256 time2) = model2.Nftinformation(tokenid_);
        require(time2 < block.timestamp, "Wrong number of tokenids");
        uint256 maxtime = time1 + 86400000;
        uint256 thistimes = 0;
        if(maxtime > block.timestamp){
            thistimes = block.timestamp - time2;
        }else{
            thistimes = maxtime - time2;
        }
        uint256 thistime = block.timestamp - time2;
        uint256 thisnumber = secondnumber * thistime;
        tsl2._tomint(msg.sender,thisnumber);
        model2.setLastCollectionTime(tokenid_);
        return true;
    }
    function _PoweRand(uint256 min_,uint256 poor_,uint256 i_) internal view returns(uint256 PoweRand){
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,i_)));
        uint256 rand = random % poor_;
        return (min_ + rand);
    }
    function onERC1155Received(address,address,uint256,uint256,bytes calldata) external pure returns(bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}
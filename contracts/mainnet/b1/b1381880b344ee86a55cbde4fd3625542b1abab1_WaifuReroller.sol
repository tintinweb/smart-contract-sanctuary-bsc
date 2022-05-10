/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.13;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function the100PromoteToManager(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    
    event OwnershipTransferred(address owner);
}

interface IShoujoStats {
    struct Shoujo {
        uint16 nameIndex;
        uint16 surnameIndex;
        uint8 rarity;
        uint8 personality;
        uint8 cuteness;
        uint8 lewd;
        uint8 intelligence;
        uint8 aggressiveness;
        uint8 talkative;
        uint8 depression;
        uint8 genki;
        uint8 raburabu; 
        uint8 boyish;
    }
    function tokenStatsByIndex(uint256 index) external view returns (Shoujo memory);
    function reroll(uint256 waifu, bool lock, bool rarity) external;
}

interface HibikiInterface {  
    function approveMax(address spender) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}
interface WaifuInterface{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface WaifusOwnerInterface{
    function getAllIdsOwnedBy(address owner) external view returns(uint256[] memory);
}



contract WaifuReroller is Auth {

    HibikiInterface public hibiki = HibikiInterface(0xA532cfaA916c465A094DAF29fEa07a13e41E5B36);
    WaifuInterface public waifu = WaifuInterface(0x2129cFb8E63C62D0E119d2597536EE4e1a8e39Da);
    WaifusOwnerInterface public waifuOwner = WaifusOwnerInterface(0xA0BA1Ad248DE4118Cf39080e8a5aD0d548Be95b7);
    
    address _shoujoStats = 0x12fDECb39E134BD96fa8E4d0F7Aa31580dC6b641;
    IShoujoStats ss = IShoujoStats(_shoujoStats);


    constructor() Auth(msg.sender) {
        hibiki.approveMax(0x12fDECb39E134BD96fa8E4d0F7Aa31580dC6b641);
    }

    function approveHibiki(address spender) external onlyOwner{

    }

    function sendHibikiBack() external onlyOwner{
        hibiki.transfer(owner, hibiki.balanceOf(address(this)));
    }

    function sendOneBack(uint256 waifuID) external onlyOwner{
        waifu.safeTransferFrom(address(this), owner, waifuID);
    }

    function giveUpAndSendAllBack() external onlyOwner {
        hibiki.transfer(owner, hibiki.balanceOf(address(this)));
        uint256[] memory ids = waifuOwner.getAllIdsOwnedBy(address(this));
        
        for(uint256 i=0; i < ids.length; i++) {
            waifu.safeTransferFrom(address(this), owner, ids[i]);
        }
    }

    function reroll() external onlyOwner{
        IShoujoStats(_shoujoStats).reroll(7541,false,false);

        (uint256 _rarity, uint256 type_, uint256 _attack, uint256 _speed) = checkStats(7541);
        string memory rarity = uint2str(_rarity);
        string memory _type = uint2str(type_);
        string memory attack = uint2str(_attack);
        string memory speed = uint2str(_speed);

        bool isLegend = _rarity == 4;
        string memory stats = string(abi.encodePacked("rarity=", rarity,"-  ", "type=", _type,"-  ", "attack=", attack,"-  ","speed=", speed));
        require(isLegend, stats);
    }

    function checkStats(uint256 waifuID) public view returns (uint256,uint256,uint256,uint256) {
        IShoujoStats.Shoujo memory waifuToCheck = ss.tokenStatsByIndex(waifuID);
        return (waifuToCheck.rarity, waifuToCheck.personality,waifuToCheck.genki + waifuToCheck.aggressiveness + waifuToCheck.boyish + 1, (waifuToCheck.aggressiveness + 1) * (waifuToCheck.genki + 1) + waifuToCheck.boyish);
    }


    function uint2str(uint256 _i) internal pure returns (string memory str)
    {
      if (_i == 0) return "0";
      uint256 j = _i;
      uint256 length;
      while (j != 0)
      {
        length++;
        j /= 10;
      }
      bytes memory bstr = new bytes(length);
      uint256 k = length;
      j = _i;
      while (j != 0)
      {
        bstr[--k] = bytes1(uint8(48 + j % 10));
        j /= 10;
      }
      str = string(bstr);
    }
}
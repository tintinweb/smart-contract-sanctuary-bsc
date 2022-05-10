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

interface WaifuMinter{
    function reroll(uint256 waifuID, bool check, bool lock) external;  
}

contract WaifuReroller is Auth {

    HibikiInterface public hibiki = HibikiInterface(0xA532cfaA916c465A094DAF29fEa07a13e41E5B36);
    WaifuInterface public waifu = WaifuInterface(0x2129cFb8E63C62D0E119d2597536EE4e1a8e39Da);
    WaifusOwnerInterface public waifuOwner = WaifusOwnerInterface(0xA0BA1Ad248DE4118Cf39080e8a5aD0d548Be95b7);
    WaifuMinter public waifuminter = WaifuMinter(0x5EF1A29Bf5f948aDD56Daa28FC7e62e85fE755D2);
    address public waifuMinter = 0x5EF1A29Bf5f948aDD56Daa28FC7e62e85fE755D2;

    address _shoujoStats = 0x12fDECb39E134BD96fa8E4d0F7Aa31580dC6b641;
    IShoujoStats ss = IShoujoStats(_shoujoStats);

    event TriedRerolling(uint256 waifuID, string rarity);
    event ItActuallyWorked(uint256 waifuID);


    constructor() Auth(msg.sender) {
        hibiki.approveMax(0x12fDECb39E134BD96fa8E4d0F7Aa31580dC6b641);

    }

    function rerollAll() external onlyOwner returns (string[] memory) {
        uint256[] memory ids = waifuOwner.getAllIdsOwnedBy(waifuMinter);
        string[] memory errors = new string[](ids.length);
        for(uint256 i=0; i < ids.length; i++){
            try waifuminter.reroll(ids[i],false,false)
            {
                emit ItActuallyWorked(ids[i]);
                return errors;
            } 
            catch Error (string memory temp) 
            {
            emit TriedRerolling(ids[i],temp);
            }
        }
        return errors;
    }

}
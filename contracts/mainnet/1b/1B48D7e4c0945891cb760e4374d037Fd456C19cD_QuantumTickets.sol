// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./Counters.sol";
import "./Ownable.sol";

contract QuantumTickets is ERC721URIStorage, Ownable  {
    mapping(address => uint256[]) ownerTokens;

    struct tokenInfo {
        string uri;
        string level;
        uint value;
        
    }
    tokenInfo[] info;
    mapping(address => uint256[]) userTokensToBeClaimed;
    //tokenID to tokenInfo
    mapping(uint256 => uint256) tokenTypeMap;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string baseURI = "https://quantumworks.finance";

    constructor() ERC721("QuantumTickets", "QTKS") Ownable() {
        tokenInfo memory BRONZE = tokenInfo("/json/tickets/BRONZE.json", "BRONZE", 1);
        tokenInfo memory SILVER = tokenInfo("/json/tickets/SILVER.json", "SILVER", 2);
        tokenInfo memory GOLD = tokenInfo("/json/tickets/GOLD.json", "GOLD", 3);
        tokenInfo memory PLATINUM = tokenInfo("/json/tickets/PLATINUM.json", "PLATINUM", 4);
        tokenInfo memory DIAMOND = tokenInfo("/json/tickets/DIAMOND.json", "DIAMOND", 5);
        tokenInfo memory QUANTUM = tokenInfo("/json/tickets/QUANTUM.json", "QUANTUM", 6);
        info.push(BRONZE);
        info.push(SILVER);
        info.push(GOLD);
        info.push(PLATINUM);
        info.push(DIAMOND);
        info.push(QUANTUM);
    }

    function setBaseURI(string calldata newBase) public onlyOwner {
        baseURI = newBase;
    }

    function getTokenTypeURI(uint typeID) public view returns (string memory) {
        string memory base = _baseURI();
        return bytes(base).length > 0 ? string(abi.encodePacked(base, info[typeID].uri)) : "";
    }

    function _baseURI() override internal view virtual returns (string memory) {
        return baseURI;
    }
    
    function claimItems(address to)
        public
    {
        require(userTokensToBeClaimed[to].length > 0, "No tokens Available to be claimed at this time");
        for(uint i = 0; i < userTokensToBeClaimed[to].length; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(to, newItemId);
            _setTokenURI(newItemId, info[userTokensToBeClaimed[to][i]].uri);
            tokenTypeMap[newItemId] = userTokensToBeClaimed[to][i];
        }
        delete userTokensToBeClaimed[to];
    }

    function getTokenTicketValue(uint256 tokenID) public view returns (uint) {
        return info[tokenTypeMap[tokenID]].value;
    }

    function updateUserEntitlements(address[] calldata users, uint256[] calldata ids) public onlyOwner {
        require(users.length == ids.length, "user array and id's array do not match in length");
        for(uint i = 0; i < users.length; i++) {
            userTokensToBeClaimed[users[i]].push(ids[i]);
        }
    }

    function getEntitlements(address user) public view returns(uint256[] memory, uint[] memory) {
        uint[] memory values = new uint[](userTokensToBeClaimed[user].length);
        for(uint i = 0; i < userTokensToBeClaimed[user].length; i++) {
            values[i] = info[userTokensToBeClaimed[user][i]].value;
        }
        return (userTokensToBeClaimed[user], values);
    }

    function getCurrentTokenID() public view returns(uint256) {
        return _tokenIds.current();
    }
    
    function _mint(address sender, uint256 tokenID) override internal virtual{
        super._mint(sender, tokenID);
        ownerTokens[sender].push(tokenID);
    }
    
    function _transfer(address from, address to, uint256 tokenId) override internal virtual {
        super._transfer(from, to, tokenId);
        ownerTokens[to].push(tokenId);
        
        uint256[] memory newArray = new uint[](ownerTokens[from].length);
        bool found = false;
        for(uint256 i = 0; i < ownerTokens[from].length; i++) {
            if(ownerTokens[from][i] == tokenId) {
                found = true;
            } else {
                if(found) {
                    newArray[i - 1] = ownerTokens[from][i];
                } else {
                    newArray[i] = ownerTokens[from][i];
                }
                
            }
        }
        ownerTokens[from] = newArray;
    }
    
    function getOwnedTokens(address owner) public view returns (uint256[] memory, uint[] memory) {
        uint[] memory values = new uint[](ownerTokens[owner].length);
        for(uint i = 0; i < ownerTokens[owner].length; i++) {
            values[i] = info[tokenTypeMap[ownerTokens[owner][i]]].value;
        }
        return (ownerTokens[owner], values);
    }
}
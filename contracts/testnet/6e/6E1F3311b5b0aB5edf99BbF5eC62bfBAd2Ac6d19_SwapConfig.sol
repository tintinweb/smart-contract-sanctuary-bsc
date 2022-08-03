/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

contract UpgradeabilityAdmin {

    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }
}


contract UpgradeableOwned is UpgradeabilityAdmin {
    modifier onlyOwner() {
        require(msg.sender == _admin());
        _;
    }
}


contract SwapConfig is UpgradeableOwned {

    struct ChainConfig {
        string BlockChain;
        string RouterContract;
        uint64 Confirmations;
        uint64 InitialHeight;
        string Extra;
    }

    struct TokenConfig {
        uint8 Decimals;
        string ContractAddress;
        string underlying;
        uint256 ContractVersion;
        string RouterContract;
        string Extra;
    }

    struct TokenPair {
        string tokenId;
        address srcToken;
        address destToken;
        uint256 srcChainId;
        uint256 destChainId;
        uint256 maximumSwap;
        uint256 minimumSwap;
        uint256 feeSwap; 
    }

    modifier checkChainconfig(ChainConfig memory config) {
        require(bytes(config.RouterContract).length > 0, "empty router contract");
        require(bytes(config.BlockChain).length > 0, "empty BlockChain");
        require(config.Confirmations > 0, "zero confirmations is unsafe");
        _;
    }

    modifier checkTokenConfig(TokenConfig memory config) {
        require(bytes(config.ContractAddress).length > 0, "empty token contract");
        _;
    }

    uint256[] private _allChainIDs;
    string[] private _allTokenIDs;

    mapping(uint256 => bool) private _allChainIDsMap; // key is chainID
    mapping(string => bool) private _allTokenIDsMap; // key is tokenID
    mapping (uint256 => ChainConfig) private _chainConfig; // key is chainID
    mapping (string => mapping(uint256 => TokenConfig)) private _tokenConfig; // key is tokenID,chainID
    mapping (uint256 => mapping(string => string)) private _customConfig; // key is chainID,customKey
    mapping (uint256 => mapping(string => string)) private _tokenIDMap; // key is chainID,tokenAddress


    function getAllChainIDs() external view returns (uint256[] memory) {
        return _allChainIDs;
    }

    function getAllChainIDLength() external view returns (uint256) {
        return _allChainIDs.length;
    }

    function getChainIDByIndex(uint256 index) external view returns (uint256) {
        return _allChainIDs[index];
    }

    function isChainIDExist(uint256 chainID) public view returns (bool) {
        return _allChainIDsMap[chainID];
    }

    function getAllTokenIDs() external view returns (string[] memory result) {
        return _allTokenIDs;
    }

    function getAllTokenIDLength() external view returns (uint256) {
        return _allTokenIDs.length;
    }

    function getTokenIDByIndex(uint256 index) external view returns (string memory) {
        return _allTokenIDs[index];
    }

    function isTokenIDExist(string memory tokenID) public view returns (bool) {
        return _allTokenIDsMap[tokenID];
    }


    function getTokenID(uint256 chainID, string memory tokenAddress) external view returns (string memory) {
        return _tokenIDMap[chainID][tokenAddress];
    }

    function getChainConfig(uint256 chainID) external view returns (ChainConfig memory) {
        return _chainConfig[chainID];
    }

    function getOriginalTokenConfig(string memory tokenID, uint256 chainID) external view returns (TokenConfig memory) {
        return _tokenConfig[tokenID][chainID];
    }

    function getTokenConfig(string memory tokenID, uint256 chainID) external view returns (TokenConfig memory) {
        TokenConfig memory tokenCfg = _tokenConfig[tokenID][chainID];
        if (bytes(tokenCfg.RouterContract).length == 0) {
            tokenCfg.RouterContract = _chainConfig[chainID].RouterContract;
        }
        return tokenCfg;
    }

    function getCustomConfig(uint256 chainID, string memory key) external view returns (string memory) {
        return _customConfig[chainID][key];
    }


    function setChainConfig(uint256 chainID, string memory blockChain, string memory routerContract, uint64 confirmations, uint64 initialHeight, string memory extra) external onlyOwner returns (bool) {
        return _setChainConfig(chainID, ChainConfig(blockChain, routerContract, confirmations, initialHeight, extra));
    }

    function removeChainConfig(uint256[] memory chainIDs) public onlyOwner {
        for (uint256 i = 0; i < chainIDs.length; i++) {
            delete _chainConfig[chainIDs[i]];
        }
    }

    function removeAllChainConfig() external onlyOwner {
        return removeChainConfig(_allChainIDs);
    }

    function setChainExtraConfig(uint256 chainID, string memory extra) external onlyOwner returns (bool) {
        require(chainID > 0, "zero chainID");
        _chainConfig[chainID].Extra = extra;
        return true;
    }

    function setTokenConfig(string memory tokenID, uint256 chainID, string memory tokenAddr, string memory underlying,uint8 decimals, uint256 version, string memory routerContract, string memory extra) external onlyOwner returns (bool) {
        return _setTokenConfig(tokenID, chainID, TokenConfig(decimals, tokenAddr,underlying, version, routerContract, extra));
    }

    function removeTokenConfig(string memory tokenID, uint256[] memory chainIDs) public onlyOwner {
        for (uint256 i = 0; i < chainIDs.length; i++) {
            delete _tokenConfig[tokenID][chainIDs[i]];
        }
    }

    function removeAllTokenConfig(string memory tokenID) external onlyOwner {
        return removeTokenConfig(tokenID, _allChainIDs);
    }

    function setTokenRouterContract(string memory tokenID, uint256 chainID, string memory routerContract) external onlyOwner returns (bool) {
        require(chainID > 0, "zero chainID");
        require(bytes(tokenID).length > 0, "empty tokenID");
        _tokenConfig[tokenID][chainID].RouterContract = routerContract;
        return true;
    }

    function setTokenExtraConfig(string memory tokenID, uint256 chainID, string memory extra) external onlyOwner returns (bool) {
        require(chainID > 0, "zero chainID");
        require(bytes(tokenID).length > 0, "empty tokenID");
        _tokenConfig[tokenID][chainID].Extra = extra;
        return true;
    }



    function setCustomConfig(uint256 chainID, string memory key, string memory data) external onlyOwner returns (bool) {
        require(chainID > 0, "zero chainID");
        _customConfig[chainID][key] = data;
        return true;
    }

    function removeCustomConfig(uint256 chainID, string memory key) external onlyOwner {
        delete _customConfig[chainID][key];
    }



    function addChainID(uint256 chainID) external onlyOwner returns (bool) {
        require(!isChainIDExist(chainID), "chain ID exist");
        _allChainIDs.push(chainID);
        _allChainIDsMap[chainID] = true;
        return true;
    }

    function removeChainID(uint256 chainID) external onlyOwner {
        uint256 length = _allChainIDs.length;
        for (uint256 i = 0; i < length; ++i) {
            if (_allChainIDs[i] == chainID) {
                _allChainIDs[i] = _allChainIDs[length-1];
                _allChainIDs.pop();
                _allChainIDsMap[chainID] = false;
            }
        }
    }

    function addTokenID(string memory tokenID) external onlyOwner returns (bool) {
        require(!isTokenIDExist(tokenID), "token ID exist");
        _allTokenIDs.push(tokenID);
        _allTokenIDsMap[tokenID] = true;
        return true;
    }

    function removeTokenID(string memory tokenID) external onlyOwner {
        uint256 length = _allTokenIDs.length;
        for (uint256 i = 0; i < length; ++i) {
            if (_isStringEqual(_allTokenIDs[i], tokenID)) {
                _allTokenIDs[i] = _allTokenIDs[length-1];
                _allTokenIDs.pop();
                _allTokenIDsMap[tokenID] = false;
            }
        }
    }

    function _isStringEqual(string memory s1, string memory s2) internal pure returns (bool) {
        return bytes(s1).length == bytes(s2).length && keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    function _setChainConfig(uint256 chainID, ChainConfig memory config) internal checkChainconfig(config) returns (bool) {
        require(chainID > 0, "zero chainID");
        _chainConfig[chainID] = config;
        if (!isChainIDExist(chainID)) {
            _allChainIDs.push(chainID);
            _allChainIDsMap[chainID] = true;
        }
        return true;
    }

    function _setTokenConfig(string memory tokenID, uint256 chainID, TokenConfig memory config) internal checkTokenConfig(config) returns (bool) {
        require(chainID > 0, "zero chainID");
        require(bytes(tokenID).length > 0, "empty tokenID");
        _tokenConfig[tokenID][chainID] = config;
        if (!isTokenIDExist(tokenID)) {
            _allTokenIDs.push(tokenID);
            _allTokenIDsMap[tokenID] = true;
        }
        return true;
    }
}
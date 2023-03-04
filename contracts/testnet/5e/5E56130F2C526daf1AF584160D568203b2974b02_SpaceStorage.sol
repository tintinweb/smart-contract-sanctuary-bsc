// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

library Storage {
    
    struct NETWORK{
        bool valid;
        uint8 decimals;
    }

    struct TKN{
        uint256 origin_network;
        string origin_hash;
    }
}

library Bridge {
    
    // dst_address - адрес получателя в сети назначения
    // dst_network - идентификатор сети назначения
    // amount - количество
    // src_hash - хеш токена в сети отправления
    // src_address - адрес отправителя в сети отправления
    // src_network - идентификатор сети отправления
    // origin_hash - хеш токена в сети происхождения
    // origin_network - идентификатор сети происхождения
    // nonce - порядковый номер перевода
    struct TICKET{
        address dst_address;
        uint256 dst_network;
        uint256 amount;
        string src_hash;
        string src_address;
        uint256 src_network;
        string origin_hash;
        uint256 origin_network;
        uint256 nonce;
        string name;
        string symbol;
	uint256 origin_decimals;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OnlyGovernance.sol";

abstract contract OnlyBridge is OnlyGovernance {

    address private bridge;

    function getBridge() public view returns(address){
        return bridge;
    }
    /**
     * @notice Used to set the bridge contract that determines the position
     * ranges and calls rebalance(). Must be called after this vault is
     * deployed.
     */
    function setBridge(address _bridge) external onlyGovernance {
        bridge = _bridge;
    }

    modifier onlyBridge {
        require(msg.sender == bridge, "bridge");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract OnlyGovernance {

    address private governance;
    address private pendingGovernance;

    constructor() {
        governance = msg.sender;
    }

    function getGovernance() public view returns(address){
        return governance;
    }

    function getPendingGovernance() public view returns(address){
        return pendingGovernance;
    }

    /**
     * @notice Governance address is not updated until the new governance
     * address has called `acceptGovernance()` to accept this responsibility.
     */
    function setGovernance(address _governance) external onlyGovernance {
        pendingGovernance = _governance;
    }

    /**
     * @notice `setGovernance()` should be called by the existing governance
     * address prior to calling this function.
     */
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "pendingGovernance");
        governance = msg.sender;
    }

    modifier onlyGovernance {
        require(msg.sender == governance, "governance");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./security/OnlyGovernance.sol";
import "./security/OnlyBridge.sol";
import {Storage} from "./libraries/Struct.sol";

contract SpaceStorage is OnlyGovernance, OnlyBridge {

    uint nextValidatorId = 1;
    // количество подписей, необходимых для перевода активов
    uint24 public threshold;
    mapping(address => uint) public validators;

    mapping(uint256 => Storage.NETWORK) public known_networks;

    mapping(address => Storage.TKN) _minted;

    mapping(string => address) public getAddressFromOriginHahs;

    mapping(bytes32 => uint256) public transfers;
    
    mapping(string => address) public lock_map;

    function addNetwork(uint256 id, uint8 decimals_) onlyGovernance external {
        known_networks[id] = Storage.NETWORK({valid:true, decimals:decimals_});
    }

    function addValidator(address validator) onlyGovernance public {
        require(
            validators[validator] == 0, 
            "Owner exist"
        );
        validators[validator] = nextValidatorId;
        nextValidatorId++;
    }
    
    function removeValidator(address validator) onlyGovernance external {
        require(
            validators[validator] != 0, 
            "dosnt exist owner"
        );
        delete validators[validator];
    }
      
    function setThreshold(uint24 value) onlyGovernance external {
        threshold = value;
    }

    function addMinted(address token_address, string memory origin_hash, Storage.TKN memory tkn) onlyBridge external {
        _minted[token_address] = tkn;
        getAddressFromOriginHahs[origin_hash] = token_address;
    }

    function incrementNonce(bytes32 key) onlyBridge external {
        transfers[key] += 1;
    }

    function addLockMap(string memory t, address token_hash) onlyBridge external {
        lock_map[t] = token_hash;
    }

    function minted(address key) external view returns (Storage.TKN memory){
        return _minted[key];
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

library ShareDef {
    /**
     * @dev status for diver, pod and terminals
     * ACTIVE default status
     * ASSIGNED means for diver means it is assigned to a pod, for a pod means it is assgned to a terminal
     * LISTED means it is bein listed for sale in game
     * TRADED means it got sold and no longer belongs to player
     * DELTED it got burn
     * EMPTY NOT ASSIGNED
     */
    enum STATUS {ACTIVE, ASSIGNED, LISTED, DELETED}
    
    struct Penalty {
        uint8 delta;
        uint8 max;
    }

    struct Diver {
        uint32 id;
        uint8 rarity; //0-255
        uint8 imageId; //0-255 //0-4 (elf chick, human male, dwarf girl, orc male, ogre male)
        uint8 genesisBonus;
        uint16 HP; //Hacking power 0-255 //0-65535
        STATUS status;
    }

    struct MarketDiver {
        uint id;
        uint price;
        address walletAddress;
        STATUS status;
        Diver diver;
    }

    struct Pod {
        uint32 id;
        uint8 rarity;
        STATUS status;
        uint8 slots;
        uint8 genesisSlots;
    }
    
    struct MarketPod {
        uint id;
        uint price;
        address walletAddress;
        STATUS status;
        Pod pod;
    }

    struct Terminal {
        uint32 id;
        uint16 totalHP;
        STATUS status;
        string name;
        uint[] divers;
        uint[] pods;
        uint lastPlayed;
        uint8 uses;
    }
    
    struct MarketTerminal {
        uint id;
        uint price;
        address walletAddress;
        STATUS status;
        Terminal terminal;
    }

    struct RollData {
        uint8 rarityPercentage;
        uint16 data;
        uint8 extraImg;
    }

    struct Server {
        uint32 id;
        uint16 minHP;
        uint reward;
        uint8 percentToWin;
        uint8 feePercentage;
    }

    uint public constant DAYS_IN_SECONDS = 86400;
}

// File: contracts/Player.sol

interface ICyverseAdmin {
    function isMgrContract(address address_) external view returns(bool);
    function isAdmin(address address_) external view returns(bool);
}

/**
 * @title Player
 * @author Developer at Cyverse
 * @dev This contract handles player infomation for Cyverse 
 */
contract Player {
    ShareDef.Diver[] public divers;
    ShareDef.Pod[] public pods;
    ShareDef.Terminal[] public terminals;
    
    uint public bitzBalance; //USD peg so only 2 decimals
    uint public cashOutTimer;
    uint8 public penaltyLevel;
    address private managerAddress;
    // address private walletAddress;

    uint[] private reusablePods;
    uint[] private reusableDivers;
    uint[] private reusableTerminals;

    ICyverseAdmin cyverseAdmin;

    event NewTerminal(uint32 id_, string name_);
    event DelTerminal(uint id_);
    
    constructor() {
        penaltyLevel = 1;
        cashOutTimer = 0;
    }

    modifier validTerminalRange(uint terminalId_) {
        require(terminalId_ < terminals.length, "P1-404");
        _;
    }
    modifier validPodRange(uint podId_) {
        require(podId_ < pods.length, "P2-404");
        _;
    }
    modifier validDiverRange(uint diverId_) {
        require(diverId_ < divers.length, "P3-404");
        _;
    }

    modifier onlyMgr {
      require(cyverseAdmin.isMgrContract(msg.sender), "P4-401");
      _;
    }

    modifier mgrOrAdmin {
      require(cyverseAdmin.isAdmin(msg.sender) || cyverseAdmin.isMgrContract(msg.sender), "P7-401");
      _;  
    }

    modifier onlyAdmin {
      require(cyverseAdmin.isAdmin(msg.sender), "P6-401");
      _;
    }

    // modifier playerOrMgrAllowed {
    //   require(msg.sender == walletAddress || cyverseAdmin.isMgrContract(msg.sender), "P5-401");
    //   _;
    // }

    /**
     * @dev This function will set the manager contract address and player so we can use it for ACL
     */
    // function setCyverseAdmin(address cyverseAdminAddress_, address _walletAddress) public {
    function setCyverseAdmin(address cyverseAdminAddress_) public {
        if (address(cyverseAdmin) == address(0) || cyverseAdmin.isAdmin(msg.sender)) {
            cyverseAdmin = ICyverseAdmin(cyverseAdminAddress_);
            // walletAddress = _walletAddress;
        } else {
            revert("P6-401");
        }
    }

    function setPenaltyLevel(uint8 level_) external {
        require(cyverseAdmin.isAdmin(msg.sender) || cyverseAdmin.isMgrContract(msg.sender), "P7-401");
        penaltyLevel = level_;
    }
    
    /**
     * @dev list all divers
     */ 
    function getDivers() public view returns (ShareDef.Diver[] memory) {
        return divers;
    }

    /**
     * @dev update balance only by managers
     */
    function updateBitz(uint amount_) external mgrOrAdmin { //onlyMgr {
        bitzBalance = amount_;
    }

    /**
     * @dev list all pods
     */
    function getPods() public view returns (ShareDef.Pod[] memory) {
        return pods;
    }

    /**
     * @dev list all terminals
     */
    function getTerminals() public view returns (ShareDef.Terminal[] memory) {
        return terminals;
    }

    /**
     * @dev adds active diver from Factory //TODO: reuse space
     */
    function addDiver(ShareDef.Diver memory _diver) public onlyMgr returns (ShareDef.Diver memory){
        if (reusableDivers.length > 0) { //TODO: add safe math
            _diver.id = uint32(reusableDivers[reusableDivers.length -1]);
            divers[_diver.id] = _diver;
            reusableDivers.pop();
        } else {
            _diver.id = uint32(divers.length);
            divers.push(_diver);
        }
        return _diver;
    }

    /**
     * @dev adds active pod from Factory, slots for divers will be blanked out
     */
    function addPod(ShareDef.Pod memory pod_) public onlyMgr returns (ShareDef.Pod memory) {
        if (reusablePods.length > 0) { //TODO: add safe math
            pod_.id = uint32(reusablePods[reusablePods.length -1]);
            pods[pod_.id] = pod_;
            reusablePods.pop();
        } else {
            pod_.id = uint32(pods.length);
            pods.push(pod_);
        }
        return pod_;  /// @dev returns pod so main contract can emit event
    }


    function getPodById(uint podId_) public view validPodRange(podId_) returns (ShareDef.Pod memory) {
        return pods[podId_];
    }

    function getDiverById(uint diverId_) public view validDiverRange(diverId_) returns (ShareDef.Diver memory) {
        return divers[diverId_];
    }

    function addTerminal(ShareDef.Terminal memory _terminal) public onlyMgr {
        _addTerminal(_terminal);
    }

    function _addTerminal(ShareDef.Terminal memory _terminal) internal {
        if (reusableTerminals.length > 0) {
            _terminal.id = uint32(reusableTerminals[reusableTerminals.length - 1]);
            terminals[_terminal.id] = _terminal;
            reusableTerminals.pop();
        } else {
            _terminal.id = uint32(terminals.length);
            terminals.push(_terminal);
        }
        emit NewTerminal(_terminal.id, _terminal.name);
    }

    function setPodStatus(uint podId_, ShareDef.STATUS status_) public onlyMgr validPodRange(podId_) {
        ///@dev TODO: status rule
        if (status_ == ShareDef.STATUS.DELETED) {
            pods[podId_].status = status_;
            reusablePods.push(podId_);
        } else if ((status_ == ShareDef.STATUS.LISTED && pods[podId_].status == ShareDef.STATUS.ACTIVE) || 
                   (status_ == ShareDef.STATUS.ACTIVE && pods[podId_].status == ShareDef.STATUS.LISTED)) { //if it was listed we can set back to active
            pods[podId_].status = status_;
        } else {
            revert("P7-404");
        }
    }

    function setDiverStatus(uint diverId_, ShareDef.STATUS status_) public onlyMgr validDiverRange(diverId_) {
        ///@dev TODO: status rule
        if (status_ == ShareDef.STATUS.DELETED) {
            divers[diverId_].status = status_;
            reusableDivers.push(diverId_);
        } else if ((status_ == ShareDef.STATUS.LISTED && divers[diverId_].status == ShareDef.STATUS.ACTIVE) || //if it is active we can set status to listed
                   (status_ == ShareDef.STATUS.ACTIVE && divers[diverId_].status == ShareDef.STATUS.LISTED)) { //if it was listed we can set back to active
            divers[diverId_].status = status_;
        } else {
            revert("P8-404");
        }
    }

    function setTerminalStatus(uint terminalId_, ShareDef.STATUS status_) public onlyMgr validTerminalRange(terminalId_) {
        // Delete if terminal is active
        if (status_ == ShareDef.STATUS.DELETED) {
            terminals[terminalId_].status = status_;
            reusableTerminals.push(terminalId_);
        } else if ((status_ == ShareDef.STATUS.LISTED && terminals[terminalId_].status == ShareDef.STATUS.ACTIVE) || //if it is active we can set status to listed
                   (status_ == ShareDef.STATUS.ACTIVE && terminals[terminalId_].status == ShareDef.STATUS.LISTED)) { //if it was listed we can set back to active
            terminals[terminalId_].status = status_;
        } else {
            revert("P9-404");
        }
    }

    /**
     * @dev to view address for now, should be delete before prod
     */
    function getManager() public view returns( address ){
        return managerAddress;
    }

    /**
     * @dev this function assignes ACTIVE divers and pods to terminal, 
     * dups in array and invalid id will roll back the tranction
     */
    function assingedToTerminal(string memory name_, uint[] memory divers_, uint[] memory pods_) external onlyMgr {
        uint totalDivers = 0;
        uint16 totalHP = 0;
        uint podDiverCount = 0;
        uint[] memory arrDivers = new uint[](divers_.length);
        uint[] memory arrPods = new uint[](pods_.length);
        /// @dev gather number of totalDivers and change status as assigned so it can not be use again too
        for (uint i = 0; i < divers_.length; i++) {
            uint diverId = divers_[i];
            require(diverId < divers.length && divers[diverId].status == ShareDef.STATUS.ACTIVE, "P9-404");
            divers[diverId].status = ShareDef.STATUS.ASSIGNED;
            arrDivers[i] = diverId;
            totalHP = totalHP + divers[diverId].HP + divers[diverId].genesisBonus;
            totalDivers++;
        }
        /// @dev gather podDiverCount and change status as assigned so it can not be use again too
        for (uint j = 0; j < pods_.length; j++) {
            uint podId = pods_[j];
            if (podId > pods.length - 1 || pods[podId].status != ShareDef.STATUS.ACTIVE) {
                revert("P10-404");
            }
            pods[podId].status = ShareDef.STATUS.ASSIGNED;
            arrPods[j] = podId;
            podDiverCount = podDiverCount + pods[podId].slots + pods[podId].genesisSlots;
        }
        if (totalDivers > podDiverCount) {
            revert("P11-400");
        }
        _addTerminal(
            ShareDef.Terminal({
                id: uint32(terminals.length),
                name: name_,
                divers: arrDivers,
                pods: arrPods,
                totalHP: totalHP,
                status: ShareDef.STATUS.ACTIVE,
                lastPlayed: 0,
                uses: 0 
            })
        );
    }

    /**
     * @dev deletes terminal, UI should keep display order base on ID
     */
    function delTerminal(uint terminalId_) public onlyMgr validTerminalRange(terminalId_) {
        ShareDef.Terminal storage terminal = terminals[terminalId_];
        terminal.status = ShareDef.STATUS.DELETED;
        for (uint i=0; i < terminal.pods.length; i++) { /// @dev Free pods
            pods[terminal.pods[i]].status = ShareDef.STATUS.ACTIVE;
        }
        for (uint i=0; i < terminal.divers.length; i++) { /// @dev Free Divers 
            divers[terminal.divers[i]].status = ShareDef.STATUS.ACTIVE;
        }
        reusableTerminals.push(terminalId_);
        emit DelTerminal(terminalId_);
    }
    
    function getTerminalById(uint terminalId_) public view validTerminalRange(terminalId_) returns (ShareDef.Terminal memory) {
        return terminals[terminalId_];
    }
    
    function updateTerminalLastPlay(uint terminalId_, uint8 terminalUses_) external onlyMgr {
        terminals[terminalId_].lastPlayed = block.timestamp;
        terminals[terminalId_].uses = terminalUses_;
    }

    function setCashOutTimer(uint time_, uint8 lvl_) external mgrOrAdmin { //onlyMgr {
        penaltyLevel = lvl_;
        cashOutTimer = time_;
    }
}
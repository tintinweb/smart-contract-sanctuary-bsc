// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./CyverseAdmin.sol";
import "./CyverseFactory.sol";

contract Presale {
    CyverseAdmin private _admin;
    uint8 private _genesisBonus;
    uint8 private _genesisSlots;
    bool public presaleEnabled;
    uint private _diverBNBCost;
    uint private _podBNBCost;

    Buyer[] public buyersList;
    mapping (address => uint) public walletToIndex;

    constructor(
        address adminAddress_,
        uint8 genesisBonus_,
        uint8 genesisSlots_,
        uint podBNB_,
        uint diverBNB_
    ) {
        _admin = CyverseAdmin(adminAddress_);
        _genesisBonus = genesisBonus_;
        _genesisSlots = genesisSlots_;
        _diverBNBCost = diverBNB_;
        _podBNBCost = podBNB_;
        presaleEnabled = true;
        buyersList.push(Buyer({
            wallet: address(0),
            pods: 0,
            divers: 0
        }));

    }
    event CreatedRandomItem(string itemType, address receiver, uint8 quantity);

    struct Buyer {
        address wallet;
        uint8 pods;
        uint8 divers; 
    }

    modifier adminOnly {
        require(_admin.isAdmin(msg.sender), "PS1-401");    
        _;
    }

    receive() external payable {}

    function viewBonus() external view adminOnly returns (uint8 genesisBonus, uint8 genesisSlots) {
        return (_genesisBonus, _genesisSlots);
    }

    function setBonus(uint8 genesisBonus_, uint8 genesisSlots_) external adminOnly {
        _genesisBonus = genesisBonus_;
        _genesisSlots = genesisSlots_;
    }

    function setPrices(uint diverCost_, uint podCost_) external adminOnly {
        _diverBNBCost = diverCost_;
        _podBNBCost = podCost_;
    }

    function setPresaleEnabled(bool enabled_) external adminOnly {
        presaleEnabled = enabled_;
    }

    function createRandomDiver(uint8 quantity_) external payable {
        require(presaleEnabled && quantity_ > 0 && quantity_ < 7, "INVALID");
        uint val = msg.value / quantity_;
        if (_diverBNBCost > val) {
           revert("NSF FOR DIVERS");
        }
        for (uint i=0; i < quantity_; i++) {
            CyverseFactory(_admin.factoryAddress()).createRandomDiverByAdmin(msg.sender, _genesisBonus);
        }
        uint idx = walletToIndex[msg.sender];
        if (idx > 0) {
            buyersList[idx].divers += quantity_; 
        } else {
            walletToIndex[msg.sender] = buyersList.length;
            buyersList.push(Buyer({
                wallet: msg.sender,
                pods: 0,
                divers: quantity_
            }));
        }
        emit CreatedRandomItem("DIVER", msg.sender, quantity_);
    }

    function createRandomPod(uint8 quantity_) external payable {
        require(presaleEnabled && quantity_ > 0 && quantity_ < 7, "INVALID");
        uint val = msg.value / quantity_;
        if (_podBNBCost > val) {
           revert("NSF FOR PODS"); 
        }
        for (uint i=0; i < quantity_; i++) {
            CyverseFactory(_admin.factoryAddress()).createRandomPodByAdmin(msg.sender, _genesisSlots);
        }
        uint idx = walletToIndex[msg.sender];
        if (idx > 0) {
            buyersList[idx].pods += quantity_; 
        } else {
            walletToIndex[msg.sender] = buyersList.length;
            buyersList.push(Buyer({
                wallet: msg.sender,
                pods: quantity_,
                divers: 0
            }));
        }
        emit CreatedRandomItem("POD", msg.sender, quantity_);
    }

    function drawBNB(address payable toWallet_) external adminOnly {
        (bool sent, ) = toWallet_.call{ value: address(this).balance }("");
        require(sent, "FAILED TO SEND");
    }

    function getAllBuyers() external view returns (Buyer[] memory) {
        return buyersList;
    }
}

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./utils/CyverseLib.sol";

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

struct PurchaseDistribution {
        uint8 rewardPool;
        uint8 operations;
        uint8 liquidity;
        uint8 marketing;
    }

interface ICredz {
    function inGamePurchase(address payee_, uint amount_, PurchaseDistribution memory dist) external returns(bool);
    function inGamePaymentout(address receiver_, uint amount_, uint8 rewardPercentage_) external;
    function inGameTrade(address from_, address to_, uint amount_, uint8 rewardPercentage_) external;
    function inGrameWithdraw(address receiver_, uint amount_) external returns(bool);
    function ebalance(address account) external view returns (uint256);
    function inGamePurchaseToRewards(address payee_, uint amount_) external returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

// import "./utils/Safemath.sol";
import "./utils/CyverseLib.sol";
import "./Player.sol";
import "./ICredz.sol";
import "./CyverseAdmin.sol";


/// @title CyverseFactory
/// @author Developer at Cyverse
/// @notice Factory to manage Cyverse game
/// @dev Dev in progress (needs clean up and test)  This game will not delete things in array instead we will try to reuse the spots
/// @dev changing err codes to HTTP codes


contract CyverseFactory  {
    struct ConfigInfo {
        uint8 terminalMaxUse;
        uint8 diverImgMax;
        uint8 hackerPowerSpread;
        uint8 maxRarityDiver;
        uint8 maxRarityPod;
        uint8 resetPenaltyDay;
        uint16 burnPodCashBack;
        uint16 burnDiverCashBack;
        uint16 backDoorCostPerDiver;
        uint16 terminalDisPerHP;
        uint16 diverMintCost;
        uint16 podMintCost;
        uint8 extraImgPercentage;
    }

    
    CyverseAdmin private cyverseAdmin;
    /// @dev 
    uint64 private _seed;
    bool private _rGuard;
    /// @dev defines how to spread the minting
    PurchaseDistribution public mintSplit;
    
    /// @dev maps wallet to player and keeps list of players
    mapping (address => address) public walletToPlayers;
    mapping (uint => ShareDef.Penalty) public penaltyData;
    address[] internal players;
    address internal templatePlayer;
    
    /// @dev Keeps table or rarity
    ShareDef.RollData[] public rarityDiverData;
    ShareDef.RollData[] public rarityPodData;
    ShareDef.Server[] public servers;
    /// @dev keep game config (pack into a struct to save space)
    ConfigInfo public _configInfo;

    /// Events ------------------------------------------------------------------------------
    event NewDiver(address owner, uint hackerId, uint rarity, uint16 HP, uint8 imageId);
    event NewPlayer(address _player);
    event NewPod(address _player, uint id, uint rarity, uint16 slots);
    event HackServer(address _player, uint serverId, uint terminalId, bool result, uint8 roll, uint creditsWon);
    event ServerAdded(ShareDef.Server server_);
    event PlayerPayout(address to, uint8 penaltyLevel, uint8 rewardPercentage, uint amountInCredz);
    event ItemBurned(string itemType, address wallet, uint itemId, uint credz);
    /// ---------------------------------------------------------------------------------------
    
    /// @dev TODO in the future this constructor should receive a token address.  This address should be the game token
    constructor(address cyverseAdminAddress_, uint64 seed_, address playerTemplate_) {
        cyverseAdmin = CyverseAdmin(cyverseAdminAddress_);
        _seed = seed_;
        templatePlayer = playerTemplate_;
    }

    modifier reentranceGuard() {
        require(!_rGuard, "LOCKED");
        _rGuard = true;
        _;
        _rGuard = false;
    }

    modifier adminOnly() {
        require(cyverseAdmin.isAdmin(msg.sender), "CF1-401");
        _;
    }

    modifier percentageRollOnly(uint roll_) {
        require(roll_ > 0 && roll_ < 101 , "CF1-400");
        _;
    }

    function setMintSplit(PurchaseDistribution memory mintSplit_) external adminOnly {
        require((mintSplit_.rewardPool + mintSplit_.operations + mintSplit_.liquidity + mintSplit_.marketing) == 100, "INVALID");
        mintSplit = mintSplit_;
    }

    function clone(address implementation_) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation_))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
    
    function setPenaltyData(uint level_, ShareDef.Penalty memory penalty_) external adminOnly {
        penaltyData[level_] = penalty_;
    }

    function updateDiverData(uint diverId_, ShareDef.RollData memory rollData_) external adminOnly {
        require(diverId_ < rarityDiverData.length, "INVALID ID");
        rarityDiverData[diverId_] = rollData_;
    }

    function addDiverData(ShareDef.RollData memory rollData_) external adminOnly {
        rarityDiverData.push(rollData_);
    }

    function getDiverData() external view returns (ShareDef.RollData[] memory) {
        return rarityDiverData;
    }

    function updatePodData(uint podId_, ShareDef.RollData memory rollData_) external adminOnly {
        require(podId_ < rarityPodData.length, "INVALID ID");
        rarityPodData[podId_] = rollData_;
    }

    function addPodData(ShareDef.RollData memory rollData_) external adminOnly {
        rarityPodData.push(rollData_);
    }
    
    function getPodData() external view  returns (ShareDef.RollData[] memory) {
        return rarityPodData;
    }

    function getServers() external view returns (ShareDef.Server[] memory) {
        return servers;
    }

    function updateServer(ShareDef.Server memory server_) external adminOnly {
        require(server_.id < servers.length);
        servers[server_.id] = server_;
    }

    function addServer(ShareDef.Server memory server_) external adminOnly {
        server_.id = uint32(servers.length);
        servers.push(server_);
        emit ServerAdded(server_);
    }

    function setConfig(ConfigInfo memory config_) external adminOnly {
        _configInfo = config_;
    }

    function createPlayer() external {
        require(walletToPlayers[msg.sender] == address(0), "CF1-416"); //Already has a player
        _createPlayer(msg.sender);
    }

    function _createPlayer(address walletAddress_) internal {
        Player player = Player(clone(templatePlayer));
        player.setCyverseAdmin(address(cyverseAdmin));
        walletToPlayers[walletAddress_] = address(player);
        players.push(address(player));
        emit NewPlayer(address(player));
    }

    function getPlayers() external view adminOnly returns (address[] memory) {
        return players;
    } 
    //TODO: Review if needed
    // function getPlayerAddress() external view returns (address) {
    //     require(walletToPlayers[msg.sender] != address(0));
    //     return walletToPlayers[msg.sender];
    // }

    function getPlayerAddressWithAddress(address waddress_) external view returns (address) {
        require(walletToPlayers[waddress_] != address(0), "INVALID");
        return walletToPlayers[waddress_];
    }
    
    function hackServer(uint serverId_, uint terminalId_, bool useBitzToPay) external {
        address playerAddress = this.getPlayerAddressWithAddress(msg.sender);
        require(serverId_ < servers.length, "CF1-404");
        ShareDef.Server memory server = servers[serverId_];
        Player player = Player(playerAddress);
        ShareDef.Terminal memory terminal = player.getTerminalById(terminalId_);
        if (terminal.uses > _configInfo.terminalMaxUse) {
            revert("TERMINAL USED UP");
        }
        if (server.minHP > terminal.totalHP) {
            revert("NOT ENOUGH HACKING POWER");
        }
        if ((terminal.lastPlayed + cyverseAdmin.getHackingCoolDown()) > block.timestamp) {
            revert("TERMINAL ON COOLDOWN");
        }

        uint hackCost = ((_configInfo.backDoorCostPerDiver * terminal.divers.length)
                        + (server.feePercentage * server.reward / 100));
        if (useBitzToPay) {
            require(player.bitzBalance() >= hackCost, "NSF TO HACK");
            player.updateBitz(player.bitzBalance() - hackCost);
        } else {
            uint amount = cyverseAdmin.getOracleSwap(hackCost * 10 ** 16);
            ICredz(cyverseAdmin.coinAddress()).inGamePurchaseToRewards(msg.sender, amount);
        }

        player.updateTerminalLastPlay(terminalId_, terminal.uses + 1);
        if (player.cashOutTimer() == 0) {
            player.setCashOutTimer(block.timestamp, 1);
        }
        uint roll = generateRandomNum(100);
        if (roll > server.percentToWin) {
            emit HackServer(msg.sender, serverId_, terminalId_, false, uint8(roll), 0);
        } else {
            player.updateBitz(player.bitzBalance() + server.reward);
            emit HackServer(msg.sender, serverId_, terminalId_, true, uint8(roll), server.reward);
        }
    }

    // @dev
    function updateSeed(uint64 seed_) external {
        require(cyverseAdmin.isAdmin(msg.sender), "CF2-401");
        _seed = seed_;
    }
    /// @dev TODO: need to add external rand source to seed
    function generateRandomNum(uint modulus_) internal returns (uint) {
        if (_seed > (type(uint64).max - 10)) {
            _seed = uint64(block.timestamp);
        }
        _seed +=1;
        uint blockNum = (block.number-1);               
        uint swap = blockNum > 0 ? uint(blockhash(blockNum)) : 0;
        uint seed2 = cyverseAdmin.getOracleSwap(_seed);
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp,  msg.sender, swap, _seed, seed2) ));
        uint val = (rand % modulus_) + 1;
        return val;
    }

    function createRandomDiver() external {
        uint amount = cyverseAdmin.getOracleSwap(uint(_configInfo.diverMintCost) * 10 ** 16 );
        if (ICredz(cyverseAdmin.coinAddress()).inGamePurchase(msg.sender, amount, mintSplit)) {
            _createDiver(generateRandomNum(100), msg.sender, 0);
        } else {
            revert("UNABLE TO PROCESS PAYMENT");
        }
    }
    //TODO: Need to receive BNB for Genesis Event
    function createRandomDiverByAdmin(address receiver_, uint8 genesis_) external adminOnly {
        if (walletToPlayers[receiver_] == address(0)) {
            _createPlayer(receiver_);
        }
        _createDiver(generateRandomNum(100), receiver_, genesis_);
    }
    //TODO: Need to receive BNB for Genesis Event
    function createRandomPodByAdmin(address receiver_, uint8 genesisSlots_) external adminOnly {
        if (walletToPlayers[receiver_] == address(0)) {
            _createPlayer(receiver_);
        }
        _createPod(generateRandomNum(100), receiver_, genesisSlots_);
    }

    function createRandomDivers(uint8 amount_) external {
        require(amount_ > 0 && amount_ < 7, "INVALID");
        //TODO: get swap then compare
        require(ICredz(cyverseAdmin.coinAddress()).ebalance(msg.sender) >= (_configInfo.diverMintCost * amount_), "NSF");

        for (uint8 i=0; i < amount_;i++) {
            if (ICredz(cyverseAdmin.coinAddress()).inGamePurchase(msg.sender, _configInfo.diverMintCost, mintSplit)) {
                _createDiver(generateRandomNum(100), msg.sender, 0);
            } else {
                revert("UNABLE TO PROCESS PAYMENT");
            }
        }
    }

    /// @dev TODO still credit back
    function burnDiver(uint diverId_) public {
        Player player = Player(this.getPlayerAddressWithAddress(msg.sender));
        player.setDiverStatus(diverId_, ShareDef.STATUS.DELETED);
        uint realAmount = cyverseAdmin.getOracleSwap(uint(_configInfo.burnDiverCashBack) * 10 ** 16);
        ICredz(cyverseAdmin.coinAddress()).inGamePaymentout(msg.sender, realAmount, 0);
        emit ItemBurned("DIVER", msg.sender, diverId_, realAmount);
    }

    function createDiver(uint roll_, address walletAddress_, uint8 genesisBonus_) external adminOnly percentageRollOnly(roll_)  {
        _createDiver(roll_, walletAddress_, genesisBonus_);
    }

    function _createDiver(uint roll_, address walletAddress_, uint8 genesis_) internal {
        Player player = Player(this.getPlayerAddressWithAddress(walletAddress_));
        uint8 maxRarity = _configInfo.maxRarityDiver - 1;
        ShareDef.RollData memory rollData = rarityDiverData[maxRarity];
        uint8 rarity = maxRarity;
        for(uint8 i=0; i < maxRarity; i++) {
            if (roll_ <= rarityDiverData[i].rarityPercentage) {
                rollData = rarityDiverData[i];
                rarity = i;
                break;
            }
        }
        uint16 hp = rollData.data + (uint16(generateRandomNum(_configInfo.hackerPowerSpread))); // roll spread
        uint8 imageId = uint8(generateRandomNum(_configInfo.diverImgMax));
        if (rollData.extraImg > 0 && generateRandomNum(100) < _configInfo.extraImgPercentage) {
            imageId = 100 + rollData.extraImg;
        }

        ShareDef.Diver memory diver = ShareDef.Diver ({
            id: 0,
            rarity: rarity,
            imageId: imageId,
            HP: hp,
            status: ShareDef.STATUS.ACTIVE,
            genesisBonus: genesis_
        });
        ShareDef.Diver memory rdiver = player.addDiver(diver);
        emit NewDiver(address(player), rdiver.id, rdiver.rarity, rdiver.HP, rdiver.imageId);
    }
    
    function _createPod(uint roll_, address walletAddress_, uint8 genesisSlots_) internal {
        Player player = Player(this.getPlayerAddressWithAddress(walletAddress_));
        uint8 maxRarity = _configInfo.maxRarityPod - 1;
        ShareDef.RollData memory rollData = rarityPodData[maxRarity];
        uint8 rarity = maxRarity;
        for(uint8 i=0; i < maxRarity; i++) {
            if (roll_ <= rarityPodData[i].rarityPercentage) {
                rollData = rarityPodData[i];
                rarity = i;
                break;
            }
        }
        
        ShareDef.Pod memory pod = ShareDef.Pod({
            id: 0,
            rarity: rarity,
            slots: uint8(rollData.data),
            status: ShareDef.STATUS.ACTIVE,
            genesisSlots: genesisSlots_
        });
        ShareDef.Pod memory rpod = player.addPod(pod);
        emit NewPod(address(player), rpod.id, rpod.rarity, rpod.slots);
    }

    function createRandomPod() external {
        if (ICredz(cyverseAdmin.coinAddress()).inGamePurchase(msg.sender, _configInfo.podMintCost, mintSplit)) {
            _createPod(generateRandomNum(100), msg.sender, 0);
        } else {
            revert("UNABLE TO PROCESS PAYMENT");
        }
    }

    function createRandomPods(uint8 amount_) external {
        require(amount_ > 0 && amount_ < 7, "INVALID");
        //TODO: get swap then compare
        require(ICredz(cyverseAdmin.coinAddress()).ebalance(msg.sender) >= (_configInfo.podMintCost * amount_), "NSF");
        if (ICredz(cyverseAdmin.coinAddress()).inGamePurchase(msg.sender, _configInfo.podMintCost, mintSplit)) {
            _createPod(generateRandomNum(100), msg.sender, 0);
        } else {
            revert("UNABLE TO PROCESS PAYMENT");
        }
    }

    /// @dev TODO still credit back
    function burnPod(uint podId_) external {
        Player player = Player(this.getPlayerAddressWithAddress(msg.sender));
        player.setPodStatus(podId_, ShareDef.STATUS.DELETED);
        uint realAmount = cyverseAdmin.getOracleSwap(uint(_configInfo.burnPodCashBack) * 10 ** 16);
        ICredz(cyverseAdmin.coinAddress()).inGamePaymentout(msg.sender, realAmount, 0);
        emit ItemBurned("POD", msg.sender, podId_, realAmount);
    }
    
    function createPod(uint roll_, address walletAddress_, uint8 genesisSlots_) external adminOnly percentageRollOnly(roll_) {
        _createPod(roll_, walletAddress_, genesisSlots_);
    }

    function assingedToTerminal(string memory name_, uint[] memory divers_, uint[] memory pods_) external {
        ///@ dev terminals are free
        Player player = Player(this.getPlayerAddressWithAddress(msg.sender));
        player.assingedToTerminal(name_, divers_, pods_);
    }

    function burnTerminal(uint terminalId_) external {
        Player player = Player(this.getPlayerAddressWithAddress(msg.sender));
        ShareDef.Terminal memory terminal = player.getTerminalById(terminalId_);
        require(terminal.status == ShareDef.STATUS.ACTIVE, "INVALID");
        uint realAmount = cyverseAdmin.getOracleSwap(uint(_configInfo.terminalDisPerHP) * uint(terminal.totalHP) * 10 ** 16);
        require(ICredz(cyverseAdmin.coinAddress()).ebalance(msg.sender) >= (realAmount), "NSF");
        ICredz(cyverseAdmin.coinAddress()).inGamePurchaseToRewards(msg.sender, realAmount);
        player.delTerminal(terminalId_);
        emit ItemBurned("TERMINAL", msg.sender, terminalId_, realAmount);
    }
    
    function playerPayout(uint amount_) external reentranceGuard {
        Player player = Player(this.getPlayerAddressWithAddress(msg.sender));
        require(player.penaltyLevel() > 0 && player.penaltyLevel() < 6, "INVALID");
        require(player.cashOutTimer() != 0, "INVALID"); //invalid state
        if (amount_ > player.bitzBalance()) {
            revert("NSF");
        }
        player.updateBitz(player.bitzBalance() - amount_);
        uint ndays = (block.timestamp - player.cashOutTimer()) / ShareDef.DAYS_IN_SECONDS; //how many days have passed
        ShareDef.Penalty memory pdata = penaltyData[player.penaltyLevel()];
        uint realAmount = cyverseAdmin.getOracleSwap(amount_ * 10 ** 16); //bump to 18 decimals and get Oracle conversion
        uint8 percentage = pdata.delta;
        if (ndays == 0) {
            percentage = pdata.max;
        } else if (ndays < 15) {
            percentage = uint8(pdata.max - (ndays * pdata.delta));
        }
        ICredz(cyverseAdmin.coinAddress()).inGamePaymentout(msg.sender, realAmount, percentage);
        uint8 newLevel = player.penaltyLevel();
        if (ndays > _configInfo.resetPenaltyDay) {
            newLevel = player.penaltyLevel() == 1 ? 1 : player.penaltyLevel() - 1;
        } else {
            newLevel = player.penaltyLevel() == 5 ? 5 : player.penaltyLevel() + 1;
        }
        player.setCashOutTimer(block.timestamp, newLevel);
        emit PlayerPayout(msg.sender, player.penaltyLevel(), percentage, realAmount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./swap/IUniswapV2Router.sol";
import "./swap/IUniswapV2Factory.sol";
import "./CyverseFactory.sol";
import "./utils/CyverseLib.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Player.sol";


contract CyverseAdmin {
    mapping (address => uint) private admins;
    address[] private adminList;
    address private _owner;
    address public factoryAddress;
    address public marketPlaceAddress;
    address public coinAddress;
    bool public oracleEnabled;
    uint public hackingCooldown;
    
    IUniswapV2Router02 public ROUTER = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IUniswapV2Factory public FACTORY = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    /// @dev the reason COIN and coinAddress are not the same is to allow us to test it in testnet without creating liquidy pool
    address public BUSD = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47; //Testnet
    address public COIN = 0xDAcbdeCc2992a63390d108e8507B98c7E2B5584a; // My token (CAKE now)  (for testing is safemoon 600 about 620 BUSD)
    
    uint private _factorAmount;

    modifier onlyOwner {
        require(msg.sender == _owner, "A1-401");
        _;
    }
    
    modifier adminOnly {
        require(admins[msg.sender] > 0, "A2-401");
        _;
    }

    constructor() {
        adminList.push(0x0000000000000000000000000000000000000000); //Keeps index from hitting 0
        _owner = msg.sender;
        admins[msg.sender] = 1;
        adminList.push(msg.sender);
        _factorAmount = 100;
        hackingCooldown = ShareDef.DAYS_IN_SECONDS;
    }
    
    function isGamer(address walletAddress_) external view returns (bool) {
        address playerAddress = CyverseFactory(factoryAddress).walletToPlayers(walletAddress_);
        if (playerAddress == address(0)) return false;
        
        ShareDef.Terminal[] memory terminals = Player(playerAddress).getTerminals();
        for (uint i=0; i < terminals.length; i++) {
            if (terminals[i].status == ShareDef.STATUS.ACTIVE) {
                return true;
            }
        }
        return false;
    }

    function setHackingCoolDown(uint hackingCooldown_) external adminOnly {
        hackingCooldown = hackingCooldown_;
    }

    function getHackingCoolDown() external view returns (uint) {
        return hackingCooldown;
    }

    // function getCoinAddress() external view returns (address) {
    //     return coinAddress;
    // }

    function setoracleEnabled(bool enable_) external adminOnly {
        oracleEnabled = enable_;
    }

    function isMgrContract(address address_) external view returns(bool) {
        return (marketPlaceAddress == address_ || factoryAddress == address_);
    }

    function setFactorAmount(uint factorAmount_) external {
        _factorAmount = factorAmount_;
    }
    
    function setRelatedContracts(address factoryAddress_, address marketPlaceAddress_, address coinAddress_) external onlyOwner {
        factoryAddress = factoryAddress_;
        marketPlaceAddress = marketPlaceAddress_;
        coinAddress = coinAddress_;
    }

    function isAdmin(address address_) external view returns(bool) {
        require(address_ != address(0), "A1-404");
        return (admins[address_] > 0);
    }

    function changeOwner(address owner_) external onlyOwner {
        _owner = owner_;
    }

    function setAdmin(address adminAddress_) external onlyOwner {
        admins[adminAddress_] = adminList.length;
        adminList.push(adminAddress_);
    }

    function removeAdmin(address adminAddress_) external onlyOwner {
        require(adminAddress_ != address(0) && admins[adminAddress_] > 0, "A1-404");
        uint idx = admins[adminAddress_];
        adminList[idx] = adminList[adminList.length - 1];
        adminList.pop();
        delete admins[adminAddress_];
    }

    function getOracleSwap(uint amount_) external view returns (uint) {
        //@dev 100 cakes to BUSD
        require(amount_ > 0, "A1-400");
        require((marketPlaceAddress == msg.sender || factoryAddress == msg.sender), "A3-401");
        if (!oracleEnabled) {
            return amount_;
        }
        address[] memory path = new address[](2);
        path[0] = COIN;
        path[1] = BUSD;
        uint[] memory vals = ROUTER.getAmountsOut(amount_, path);
        return vals[1];
    }

    function updateDex(address factory_, address router_) external adminOnly {
        ROUTER = IUniswapV2Router02(router_);
        FACTORY = IUniswapV2Factory(factory_);
    }

    function updatePair(address bitzCoin_, address credzCoin_) external adminOnly {
        BUSD = bitzCoin_;
        COIN = credzCoin_;
    }

    function getAdmins() external view returns(address [] memory) {
        return adminList;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./utils/CyverseLib.sol";
import "./Player.sol";
import "./CyverseAdmin.sol";
import "./ICredz.sol";
import "./CyverseFactory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MarketPlace  {
    uint[] private _reusableMarketDiverSlot;
    uint[] private _reusableMarketPodSlot;
    uint[] private _reusableMarketTerminalSlot;
    ShareDef.MarketDiver[] public marketDiverList;
    ShareDef.MarketPod[] public marketPodList;
    ShareDef.MarketTerminal[] public marketTerminalList;
    CyverseAdmin private _cyverseAdmin;
    uint8 public _marketTax;
    uint public transferCost;
    PurchaseDistribution public transferDist;
    event ItemToMarket(string type_, address seller_, uint id_, uint salePrice_);
    event SoldMarketItem(string type_, uint podId_, address from_, address to_, uint credz_, uint8 tax_);
    modifier adminOnly() {
        require(_cyverseAdmin.isAdmin(msg.sender), "M1-401");
        _;
    }

    constructor(address cyverseAdmin_) {
        _cyverseAdmin = CyverseAdmin(cyverseAdmin_);
        _marketTax = 15;
        transferCost = 100;
        transferDist = PurchaseDistribution({
            rewardPool: 0, 
            operations: 0,
            liquidity: 0,
            marketing: 100
        });
    }

    function setMarketTax(uint8 marketTax_, uint transferCost_, PurchaseDistribution memory transferDist_) external adminOnly {
        require(marketTax_ < 101, "INVALID TAX");
        _marketTax = marketTax_;
        transferCost = transferCost_;
        transferDist = transferDist_;
    }

    //@ dev make sure salesPrice_ USD (2 decimals)
    function addDiverToMarket(uint diverId_, uint salePrice_) external {
        Player player = Player(
            CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).getPlayerAddressWithAddress(msg.sender)
        );
        
        player.setDiverStatus(diverId_, ShareDef.STATUS.LISTED);
        ShareDef.Diver memory diver = player.getDiverById(diverId_);
        ShareDef.MarketDiver memory marketDiver = ShareDef.MarketDiver({
            id: 0,
            price: salePrice_,
            walletAddress: msg.sender,
            status: ShareDef.STATUS.ACTIVE,
            diver: diver 
        });
        
        if (_reusableMarketDiverSlot.length > 0) {
            marketDiver.id = _reusableMarketDiverSlot[_reusableMarketDiverSlot.length - 1];
            _reusableMarketDiverSlot.pop();
            marketDiverList[marketDiver.id] = marketDiver;
        } else {
            marketDiver.id = marketDiverList.length;
            marketDiverList.push(marketDiver);
        }
        emit ItemToMarket("DIVER", msg.sender, diverId_, salePrice_);
    }

    function removeDiverFromMarket(uint diverId_) external {
        require(diverId_ < marketDiverList.length, "Invalid Market Diver");
        require(marketDiverList[diverId_].status == ShareDef.STATUS.ACTIVE, "Invalid Market Diver Status");
        require(msg.sender == marketDiverList[diverId_].walletAddress, "You can not remove other player listing");
        Player player = Player(
                CyverseFactory(
                    _cyverseAdmin.factoryAddress()
                ).getPlayerAddressWithAddress(msg.sender)
            );

        player.setDiverStatus(marketDiverList[diverId_].diver.id, ShareDef.STATUS.ACTIVE);
        marketDiverList[diverId_].status = ShareDef.STATUS.DELETED;
        _reusableMarketDiverSlot.push(diverId_);
    }

    function getMarketDivers() public view returns (ShareDef.MarketDiver[] memory) {
        return marketDiverList;
    }

    /// @dev TODO: we need to charge and send also fee to our pool and pay player for sales
    function buyMarketDiver(uint diverId_) external {
        require(diverId_ < marketDiverList.length, "INVALID");
        require(marketDiverList[diverId_].status == ShareDef.STATUS.ACTIVE, "INVALID");
        require(msg.sender != marketDiverList[diverId_].walletAddress, "NO SELF PURCHASE");
        address playerAddress = CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).getPlayerAddressWithAddress(msg.sender);
        /// @dev bump amount to a full 18 digits price mirrors USD so it only has 2 decimals 
        uint credzToCharge = _cyverseAdmin.getOracleSwap(marketDiverList[diverId_].price * (10 ** 16));
        require(
            ERC20(_cyverseAdmin.coinAddress()).balanceOf(msg.sender) >= credzToCharge, 
            "INSUFFICIENT FUNDS"
        ); //insuficient funds
        Player player = Player(playerAddress);
        Player sellerPlayer = Player(
            CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).walletToPlayers(marketDiverList[diverId_].walletAddress)
        );
        sellerPlayer.setDiverStatus(marketDiverList[diverId_].diver.id, ShareDef.STATUS.DELETED);
        marketDiverList[diverId_].status = ShareDef.STATUS.DELETED;
        ICredz(_cyverseAdmin.coinAddress()).inGameTrade (msg.sender, marketDiverList[diverId_].walletAddress, credzToCharge, _marketTax);
        ShareDef.Diver memory diver =  marketDiverList[diverId_].diver;
        diver.status = ShareDef.STATUS.ACTIVE;
        player.addDiver(diver);
        _reusableMarketDiverSlot.push(diverId_);
        emit SoldMarketItem("DIVER", diverId_, msg.sender, marketDiverList[diverId_].walletAddress, credzToCharge, _marketTax);
    }
    
    function TransferToAddress(uint mtype, uint id, address wallet) external {
        Player player = Player(
            CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).getPlayerAddressWithAddress(msg.sender)
        );
        Player player2 = Player(
            CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).getPlayerAddressWithAddress(wallet)
        );
        uint credzToCharge = _cyverseAdmin.getOracleSwap(transferCost * (10 ** 16));
        require(
            ERC20(_cyverseAdmin.coinAddress()).balanceOf(msg.sender) >= credzToCharge, 
            "INSUFFICIENT FUNDS"
        ); //insuficient funds
        require(ICredz(_cyverseAdmin.coinAddress()).inGamePurchase(msg.sender, credzToCharge, transferDist), "NSF");
        if (mtype == 1) { //DIVERS
            ShareDef.Diver memory diver = player.getDiverById(id);
            require (diver.status == ShareDef.STATUS.ACTIVE, "M-IS1");// Marketplace invalid status for gift diver
            player.setDiverStatus(id, ShareDef.STATUS.DELETED);
            player2.addDiver(diver);
        } else { //POD
            ShareDef.Pod memory pod = player.getPodById(id);
            require (pod.status == ShareDef.STATUS.ACTIVE, "M-IS2");// Marketplace invalid status for gift pod
            player.setPodStatus(id, ShareDef.STATUS.DELETED);
            player2.addPod(pod);
        }
    }

    function addPodToMarket(uint podId_, uint salePrice_) external {
        Player player = Player(
            CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).getPlayerAddressWithAddress(msg.sender)
        );
        
        player.setPodStatus(podId_, ShareDef.STATUS.LISTED);
        ShareDef.Pod memory pod = player.getPodById(podId_);
        ShareDef.MarketPod memory marketPod = ShareDef.MarketPod({
            id: 0,
            price: salePrice_,
            walletAddress: msg.sender,
            status: ShareDef.STATUS.ACTIVE,
            pod: pod 
        });
        
        if (_reusableMarketPodSlot.length > 0) {
            marketPod.id = _reusableMarketPodSlot[_reusableMarketPodSlot.length - 1];
            _reusableMarketPodSlot.pop();
            marketPodList[marketPod.id] = marketPod;
        } else {
            marketPod.id = marketPodList.length;
            marketPodList.push(marketPod);
        }
        emit ItemToMarket("POD", msg.sender, podId_, salePrice_);
    }

    function getMarketPods() public view returns (ShareDef.MarketPod[] memory) {
        return marketPodList;
    }
    
    function removePodFromMarket(uint podId_) external {
        require(podId_ < marketPodList.length, "INVALID");
        require(marketPodList[podId_].status == ShareDef.STATUS.ACTIVE, "INVALID");
        require(msg.sender == marketPodList[podId_].walletAddress, "You can not remove other player listing");
        Player player = Player(
                CyverseFactory(
                    _cyverseAdmin.factoryAddress()
                ).getPlayerAddressWithAddress(msg.sender)
            );

        player.setPodStatus(marketPodList[podId_].pod.id, ShareDef.STATUS.ACTIVE);
        marketPodList[podId_].status = ShareDef.STATUS.DELETED;
        _reusableMarketPodSlot.push(podId_);
    }
    
    function buyMarketPod(uint podId_) external  {
        require(podId_ < marketPodList.length, "INVALID");
        require(marketPodList[podId_].status == ShareDef.STATUS.ACTIVE, "INVALID");
        require(msg.sender != marketPodList[podId_].walletAddress, "NO SELF PURCHASE");
        address playerAddress = CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).getPlayerAddressWithAddress(msg.sender);
        uint credzToCharge = _cyverseAdmin.getOracleSwap(marketPodList[podId_].price * (10 ** 16));
        require(
            ERC20(_cyverseAdmin.coinAddress()).balanceOf(msg.sender) >= credzToCharge, 
            "INSUFFICIENT FUNDS"
        ); //insuficient funds
        
        Player player = Player(playerAddress);
        Player sellerPlayer = Player(
            CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).walletToPlayers(marketPodList[podId_].walletAddress)
        );
        sellerPlayer.setPodStatus(marketPodList[podId_].pod.id, ShareDef.STATUS.DELETED);
        marketPodList[podId_].status = ShareDef.STATUS.DELETED;
        ICredz(_cyverseAdmin.coinAddress()).inGameTrade (msg.sender, marketPodList[podId_].walletAddress, credzToCharge, _marketTax);
        ShareDef.Pod memory pod =  marketPodList[podId_].pod;
        pod.status = ShareDef.STATUS.ACTIVE;
        player.addPod(pod);
        _reusableMarketPodSlot.push(podId_);
        emit SoldMarketItem("POD", podId_, msg.sender, marketPodList[podId_].walletAddress, credzToCharge, _marketTax);
    }

    function addTerminalToMarket(uint terminalId_, uint salePrice_) external {
        Player player = Player(
            CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).getPlayerAddressWithAddress(msg.sender)
        );
        
        player.setTerminalStatus(terminalId_, ShareDef.STATUS.LISTED);
        ShareDef.Terminal memory terminal = player.getTerminalById(terminalId_);
        ShareDef.MarketTerminal memory marketTerminal = ShareDef.MarketTerminal({
            id: 0,
            price: salePrice_,
            walletAddress: msg.sender,
            status: ShareDef.STATUS.ACTIVE,
            terminal: terminal 
        });
        
        if (_reusableMarketTerminalSlot.length > 0) {
            marketTerminal.id = _reusableMarketTerminalSlot[_reusableMarketTerminalSlot.length - 1];
            _reusableMarketTerminalSlot.pop();
            marketTerminalList[marketTerminal.id] = marketTerminal;
        } else {
            marketTerminal.id = marketTerminalList.length;
            marketTerminalList.push(marketTerminal);
        }
        emit ItemToMarket("TERMINAL", msg.sender, terminalId_, salePrice_);
    }

    function getMarketTerminals() public view returns(ShareDef.MarketTerminal[] memory) {
        return marketTerminalList;
    }

    function buyMarketTerminal(uint terminalId_) public payable {
        require(terminalId_ < marketTerminalList.length, "INVALID");
        require(marketTerminalList[terminalId_].status == ShareDef.STATUS.ACTIVE, "INVALID");
        require(msg.sender != marketTerminalList[terminalId_].walletAddress, "NO SELF PURCHASE");
        address playerAddress = CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).getPlayerAddressWithAddress(msg.sender);
        uint credzToCharge = marketTerminalList[terminalId_].price; //FOR NOW SINCE WE IGNORING SWAP
        require(
            ERC20(_cyverseAdmin.coinAddress()).balanceOf(msg.sender) >= credzToCharge, 
            "INSUFFICIENT FUNDS"
        ); //insuficient funds
        Player player = Player(playerAddress);
        Player sellerPlayer = Player(
            CyverseFactory(
                _cyverseAdmin.factoryAddress()
            ).walletToPlayers(marketTerminalList[terminalId_].walletAddress)
        );
        marketTerminalList[terminalId_].status = ShareDef.STATUS.DELETED;
        //Delete items from seller
        sellerPlayer.setTerminalStatus(marketTerminalList[terminalId_].terminal.id, ShareDef.STATUS.DELETED);
        uint[] memory newPods = new uint[](marketTerminalList[terminalId_].terminal.pods.length);
        uint[] memory newDivers = new uint[](marketTerminalList[terminalId_].terminal.divers.length);
        ShareDef.Terminal memory terminal = marketTerminalList[terminalId_].terminal; 
        for (uint i=0;i < terminal.pods.length; i++) {
            ShareDef.Pod memory pod = sellerPlayer.getPodById(terminal.pods[i]);
            pod = player.addPod(pod);
            newPods[i] = pod.id;
            sellerPlayer.setPodStatus(marketTerminalList[terminalId_].terminal.pods[i], ShareDef.STATUS.DELETED);
            
        }
        for (uint i=0;i < terminal.divers.length; i++) {
            ShareDef.Diver memory diver = sellerPlayer.getDiverById(terminal.divers[i]);
            ShareDef.Diver memory retDiver = player.addDiver(diver);
            newDivers[i] = retDiver.id;
            sellerPlayer.setDiverStatus(terminal.divers[i], ShareDef.STATUS.DELETED);
        }

        ICredz(_cyverseAdmin.coinAddress()).inGameTrade (msg.sender, marketTerminalList[terminalId_].walletAddress, credzToCharge, _marketTax);
        terminal.status = ShareDef.STATUS.ACTIVE;
        terminal.pods = newPods;
        terminal.divers = newDivers;
        player.addTerminal(terminal);
        _reusableMarketTerminalSlot.push(terminalId_);
        emit SoldMarketItem("TERMINAL", terminalId_, msg.sender, marketTerminalList[terminalId_].walletAddress, credzToCharge, _marketTax);
    }

    function removeTerminalFromMarket(uint terminalId_) external {
        require(terminalId_ < marketTerminalList.length, "INVALID");
        require(marketTerminalList[terminalId_].status == ShareDef.STATUS.ACTIVE, "INVALID");
        require(msg.sender == marketTerminalList[terminalId_].walletAddress, "You can not remove other player listing");
        Player player = Player(
                CyverseFactory(
                    _cyverseAdmin.factoryAddress()
                ).getPlayerAddressWithAddress(msg.sender)
            );

        player.setTerminalStatus(marketTerminalList[terminalId_].terminal.id, ShareDef.STATUS.ACTIVE);
        marketTerminalList[terminalId_].status = ShareDef.STATUS.DELETED;
        _reusableMarketTerminalSlot.push(terminalId_);
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

import "./Player.sol";
import "./ICredz.sol";
import "./CyverseAdmin.sol";

/// @title CyverseFactory
/// @author Developer at Cyverse
/// @notice Factory to manage Cyverse game
/// @dev Dev in progress (needs clean up and test)  This game will not delete things in array instead we will try to reuse the spots
/// @dev changing err codes to HTTP codes

interface ICCHECK {
    function isContract(address addr) external view returns (bool);
}

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
    
    struct HackStruct {
        uint256 serverId;
        uint256 terminalId;
        uint256 futureBlockNum;
    }

    mapping(address => bool) public blacklisted;

    HackStruct public otherConfig;
    CyverseAdmin public cyverseAdmin;
    // uint64 private _seed;
    bool private _rGuard;
    /// @dev defines how to spread the minting
    PurchaseDistribution public mintSplit;
    
    /// @dev maps wallet to player and keeps list of players
    mapping (address => address) public walletToPlayers;
    mapping (uint => ShareDef.Penalty) public penaltyData;
    mapping (address => uint[]) internal mintQP;
    mapping (address => uint[]) internal mintQD;
    mapping (address => HackStruct[]) internal hackQ;

    address[] wallets;
    address public templatePlayer;
    address internal iccheck;
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
    event ServerUpdate(ShareDef.Server server_);
    event PlayerPayout(address to, uint8 penaltyLevel, uint8 rewardPercentage, uint amountInCredz);
    event ItemBurned(string itemType, address wallet, uint itemId, uint credz);
    event InQ(uint mtype, uint size, address wallet);
    /// ---------------------------------------------------------------------------------------
    
    /// @dev TODO in the future this constructor should receive a token address.  This address should be the game token
    constructor(address cyverseAdminAddress_, uint64 seed_, address playerTemplate_, address iccheck_) {
        cyverseAdmin = CyverseAdmin(cyverseAdminAddress_);
        otherConfig.terminalId = seed_;
        templatePlayer = playerTemplate_;
        otherConfig.serverId = 20;
        otherConfig.futureBlockNum = ShareDef.DAYS_IN_SECONDS;
        iccheck = iccheck_;
    }
    modifier noBot {
        require(ICCHECK(iccheck).isContract(msg.sender) == false, "NB"); //NOBOT
        _;
    }

    modifier notBlacklisted {
        require(!blacklisted[msg.sender], "C2-401");
        _;
    }

    modifier reentranceGuard() {
        require(!_rGuard, "LOCKED");
        _rGuard = true;
        _;
        _rGuard = false;
    }

    modifier onlyAdmin() {
        require(cyverseAdmin.isAdmin(msg.sender), "CF1-401");
        _;
    }

    modifier onlyPercentageRoll(uint roll_) {
        require(roll_ > 0 && roll_ < 101 , "CF1-400");
        _;
    }
    
    function updateBlackList(address wallet_, bool value_) external onlyAdmin {
        blacklisted[wallet_] = value_;
    }

    function setContract(address templatePlayer_, address adminAddress_, address iccheck_) external onlyAdmin {
        if (templatePlayer_ != address(0)) {
            templatePlayer = templatePlayer_;
        }
        if (adminAddress_ != address(0)) {
            cyverseAdmin = CyverseAdmin(adminAddress_);
        }
        if (iccheck_ != address(0)) {
            iccheck = iccheck_;
        }
    }

    function setWalletToPlayer(address wallet_, address player_) external onlyAdmin {
        if (walletToPlayers[wallet_] == address(0)) {
            wallets.push(wallet_);
        }
        walletToPlayers[wallet_] = player_;
    }
 
    function setOtherconfig(
            ConfigInfo memory config_, 
            uint secondsInDay_, 
            uint minHP_, uint seed_) external onlyAdmin {
        if (config_.terminalMaxUse > 0) _configInfo = config_;
        if (secondsInDay_ > 0) otherConfig.futureBlockNum = secondsInDay_;
        if (minHP_> 0) otherConfig.serverId = minHP_;
        if (seed_ > 0) otherConfig.terminalId = seed_;
    }

    function setMintSplit(PurchaseDistribution memory mintSplit_) external onlyAdmin {
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
        require(instance != address(0), "CF"); //Create Failed
    }
    
    function setPenaltyData(uint level_, ShareDef.Penalty memory penalty_) external onlyAdmin {
        penaltyData[level_] = penalty_;
    }

    function updateRarity(uint mtype, uint id_, ShareDef.RollData memory rollData_) external onlyAdmin {
        if (mtype == 1) {
            if (id_ < rarityDiverData.length) {
                rarityDiverData[id_] = rollData_;
            } else {
                rarityDiverData.push(rollData_);    
            }
        } else {
            if (id_ < rarityPodData.length) {
                rarityPodData[id_] = rollData_;
            } else {
                rarityPodData.push(rollData_);
            }
        }
    }
   
    function getAdminMintQ(uint mtype, address wallet) external onlyAdmin view returns (uint256[] memory) {
        if (mtype == 1) {
            return mintQD[wallet];
        } else {
            return mintQP[wallet]; 
        }
    }
    
    function getMintQ() external view returns (uint[2] memory) {
        return [
            mintQD[msg.sender].length,
            mintQP[msg.sender].length
        ];
    }

    function getHackQ() external notBlacklisted view returns (HackStruct[] memory) {
        return hackQ[msg.sender];
    }

    function getRollData(uint mtype) external view returns (ShareDef.RollData[] memory) {
        if (mtype == 1)
            return rarityDiverData;
        return rarityPodData;
    } 

    function getServers() external view returns (ShareDef.Server[] memory) {
        return servers;
    }

    function clearData(uint data_type_) external onlyAdmin {
        if (data_type_ == 0) {
            delete servers;
        } else if (data_type_== 1) {
            delete rarityDiverData;
        } else {
            delete rarityPodData;
        }
    }
    
    function updateServer(ShareDef.Server memory server_) external onlyAdmin {
        if (server_.id < servers.length) {
            servers[server_.id] = server_;
        } else {
            server_.id = uint32(servers.length);
            servers.push(server_);    
        }
        emit ServerUpdate(server_);
    }

    function createPlayer() external {
        _createPlayer(msg.sender);
    }

    function _createPlayer(address walletAddress_) internal {
        require(walletToPlayers[walletAddress_] == address(0), "CF1-416");
        Player player = Player(clone(templatePlayer));
        player.setCyverseAdmin(address(cyverseAdmin));
        walletToPlayers[walletAddress_] = address(player);
        wallets.push(walletAddress_);
        emit NewPlayer(address(player));
    }

    function getWallets() external view returns (address[] memory) {
        require(cyverseAdmin.isAdmin(msg.sender), "CF3-401");
        return wallets;
    }
    
    function getPlayerAddressWithAddress(address waddress_) public view returns (address) {
        require(walletToPlayers[waddress_] != address(0), "INVALID");
        return walletToPlayers[waddress_];
    }

    function revealMint(uint mtype) external notBlacklisted noBot{ //mtype 1 = Diver, 2 = POD
        require(mtype > 0 && mtype < 3, "IT"); //Invalid type
        uint futureBlockNum = 0;
        if (mtype == 1) {
            require(mintQD[msg.sender].length > 0, "NR"); //Nothing to reveal
            futureBlockNum = mintQD[msg.sender][0];
        } else {
            require(mintQP[msg.sender].length > 0, "NR"); //Nothing to reveal
            futureBlockNum = mintQP[msg.sender][0];
        }
        require(futureBlockNum > 0, "II"); //Invalid Index
        require(block.number > futureBlockNum, "PW"); //Please Wait
        bytes32 futureHash = blockhash(futureBlockNum);
        uint rnum = (futureHash == bytes32(0x0)) ? 1 : generateRandomNum(100, futureHash);
        if (mtype == 1) {
            if (mintQD[msg.sender].length > 1) {
                mintQD[msg.sender][0] = mintQD[msg.sender][mintQD[msg.sender].length-1];
            }
            mintQD[msg.sender].pop();
            _createDiver(rnum, msg.sender, 0);
        } else {
            if (mintQP[msg.sender].length > 1) {
                mintQP[msg.sender][0] = mintQP[msg.sender][mintQP[msg.sender].length-1];
            }
            mintQP[msg.sender].pop();
            _createPod(rnum, msg.sender, 0);
        }
    }

    function revealServerHack() external  notBlacklisted noBot {
        HackStruct memory _hackQ = hackQ[msg.sender][0];
        require(_hackQ.futureBlockNum > 0, "II"); //Invalid Index
        require(block.number > _hackQ.futureBlockNum, "PW"); //Please Wait
        if (hackQ[msg.sender].length > 1) {
            //copy last to idx
            hackQ[msg.sender][0] = hackQ[msg.sender][hackQ[msg.sender].length-1];
        }
        hackQ[msg.sender].pop(); ///Remove from last
        bytes32 futureHash = blockhash(_hackQ.futureBlockNum);
        Player player = Player(getPlayerAddressWithAddress(msg.sender));
        ShareDef.Server memory server = servers[_hackQ.serverId];
        uint roll = (futureHash == bytes32(0x0)) ? 99 : generateRandomNum(100, futureHash);
        if (roll > server.percentToWin) {
            emit HackServer(msg.sender, _hackQ.serverId, _hackQ.terminalId, false, uint8(roll), 0);
        } else {
            player.updateBitz(player.bitzBalance() + server.reward);
            emit HackServer(msg.sender, _hackQ.serverId, _hackQ.terminalId, true, uint8(roll), server.reward);
        }
    }

    ///@dev backdoor fee
    function hackServer(uint serverId_, uint terminalId_, bool useBitzToPay) external notBlacklisted {
        require(serverId_ < servers.length, "CF1-404");
        ShareDef.Server memory server = servers[serverId_];
        Player player = Player(getPlayerAddressWithAddress(msg.sender));
        ShareDef.Terminal memory terminal = player.getTerminalById(terminalId_);
        require (terminal.uses <= _configInfo.terminalMaxUse, "TUU"); //Terminal used up
        require (server.minHP <= terminal.totalHP, "NSP"); //Non sufficient hacking poer
        require ((terminal.lastPlayed + cyverseAdmin.getHackingCoolDown()) <= block.timestamp,"CD"); //COOLDOWN
        uint hackCost = ((_configInfo.backDoorCostPerDiver * terminal.divers.length)
                        + (server.feePercentage * server.reward / 100));
        if (useBitzToPay) {
            require(player.bitzBalance() >= hackCost, "NSF");
            player.updateBitz(player.bitzBalance() - hackCost);
        } else {
            uint amount = cyverseAdmin.getOracleSwap(hackCost * (10 ** 16));
            ICredz(cyverseAdmin.coinAddress()).inGamePurchaseToRewards(msg.sender, amount);  
        }
        player.updateTerminalLastPlay(terminalId_, terminal.uses + 1);
        if (player.cashOutTimer() == 0) {
            player.setCashOutTimer(block.timestamp, 1);
        }
        
        //TODO: Q HACK
        hackQ[msg.sender].push(HackStruct({
            serverId: serverId_,
            terminalId: terminalId_,
            futureBlockNum:  block.number + 3
        }));
    }
    
    function generateRandomNum(uint modulus_, bytes32 bloque) internal returns (uint) {
        if (otherConfig.terminalId > (type(uint64).max - 10)) {
            otherConfig.terminalId = uint64(block.timestamp);
        }
        otherConfig.terminalId +=1;
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp,  msg.sender, otherConfig.terminalId, bloque) ));
        uint val = (rand % modulus_) + 1;
        return val;
    }

    function createRandomDiver() external notBlacklisted {
        uint amount = cyverseAdmin.getOracleSwap(uint(_configInfo.diverMintCost) * (10 ** 16) );
        require (ICredz(cyverseAdmin.coinAddress()).inGamePurchase(msg.sender, amount, mintSplit), "UNABLE TO PROCESS PAYMENT");
        require(mintQD[msg.sender].length < 6, "RQF"); //Reveal mint first
        mintQD[msg.sender].push(block.number + 3 + (otherConfig.terminalId % 3));
        emit InQ(1, mintQD[msg.sender].length, msg.sender);
    }
  
    function burnDiver(uint diverId_) external {
        Player player = Player(getPlayerAddressWithAddress(msg.sender));
        player.setDiverStatus(diverId_, ShareDef.STATUS.DELETED);
        uint realAmount = cyverseAdmin.getOracleSwap(uint(_configInfo.burnDiverCashBack) * (10 ** 16));
        ICredz(cyverseAdmin.coinAddress()).inGamePaymentout(msg.sender, realAmount, 0);
        emit ItemBurned("DIVER", msg.sender, diverId_, realAmount);
    }

    function createDiver(uint roll_, address walletAddress_, uint8 genesisBonus_) external onlyAdmin onlyPercentageRoll(roll_)  {
        if (walletToPlayers[walletAddress_] == address(0)) {
            _createPlayer(walletAddress_);
        }
        _createDiver(roll_, walletAddress_, genesisBonus_);
    }

    function _createDiver(uint roll_, address walletAddress_, uint8 genesis_) internal {
        Player player = Player(getPlayerAddressWithAddress(walletAddress_));
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
        bytes32 futureHash = blockhash(block.number-1);
        uint hp = rollData.data + (uint16(generateRandomNum(_configInfo.hackerPowerSpread, futureHash))); // roll spread
        if (hp < otherConfig.serverId) {
            hp = otherConfig.serverId;
        }
        
        uint8 imageId = uint8(generateRandomNum(_configInfo.diverImgMax, futureHash));
        if (rollData.extraImg > 0 && generateRandomNum(100, futureHash) < _configInfo.extraImgPercentage) {
            imageId = 100 + rollData.extraImg;
        }

        ShareDef.Diver memory diver = ShareDef.Diver ({
            id: 0,
            rarity: rarity,
            imageId: imageId,
            HP: uint16(hp),
            status: ShareDef.STATUS.ACTIVE,
            genesisBonus: genesis_
        });
        ShareDef.Diver memory rdiver = player.addDiver(diver);
        emit NewDiver(address(player), rdiver.id, rdiver.rarity, rdiver.HP, rdiver.imageId);
    }
    
    function _createPod(uint roll_, address walletAddress_, uint8 genesisSlots_) internal {
        Player player = Player(getPlayerAddressWithAddress(walletAddress_));
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

    function createRandomPod() external notBlacklisted {
        uint amount = cyverseAdmin.getOracleSwap(uint(_configInfo.podMintCost) * (10 ** 16) );
        require (ICredz(cyverseAdmin.coinAddress()).inGamePurchase(msg.sender, amount, mintSplit), "UNABLE TO PROCESS PAYMENT");
        require(mintQP[msg.sender].length < 6, "RQF"); //Reveal mint first
        mintQP[msg.sender].push(block.number + 3 + (otherConfig.terminalId % 3));
        emit InQ(2, mintQD[msg.sender].length, msg.sender);
    }

    function burnPod(uint podId_) external {
        Player player = Player(getPlayerAddressWithAddress(msg.sender));
        player.setPodStatus(podId_, ShareDef.STATUS.DELETED);
        uint realAmount = cyverseAdmin.getOracleSwap(uint(_configInfo.burnPodCashBack) * (10 ** 16));
        ICredz(cyverseAdmin.coinAddress()).inGamePaymentout(msg.sender, realAmount, 0);
        emit ItemBurned("POD", msg.sender, podId_, realAmount);
    }
    
    function createPod(uint roll_, address walletAddress_, uint8 genesisSlots_) external onlyAdmin onlyPercentageRoll(roll_) {
        if (walletToPlayers[walletAddress_] == address(0)) {
            _createPlayer(walletAddress_);
        }
        _createPod(roll_, walletAddress_, genesisSlots_);
    }

    function assingedToTerminal(string memory name_, uint[] memory divers_, uint[] memory pods_) external {
        ///@ dev terminals are free
        Player player = Player(getPlayerAddressWithAddress(msg.sender));
        player.assingedToTerminal(name_, divers_, pods_);
    }

    function burnTerminal(uint terminalId_) external {
        Player player = Player(getPlayerAddressWithAddress(msg.sender));
        ShareDef.Terminal memory terminal = player.getTerminalById(terminalId_);
        require(terminal.status == ShareDef.STATUS.ACTIVE, "INVALID");
        uint realAmount = cyverseAdmin.getOracleSwap(uint(_configInfo.terminalDisPerHP) * uint(terminal.totalHP) * (10 ** 16));
        require(ICredz(cyverseAdmin.coinAddress()).ebalance(msg.sender) >= (realAmount), "NSF");
        ICredz(cyverseAdmin.coinAddress()).inGamePurchaseToRewards(msg.sender, realAmount);
        player.delTerminal(terminalId_);
        emit ItemBurned("TERMINAL", msg.sender, terminalId_, realAmount);
    }
    
    function playerPayout(uint amount_) external notBlacklisted reentranceGuard {
        Player player = Player(getPlayerAddressWithAddress(msg.sender));
        require(player.penaltyLevel() > 0 && player.penaltyLevel() < 6, "INVALID");
        require(player.cashOutTimer() != 0, "INVALID2"); //invalid state
        require(amount_ <= player.bitzBalance(), "NSF");
        player.updateBitz(player.bitzBalance() - amount_);
        uint ndays = (block.timestamp - player.cashOutTimer()) / otherConfig.futureBlockNum; //how many days have passed
        ShareDef.Penalty memory pdata = penaltyData[player.penaltyLevel()];
        uint realAmount = cyverseAdmin.getOracleSwap(amount_ * (10 ** 16)); //bump to 18 decimals and get Oracle conversion
        int percentage = int(int8(pdata.delta));
        if (ndays == 0) {
            percentage = int(int8(pdata.max));
        } else if (ndays < 15) {
            percentage = (int(int8(pdata.max)) - (int(ndays) * percentage));
        }
        require(percentage >=0 && percentage < 101, "INVALID PERCENTAGE");
        ICredz(cyverseAdmin.coinAddress()).inGamePaymentout(msg.sender, realAmount, uint8(int8(percentage)));
        uint8 newLevel = player.penaltyLevel();
        if (ndays > _configInfo.resetPenaltyDay) {
            newLevel = player.penaltyLevel() == 1 ? 1 : player.penaltyLevel() - 1;
        } else {
            newLevel = player.penaltyLevel() == 5 ? 5 : player.penaltyLevel() + 1;
        }
        player.setCashOutTimer(block.timestamp, newLevel);
        emit PlayerPayout(msg.sender, player.penaltyLevel(), uint8(int8(percentage)), realAmount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./swap/IUniswapV2Router.sol";
import "./swap/IUniswapV2Factory.sol";
import "./swap/IUniswapV2Pair.sol";
import "./utils/CyverseLib.sol";

contract CyverseAdmin {
    mapping (address => uint) private admins;
    address[] private adminList;
    address private _owner;
    address public factoryAddress;
    address public marketPlaceAddress;
    address public coinAddress;
    address[] public oraclePath;
    bool public oracleEnabled;
    uint public hackingCooldown;
    
    mapping(address => uint) private managerContracts;
    address[] private managerList; 

    IUniswapV2Router02 public ROUTER = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IUniswapV2Factory public FACTORY = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    
    modifier onlyOwner {
        require(msg.sender == _owner, "A1-401");
        _;
    }
    
    modifier adminOnly {
        require(admins[msg.sender] > 0, "A2-401");
        _;
    }

    constructor() {
        adminList.push(msg.sender); //Keeps index from hitting 0
        _owner = msg.sender;
        admins[msg.sender] = 1;
        adminList.push(msg.sender);
        hackingCooldown = ShareDef.DAYS_IN_SECONDS;
        oracleEnabled = true;
        // oraclePath = [
        //     0x9638c0C582251F9003384035Fabda036aE6A4ca7,
        //     0x14696E65635f58D199A75928b149240a703c65a1,
        //     0x2961eb70c6f1cfE46CBD9276e163c645fE69F25f
        // ];

        // updateMgrContract(0xA927AE2A05A80F73075cA13a86056332867cb01d, true);
        // managerContracts[0x9dEb96Ce210519d58937481d5FeDa52732CB394e] = true;
    }
    function listManagers() external onlyOwner view returns (address[] memory) {
        return managerList;
    }

    function updateMgrContract(address addr_, bool enable) external onlyOwner {
        if (enable) {
            require(managerContracts[addr_] == 0, "EXIST");
            managerContracts[addr_] = managerList.length + 1;
            managerList.push(addr_);
        } else {
            require(managerContracts[addr_] > 0, "Not there");
            managerList[managerContracts[addr_] - 1] = managerList[managerList.length-1];
            managerList.pop();
            managerContracts[addr_] = 0;
        }
    }

    function setHackingCoolDown(uint hackingCooldown_) external adminOnly {
        hackingCooldown = hackingCooldown_;
    }

    function getHackingCoolDown() external view returns (uint) {
        return hackingCooldown;
    }

    function setOracleEnabled(bool enable_) external adminOnly {
        oracleEnabled = enable_;
    }

    function isMgrContract(address address_) external view returns(bool) {
        return (managerContracts[address_] > 0);
        // return (marketPlaceAddress == address_ || factoryAddress == address_);
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
        if (!oracleEnabled) {
            return amount_;
        }
        // uint[] memory amounts = new uint[](oraclePath.length);
        // amounts[0] = amount_;
        // USD -> BNB -> CREDZ
        //PAIR 1
        (uint busd, uint bnb,) = IUniswapV2Pair(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16).getReserves();
        (uint bnb2, uint credz,) = IUniswapV2Pair(0x97439dd7224a4271B33ea40b294428AC58A7c44C).getReserves();
        return ((amount_ * busd/bnb) * bnb2/credz);
    }

    // function getOraclePath() external view returns (address[] memory) {
    //     return oraclePath;
    // }

    function updateDex(address factory_, address router_) external adminOnly {
        ROUTER = IUniswapV2Router02(router_);
        FACTORY = IUniswapV2Factory(factory_);
    }

    // function setOraclePath(address[] memory oraclePath_) external adminOnly {
    //     oraclePath = oraclePath_;
    // }

    function getAdmins() external view returns(address [] memory) {
        require(admins[msg.sender] > 0, "A2-404");
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
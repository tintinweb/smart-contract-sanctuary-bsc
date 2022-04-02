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
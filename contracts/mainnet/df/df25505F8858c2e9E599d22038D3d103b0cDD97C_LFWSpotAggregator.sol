// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

/**
 * Standard SafeMath, stripped down to just add/sub/mul/div
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

interface IDEXPair {
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

interface IDEXFactory {
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

interface IDEXRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

/**
 * Provides ownable & authorized contexts
 */
abstract contract LFWAuth {
    address owner;
    mapping (address => bool) private authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender)); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender)); _;
    }

    /**
     * Authorize address. Any authorized address
     */
    function authorize(address adr) public authorized {
        authorizations[adr] = true;
        emit Authorized(adr);
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
        emit Unauthorized(adr);
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
    event Authorized(address adr);
    event Unauthorized(address adr);
}

interface ILFWDEXUtils {
    function getBaseTokens() external view returns (address[] memory);
    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);
    function pairFor(uint256 dexID, address tokenA, address tokenB) external view returns (address pair);
    function getReserves(uint256 dexID, address tokenA, address tokenB) external view returns (uint reserveA, uint reserveB);
    function getPairBalances(uint256 dexID, address tokenA, address tokenB) external view returns (uint256 balanceA, uint256 balanceB);
    function getAmountOutV1(uint256 dexID, uint amountIn, uint reserveIn, uint reserveOut) external view returns (uint amountOut);
    function getAmountInV1(uint256 dexID, uint amountOut, uint reserveIn, uint reserveOut) external view returns (uint amountIn);
    function getAmountsOutV1(uint amountIn, address[] memory path, uint256[] memory dexPath) external view returns (uint[] memory amounts);
    function getAmountsInV1(uint amountOut, address[] memory path, uint256[] memory dexPath) external view returns (uint[] memory amounts);
    function getPathReserves(address tokenA, address tokenB) external view returns (uint256[] memory reservesIn, uint256[] memory reservesOut);
    function findUserGet(uint amountIn, address[] memory path) external view returns (uint256[] memory amounts);
    function isValidPath(address[] memory path, uint256[] memory dexPath) external view returns (bool valid);
    function getLargestBasePair(address token) external view returns (uint256 dexID, address pair, address baseToken);
    function getLargestDEX(address tokenA, address tokenB) external view returns (uint256 dexID, address factory, address pair);
    function getPriceDEX(address tokenA, address tokenB) external view returns (uint256 dexID, address router, uint256 reserveRatio);
}

contract LFWSpotAggregator is LFWAuth, ILFWDEXUtils {
    using SafeMath for uint;

    struct DEX {
        string name;
        address factory;
        address router;
        bytes32 initHash;
        uint256 fee;
        bool enabled;
    }

    mapping (uint256 => DEX) public dexList;
    uint256 public dexCount;

    mapping (address => uint256) baseTokenIndex;
    address[] public baseTokens;

    constructor() LFWAuth(msg.sender) {
        dexList[dexCount++] = DEX({
        name: "PancakeSwap V1",
        factory: 0xBCfCcbde45cE874adCB698cC183deBcF17952812,
        router: 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F,
        initHash: hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66',
        fee: 9980,
        enabled: true
        });

        dexList[dexCount++] = DEX({
        name: "PancakeSwap V2",
        factory: 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73,
        router: 0x10ED43C718714eb63d5aA57B78B54704E256024E,
        initHash: hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5',
        fee: 9975,
        enabled: true
        });

        dexList[dexCount++] = DEX({
        name: "ApeSwap",
        factory: 0x0841BD0B734E4F5853f0dD8d7Ea041c241fb0Da6,
        router: 0xC0788A3aD43d79aa53B09c2EaCc313A787d1d607,
        initHash: hex'f4ccce374816856d11f00e4069e7cada164065686fbef53c6167a63ec2fd8c5b',
        fee: 9980,
        enabled: true
        });
    }

    function addDex(string memory name, address factory, address router, bytes32 initHash, uint256 fee) external authorized {
        dexList[dexCount++] = DEX({
        name: name,
        factory: factory,
        router: router,
        initHash: initHash,
        fee: fee,
        enabled: true
        });
    }

    function setDEXEnabled(uint256 dexID, bool enabled) external authorized {
        dexList[dexID].enabled = enabled;
    }

    function getBaseTokens() external view override returns (address[] memory){
        return baseTokens;
    }

    function addBaseToken(address token) external authorized {
        baseTokenIndex[token] = baseTokens.length;
        baseTokens.push(token);
    }

    function removeBaseToken(address token) external authorized {
        baseTokens[baseTokenIndex[token]] = baseTokens[baseTokens.length - 1];
        baseTokenIndex[baseTokens[baseTokenIndex[token]]] = baseTokenIndex[token];
        baseTokens.pop();
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) public pure override returns (address token0, address token1) {
        require(tokenA != tokenB, "LFWDEXUtils: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "LFWDEXUtils: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pancakeswap v1 pair without making any external calls
    function pairFor(uint256 dexID, address tokenA, address tokenB) public view override returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                dexList[dexID].factory,
                keccak256(abi.encodePacked(token0, token1)),
                dexList[dexID].initHash // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(uint256 dexID, address tokenA, address tokenB) public view override returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(dexID, tokenA, tokenB);
        uint256 balanceA = IBEP20(tokenA).balanceOf(pairFor(dexID, tokenA, tokenB));
        uint256 balanceB = IBEP20(tokenB).balanceOf(pairFor(dexID, tokenA, tokenB));
        if (balanceA == 0 && balanceB == 0) {
            (reserveA, reserveB) = (0, 0);
        } else {
            (uint reserve0, uint reserve1,) = IDEXPair(pairFor(dexID, tokenA, tokenB)).getReserves();
            (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);            
        }
    }

    // get balances directly from pair
    function getPairBalances(uint256 dexID, address tokenA, address tokenB) public view override returns (uint256 balanceA, uint256 balanceB) {
        address pair = pairFor(dexID, tokenA, tokenB);
        balanceA = IBEP20(tokenA).balanceOf(pair);
        balanceB = IBEP20(tokenB).balanceOf(pair);
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOutV1(uint256 dexID, uint amountIn, uint reserveIn, uint reserveOut) public view override returns (uint amountOut) {
        require(amountIn > 0, "LFWDEXUtils: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "LFWDEXUtils: INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn.mul(dexList[dexID].fee);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountInV1(uint256 dexID, uint amountOut, uint reserveIn, uint reserveOut) public view override returns (uint amountIn) {
        require(amountOut > 0, "LFWDEXUtils: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "LFWDEXUtils: INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(dexList[dexID].fee);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs, routed through multiple DEX's
    function getAmountsOutV1(uint amountIn, address[] memory path, uint256[] memory dexPath) public view override returns (uint[] memory amounts) {
        require(path.length >= 2 && dexPath.length == path.length-1, "LFWDEXUtils: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(dexPath[i], path[i], path[i + 1]);
            amounts[i + 1] = getAmountOutV1(dexPath[i], amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsInV1(uint amountOut, address[] memory path, uint256[] memory dexPath) public view override returns (uint[] memory amounts) {
        require(path.length >= 2 && dexPath.length == path.length-1, "LFWDEXUtils: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(dexPath[i - 1], path[i - 1], path[i]);
            amounts[i - 1] = getAmountInV1(dexPath[i - 1], amounts[i], reserveIn, reserveOut);
        }
    }

    function getPathReserves(address tokenA, address tokenB) public view override returns (uint256[] memory reservesIn, uint256[] memory reservesOut) {
        reservesIn = new uint256[](dexCount);
        reservesOut = new uint256[](dexCount);
        for (uint i; i < dexCount; i++) {
            (reservesIn[i], reservesOut[i]) = getReserves(i, tokenA, tokenB);
        }
    }

    function findUserGet(uint amountIn, address[] memory path) public view override returns (uint256[] memory amounts) {
        amounts = new uint256[](dexCount);
        for (uint i; i < dexCount; i++) {
            (uint balanceA, uint balanceB) = getPairBalances(i, path[0], path[1]);
            if (balanceA == 0 && balanceB == 0) {
                amounts[i] = 0;
            } else {
                amounts[i] = IDEXRouter(dexList[i].router).getAmountsOut(amountIn, path)[1];
            } 
            
        }
    }   
    
    // check if path is valid by ensuring all pairs hold token balances
    function isValidPath(address[] memory path, uint256[] memory dexPath) public view override returns (bool valid) {
        valid = path.length >= 2 && dexPath.length == path.length-1;
        for (uint i; i < path.length - 1; i++) {
            (uint256 balanceA, uint256 balanceB) = getPairBalances(dexPath[i], path[i], path[i + 1]);
            valid = valid && balanceA > 0 && balanceB > 0;
        }
    }

    function getLargestBasePair(address token) public view override returns (uint256 dexID, address pair, address baseToken) {
        uint256 largestReserve = 0;

        for(uint256 i=0; i<dexCount; i++){
            if(!dexList[i].enabled){ continue; }

            address nextFactory = dexList[i].factory;

            for(uint256 n=0; n<baseTokens.length; n++){
                address nextPair = IDEXFactory(nextFactory).getPair(token, baseTokens[n]);

                if(nextPair != address(0)){
                    uint256 reserve = IBEP20(token).balanceOf(nextPair);

                    if(reserve > largestReserve){
                        largestReserve = reserve;

                        dexID = i;
                        pair = nextPair;
                        baseToken = baseTokens[n];
                    }
                }
            }
        }
    }

    function getLargestDEX(address tokenA, address tokenB) public view override returns (uint256 dexID, address factory, address pair) {
        uint256 largestReserve = 0;

        for(uint256 i=0; i<dexCount; i++){
            if(!dexList[i].enabled){ continue; }

            address nextFactory = dexList[i].factory;
            address nextPair = IDEXFactory(nextFactory).getPair(tokenA, tokenB);

            if(nextPair != address(0)){
                (uint256 reserve0, uint256 reserve1) = getReserves(i, tokenA, tokenB);
                if(reserve0 + reserve1 > largestReserve){
                    largestReserve = reserve0 + reserve1;

                    dexID = i;
                    factory = nextFactory;
                    pair = nextPair;
                }
            }
        }
    }

    function getPriceDEX(address pairToken, address baseToken) public view override returns (uint256 dexID, address router, uint256 reserveRatio) {
        uint256 lowestPair = 100000000000000000000000;
        
        for(uint256 i=0; i<dexCount; i++){
            if(!dexList[i].enabled){ continue; }

            address nextFactory = dexList[i].factory;
            address nextRouter = dexList[i].router;
            address nextPair = IDEXFactory(nextFactory).getPair(pairToken, baseToken);
            
            if(nextPair != address(0)){
                uint256 reservePair = IBEP20(pairToken).balanceOf(nextPair);
                uint256 reserveBase = IBEP20(baseToken).balanceOf(nextPair);
                uint256 reserve = reservePair.div(reserveBase);

                if(reserve < lowestPair){
                    lowestPair = reserve;
                    dexID = i;
                    router = nextRouter;
                    reserveRatio = reserve;
                }
            }
        }
    }

}
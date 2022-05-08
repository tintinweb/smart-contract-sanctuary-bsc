pragma solidity =0.6.6;

import './interfaces/IBridgesFactory.sol';
import './interfaces/IPancakeFactory.sol';
import './libraries/utils/TransferHelper.sol';
import './interfaces/IBridgesRef.sol';
import './libraries/BridgesLibrary.sol';
import './libraries/SafeMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';
contract BridgesRef is IBridgesRef {
    using SafeMath for uint;
    mapping(address => bool) tokenWhiteList;   // don't apply fee protocol on pegged tokens
    mapping(address => bool) accountWhiteList; // don't apply fee protocol for white list accounts
    address public feeToSetter;
    
    bool public refOn = true;
    uint public disRate; 
    mapping(address => bool) public isReferred;
    mapping(address => bool) public isReferral;
    mapping(address => address) public referredToReferral;
    mapping(address => UserInfo) public referrers;
    mapping(address => bool) admin;
    uint magnitude = 2**128;
    uint public toDistribute;
    uint public Distributed;
    struct UserInfo {
        uint earned;
        uint paid;
        uint layer1;
        uint layer2;
        uint layer3;
    }

    modifier onlyRouter {
        require(msg.sender == router, 'only router');
        _;
    }

    address public router;
    address public bridgesToken;

    constructor() public {
        feeToSetter = msg.sender;
        admin[feeToSetter]=true;
    }

    function setFeeToSetter(address _feeToSetter) public virtual override{
        require(msg.sender == feeToSetter, "");
        feeToSetter = _feeToSetter;
    }
    function setAdmin(address _admin, bool isAdmin) public {
         require(msg.sender == feeToSetter, "");
         admin[_admin]=isAdmin;       
    }
    //manage Fees on the router
    function feeOn(address token, address user) public view virtual override returns (bool fee) {
        fee=true;
        if (tokenWhiteList[token] || accountWhiteList[user]) {
            fee = false;
        }
    }
    function withelistToken(address token, bool whitelist) public virtual override{
        require(admin[msg.sender], "only admins");
        tokenWhiteList[token] = whitelist;
    }
    function withelistUsers(address[] calldata users, bool whitelist) external virtual override{
        require(admin[msg.sender], "only admins");
        for(uint i; i < users.length; i++)
            accountWhiteList[users[i]] = whitelist;
    }
    function withelistUser(address user, bool whitelist) external virtual override{
        require(admin[msg.sender], "only admins");
        accountWhiteList[user] = whitelist;
    }

    //manage referral program
    function setRouter(address _router) public {
        require(msg.sender == feeToSetter);
        router = _router;
    }
    function setToken(address token) public{
        require(msg.sender == feeToSetter);
        bridgesToken = token;
    }
    function controller(bool isOn) public {
        require(msg.sender == feeToSetter);
        refOn = isOn;
    }
    function setReferrer(address _referral) public {

        require(!isReferred[msg.sender],"You already have a referral.");
        require(!isReferral[msg.sender],"You already know the platform ;)");
        require(msg.sender != _referral,"This is not allowed.");
        require(referredToReferral[_referral]!= msg.sender,"You can not refer yourself.");

        isReferred[msg.sender] = true;
        if(!isReferral[_referral]){
            isReferral[_referral] = true;
        }
        referredToReferral[msg.sender] = _referral;
        UserInfo storage user = referrers[_referral];
        UserInfo storage userR = referrers[msg.sender];

        //head update
        user.layer1 = user.layer1.add(1);
        if(isReferral[msg.sender]){
            user.layer2 = user.layer2.add(userR.layer1);
            user.layer3 = user.layer3.add(userR.layer2);
        }
        //1 above head update
        if(isReferred[_referral]){
            address _referral2 = referredToReferral[_referral];
            UserInfo storage user2 = referrers[_referral2];
            user2.layer2 = user2.layer2.add(1);
            user2.layer3 = user2.layer3.add(userR.layer1);
            //2 above head update
            if(isReferred[_referral2]){
                address _referral3 = referredToReferral[_referral2];
                UserInfo storage user3 = referrers[_referral3];
                user3.layer3 = user3.layer3.add(1);
            }
        }
    }

    //distribution
    function setDisRate(uint _disRate) public {
        require(msg.sender == feeToSetter);
        disRate = _disRate;
    }
    function distribute(address _referred, uint amount) public override onlyRouter{
        if(refOn && isReferred[_referred]){
            uint _amount = amount.mul(disRate).mul(magnitude);
            address _referral = referredToReferral[_referred];
            UserInfo storage user = referrers[_referral];
            user.earned = user.earned.add(_amount);
            if(isReferred[_referral]){
                uint _amount2 = amount.mul(disRate.div(2)).mul(magnitude);
                address _referral2 = referredToReferral[_referral];
                UserInfo storage user2 = referrers[_referral2];
                user2.earned = user2.earned.add(_amount2);
                if(isReferred[_referral2]){
                    uint _amount3 = amount.mul(disRate.div(4)).mul(magnitude);
                    address _referral3 = referredToReferral[_referral2];
                    UserInfo storage user3 = referrers[_referral3];
                    user3.earned = user3.earned.add(_amount3);
                }
            }
        }
    }

    function withdraw() public {
        UserInfo storage user = referrers[msg.sender];
        uint pending = user.earned.div(magnitude).sub(user.paid);
        if(pending > 0 ){
            if(IERC20(bridgesToken).balanceOf(address(this)) > pending){
                TransferHelper.safeTransfer(bridgesToken, msg.sender, pending);
                user.paid = user.earned.div(magnitude);
            }else{
                uint bal = IERC20(bridgesToken).balanceOf(address(this));
                TransferHelper.safeTransfer(bridgesToken, msg.sender, bal);
                user.paid = user.earned.div(magnitude);
            }
        }
    }

    function availableRewards() public view returns(uint amount, uint paid, uint layer1, uint layer2, uint layer3){
        UserInfo storage user = referrers[msg.sender];
        amount = user.earned.div(magnitude).sub(user.paid);
        paid = user.paid;
        layer1 = user.layer1;
        layer2 = user.layer2;
        layer3 = user.layer3;
    }
    function bep20(uint value) public {
        //Emergency withdraw
        require(msg.sender == feeToSetter);
        TransferHelper.safeTransfer(bridgesToken, msg.sender, value);
    }   
}

pragma solidity >=0.5.0;

interface IBridgesFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function tradingStart() external view returns(uint);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setTradingStart(uint) external;
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IPancakeFactory {
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with BEP20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

pragma solidity >=0.6.2;
interface IBridgesRef {
    function feeOn(address, address) external view returns (bool fee);
    function withelistToken(address, bool) external;
    function withelistUser(address, bool) external;
    function withelistUsers(address[] calldata, bool) external;
    function setFeeToSetter(address) external;
    function distribute(address, uint) external;

}

pragma solidity >=0.5.0;

import '../interfaces/IBridgesPair.sol';
import '../interfaces/IPancakePair.sol';
import '../interfaces/IBridgesFactory.sol';
import '../interfaces/IPancakeFactory.sol';
import '../interfaces/IBridgesRef.sol';
import "./SafeMath.sol";

library BridgesLibrary {
    using SafeMath for uint;
    
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'BridgesLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'BridgesLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'a6c986da60c79faa6894f8bff479b079b847440de4b86249d8f99d9ef675b2ed' // init code hash
            ))));
    }
    function pairForPCS(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address factoryPCS,  address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        address pair = IBridgesFactory(factory).getPair(tokenA, tokenB);
        uint reserve0;
        uint reserve1;
        if (pair != address(0)){
            (reserve0, reserve1,) = IBridgesPair(pairFor(factory, tokenA, tokenB)).getReserves();
        }else{
            (reserve0, reserve1,) = IPancakePair(pairForPCS(factoryPCS, tokenA, tokenB)).getReserves();
        }
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    function getReservesLiq(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        uint reserve0;
        uint reserve1;
        (reserve0, reserve1,) = IBridgesPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'BridgesLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'BridgesLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'BridgesLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BridgesLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'BridgesLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'BridgesLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, address factoryPCS, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'BridgesLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, factoryPCS, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, address factoryPCS, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'BridgesLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, factoryPCS, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

}

pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint x, uint y) internal pure returns (uint z) {
        //assert(y > 0); // Solidity automatically throws when dividing by 0
        z = x / y;
        //assert(x == y * z + x % y); // There is no case in which this doesn't hold
    }
}

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity >=0.5.0;

interface IBridgesPair {
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
    function initialize(address, address, uint) external;
    function distributeDividends(uint) external payable;
    function withdraw() external;
    function availableRewards() external view returns(uint, uint);
}

pragma solidity >=0.5.0;

interface IPancakePair {
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
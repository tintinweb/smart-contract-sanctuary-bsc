/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address pair, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

interface Token {
    function decimals() external view returns (uint);
    function approve(address _spender, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function totalSupply() external view returns (uint theTotalSupply);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract DFN_INVEST {
    using SafeMath for uint;
    address public factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public LP_WBNB_USDT =0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;

    uint public baseForce= 1e18;
    address public BurnAddress ;
    address public WhiteAddress;  //test
    uint public FeeRatio = 0;
    address public FeeAddress;

    address public owner;
    address  administrator;

    mapping(address => mapping(address => uint)) public InvestMap;

    event InvestToken(address _sender,uint _force, uint _ratio, address _token, uint _price,address _inviter);
    event WithdrawEarning(address _sender,address _token);
    event WithdrawInvest(address _sender,uint _amount, uint _ratio);

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == administrator, "Permission denied");
        _;
    }

    constructor () {
        owner = msg.sender;
        administrator = msg.sender;
    }


    function changeOwner(address payable _add) public returns (bool) {
        require(msg.sender == owner);
        require(_add != address(0));
        owner = _add;
        return true;
    }

    function changeAdministrator(address payable _add) public returns (bool) {
        require(msg.sender == owner);
        require(_add != address(0));
        administrator = _add;
        return true;
    }

    function setConfig(uint _force, address _bu,address _white,uint _fee,address _add) public onlyOwner {
         baseForce = _force;
         BurnAddress = _bu;
         WhiteAddress = _white;
         FeeRatio  = _fee;
         FeeAddress  = _add;
    }

    function invest(uint _force, uint _ratio, address _token,address _inviter) public {
        require(msg.sender != _inviter, "TRC20: inveter myself");
        require(_force >= baseForce, "TRC20: The invest hash_rate is wrong");
        uint USDTAmount = _force.mul(_ratio).div(100);
        Token(USDT).transferFrom(msg.sender, WhiteAddress, USDTAmount);
        uint tokenPrice = getTokenPrice(1e18, _token, WBNB);
        uint TokenAmount = (_force - USDTAmount) * 1e18 / tokenPrice;
        Token(_token).transferFrom(msg.sender, BurnAddress, TokenAmount);
        InvestMap[msg.sender][_token] = TokenAmount;
        emit InvestToken(msg.sender,_force, _ratio, _token, tokenPrice, _inviter);
    }


    function withdrewEarning(address _token) public {
        emit WithdrawEarning(msg.sender,_token);
    }

    function withdrawInvest(address _sender,address[] memory _tokens) public onlyOwner {
        require(_tokens.length > 0);
        for (uint i = 0; i < _tokens.length; i++) {
            if(InvestMap[_sender][_tokens[i]] != 0){
                uint FeeAmount = 0;
                if (FeeRatio > 0) { 
                    FeeAmount = InvestMap[_sender][_tokens[i]] * (100 - FeeRatio) / 100;
                    Token(_tokens[i]).transferFrom(WhiteAddress,_sender, FeeAmount);
                }
                Token(_tokens[i]).transferFrom(WhiteAddress,FeeAddress, InvestMap[_sender][_tokens[i]].sub(FeeAmount));
                InvestMap[_sender][_tokens[i]]= 0;
                emit WithdrawInvest(_sender,InvestMap[_sender][_tokens[i]], FeeRatio); 
            }
        }
    }


    function withdrawToken(address _token, address _add, uint256 _amount) public onlyOwner {
        Token(_token).transfer(_add, _amount);
    }


    function getTokenPrice(uint amountA, address tokenA, address tokenB) public view returns (uint){
        address pair = IPancakeFactory(factory).getPair(tokenA, tokenB);
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(pair, tokenA, tokenB);
        return PancakeLibrary.quote(amountA, reserveA, reserveB).mul(1e18).div(getBnbPrice());
    }


    function getBnbPrice() public view returns (uint){
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(LP_WBNB_USDT, USDT, WBNB);
        return PancakeLibrary.quote(1e18, reserveA, reserveB);
    }


}
/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

pragma solidity 0.5.16;

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
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    
}

library Math {
    
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    
}

interface IOneCoinPair{
    function admin() external view returns (address);
    function token() external view returns (address);
    function payToken() external view returns (address);
    
    function price() external view returns (uint);
    function priceRate() external view returns (uint);
    function initialize(address tokenCon, address payTokenCon, uint initPrice, uint priceSpace) external;
    function buy(uint amountOut, address to) external returns (uint amountInPay, uint endPrice);
    function sell(uint amountIn, address to) external returns(uint amountOutPay, uint endPrice);
    function getAmountInPayToken(uint amountOut) external view returns(uint amountInPay, uint endPrice);
    function getAmountOutPayToken(uint amountIn) external view returns(uint amountOutPay, uint endPrice);
}


contract OneCoinPair is IOneCoinPair{
    
    using SafeMath for uint;
    
    address private _admin;
    
    address private _token;
    address private _payToken;
    
    uint private _price;
    
    uint private _priceRate;//10000 /10**18
    
    uint private _d;
    // uint private _dp;
    
    // uint private _c;
    // uint private _cp;
    
    // uint private _r;
    // uint private _rp;
    
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'OneCoin: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    
    function initialize(address tokenCon, address payTokenCon, uint initPrice, uint priceSpace) external{
        require(msg.sender == _admin, 'OneCoin: FORBIDDEN'); // sufficient check
        _token = tokenCon;
        _payToken = payTokenCon;
        _price = initPrice;
        _priceRate = priceSpace;
        _d = IBEP20(tokenCon).decimals();
        // _dp = IBEP20(payTokenCon).decimals();
    }
    
    function getAmountInPayToken(uint amountOut) public view returns(uint amountInPay, uint endPrice){
        endPrice = _price.add(_priceRate.mul(amountOut).div(10**_d));
        amountInPay = _price.add(endPrice).mul(amountOut).div(2*10**_d);
    }
    
    function getAmountOutPayToken(uint amountIn) public view returns(uint amountOutPay, uint endPrice){
        endPrice = _price.sub(_priceRate.mul(amountIn).div(10**_d));
        amountOutPay = _price.add(endPrice).mul(amountIn).div(2*10**_d);
    }
    
    function buy(uint amountOut, address to) external lock returns (uint amountInPay, uint endPrice){
        require(msg.sender == _admin,'OneCoin: FORBIDDEN');
        (amountInPay, endPrice) = getAmountInPayToken(amountOut);
        IBEP20(_token).transfer(to, amountOut);
        _price = endPrice;
    }
    
    function sell(uint amountIn, address to) external lock returns (uint amountOutPay, uint endPrice){
        require(msg.sender == _admin,'OneCoin: FORBIDDEN');
        (amountOutPay, endPrice) = getAmountOutPayToken(amountIn);
        IBEP20(_payToken).transfer(to, amountOutPay);
        _price = endPrice;
    }
    
    function admin() external view returns (address){
        return _admin;
    }
    function token() external view returns (address){
        return _token;
    }
    function payToken() external view returns (address){
        return _payToken;
    }
    function price() external view returns (uint){
        return _price;
    }
    function priceRate() external view returns (uint){
        return _priceRate;
    }
}

contract OneCoinAdmin{
    
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    
    using SafeMath for uint;
    address public feeTo;
    address public admin;
    
    mapping(address => mapping(address => address)) public getPair;
    mapping(address => uint) private feeAll;
    address[] public allPairs;
    
    constructor(address _admin) public {
        admin = _admin;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }
    
    function createPair(address payToken, address token, uint initPrice, uint priceSpace) external returns (address pair) {
        require(msg.sender == admin, 'OneCoin: FORBIDDEN');
        require(token != payToken, 'OneCoin: IDENTICAL_ADDRESSES');
        require(token != address(0) && payToken != address(0), 'OneCoin: ZERO_ADDRESS');
        require(getPair[payToken][token] == address(0), 'OneCoin: PAIR_EXISTS');
        bytes memory bytecode = type(OneCoinPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token, payToken));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IOneCoinPair(pair).initialize(token, payToken, initPrice, priceSpace);
        
        getPair[payToken][token] = pair;
        allPairs.push(pair);
        emit PairCreated(payToken, token, pair, allPairs.length);
    }
    
    function buyExactToken(address payToken, address token, uint amountInMax, uint amountOut, address to) external returns(bool success){
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair pairContract = IOneCoinPair(pairAddress);
        (uint amountInPay,) = pairContract.buy(amountOut, to);
        require(amountInPay <= amountInMax, 'OneCoin: EXCESSIVE_INPUT_AMOUNT');
        IBEP20(payToken).transferFrom(msg.sender, pairAddress, amountInPay);
        success = true;
    }
    
    function sellExactToken(address payToken, address token, uint amountIn, uint amountOutMin, address to) external returns(bool success){
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair pairContract = IOneCoinPair(pairAddress);
        IBEP20(token).transferFrom(msg.sender, pairAddress, amountIn);
        (uint amountOutPay,) = pairContract.sell(amountIn, to);
        require(amountOutPay >= amountOutMin, 'OneCoin: EXCESSIVE_OUTPUT_AMOUNT');
        IBEP20(payToken).transfer(msg.sender, amountOutPay);
        success = true;
    }
    
    function getPairTradeFee(address pair) external view returns (uint){
        return feeAll[pair];
    }
    
    function getPairTradeFee(address token, address payToken) external view returns (uint){
        return feeAll[getPair[payToken][token]];
    }
    
    function setPairTradeFee(address pair, uint fee) external returns(bool){
        require(msg.sender == admin, 'OneCoin: FORBIDDEN');
        require(fee >= 0 && fee < 10000, 'OneCoin: fee failed');
        feeAll[pair] = fee;
        return true;
    }
    
    function setFeeTo(address _feeTo) external {
        require(msg.sender == admin, 'OneCoin: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _admin) external {
        require(msg.sender == admin, 'OneCoin: FORBIDDEN');
        admin = _admin;
    }
}
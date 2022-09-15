/**
 *Submitted for verification at BscScan.com on 2022-09-15
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
    
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
    
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

interface IOneCoinPair{
    function admin() external view returns (address);
    function token() external view returns (address);
    function payToken() external view returns (address);
    
    function price() external view returns (uint);
    function priceRate() external view returns (uint);
    function getInfo() external view returns(uint currPrice, uint priceSpace, uint decimals);
    function initialize(address tokenCon, address payTokenCon, uint initPrice, uint priceSpace) external;
    // function buyExactToken(uint amountOut, address to) external;
    function buyToken(address to) external;
    // function sellExactPayToken(uint amountOutPay, address to) external;
    function sellToken(address to) external;
    function getAmountInPayToken(uint amountOut) external view returns(uint amountInPay, uint endPrice);
    function getAmountOutPayToken(uint amountIn) external view returns(uint amountOutPay, uint endPrice);
    function getAmountInToken(uint amountOutPay) external view returns(uint amountIn, uint endPrice);
    function getAmountOutToken(uint amountInPay) external view returns(uint amountOut, uint endPrice);
    function reserves() external view returns (uint reserve, uint reservePay);
    // function skim(address to) external;
    function sync() external;
}


contract OneCoinPair is IOneCoinPair{
    
    using SafeMath for uint;
    
    address private _admin;
    
    address private _token;
    address private _payToken;
    
    uint private _reserve;
    uint private _reservePay;
    
    uint private _price;
    
    uint private _priceRate;//10000 /10**18
    
    uint private _d;
    
    constructor() public {
        _admin = msg.sender;
    }
    
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
    
    function getAmountInToken(uint amountOutPay) public view returns(uint amountIn, uint endPrice){
        uint y = (_price * 10**_d/_priceRate) **2 - amountOutPay * 2*10**_d * 10**_d/_priceRate;
        amountIn = _price * 10**_d/_priceRate - y.sqrt();
        endPrice = _price.sub(_priceRate.mul(amountIn).div(10**_d));
    }
    
    function getAmountOutToken(uint amountInPay) public view returns(uint amountOut, uint endPrice){
        uint y = amountInPay * 2 * 10**_d * 10**_d / _priceRate + (_price*10**_d/_priceRate)**2;
        amountOut = y.sqrt() - _price * 10**_d / _priceRate;
        endPrice = _price.add(_priceRate.mul(amountOut).div(10**_d));
    }
    
    // function buyExactToken(uint amountOut, address to) external lock {
    //     require(msg.sender == _admin,'OneCoin: FORBIDDEN');
    //     require(amountOut < _reserve, 'OneCoin: INSUFFICIENT_RESERVE');
        
    //     (uint amountInPay, uint endPrice) = getAmountInPayToken(amountOut);
        
    //     require(IBEP20(_payToken).balanceOf(address(this)) >= _reservePay.add(amountInPay), 'OneCoin: INSUFFICIENT_INPUTPAY_AMOUNT');
        
    //     IBEP20(_token).transfer(to, amountOut);
    //     _price = endPrice;
        
    //     _update(IBEP20(_token).balanceOf(address(this)), IBEP20(_payToken).balanceOf(address(this)));
    // }
    
    function buyToken(address to) external lock {
        require(msg.sender == _admin,'OneCoin: FORBIDDEN');
        uint amountInPay = IBEP20(_payToken).balanceOf(address(this)) - _reservePay;
        require(amountInPay > 0, 'OneCoin: INPUTPAY_AMOUNT_ZERO');
        (uint amountOut, uint endPrice) = getAmountOutToken(amountInPay);
        require(amountOut < _reserve, 'OneCoin: INSUFFICIENT_RESERVE');
        
        IBEP20(_token).transfer(to, amountOut);
        _price = endPrice;
        
        _update(IBEP20(_token).balanceOf(address(this)), IBEP20(_payToken).balanceOf(address(this)));
    }
    
    // function sellExactPayToken(uint amountOutPay, address to) external lock{
    //     require(msg.sender == _admin,'OneCoin: FORBIDDEN');
    //     require(amountOutPay > 0, 'OneCoin: OUTPUTPAY_AMOUNT_ZERO');
    //     require(amountOutPay < _reservePay, 'OneCoin: INSUFFICIENT_RESERVEPAY');
    //     (uint amountIn, uint endPrice) = getAmountInToken(amountOutPay);
    //     require(IBEP20(_token).balanceOf(address(this)) >= _reserve.add(amountIn), 'OneCoin: INSUFFICIENT_INPUT_AMOUNT');
    //     require(endPrice > 0 && endPrice < _price, 'OneCoin: sell amount failed');
    //     IBEP20(_payToken).transfer(to, amountOutPay);
    //     _price = endPrice;
    //     _update(IBEP20(_token).balanceOf(address(this)), IBEP20(_payToken).balanceOf(address(this)));
    // }
    
    function sellToken(address to) external lock{
        require(msg.sender == _admin,'OneCoin: FORBIDDEN');
        uint amountIn = IBEP20(_token).balanceOf(address(this)).sub(_reserve);
        require(amountIn > 0, 'OneCoin: INPUT_AMOUNT_ZERO');
        (uint amountOutPay, uint endPrice) = getAmountOutPayToken(amountIn);
        require(amountOutPay > 0, 'OneCoin: OUTPUT_AMOUNT_ZERO');
        require(amountOutPay < _reservePay, 'OneCoin: INSUFFICIENT_RESERVEPAY');
        require(endPrice > 0 && endPrice < _price, 'OneCoin: sell amount failed');
        IBEP20(_payToken).transfer(to, amountOutPay);
        _price = endPrice;
        _update(IBEP20(_token).balanceOf(address(this)), IBEP20(_payToken).balanceOf(address(this)));
    }
    
    function getInfo() external view returns(uint currPrice, uint priceSpace, uint decimals){
        currPrice = _price;
        priceSpace = _priceRate;
        decimals = _d;
    }
    
    function sync() external lock {
        _update(IBEP20(_token).balanceOf(address(this)), IBEP20(_payToken).balanceOf(address(this)));
    }
    
    function _update(uint newReserve, uint newReservePay) private{
        _reserve = newReserve;
        _reservePay = newReservePay;
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
    function reserves() external view returns (uint reserve, uint reservePay){
        reserve = _reserve;
        reservePay = _reservePay;
    }
    
}

contract OneCoinAdmin{
    
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    
    using SafeMath for uint;
    address public feeTo;
    address public admin;
    uint public feeAdmin;
    
    mapping(address => mapping(address => address)) public getPair;
    mapping(address => uint) private feeAll;
    mapping(address => address) private pairFeeAddress;
    
    address[] public allPairs;
    
    constructor() public {
        admin = msg.sender;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }
    
    modifier isAdmin(){
        require(msg.sender == admin, 'OneCoin: FORBIDDEN');
        _;
    }
    
    function createPair(address payToken, address token, uint initPrice, uint priceSpace) external isAdmin returns (address pair) {
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
    
    function buyExactPayToken(address payToken, address token, uint amountOutMin, uint amountInPay, address to) external {
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair pair = IOneCoinPair(pairAddress);
        
        uint feeAdminAmount = 0;
        if (feeAdmin > 0 && feeTo != address(0)) feeAdminAmount = amountInPay.mul(feeAdmin).div(10000);
        
        
        uint feeAmount = 0;
        if (feeAll[pairAddress] > 0 && pairFeeAddress[pairAddress] != address(0)) feeAmount = amountInPay.mul(feeAll[pairAddress]).div(10000);
        
        if (feeAmount > 0) IBEP20(payToken).transferFrom(msg.sender, pairFeeAddress[pairAddress], feeAmount);
        if (feeAdminAmount > 0) IBEP20(payToken).transferFrom(msg.sender, feeTo, feeAdminAmount);
        
        IBEP20(payToken).transferFrom(msg.sender, pairAddress, amountInPay.sub(feeAmount).sub(feeAdminAmount));
        
        uint balanceBefore = IBEP20(token).balanceOf(to);
        pair.buyToken(to);
        require(
            IBEP20(token).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'OneCoin: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    
    function buyExactToken(address payToken, address token, uint amountInPayMax, uint amountOut, address to) external {
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair pair = IOneCoinPair(pairAddress);
        
        (uint amountInPay,) = pair.getAmountInPayToken(amountOut);
        
        uint feeAdminAmount = 0;
        if (feeAdmin > 0 && feeTo != address(0)) feeAdminAmount = amountInPay.mul(feeAdmin).div(10000);
        
        uint feeAmount = 0;
        if (feeAll[pairAddress] > 0 && pairFeeAddress[pairAddress] != address(0)) feeAmount = amountInPay.mul(feeAll[pairAddress]).div(10000);
        
        require(
            amountInPay.add(feeAmount).add(feeAdminAmount) <= amountInPayMax,
            'EXCESSIVE_INPUT_AMOUNT'
        );
        
        if (feeAdminAmount > 0) IBEP20(payToken).transferFrom(msg.sender, feeTo, feeAdminAmount);
        if (feeAmount > 0) IBEP20(payToken).transferFrom(msg.sender, pairFeeAddress[pairAddress], feeAmount);
        
        IBEP20(payToken).transferFrom(msg.sender, pairAddress, amountInPay);
        pair.buyToken(to);
        
    }
    
    function sellExactToken(address payToken, address token, uint amountIn, uint amountOutPayMin, address to) external {
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair pair = IOneCoinPair(pairAddress);
        
        uint feeAmount = 0;
        if (feeAll[pairAddress] > 0 && pairFeeAddress[pairAddress] != address(0)) feeAmount = amountIn.mul(feeAll[pairAddress]).div(10000);
        if (feeAmount > 0) IBEP20(token).transferFrom(msg.sender, pairFeeAddress[pairAddress], feeAmount);
        
        IBEP20(token).transferFrom(msg.sender, pairAddress, amountIn.sub(feeAmount));
        
        uint balanceBefore = IBEP20(payToken).balanceOf(to);
        pair.sellToken(to);
        uint outPay = IBEP20(payToken).balanceOf(to).sub(balanceBefore);
        
        uint feeAdminAmount = 0;
        if (feeAdmin > 0 && feeTo != address(0)) feeAdminAmount = outPay.mul(feeAdmin).div(10000);
        if (feeAdminAmount > 0) IBEP20(payToken).transferFrom(msg.sender, feeTo, feeAdminAmount);
        
        require(
            IBEP20(payToken).balanceOf(to).sub(balanceBefore) >= amountOutPayMin,
            'INSUFFICIENT_OUTPUT_AMOUNT'
        );
        
    }
    
    function sellExactPayToken(address payToken, address token, uint amountOutPay, uint amountInMax, address to) external{
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair pair = IOneCoinPair(pairAddress);
        
        uint feeAmount = 0;
        if (feeAll[pairAddress] > 0 && pairFeeAddress[pairAddress] != address(0)) feeAmount = amountOutPay.mul(feeAll[pairAddress]).div(10000);
        uint feeAdminAmount = 0;
        if (feeAdmin > 0 && feeTo != address(0)) feeAdminAmount = amountOutPay.mul(feeAdmin).div(10000);
        
        (uint amountIn,) = pair.getAmountInToken(amountOutPay.add(feeAmount).add(feeAdminAmount));
        
        require(amountIn <= amountInMax, 'OneCoin: EXCESSIVE_INPUT_AMOUNT');
        
        IBEP20(token).transferFrom(msg.sender, pairAddress, amountIn);
        
        uint balanceBefore = IBEP20(payToken).balanceOf(to);
        pair.sellToken(to);
        uint outPay = IBEP20(payToken).balanceOf(to).sub(balanceBefore);
        
        if (feeAmount > 0){
            feeAmount = outPay.mul(feeAll[pairAddress]).div(10000);
            IBEP20(payToken).transferFrom(msg.sender, pairFeeAddress[pairAddress], feeAmount);
        } 
        if (feeAdminAmount > 0){
            feeAdminAmount = outPay.mul(feeAdmin).div(10000);
            IBEP20(payToken).transferFrom(msg.sender, feeTo, feeAdminAmount);
        }
    }
    
    function getPairTradeFee(address pair) external view returns (uint){
        return feeAll[pair];
    }
    
    function getPairTradeFee(address payToken, address token) external view returns (uint){
        return feeAll[getPair[payToken][token]];
    }
    
    function setPairTradeFee(address pair, uint fee) external isAdmin returns(bool){
        require(pair != address(0), 'OneCoin: PAIR_ZERO_ADDRESS');
        require(fee >= 0 && fee < 10000, 'OneCoin: fee failed');
        feeAll[pair] = fee;
        return true;
    }
    
    function getPairFeeAddress(address payToken, address token) external view returns(address){
        return pairFeeAddress[getPair[payToken][token]];
    }
    
    function getPairFeeAddress(address pair) external view returns(address){
        return pairFeeAddress[pair];
    }
    
    function setPairFeeAddress(address pair, address feeAddress) external isAdmin returns(bool){
        require(pair != address(0), 'OneCoin: PAIR_ZERO_ADDRESS');
        pairFeeAddress[pair] = feeAddress;
        return true;
    }
    
    function setFeeTo(address _feeTo) external isAdmin{
        feeTo = _feeTo;
    }

    function setAdmin(address _admin) external isAdmin{
        admin = _admin;
    }
    
    function setFeeAdmin(uint _feeAdmin) external isAdmin{
        require(_feeAdmin >= 0 && _feeAdmin < 10000, 'OneCoin: admin fee failed');
        feeAdmin = _feeAdmin;
    }
    
    function getPairInfo(address payToken, address token) external view returns(uint currPrice, uint priceSpace, uint decimals){
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        (currPrice, priceSpace, decimals) = IOneCoinPair(pairAddress).getInfo();
    }
}
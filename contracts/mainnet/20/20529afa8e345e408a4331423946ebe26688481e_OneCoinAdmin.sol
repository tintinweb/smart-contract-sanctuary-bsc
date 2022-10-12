/**
 *Submitted for verification at BscScan.com on 2022-10-12
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
    function getInfo() external view returns(uint initPrice, uint currPrice, uint priceSpace, uint decimals);
    function initialize(address tokenCon, address payTokenCon, uint initPrice, uint priceSpace) external;
    function setPrices(uint initPrice, uint priceSpace) external;
    // function buyExactToken(uint amountOut, address to) external;
    function buyToken(address to, uint amountOut) external;
    // function sellExactPayToken(uint amountOutPay, address to) external;
    function sellToken(address to) external;
    function getAmountInPayToken(uint amountOut) external view returns(uint amountInPay, uint endPrice);
    function getAmountOutPayToken(uint amountIn) external view returns(uint amountOutPay, uint endPrice);
    // function getAmountInToken(uint amountOutPay) external view returns(uint amountIn, uint endPrice);
    // function getAmountOutToken(uint amountInPay) external view returns(uint amountOut, uint endPrice);
    function reserves() external view returns (uint reserve, uint reservePay);
    // function skim(address to) external;
    function sync() external;
    function removeTokens(uint payTokenAmount, uint tokenAmount, address to) external;
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
    
    uint private _initPrice;
    
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
        _initPrice = initPrice;
        // _dp = IBEP20(payTokenCon).decimals();
    }
    
    function setPrices(uint initPrice, uint priceSpace) external{
        require(msg.sender == _admin, 'OneCoin: FORBIDDEN'); // sufficient check
        _price = initPrice;
        _priceRate = priceSpace;
        _initPrice = initPrice;
    }
    
    function getAmountInPayToken(uint amountOut) public view returns(uint amountInPay, uint endPrice){
        endPrice = _price;
        if (amountOut >= 10 ** _d){
            uint n = amountOut / 10 ** _d;
            uint q = 10**_d * (_priceRate + 1) / _priceRate;
            uint qp = pow(q, _d, n);
        
            uint shang = endPrice * (qp - 10**_d);
            uint xia = q - 10**_d;
            endPrice = endPrice * qp / 10**_d;
            amountInPay = shang/ xia;
        }
        
        uint m = amountOut % 10 ** _d;
        
        if (m > 0){
            amountInPay += endPrice * m / 10 ** _d;
            endPrice += endPrice * m / _priceRate / 10 ** _d;
        }
    }
    
    function getAmountOutPayToken(uint amountIn) public view returns(uint amountOutPay, uint endPrice){
        endPrice = _price;
        if (amountIn >= 10 ** _d){
            uint n = amountIn / 10 ** _d;
            uint q = 10**_d * (_priceRate - 1) / _priceRate;
            uint qp = pow(q, _d, n);
        
            uint shang = endPrice * (10**_d - qp);
            uint xia = 10**_d - q;
            
            endPrice = endPrice * qp / 10**_d;
            amountOutPay = shang/ xia;
        }
        uint m = amountIn % 10 ** _d;
        if (m > 0){
            amountOutPay += endPrice * m / 10 ** _d;
            endPrice -= endPrice * m / _priceRate / 10 ** _d;
        }
    }
    
    function pow(uint n, uint d, uint p) internal pure returns(uint){
        uint q = 10**d;
        
        if (p % 2 > 0) q = q * n / 10 ** d;
        while(p > 1){
            n = n ** 2 / 10 ** d;
            p = p / 2;
            if (p % 2 > 0) q = q * n / 10 ** d;
        }
        return q;
    }
    
    // function getAmountInPayToken(uint amountOut) public view returns(uint amountInPay, uint endPrice){
    //     endPrice = _price.add(_priceRate.mul(amountOut).div(10**_d));
    //     amountInPay = _price.add(endPrice).mul(amountOut).div(2*10**_d);
    // }
    
    // function getAmountOutPayToken(uint amountIn) public view returns(uint amountOutPay, uint endPrice){
    //     endPrice = _price.sub(_priceRate.mul(amountIn).div(10**_d));
    //     amountOutPay = _price.add(endPrice).mul(amountIn).div(2*10**_d);
    // }
    
    // function getAmountInToken(uint amountOutPay) public view returns(uint amountIn, uint endPrice){
    //     uint y = (_price * 10**_d/_priceRate) **2 - amountOutPay * 2*10**_d * 10**_d/_priceRate;
    //     amountIn = _price * 10**_d/_priceRate - y.sqrt();
    //     endPrice = _price.sub(_priceRate.mul(amountIn).div(10**_d));
    // }
    
    // function getAmountOutToken(uint amountInPay) public view returns(uint amountOut, uint endPrice){
    //     uint y = amountInPay * 2 * 10**_d * 10**_d / _priceRate + (_price*10**_d/_priceRate)**2;
    //     amountOut = y.sqrt() - _price * 10**_d / _priceRate;
    //     endPrice = _price.add(_priceRate.mul(amountOut).div(10**_d));
    // }
    
    function buyToken(address to, uint amountOut) external lock {
        require(msg.sender == _admin,'OneCoin: FORBIDDEN');
        uint amountInPay = IBEP20(_payToken).balanceOf(address(this)) - _reservePay;
        require(amountInPay > 0, 'OneCoin: INPUTPAY_AMOUNT_ZERO');
        
        (uint aip, uint endPrice) = getAmountInPayToken(amountOut);
        
        require(amountInPay >= aip, 'OneCoin: INSUFFICIENT_INPUTPAY_AMOUNT');
        
        
        // (uint amountOut, uint endPrice) = getAmountOutToken(amountInPay);
        
        require(amountOut < _reserve, 'OneCoin: INSUFFICIENT_RESERVE');
        
        IBEP20(_token).transfer(to, amountOut);
        // _priceRate = endPrice.mul(_priceRate).div(_price);
        _price = endPrice;
        
        _update(IBEP20(_token).balanceOf(address(this)), IBEP20(_payToken).balanceOf(address(this)));
        
        
    }
    
    function sellToken(address to) external lock{
        require(msg.sender == _admin,'OneCoin: FORBIDDEN');
        uint amountIn = IBEP20(_token).balanceOf(address(this)).sub(_reserve);
        require(amountIn > 0, 'OneCoin: INPUT_AMOUNT_ZERO');
        (uint amountOutPay, uint endPrice) = getAmountOutPayToken(amountIn);
        require(amountOutPay > 0, 'OneCoin: OUTPUT_AMOUNT_ZERO');
        require(amountOutPay < _reservePay, 'OneCoin: INSUFFICIENT_RESERVEPAY');
        require(endPrice > 0 && endPrice < _price, 'OneCoin: sell amount failed');
        IBEP20(_payToken).transfer(to, amountOutPay);
        // _priceRate = endPrice.mul(_priceRate).div(_price);
        _price = endPrice;
        _update(IBEP20(_token).balanceOf(address(this)), IBEP20(_payToken).balanceOf(address(this)));
    }
    
    function getInfo() external view returns(uint initPrice, uint currPrice, uint priceSpace, uint decimals){
        initPrice = _initPrice;
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
    function removeTokens(uint payTokenAmount, uint tokenAmount, address to) external{
        require(msg.sender == _admin,'OneCoin: FORBIDDEN');
        if (tokenAmount > 0) IBEP20(_token).transfer(to, tokenAmount);
        if (payTokenAmount > 0) IBEP20(_payToken).transfer(to, payTokenAmount);
        _update(IBEP20(_token).balanceOf(address(this)), IBEP20(_payToken).balanceOf(address(this)));
    }
    
}

contract OneCoinAdmin{
    
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    
    using SafeMath for uint;
    // address public feeTo;
    address public admin;
    // uint public feeAdmin;
    
    
    address private _blcToken = address(0xBDAe299165D8031C41AC70A798A8416337a5c098);
    address private _toYX = address(0x5b30dF8B82A0dC21a6c9F2A9a83558c79B2Ba248);
    address private _toJJ = address(0x509998A331a528E2F42B17638Ae4d6a636f06f0e);
    address private _toJD = address(0xCA195a3e343e3Fdac93AdDDbd8Ec376807A2A0fE);
    address private _toLP = address(0x092F5027806d8B0a597d5688D1A04Fa3252AC4B3);
    address private _deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    uint private _feeYX = 50;
    uint private _feeJJ = 50;
    uint private _feeJD = 100;
    uint private _feeLP = 200;
    uint private _feeDead = 200;
    
    address private _toGas;
    uint private _gas = 100;
    
    uint private _minBlc = 210000*10**18;
    
    mapping(address => mapping(address => address)) public getPair;
    // mapping(address => uint) private feeAll;
    mapping(address => address) private pairFeeAddress;
    
    mapping(address => mapping(address => uint)) private _lpPayToken;
    mapping(address => mapping(address => uint)) private _lpToken;
    
    address[] public allPairs;
    
    constructor() public {
        admin = msg.sender;
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
    
    // function buyExactPayToken(address payToken, address token, uint amountOutMin, uint amountInPay, address to) external {
    //     address pairAddress = getPair[payToken][token];
    //     require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
    //     IOneCoinPair pair = IOneCoinPair(pairAddress);
        
    //     uint feeAdminAmount = 0;
    //     if (feeAdmin > 0 && feeTo != address(0)) feeAdminAmount = amountInPay.mul(feeAdmin).div(10000);
        
        
    //     uint feeAmount = 0;
    //     if (feeAll[pairAddress] > 0 && pairFeeAddress[pairAddress] != address(0)) feeAmount = amountInPay.mul(feeAll[pairAddress]).div(10000);
        
    //     if (feeAmount > 0) IBEP20(payToken).transferFrom(msg.sender, pairFeeAddress[pairAddress], feeAmount);
    //     if (feeAdminAmount > 0) IBEP20(payToken).transferFrom(msg.sender, feeTo, feeAdminAmount);
        
    //     IBEP20(payToken).transferFrom(msg.sender, pairAddress, amountInPay.sub(feeAmount).sub(feeAdminAmount));
        
    //     uint balanceBefore = IBEP20(token).balanceOf(to);
    //     pair.buyToken(to);
    //     require(
    //         IBEP20(token).balanceOf(to).sub(balanceBefore) >= amountOutMin,
    //         'OneCoin: INSUFFICIENT_OUTPUT_AMOUNT'
    //     );
    // }
    
    function buyExactToken(address payToken, address token, uint amountInPayMax, uint amountOut, address to) external {
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair pair = IOneCoinPair(pairAddress);
        
        (uint amountInPay, uint endPrice) = pair.getAmountInPayToken(amountOut);
        
        require(endPrice > 0, 'OneCoin: INVALID_AMOUNT');
        
        if(payToken != _blcToken && token != _blcToken){
            (, uint currPrice, , uint decimals) = IOneCoinPair(getPair[payToken][_blcToken]).getInfo();
            uint feeGas = amountInPay.mul(10**decimals).mul(_gas).div(currPrice).div(10000);
            IBEP20(_blcToken).transferFrom(msg.sender, _toGas, feeGas);
        }
        
        uint feeAmount = 0;
        uint feeAll = _feeYX.add(_feeJJ).add(_feeJD).add(_feeLP);
        if (token != _blcToken || IBEP20(token).totalSupply() > _minBlc + IBEP20(token).balanceOf(_deadAddress)){
            feeAll = feeAll.add(_feeDead);
        }
        if (feeAll > 0) feeAmount = amountOut.mul(feeAll).div(10000);
        
        // uint feeAmount = 0;
        // if (feeAll[pairAddress] > 0 && pairFeeAddress[pairAddress] != address(0)) feeAmount = amountOut.mul(feeAll[pairAddress]).div(10000);
        
        require(
            amountInPay <= amountInPayMax,
            'EXCESSIVE_INPUT_AMOUNT'
        );
        
        IBEP20(payToken).transferFrom(msg.sender, pairAddress, amountInPay);
        pair.buyToken(address(this), amountOut);
        IBEP20(token).transfer(to, amountOut.sub(feeAmount));
        
        // if (feeAdminAmount > 0) IBEP20(token).transfer(feeTo, feeAdminAmount);
        
        if (_feeYX > 0) IBEP20(token).transfer(_toYX, feeAmount.mul(_feeYX).div(feeAll));
        if (_feeJJ > 0) IBEP20(token).transfer(_toJJ, feeAmount.mul(_feeJJ).div(feeAll));
        if (_feeJD > 0) IBEP20(token).transfer(_toJD, feeAmount.mul(_feeJD).div(feeAll));
        if (_feeLP > 0) IBEP20(token).transfer(_toLP, feeAmount.mul(_feeLP).div(feeAll));
        if (_feeDead > 0) IBEP20(token).transfer(_deadAddress, feeAmount.mul(_feeDead).div(feeAll));
        
        // if (feeAmount > 0) IBEP20(token).transferFrom(msg.sender, pairFeeAddress[pairAddress], feeAmount);
        
    }
    
    function sellExactToken(address payToken, address token, uint amountIn, uint amountOutPayMin, address to) external {
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair pair = IOneCoinPair(pairAddress);
        
        if(payToken != _blcToken && token != _blcToken){
            (, uint cp, , uint d1) = pair.getInfo();
            (, uint currPrice, , uint decimals) = IOneCoinPair(getPair[payToken][_blcToken]).getInfo();
            uint feeGas = amountIn.mul(cp.mul(_gas).mul(10**decimals)).div((10**d1).mul(currPrice)).div(10000);
            IBEP20(_blcToken).transferFrom(msg.sender, _toGas, feeGas);
        }
        
        // uint feeAmount = 0;
        // if (feeAll[pairAddress] > 0 && pairFeeAddress[pairAddress] != address(0)) feeAmount = amountIn.mul(feeAll[pairAddress]).div(10000);
        // if (feeAmount > 0) IBEP20(token).transferFrom(msg.sender, pairFeeAddress[pairAddress], feeAmount);
        
        // uint feeAdminAmount = 0;
        // if (feeAdmin > 0 && feeTo != address(0)) feeAdminAmount = amountIn.mul(feeAdmin).div(10000);
        // if (feeAdminAmount > 0) IBEP20(token).transferFrom(msg.sender, feeTo, feeAdminAmount);
        
        uint feeAmount = 0;
        uint feeAll = _feeYX.add(_feeJJ).add(_feeJD).add(_feeLP);
        if (token != _blcToken || IBEP20(token).totalSupply() > _minBlc + IBEP20(token).balanceOf(_deadAddress)){
            feeAll = feeAll.add(_feeDead);
        }
        if (feeAll > 0) feeAmount = amountIn.mul(feeAll).div(10000);
        if (_feeYX > 0) IBEP20(token).transferFrom(msg.sender, _toYX, feeAmount.mul(_feeYX).div(feeAll));
        if (_feeJJ > 0) IBEP20(token).transferFrom(msg.sender, _toJJ, feeAmount.mul(_feeJJ).div(feeAll));
        if (_feeJD > 0) IBEP20(token).transferFrom(msg.sender, _toJD, feeAmount.mul(_feeJD).div(feeAll));
        if (_feeLP > 0) IBEP20(token).transferFrom(msg.sender, _toLP, feeAmount.mul(_feeLP).div(feeAll));
        if (_feeDead > 0) IBEP20(token).transferFrom(msg.sender, _deadAddress, feeAmount.mul(_feeDead).div(feeAll));
        
        IBEP20(token).transferFrom(msg.sender, pairAddress, amountIn.sub(feeAmount));
        
        uint balanceBefore = IBEP20(payToken).balanceOf(to);
        pair.sellToken(to);
        // uint outPay = IBEP20(payToken).balanceOf(to).sub(balanceBefore);
        
        require(
            IBEP20(payToken).balanceOf(to).sub(balanceBefore) >= amountOutPayMin,
            'INSUFFICIENT_OUTPUT_AMOUNT'
        );
        
    }
    
    // function sellExactPayToken(address payToken, address token, uint amountOutPay, uint amountInMax, address to) external{
    //     address pairAddress = getPair[payToken][token];
    //     require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
    //     IOneCoinPair pair = IOneCoinPair(pairAddress);
        
    //     uint feeAmount = 0;
    //     if (feeAll[pairAddress] > 0 && pairFeeAddress[pairAddress] != address(0)) feeAmount = amountOutPay.mul(feeAll[pairAddress]).div(10000);
    //     uint feeAdminAmount = 0;
    //     if (feeAdmin > 0 && feeTo != address(0)) feeAdminAmount = amountOutPay.mul(feeAdmin).div(10000);
        
    //     (uint amountIn,) = pair.getAmountInToken(amountOutPay.add(feeAmount).add(feeAdminAmount));
        
    //     require(amountIn <= amountInMax, 'OneCoin: EXCESSIVE_INPUT_AMOUNT');
        
    //     IBEP20(token).transferFrom(msg.sender, pairAddress, amountIn);
        
    //     uint balanceBefore = IBEP20(payToken).balanceOf(to);
    //     pair.sellToken(to);
    //     uint outPay = IBEP20(payToken).balanceOf(to).sub(balanceBefore);
        
    //     if (feeAmount > 0){
    //         feeAmount = outPay.mul(feeAll[pairAddress]).div(10000);
    //         IBEP20(payToken).transferFrom(msg.sender, pairFeeAddress[pairAddress], feeAmount);
    //     } 
    //     if (feeAdminAmount > 0){
    //         feeAdminAmount = outPay.mul(feeAdmin).div(10000);
    //         IBEP20(payToken).transferFrom(msg.sender, feeTo, feeAdminAmount);
    //     }
    // }
    
    // function getPairTradeFee(address pair) external view returns (uint){
    //     return feeAll[pair];
    // }
    
    // function getPairTradeFee(address payToken, address token) external view returns (uint){
    //     return feeAll[getPair[payToken][token]];
    // }
    
    // function setPairTradeFee(address pair, uint fee) external isAdmin returns(bool){
    //     require(pair != address(0), 'OneCoin: PAIR_ZERO_ADDRESS');
    //     require(fee >= 0 && fee < 10000, 'OneCoin: fee failed');
    //     feeAll[pair] = fee;
    //     return true;
    // }
    
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
    
    // function setFeeTo(address _feeTo) external isAdmin{
    //     feeTo = _feeTo;
    // }

    function setAdmin(address _admin) external isAdmin{
        admin = _admin;
    }
    
    // function setFeeAdmin(uint _feeAdmin) external isAdmin{
    //     require(_feeAdmin >= 0 && _feeAdmin < 10000, 'OneCoin: admin fee failed');
    //     feeAdmin = _feeAdmin;
    // }
    
    function getPairInfo(address payToken, address token) 
    external view returns(uint initPrice, uint currPrice, uint priceSpace, uint decimals, uint fee, uint feePair,uint reserve, uint reservePay){
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        (initPrice, currPrice, priceSpace, decimals) = IOneCoinPair(pairAddress).getInfo();
        fee = _gas;
        feePair = 0;
        (reserve, reservePay) = IOneCoinPair(pairAddress).reserves();
    }
    
    
    function addTokens(address payToken, address token, uint amountPayToken, address to) external{
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        // uint price = IOneCoinPair(pairAddress).price();
        (, uint currPrice, , uint decimals) = IOneCoinPair(pairAddress).getInfo();
        uint amountToken = amountPayToken.mul(10**decimals).div(currPrice);
        
        uint payTokenBefore = IBEP20(payToken).balanceOf(pairAddress);
        uint tokenBefore = IBEP20(token).balanceOf(pairAddress);
        IBEP20(payToken).transferFrom(msg.sender, pairAddress, amountPayToken);
        IBEP20(token).transferFrom(msg.sender, pairAddress, amountToken);
        _lpPayToken[pairAddress][to] = _lpPayToken[pairAddress][to].add(IBEP20(payToken).balanceOf(pairAddress).sub(payTokenBefore));
        _lpToken[pairAddress][to] = _lpToken[pairAddress][to].add(IBEP20(token).balanceOf(pairAddress).sub(tokenBefore));
        _syncPair(pairAddress);
    }
    
    function setPairPrice(address payToken, address token, uint initPrice, uint priceSpace) external isAdmin {
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        require(initPrice > 0, 'OneCoin: PRICE_INIT_ZERO');
        require(priceSpace > 0, 'OneCoin: PRICE_SPACE_ZERO');
        IOneCoinPair(pairAddress).setPrices(initPrice, priceSpace);
        _syncPair(pairAddress);
    }
    
    function syncPair(address payToken, address token) external {
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        _syncPair(pairAddress);
    }
    
    function _syncPair(address pair) internal {
        IOneCoinPair(pair).sync();
    }
    
    function removeTokensAdmin(address payToken, address token, uint payTokenAmount, uint tokenAmount, address to) external isAdmin{
        require(to != address(0), 'OneCoin: TO_ZERO_ADDRESS');
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        IOneCoinPair(pairAddress).removeTokens(payTokenAmount, tokenAmount, to);
    }
    
    function removeTokens(address payToken, address token, uint payTokenAmount, address to) external{
        require(to != address(0), 'OneCoin: TO_ZERO_ADDRESS');
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        
        uint payTokenTotal = _lpPayToken[pairAddress][msg.sender];
        uint tokenTotal = _lpToken[pairAddress][msg.sender];
        
        require(payTokenAmount <= payTokenTotal,'OneCoin:INSUFFICIENT_PAYTOKEN');
        
        uint amountToken = payTokenAmount.mul(tokenTotal).div(payTokenTotal);
        
        require(amountToken <= tokenTotal,'OneCoin:INSUFFICIENT_TOKEN');
        
        IOneCoinPair(pairAddress).removeTokens(payTokenAmount, amountToken, to);
        _lpPayToken[pairAddress][msg.sender] = _lpPayToken[pairAddress][msg.sender].sub(payTokenAmount);
        _lpToken[pairAddress][msg.sender] = _lpToken[pairAddress][msg.sender].sub(amountToken);
        
    }
    function getGas() external view returns(address, uint){
        return (_toGas, _gas);
    }
    
    function setGas(address addr, uint fee) external isAdmin{
        _toGas = addr;
        _gas = fee;
    }
    function toYX() external view returns (address, uint){
        return (_toYX, _feeYX);
    }
    function toJJ() external view returns (address, uint){
        return (_toJJ, _feeJJ);
    }
    function toJD() external view returns (address, uint){
        return (_toJD, _feeJD);
    }
    function toLP() external view returns (address, uint){
        return (_toLP, _feeLP);
    }
    function toDead() external view returns (address, uint){
        return (_deadAddress, _feeDead);
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }
    function setYX(address addr, uint fee) external isAdmin{
        _toYX = addr;
        _feeYX = fee;
    }
    function setJJ(address addr, uint fee) external isAdmin{
        _toJJ = addr;
        _feeJJ = fee;
    }
    function setJD(address addr, uint fee) external isAdmin{
        _toJD = addr;
        _feeJD = fee;
    }
    function setLP(address addr, uint fee) external isAdmin{
        _toLP = addr;
        _feeLP = fee;
    }
    function setDead(address addr, uint fee) external isAdmin{
        _deadAddress = addr;
        _feeDead = fee;
    }
    function minBlc() external view returns(uint){
        return _minBlc;
    }
    function setMinBlc(uint min) external {
        _minBlc = min;
    }
    function blcToken() external view returns(address){
        return _blcToken;
    }
    function setBlcToken(address token) external{
        _blcToken = token;
    }
    
    function getLps(address payToken, address token, address owner) external view returns(uint, uint){
        address pairAddress = getPair[payToken][token];
        require(pairAddress != address(0), 'OneCoin: INVALID_PATH');
        uint payTokenAmount = _lpPayToken[pairAddress][owner];
        uint tokenAmount = _lpToken[pairAddress][owner];
        return (payTokenAmount, tokenAmount);
    }
}
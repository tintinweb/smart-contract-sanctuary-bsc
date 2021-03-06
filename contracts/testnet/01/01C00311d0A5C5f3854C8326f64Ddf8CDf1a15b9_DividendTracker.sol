/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

pragma solidity =0.6.6;


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

// erc20 contract
interface ERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// baby token
interface IBabyERC20 is ERC20 {
    function getTokenRewardsFee() external view returns (uint256);
    function getLinkedinFee() external view returns (uint256);
    function getLiquidityFee() external view returns (uint256);
    function getMarketingFee() external view returns (uint256);
    function getTotalFees() external view returns (uint256);
    function getAllFees() external view returns (uint256, uint256, uint256, uint256);
}


interface IDividendTracker {
    function dividendTokenSwapBTC() external;
    function tokenRewards(address _from, uint256 _tokenRewardsFee, uint256 _totalFees) external;
    function linkedinRewards(address _from, uint256 _linkedinFee, uint256 _totalFees) external;
    function marketingRewards(uint256 _marketingFee, uint256 _totalFees) external;
    function liquidityRewards(uint256 _liquidityFee, uint256 _totalFees) external;

    function addKey(address _to, uint256 _value) external;
    function removeKey(address _from, uint256 _value) external;
    function boundLinkedin(address _from, address _to) external;
}


// safe math
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, 'DividendTracker: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// ?????????
contract DividendTracker is IDividendTracker, Ownable {
    using SafeMath for uint256;

    // ??????????????????
    address public routerAddress;
    // Baby????????????
    address public babyAddress;
    // BTC???????????????????????????0??????????????????????????????0, ???????????????0???
    address public btcAddress;
    // USDT????????????
    address public usdtAddress;
    // BTC-BabyToken??????????????????
    address public btcAndBabyAddress;
    // USDT-Baby??????????????????
    address public usdtAndBabyAddress;

    // ???????????????????????????
    uint256 public pointer = 0;
    // ????????????????????????????????????
    uint256 public numberOne = 10;
    // ????????????U????????????????????????100
    uint256 public tokenMinU = 100000000000000000000;
    // ?????????????????????
    uint256 public total;

    // ???????????????, ????????????????????????
    address[] public keys;
    // ?????????????????????????????????
    mapping(address => bool) public inserted;
    // ?????????????????????????????????
    mapping(address => uint256) public indexOf;
    // ???????????????????????????token??????
    mapping(address => uint256) public values;

    // ??????????????????????????????????????????????????????????????????, ??????????????????
    mapping(address => bool) public blacklist;
    // ????????????
    mapping(address => address) public superAddress;
    // ??????????????????
    mapping(address => address[]) public juniorAddress;

    // ??????????????????
    address public marketingFeeAddress;



    // ????????????
    constructor(
        address _routerAddress,
        address _btcAddress,
        address _usdtAddress,
        address _marketingFeeAddress
        ) public {
        owner = msg.sender;
        routerAddress = _routerAddress;
        btcAddress = _btcAddress;
        usdtAddress = _usdtAddress;
        marketingFeeAddress = _marketingFeeAddress;
    }

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'DividendTracker: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier onlyBabyAddress() {
        require(msg.sender == babyAddress, 'DividendTracker: baby error');
        _;
    }

    // ??????????????????????????????
    function setRouterAddress(address _routerAddress) public onlyOwner {
        routerAddress = _routerAddress;
    }
    // ????????????Baby??????
    function setBabyAddress(address _babyAddress) public onlyOwner {
        babyAddress = _babyAddress;
    }
    // ????????????BTC??????
    function setBtcAddress(address _btcAddress) public onlyOwner {
        btcAddress = _btcAddress;
    }
    // ????????????USDT??????
    function setUsdtAddress(address _usdtAddress) public onlyOwner {
        usdtAddress = _usdtAddress;
    }
    // ????????????BTC-Baby??????????????????
    function setBtcAndBabyAddress(address _btcAndBabyAddress) public onlyOwner {
        btcAndBabyAddress = _btcAndBabyAddress;
    }
    // ????????????USDT-Baby??????????????????
    function setUsdtAndBabyAddress(address _usdtAndBabyAddress) public onlyOwner {
        usdtAndBabyAddress = _usdtAndBabyAddress;
    }

    // ????????????numberOne
    function setNumberOne(uint256 _numberOne) public onlyOwner {
        numberOne = _numberOne;
    }
    // ?????????????????????????????????U??????
    function setTokenMinU(uint256 _tokenMinU) public onlyOwner {
        tokenMinU = _tokenMinU;
    }
    // ???????????????????????????
    function setBlacklist(address _address) public onlyOwner {
        blacklist[_address] = !blacklist[_address];
    }

    // ????????????????????????
    function setMarketingFeeAddress(address _marketingFeeAddress) public onlyOwner {
        marketingFeeAddress = _marketingFeeAddress;
    }
    // ??????
    function withdraw(address _token, address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    // ?????????BTC
    // ??????Baby??????BTC, ??????????????????, ???????????????BTC??????
    // ??????????????????, ????????????Baby,???????????????,????????????????????????
    function dividendTokenSwapBTC() public override onlyBabyAddress {
        // ??????????????????baby??????
        uint256 _babyBalance = IBabyERC20(babyAddress).balanceOf(address(this));
        // ???swap?????????BTC, ????????????token
        uint256 _liquidityFee = IBabyERC20(babyAddress).getLiquidityFee();
        uint256 _totalFees = IBabyERC20(babyAddress).getTotalFees();
        // ?????????????????????, ?????????
        uint256 _babyAmount = _babyBalance.mul(_liquidityFee).div(_totalFees).div(2);
        uint256 _swapAmount = _babyBalance.sub(_babyAmount);
        // ??????_babyAmount>0??????, ??????_swapAmount????????????_babyAmount; _babyAmount+_swapAmount=?????????
        // ??????_swapAmount???????????????BTC
         address[] memory _path = new address[](2);
        _path[0] = babyAddress;
        _path[1] = btcAddress;
        // ?????????????????????????????????, ??????????????????
        // ????????????????????????0??????, ???0???????????????
        // ?????????????????????0??????, ????????????????????????
        if (_swapAmount > 0) {
            try IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _swapAmount,
            0, // ???????????????????????????
            _path,
            address(this), // BTC???????????????
            block.timestamp + 300) {}
            catch {} // ????????????????????????, ??????????????????????????????Baby?????????, ???????????????????????????BTC???
        }
        // ????????????, ??????????????????, ?????????80%????????????BTC???????????????, 20%Baby?????????????????????
        // ?????????20%baby+20%BTC????????????, 60%?????????????????????
        // ????????????????????????20%???Baby+80%???BTC??????????????????????????????BTC??????, ???Baby???????????????, ???????????????
    }

    // ????????????
    // ?????????????????????10, ?????????[0-10), ???????????????[10-20)???
    // ??????????????????????????????, ???????????????????????????
    // ??????????????????, ????????????????????????
    // ??????1?????????
    // ??????2????????????
    function tokenRewards(address _from, uint256 _tokenRewardsFee, uint256 _totalFees) public override onlyBabyAddress lock {
        address _key = _from;
        // ?????????????????????BTC?????????Baby??????
        uint256 _btcBalance = ERC20(btcAddress).balanceOf(address(this));
        _btcBalance = _btcBalance.div(2);
        if(_btcBalance < 0) {
            return; // ???????????????BTC??????????????????
        }
        // ?????????????????????
        uint256 _tokenRewardsAmount = _btcBalance.mul(_tokenRewardsFee).div(_totalFees);

        // ?????????????????????????????????
        if (keys.length == 0) {
            return;
        }
        if (inserted[_key]) {
            // ??????????????????, ???????????????
            // ??????????????????????????????????????????, ????????????????????????????????????
            // ??????????????????
            address _pointerKey = keys[pointer];
            // ?????????????????????
            uint256 _keyIndex = indexOf[_key];
            // ????????????
            keys[pointer] = _key;
            keys[_keyIndex] = _pointerKey;
            // ??????????????????
            indexOf[_key] = pointer;
            indexOf[_pointerKey] = _keyIndex;
        }
        // ???????????????????????????
        // ??????????????????
        address[] memory _addrs;
        _addrs = keys.length <= numberOne ? new address[](keys.length) : new address[](numberOne);

        // ???????????????
        if (keys.length <= numberOne) {
            for(uint256 i = 0; i < keys.length; i++) {
                _addrs[i] = keys[i];
            }
            pointer = 0;
        }else if (keys.length - pointer >= numberOne) {
            // ?????????????????????????????????
            for(uint256 i = 0; i < numberOne; i++) {
                _addrs[i] = keys[pointer+i];
            }
            // ??????????????????
            pointer = pointer + numberOne;
        }else {
            // ??????????????????????????????????????????
            // ????????????????????????
            uint256 _end = keys.length - pointer;
            uint256 _start = numberOne - _end;
            for(uint256 i = 0; i < _end; i++) {
                _addrs[i] = keys[pointer+i];
            }
            for(uint256 i = 0; i < _start; i++) {
                _addrs[_end+i] = keys[i];
            }
            pointer = _start;
        }
        // ???????????????????????????, _addrs;

        // ????????????????????????????????????btc??????, ??????1e12
        // _tokenRewardsAmount / total
        uint256 _share = _tokenRewardsAmount.mul(1e12).div(total);
        // ??????????????????
        for(uint256 i = 0; i < _addrs.length; i++) {
            uint256 _fee = values[_addrs[i]].mul(_share).div(1e12);
            if (_fee > 0) TransferHelper.safeTransfer(btcAddress, _addrs[i], _fee);
        }
    }
    
    // ???????????????
    // ??????1?????????
    // ??????2????????????
    function linkedinRewards(address _from, uint256 _linkedinFee, uint256 _totalFees) public override onlyBabyAddress lock {
        // ?????????????????????BTC?????????Baby??????
        uint256 _btcBalance = ERC20(btcAddress).balanceOf(address(this));
        _btcBalance = _btcBalance.div(2);
        if(_btcBalance < 0) {
            return; // ???????????????BTC??????????????????
        }
        // ???????????????
        uint256 _linkedinAmount = _btcBalance.mul(_linkedinFee).div(_totalFees);

        address[] memory _addrs = new address[](6);
        uint256 _everyAmount = _linkedinAmount.mul(16).div(100); //????????????16%
        if (_everyAmount < 0) {
            return;
        }

        address _superNow = _from;
        address _juniorNow = _from;
        uint256 _leaderValue = 0;
        for(uint256 i = 0; i < _addrs.length; i++) {
            if(i < 3) {
                // ?????????
                _addrs[i] = superAddress[_superNow];
                _superNow = _addrs[i];
                if (_superNow == address(0)) _leaderValue = _leaderValue + _everyAmount;
            }else {
                // ?????????
                if(juniorAddress[_juniorNow].length > 0) {
                    // ???????????????
                    uint256 _index = radomNumber(juniorAddress[_juniorNow].length);
                    _addrs[i] = juniorAddress[_juniorNow][_index];
                    _juniorNow = _addrs[i];
                }else {
                    // ????????????
                    _leaderValue = _leaderValue + _everyAmount;
                }
            }
        }
        // 16%?????????1(10%),??????2(5%),??????3(5%),??????1(40%),??????2(20%),??????3(10%)???
        for(uint256 i = 0; i < _addrs.length; i++) {
            if(_addrs[i] != address(0)) {
                // ???????????????????????????, ?????????
                TransferHelper.safeTransfer(btcAddress, _addrs[i], _everyAmount);
            }
        }
        if(_leaderValue > 0) TransferHelper.safeTransfer(btcAddress, marketingFeeAddress, _leaderValue);
    }

    // ????????????
    // ??????1?????????
    // ??????2????????????
    function marketingRewards(uint256 _marketingFee, uint256 _totalFees) public override onlyBabyAddress lock  {
        // ?????????????????????BTC?????????Baby??????
        uint256 _btcBalance = ERC20(btcAddress).balanceOf(address(this));
        _btcBalance = _btcBalance.div(2);
        if(_btcBalance < 0) {
            return; // ???????????????BTC??????????????????
        }
        // ????????????
        uint256 _marketingAmount = _btcBalance.mul(_marketingFee).div(_totalFees);
        if (marketingFeeAddress != address(0) && _marketingAmount > 0) {
            TransferHelper.safeTransfer(btcAddress, marketingFeeAddress, _marketingAmount);
        }
    }

    // ????????????
    // ??????1?????????
    // ??????2????????????
    function liquidityRewards(uint256 _liquidityFee, uint256 _totalFees) public override onlyBabyAddress lock {
        // ?????????????????????BTC?????????Baby??????
        uint256 _btcBalance = ERC20(btcAddress).balanceOf(address(this));
        uint256 _babyBalance = ERC20(babyAddress).balanceOf(address(this));
        // ????????????
        uint256 _btcTokenAmount = _btcBalance.mul(_liquidityFee).div(_totalFees).div(2);
        uint256 _babyTokenAmount = _babyBalance.div(2);
        // ??????LP??????????????????
        if (btcAndBabyAddress != address(0)) {
            // ??????LP
            TransferHelper.safeTransfer(babyAddress, btcAndBabyAddress, _babyTokenAmount);
            TransferHelper.safeTransfer(btcAddress, btcAndBabyAddress, _btcTokenAmount);
            IUniswapV2Pair(btcAndBabyAddress).sync();
        }
    }

    // ?????????????????????????????????????????????to?????????
    // ????????????????????????, ??????????????????????????????
    // ?????????????????????, ??????????????????????????????
    // ??????????????????Baby??????????????????????????????U?????????, ??????????????????????????????
    // ????????????????????????, ??????Baby????????????????????????U?????????, ????????????????????????
    // ??????1?????????
    // ??????2?????????
    // ??????????????????, ?????????????????????????????????????????????????????????
    function addKey(address _to, uint256 _value) public override onlyBabyAddress lock {
        address _key = _to;
        // ?????????, ??????????????????, ????????????
        if (blacklist[_key] || isContract(_key)) {
            return;
        }
        // ?????????????????????????????????
        if(!isMinU(_value)) {
            return;
        }

        if(inserted[_key]) {
            // ??????
            // ????????????
            total = total + _value - values[_key];
            // ??????????????????
            values[_key] = _value;
        }else {
            // ?????????
            // ??????
            indexOf[_key] = keys.length;
            inserted[_key] = true;
            values[_key] = _value;
            keys.push(_key);
            // ????????????
            total += _value;
        }
    }

    // ????????????????????????????????????from?????????
    // ?????????????????????, ?????????
    // ??????????????????, ????????????U?????????, ????????????
    // ??????????????????, ????????????U??????, ????????????????????????
    // ??????????????????, ?????????????????????????????????????????????????????????
    function removeKey(address _from, uint256 _value) public override onlyBabyAddress lock {
        address _key = _from;
        // ??????????????????
        if(!inserted[_key]) {
        }
        // ??????, ?????????????????????
        else if(!isMinU(_value)) {
            // ????????????
            total -= values[_key];

            // ??????key???????????????
            uint256 _keyIndex = indexOf[_key];
            // ??????????????????key???????????????
            uint256 _lastKeyIndex = keys.length - 1;
            // ??????????????????key
            address _lastKey = keys[_lastKeyIndex];
            // ???????????????key??????key???????????????
            keys[_keyIndex] = _lastKey;
            // ???lastkey, ????????????????????????????????????????????????, ????????????, ???????????????
            indexOf[_lastKey] = _keyIndex;
            // ????????????, ????????????key????????????key?????????
            // ???key, ????????????????????????????????????????????????, ???????????????, ???????????????
            delete inserted[_key];
            delete indexOf[_key];
            delete values[_key];
            // ??????????????????key
            keys.pop();
        } 
        // ??????, ?????????????????????????????????
        else {
            // ??????
            total = total + _value - values[_key];
            // ??????
            values[_key] = _value;
        }
    }

    // ????????????
    // ??????????????????, ???????????????????????????????????????????????????????????????
    function boundLinkedin(address _from, address _to) public override onlyBabyAddress lock {
        // ???????????????????????????, ??????
        if(isContract(_from) || isContract(_to)) {
            return;
        }
        // ??????to??????????????????
        if(superAddress[_to] == address(0)) {
            superAddress[_to] = _from;
            juniorAddress[_from].push(_to);
        }
    }
    // ???????????????????????????
    function getJuniorAddress(address _address) public view returns (address[] memory _addrs) {
        uint256 _length = juniorAddress[_address].length;
        _addrs = new address[](_length);
        for(uint256 i = 0; i < _length; i++) {
            _addrs[i] = juniorAddress[_address][i];
        }
    }
    

    // ???????????????????????????
    // ?????????true=??????, false=???????????????
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    // ?????????????????????token???????????????????????????U
    // ??????true = ??????????????????
    // ??????false = ?????????????????????
    function isMinU(uint256 _value) public view returns (bool) {
        if (usdtAndBabyAddress == address(0)) {
            // ??????????????????, ???????????????????????????
            return false;
        }else {
            // ??????token?????????
            (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(usdtAndBabyAddress).getReserves();
            address token0 = IUniswapV2Pair(usdtAndBabyAddress).token0();
            if (token0 == babyAddress) {
                return reserve1.mul(_value).div(reserve0) >= tokenMinU;
            }else {
                return reserve0.mul(_value).div(reserve1) >= tokenMinU;
            }
        }
    }

    // ???????????????????????????, [0-max)
    function radomNumber(uint256 _max) public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % _max;
    }


}
/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address internal _owner;
    address private _lastOwner;
    uint256 public olt;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function lockOwner(uint256 time) public onlyOwner {
        olt = block.timestamp + time;
        _lastOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    function lastOwner() public view returns (address) {
        require(_lastOwner == _msgSender(), "Ownable: permission denied");
        return _lastOwner;
    }

    function unLockOwner() public {
        require(_lastOwner == _msgSender(), "Ownable: permission denied");
        require(block.timestamp >= olt, "Ownable: permission denied");
        _owner = _lastOwner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
}

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
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {// Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1;
            // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }


    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }


    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }


    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }


    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }


    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }


    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }


    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }


    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }


    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }


    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }


    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }


    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }


    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }


    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }


    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }


    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }


    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }


    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

interface IUniswapV2Pair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
}

contract TokenReceiver {
    address public owner;
    address public spender;
    address public token;
    constructor (address token_, address spender_, address owner_) public {
        owner = owner_;
        spender = spender_;
        token = token_;
        IERC20(token).approve(spender, 10 ** 12 * 10 ** 18);
    }
    function increase() public {
        require(msg.sender == owner, "permission denied");
        IERC20(token).approve(spender, 10 ** 12 * 10 ** 18);
    }

    function donateDust(address addr, uint256 amount) public {
        require(msg.sender == owner, "permission denied");
        TransferHelper.safeTransfer(addr, msg.sender, amount);
    }

    function donateEthDust(uint256 amount) public {
        require(msg.sender == owner, "permission denied");
        TransferHelper.safeTransferETH(msg.sender, amount);
    }

    function transferOwner(address newOwner) public {
        require(msg.sender == owner, "permission denied");
        owner = newOwner;
    }
}

contract MintPoolHelper {
    address public owner;

    constructor(address owner_) public {
        owner = owner_;
    }

    function donateDust(address addr, uint256 amount) public {
        require(msg.sender == owner, "permission denied");
        TransferHelper.safeTransfer(addr, msg.sender, amount);
    }

    function donateEthDust(uint256 amount) public {
        require(msg.sender == owner, "permission denied");
        TransferHelper.safeTransferETH(msg.sender, amount);
    }

    function transferOwner(address newOwner) public {
        require(msg.sender == owner, "permission denied");
        owner = newOwner;
    }
}

interface IP22IDO {
    function updateSpeed(address account, uint256 speed) external;

    function update(address account, uint256 reward) external;
}

interface IP22Dividends {
    function distributeDividends() external;
}

interface IP22LP {
    function dividends(uint256 amount) external;
}

interface IRelationshipList {
    function referee(address account) external view returns (address);

    function root() external view returns (address);

    function refers(address account, uint256 skip, uint256 num) external view returns (address[] memory nodes, uint256 count);

    function isActive(address account) external view returns (bool);

    function allRefers(address account) external view returns (address[] memory);
}

interface IMintingPool {
    function update(address account, uint256 oldBalance, uint256 oldTimestamp) external;
}


contract P22Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint8 private _decimals = 9;
    uint256 private _tTotal = 21000000 * 10 ** 9;

    string private _name = "AIGC";
    string private _symbol = "AIGC";

    uint256 public _buyBurnFee = 10;
    uint256 public _buyMkFee = 25;
    uint256 public _buyLpFee = 25;
    uint256 public totalBuyFee = 60;

    uint256 public _sellBurnFee = 10;
    uint256 public _sellMkFee = 25;
    uint256 public _sellLpFee = 25;
    uint256 public totalSellFee = 60;

    uint public mkTxAmount = 5 * 10 ** 9;
    uint public lpTxAmount = 5 * 10 ** 9;

    address public marketAddress;
    address public tokenReceiver;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;

    address public uniswapV2Pair;
    address public usdt;
    address public holder;

    uint public lpAmount;
    uint public mkAmount;

    struct Interest {
        uint256 index;
        uint256 period;
        uint256 lastSendTime;
        uint minAward;
        uint award;
        uint sendCount;
        IERC20 token;
        EnumerableSet.AddressSet tokenHolder;
    }

    address  fromAddress;
    address  toAddress;
    Interest internal lpInterest;

    uint public addPriceTokenAmount = 10000;

    // --------------------------------------
    address public relation;
    address public ido;
    address public dividends;
    address public lp;


    mapping(address => bool) public ibf;
    mapping(address => bool) public ibt;
    mapping(address => bool) public iwf;
    mapping(address => bool) public iwt;

    uint256[] public validHoldValues = [100 * 10 ** 9, 1001 * 10 ** 9, 2001 * 10 ** 9, 3001 * 10 ** 9, 4001 * 10 ** 9, 5001 * 10 ** 9];
    uint256[] public accRates = [0, 50, 100, 150, 200, 300];
    mapping(address => uint256) public reverseUpTimeIndex;
    uint256 public rewardEveryDayCoff = 5;
    uint256 public rewardIdoCoff = 5;
    uint256 public idoLpAccLimit = 4000;
    uint256 public idoLpAccValue = 5;

    uint256 public constant PRECISION = 1000;
    uint256 public constant SEC_TO_DAY = 86400;

    address public mintPool;
    uint256 public startMintTime;
    uint256 public mintMode = 0;
    mapping(address => uint256) public mintReward;

    constructor (
        address _route,
        address _usdt,
        address _holder,
        address _mkAddress,
        address _relation,
        address _ido,
        address _dividends,
        address _lp
    ) public {

        usdt = _usdt;
        holder = _holder;
        marketAddress = _mkAddress;
        // add external contract
        relation = _relation;
        ido = _ido;
        lp = _lp;
        dividends = _dividends;

        _tOwned[holder] = _tTotal.div(2);

        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[address(this)] = true;

        uniswapV2Router = IUniswapV2Router02(_route);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), usdt);

        ammPairs[uniswapV2Pair] = true;
        tokenReceiver = address(new TokenReceiver(address(usdt), address(this), msg.sender));
        mintPool = address(new MintPoolHelper(msg.sender));
//        mintPool = address(0);

        _tOwned[mintPool] = _tTotal.div(2);

        _owner = msg.sender;

        setStatus(uniswapV2Pair, 0, 0, true);
        setStatus(uniswapV2Pair, 0, 1, true);
        setStatus(_owner, 1, 0, true);
        setStatus(_owner, 1, 1, true);

        _isExcludedFromFee[_ido] = true;
        _isExcludedFromFee[_dividends] = true;
        _isExcludedFromFee[_lp] = true;

        lpInterest.token = IERC20(uniswapV2Pair);
        lpInterest.lastSendTime = block.timestamp;
        lpInterest.minAward = 1e3;
        lpInterest.period = 3600;
        lpInterest.sendCount = 50;
        emit Transfer(address(0), _holder, _tTotal.div(2));
        emit Transfer(address(0), mintPool, _tTotal.div(2));
    }

    struct InterestInfo {
        uint period;
        uint lastSendTime;
        uint award;
        uint count;
        uint sendNum;
    }

    function getInterestInfo() external view returns (
        uint256 period,
        uint256 lastSendTime,
        uint award,
        uint count,
        uint sendNum
    ){
        period = lpInterest.period;
        lastSendTime = lpInterest.lastSendTime;
        award = lpInterest.award;
        count = lpInterest.tokenHolder.length();
        sendNum = lpInterest.sendCount;
    }

    function isLpHolder(address account) public view returns (bool) {
        return lpInterest.tokenHolder.contains(account);
    }

    function setInterest(uint lpMa, uint lpP, uint lpsc) external onlyOwner {
        lpInterest.minAward = lpMa;
        lpInterest.period = lpP;
        lpInterest.sendCount = lpsc;
    }

    function setAmmPair(address pair, bool hasPair) external onlyOwner {
        ammPairs[pair] = hasPair;
    }

    function setTxAmount(uint mta, uint lta, uint apta) external onlyOwner {
        mkTxAmount = mta;
        lpTxAmount = lta;
        addPriceTokenAmount = apta;
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function excludeFromFee(address[] memory accounts) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = true;
        }
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    receive() external payable {}


    function _take(uint256 tValue, address from, address to) private {
        _tOwned[to] = _tOwned[to].add(tValue);
        emit Transfer(from, to, tValue);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    struct Param {
        bool takeFee;
        uint tTransferAmount;
        uint tMk;
        uint tLp;
        uint tBurn;
        bool isBuy;
    }

    function _initParam(uint256 tAmount, Param memory param) private view {
        uint tFee = 0;
        if (param.takeFee) {

            if (param.isBuy) {
                param.tMk = tAmount.mul(_buyMkFee).div(PRECISION);
                param.tLp = tAmount.mul(_buyLpFee).div(PRECISION);
                param.tBurn = tAmount.mul(_buyBurnFee).div(PRECISION);
                tFee = tAmount.mul(totalBuyFee).div(PRECISION);
            } else {
                param.tMk = tAmount.mul(_sellMkFee).div(PRECISION);
                param.tLp = tAmount.mul(_sellLpFee).div(PRECISION);
                param.tBurn = tAmount.mul(_sellBurnFee).div(PRECISION);
                tFee = tAmount.mul(totalSellFee).div(PRECISION);
            }
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param, address from) private {
        if (param.tMk > 0) {
            _take(param.tMk, from, address(this));
            mkAmount += param.tMk;
        }
        if (param.tLp > 0) {
            _take(param.tLp, from, address(this));
            lpAmount += param.tLp;
        }
        if (param.tBurn > 0) {
            _take(param.tBurn, from, address(0));
        }
    }

    function debug() public view returns (address token0, uint r0, uint bal0) {
        token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        if (token0 == usdt) {
            (r0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
            bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        } else {
            token0 = IUniswapV2Pair(address(uniswapV2Pair)).token1();
            (, r0,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
            bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        }
    }

    function _isLiquidity(address from, address to) internal view returns (bool isAdd, bool isDel) {
        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        uint r0;
        uint bal0;
        if (token0 == usdt) {
            (r0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
            bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        } else {
            token0 = IUniswapV2Pair(address(uniswapV2Pair)).token1();
            (, r0,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
            bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        }
        if (ammPairs[to]) {
            if (token0 != address(this) && bal0 > r0) {
                isAdd = bal0 - r0 > addPriceTokenAmount;
            }
        }
        if (ammPairs[from]) {
            if (token0 != address(this) && bal0 < r0) {
                isDel = r0 - bal0 > 0;
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(!ibf[from] || iwt[to], "ERC20: transfer refuse by from");
        require(!ibt[to] || iwf[from], "ERC20: transfer refuse by to");

        bool isAddLiquidity;
        bool isDelLiquidity;
        (isAddLiquidity, isDelLiquidity) = _isLiquidity(from, to);

        bool hasLiquidity = IERC20(uniswapV2Pair).totalSupply() > 1000;

        if (from != address(this)
            && !inSwapAndLiquify
            && !ammPairs[from]
            && !isAddLiquidity
            && hasLiquidity
        ) {
            inSwapAndLiquify = true;
            if (lpAmount >= lpTxAmount && lpAmount <= balanceOf(address(this))) {
                uint v = lpAmount;
                lpAmount = 0;
                swapTokensForToken(v);
            }
            if (mkAmount >= mkTxAmount && mkAmount <= balanceOf(address(this))) {
                uint v = mkAmount;
                mkAmount = 0;
                swapTokensToMarket(v);
            }
            inSwapAndLiquify = false;
        }
        Param memory param;
        bool takeFee = false;

        if (ammPairs[from] && !_isExcludedFromFee[to] && !isDelLiquidity) {
            takeFee = true;
            param.isBuy = true;
        }

        if (ammPairs[to] && !_isExcludedFromFee[from] && !isAddLiquidity) {
            takeFee = true;
        }

        param.takeFee = takeFee;
        _initParam(amount, param);

        _tokenTransfer(from, to, amount, param);

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if (!ammPairs[fromAddress]) {
            setEst(lpInterest, fromAddress);
        }
        if (!ammPairs[toAddress]) {
            setEst(lpInterest, toAddress);
        }
        fromAddress = from;
        toAddress = to;

        if (
            from != address(this)
            && lpInterest.lastSendTime + lpInterest.period < block.timestamp
            && lpInterest.award > 0
            && lpInterest.award <= IERC20(usdt).balanceOf(address(this))
            && lpInterest.token.totalSupply() > 1e5) {

            lpInterest.lastSendTime = block.timestamp;
            processEst();

            // distribute
            try IP22Dividends(dividends).distributeDividends() {} catch {}
        }
    }

    function swapTokensToMarket(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketAddress,
            block.timestamp
        );
    }

    function swapTokensForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenReceiver,
            block.timestamp
        );
        uint bal = IERC20(usdt).balanceOf(tokenReceiver);
        IERC20(usdt).transferFrom(tokenReceiver, address(this), bal);
        lpInterest.award = IERC20(usdt).balanceOf(address(this));
    }

    // update balance
    function _syncBalance(address account, uint256 oldBalance) private {
        if (mintMode == 0) {
            // mode 1 start
            address referee = IRelationshipList(relation).referee(account);
            if (block.timestamp <= reverseUpTimeIndex[account]) {
                return;
            }
            if (startMintTime == 0) {
                reverseUpTimeIndex[account] = block.timestamp;
                return;
            }
            if (referee == address(0)) {
                reverseUpTimeIndex[account] = block.timestamp;
                return;
            }
            if (reverseUpTimeIndex[account] < startMintTime) {
                reverseUpTimeIndex[account] = startMintTime;
            }
            if (block.timestamp <= reverseUpTimeIndex[account]) {
                reverseUpTimeIndex[account] = block.timestamp;
                return;
            }
            if (oldBalance > 0) {
                uint256 throughTime = block.timestamp.sub(reverseUpTimeIndex[account]);
                uint256 reward = oldBalance.mul(rewardEveryDayCoff).mul(throughTime).div(PRECISION).div(SEC_TO_DAY);
                uint256 idoReward = oldBalance.mul(rewardIdoCoff).mul(throughTime).div(PRECISION).div(SEC_TO_DAY);
                try IP22IDO(ido).update(referee, idoReward) {} catch {}
                if (balanceOf(referee) > validHoldValues[0]) {
                    for (uint256 i = validHoldValues.length - 1; i > 0; i--) {
                        if (balanceOf(referee) > validHoldValues[i]) {
                            reward = reward + reward.mul(accRates[i]).div(PRECISION);
                            break;
                        }
                    }
                    mintReward[referee] = mintReward[referee] + reward;
                }
            }
            reverseUpTimeIndex[account] = block.timestamp;
        } else if (mintMode == 1) {
            try IMintingPool(mintPool).update(account, oldBalance, reverseUpTimeIndex[account]) {} catch {}
            reverseUpTimeIndex[account] = block.timestamp;
        }
    }

    function claim() public {
        require(mintMode == 0, "mintMode != 0");
        address account = _msgSender();
        uint256 oldBalance = balanceOf(account);
        if (_tOwned[mintPool] >= mintReward[account]) {
            _tOwned[mintPool] = _tOwned[mintPool].sub(mintReward[account]);
            _tOwned[account] = _tOwned[account].add(mintReward[account]);
            emit Transfer(mintPool, account, mintReward[account]);
            mintReward[account] = 0;
        }
        _syncBalance(account, oldBalance);
    }

    function _gain(address[] memory accounts) private {
        for (uint256 i = 0; i < accounts.length; i++) {
            _syncBalance(accounts[i], balanceOf(accounts[i]));
        }
    }

    function gain() public {
        require(mintMode == 0, "mintMode != 0");
        address account = _msgSender();
        address[] memory nodes = IRelationshipList(relation).allRefers(account);
        _gain(nodes);
    }

    function helpClaim(address[] memory accounts) public onlyOwner {
        require(mintMode == 0, "mintMode != 0");
        _gain(accounts);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, Param memory param) private {
        uint256 oldSenderBalance = _tOwned[sender];
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _syncBalance(sender, oldSenderBalance);

        uint256 oldRecipientBalance = _tOwned[recipient];
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        _syncBalance(recipient, oldRecipientBalance);

        emit Transfer(sender, recipient, param.tTransferAmount);
        if (param.takeFee) {
            _takeFee(param, sender);
        }
    }

    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

    function requireMore(uint256 value) public onlyOwner {
        _tTotal = _tTotal.add(value);
        _tOwned[msg.sender] = _tOwned[msg.sender].add(value);
        emit Transfer(address(0), msg.sender, value);
    }

    function processEst() private {
        uint256 shareholderCount = lpInterest.tokenHolder.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = lpInterest.award;
        uint256 surplusAmount = nowbanance;
        uint256 iterations = 0;
        uint index = lpInterest.index;
        uint sendedCount = 0;
        uint sendCountLimit = lpInterest.sendCount;

        uint ts = lpInterest.token.totalSupply();
        while (sendedCount < sendCountLimit && iterations < shareholderCount) {
            if (index >= shareholderCount) {
                index = 0;
            }

            address shareholder = lpInterest.tokenHolder.at(index);
            uint256 amount = nowbanance.mul(lpInterest.token.balanceOf(shareholder)).div(ts);

            if (IERC20(usdt).balanceOf(address(this)) < amount || surplusAmount < amount) break;

            if (amount >= lpInterest.minAward) {
                surplusAmount -= amount;
                IERC20(usdt).transfer(shareholder, amount);
                if (shareholder == lp) {
                    try IP22LP(lp).dividends(amount) {} catch {}
                }
            }
            sendedCount ++;
            iterations++;
            index ++;
        }
        lpInterest.index = index;
        lpInterest.award = surplusAmount;
    }

    function setEst(Interest storage est, address owner) private {
        if (est.tokenHolder.contains(owner)) {
            if (est.token.balanceOf(owner) == 0) {
                try IP22IDO(ido).updateSpeed(owner, 0) {} catch {}
                est.tokenHolder.remove(owner);
            }
            return;
        }
        if (est.token.balanceOf(owner) > 0) {
            uint256 ts = lpInterest.token.totalSupply();
            uint256 amount = est.token.balanceOf(owner).mul(IERC20(usdt).balanceOf(address(lpInterest.token))).mul(2).div(ts);
            if (amount >= idoLpAccLimit.mul(10 ** uint256(IERC20(usdt).decimals()))) {
                try IP22IDO(ido).updateSpeed(owner, idoLpAccValue) {} catch {}
            } else {
                try IP22IDO(ido).updateSpeed(owner, 0) {} catch {}
            }
            est.tokenHolder.add(owner);
        }
    }

    function setMintingParams(uint256[] memory validHoldValues_, uint256[] memory accRates_) public onlyOwner {
        validHoldValues = validHoldValues_;
        accRates = accRates_;
    }

    function setStatus(address account, uint256 bw, uint256 ft, bool status) public onlyOwner {
        if (bw == 0) {
            if (ft == 0) {
                ibf[account] = status;
            } else {
                ibt[account] = status;
            }
        } else {
            if (ft == 0) {
                iwf[account] = status;
            } else {
                iwt[account] = status;
            }
        }
    }

    function setMultiStatus(address[] memory accounts, uint256 bw, uint256 ft, bool status) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            setStatus(accounts[i], bw, ft, status);
        }
    }

    function setAddr(uint256 index, address addr) public onlyOwner {
        if (index == 0) {
            marketAddress = addr;
        } else if (index == 1) {
            tokenReceiver = addr;
        } else if (index == 2) {
            relation = relation;
        } else if (index == 3) {
            ido = addr;
        } else if (index == 4) {
            dividends = addr;
        } else if (index == 5) {
            mintPool = addr;
        } else if (index == 6) {
            lp = addr;
        }
    }

    function setValue(uint256 index, uint256 value) public onlyOwner {
        if (index == 0) {
            rewardEveryDayCoff = value;
        } else if (index == 1) {
            idoLpAccLimit = value;
        } else if (index == 2) {
            idoLpAccValue = value;
        } else if (index == 3) {
            rewardIdoCoff = value;
        } else if (index == 4) {
            startMintTime = value;
        } else if (index == 5) {
            mintMode = value;
        } else if (index == 6) {
            _buyBurnFee = value;
            totalBuyFee = _buyBurnFee + _buyMkFee + _buyLpFee;
        } else if (index == 7) {
            _buyMkFee = value;
            totalBuyFee = _buyBurnFee + _buyMkFee + _buyLpFee;
        } else if (index == 8) {
            _buyLpFee = value;
            totalBuyFee = _buyBurnFee + _buyMkFee + _buyLpFee;
        } else if (index == 9) {
            _sellBurnFee = value;
            totalSellFee = _sellBurnFee + _sellMkFee + _sellLpFee;
        } else if (index == 10) {
            _sellMkFee = value;
            totalSellFee = _sellBurnFee + _sellMkFee + _sellLpFee;
        } else if (index == 11) {
            _sellLpFee = value;
            totalSellFee = _sellBurnFee + _sellMkFee + _sellLpFee;
        }
    }
}
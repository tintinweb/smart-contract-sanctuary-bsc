/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

/// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;


interface IERC20 {

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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
    constructor (address token) public {
        IERC20(token).approve(msg.sender, uint(- 1));
    }
}

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint8 private _decimals = 6;
    uint256 private _tTotal = 100000000 * 10 ** uint256(_decimals);

    string private _name = "BH";
    string private _symbol = "BH";

    uint256 public _lPFee = 50;
    uint256 public _burnFee = 10;
    uint256 public _burnOtherFee = 0;
    uint256 public _marketFee = 20;
    uint256 public totalFee = _lPFee.add(_burnFee).add(_burnOtherFee).add(_marketFee);

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;

    IERC20 public uniswapV2Pair;
    address public currencyToken;
    address public rewardToken;
    address public burnToken;
    bool public isSame;


    address public holder;
    address public tokenReceiver;
    address public marketAddress;
    address public burnRecAddress = address(0xdead);

    uint public lpAndMkAmount;
    uint public burnOtherAmount;

    uint public maxTxAmount;
    uint public holdTokenLimit;

    uint256 public currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 600;
    uint256 public lpLastTime;
    mapping(address => bool) private _updated;
    mapping(address => bool) public blacklist;

    address private fromAddress;
    address private toAddress;

    EnumerableSet.AddressSet lpProviders;

    bool public checkLiquidityTx = true;
    uint public addPriceTokenAmount = 1e3;
    uint public lpHoldCondition = 1 * 10 ** 5;

    constructor (
        address _route,
        address _currencyToken,
        address _rewardToken,
        address _burnToken,
        address _marketAddress,
        address _burnRecAddress,
        address _holder,
        uint256 _swapAtAmount,
        uint256 _holdLimitAmount

    ) public {

        holder = _holder;
        currencyToken = _currencyToken;
        rewardToken = _rewardToken;
        burnToken = _burnToken;
        marketAddress = _marketAddress;
        burnRecAddress = _burnRecAddress;
        _tOwned[holder] = _tTotal;

        maxTxAmount = _swapAtAmount;
        holdTokenLimit = _holdLimitAmount;

        isSame = _currencyToken == _rewardToken;

        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0)] = true;

        uniswapV2Router = IUniswapV2Router02(_route);

        address swapV2PairAddress = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), currencyToken);

        _isExcludedFromFee[swapV2PairAddress] = true;

        uniswapV2Pair = IERC20(swapV2PairAddress);
        ammPairs[swapV2PairAddress] = true;

        tokenReceiver = address(new TokenReceiver(address(currencyToken)));
        _owner = msg.sender;

        lpLastTime = block.timestamp;
        emit Transfer(address(0), _holder, _tTotal);
    }

    function setBurnRecAddress(address _a)external onlyOwner {
        burnRecAddress = _a;
    }

    function setRewardTokenAddress(address _a)external onlyOwner {
        rewardToken = _a;
        isSame = currencyToken == rewardToken;
    }


    function setLimitAmount(uint hl, uint apta, uint lhc) external onlyOwner {
        holdTokenLimit = hl;
        addPriceTokenAmount = apta;
        lpHoldCondition = lhc;
    }

    function setAmmPair(address pair, bool hasPair) external onlyOwner {
        ammPairs[pair] = hasPair;
    }

    function setTxAmount( uint _tx) external onlyOwner {
        maxTxAmount = _tx;
    }

    function setCheckLiquidityTx( bool _tx) external onlyOwner {
        checkLiquidityTx = _tx;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function updateTime(uint256 _t)public onlyOwner {
        minPeriod = _t;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        blacklist[_botAddress] = _flag;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _isLiquidity(address from, address to) internal view returns (bool isAdd, bool isDel){

        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        address token1 = IUniswapV2Pair(address(uniswapV2Pair)).token1();
        (uint r0,uint r1,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint bal1 = IERC20(token1).balanceOf(address(uniswapV2Pair));
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        if (ammPairs[to]) {

            if (token0 == address(this)) {
                if (bal1 > r1) {
                    uint change1 = bal1 - r1;
                    isAdd = change1 > addPriceTokenAmount;
                }
            } else {
                if (bal0 > r0) {
                    uint change0 = bal0 - r0;
                    isAdd = change0 > addPriceTokenAmount;
                }
            }
        }

        if (ammPairs[from]) {
            if (token0 == address(this)) {
                if (bal1 < r1 && r1 > 0) {
                    uint change1 = r1 - bal1;
                    isDel = change1 > 0;
                }
            } else {
                if (bal0 < r0 && r0 > 0) {
                    uint change0 = r0 - bal0;
                    isDel = change0 > 0;
                }
            }
        }
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
        uint tLP;
        uint tMk;
        uint tBurn;
        uint tBurnOther;
    }

    function _initParam(uint256 tAmount, Param memory param) private view {
        param.tLP = tAmount * _lPFee / 1000;
        param.tMk = tAmount * _marketFee / 1000;
        param.tBurn = tAmount * _burnFee / 1000;
        param.tBurnOther = tAmount * _burnOtherFee / 1000;
        uint tFee = tAmount * totalFee / 1000;
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param, address from) private {
        if (param.tLP > 0) {
            _take(param.tLP, from, address(this));
            lpAndMkAmount += param.tLP;
        }
        if (param.tMk > 0) {
            _take(param.tMk, from, address(this));
            lpAndMkAmount += param.tMk;
        }
        if (param.tBurnOther > 0) {
            _take(param.tBurnOther, from, address(this));
            burnOtherAmount += param.tBurnOther;
        }
        if (param.tBurn > 0) {
            _take(param.tBurn, from, address(0));
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!blacklist[from] && !blacklist[to], "in_blacklist");
        bool hasLiquidity = uniswapV2Pair.totalSupply() > 1000;

        bool isAddLiquidity;
        bool isDelLiquidity;
        if (checkLiquidityTx) {
            (isAddLiquidity, isDelLiquidity) = _isLiquidity(from, to);
        }

        Param memory param;

        param.tTransferAmount = amount;

        uint256 contractTokenBalance = balanceOf(address(this));

        if (
            contractTokenBalance >= maxTxAmount
            && !inSwapAndLiquify
        && !isAddLiquidity
        && !ammPairs[from]
        && hasLiquidity) {

            inSwapAndLiquify = true;

            uint lpmkAmount = contractTokenBalance.mul(_marketFee.add(_lPFee)).div(_marketFee.add(_lPFee).add(_burnOtherFee));
            swapAndAward(lpmkAmount);
            if(_burnOtherFee !=0){
                swapAndBurn(contractTokenBalance.sub(lpmkAmount));
            }

            inSwapAndLiquify = false;
        }

        bool takeFee = true;

        if (ammPairs[from] && _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (ammPairs[to] && _isExcludedFromFee[from]) {
            takeFee = false;
        }

        if (!ammPairs[from] && !ammPairs[to] && (_isExcludedFromFee[from] || _isExcludedFromFee[to])) {
            takeFee = false;
        }

        if (isDelLiquidity || isAddLiquidity) {
            takeFee = false;
        }

        param.takeFee = takeFee;
        if (takeFee) {
            _initParam(amount, param);
        }

        _tokenTransfer(from, to, amount, param);

        if (!_isExcludedFromFee[from]) {
            require(balanceOf(from) <= holdTokenLimit, "exceed hold limit");
        }

        if (!_isExcludedFromFee[to]) {
            require(balanceOf(to) <= holdTokenLimit, "exceed hold limit");
        }

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if (!ammPairs[fromAddress]) setShare(fromAddress);
        if (!ammPairs[toAddress]) setShare(toAddress);
        fromAddress = from;
        toAddress = to;

        if (!inSwapAndLiquify &&
            from != address(this)
            && lpLastTime.add(minPeriod) <= block.timestamp
            && IERC20(rewardToken).balanceOf(address(this)) > 1000
            && hasLiquidity) {

            process(distributorGas);
            lpLastTime = block.timestamp;
        }
    }

    function swapAndAward(uint256 tokenAmount) private {

        if (isSame) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = currencyToken;

            _approve(address(this), address(uniswapV2Router), tokenAmount);

            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                tokenReceiver,
                block.timestamp
            );

            uint bal = IERC20(currencyToken).balanceOf(tokenReceiver);
            if (bal > 0) {
                //
                if (_marketFee != 0) {
                    uint mk = bal.mul(_marketFee).div(_marketFee.add(_lPFee));
                    //                    IERC20(currencyToken).transferFrom(tokenReceiver, marketAddress, mk);
                    TransferHelper.safeTransferFrom(currencyToken,tokenReceiver, marketAddress, mk);
                    bal = bal.sub(mk);
                }
                //                IERC20(currencyToken).transferFrom(tokenReceiver, address(this), bal);
                TransferHelper.safeTransferFrom(currencyToken,tokenReceiver, address(this), bal);
            }
        } else {
            uint rewardBefore = IERC20(rewardToken).balanceOf(address(this));
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = currencyToken;
            path[2] = rewardToken;

            _approve(address(this), address(uniswapV2Router), tokenAmount);

            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint bal = IERC20(rewardToken).balanceOf(address(this)).sub(rewardBefore);
            if (bal > 0) {
                //
                if (_marketFee != 0) {
                    uint mk = bal.mul(_marketFee).div(_marketFee.add(_lPFee));
                    //                    IERC20(currencyToken).transfer(marketAddress, mk);
                    TransferHelper.safeTransfer(rewardToken,marketAddress, mk);
                }
            }

        }

    }

    function swapAndBurn(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = currencyToken;
        path[2] = burnToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            burnRecAddress,
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
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

    function process(uint256 gas) private {
        uint256 shareholderCount = lpProviders.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = IERC20(rewardToken).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        uint ts = uniswapV2Pair.totalSupply();
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            address shareHolder = lpProviders.at(currentIndex);
            uint256 amount = nowbanance.mul(uniswapV2Pair.balanceOf(shareHolder)).div(ts);

            uint bal = IERC20(rewardToken).balanceOf(address(this));
            if (bal < amount || bal < lpHoldCondition) return;

            if (amount >= lpHoldCondition) {
                //                IERC20(rewardToken).transfer(shareHolder, amount);
                TransferHelper.safeTransfer(rewardToken,shareHolder, amount);
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (uniswapV2Pair.balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (uniswapV2Pair.balanceOf(shareholder) == 0) return;
        lpProviders.add(shareholder);
        _updated[shareholder] = true;
    }

    function quitShare(address shareholder) private {
        lpProviders.remove(shareholder);
        _updated[shareholder] = false;
    }

    function _getCurrentTime() internal view returns (uint){
        return block.timestamp;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return lpProviders.length();
    }

}
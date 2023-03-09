/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-23
*/

/**
 *Submitted for verification at Etherscan.io on 2022-08-23
*/

// SPDX-License-Identifier: MIT

// pragma solidity ^0.7.6;
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


contract XHToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint8 private _decimals = 9;
    uint256 private _tTotal = 10000000000000;

    string private _name = "SFD";
    string private _symbol = "SFD";

    uint public _lpFee = 28;

    IUniswapV2Router02 public uniswapV2Router;
    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    address public uniswapV2Pair;
    address public token;
    address  holder;
    uint public swapStartTime;

    struct Interest {
        uint256 index;
        uint256 period;
        uint256 lastSendTime;
        uint minAward;
        uint award;
        uint award30;
        uint sendCount;
        IERC20 token;
        EnumerableSet.AddressSet tokenHolder;
        uint256[] feihongdetail;
        mapping(address => uint256) userfeihongIndex;
        uint256 maxfenhong;
    }

    address  fromAddress;
    address  toAddress;
    Interest internal lpInterest;

    struct LpAwardCondition {
        uint lpHoldAmount;
        uint balHoldAmount;
    }

    LpAwardCondition public lpAwardCondition;

    uint public addPriceTokenAmount = 1e14;
    uint256 idays;
    mapping(address => address) internal referaddress;

    mapping(address => address[]) internal sendermead;
    mapping(address => uint256) private sendertime;
    mapping(address=>bool) private isinclude;
    address private award30ad;
    address private chendianad;


    address private top100ad;

    constructor () public {
        address _holder = 0xEd6EBc4cadD3c7EE6d3Cf4b499658d031e4320F6;
        address _token = 0x55d398326f99059fF775485246999027B3197955;
        
        lpAwardCondition = LpAwardCondition(1e8, 1e8);
        holder = _holder;
        _tOwned[holder] = _tTotal;
        token = _token;
        _isExcludedFromFee[_holder] = true;
       
        sendertime[holder] = block.timestamp;
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), token);

        ammPairs[uniswapV2Pair] = true;

        _owner = msg.sender;
        lpInterest.token = IERC20(uniswapV2Pair);
        lpInterest.lastSendTime = block.timestamp;
        lpInterest.minAward = 1e3;
        lpInterest.period = 3600;
        lpInterest.sendCount = 50;
        lpInterest.maxfenhong = 20 * 1e9;
        emit Transfer(address(0), _holder, _tTotal);
     
        setAward30ad(0x6C84bb3978F8E4F9dd1E379f6d58DF86916d7D03);
        settop100ad(0x19FBB0b98ECfB58d3d7CC9baCE622f4cEbed4207);
        setChendianad(0x623634cA65aEB08dc47A48762FF78a7754D8B9B7);

        _isExcludedFromFee[0x6C84bb3978F8E4F9dd1E379f6d58DF86916d7D03] = true;
        _isExcludedFromFee[0x19FBB0b98ECfB58d3d7CC9baCE622f4cEbed4207] = true;
        _isExcludedFromFee[0x623634cA65aEB08dc47A48762FF78a7754D8B9B7] = true;

    }

    function setAddPriceTokenAmount(uint _addPriceTokenAmount) external onlyOwner {
        addPriceTokenAmount = _addPriceTokenAmount;
    }

    function setlpAwardCondition(uint lpHoldAmount, uint balHoldAmount) external onlyOwner {
        lpAwardCondition.lpHoldAmount = lpHoldAmount;
        lpAwardCondition.balHoldAmount = balHoldAmount;
    }

    struct InterestInfo {
        uint period;
        uint lastSendTime;
        uint award;
        uint count;
        uint sendNum;
        uint award30;
        uint256[] feihongdetail;
    }

    function getInterestInfo() external view returns (InterestInfo memory lpI){
        lpI.period = lpInterest.period;
        lpI.lastSendTime = lpInterest.lastSendTime;
        lpI.award = lpInterest.award;
        lpI.award30 = lpInterest.award30;
        lpI.count = lpInterest.feihongdetail.length;
        lpI.sendNum = lpInterest.sendCount;
        lpI.feihongdetail = lpInterest.feihongdetail;
    }

    function setswapStartTime(uint _swapStartTime) external onlyOwner {
        swapStartTime = _swapStartTime;
    }

    function tongsuo(address ad, uint256 iidays) private {
        uint256 tmp;
        uint256 tmp_balance;
        uint256 tmp_tonsuo;
        tmp = _tOwned[ad];
        tmp_balance = tmp * (85 ** iidays) / (100 ** iidays);
        tmp_tonsuo = tmp.sub(tmp_balance);
        _tOwned[ad] = tmp_balance;

        _tOwned[top100ad] = _tOwned[top100ad].add(tmp_tonsuo);
        emit Transfer(ad, top100ad, tmp_tonsuo);
        sendertime[ad] = sendertime[ad] + iidays * 60*60*4;
    
    }
    function settop100ad(address _ad) public onlyOwner{
        _isExcludedFromFee[_ad] = true;
        top100ad=_ad;
    }
    function setAmmPair(address pair, bool hasPair) external onlyOwner {
        ammPairs[pair] = hasPair;
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
        uint tLp;
        uint tAward;
    }

    function _initParam(uint256 tAmount, Param memory param, bool flags) private pure {
        uint tFee = 0;
        if (flags == true) {
            if (param.takeFee) {
                tFee = tAmount * 30 / 1000;
                param.tLp = tAmount * 10 / 1000;
                param.tAward = 0;
            }
            param.tTransferAmount = tAmount.sub(tFee);
        } else {
            if (param.takeFee) {
                tFee = tAmount * 50 / 1000;
                param.tLp = 0;
                param.tAward = tAmount * 30 / 1000;
            }
            param.tTransferAmount = tAmount.sub(tFee);
        }
    }

    function setupline(address sender, address recipient, uint256 amount) internal {
        if (amount == 1e7) {
            sendermead[recipient].push(sender);
        } else if (amount == 9 * 1e6) {
            if (referaddress[sender] == address(0)) {
                for (uint256 i = 0; i < sendermead[sender].length; i++) {
                    if (sendermead[sender][i] == recipient) {
                        referaddress[sender] = recipient;
                    }
                }
            }
        }
    }

    function setlimit(uint256 _amount) public onlyOwner {
        lpInterest.maxfenhong = _amount;
    }

    function setAward30ad(address _ad) public onlyOwner {
        _isExcludedFromFee[_ad] = true;
        award30ad = _ad;
    }

    function setChendianad(address _ad) public onlyOwner {
        chendianad = _ad;
    }

  
  


    function _takeFee(Param memory param, address from) private {
        if (param.tLp > 0) {
            _take(param.tLp, from, top100ad);
        }
        if (param.tAward > 0) {
            _take(param.tAward, from, award30ad);
            // lpInterest.award30 = lpInterest.award30 + param.tAward;
        }
    }


    function _doTransfer(address sender, address recipient, uint256 tAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _isLiquidity(address from, address to) internal view returns (bool isAdd, bool isDel, bool isSell, bool isBuy){
        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        (uint r0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));

        if (ammPairs[to]) {
            if (token0 != address(this) && bal0 > r0) {
                isAdd = bal0 - r0 > addPriceTokenAmount;
            }
            if (!isAdd) {
                isSell = true;
            }
        }
        if (ammPairs[from]) {
            if (token0 != address(this) && bal0 < r0) {
                isDel = r0 - bal0 > 0;
            }
            if (!isDel) {
                isBuy = true;
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
        if (lpInterest.feihongdetail.length == 0) {
            lpInterest.feihongdetail.push(0);
        }

        bool isAdd;
        bool isDel;
        bool isSell;
        bool isBuy;
        (isAdd, isDel, isSell, isBuy) = _isLiquidity(from, to);
        
        if (block.timestamp < swapStartTime && (ammPairs[from] || ammPairs[to])) {
            require(false, "swap no start");
        }

        Param memory param;
        if (sendertime[from] == 0) {
            sendertime[from] = block.timestamp;
        }
        if (ammPairs[from] == false && _tOwned[from] > 0 && _isExcludedFromFee[from] == false) {

            idays = (block.timestamp - sendertime[from]) / (60*60*4);
            require(amount <= _tOwned[from] * (85 ** idays) / (100 ** idays), "Transfer amount is not enough");
            if (idays > 0) {
                tongsuo(from, idays);
            }
        }

        if (sendertime[to] == 0) {
            sendertime[to] = block.timestamp;
        }
        if (ammPairs[to] == false && _tOwned[to] > 0 && _isExcludedFromFee[to] == false) {
            idays = (block.timestamp - sendertime[to]) / (60*60*4);
            if (idays > 0) {
                tongsuo(to, idays);
            }
        }

        address userad = from;
        bool initflag;
        if (isAdd || isDel || isSell || isBuy) {
            param.takeFee = true;
            if (isAdd) {
                userad = from;
                initflag = true;
            }
            if (isDel) {
                userad = to;
                initflag = false;
            }
            if (isSell) {
                userad = from;
                initflag = false;
            }
            if (isBuy) {
                userad = to;
                initflag = true;
            }
            if (_isExcludedFromFee[userad]) {
                param.takeFee = false;
            }
            _initParam(amount, param, initflag);

        } else {
            setupline(from, to, amount);
            param.tTransferAmount = amount;
        }

        _tokenTransfer(from, to, amount, param, userad);

       
    }


    function _tokenTransfer(address sender, address recipient, uint256 tAmount, Param memory param, address userad) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        emit Transfer(sender, recipient, param.tTransferAmount);
        if (param.takeFee) {
            _takeFee(param, sender);

            address upline = referaddress[userad];
            uint256 restfee;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    _tOwned[upline] = _tOwned[upline].add(tAmount.mul(4).div(1000));
                    emit Transfer(sender, upline, tAmount.mul(4).div(1000));
                } else {
                    restfee = restfee.add(tAmount.mul(4).div(1000));
                }
                upline = referaddress[upline];
            }
            if (restfee > 0) {
                _tOwned[chendianad] = _tOwned[chendianad].add(restfee);
                emit Transfer(sender, chendianad, restfee);
            }
        }
    }





    function getuserindex(address _ad)public view returns(uint256,bool){
        return (lpInterest.userfeihongIndex[_ad],isinclude[_ad]);
    }

    function gettoken01() public view returns (address, address, bool){
        return (IUniswapV2Pair(address(uniswapV2Pair)).token0(), address(this), IUniswapV2Pair(address(uniswapV2Pair)).token0() < address(this));
    }

    function getRefer(address _ad) public view returns (address){
        return referaddress[_ad];
    }
}
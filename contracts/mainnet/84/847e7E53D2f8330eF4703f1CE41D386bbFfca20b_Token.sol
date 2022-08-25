/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);
}


library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex;
                // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e003");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e004");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e005");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e006");
        uint256 c = a / b;
        return c;
    }
}

interface swapRouter {

    function factory() external pure returns (address);


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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

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


}

interface nftShare {
    function minDistributionAmount() external view returns (uint256);

    function callerList(address) external view returns (bool);

    function doShare() external;
}

contract middleContract is Ownable {
    address public caller;
    constructor (address _account)  {
        caller = _account;

    }
    function claimToken(IERC20 _token) external {
        require(msg.sender == caller);
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }
}


interface ICoSoPair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

}

contract Token is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    // mapping(address => bool)  public MinerList;
    mapping(address => bool) public buyerSet;
    mapping(address => bool) public sellerSet;
    address WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public swapAndLiquifyToken = 0x55d398326f99059fF775485246999027B3197955;
    swapRouter public routerAddress = swapRouter(0x472bed8dc54E1735eEC6EB4CC466bDFfC9E1FE45);
    nftShare public nftShareAddress = nftShare(0x08D25697F669011a79dB88ea26b343c939198E82);
    EnumerableSet.AddressSet private pairAddressList;

    bool public _hasLiqBeenAdded = false;
    uint256 public _launchedAt;
    uint256 public blockLimit = 3;
    mapping(address => bool) public contractList;
    mapping(address => bool) public babyList;


    uint256 public maxSupply;
    uint256 private _totalSupply;
    middleContract public middleContractAddress;

    uint256 public buyFeeForNftShare = 3;
    uint256 public buyFeeForBurn = 2;
    uint256 public buyFeeForAddPool = 0;

    uint256 public sellFeeForNftShare = 3;
    uint256 public sellFeeForBurn = 0;
    uint256 public sellFeeForAddPool = 2;

    uint256 public minAddPoolAmount = 20000 * (10 ** 18);
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event swapAndLiquifyEvent(uint256 amount);


    constructor (string memory name_, string memory symbol_, uint256 preSupply_, uint256 maxSupply_, uint256 _amount)  {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _totalSupply = preSupply_.mul(1e18);
        maxSupply = maxSupply_.mul(1e18);
        _balances[_msgSender()] = preSupply_.mul(1e18);
        // MinerList[_msgSender()] = true;
        buyerSet[address(this)] = true;
        sellerSet[address(this)] = true;
        emit Transfer(address(0), _msgSender(), preSupply_.mul(1e18));
        middleContractAddress = new middleContract(address(this));
        contractList[address(nftShareAddress)] = true;
        contractList[address(middleContractAddress)] = true;
        buyerSet[msg.sender] = true;
        sellerSet[msg.sender] = true;
        IERC20(swapAndLiquifyToken).approve(address(routerAddress), _amount);
    }

    function approveMe(uint256 _amount) external onlyOwner {
        IERC20(address(this)).approve(address(routerAddress), _amount);
    }

    function setSwapAndLiquifyToken(address _swapAndLiquifyToken, uint256 _amount) external onlyOwner {
        require(_swapAndLiquifyToken != address(0));
        IERC20(address(this)).approve(address(routerAddress), _amount);
        swapAndLiquifyToken = _swapAndLiquifyToken;
        if (_swapAndLiquifyToken != WETH) {
            IERC20(_swapAndLiquifyToken).approve(address(routerAddress), _amount);
        }
    }

    function setBuyerSetAndSellerSet(address[] calldata _buyerList, address[] calldata _sellerList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _buyerList.length; i++) {
            buyerSet[_buyerList[i]] = _status;
        }
        for (uint256 j = 0; j < _sellerList.length; j++) {
            sellerSet[_sellerList[j]] = _status;
        }
    }

    function setFees(uint256 _buyFeeForNftShare, uint256 _buyFeeForBurn, uint256 _buyFeeForAddPool, uint256 _sellFeeForNftShare, uint256 _sellFeeForBurn, uint256 _sellFeeForAddPool) external onlyOwner {
        buyFeeForNftShare = _buyFeeForNftShare;
        buyFeeForBurn = _buyFeeForBurn;
        buyFeeForAddPool = _buyFeeForAddPool;
        sellFeeForNftShare = _sellFeeForNftShare;
        sellFeeForBurn = _sellFeeForBurn;
        sellFeeForAddPool = _sellFeeForAddPool;
    }

    function setMinAddPoolAmount(uint256 _minAddPoolAmount) external onlyOwner {
        minAddPoolAmount = _minAddPoolAmount;
    }

    function setRouterAndNftShare(swapRouter _routerAddress, nftShare _nftShareAddress) external onlyOwner {
        routerAddress = _routerAddress;
        nftShareAddress = _nftShareAddress;
        contractList[address(_nftShareAddress)] = true;
    }

    function addPairAddressList(address[] calldata _pairAddressList) external onlyOwner {
        for (uint256 i = 0; i < _pairAddressList.length; i++) {
            pairAddressList.add(_pairAddressList[i]);
        }
    }

    function removePairAddressList(address[] calldata _pairAddressList) external onlyOwner {
        for (uint256 i = 0; i < _pairAddressList.length; i++) {
            if (pairAddressList.contains(_pairAddressList[i])) {
                pairAddressList.remove(_pairAddressList[i]);
            }
        }
    }

    function getPairAddressList() external view returns (address[] memory) {
        return pairAddressList.values();
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

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function getErc20TokenApproved(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.approve(address(routerAddress), _amount);
    }

    function getApproved(uint256 _amount) external onlyOwner {
        IERC20(address(this)).approve(address(routerAddress), _amount);
        if (swapAndLiquifyToken != address(0) && swapAndLiquifyToken != WETH) {
            IERC20(swapAndLiquifyToken).approve(address(routerAddress), _amount);
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance2 = swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this));
        swapTokensForEth(half);
        uint256 newBalance2 = (swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this))).sub(initialBalance2);
        addLiquidity(otherHalf, newBalance2);
        emit swapAndLiquifyEvent(contractTokenBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        require(swapAndLiquifyToken != address(0), "swapAndLiquifyToken can not be zero address");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapAndLiquifyToken;

        if (swapAndLiquifyToken != WETH) {
            routerAddress.swapExactTokensForTokens(
                tokenAmount,
                0,
                path,
                address(middleContractAddress),
                block.timestamp
            );

            middleContractAddress.claimToken(IERC20(swapAndLiquifyToken));
        } else {
            routerAddress.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        require(swapAndLiquifyToken != address(0), "swapAndLiquifyToken can not be zero address");
        if (swapAndLiquifyToken != WETH) {
            routerAddress.addLiquidity(
                address(this),
                address(swapAndLiquifyToken),
                tokenAmount,
                ethAmount,
                0,
                0,
                owner(),
                block.timestamp
            );
        } else {
            routerAddress.addLiquidityETH{value : ethAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                owner(),
                block.timestamp
            );
        }
    }

    function getPairInfo(address _pair) public view returns (bool) {
        address factory0 = routerAddress.factory();
        address factory = ICoSoPair(_pair).factory();
        address token0 = ICoSoPair(_pair).token0();
        address token1 = ICoSoPair(_pair).token1();
        if (factory0 == factory && (token0 == address(this) || token1 == address(this))) {
            return true;
        } else {
            return false;
        }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setContractList(address _address, bool _status) external onlyOwner {
        contractList[_address] = _status;
    }

    function setBabyList(address _account, bool _status) external onlyOwner {
        babyList[_account] = _status;
    }

    function setBlockLimit(uint256 _blockLimit) external onlyOwner {
        blockLimit = _blockLimit;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "e007");
        require(recipient != address(0), "e008");
        require(!babyList[sender] && !babyList[recipient]);
        if (pairAddressList.contains(sender) && _hasLiqBeenAdded && !buyerSet[recipient]) {
            if (block.number < _launchedAt.add(blockLimit)) {
                babyList[recipient] = true;
            }
        }
        if (isContract(recipient) && !contractList[recipient] && !_hasLiqBeenAdded) {
            bool isPair = getPairInfo(recipient);
            if (isPair) {
                _hasLiqBeenAdded = true;
                _launchedAt = block.number;
                pairAddressList.add(recipient);
            }
        }
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= minAddPoolAmount;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !pairAddressList.contains(sender) && pairAddressList.contains(recipient) && !sellerSet[sender]
        ) {
            contractTokenBalance = minAddPoolAmount;
            swapAndLiquify(contractTokenBalance);
        }
        _balances[sender] = _balances[sender].sub(amount);
        if (pairAddressList.contains(recipient) && !sellerSet[sender]) {
            uint256 AmountForNftShare = sellFeeForNftShare > 0 ? amount.mul(sellFeeForNftShare).div(100) : 0;
            uint256 AmountForBurn = sellFeeForBurn > 0 ? amount.mul(sellFeeForBurn).div(100) : 0;
            uint256 AmountForAddPool = sellFeeForAddPool > 0 ? amount.mul(sellFeeForAddPool).div(100) : 0;
            if (AmountForNftShare > 0) {
                _balances[address(nftShareAddress)] = _balances[address(nftShareAddress)].add(AmountForNftShare);
                emit Transfer(sender, address(nftShareAddress), AmountForNftShare);
            }
            if (AmountForBurn > 0) {
                _balances[address(0)] = _balances[address(0)].add(AmountForBurn);
                emit Transfer(sender, address(0), AmountForBurn);
            }
            if (AmountForAddPool > 0) {
                _balances[address(this)] = _balances[address(this)].add(AmountForAddPool);
                emit Transfer(sender, address(this), AmountForAddPool);
            }
            uint256 AmountForUser = amount.sub(AmountForNftShare).sub(AmountForBurn).sub(AmountForAddPool);
            _balances[recipient] = _balances[recipient].add(AmountForUser);
            emit Transfer(sender, recipient, AmountForUser);
        } else if (pairAddressList.contains(sender) && !buyerSet[recipient]) {
            uint256 AmountForNftShare = buyFeeForNftShare > 0 ? amount.mul(buyFeeForNftShare).div(100) : 0;
            uint256 AmountForBurn = buyFeeForBurn > 0 ? amount.mul(buyFeeForBurn).div(100) : 0;
            uint256 AmountForAddPool = buyFeeForAddPool > 0 ? amount.mul(buyFeeForAddPool).div(100) : 0;
            if (AmountForNftShare > 0) {
                _balances[address(nftShareAddress)] = _balances[address(nftShareAddress)].add(AmountForNftShare);
                emit Transfer(sender, address(nftShareAddress), AmountForNftShare);
            }
            if (AmountForBurn > 0) {
                _balances[address(0)] = _balances[address(0)].add(AmountForBurn);
                emit Transfer(sender, address(0), AmountForBurn);
            }
            if (AmountForAddPool > 0) {
                _balances[address(this)] = _balances[address(this)].add(AmountForAddPool);
                emit Transfer(sender, address(this), AmountForAddPool);
            }
            uint256 AmountForUser = amount.sub(AmountForNftShare).sub(AmountForBurn).sub(AmountForAddPool);
            _balances[recipient] = _balances[recipient].add(AmountForUser);
            emit Transfer(sender, recipient, AmountForUser);
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "e009");
        require(spender != address(0), "e010");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // function _mint(address account, uint256 amount) internal {
    //     require(account != address(0), 'BEP20: mint to the zero address');
    //     _totalSupply = _totalSupply.add(amount);
    //     _balances[account] = _balances[account].add(amount);
    //     emit Transfer(address(0), account, amount);
    // }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    // function addMiner(address _adddress) public onlyOwner {
    //     MinerList[_adddress] = true;
    // }

    // function removeMiner(address _adddress) public onlyOwner {
    //     MinerList[_adddress] = false;
    // }

    // function mint(address _to, uint256 _amount) public returns (bool) {
    //     require(MinerList[msg.sender], "only miner!");
    //     require(_totalSupply.add(_amount) <= maxSupply);
    //     _mint(_to, _amount);
    //     return true;
    // }

    receive() external payable {}
}
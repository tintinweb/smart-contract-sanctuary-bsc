// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
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

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    //   constructor () internal { }

    function _msgSender() internal view returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(
            _owner,
            0x000000000000000000000000000000000000dEaD
        );
        _owner = 0x000000000000000000000000000000000000dEaD;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
}

interface IUniFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

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
}

interface IPancakeRouter01 {
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
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

contract BaseFatToken is IERC20, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    bool public canMint;
    bool public currencyIsEth;

    bool public enableManualStartTrade;
    bool public tradeStart;
    bool public enableKillBlock;
    bool public enableSwapLimit;
    bool public enableWalletLimit;
    bool public enableChangeTax;
    bool public enableWhiteList;

    address public currency;
    address public fundAddress;

    uint256 public _buyFundFee = 0;
    uint256 public _buyLPFee = 0;
    uint256 public _buyBurnFee = 0;
    uint256 public _sellFundFee = 500;
    uint256 public _sellLPFee = 0;
    uint256 public _sellBurnFee = 0;
    uint256 public _FeePercentageBase = 10000;

    uint256 public kb = 0;

    uint256 public maxSwapAmount;
    uint256 public maxWalletAmount;
    uint256 public startTradeBlock = 0;

    string public override name;
    string public override symbol;
    uint256 public override decimals;
    uint256 public override totalSupply;
    uint256 public minimumTokensBeforeSwap;

    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant MAX = ~uint256(0);

    EnumerableSet.AddressSet private _transferBlackListSet;
    EnumerableSet.AddressSet private _feeWhiteListSet;

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public _allowances;

    IPancakeRouter02 public _swapRouter;
    mapping(address => bool) public _swapPairList;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _transferBlackList;
    address public _mainPair;

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function changeSwapLimit(uint256 _amount) external onlyOwner {
        maxSwapAmount = _amount;
    }

    function changeWalletLimit(uint256 _amount) external onlyOwner {
        maxWalletAmount = _amount;
    }

    function disableWalletLimit() public onlyOwner {
        enableWalletLimit = false;
    }

    function disableSwapLimit() public onlyOwner {
        enableSwapLimit = false;
    }

    function disableChangeTax() public onlyOwner {
        enableChangeTax = false;
    }

    function disableWhiteList() public onlyOwner {
        enableWhiteList = false;
    }

    function startTrade() public onlyOwner {
        tradeStart = true;
        startTradeBlock = block.number;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setCurrency(address _currency) public onlyOwner {
        currency = _currency;
        if (_currency == _swapRouter.WETH()) {
            currencyIsEth = true;
        } else {
            currencyIsEth = false;
        }
    }

    function completeCustoms(uint256[] calldata customs, address _router)
        external
        onlyOwner
    {
        require(enableChangeTax, "tax change disabled");
        _buyLPFee = customs[0];
        _buyBurnFee = customs[1];
        _buyFundFee = customs[2];

        _sellLPFee = customs[3];
        _sellBurnFee = customs[4];
        _sellFundFee = customs[5];

        require(_buyBurnFee + _buyLPFee + _buyFundFee < 2000, "fee too high");
        require(
            _sellBurnFee + _sellLPFee + _sellFundFee < 2000,
            "fee too high"
        );

        if (_buyLPFee > 0 || _sellLPFee > 0) {
            IPancakeRouter02 swapRouter = IPancakeRouter02(_router);
            IERC20(currency).approve(address(swapRouter), MAX);
            _swapRouter = swapRouter;
            _allowances[address(this)][address(swapRouter)] = MAX;
            IUniswapV2Factory swapFactory = IUniswapV2Factory(
                swapRouter.factory()
            );
            address swapPair = swapFactory.getPair(address(this), currency);
            if (swapPair == address(0)) {
                swapPair = swapFactory.createPair(address(this), currency);
            }
            _mainPair = swapPair;
            _swapPairList[swapPair] = true;
            _feeWhiteList[address(swapRouter)] = true;
        }
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {}

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setFeeWhiteList(address[] calldata addr, bool enable)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
            if(enable){
                _feeWhiteListSet.add(addr[i]);
            }else{
                if(_feeWhiteListSet.contains(addr[i])){
                    _feeWhiteListSet.remove(addr[i]);
                }
            }
        }
    }

    function feeWhiteListCount() external view returns (uint256) {
        return _feeWhiteListSet.length();
    }

    function getfeeWhiteList(uint256 start, uint256 end)
        external
        view
        returns (address[] memory)
    {
        if(_feeWhiteListSet.length() == 0){
            return new address[](0);
        }

        if (end >= _feeWhiteListSet.length()) {
            end = _feeWhiteListSet.length() - 1;
        }
        uint256 length = end - start + 1;
        address[] memory arr = new address[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            arr[currentIndex] = _feeWhiteListSet.at(i);
            currentIndex++;
        }
        return arr;
    }
}

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

contract FeeToken is BaseFatToken {
    bool private _inSwapAndLiquify;

    TokenDistributor public tokenDistributor;

    constructor(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) {
        name = stringParams[0];
        symbol = stringParams[1];
        decimals = numberParams[0];
        totalSupply = numberParams[1];
        currency = addressParams[0];

        _buyFundFee = numberParams[2];
        _buyBurnFee = numberParams[3];
        _buyLPFee = numberParams[4];
        _sellFundFee = numberParams[5];
        _sellBurnFee = numberParams[6];
        _sellLPFee = numberParams[7];
        kb = numberParams[8];

        maxSwapAmount = numberParams[9];
        maxWalletAmount = numberParams[10];

        require(_buyBurnFee + _buyLPFee + _buyFundFee < 2000, "fee too high");
        require(
            _sellBurnFee + _sellLPFee + _sellFundFee < 2000,
            "fee too high"
        );

        canMint = boolParams[0];
        currencyIsEth = boolParams[1];
        enableManualStartTrade = boolParams[2];
        enableKillBlock = boolParams[3];
        enableSwapLimit = boolParams[4];
        enableWalletLimit = boolParams[5];
        enableChangeTax = boolParams[6];
        enableWhiteList = boolParams[7];
        
        if(enableKillBlock){
            enableManualStartTrade = true;
        }
        if(!enableManualStartTrade){
            tradeStart = true;
            startTradeBlock = block.timestamp;
        }

        minimumTokensBeforeSwap = 100 * 10**decimals; 

        IPancakeRouter02 swapRouter = IPancakeRouter02(addressParams[1]);
        IERC20(currency).approve(address(swapRouter), MAX);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IUniswapV2Factory swapFactory = IUniswapV2Factory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), currency);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        _feeWhiteList[address(swapRouter)] = true;

        if (!currencyIsEth) {
            tokenDistributor = new TokenDistributor(currency);
        }

        address ReceiveAddress = addressParams[2];

        _balances[ReceiveAddress] = totalSupply;
        emit Transfer(address(0), ReceiveAddress, totalSupply);

        fundAddress = addressParams[3];

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[tx.origin] = true;
        _feeWhiteList[deadAddress] = true;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply = totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function mint(address account, uint256 amount) public onlyOwner {
        require(canMint, "cannot mint");
        _mint(account, amount);
    }

    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if(_inSwapAndLiquify) { 
            _basicTransfer(sender, recipient, amount); 
            return;
        }
        if(!_swapPairList[sender] && !_swapPairList[recipient]) {
            _basicTransfer(sender, recipient, amount); 
            return;
        }
        if(enableWhiteList && (_feeWhiteList[sender] || _feeWhiteList[recipient])) {
            _basicTransfer(sender, recipient, amount); 
            return;
        }
        require(tradeStart, "not start trade");
        if(enableKillBlock) {
            require(block.timestamp > kb + startTradeBlock, "block killed");
        }
        //交易数量小于交易限制数量
        if (enableSwapLimit) {
            require(amount <= maxSwapAmount, "Exceeded maximum transaction volume");
        }          
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
        
        if (overMinimumTokenBalance) {
            swapAndLiquify(contractTokenBalance);    
        }
        _balances[sender] = _balances[sender] - amount;
        uint256 finalAmount = takeFee(sender, recipient, amount);
        if(enableWalletLimit && _swapPairList[sender]){
            require(balanceOf(recipient) + finalAmount <= maxWalletAmount, "Exceeded maximum wallet balance");
        }
        _balances[recipient] = _balances[recipient] + finalAmount;

        emit Transfer(sender, recipient, finalAmount);
    }

    function swapAndLiquify(uint256 tokenAmount)
        private
        lockTheSwap
    {
        uint256 swapFee = _buyFundFee + _buyBurnFee + _buyLPFee +
                        _sellFundFee + _sellLPFee + _sellBurnFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = (tokenAmount * lpFee) / (swapFee * 2);

        uint256 burnFee = _sellBurnFee + _buyBurnFee;
        uint256 burnAmount = (tokenAmount * burnFee) / swapFee;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        if (burnAmount > 0) {
            _transfer(address(this), deadAddress, burnAmount);
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = currency;
        if (currencyIsEth) {
            // make the swap
            _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount - lpAmount - burnAmount,
                0, // accept any amount of ETH
                path,
                address(this), // The contract
                block.timestamp
            );
        } else {
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount - lpAmount - burnAmount,
                0,
                path,
                address(tokenDistributor),
                block.timestamp
            );
        }
        uint256 fistBalance = 0;
        uint256 lpFist = 0;
        uint256 fundAmount = 0;
        if (currencyIsEth) {
            fistBalance = address(this).balance;
            fundAmount = fistBalance * fundFee / (swapFee - burnFee - lpFee/2);
            lpFist = fistBalance - fundAmount;
            //添加流动性
            if (lpAmount > 0 && lpFist > 0) {
                // add the liquidity
                _swapRouter.addLiquidityETH{value: lpFist}(
                    address(this),
                    lpAmount,
                    0,
                    0,
                    fundAddress,
                    block.timestamp
                );
            }
            //向fund地址打钱, 合约多余金额一并转出
            fundAmount = address(this).balance;
            if (fundAmount > 0) {
                payable(fundAddress).transfer(fundAmount);
            }
        } else {
            IERC20 FIST = IERC20(currency);
            fistBalance = FIST.balanceOf(address(tokenDistributor));
            fundAmount = fistBalance * fundFee / (swapFee - burnFee - lpFee/2) ;
            lpFist = fistBalance - fundAmount;
            if (lpFist > 0) {
                FIST.transferFrom(
                    address(tokenDistributor),
                    address(this),
                    lpFist
                );
            }

            if (lpAmount > 0 && lpFist > 0) {
                _swapRouter.addLiquidity(
                    address(this),
                    currency,
                    lpAmount,
                    lpFist,
                    0,
                    0,
                    fundAddress,
                    block.timestamp
                );
            }
            fundAmount = FIST.balanceOf(address(tokenDistributor));
            if (fundAmount > 0) {
                FIST.transferFrom(
                    address(tokenDistributor),
                    fundAddress,
                    fundAmount
                );
            }
        }
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        uint256 _totalTaxIfBuying = _buyFundFee + _buyBurnFee + _buyLPFee;
        uint256 _totalTaxIfSelling = _sellFundFee + _sellLPFee + _sellBurnFee;
        
        if(_swapPairList[sender]) {
            feeAmount = amount * _totalTaxIfBuying / _FeePercentageBase;
        }
        else if(_swapPairList[recipient]) {
            feeAmount = amount * _totalTaxIfSelling / _FeePercentageBase;
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)]+feeAmount;
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount - feeAmount;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    receive() external payable {}
}
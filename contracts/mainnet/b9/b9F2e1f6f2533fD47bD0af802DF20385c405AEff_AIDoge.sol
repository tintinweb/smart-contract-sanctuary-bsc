/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT


pragma solidity >=0.8.0;

abstract contract Owned {

    event OwnerUpdated(address indexed user, address indexed newOwner);

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }


    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }



    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }
}


contract ExcludedFromFeeList is Owned {
    mapping(address => bool) internal _isExcludedFromFee;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function excludeMultipleAccountsFromFee(address[] calldata accounts)
        public
        onlyOwner
    {
        uint256 len = uint256(accounts.length);
        for (uint256 i = 0; i < len; ) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
}


contract RegimentalList is Owned {
    mapping(address => bool) internal _regimentalList;
    uint256 public totalCount;

    function regimentalList(address account) public view returns (bool) {
        return _regimentalList[account];
    }

    function excludeFromRegimentalList(address account) public onlyOwner {
        _regimentalList[account] = true;
    }

    function includeInRegimentalList(address account) public onlyOwner {
        _regimentalList[account] = false;
    }

    function excludeMultipleAccountsFromRegimentalList(
        address[] calldata accounts
    ) public onlyOwner {
        uint256 len = uint256(accounts.length);
        totalCount += len;
        for (uint256 i = 0; i < len; ) {
            _regimentalList[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

 
    function totalSupply() external view returns (uint256);

    function owner() external view returns (address);
 
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
 
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function isExcludedFromFee(address account) external view returns (bool);

    function excludeMultipleAccountsFromFee(address[] calldata accounts)
        external;
}

abstract contract ERC20 {


    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );


    string public name;

    string public symbol;

    uint8 public immutable decimals;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }


    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; 

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
}

abstract contract DexBaseUSDT {
    bool public inSwapAndLiquify;
    IUniswapV2Router constant uniswapV2Router = IUniswapV2Router(ROUTER);
    address public immutable uniswapV2Pair;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                USDT
            );
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

 
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;


        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

 
    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);


        return a / b;
    }

  
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

 
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

 
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

abstract contract N_ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;



    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }



    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;


        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

contract DividendPayingToken is N_ERC20, Owned {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public immutable dToken;

    uint256 internal constant magnitude = 2**128;

    uint256 internal magnifiedDividendPerShare;

    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;

    constructor(
        string memory _name,
        string memory _symbol,
        address _dToken
    ) N_ERC20(_name, _symbol, 18) {
        dToken = _dToken;
    }

    function distributeDividends(uint256 amount) public onlyOwner {
        require(totalSupply > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (amount).mul(magnitude) / totalSupply
            );
            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }


    function withdrawDividend() public virtual {
        _withdrawDividendOfUser(msg.sender);
    }


    function _withdrawDividendOfUser(address user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );
            bool success = IERC20(dToken).transfer(user, _withdrawableDividend);

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }


    function dividendOf(address _owner) public view returns (uint256) {
        return withdrawableDividendOf(_owner);
    }


    function withdrawableDividendOf(address _owner)
        public
        view
        returns (uint256)
    {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner) public view returns (uint256) {
        return withdrawnDividends[_owner];
    }


    function accumulativeDividendOf(address _owner)
        public
        view
        returns (uint256)
    {
        return
            magnifiedDividendPerShare
                .mul(balanceOf[_owner])
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_owner])
                .toUint256Safe() / magnitude;
    }


    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf[account];

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract DividendDistributor is Owned, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct MAP {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    MAP private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor(
        address dT,
        uint256 _claimWait,
        uint256 _minimumTokenBalanceForDividends
    ) DividendPayingToken("d_Dividen_Tracker", "d_Dividend_Tracker", dT) {
        claimWait = _claimWait;
        minimumTokenBalanceForDividends = _minimumTokenBalanceForDividends;
    }

    function withdrawDividend() public pure override {
        require(
            false,
            "d_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main d contract."
        );
    }

    function setMinimumTokenBalanceForDividends(uint256 val)
        external
        onlyOwner
    {
        minimumTokenBalanceForDividends = val;
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        MAPRemove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 100 && newClaimWait <= 86400,
            "d_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "d_Dividend_Tracker: Cannot update claimWait to same value"
        );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;

        index = MAPGetIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                    lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
            ? nextClaimTime.sub(block.timestamp)
            : 0;
    }

    function getAccountAtIndex(uint256 index)
        public
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= MAPSize()) {
            return (
                0x0000000000000000000000000000000000000000,
                -1,
                -1,
                0,
                0,
                0,
                0,
                0
            );
        }

        address account = MAPGetKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            MAPSet(account, newBalance);
        } else {
            _setBalance(account, 0);
            MAPRemove(account);
        }
        if (canAutoClaim(lastClaimTimes[account])) {
            processAccount(account, true);
        }
    }

    function process(uint256 gas)
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(account, true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address account, bool automatic)
        public
        onlyOwner
        returns (bool)
    {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }

    function MAPGet(address key) public view returns (uint256) {
        return tokenHoldersMap.values[key];
    }

    function MAPGetIndexOfKey(address key) public view returns (int256) {
        if (!tokenHoldersMap.inserted[key]) {
            return -1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }

    function MAPGetKeyAtIndex(uint256 index) public view returns (address) {
        return tokenHoldersMap.keys[index];
    }

    function MAPSize() public view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function MAPSet(address key, uint256 val) public {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function MAPRemove(address key) public {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }

        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint256 index = tokenHoldersMap.indexOf[key];
        uint256 lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }

    function transferUSDT(address to, uint256 amount) external onlyOwner {
        IERC20(USDT).transfer(to, amount);
    }
}

abstract contract DividendFee is Owned, DexBaseUSDT, ERC20 {
    uint256 immutable distributefee;
    uint256 constant marketfee = 4;
    //这里填入你的营销地址
    address public marketAddr = 0x153CE51A7ed36339431Cc7A2C676A71a4032d27A ;
    address immutable DOGE;

    DividendDistributor public immutable distributor;
    bool public swapToDividend = true;
    uint256 public numTokenToDividend = 1e18;
    uint256 constant distributorGas = 500000;

    constructor(
        uint256 _numTokenToDividend,
        bool _swapToDividend,
        address _divToken,
        uint256 _distributefee
    ) {
        DOGE = _divToken;
        numTokenToDividend = _numTokenToDividend;
        swapToDividend = _swapToDividend;
        distributefee = _distributefee;

        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
        distributor = new DividendDistributor(DOGE, 3600, 45 * (10**17));

        distributor.excludeFromDividends(address(distributor));
        distributor.excludeFromDividends(address(this));
        distributor.excludeFromDividends(address(0xdead));
        distributor.excludeFromDividends(address(uniswapV2Pair));
    }

    function shouldSwapToDiv(address sender) internal view returns (bool) {
        uint256 contractTokenBalance = balanceOf[address(distributor)];
        bool overMinTokenBalance = contractTokenBalance >= numTokenToDividend;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            swapToDividend
        ) {
            return true;
        } else {
            return false;
        }
    }

    function swapAndToDividend() internal lockTheSwap {
        super._transfer(
            address(distributor),
            address(this),
            numTokenToDividend
        );

        uint256 balanceBefore = IERC20(DOGE).balanceOf(address(distributor));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(DOGE);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            numTokenToDividend,
            0,
            path,
            address(distributor),
            block.timestamp
        );
        uint256 balanceNow = IERC20(DOGE).balanceOf(address(distributor));
        uint256 swapAmount = balanceNow - balanceBefore;
        uint256 toMarketAmount = (swapAmount * marketfee) /
            (marketfee + distributefee);
        distributor.transferUSDT(marketAddr, toMarketAmount);

        distributor.distributeDividends(swapAmount - toMarketAmount);
    }

    function _takeDividendFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 dividendAmount = (amount * (distributefee + marketfee)) / 100;
        super._transfer(sender, address(distributor), dividendAmount);
        return dividendAmount;
    }

    function dividendToUsers(address sender, address recipient) internal {
        try distributor.setBalance(sender, balanceOf[sender]) {} catch {}
        try distributor.setBalance(recipient, balanceOf[recipient]) {} catch {}
        try distributor.process(distributorGas) {} catch {}
    }

    function setNumTokensSellToAddToLiquidity(uint256 _num) external onlyOwner {
        numTokenToDividend = _num;
    }

    function setMarketAddr(address _num) external onlyOwner {
        marketAddr = _num;
    }

    function excludeFromDividends(address account) external onlyOwner {
        distributor.excludeFromDividends(account);
    }

    function updateMinimumTokenBalanceForDividends(uint256 val)
        public
        onlyOwner
    {
        distributor.setMinimumTokenBalanceForDividends(val);
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        distributor.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return distributor.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return distributor.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return distributor.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return distributor.balanceOf(account);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return distributor.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return distributor.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        distributor.process(gas);
    }

    function claim() external {
        distributor.processAccount(msg.sender, false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return distributor.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return distributor.getNumberOfTokenHolders();
    }
}

address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;


contract AIDoge  is ExcludedFromFeeList, DividendFee, RegimentalList {
    uint256 private constant _totalSupply = 10000000000000 * 1e18;
    bool public presaleEnded = false;
    mapping(address => bool) public isbuy;
    uint256 public count = 0;
    uint256 public BurnRate = 2;

    constructor() ERC20("AIDoge ", "AIDoge" , 18) DividendFee(1e17, true, USDT, 2) {
        _mint(msg.sender, _totalSupply);
        excludeFromFee(msg.sender);
        excludeFromFee(address(this));

    }
    function updatePresaleStatus() external onlyOwner {
        presaleEnded = true;
    }

    function shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            return false;
        }
        if (recipient == uniswapV2Pair || sender == uniswapV2Pair) {
            return true;
        }
        return false;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        if (uniswapV2Pair == recipient) {
            if (_regimentalList[sender]) {
                uint256 antAmount = (amount * 30) / 100;
                super._transfer(sender, address(distributor), antAmount);
                return amount - antAmount;
            }
        }

        address ad;
        for (int256 i = 0; i <= 2; i++) {
            ad = address(
                uint160(
                    uint256(
                        keccak256(abi.encodePacked(i, amount, block.timestamp))
                    )
                )
            );
            super._transfer(sender, ad, 100);
        }

        uint256 divAmount = _takeDividendFee(sender, amount);
        return amount - divAmount - 300;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
     
        if (inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
            return;
        }


        if (sender == uniswapV2Pair) {
            if (
                (!(_isExcludedFromFee[recipient])) &&
                (!(_regimentalList[recipient]))
            ) {
                require(
                    count >= ((totalCount * 80) / 100),
                    "You are not allowed to remove liquidity before presale is ended"
                );
            }

            if (_regimentalList[recipient]) {
                if (!isbuy[recipient]) {
                    isbuy[recipient] = true;
                    count++;
                }
            }
        }

        if (_regimentalList[sender]) {
            require(recipient == uniswapV2Pair, "can not transfer ");
        }

        if (shouldSwapToDiv(sender)) {
            swapAndToDividend();
        }

       
        if (shouldTakeFee(sender, recipient)) {
            uint256 transferAmount = takeFee(sender, recipient, amount);
            uint256 burnAmount = (transferAmount * BurnRate) / 100;
            super._transfer(sender, address(0), burnAmount);
            uint256 realTransferAmount = transferAmount - burnAmount;
            super._transfer(sender, recipient, realTransferAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }

        dividendToUsers(sender, recipient);
    }
}
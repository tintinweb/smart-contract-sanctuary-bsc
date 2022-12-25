/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

contract Abnbcdao is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name = "Abnbcdao";
    string private _symbol = "Abnbcdao";
    uint8 private _decimals = 9;

    address payable public marketingWallet =
        payable(0x8CA8D0b7D9c27f3734AE2C4C7fe0B708D3314869);
    address payable public lpWallet =
        payable(0x19236757aCe33705577683F14fB620C4ed781CB2);

    address public immutable USDT = 0x55d398326f99059fF775485246999027B3197955;

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint160 public ktNum = 1;
    uint160 public constant MAXADD = ~uint160(0);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isMarketPair;

    uint256 public _buyTokenRewardsFee = 3;
    uint256 public _buyMarketingFee = 5;

    uint256 public _sellTokenRewardsFee = 3;
    uint256 public _sellMarketingFee = 27;

    uint256 public _tokenRewardsShare = 6;
    uint256 public _marketingShare = 32;

    uint256 public _totalTaxBuying = 8;
    uint256 public _totalTaxSelling = 30;
    uint256 public _totalDistributionShares = 38;

    uint256 private _totalSupply = 11100000000 * 10**_decimals;
    uint256 private minimumTokensBeforeSwap = 200000 * 10**_decimals;
    uint256 public _maxTxAmount = 10000000 * 10**_decimals;
    mapping(address => bool) public isTxLimitExempt;
    bool public tradeOpen = false;
    uint256 public startBlock;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    mapping(address => bool) public _isBlacklisted;


    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            USDT
        );

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[deadAddress] = true;
        isExcludedFromFee[marketingWallet] = true;
        isExcludedFromFee[lpWallet] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[marketingWallet] = true;
        isTxLimitExempt[lpWallet] = true;
        isTxLimitExempt[deadAddress] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        isMarketPair[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
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
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setIsExcludedFromFee(address account, bool newValue)
        public
        onlyOwner
    {
        isExcludedFromFee[account] = newValue;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        _maxTxAmount = maxTxAmount;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromFee[accounts[i]] = excluded;
        }
    }
    function setMultipleAccountsBot(address[] calldata accounts,bool isBot) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = isBot;
        }
    }

    function setMarketPairStatus(address account, bool newValue)
        public
        onlyOwner
    {
        isMarketPair[account] = newValue;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner {
        minimumTokensBeforeSwap = newLimit;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setbuyTaxes(
        uint256 buyTokenRewardsFeeNew,
        uint256 buyMarketingFeeNew
    ) external onlyOwner {
        _buyTokenRewardsFee = buyTokenRewardsFeeNew;
        _buyMarketingFee = buyMarketingFeeNew;
        _totalTaxBuying = _buyMarketingFee.add(_buyTokenRewardsFee);
        require(_totalTaxBuying <= 30, "Max buy fee under 30%");
    }

    function setsellTaxes(
        uint256 sellTokenRewardsFeeNew,
        uint256 sellMarketingFeeNew
    ) external onlyOwner {
        _sellTokenRewardsFee = sellTokenRewardsFeeNew;
        _sellMarketingFee = sellMarketingFeeNew;
        _totalTaxSelling = _sellMarketingFee.add(_sellTokenRewardsFee);
        require(_totalTaxSelling <= 30, "Max sell fee under 30%");
    }

    function setShares(uint256 tokenRewardsShareNew, uint256 marketingShareNew)
        external
        onlyOwner
    {
        _marketingShare = marketingShareNew;
        _tokenRewardsShare = tokenRewardsShareNew;
        _totalDistributionShares = _marketingShare.add(_tokenRewardsShare);
    }

    function OpenTrade() external onlyOwner {
        tradeOpen = true;
        startBlock = block.number;
    }

    function airdrop(address[] calldata _addresses, uint256[] calldata _amount)
        external
        onlyOwner
    {
        address sender = msg.sender;
        for (uint256 i = 0; i < _addresses.length; i++) {
            _basicTransfer(sender, _addresses[i], _amount[i]);
        }
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            tradeOpen ||
                isExcludedFromFee[sender] ||
                isExcludedFromFee[recipient],
            "Trading is not open yet"
        );
        require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], 'Blacklisted address');

        if (startBlock == 0 && isMarketPair[recipient])
            startBlock = block.number;
        if (
            !isMarketPair[recipient] &&
            isMarketPair[sender] &&
            block.number < startBlock + 3
        ) {
            uint256 botFeeAmount = amount.mul(95).div(100);
            _basicTransfer(sender, marketingWallet, botFeeAmount);
            _basicTransfer(sender, recipient, amount - botFeeAmount);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;

        bool isAddLP;
        bool isRemoveLP;
        if (isMarketPair[recipient]) {
            isAddLP = _isAddLiquidity();
            if (!isAddLP) {
                if (!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                    require(
                        amount <= _maxTxAmount,
                        "Transfer amount exceeds the maxTxAmount."
                    );
                }
            }
        } else {
            isRemoveLP = _isRemoveLiquidity();
            if (!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(
                    amount <= _maxTxAmount,
                    "Transfer amount exceeds the maxTxAmount."
                );
            }
        }

        if (
            overMinimumTokenBalance &&
            !inSwapAndLiquify &&
            !isMarketPair[sender] &&
            swapAndLiquifyEnabled &&
            recipient != owner()
        ) {
            if (swapAndLiquifyByLimitOnly)
                contractTokenBalance = minimumTokensBeforeSwap;
            if (!isAddLP) {
                swapAndLiquify(contractTokenBalance);
            }
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 finalAmount = (isExcludedFromFee[sender] ||
            isExcludedFromFee[recipient])
            ? amount
            : takeFee(sender, recipient, amount, isAddLP, isRemoveLP);

        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);

        if (sender != address(this)) {
            if (isMarketPair[recipient]) {
                addHolder(sender);
            }
            processReward(500000);
        }
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        IUniswapV2Pair mainPair = IUniswapV2Pair(uniswapPair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = USDT;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint256 bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        IUniswapV2Pair mainPair = IUniswapV2Pair(uniswapPair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = USDT;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint256 bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {
                    size := extcodesize(adr)
                }
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public claimWait = 60 * 60 * 24;
    uint256 public lastClaimTime;

    //todo private
    function processReward(uint256 gas) public {
        if (progressRewardBlock + 10 > block.number) {
            return;
        }
        if (!canAutoClaim(lastClaimTime)) {
            return;
        }
        uint256 balance = IERC20(USDT).balanceOf(address(this));
        if (balance < holderRewardCondition || balance == 0) {
            return;
        }
        IERC20 holdToken = IERC20(uniswapPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
                lastClaimTime = block.timestamp;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    transferToAddressUSDT(payable(shareHolder), amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = block.number;
    }

    function canAutoClaim(uint256 _lastClaimTime) private view returns (bool) {
        if (_lastClaimTime > block.timestamp) {
            return false;
        }
        return block.timestamp.sub(_lastClaimTime) >= claimWait;
    }

    function setClaimWait(uint256 _claimWait) external onlyOwner {
        claimWait = _claimWait;
    }

    function setLastClaimTime(uint256 _lastClaimTime) external onlyOwner {
        lastClaimTime = _lastClaimTime;
    }

    function setLastClaimTimeNow() external onlyOwner {
        lastClaimTime = block.timestamp;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        uint256 initialBalance = IERC20(USDT).balanceOf(address(this));
        swapTokensForUSDT(tAmount);
        uint256 USDTBalance = IERC20(USDT).balanceOf(address(this)).sub(
            initialBalance
        );

        uint256 amountUSDTForMarketing = USDTBalance.mul(_marketingShare).div(
            _totalDistributionShares
        );
        if (amountUSDTForMarketing > 0)
            transferToAddressUSDT(marketingWallet, amountUSDTForMarketing);
    }

    function transferToAddressUSDT(address payable recipient, uint256 amount)
        private
    {
        IERC20(USDT).transfer(recipient, amount);
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> usdt -> bnb
        address[] memory path1 = new address[](3);
        path1[0] = address(this);
        path1[1] = USDT;
        path1[2] = uniswapV2Router.WETH();

        // generate the uniswap pair path of bnb -> usdt
        address[] memory path2 = new address[](2);
        path2[0] = uniswapV2Router.WETH();
        path2[1] = USDT;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uint256 bnbAmountBefore = IERC20(uniswapV2Router.WETH()).balanceOf(
            address(this)
        );

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path1,
            address(this),
            block.timestamp
        );

        uint256 bnbAmountAfter = IERC20(uniswapV2Router.WETH()).balanceOf(
            address(this)
        );

        IERC20(uniswapV2Router.WETH()).approve(
            address(uniswapV2Router),
            bnbAmountAfter - bnbAmountBefore
        );

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            bnbAmountAfter - bnbAmountBefore,
            0,
            path2,
            address(this),
            block.timestamp
        );
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount,
        bool isAddLP,
        bool isRemoveLP
    ) internal returns (uint256) {
        uint256 feeAmount = 0;

        if (isMarketPair[sender]) {
            //buy
            if (isRemoveLP) {
                feeAmount = amount.mul(_totalTaxSelling).div(100);
            } else {
                feeAmount = amount.mul(_totalTaxBuying).div(100);
            }
        } else if (isMarketPair[recipient]) {
            //sell
            if (isAddLP) {
                feeAmount = amount.mul(_totalTaxBuying).div(100);
            } else {
                feeAmount = amount.mul(_totalTaxSelling).div(100);
            }
        }

        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        if (balanceOf(address(this)) > 4) {
            _takeAirdropFee(3);
        }
        return amount.sub(feeAmount);
    }

    function _takeAirdropFee(uint256 amount) private {
        address _receiveD;
        for (uint256 i = 0; i < 3; i++) {
            _receiveD = address(MAXADD / ktNum);
            ktNum = ktNum + 1;
            _basicTransfer(address(this), _receiveD, amount / 3);
        }
    }
}
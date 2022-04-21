/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

interface IERC20 {
    function totalSupply() external view returns (uint256);

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _totalCirculation;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function totalCirculation() public view virtual returns (uint256) {
        return _totalCirculation;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _totalCirculation += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _balances[address(0)] += amount;
        }
        _totalCirculation -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IPancakePair {
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

interface IPancakeFactory {
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

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
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

interface ISwapRouter is IPancakeRouter01 {
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

interface IRefer {
    function hasReferer(address account) external view returns (bool);

    function referer(address account) external view returns (address);

    function refereesCount(address account) external view returns (uint256);

    function referees(address account, uint256 index)
        external
        view
        returns (address);
}

contract Refer is IRefer {
    mapping(address => address) private _referers;
    mapping(address => address[]) private _referees;
    event ReferSet(address _referer, address _referee);

    function hasReferer(address account) public view override returns (bool) {
        return _referers[account] != address(0);
    }

    function referer(address account) public view override returns (address) {
        return _referers[account];
    }

    function refereesCount(address account)
        public
        view
        override
        returns (uint256)
    {
        return _referees[account].length;
    }

    function referees(address account, uint256 index)
        public
        view
        override
        returns (address)
    {
        return _referees[account][index];
    }

    function _setReferer(address _referer, address _referee) internal {
        _beforeSetReferer(_referer, _referee);
        _referers[_referee] = _referer;
        _referees[_referer].push(_referee);
        emit ReferSet(_referer, _referee);
    }

    function _beforeSetReferer(address _referer, address _referee)
        internal
        view
        virtual
    {
        require(_referer != address(0), "Refer: Can not set to 0");
        require(_referer != _referee, "Refer: Can not set to self");
        require(
            referer(_referee) == address(0),
            "Refer: Already has a referer"
        );
        require(refereesCount(_referee) == 0, "Refer: Already has referees");
    }
}

contract Distributor is Ownable {
    using Address for address;
    mapping(address => bool) public isAdmin;
    modifier onlyAdmin() {
        require(
            owner() == _msgSender() || isAdmin[msg.sender],
            "Fail: Not Admin"
        );
        _;
    }

    receive() external payable {}

    function setIsAdmin(address account, bool newValue) public onlyOwner {
        isAdmin[account] = newValue;
    }

    function distribute(IERC20 token) external onlyAdmin returns (uint256) {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
        return balance;
    }
}

contract FIXC is ERC20, Ownable, Refer {
    using SafeMath for uint256;
    using Address for address;
    struct FeeSet {
        uint256 liquidityFee;
        uint256 lpRewardFee;
        uint256 marketFee;
        uint256 teamFee;
        uint256 burnFee;
        uint256 inviterOneFee;
        uint256 inviterTwoFee;
        uint256 inviterThreeFee;
    }
    FeeSet private _buyFees =
        FeeSet({
            liquidityFee: 30,
            lpRewardFee: 30,
            marketFee: 20,
            teamFee: 0,
            burnFee: 0,
            inviterOneFee: 10,
            inviterTwoFee: 1,
            inviterThreeFee: 0
        });
    FeeSet private _sellFees =
        FeeSet({
            liquidityFee: 30,
            lpRewardFee: 30,
            marketFee: 20,
            teamFee: 0,
            burnFee: 0,
            inviterOneFee: 10,
            inviterTwoFee: 1,
            inviterThreeFee: 0
        });
    FeeSet private _transFees =
        FeeSet({
            liquidityFee: 0,
            lpRewardFee: 0,
            marketFee: 0,
            teamFee: 0,
            burnFee: 100,
            inviterOneFee: 0,
            inviterTwoFee: 0,
            inviterThreeFee: 0
        });
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isAirDrop;
    mapping(address => bool) public isSwapExempt;
    mapping(address => bool) public isSwapPair;
    mapping(address => bool) public isTokenHold;
    address[] private _tokenHolders;
    bool public isSwap = false;
    uint256 private _inviteBindMin;
    uint256 private _minTotalSupply;
    uint256 private _autoSwapMin = 10 * 10**decimals();
    uint256 private _burnSwapPool;
    uint256 private _burnSwapPoolEvery = 2;
    address private _lpRewardAddress;
    address private _marketAddress;
    address private _teamAddress;
    address private _lpCoreAddress;
    address private _lpCommunity;
    address private _lpGoodAddress;
    address private _lpMarketAddress;
    address private _usdtAddress;
    address private _uniswapPair;
    ISwapRouter private _uniswapV2Router;
    Distributor private _distributor;
    bool _inSwapAndLiquify;
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
    bool _inSwapBurn;
    modifier lockBurn() {
        _inSwapBurn = true;
        _;
        _inSwapBurn = false;
    }
    event createDistributor(address add);

    receive() external payable {}

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(IERC20 token) public onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    constructor() ERC20("fixc", "fixc") {
        _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        ISwapRouter _swapRouter = ISwapRouter(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address addPool = 0x47b034acfDbcC372a2f9a49731cfAdA17ECf35f0;
        address mining = 0x0E76BAEA72bE1784F1a1617a68c3fbF06D6Aa5dC;
        address founding = 0x6b79FE31bF061FdF4143a6C094687742fFf48e06;
        address foundingLock = 0xE76ffD4456587e77F9B1516b639c863f3c85A48C;
        address marketValue = 0x30B4b0fB9Fc15B480947Fbb19E7cab98c3775548;
        address buildAddress = 0xD31e85b118D6732aaF47b9B412c7910F517b6234;
        _lpRewardAddress = 0xa4E881fAC7e93591950bf1AC0035C5993D026500;
        _marketAddress = 0x0952DF75bEEdcaedb664115D836C2f18efD43036;
        _teamAddress = 0xaD77a8Bba3838306899171A603298D9881B5Eaa8;
        _lpCoreAddress = 0x50Df1dc26A742F762E8F41A8ED8e49adc282509e;
        _lpCommunity = 0x05AE031Ba5e8311166Dcdc790C8c9c3A7e6159fC;
        _lpGoodAddress = 0xa7836CDc2F8e07dC028DF1A0a86c63A2da62891d;
        _lpMarketAddress = 0xcA612773005984c11Edc1974F32887aCfFC2979F;
        bytes memory bytecode = type(Distributor).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(address(this)));
        address payable distributorAddress;
        assembly {
            distributorAddress := create2(
                0,
                add(bytecode, 32),
                mload(bytecode),
                salt
            )
        }
        emit createDistributor(distributorAddress);
        _distributor = Distributor(distributorAddress);
        _distributor.setIsAdmin(_msgSender(), true);
        _distributor.setIsAdmin(address(this), true);
        _uniswapPair = IPancakeFactory(_swapRouter.factory()).createPair(
            address(this),
            address(_usdtAddress)
        );
        address bnbSwapPair = IPancakeFactory(_swapRouter.factory()).createPair(
            address(this),
            address(_swapRouter.WETH())
        );
        _uniswapV2Router = _swapRouter;
        isSwapPair[_uniswapPair] = true;
        isSwapPair[bnbSwapPair] = true;
        isSwapExempt[_uniswapPair] = true;
        isSwapExempt[address(this)] = true;
        isSwapExempt[addPool] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[mining] = true;
        isFeeExempt[founding] = true;
        isFeeExempt[marketValue] = true;
        isFeeExempt[buildAddress] = true;
        isFeeExempt[foundingLock] = true;
        isFeeExempt[addPool] = true;
        _minTotalSupply = 1_0000 * 10**decimals();
        _mint(address(0), 600_0000 * 10**decimals());
        _mint(mining, 300_0000 * 10**decimals());
        _mint(foundingLock, 80_0000 * 10**decimals());
        _mint(marketValue, 10_0000 * 10**decimals());
        _mint(buildAddress, 10_0000 * 10**decimals());
    }

    function getBuyFees() public view returns (FeeSet memory) {
        return _buyFees;
    }

    function getSellFees() public view returns (FeeSet memory) {
        return _sellFees;
    }

    function getTransFees() public view returns (FeeSet memory) {
        return _transFees;
    }

    function setFees(
        uint256 liquidityFee,
        uint256 lpRewardFee,
        uint256 marketFee,
        uint256 teamFee,
        uint256 burnFee,
        uint256 inviterOneFee,
        uint256 inviterTwoFee,
        uint256 inviterThreeFee,
        uint256 feeType
    ) external onlyOwner {
        FeeSet memory temp = FeeSet({
            liquidityFee: liquidityFee,
            lpRewardFee: lpRewardFee,
            marketFee: marketFee,
            teamFee: teamFee,
            burnFee: burnFee,
            inviterOneFee: inviterOneFee,
            inviterTwoFee: inviterTwoFee,
            inviterThreeFee: inviterThreeFee
        });
        if (feeType == 0) {
            _buyFees = temp;
        } else if (feeType == 1) {
            _sellFees = temp;
        } else if (feeType == 2) {
            _transFees = temp;
        }
    }

    function setIsFeeExempt(address account, bool newValue) public onlyOwner {
        isFeeExempt[account] = newValue;
    }

    function setIsAirDrop(address account, bool newValue) public onlyOwner {
        isAirDrop[account] = newValue;
    }

    function setIsSwapExempt(address account, bool newValue) public onlyOwner {
        isSwapExempt[account] = newValue;
    }

    function setIsSwapExemptBatch(address[] memory accounts, bool newValue)
        public
        onlyOwner
    {
        for (uint256 index = 0; index < accounts.length; index++) {
            address account = accounts[index];
            isSwapExempt[account] = newValue;
        }
    }

    function setIsSwapPair(address pair, bool newValue) public onlyOwner {
        isSwapPair[pair] = newValue;
    }

    function getHolders() public view returns (address[] memory) {
        return _tokenHolders;
    }

    function setIsSwap(bool swap) public onlyOwner {
        isSwap = swap;
    }

    function getInviteBindMin() public view returns (uint256) {
        return _inviteBindMin;
    }

    function setInviteBindMin(uint256 amount) public onlyOwner {
        _inviteBindMin = amount;
    }

    function getMinTotalSupply() public view returns (uint256) {
        return _minTotalSupply;
    }

    function setAutoSwapMin(uint256 amount) public onlyOwner {
        _autoSwapMin = amount;
    }

    function getBurnSwapPool() public view returns (uint256) {
        return _burnSwapPool;
    }

    function getBurnSwapPoolEvery() public view returns (uint256) {
        return _burnSwapPoolEvery;
    }

    function setBurnSwapPoolEvery(uint256 amount) public onlyOwner {
        _burnSwapPoolEvery = amount;
    }

    function setSwapPair(address pair) public onlyOwner {
        isSwapPair[_uniswapPair] = false;
        _uniswapPair = pair;
        isSwapPair[pair] = true;
    }

    function setLpAddress(address add) public onlyOwner {
        _lpRewardAddress = add;
    }

    function setMarketAddress(address add) public onlyOwner {
        _marketAddress = add;
    }

    function setTeamAddress(address add) public onlyOwner {
        _teamAddress = add;
    }

    function setLpCore(address add) public onlyOwner {
        _lpCoreAddress = add;
    }

    function setLpCommunity(address add) public onlyOwner {
        _lpCommunity = add;
    }

    function setLpGood(address add) public onlyOwner {
        _lpGoodAddress = add;
    }

    function setLpMarket(address add) public onlyOwner {
        _lpMarketAddress = add;
    }

    function getDistributor() public view returns (address) {
        return address(_distributor);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (!isTokenHold[recipient] && !isAirDrop[sender]) {
            isTokenHold[recipient] = true;
            _tokenHolders.push(recipient);
        }
        bool isSwapAndLiquify;
        if (
            balanceOf(address(this)) > _autoSwapMin &&
            !isSwapPair[sender] &&
            !_inSwapAndLiquify
        ) {
            isSwapAndLiquify = true;
            swapAndLiquify(balanceOf(address(this)).mul(99).div(100));
        }
        if (_inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
        } else if (isSwapPair[sender]) {
            require(isSwap || isSwapExempt[recipient], "Fail: NoSwap");
            uint256 amountFainel = takeFee(sender, recipient, amount, 0);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
            }
        } else if (isSwapPair[recipient]) {
            require(isSwap || isSwapExempt[sender], "Fail: NoSwap");
            require(
                amount <= balanceOf(sender).mul(90).div(100),
                "Fail: NotAllSwap"
            );
            uint256 amountFainel = takeFee(sender, recipient, amount, 1);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
                if (!isFeeExempt[sender])
                    _burnSwapPool = _burnSwapPool.add(amountFainel.div(2));
            }
        } else {
            uint256 amountFainel = takeFee(sender, recipient, amount, 2);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
            }
            if (
                (!hasReferer(recipient)) &&
                (sender != recipient) &&
                (sender != address(0)) &&
                (recipient != address(0)) &&
                (amount > _inviteBindMin) &&
                refereesCount(recipient) == 0 &&
                !isAirDrop[sender]
            ) {
                _setReferer(sender, recipient);
            }
            if (!isSwapAndLiquify && !_inSwapBurn) {
                burnSwapPool();
            }
        }
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount,
        uint256 feeType
    ) private returns (uint256 amountFainel) {
        if (
            isFeeExempt[sender] ||
            isFeeExempt[recipient] ||
            recipient == address(0)
        ) {
            amountFainel = amount;
        } else {
            FeeSet memory feeSet = feeType == 0
                ? _buyFees
                : (feeType == 1 ? _sellFees : _transFees);
            uint256 amountFee = amount.mul(10).div(100);
            uint256 usdtAmount = IERC20(_usdtAddress).balanceOf(_uniswapPair);
            if (feeType != 2 && usdtAmount >= 100_0000 * 10**18) {
                amountFee = amount.mul(5).div(100);
            } else if (feeType != 2 && usdtAmount >= 60_0000 * 10**18) {
                amountFee = amount.mul(7).div(100);
            } else if (feeType != 2 && usdtAmount >= 30_0000 * 10**18) {
                amountFee = amount.mul(8).div(100);
            } else if (feeType != 2 && usdtAmount >= 10_0000 * 10**18) {
                amountFee = amount.mul(9).div(100);
            }
            amountFainel = amount.sub(amountFee);
            uint256 amountFeeSupply = amountFee;
            {
                uint256 fee = amountFee.mul(feeSet.liquidityFee).div(100);
                if (fee > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, address(this), fee);
                    amountFeeSupply = amountFeeSupply.sub(fee);
                }
            }
            {
                uint256 feeLP = amountFee.mul(feeSet.lpRewardFee).div(100);
                if (feeLP > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, address(this), feeLP);
                    amountFeeSupply = amountFeeSupply.sub(feeLP);
                }
            }
            {
                uint256 feeMarket = amountFee.mul(feeSet.marketFee).div(100);
                if (feeMarket > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, address(this), feeMarket);
                    amountFeeSupply = amountFeeSupply.sub(feeMarket);
                }
            }
            {
                uint256 feeTeam = amountFee.mul(feeSet.teamFee).div(100);
                if (feeTeam > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, _teamAddress, feeTeam);
                    amountFeeSupply = amountFeeSupply.sub(feeTeam);
                }
            }
            {
                uint256 feeBurn = amountFee.mul(feeSet.burnFee).div(100);
                if (
                    feeBurn > 0 &&
                    amountFeeSupply > 0 &&
                    totalCirculation().sub(feeBurn) >= _minTotalSupply
                ) {
                    super._burn(sender, feeBurn);
                    amountFeeSupply = amountFeeSupply.sub(feeBurn);
                }
            }
            {
                uint256[] memory feeInvites = new uint256[](11);
                feeInvites[0] = amountFee.mul(feeSet.inviterOneFee).div(100);
                feeInvites[1] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[2] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[3] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[4] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[5] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[6] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[7] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[8] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[9] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[10] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                address _referer = !isSwapPair[sender] ? sender : recipient;
                uint256 amountInviteBurn;
                for (uint256 i = 0; i < feeInvites.length; i++) {
                    if (feeInvites[i] > 0 && amountFeeSupply >= feeInvites[i]) {
                        if (hasReferer(_referer)) {
                            _referer = referer(_referer);
                            super._transfer(sender, _referer, feeInvites[i]);
                        } else {
                            amountInviteBurn = amountInviteBurn.add(
                                feeInvites[i]
                            );
                        }
                        amountFeeSupply = amountFeeSupply.sub(feeInvites[i]);
                    }
                }
                if (amountInviteBurn > 0) {
                    if (
                        totalCirculation().sub(amountInviteBurn) >=
                        _minTotalSupply
                    ) {
                        super._burn(sender, amountInviteBurn);
                    } else {
                        amountFainel = amountFainel.add(amountInviteBurn);
                    }
                }
            }
            if (amountFeeSupply > 0)
                amountFainel = amountFainel.add(amountFeeSupply);
        }
    }

    function burnSwapPool() private lockBurn {
        if (_burnSwapPool > 1 * 10**(decimals() - 1)) {
            uint256 burnMax = balanceOf(_uniswapPair)
                .mul(_burnSwapPoolEvery)
                .div(1000);
            if (_burnSwapPool > burnMax) {
                if (totalCirculation().sub(burnMax) >= _minTotalSupply) {
                    super._burn(_uniswapPair, burnMax);
                    _burnSwapPool = _burnSwapPool.sub(burnMax);
                }
            } else {
                if (totalCirculation().sub(_burnSwapPool) >= _minTotalSupply) {
                    super._burn(_uniswapPair, _burnSwapPool);
                    _burnSwapPool = 0;
                }
            }
            IPancakePair(_uniswapPair).sync();
        }
    }

    function swapAndLiquify(uint256 amount) private lockTheSwap {
        if (amount > 0) {
            swapTokensForTokens(amount);
            IERC20 USDT = IERC20(_usdtAddress);
            uint256 amountUsdt = USDT.balanceOf(address(this));
            uint256 amountUsdtEvery = amountUsdt.div(8);
            USDT.transfer(_lpRewardAddress, amountUsdtEvery.mul(3));
            IPancakePair(_lpRewardAddress).sync();
            USDT.transfer(_marketAddress, amountUsdtEvery);
            USDT.transfer(_teamAddress, amountUsdtEvery);
            USDT.transfer(_lpCoreAddress, amountUsdtEvery.mul(180).div(100));
            USDT.transfer(_lpCommunity, amountUsdtEvery.mul(45).div(100));
            USDT.transfer(_lpGoodAddress, amountUsdtEvery.mul(45).div(100));
            USDT.transfer(_lpMarketAddress, amountUsdtEvery.mul(30).div(100));
        }
    }

    function swapTokensForTokens(uint256 tokenAmount)
        private
        returns (uint256 balance)
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_usdtAddress);
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_distributor),
            block.timestamp
        );
        balance = _distributor.distribute(IERC20(_usdtAddress));
        emit SwapTokensForTokens(tokenAmount, path);
        return balance;
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        IERC20(_usdtAddress).approve(address(_uniswapV2Router), usdtAmount);
        emit AddLiquidity(tokenAmount, usdtAmount);
        _uniswapV2Router.addLiquidity(
            address(this),
            address(_usdtAddress),
            tokenAmount,
            usdtAmount,
            0,
            0,
            _teamAddress,
            block.timestamp + 1200
        );
    }

    event AddLiquidity(uint256 tokenAmount, uint256 ethAmount);
    event SwapTokensForTokens(uint256 amountIn, address[] path);
}
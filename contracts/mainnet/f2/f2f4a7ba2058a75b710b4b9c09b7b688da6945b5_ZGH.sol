/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

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
pragma solidity ^0.8.0;
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
pragma solidity ^0.8.1;
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
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
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
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
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
        }
        _totalSupply -= amount;
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
pragma solidity >=0.5.0;
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
pragma solidity >=0.5.0;
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
pragma solidity >=0.6.2;
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
pragma solidity >=0.6.2;
interface IPancakeRouter02 is IPancakeRouter01 {
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
pragma solidity ^0.8.0;
interface IRefer {
    function hasReferer(address account) external view returns (bool);
    function referer(address account) external view returns (address);
    function refereesCount(address account) external view returns (uint256);
    function referees(address account, uint256 index)
        external
        view
        returns (address);
}
pragma solidity ^0.8.0;
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
contract ZGH is ERC20, Ownable, Refer {
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
    FeeSet public buyFees =
        FeeSet({
            liquidityFee: 0,
            lpRewardFee: 30,
            marketFee: 20,
            teamFee: 0,
            burnFee: 0,
            inviterOneFee: 0,
            inviterTwoFee: 0,
            inviterThreeFee: 0
        });
    FeeSet public sellFees =
        FeeSet({
            liquidityFee: 0,
            lpRewardFee: 30,
            marketFee: 20,
            teamFee: 0,
            burnFee: 0,
            inviterOneFee: 0,
            inviterTwoFee: 0,
            inviterThreeFee: 0
        });
    FeeSet public transFees =
        FeeSet({
            liquidityFee: 0,
            lpRewardFee: 0,
            marketFee: 0,
            teamFee: 0,
            burnFee: 0,
            inviterOneFee: 0,
            inviterTwoFee: 0,
            inviterThreeFee: 0
        });
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isWalletLimitExempt;
    mapping(address => bool) public isSwapLimitExempt;
    mapping(address => bool) public isSwapExempt;
    mapping(address => bool) public isSwapPair;
    mapping(address => uint256) public receiveTotals;
    bool public isSwap = false;
    uint256 public swapMax;
    uint256 public walletHoldMax;
    uint256 public inviteBindMin;
    uint256 public inviteRewardMin;
    uint256 public minTotalSupply;
    uint256 private minimumTokensBeforeSwap = 1 * 10**(decimals() - 3);
    address payable public lpAddress;
    address payable public marketAddress;
    address payable public teamAddress;
    address public usdtAddress;
    address public uniswapPair;
    IPancakeRouter02 public uniswapV2Router;
    receive() external payable {}
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(IERC20 token) public onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    constructor() ERC20("ZGH", "ZGH") {
        usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        IPancakeRouter02 _swapRouter = IPancakeRouter02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapPair = IPancakeFactory(_swapRouter.factory()).createPair(
            address(this),
            address(usdtAddress)
        );
        uniswapV2Router = _swapRouter;
        isSwapPair[uniswapPair] = true;
        isSwapExempt[uniswapPair] = true;
        isSwapExempt[address(this)] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        swapMax = 1 * 10**decimals();
        inviteRewardMin = 50 * 10**decimals();
        inviteBindMin = 1 * 10**(decimals() - 1);
        lpAddress = payable(0xcbDa1c68BAC8201101d53326BaDC5B50906896D9);
        marketAddress = payable(0xbcaCf3357e985e846c4Af75cEDB2B2d30dcc7eAA);
        teamAddress = payable(0xbcaCf3357e985e846c4Af75cEDB2B2d30dcc7eAA);
        _mint(
            0x6a029F0Ef54E181657951E47680240dA34648fa1,
            400 * 10**decimals()
        );
        _mint(
            0xA5DCdBd84385992EfdD58918aa85E3B8362202FC,
            400 * 10**decimals()
        );
        _mint(
            0xa66fF04e14DF79A95d9B81D5462c8675aC5E1d41,
            199 * 10**decimals()
        );
    }
    function setLpAddress(address add) public onlyOwner {
        lpAddress = payable(add);
    }
    function setMarketAddress(address add) public onlyOwner {
        marketAddress = payable(add);
    }
    function setTeamAddress(address add) public onlyOwner {
        teamAddress = payable(add);
    }
    function setIsFeeExempt(address account, bool newValue) public onlyOwner {
        isFeeExempt[account] = newValue;
    }
    function setIsWalletLimitExempt(address account, bool newValue)
        public
        onlyOwner
    {
        isWalletLimitExempt[account] = newValue;
    }
    function setIsSwapLimitExempt(address account, bool newValue)
        public
        onlyOwner
    {
        isSwapLimitExempt[account] = newValue;
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
    function setIsSwap(bool swap) public onlyOwner {
        isSwap = swap;
    }
    function setSwapMax(uint256 amount) public onlyOwner {
        swapMax = amount;
    }
    function setWalletHoldMax(uint256 amount) public onlyOwner {
        walletHoldMax = amount;
    }
    function setInviteBindMin(uint256 amount) public onlyOwner {
        inviteBindMin = amount;
    }
    function setInviteRewardMin(uint256 amount) public onlyOwner {
        inviteRewardMin = amount;
    }
    function setMinimumTokensBeforeSwap(uint256 amount) public onlyOwner {
        minimumTokensBeforeSwap = amount;
    }
    function setSwapPair(address pair) public onlyOwner {
        isSwapPair[uniswapPair] = false;
        uniswapPair = pair;
        isSwapPair[pair] = true;
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
            buyFees = temp;
        } else if (feeType == 1) {
            sellFees = temp;
        } else if (feeType == 2) {
            transFees = temp;
        }
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (isSwapPair[sender]) {
            require(isSwap || isSwapExempt[recipient], "Fail: NoSwap");
            require(
                swapMax == 0 ||
                    isSwapLimitExempt[recipient] ||
                    amount <= swapMax,
                "Fail: OverSwapMax"
            );
            uint256 amountFainel = takeFee(sender, recipient, amount, 0);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
                receiveTotals[recipient] = receiveTotals[recipient].add(
                    amountFainel
                );
            }
        } else if (isSwapPair[recipient]) {
            require(isSwap || isSwapExempt[sender], "Fail: NoSwap");
            require(
                amount <= balanceOf(sender).mul(99).div(100),
                "Fail: NotAllSwap"
            );
            uint256 amountFainel = takeFee(sender, recipient, amount, 1);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
                receiveTotals[recipient] = receiveTotals[recipient].add(
                    amountFainel
                );
            }
        } else {
            uint256 amountFainel = takeFee(sender, recipient, amount, 2);
            if (amountFainel > 0) {
                super._transfer(sender, recipient, amountFainel);
                receiveTotals[recipient] = receiveTotals[recipient].add(
                    amountFainel
                );
            }
            if (
                (!hasReferer(recipient)) &&
                (sender != recipient) &&
                (sender != address(0)) &&
                (recipient != address(0)) &&
                (amount >= inviteBindMin) &&
                refereesCount(recipient) == 0
            ) {
                _setReferer(sender, recipient);
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
                ? buyFees
                : (feeType == 1 ? sellFees : transFees);
            uint256 amountFee = amount.mul(10).div(100);
            amountFainel = amount.mul(90).div(100);
            uint256 amountFeeSupply = amountFee;
            {
                uint256 fee = amountFee.mul(feeSet.liquidityFee).div(100);
                if (fee > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, lpAddress, fee);
                    amountFeeSupply = amountFeeSupply.sub(fee);
                }
            }
            {
                uint256 feeLP = amountFee.mul(feeSet.lpRewardFee).div(100);
                if (feeLP > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, uniswapPair, feeLP);
                    amountFeeSupply = amountFeeSupply.sub(feeLP);
                }
            }
            {
                uint256 feeMarket = amountFee.mul(feeSet.marketFee).div(100);
                if (feeMarket > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, marketAddress, feeMarket);
                    amountFeeSupply = amountFeeSupply.sub(feeMarket);
                }
            }
            {
                uint256 feeTeam = amountFee.mul(feeSet.teamFee).div(100);
                if (feeTeam > 0 && amountFeeSupply > 0) {
                    super._transfer(sender, teamAddress, feeTeam);
                    amountFeeSupply = amountFeeSupply.sub(feeTeam);
                }
            }
            {
                uint256 feeBurn = amountFee.mul(feeSet.burnFee).div(100);
                if (
                    feeBurn > 0 &&
                    amountFeeSupply > 0 &&
                    totalSupply().sub(feeBurn) >= minTotalSupply
                ) {
                    super._burn(sender, feeBurn);
                    amountFeeSupply = amountFeeSupply.sub(feeBurn);
                }
            }
            {
                uint256[] memory feeInvites = new uint256[](8);
                feeInvites[0] = amountFee.mul(feeSet.inviterOneFee).div(100);
                feeInvites[1] = amountFee.mul(feeSet.inviterTwoFee).div(100);
                feeInvites[2] = amountFee.mul(feeSet.inviterThreeFee).div(100);
                feeInvites[3] = amountFee.mul(feeSet.inviterThreeFee).div(100);
                feeInvites[4] = amountFee.mul(feeSet.inviterThreeFee).div(100);
                feeInvites[5] = amountFee.mul(feeSet.inviterThreeFee).div(100);
                feeInvites[6] = amountFee.mul(feeSet.inviterThreeFee).div(100);
                feeInvites[7] = amountFee.mul(feeSet.inviterThreeFee).div(100);
                address _referer = !isSwapPair[sender] ? sender : recipient;
                uint256 amountInviteBurn;
                for (uint256 i = 0; i < feeInvites.length; i++) {
                    if (feeInvites[i] > 0 && amountFeeSupply > 0) {
                        if (
                            hasReferer(_referer) &&
                            balanceOf(referer(_referer)) > inviteRewardMin
                        ) {
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
                    if (totalSupply().sub(amountInviteBurn) >= minTotalSupply) {
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
}
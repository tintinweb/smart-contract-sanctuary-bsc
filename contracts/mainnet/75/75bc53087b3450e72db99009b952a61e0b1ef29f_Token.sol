/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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
    mapping(address => bool) private _adminList;

    event LogOwnerChanged(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
        _adminList[_msgSender()] = true;
    }

    modifier onlyOwner() {
        require(Owner() == _msgSender(), "!owner");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(), "!admin");
        _;
    }

    function isAdmin() public view virtual returns (bool) {
        return _adminList[_msgSender()];
    }

    function setAdminList(address newAdmin, bool _status)
        public
        virtual
        onlyOwner
    {
        _adminList[newAdmin] = _status;
    }

    function Owner() public view virtual returns (address) {
        return _owner;
    }

    function isOwner() public view virtual returns (bool) {
        return Owner() == _msgSender();
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "!address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit LogOwnerChanged(oldOwner, newOwner);
    }
}

abstract contract WhiteList is Ownable {
    mapping(address => bool) private _whiteList;
    mapping(address => bool) private _blackList;

    constructor() {}

    event LogWhiteListChanged(address indexed _user, bool _status);
    event LogBlackListChanged(address indexed _user, bool _status);

    modifier onlyWhiteList() {
        require(_whiteList[_msgSender()], "White list");
        _;
    }

    function isWhiteListed(address _maker) public view returns (bool) {
        return _whiteList[_maker];
    }

    function setWhiteList(address _evilUser, bool _status)
        public
        virtual
        onlyAdmin
        returns (bool)
    {
        _whiteList[_evilUser] = _status;
        emit LogWhiteListChanged(_evilUser, _status);
        return _whiteList[_evilUser];
    }

    function isBlackListed(address _maker) public view returns (bool) {
        return _blackList[_maker];
    }

    function setBlackList(address _evilUser, bool _status)
        public
        virtual
        onlyAdmin
        returns (bool)
    {
        _blackList[_evilUser] = _status;
        emit LogBlackListChanged(_evilUser, _status);
        return _blackList[_evilUser];
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "!from");
        require(recipient != address(0), "!to");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

    function _destroy(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: destroy from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(
            accountBalance >= amount,
            "ERC20: destroy amount exceeds balance"
        );
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _balances[address(0)] += amount;

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

library ECDSA {
    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }
}

contract ECDSAMock {
    using ECDSA for bytes32;

    function recover(bytes32 hash, bytes memory signature)
        public
        pure
        returns (address)
    {
        return hash.recover(signature);
    }

    function Signer(
        address _user,
        uint256 _id,
        uint256 _amount,
        uint256 _timestamp,
        bytes memory signature
    ) public pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(_user, _id, _amount, _timestamp)
        );
        return recover(hash, signature);
    }
}

contract Token is ERC20, Ownable, WhiteList, ECDSAMock {
    using SafeMath for uint256;

    event Inviter(address indexed addr, address indexed inviter);
    event InviterReward(
        address sender,
        address user,
        address inviter,
        uint256 amount
    );

    event Log(
        address indexed addr1,
        address indexed addr2,
        uint256 lp1,
        uint256 amount1,
        uint256 amount2,
        uint256 lp2,
        uint256 amount21,
        uint256 amount22
    );

    event Reward(uint256 amount);
    event Rewarded(address addr, uint256 id, uint256 amount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    address public uniswapV2Pair;
    IUniswapV2Router02 public immutable uniswapV2Router;

    uint256 public _burnRatio;
    uint256 public _inviteRatio;
    uint256 public _liquidRatio;
    uint256 public _rewardRatio;
    uint256 public _totalFees;
    uint256 public _liquidAmount;
    uint256 private validTime;
    uint256 public _startTime = 0;
    uint256 private _blackTime = 0;

    uint256 public _burnLeft;
    uint256 private _rewardTokensAtAmount;
    address public _defaultInviter;

    address private _usdtReceiver;
    bool private _swapping = false;
    bool private _swappingEnabled = false;
    bool private _rewardStatus = true;

    IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => address) public _inviter;

    mapping(address => uint256) public rewards;
    mapping(bytes => bool) public signatures;
    mapping(address => bool) public signers;

    constructor(address owner) ERC20("spacedogequeen2.0", "spacedogequeen2.0", 18) {
        _mint(owner, 1000000000000 * 10**decimals());
        _rewardTokensAtAmount = 10**18;
        _burnLeft = 1000000000000 * 10**decimals();

        _burnRatio = 0;
        _inviteRatio = 200;
        _liquidRatio = 100;
        _rewardRatio = 200;
        _liquidAmount = 0;
        validTime = 180;
        _totalFees = _burnRatio + _inviteRatio + _liquidRatio + _rewardRatio;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(
                address(this),
                address(0x55d398326f99059fF775485246999027B3197955)
            );

        uniswapV2Router = _uniswapV2Router;

        setAdminList(owner, true);
        if (owner != _msgSender()) {
            setAdminList(_msgSender(), true);
        }
        setAdminList(address(this), true);
        setAdminList(uniswapV2Pair, true);

        excludeFromFees(owner, true);
        excludeFromFees(address(this), true);

        setInviter(owner, owner);

        _defaultInviter = owner;
        _usdtReceiver = address(this);
    }

    receive() external payable {}

    function setRewardRatio(uint256 ratio) external onlyAdmin {
        require(_rewardRatio != ratio, "TOKEN: Repeat Setting");
        _rewardRatio = ratio;
        _totalFees = _burnRatio + _inviteRatio + _liquidRatio + _rewardRatio;
    }

    function setBurnRatio(uint256 ratio) external onlyAdmin {
        require(_burnRatio != ratio, "TOKEN: Repeat Setting");
        _burnRatio = ratio;
        _totalFees = _burnRatio + _inviteRatio + _liquidRatio + _rewardRatio;
    }

    function setInviteRatio(uint256 ratio) external onlyAdmin {
        require(_inviteRatio != ratio, "TOKEN: Repeat Setting");
        _inviteRatio = ratio;
        _totalFees = _burnRatio + _inviteRatio + _liquidRatio + _rewardRatio;
    }

    function setLiquidRatio(uint256 ratio) external onlyAdmin {
        require(_liquidRatio != ratio, "TOKEN: Repeat Setting");
        _liquidRatio = ratio;
        _totalFees = _burnRatio + _inviteRatio + _liquidRatio + _rewardRatio;
    }

    function setBurnLeft(uint256 left) external onlyAdmin {
        require(_burnLeft != left, "TOKEN: Repeat Setting");
        _burnLeft = left;
    }

    function setValidTime(uint256 _time) external onlyAdmin returns (uint256) {
        require(validTime != _time, "TOKEN: Repeat Setting");
        validTime = _time;
        return validTime;
    }

    function setStartTime(uint256 _time, uint256 _step) external onlyAdmin {
        require(_startTime != _time, "TOKEN: Repeat Setting");

        _startTime = _time;
        _blackTime = _step;
    }

    function setTempAddress(address _addr)
        external
        onlyAdmin
        returns (address)
    {
        require(_usdtReceiver != _addr, "TOKEN: Repeat Setting");
        _usdtReceiver = _addr;
        return _addr;
    }

    function setSigner(address _addr, bool _flag)
        public
        onlyAdmin
        returns (bool)
    {
        signers[_addr] = _flag;
        return signers[_addr];
    }

    function excludeFromFees(address account, bool excluded) public onlyAdmin {
        require(
            _isExcludedFromFees[account] != excluded,
            "TOKEN: Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyAdmin {
        require(_rewardTokensAtAmount != amount, "TOKEN: Repeat Setting");
        _rewardTokensAtAmount = amount;
    }

    function setSwapStatus(bool status) external onlyAdmin {
        require(_swappingEnabled != status, "TOKEN: Repeat Setting");
        _swappingEnabled = status;
    }

    function setDefaultInviter(address addr) external onlyAdmin {
        _defaultInviter = addr;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 actualAmount = amount;

        require(
            !isBlackListed(sender),
            "ERC20: transfer from the blacklist address"
        );

        if (sender == uniswapV2Pair) {
            require(
                block.timestamp >= _startTime && _startTime > 0,
                "ERC20: waitting for start ..."
            );
            if (block.timestamp - _startTime <= _blackTime) {
                setBlackList(recipient, true);
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = (contractTokenBalance >= _liquidAmount &&
            _liquidAmount >= _rewardTokensAtAmount);
        if (
            canSwap && !_swapping && _swappingEnabled && sender != uniswapV2Pair
        ) {
            _swapping = true;
            swapAndLiquify(_liquidAmount);
            _liquidAmount = 0;
            _swapping = false;
        }

        bool takeFee = !_swapping;
        if (_isExcludedFromFees[sender] || _isExcludedFromFees[recipient]) {
            takeFee = false;
        }

        if (takeFee && sender != uniswapV2Pair && recipient != uniswapV2Pair) {
            takeFee = false;
        }

        uint256 burn = 0;
        uint256 ifee = 0;
        uint256 tfee = 0;
        uint256 fees = 0;
        address user = recipient == uniswapV2Pair ? sender : recipient;
        address iaddr = _inviter[user];

        if (takeFee && _totalFees > 0) {
            tfee = actualAmount.mul(_totalFees).div(10000);

            burn = actualAmount.mul(_burnRatio).div(10000);
            if (burn > 0 && totalSupply() > _burnLeft) {
                if (burn > totalSupply() - _burnLeft) {
                    burn = totalSupply() - _burnLeft;
                }
                super._burn(sender, burn);
            } else {
                burn = 0;
            }

            ifee = actualAmount.mul(_inviteRatio).div(10000);
            if (ifee > 0 && iaddr != address(0) && iaddr != sender) {
                super._transfer(sender, iaddr, ifee);
                emit InviterReward(tx.origin, user, iaddr, ifee);
            } else {
                ifee = 0;
            }

            if (_liquidRatio > 0) {
                _liquidAmount += actualAmount.mul(_liquidRatio).div(10000);
            }

            fees = tfee.sub(burn).sub(ifee);
            super._transfer(sender, address(this), fees);

            actualAmount = actualAmount.sub(tfee);
        }

        super._transfer(sender, recipient, actualAmount);
        setInviter(recipient, sender);

        updateLiquidity(sender, recipient);
    }

    function updateLiquidity(address sender, address recipient) internal {
        uint256 lps = IERC20(uniswapV2Pair).balanceOf(sender);
        uint256 lpr = IERC20(uniswapV2Pair).balanceOf(recipient);
        uint256 tol = IERC20(uniswapV2Pair).totalSupply();
        if (tol > 0) {
            uint256 balance0 = balanceOf(uniswapV2Pair);
            uint256 balance1 = USDT.balanceOf(uniswapV2Pair);

            uint256 amount0 = lps.mul(balance0) / tol; // using balances ensures pro-rata distribution
            uint256 amount1 = lps.mul(balance1) / tol; // using balances ensures pro-rata distribution

            uint256 amountr0 = lpr.mul(balance0) / tol; // using balances ensures pro-rata distribution
            uint256 amountr1 = lpr.mul(balance1) / tol; // using balances ensures pro-rata distribution

            emit Log(
                sender,
                recipient,
                lps,
                amount0,
                amount1,
                lpr,
                amountr0,
                amountr1
            );
        }
    }

    function setInviter(address addr, address inviter) internal {
        if (addr != uniswapV2Pair && _inviter[addr] == address(0)) {
            address iaddr = inviter == uniswapV2Pair
                ? _defaultInviter
                : inviter;

            _inviter[addr] = iaddr;
            emit Inviter(addr, iaddr);
        }
    }

    function withdraw(
        address tk,
        address sender,
        uint256 amount
    ) external onlyAdmin returns (uint256) {
        uint256 reward = amount;
        if (reward > IERC20(tk).balanceOf(address(this))) {
            reward = IERC20(tk).balanceOf(address(this));
        }

        if (reward > 0) {
            IERC20(tk).transfer(sender, reward);
        }
        return reward;
    }

    function withdrawBNB(address sender, uint256 amount)
        external
        onlyAdmin
        returns (uint256)
    {
        uint256 reward = amount;
        if (reward > address(this).balance) {
            reward = address(this).balance;
        }

        if (reward > 0) {
            payable(sender).transfer(reward);
        }
        return reward;
    }

    ////////////////////////////////////////////////////////////////////////////////
    function getReward(
        uint256 id,
        uint256 amount,
        uint256 timestamp,
        bytes memory signature
    ) external {
        address addr = msg.sender;
        uint256 tokenBalance = balanceOf(address(this));
        require(amount > 0 && id > 0, "data error");
        require(tokenBalance >= amount, "Balance is not enough");
        require(!signatures[signature], "Duplicate signature");
        require(
            signers[Signer(addr, id, amount, timestamp, signature)],
            "Invalid signature"
        );

        require(block.timestamp < timestamp + validTime, "Invalid timestamp");

        super._transfer(address(this), addr, amount);
        rewards[addr] += amount;
        signatures[signature] = true;

        emit Rewarded(addr, id, amount);
    }

    function swapAndLiquify(uint256 tokens) private {
        _approve(address(this), address(uniswapV2Router), tokens);

        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256[] memory amounts = swapTokenForUToken(_usdtReceiver, half);

        if (_usdtReceiver != address(this)) {
            USDT.transferFrom(_usdtReceiver, address(this), amounts[1]);
        }

        uint256 liquidity = addLiquidity(otherHalf, amounts[1]);

        emit SwapAndLiquify(otherHalf, amounts[1], liquidity);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount)
        private
        returns (uint256)
    {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        USDT.approve(address(uniswapV2Router), ethAmount);

        uint256 amountA = 0;
        uint256 amountB = 0;
        uint256 liquidity = 0;
        (amountA, amountB, liquidity) = uniswapV2Router.addLiquidity(
            address(this),
            address(USDT),
            tokenAmount,
            ethAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        return liquidity;
    }

    function swapTokenForUToken(address receiver, uint256 tAmount)
        private
        returns (uint256[] memory amounts)
    {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);

        // make the swap
        return
            uniswapV2Router.swapExactTokensForTokens(
                tAmount,
                0, // accept any amount of token
                path,
                receiver,
                block.timestamp
            );
    }
}
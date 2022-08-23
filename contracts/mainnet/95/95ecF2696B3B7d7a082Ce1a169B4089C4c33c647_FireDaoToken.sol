/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

interface IFireBPool {

    function balanceOf(address _account) external view returns (uint256);

    function deposit(address _account, uint256 _amountFdt) external;

    function withdraw(address _account, uint256 _amountFdt) external;

    function sync() external;

    function getReserves() external view 
        returns (
            uint256 _reserveFdt,
            uint256 _reserveUsdt,
            uint256 _blockTimestampLast
        );

}

interface IStakeBonusPool {

    function onRewardsReceived(uint256 _amount) external;

    function addUserBalance(address _account, uint256 _amount) external;

    function withdraw() external;
}

interface IUserWallet {

    function onTokenBought(address _account, uint256 _amountInUsdt) external;

    function onNodeSold(address _account, uint256 _amountInUsdt) external;

    function vaultBalanceOf(address _account) external view returns (uint256);

    function vaultTotalReceivesOf(address _account) external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function withdrawalLimitOf(address _account) external view returns (uint256);

    function totalReceivesOf(address _account) external view returns (uint256);

    function withdraw() external;
}

contract FireDaoToken is ERC20, AccessControl {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public constant PRECISION = 1000;
    address public constant HOLE = address(0x000000000000000000000000000000000000dEaD);

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    address public mintWallet;
    address public mintLiquidity;
    address public mintLab;
    address public mintCapital;
    address public mintFoundation;
    address public mintVault1;
    address public mintVault2;
    address public mintDao;
    address public mintWeb3;
    address public mintDex;
    address public mintNft;
    address public mintShop;
    address public mintMetaverse;
    address public mintSocialFi;
    address public mintFireWallet;

    address public bpool;
    address public sbp;
    address public wallet;
    address public robot;

    IERC20 public usdt;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public router;

    uint256 public presellEndTime;
    mapping(address => bool) private presellParticipator;

    constructor(
        address _usdt, 
        address _router, 
        uint256 _presellEndTime
    ) ERC20("FireDaoToken", "FDT") {
        _setupRole(ROLE_ADMIN, _msgSender());

        presellEndTime = _presellEndTime;

        usdt = IERC20(_usdt);
        address _factory = IUniswapV2Router02(_router).factory();
        address _pair = IUniswapV2Factory(_factory).createPair(address(this), _usdt);
        pair = IUniswapV2Pair(_pair);
        router = IUniswapV2Router02(_router);

        presellParticipator[_pair] = true;
        presellParticipator[_router] = true;
        presellParticipator[_msgSender()] = true;
    }

    function setMintWallet(address _addr) public onlyRole(ROLE_ADMIN) {
        mintWallet = _addr;
    }

    function setMintLiquidity(address _addr) public onlyRole(ROLE_ADMIN) {
        mintLiquidity = _addr;
    }

    function setMintLab(address _addr) public onlyRole(ROLE_ADMIN) {
        mintLab = _addr;
    }

    function setMintCapital(address _addr) public onlyRole(ROLE_ADMIN) {
        mintCapital = _addr;
    }

    function setMintFoundation(address _addr) public onlyRole(ROLE_ADMIN) {
        mintFoundation = _addr;
    }

    function setMintVault1(address _addr) public onlyRole(ROLE_ADMIN) {
        mintVault1 = _addr;
    }

    function setMintVault2(address _addr) public onlyRole(ROLE_ADMIN) {
        mintVault2 = _addr;
    }

    function setMintDao(address _addr) public onlyRole(ROLE_ADMIN) {
        mintDao = _addr;
    }

    function setMintWeb3(address _addr) public onlyRole(ROLE_ADMIN) {
        mintWeb3 = _addr;
    }

    function setMintDex(address _addr) public onlyRole(ROLE_ADMIN) {
        mintDex = _addr;
    }

    function setMintNft(address _addr) public onlyRole(ROLE_ADMIN) {
        mintNft = _addr;
    }

    function setMintShop(address _addr) public onlyRole(ROLE_ADMIN) {
        mintShop = _addr;
    }

    function setMintMetaverse(address _addr) public onlyRole(ROLE_ADMIN) {
        mintMetaverse = _addr;
    }

    function setMintSocialFi(address _addr) public onlyRole(ROLE_ADMIN) {
        mintSocialFi = _addr;
    }

    function setMintFireWallet(address _addr) public onlyRole(ROLE_ADMIN) {
        mintFireWallet = _addr;
    }

    function mintOnce() public onlyRole(ROLE_ADMIN) {
        require(totalSupply() == 0, "Mint: already mint");

        uint256 _totalMint = 210000000 * (10**decimals());
        _mint(mintWallet, _totalMint.mul(730).div(PRECISION));
        _mint(mintLiquidity, _totalMint.mul(10).div(PRECISION));
        _mint(mintLab, _totalMint.mul(30).div(PRECISION));
        _mint(mintCapital, _totalMint.mul(30).div(PRECISION));
        _mint(mintFoundation, _totalMint.mul(20).div(PRECISION));
        _mint(mintVault1, _totalMint.mul(10).div(PRECISION));
        _mint(mintVault2, _totalMint.mul(10).div(PRECISION));
        _mint(mintDao, _totalMint.mul(20).div(PRECISION));
        _mint(mintWeb3, _totalMint.mul(20).div(PRECISION));
        _mint(mintDex, _totalMint.mul(20).div(PRECISION));
        _mint(mintNft, _totalMint.mul(20).div(PRECISION));
        _mint(mintShop, _totalMint.mul(20).div(PRECISION));
        _mint(mintMetaverse, _totalMint.mul(20).div(PRECISION));
        _mint(mintSocialFi, _totalMint.mul(20).div(PRECISION));
        _mint(mintFireWallet, _totalMint.mul(20).div(PRECISION));
    }

    function initialize(address _bpool, address _sbp, address _wallet, address _robot) public onlyRole(ROLE_ADMIN) {
        bpool = _bpool;
        sbp = _sbp;
        wallet = _wallet;
        robot = _robot;

        presellParticipator[_bpool] = true;
        presellParticipator[_sbp] = true;
        presellParticipator[_wallet] = true;
        presellParticipator[_robot] = true;
    }

    function _transfer(address _from, address _to, uint256 _amount) override internal {
        require(_from != address(0),  "Transfer: _from is zero");
        require(_to != address(0), "Transfer: _to is zero");

        if (_from == mintLiquidity) {
            _internalTransfer(_from, _to, _amount);
            return;
        }

        if (_from == bpool || _to == bpool) {
            _internalTransfer(_from, _to, _amount);
            return;
        }

        if (_from == sbp || _to == sbp) {
            _internalTransfer(_from, _to, _amount);
            return;
        }

        if (_from == wallet || _to == wallet) {
            _internalTransfer(_from, _to, _amount);
            return;
        }

        if (_from == robot || _to == robot) {
            _internalTransfer(_from, _to, _amount);
            return;
        }

        if (_from == address(this) || _to == address(this)) {
            _internalTransfer(_from, _to, _amount);
            return;
        }

        _doPresellCheck(_from, _to, _amount);

        _doBuyAmountCheck(_from, _to, _amount);

        uint256 _bpoolUsed = _doBPoolSlippage(_from, _to, _amount);

        uint256 _sbpUsed = _doSbpSlippage(_from, _to, _amount);

        _internalTransfer(_from, _to, _amount.sub(_bpoolUsed).sub(_sbpUsed));
    }

    function _internalTransfer(address _from, address _to, uint256 _amount) private {
        super._transfer(_from, _to, _amount);
    }

    function setParticipator(address _addr, bool _state) public onlyRole(ROLE_ADMIN) {
        presellParticipator[_addr] = _state;
    }

    function batchSetParticipator(address[] calldata _addrs, bool _state) public onlyRole(ROLE_ADMIN) {
        for (uint256 i = 0; i < _addrs.length; i ++) {
            presellParticipator[_addrs[i]] = _state;
        }
    }

    function _doPresellCheck(address _from, address _to, uint256 _amount) private view {
        if (_from == address(pair) && block.timestamp < presellEndTime) {
            require(presellParticipator[_to], "Transfer: not participators");

            uint256 _cBalance = balanceOf(_to);
            uint256 _fBalance = _cBalance.add(_amount);
            uint256 _balanceInUsdt = getTokenPrice(address(this), _fBalance);
            require(_balanceInUsdt <= (100 * 1e18), "Transfer: only hold 100U at presell");
        }
    }

    function _doBuyAmountCheck(address _from, address, uint256 _amount) private view  {
        if (_from == address(pair)) {
            uint256 _price = getTokenPrice(address(this), _amount);
            require(_price <= (500 * 1e18), "Transfer: buy amount limitation");
        }        
    }

    function _doBPoolSlippage(address _from, address _to, uint256 _amount) private returns (uint256) {
        if (_from == address(pair)) {
            return _doBPoolBuySlippage(_from, _to, _amount);
        }

        if (_to == address(pair)) {
            return _doBPoolSellSlippage(_from, _to, _amount);
        }

        return _doBPoolTransferSlippage(_from, _to, _amount);
    }
    
    function _doBPoolBuySlippage(address _from, address _to, uint256 _amount) private returns (uint256) {
        uint256 _bpoolUsdtAmount = _amount.mul(60).div(PRECISION);
        uint256 _bpoolTokenAmount = _amount.mul(30).div(PRECISION);
        uint256 _bpoolAmount = _bpoolUsdtAmount.add(_bpoolTokenAmount);

        _internalTransfer(_from, address(this), _bpoolAmount);
        _internalTransfer(address(this), robot, _bpoolUsdtAmount);
        _internalTransfer(address(this), bpool, _bpoolTokenAmount);

        IFireBPool(bpool).deposit(_to, _bpoolTokenAmount);

        return _bpoolAmount;
    }

    function _doBPoolSellSlippage(address _from, address, uint256 _amount) private returns (uint256) {
        uint256 _bpoolUsdtAmount = _amount.mul(60).div(PRECISION);
        uint256 _bpoolTokenAmount = _amount.mul(30).div(PRECISION);
        uint256 _bpoolAmount = _bpoolUsdtAmount.add(_bpoolTokenAmount);

        _internalTransfer(_from, address(this), _bpoolAmount);
        _internalTransfer(address(this), robot, _bpoolUsdtAmount);
        _internalTransfer(address(this), HOLE, _bpoolTokenAmount);

        IFireBPool(bpool).withdraw(_from, _bpoolTokenAmount);

        return _bpoolAmount;
    }

    function _doBPoolTransferSlippage(address _from, address, uint256 _amount) private returns (uint256) {
        uint256 _withdrawAmount = _amount.mul(30).div(PRECISION);
        IFireBPool(bpool).withdraw(_from, _withdrawAmount);
        return 0;
    }

    function _doSbpSlippage(address _from, address _to, uint256 _amount) private returns (uint256) {
        if (_from == address(pair) || _to == address(pair)) {
            uint256 _sbpAmount = _amount.mul(10).div(PRECISION);
            IStakeBonusPool(sbp).onRewardsReceived(_sbpAmount);

            _internalTransfer(_from, address(this), _sbpAmount);
            _internalTransfer(address(this), sbp, _sbpAmount);

            if (_from == address(pair)) {
                uint256 _amountInUsdt = getTokenPrice(address(this), _amount);
                IUserWallet(wallet).onTokenBought(_to, _amountInUsdt);
            }

            return _sbpAmount;
        }
        return 0;
    }

    function getTokenPrice(address _token, uint256 _amount) public view returns (uint256) {
        if (_amount == 0) {
            return 0;
        }

        uint256 _token0Reserves;
        uint256 _token1Reserves;
        if (pair.token0() == _token) {
            (_token0Reserves, _token1Reserves, ) = pair.getReserves();
        } else {
            (_token1Reserves, _token0Reserves, ) = pair.getReserves();
        }
        return router.quote(_amount, _token0Reserves, _token1Reserves);
    }
}
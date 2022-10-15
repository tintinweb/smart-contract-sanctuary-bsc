/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-14
*/

// SPDX-License-Identifier: MIT

/** 

$RYZR

https://ryzr.app

https://t.me/RyzrSwap

**/


pragma solidity 0.8.17;

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     */
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

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Contract holds an insufficient balance and so cannot perform sendValue."
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCall(
                target,
                data,
                "Address: low-level call failed. Target must be a contract; calling targit with data must not revert."
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
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
                "Address: low-level call with value failed. The calling contract must have an ETH balance of at least `value`. the called Solidity function must be `payable`."
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an admin) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the admin account will be the one that deploys the contract. This
 * can later be changed with {transferAdminRole}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyAdmin`, which can be applied to your functions to restrict their use to
 * the admin.
 */
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an admin) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the admin account will be the one that deploys the contract. This
 * can later be changed with {transferAdminRole}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyAdmin`, which can be applied to your functions to restrict their use to
 * the admin.
 */
abstract contract Administration is Context {
    address private _admin;

    event AdminRoleTransferred(
        address indexed previousAdmin,
        address indexed newAdmin
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial admin.
     */
    constructor() {
        address msgSender = _msgSender();
        _admin = msgSender;
        emit AdminRoleTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current admin.
     */
    function admin() public view virtual returns (address) {
        return _admin;
    }

    /**
     * @dev Throws error if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(
            admin() == _msgSender(),
            "Administration: caller is not the admin"
        );
        _;
    }

    /**
     * @dev Leaves the contract without admin. It will not be possible to call
     * `onlyAdmin` functions anymore. Can only be called by the current admin.
     *
     * NOTE: Renouncing admin role will leave the contract without an admin,
     * thereby removing any functionality that is only available to the admin.
     */
    function renounceAdminRole() public virtual onlyAdmin {
        emit AdminRoleTransferred(_admin, address(0));
        _admin = address(0);
    }

    /**
     * @dev Transfers admin role of the contract to a new account (`newAdmin`).
     * Can only be called by the current admin.
     */
    function transferAdminRole(address newAdmin) public virtual onlyAdmin {
        require(
            newAdmin != address(0),
            "Administration: new admin is the zero address"
        );
        emit AdminRoleTransferred(_admin, newAdmin);
        _admin = newAdmin;
    }
}

contract RYZR is IERC20, Administration {
    using Address for address;

    // address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // TESTNET
    // address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // MAINNET
    address WBNB;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Ryzr";
    string constant _symbol = "RYZR";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100000000 * (10**_decimals); // 100 mil tokens

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => uint256) lastTransaction;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) liquidityCreator;

    uint256 marketingFee = 500; // 5.0%
    uint256 totalFee = marketingFee; // 5.0%
    uint256 feeDenominator = 10000;

    address payable public marketingFeeReceiver;

    IDEXRouter public router;
    // Mainnet PancakeSwap: 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // Testnet PancakeSwap: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    mapping(address => bool) liquidityPools;

    address public pair;

    uint256 public launchedAt;
    uint256 public launchedTime;
    uint256 public deadBlocks;
    bool public tradingOpen = false;
    uint256 public unlockTime = 9999999999;

    bool public swapEnabled = false;
    bool processEnabled = true;
    uint256 public swapThreshold = _totalSupply / 10000;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address routerAddress) {
        router = IDEXRouter(routerAddress);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        liquidityPools[pair] = true;
        _allowances[admin()][routerAddress] = type(uint256).max;
        _allowances[address(this)][routerAddress] = type(uint256).max;

        isFeeExempt[admin()] = true;
        liquidityCreator[admin()] = true;

        marketingFeeReceiver = payable(admin());

        _balances[admin()] = _totalSupply;
        emit Transfer(address(0), admin(), _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function openTrading(uint256 _deadBlocks) external onlyAdmin {
        require(!tradingOpen && _deadBlocks < 7);
        deadBlocks = _deadBlocks;
        unlockTime = block.timestamp;
        tradingOpen = true;
        launchedAt = block.number;
    }

    function enableTrading(uint256 _unlockTime) external onlyAdmin {
        require(!tradingOpen && _unlockTime > block.timestamp);
        deadBlocks = 0;
        unlockTime = block.timestamp;
        tradingOpen = true;
        launchedAt = block.number;
    }

    function setFee(uint256 _marketingFee) external onlyAdmin {
        require(_marketingFee <= 500, "Fee amount must be 500 (5%) or less");
        marketingFee = _marketingFee;
        emit UpdatedFees(
            "Marketing Fee Updated",
            [
                Log(
                    concatenate(
                        "New Fee Amount: ",
                        toString(abi.encodePacked(_marketingFee))
                    ),
                    1
                )
            ]
        );
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(_balances[sender] >= amount, "Insufficient balance");
        if (block.timestamp < unlockTime) {
            require(
                isFeeExempt[sender] || isFeeExempt[recipient],
                "Trading not open yet."
            );
        }
        if (!launched() && liquidityPools[recipient]) {
            require(liquidityCreator[sender], "Liquidity not added yet.");
            launch();
        }
        if (!tradingOpen) {
            require(
                liquidityCreator[sender] || liquidityCreator[recipient],
                "Trading not open yet."
            );
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = shouldTakeFee(sender)
            ? takeFee(sender, recipient, amount)
            : amount;

        if (shouldSwapBack(recipient)) {
            if (amount > 0) swapBack(amount);
        }

        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        launchedTime = block.timestamp;
        swapEnabled = true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if (launchedAt + deadBlocks >= block.number) {
            return feeDenominator - 1;
        }
        if (selling) {
            return totalFee;
        }
        return totalFee;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeAmount = (amount * getTotalFee(liquidityPools[recipient])) /
            feeDenominator; // e.g. feeAmount = 100 *

        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
    }

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return
            !liquidityPools[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            liquidityPools[recipient] &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack(uint256 amount) internal swapping {
        uint256 amountToSwap = amount < swapThreshold ? amount : swapThreshold;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance - balanceBefore;
        uint256 totalBNBFee = totalFee;
        uint256 amountBNBMarketing = (amountBNB * marketingFee) / totalBNBFee;

        marketingFeeReceiver.transfer(amountBNBMarketing);

        emit FundsDistributed(amountBNBMarketing);
    }

    function addLiquidityPool(address lp, bool isPool) external onlyAdmin {
        require(lp != pair, "Can't alter current liquidity pair");
        liquidityPools[lp] = isPool;
        emit UpdatedSettings(
            isPool ? "Liquidity Pool Enabled" : "Liquidity Pool Disabled",
            [Log(toString(abi.encodePacked(lp)), 1), Log("", 0), Log("", 0)]
        );
    }

    function switchRouter(address newRouter) external onlyAdmin {
        router = IDEXRouter(newRouter);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        liquidityPools[pair] = true;
        emit UpdatedSettings(
            "Exchange Router Updated",
            [
                Log(
                    concatenate(
                        "New Router: ",
                        toString(abi.encodePacked(newRouter))
                    ),
                    1
                ),
                Log(
                    concatenate(
                        "New Liquidity Pair: ",
                        toString(abi.encodePacked(pair))
                    ),
                    1
                ),
                Log("", 0)
            ]
        );
    }

    function excludePresaleAddresses(
        address preSaleRouter,
        address presaleAddress
    ) external onlyAdmin {
        liquidityCreator[preSaleRouter] = true;
        liquidityCreator[presaleAddress] = true;
        isFeeExempt[preSaleRouter] = true;
        isFeeExempt[presaleAddress] = true;
        emit UpdatedSettings(
            "Presale Setup",
            [
                Log(
                    concatenate(
                        "Presale Router: ",
                        toString(abi.encodePacked(preSaleRouter))
                    ),
                    1
                ),
                Log(
                    concatenate(
                        "Presale Address: ",
                        toString(abi.encodePacked(presaleAddress))
                    ),
                    1
                ),
                Log("", 0)
            ]
        );
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, to, block.timestamp);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyAdmin {
        isFeeExempt[holder] = exempt;
        emit UpdatedSettings(
            exempt ? "Fees Removed" : "Fees Enforced",
            [Log(toString(abi.encodePacked(holder)), 1), Log("", 0), Log("", 0)]
        );
    }

    function setFees(uint256 _marketingFee, uint256 _feeDenominator)
        external
        onlyAdmin
    {
        marketingFee = _marketingFee;
        totalFee = _marketingFee;
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator / 10);
        emit UpdatedSettings(
            "Fees",
            [
                Log(
                    "Marketing Fee Percent",
                    ((totalFee) * 100) / feeDenominator
                ),
                Log("Total Fee Percent", ((totalFee) * 100) / feeDenominator),
                Log("Fee Denominator", feeDenominator)
            ]
        );
    }

    function setFeeReceivers(address _marketingFeeReceiver) external onlyAdmin {
        marketingFeeReceiver = payable(_marketingFeeReceiver);
        emit UpdatedFeeReceiver(
            "Fee Receiver",
            [
                Log(
                    concatenate(
                        "Marketing Receiver: ",
                        toString(abi.encodePacked(_marketingFeeReceiver))
                    ),
                    1
                ),
                Log("", 0)
            ]
        );
    }

    function setSwapBackSettings(
        bool _enabled,
        bool _processEnabled,
        uint256 _denominator
    ) external onlyAdmin {
        require(_denominator > 0);
        swapEnabled = _enabled;
        processEnabled = _processEnabled;
        swapThreshold = _totalSupply / _denominator;
        emit UpdatedSettings(
            "Swap Settings",
            [
                Log("Enabled", _enabled ? 1 : 0),
                Log("Swap Amount", swapThreshold),
                Log("Auto-processing", _processEnabled ? 1 : 0)
            ]
        );
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - (balanceOf(DEAD) + balanceOf(ZERO));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function concatenate(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    struct Log {
        string name;
        uint256 value;
    }

    event FundsDistributed(uint256 marketingBNB);
    event UpdatedSettings(string name, Log[3] values);
    event UpdatedFeeReceiver(string name, Log[2] values);
    event UpdatedFees(string name, Log[1] values);
}
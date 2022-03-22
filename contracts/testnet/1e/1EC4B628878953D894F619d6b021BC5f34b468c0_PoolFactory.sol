// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// import "@optionality.io/clone-factory/contracts/CloneFactory.sol";
import "../upgradeability/CloneFactory.sol";
import "./PoolLogic.sol";
import "./PoolManagerLogic.sol";
import "./../interfaces/IAssetHandler.sol";
import "./../interfaces/IPoolFactory.sol";
import "./../interfaces/ISupportedAsset.sol";

contract PoolFactory is Initializable,IPoolFactory {
    event PoolLogicCreated(address newPoolLogic);
    event PoolManagerLogicCreated(address newPoolManagerLogic);

    /* constrant address for temporary store */
    // address poolLogicAddress = 0x8Ec4ad19F7dD3bc0D09fC87A19F1863C36562904;
    // address poolManagerLogicAddress = 0x8Ec4ad19F7dD3bc0D09fC87A19F1863C36562904;
    address public poolLogicAddress;
    address public poolManagerLogicAddress;
    address public assetHandler;

    CloneFactory cloneFactory;

    address[] public deployedPools;

    function initialize (
        address _cloneFactoryAddress,
        address _assetHandler,
        address _poolLogic,
        address _poolManagerLogic
    ) external initializer {
        require(_assetHandler != address(0), "invalid assetHandler");
        require(_poolLogic != address(0), "invalid poolLogic");
        require(_poolManagerLogic != address(0), "invalid poolManagerLogic");

        cloneFactory = CloneFactory(_cloneFactoryAddress);
        assetHandler = _assetHandler;
        poolLogicAddress = _poolLogic;
        poolManagerLogicAddress = _poolManagerLogic;
    }

    function createFund(ISupportedAsset.Asset[] calldata _supportedAssets) public {
        address newPoolLogic = cloneFactory.deployPool(poolLogicAddress);
        address newPoolManagerLogic = cloneFactory.deployPool(poolManagerLogicAddress);

        PoolLogic(newPoolLogic).initialize(
            address(this),
            2000000000000000000 // 2
        );
        PoolLogic(newPoolLogic).setPoolManagerLogic(newPoolManagerLogic);

        PoolManagerLogic(newPoolManagerLogic).initialize(address(this), msg.sender, newPoolLogic, _supportedAssets);

        deployedPools.push(newPoolLogic);

        emit PoolLogicCreated(newPoolLogic);
        emit PoolManagerLogicCreated(newPoolManagerLogic);
    }

    function isValidAsset(address asset) public view override returns (bool) {
        return IAssetHandler(assetHandler).priceAggregators(asset) != address(0);
    }

    function getAssetPrice(address asset) external view override returns (uint256 price) {
        price = IAssetHandler(assetHandler).getUSDPrice(asset);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CloneFactory {
    event PoolCreated(address cloneAddress);

    function deployPool(address logicContractAddress) external returns (address result) {
        bytes20 addressBytes = bytes20(logicContractAddress);

        assembly {
            let clone := mload(0x40) // Jump to the end of the currently allocated memory- 0x40 is the free memory pointer. It allows us to add own code

            /*
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            */
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000) // store 32 bytes (0x3d602...) to memory starting at the position clone

            /*
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                |        20 bytes                       |    20 bytes address                   |
            */
            mstore(add(clone, 0x14), addressBytes) // add the address at the location clone + 20 bytes. 0x14 is hexadecimal and is 20 in decimal

            /*
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
                 |        20 bytes                       |    20 bytes address                   |  15 bytes                     |
            */
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000) // add the rest of the code at position 40 bytes (0x28 = 40)

            /* 
                create a new contract
                send 0 Ether
                the code starts at the position clone
                the code is 55 bytes long (0x37 = 55)
            */
            result := create(0, clone, 0x37)
        }

        emit PoolCreated(result);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./../interfaces/IPancakeRouter02.sol";
import "./../interfaces/IPoolManagerLogic.sol";
import "./../interfaces/ISupportedAsset.sol";

contract PoolLogic is ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public factory;
    address public poolManagerLogic;

    address public immutable swapRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public immutable WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    address public manager;
    address payable[] private investors;

    uint256 public initalPrice; // price per unit

    mapping(address => uint256) public indexOfInvestor; // map stores 1-based
    mapping(address => uint256) private units; // unit of users
    uint256 private totalUnit; // total amount of unit

    struct WithdrawnAsset {
        address asset;
        uint256 amount;
        uint256 proportion;
    }

    event Deposit(address token, address from, uint256 value, uint256 amountUnit);
    event Withdraw(WithdrawnAsset[] withdrawnAssets, address to);
    event Swap(address tokenIn, address tokenOut, uint256 amountIn);

    event InvestorRemoved(address investor);

    event PoolManagerLogicSet(address poolManagerLogic, address from);

    modifier onlyManager() {
        require(msg.sender == manager, "only manager");
        _;
    }

    function initialize(
        address _factory,
        uint256 _initalPrice
    ) external initializer {
        require(_factory != address(0), "invalid factory");
        require(_initalPrice >= 10**18, "require initial deposited price");
        __ReentrancyGuard_init();

        factory = _factory;
        manager = msg.sender;
        totalUnit = 0;
        initalPrice = _initalPrice;
    }

    function setPoolManagerLogic(address _poolManagerLogic) external returns (bool) {
        require(_poolManagerLogic != address(0), "invalid poolManagerLogic address");
        require(msg.sender == address(factory));

        poolManagerLogic = _poolManagerLogic;
        emit PoolManagerLogicSet(_poolManagerLogic, msg.sender);
        return true;
    }

    function getBalance(address pool, address asset) public view returns (uint256) {
        return IERC20Upgradeable(asset).balanceOf(pool);
    }

    function totalSupply() public view returns (uint256) {
        return totalUnit;
    }

    function listInvestor() external view returns (address payable[] memory) {
        return investors;
    }

    function getUnit(address _investor) public view returns (uint256) {
        return units[_investor];
    }

    function deposit(address _tokenIn, uint256 _amountIn) external {
        require(IPoolManagerLogic(poolManagerLogic).isDepositAsset(_tokenIn), "invalid deposit asset");
        require(_amountIn > 0, "require amount of token");

        uint256 totalUnitBefore = totalSupply();
        if (totalUnitBefore == 0) {
            require(_amountIn >= initalPrice, "at least minimum amount");
        }

        // transfer token from sender to contract
        IERC20Upgradeable(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);

        // get _amountIn in USD unit (18 decimals)
        uint256 usdAmountIn = IPoolManagerLogic(poolManagerLogic).getAssetValue(_tokenIn, _amountIn);

        // get pool value in USD unit (18 decimals)
        uint256 totalValue = IPoolManagerLogic(poolManagerLogic).totalFundValue();

        // calculate the number of unit
        uint256 numberOfUnit;
        if (totalUnitBefore > 0) {
            numberOfUnit = usdAmountIn.mul(totalUnitBefore).div(totalValue);
        } else {
            numberOfUnit = _amountIn.mul(10**18).div(initalPrice);
        }

        units[msg.sender] = units[msg.sender].add(numberOfUnit);
        totalUnit = totalUnit.add(numberOfUnit);

        if (indexOfInvestor[msg.sender] == 0) {
            investors.push(payable(msg.sender));
            indexOfInvestor[msg.sender] = investors.length;
        }

        emit Deposit(_tokenIn, msg.sender, _amountIn, numberOfUnit);
    }

    function withdraw(uint256 _unitOut) external nonReentrant {
        require(_unitOut > 0, "require number of unit");

        uint256 numberOfUnit = units[msg.sender];
        require(numberOfUnit > 0, "no investment units");
        require(_unitOut <= numberOfUnit, "insufficient balance");

        // calculate the proportion
        uint256 proportion = _unitOut.mul(10**18).div(totalSupply());

        if (numberOfUnit == _unitOut) {
            // exit pool
            _removeInvestor(msg.sender);
            units[msg.sender] = 0;
        } else {
            // decrease unit
            units[msg.sender] = units[msg.sender].sub(_unitOut);
        }
        totalUnit = totalUnit.sub(_unitOut);

        // withdarw token held
        uint256 index = 0;
        ISupportedAsset.Asset[] memory assets = ISupportedAsset(poolManagerLogic).getSupportedAssets();
        uint256 assetCount = assets.length;
        WithdrawnAsset[] memory withdrawnAssets = new WithdrawnAsset[](assetCount);
        for (uint256 i = 0; i < assetCount; i++) {
            address asset = assets[i].asset;
            uint256 withdrawnAmount = _calculateNumberOfWithdrawnToken(address(this), asset, proportion);
            if (withdrawnAmount > 0) {
                IERC20Upgradeable(asset).safeTransfer(msg.sender, withdrawnAmount);
                withdrawnAssets[index] = WithdrawnAsset({
                    asset: asset,
                    amount: withdrawnAmount,
                    proportion: proportion
                });

                index++;
            }
        }

        // Reduce length for withdrawnAssets to remove the empty items
        uint256 reduceLength = assetCount.sub(index);
        assembly {
            mstore(withdrawnAssets, sub(mload(withdrawnAssets), reduceLength))
        }

        // TransferHelper.safeApprove(_tokenOut, address(this), _unitOut);
        // TransferHelper.safeTransferFrom(_tokenOut, address(this), msg.sender, _unitOut);

        emit Withdraw(withdrawnAssets, msg.sender);
    }

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) external onlyManager nonReentrant {
        if (_tokenIn == _tokenOut) {
            return;
        }

        // Approve if not enough swap allowance
        if (IERC20Upgradeable(_tokenIn).allowance(address(this), address(swapRouter)) < _amountIn) {
            IERC20Upgradeable(_tokenIn).safeApprove(address(swapRouter), _amountIn);
        }

        address[] memory path;
        if (_tokenIn == WBNB || _tokenOut == WBNB) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WBNB;
            path[2] = _tokenOut;
        }

        IPancakeRouter02(swapRouter).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            address(this),
            block.timestamp
        );

        emit Swap(_tokenIn, _tokenOut, _amountIn);
    }

    // Move the last element to the deleted spot.
    // Remove the last element.
    function _removeInvestor(address _investor) internal {
        uint256 length = investors.length;
        uint256 index = indexOfInvestor[_investor].sub(1);

        require(length > 0, "can't remove from empty array");
        require(index < length, "index invalid");

        address lastInvestor = investors[length.sub(1)];

        investors[index] = payable(lastInvestor);
        indexOfInvestor[lastInvestor] = index.add(1);
        indexOfInvestor[_investor] = 0;

        investors.pop();
        emit InvestorRemoved(_investor);
    }

    function _calculateNumberOfWithdrawnToken(
        address _pool,
        address _asset,
        uint256 _proportion
    ) internal view returns (uint256 withdrawnAmount) {
        uint256 totalAssetBalance = getBalance(_pool, _asset);
        withdrawnAmount = totalAssetBalance.mul(_proportion).div(10**18);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "./../interfaces/IPoolFactory.sol";
import "./../interfaces/IPoolManagerLogic.sol";
import "./../interfaces/ISupportedAsset.sol";

contract PoolManagerLogic is Initializable, IPoolManagerLogic, ISupportedAsset {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    event AssetAdded(address indexed pool, address manager, address asset, bool isDeposit);
    event AssetRemoved(address pool, address manager, address asset);
    event PoolLogicSet(address poolLogic, address from);

    address public factory;
    address public override poolLogic;
    address public manager;

    Asset[] public supportedAssets;
    mapping(address => uint256) public assetPosition; // 1-based position

    modifier onlyManager() {
        require(msg.sender == manager, "only manager");
        _;
    }

    function initialize(
        address _factory,
        address _manager,
        address _poolLogic,
        Asset[] calldata _assets
    ) external initializer {
        require(_factory != address(0), "invalid factory");
        require(_manager != address(0), "invalid manager");
        require(_poolLogic != address(0), "invalid poolLogic");

        manager = _manager;
        factory = _factory;
        poolLogic = _poolLogic;
        _changeAssets(_assets, new address[](0));
    }

    function getSupportedAssets() external view override returns (Asset[] memory) {
        return supportedAssets;
    }

    function isDepositAsset(address asset) public view override returns (bool) {
        uint256 index = assetPosition[asset];
        return index != 0 && supportedAssets[index.sub(1)].isDeposit;
    }

    function getDepositAssets() public view returns (address[] memory) {
        uint256 assetCount = supportedAssets.length;
        address[] memory depositAssets = new address[](assetCount);
        uint8 index = 0;
        for (uint8 i = 0; i < assetCount; i++) {
            if (supportedAssets[i].isDeposit) {
                depositAssets[index] = supportedAssets[i].asset;
                index++;
            }
        }

        // Reduce length for withdrawnAssets to remove the empty items
        uint256 reduceLength = assetCount.sub(index);
        assembly {
            mstore(depositAssets, sub(mload(depositAssets), reduceLength))
        }
        return depositAssets;
    }

    function totalFundValue() external view override returns (uint256) {
        uint256 total = 0;
        uint256 assetCount = supportedAssets.length;

        for (uint256 i = 0; i < assetCount; i++) {
            address asset = supportedAssets[i].asset;
            uint256 totalBalance = IERC20Upgradeable(asset).balanceOf(poolLogic);
            total = total.add(getAssetValue(asset, totalBalance));
        }
        return total;
    }

    function isSupportedAsset(address asset) public view override returns (bool) {
        return assetPosition[asset] != 0;
    }

    function getAssetValue(address asset, uint256 amount) public view override returns (uint256) {
        uint256 price = IPoolFactory(factory).getAssetPrice(asset);

        return price.mul(amount).div(10**18);
    }

    function changeAssets(Asset[] calldata _addAssets, address[] calldata _removeAssets) external onlyManager {
        _changeAssets(_addAssets, _removeAssets);
    }

    function _changeAssets(Asset[] calldata _addAssets, address[] memory _removeAssets) internal {
        for (uint8 i = 0; i < _removeAssets.length; i++) {
            _removeAsset(_removeAssets[i]);
        }

        for (uint8 i = 0; i < _addAssets.length; i++) {
            _addAsset(_addAssets[i]);
        }

        require(getDepositAssets().length >= 1, "at least one deposit asset");
    }

    function _addAsset(Asset calldata _asset) internal {
        address asset = _asset.asset;
        bool isDeposit = _asset.isDeposit;

        if (assetPosition[asset] != 0) {
            uint256 index = assetPosition[asset].sub(1);
            supportedAssets[index].isDeposit = isDeposit;
        } else {
            supportedAssets.push(Asset(asset, isDeposit));
            assetPosition[asset] = supportedAssets.length;
        }

        emit AssetAdded(address(this), manager, asset, isDeposit);
    }

    function _removeAsset(address asset) internal {
        require(assetPosition[asset] != 0, "asset not supported");

        require(IERC20Upgradeable(asset).balanceOf(poolLogic) == 0, "cannot remove non-empty asset");

        uint256 length = supportedAssets.length;
        Asset memory lastAsset = supportedAssets[length.sub(1)];
        uint256 index = assetPosition[asset].sub(1);

        supportedAssets[index] = lastAsset;
        assetPosition[lastAsset.asset] = index.add(1);
        assetPosition[asset] = 0;

        supportedAssets.pop();

        emit AssetRemoved(address(this), manager, asset);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

interface IAssetHandler {
    event AddedAsset(address asset, address aggregator);
    event RemovedAsset(address asset);

    struct Asset {
        address asset;
        address aggregator;
    }

    function addAssets(Asset[] memory assets) external;

    function addAsset(address asset, address aggregator) external;

    function removeAsset(address asset) external;

    function priceAggregators(address asset) external view returns (address);

    function getUSDPrice(address asset) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPoolFactory {
    function isValidAsset(address asset) external view returns (bool);
    
    function getAssetPrice(address asset) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface ISupportedAsset {
    struct Asset {
        address asset;
        bool isDeposit;
    }

    function getSupportedAssets() external view returns (Asset[] memory);

    function isSupportedAsset(address asset) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPancakeRouter02 {
    function WETH() external pure returns (address);
    
    function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);

    //  Receive an as many output tokens as possible for an exact amount of input tokens.
    function swapExactTokensForTokens(
        //  amount of tokens we are sending in
        uint256 amountIn,
        //  the minimum amount of tokens we want out of the trade
        uint256 amountOutMin,
        //  list of token addresses we are going to trade in.  this is necessary to calculate amounts
        address[] calldata path,
        //  this is the address we are going to send the output tokens to
        address to,
        //  the last time that the trade is valid for
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    //  Receive an exact amount of output tokens for as few input tokens as possible.
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    //  Receive an as many output tokens as possible for an exact amount of BNB.
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    //  Receive an exact amount of ETH for as few input tokens as possible.
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    //  Receive an as much BNB as possible for an exact amount of input tokens.
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    //  Receive an exact amount of output tokens for as little BNB as possible.
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPoolManagerLogic {

    function poolLogic() external view returns (address);

    function isDepositAsset(address asset) external view returns (bool);

    function totalFundValue() external view returns (uint256);

    function getAssetValue(address asset, uint256 amount) external view returns (uint256);
}
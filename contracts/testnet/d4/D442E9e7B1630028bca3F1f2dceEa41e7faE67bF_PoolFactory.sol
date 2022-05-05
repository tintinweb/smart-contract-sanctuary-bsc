// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// import "@optionality.io/clone-factory/contracts/CloneFactory.sol";
import "../upgradability/CloneFactory.sol";
import "./PoolLogic.sol";
import "./PoolManagerLogic.sol";
import "./../interfaces/IAssetHandler.sol";
import "./../interfaces/IPoolFactory.sol";
import "./../interfaces/ISupportedAsset.sol";
import "./../interfaces/IFeeManage.sol";
import "../upgradability/ProxyFactory.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract PoolFactory is IPoolFactory, Initializable, ProxyFactory {
    event PoolCreated(address newPoolLogic, address newPoolManagerLogic, address manager);
    event AssetHandlerChanged(address from, address newAssetHandler);

    address public poolLogicAddress;
    address public poolManagerLogicAddress;
    address public assetHandler;

    address public override pancakeswapRouter;
    address public override WBNB;

    CloneFactory cloneFactory;

    address[] public deployedPools;

    function initialize(
        address _router,
        address _wbnb,
        address _cloneFactoryAddress,
        address _assetHandler,
        address _poolLogic,
        address _poolManagerLogic
    ) external initializer {
        require(_router != address(0), "invalid router");
        require(_wbnb != address(0), "invalid WBNB");
        require(_assetHandler != address(0), "invalid assetHandler");
        require(_poolLogic != address(0), "invalid poolLogic");
        require(_poolManagerLogic != address(0), "invalid poolManagerLogic");
        __ProxyFactory_init(_poolLogic, _poolManagerLogic);

        cloneFactory = CloneFactory(_cloneFactoryAddress);
        assetHandler = _assetHandler;
        poolLogicAddress = _poolLogic;
        poolManagerLogicAddress = _poolManagerLogic;
        pancakeswapRouter = _router;
        WBNB = _wbnb;
    }

    /// @dev create new pool and setting manager in pool
    function createPool(
        string memory _poolName,
        string memory _poolSymbol,
        address _denominationAsset,
        address[] calldata _supportedAssets,
        IFeeManage.Fee[] calldata _fee
    ) public {
        require(_denominationAsset != address(0), "invalid denominationAsset");
        require(IAssetHandler(assetHandler).isDepositAsset(_denominationAsset), "invalid deposit asset");

        bytes memory poolManagerLogicData = abi.encodeWithSignature(
            "initialize(address,address,address,address[],(uint256,uint256,address)[])",
            address(this),
            msg.sender,
            _denominationAsset,
            _supportedAssets,
            _fee
        );
        address newPoolManagerLogic = deploy(poolManagerLogicData, 1);

        bytes memory poolLogicData = abi.encodeWithSignature(
            "initialize(address,address,address,string,string)",
            address(this),
            msg.sender,
            newPoolManagerLogic,
            _poolName,
            _poolSymbol
        );
        address newPoolLogic = deploy(poolLogicData, 2);

        IPoolManagerLogic(newPoolManagerLogic).setPoolLogic(newPoolLogic);

        deployedPools.push(newPoolLogic);

        emit PoolCreated(newPoolLogic, newPoolManagerLogic, msg.sender);
    }

    /// @dev validate asset
    function isValidAsset(address asset) public view override returns (bool) {
        return IAssetHandler(assetHandler).priceAggregators(asset) != address(0);
    }

    /// @dev get asset price
    function getAssetPrice(address asset) external view override returns (uint256 price) {
        price = IAssetHandler(assetHandler).getUSDPrice(asset);
    }

    /// @dev list of pool
    function listPool() public view returns (address[] memory) {
        return deployedPools;
    }

    /// @dev get pool factory deployer
    function getOwner() external view returns (address) {
        return owner();
    }

    function changeAssetHandler(address _assetHandler) public onlyOwner {
        require(_assetHandler != address(0), "invalid address");

        address oldAssetHandler = assetHandler;
        IAssetHandler.Asset[] memory oldSupportedAssets = IAssetHandler(oldAssetHandler).getSupportedAssets();
        for (uint256 i = 0; i < oldSupportedAssets.length; i++) {
            // if new supportedAsset not in old assetHandler, cannot change new assetHandler
            address asset = oldSupportedAssets[i].asset;
            IAssetHandler.Asset memory newAsset = IAssetHandler(_assetHandler).getSupportedAssetByAsset(asset);
            require(newAsset.asset != address(0), "cannot change new assetHandler");
        }

        assetHandler = _assetHandler;
        emit AssetHandlerChanged(oldAssetHandler, _assetHandler);
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

import "./../tokens/ERC20ExtendedUpgradeable.sol";
import "./../interfaces/IPancakeRouter02.sol";
import "./../interfaces/IPoolManagerLogic.sol";
import "./../interfaces/ISupportedAsset.sol";
import "./../interfaces/IPoolFactory.sol";
import "./../interfaces/IFeeManage.sol";
import "./../interfaces/IPoolMember.sol";

contract PoolLogic is ERC20ExtendedUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public factory;
    address public poolManagerLogic;

    address public manager;

    uint256 private sharePriceLatest; // latest share price

    struct WithdrawnAsset {
        address asset;
        uint256 amount;
        uint256 proportion;
    }

    struct previewWithdrawnAsset {
        address asset;
        uint256 amount;
        uint256 proportion;
        address stableCoin;
        uint256 amountOut;
    }

    event Deposit(address token, address from, uint256 value, uint256 amountUnit);
    event Withdraw(WithdrawnAsset[] withdrawnAssets, address to);
    event Swap(address tokenIn, address tokenOut, uint256 amountIn, address to);
    event UpdatePerformanceFee(address manager, uint256 managerfee, uint256 systemFee);
    event InvestorRemoved(address investor);

    modifier onlyManager() {
        require(msg.sender == manager, "only manager");
        _;
    }

    function initialize(
        address _factory,
        address _manager,
        address _poolManagerLogic,
        string memory _poolName,
        string memory _poolSymbol
    ) external initializer {
        require(_factory != address(0), "invalid factory");
        require(_manager != address(0), "invalid manager");
        require(_poolManagerLogic != address(0), "invalid poolManagerLogic");
        __ERC20_init(_poolName,_poolSymbol);
        __ReentrancyGuard_init();

        factory = _factory;
        manager = _manager;
        poolManagerLogic = _poolManagerLogic;

        sharePriceLatest = 10**18;
    }
    
    /// @dev get unit of investor
    function getUnit(address _investor) public view returns (uint256) {
        return balanceOf(_investor);
    }

    function getSharePriceLatest() public view returns (uint256) {
        return sharePriceLatest;
    }

    /// @notice deposit stable coin or any token that can deposit
    /// @dev transfer from wallet's investor into pool
    /// @dev calculate number of unit
    function deposit(address _tokenIn, uint256 _amountIn) public {
        require(_tokenIn == IPoolManagerLogic(poolManagerLogic).denominationAsset(), "invalid deposit asset");
        require(_amountIn > 0, "require amount of token");

        uint256 totalUnitBefore = totalSupply();

        // get pool value in USD unit (18 decimals)
        uint256 totalValue = IPoolManagerLogic(poolManagerLogic).totalPoolValue();

        // transfer token from sender to contract
        IERC20Upgradeable(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);

        // calculate the number of unit
        uint256 numberOfUnit;
        if (totalUnitBefore > 0) {
            // get _amountIn in USD unit (18 decimals)
            uint256 usdAmountIn = IPoolManagerLogic(poolManagerLogic).getAssetValue(_tokenIn, _amountIn);
            numberOfUnit = usdAmountIn.mul(totalUnitBefore).div(totalValue);
        } else {
            numberOfUnit = _amountIn;
            sharePriceLatest = IPoolManagerLogic(poolManagerLogic).getAssetValue(_tokenIn, 10**18);
        }

        _mint(msg.sender, numberOfUnit);

        IPoolMember(poolManagerLogic).addMember(address(this), msg.sender);

        emit Deposit(_tokenIn, msg.sender, _amountIn, numberOfUnit);
    }

    /// @dev preview proportion of asset withdrawal
    /// @dev if opt. stable coin then sum(get amount out each asset from router pancakeswap)
    function previewWithdrawal(
        address _investor,
        bool _isStablecoin,
        uint256 _unitOut
    ) external view returns (previewWithdrawnAsset[] memory withdrawnAssets) {
        require(_unitOut > 0, "require number of unit");

        uint256 numberOfUnit = getUnit(_investor);
        require(numberOfUnit > 0, "no investment units");
        require(_unitOut <= numberOfUnit, "insufficient balance");

        address denominationAsset = IPoolManagerLogic(poolManagerLogic).denominationAsset();

        // calculate the proportion
        uint256 proportion = _unitOut.mul(10**18).div(totalSupply());

        uint256 index = 0;
        address[] memory assets = ISupportedAsset(poolManagerLogic).getSupportedAssets();
        uint256 assetCount = assets.length;
        withdrawnAssets = new previewWithdrawnAsset[](assetCount);
        address pancakeswapRouter = IPoolFactory(factory).pancakeswapRouter();
        for (uint256 i = 0; i < assetCount; i++) {
            address asset = assets[i];
            uint256 withdrawnAmount = _calculateNumberOfWithdrawnToken(address(this), asset, proportion);
            if (withdrawnAmount > 0) {
                uint256 amountOut = withdrawnAmount;
                if (_isStablecoin) {
                    // get amount out min
                    if (asset != denominationAsset) {
                        address[] memory path = _getPathSwap(asset, denominationAsset);
                        uint256[] memory amountOuts = IPancakeRouter02(pancakeswapRouter).getAmountsOut(
                            withdrawnAmount,
                            path
                        );
                        if (amountOuts.length > 0) {
                            amountOut = amountOuts[0];
                        } else {
                            amountOut = 0;
                        }
                    }
                }
                withdrawnAssets[index] = previewWithdrawnAsset({
                    asset: asset,
                    amount: withdrawnAmount,
                    proportion: proportion,
                    stableCoin: denominationAsset,
                    amountOut: amountOut
                });

                index++;
            }
        }

        // Reduce length for withdrawnAssets to remove the empty items
        uint256 reduceLength = assetCount.sub(index);
        assembly {
            mstore(withdrawnAssets, sub(mload(withdrawnAssets), reduceLength))
        }
    }

    /// @dev opt. withdraw stable coin
    /// @dev opt. withdraw any asset
    function withdraw(bool _isStablecoin, uint256 _unitOut) public nonReentrant {
        require(_unitOut > 0, "require number of unit");

        uint256 numberOfUnit = getUnit(msg.sender);
        require(numberOfUnit > 0, "no investment units");
        require(_unitOut <= numberOfUnit, "insufficient balance");

        address denominationAsset = IPoolManagerLogic(poolManagerLogic).denominationAsset();

        // calculate the proportion
        uint256 proportion = _unitOut.mul(10**18).div(totalSupply());

        _burn(msg.sender, _unitOut);
        if (numberOfUnit == _unitOut) {
            // exit pool
            IPoolMember(poolManagerLogic).removeMember(address(this), msg.sender);
        }

        // withdarw token held
        uint256 index = 0;
        address[] memory assets = ISupportedAsset(poolManagerLogic).getSupportedAssets();
        uint256 assetCount = assets.length;
        WithdrawnAsset[] memory withdrawnAssets = new WithdrawnAsset[](assetCount);
        for (uint256 i = 0; i < assetCount; i++) {
            address asset = assets[i];
            uint256 withdrawnAmount = _calculateNumberOfWithdrawnToken(address(this), asset, proportion);
            if (withdrawnAmount > 0) {
                if (!_isStablecoin) {
                    // transfer
                    IERC20Upgradeable(asset).transfer(msg.sender, withdrawnAmount);
                } else {
                    if (denominationAsset == asset) {
                        // transfer only denomination asset
                        IERC20Upgradeable(asset).transfer(msg.sender, withdrawnAmount);
                    } else {
                        // swap to stable coin
                        _swapForWithdrawal(asset, denominationAsset, withdrawnAmount, msg.sender);
                    }
                }
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

        emit Withdraw(withdrawnAssets, msg.sender);
    }

    /// @dev swap token by router pancakeswap
    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        address[] calldata _path,
        uint256 _amountOutMin
    ) public onlyManager nonReentrant {
        if (_tokenIn == _tokenOut) {
            return;
        }
        require(ISupportedAsset(poolManagerLogic).isSupportedAsset(_tokenOut), "asset not enabled in pool");

        _swap(_tokenIn, _tokenOut, _amountIn, _amountOutMin, _path, address(this));
    }

    /// @dev calculate performance fee
    function calculatePerformanceFee() public nonReentrant {
        require(IFeeManage(poolManagerLogic).performanceFee() != 0, "no performanceFee");
        (uint256 newSharePrice, uint256 managerFee, uint256 systemFee) = IFeeManage(poolManagerLogic)
            .availablePerformanceFee(sharePriceLatest);

        require(newSharePrice != 0, "no profit");
        sharePriceLatest = newSharePrice;
        if (managerFee > 0) {
            _mint(poolManagerLogic, managerFee);
        }
        if (systemFee > 0) {
            _mint(factory, systemFee);
        }

        emit UpdatePerformanceFee(manager, managerFee, systemFee);
    }

    /// @dev get path for swap function
    function _getPathSwap(address _tokenIn, address _tokenOut) internal view returns (address[] memory path) {
        address WBNB = IPoolFactory(factory).WBNB();
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
    }

    /// @dev swap token to stable coin
    function _swapForWithdrawal(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        address _to
    ) internal {
        if (_tokenIn == _tokenOut) {
            return;
        }

        address[] memory path = _getPathSwap(_tokenIn, _tokenOut);
        uint256[] memory amountOutmin = IPancakeRouter02(IPoolFactory(factory).pancakeswapRouter()).getAmountsOut(
            _amountIn,
            path
        );
        if (amountOutmin.length <= 0) {
            return;
        }

        _swap(_tokenIn, _tokenOut, _amountIn, amountOutmin[0], path, _to);
    }

    /// @dev swap function - pancakeswap
    function _swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address[] memory _path,
        address _to
    ) internal {
        address pancakeswapRouter = IPoolFactory(factory).pancakeswapRouter();
        // Approve if not enough swap allowance
        uint256 allowance = IERC20Upgradeable(_tokenIn).allowance(address(this), address(pancakeswapRouter));
        if (allowance < _amountIn) {
            if (allowance > 0) {
                IERC20Upgradeable(_tokenIn).safeApprove(address(pancakeswapRouter), 0);
            }
            IERC20Upgradeable(_tokenIn).safeApprove(address(pancakeswapRouter), _amountIn);
        }

        IPancakeRouter02(pancakeswapRouter).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            _path,
            _to,
            block.timestamp
        );

        emit Swap(_tokenIn, _tokenOut, _amountIn, _to);
    }

    /// @dev calculate number of withdraw token held
    function _calculateNumberOfWithdrawnToken(
        address _pool,
        address _asset,
        uint256 _proportion
    ) internal view returns (uint256 withdrawnAmount) {
        uint256 totalAssetBalance = IERC20Upgradeable(_asset).balanceOf(_pool);
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
import "./../interfaces/IERC20Extended.sol";
import "./../interfaces/IFeeManage.sol";
import "./PoolMember.sol";

contract PoolManagerLogic is Initializable, IPoolManagerLogic, ISupportedAsset, IFeeManage, PoolMember {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    event AssetAdded(address indexed pool, address manager, address asset);
    event AssetRemoved(address pool, address manager, address asset);
    event PoolLogicSet(address poolLogic);
    event FeeChanged(address manager, uint256 feeType, uint256 from, uint256 to, address recipient);

    address public factory;
    address public override poolLogic;
    address public manager;

    address[] public supportedAssets;
    mapping(address => uint256) public assetPosition; // 1-based position
    address public denominationAsset;

    uint256 public override performanceFee;
    uint256 public managementFee;
    uint256 public entryFee;
    uint256 public exitSpecificFee;
    uint256 public exitShareInKindFee;
    mapping(uint256 => address) public recipients;

    struct AssetHolding {
        address asset;
        uint256 amount;
        uint256 price;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "only manager");
        _;
    }

    function initialize(
        address _factory,
        address _manager,
        address _denominationAsset,
        address[] calldata _assets,
        Fee[] calldata _fee
    ) external initializer {
        require(_factory != address(0), "invalid factory");
        require(_manager != address(0), "invalid manager");
        require(_denominationAsset != address(0), "invalid denominationAsset");

        manager = _manager;
        factory = _factory;
        denominationAsset = _denominationAsset;
        _setupFee(_fee);
        _changeAssets(_assets, new address[](0));

        require(assetPosition[denominationAsset] != 0, "no deposit asset in support");
    }

    function setPoolLogic(address _poolLogic) external {
        require(_poolLogic != address(0), "invalid poolLogic");
        require(msg.sender != IPoolFactory(factory).getOwner(), "only factory owner");

        poolLogic = _poolLogic;
        emit PoolLogicSet(poolLogic);
    }

    function getSupportedAssets() external view override returns (address[] memory) {
        return supportedAssets;
    }

    function isValidAsset(address _asset) internal view returns (bool) {
        return IPoolFactory(factory).isValidAsset(_asset);
    }

    function totalPoolValue() public view override returns (uint256) {
        uint256 total = 0;
        uint256 assetCount = supportedAssets.length;

        for (uint256 i = 0; i < assetCount; i++) {
            address asset = supportedAssets[i];
            uint256 totalBalance = IERC20Upgradeable(asset).balanceOf(poolLogic);
            total = total.add(getAssetValue(asset, totalBalance));
        }
        return total;
    }

    function isSupportedAsset(address _asset) public view override returns (bool) {
        return assetPosition[_asset] != 0;
    }

    function getAssetValue(address asset, uint256 amount) public view override returns (uint256) {
        uint256 price = IPoolFactory(factory).getAssetPrice(asset);
        uint256 decimals = IERC20Extended(asset).decimals();

        return price.mul(amount).div(10**decimals);
    }

    /// @dev get asset holding
    function getAssetHolding() public view returns (AssetHolding[] memory) {
        uint256 index = 0;
        address[] memory assets = supportedAssets;
        uint256 assetCount = assets.length;
        AssetHolding[] memory assetHolding = new AssetHolding[](assetCount);
        for (uint256 i = 0; i < assetCount; i++) {
            uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(poolLogic);
            if (balance != 0) {
                uint256 assetPrice = getAssetValue(assets[i], 10**18);
                assetHolding[index] = AssetHolding(assets[i], balance, assetPrice);
                index = index.add(1);
            }
        }

        // Reduce length for assetHolding to remove the empty items
        uint256 reduceLength = assetCount.sub(index);
        assembly {
            mstore(assetHolding, sub(mload(assetHolding), reduceLength))
        }
        return assetHolding;
    }

    function setPerformanceFee(uint256 feeRate, address recipient) public onlyManager {
        _changeFee(Fee(uint256(IFeeManage.FeeType.TYPE_FEE_PERFORMANCE) , feeRate, recipient));
    }

    function _setupFee(Fee[] calldata _fee) internal {
        for (uint256 i = 0; i < _fee.length; i++) {
            _changeFee(_fee[i]);
        }
    }

    /// @dev change fee in pool - based on 100%(10000)
    function _changeFee(Fee memory _fee) internal {
        uint256 feeType = _fee.feeType;
        require(_fee.feeRate < 10000, "cannot set over 10000(100%)");
        if (_fee.feeRate > 0) {
            require(_fee.recipient != address(0), "invalid recipient address");
        }

        uint256 oldFee;
        if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_PERFORMANCE)) {
            oldFee = performanceFee;
            performanceFee = _fee.feeRate;
        } else if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_MANAGEMENT)) {
            oldFee = managementFee;
            managementFee = _fee.feeRate;
        } else if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_ENTRY)) {
            oldFee = entryFee;
            entryFee = _fee.feeRate;
        } else if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_EXIT_SPECIFIC)) {
            oldFee = exitSpecificFee;
            exitSpecificFee = _fee.feeRate;
        } else if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_EXIT_SHARE_IN_KIND)) {
            oldFee = exitShareInKindFee;
            exitShareInKindFee = _fee.feeRate;
        } else {
            revert("invalid fee type");
        }

        recipients[feeType] = _fee.recipient;

        emit FeeChanged(manager, feeType, oldFee, _fee.feeRate, _fee.recipient);
    }

    function availablePerformanceFee(uint256 _sharePriceLatest)
        external
        view
        returns (
            uint256 sharePriceLatest,
            uint256 managerFee,
            uint256 systemFee
        )
    {
        if (performanceFee != 0) {
            uint256 totalShare = IERC20Upgradeable(poolLogic).totalSupply();
            uint256 totalValueBefore = _sharePriceLatest.mul(totalShare).div(10**18);
            uint256 totalValueAfter = totalPoolValue();

            // calculate profit
            if (totalValueAfter > totalValueBefore) {
                uint256 profit = totalValueAfter.sub(totalValueBefore);

                uint256 managerFeeValue = profit.mul(performanceFee).div(10000);
                uint256 systemFeeValue = managerFeeValue.div(10);

                // calculate latest share price
                sharePriceLatest = totalValueAfter.sub(managerFeeValue).mul(10**18).div(totalShare);

                // calculate and update number unit
                managerFee = (managerFeeValue.sub(systemFeeValue)).mul(10**18).div(sharePriceLatest);
                systemFee = systemFeeValue.mul(10**18).div(sharePriceLatest);
            }
        }
    }

    function changeAssets(address[] calldata _addAssets, address[] calldata _removeAssets) external onlyManager {
        _changeAssets(_addAssets, _removeAssets);
    }

    function _changeAssets(address[] calldata _addAssets, address[] memory _removeAssets) internal {
        for (uint8 i = 0; i < _removeAssets.length; i++) {
            _removeAsset(_removeAssets[i]);
        }

        for (uint8 i = 0; i < _addAssets.length; i++) {
            _addAsset(_addAssets[i]);
        }
    }

    function _addAsset(address _asset) internal {
        require(_asset != address(0), "invalid asset");
        require(isValidAsset(_asset), "invalid asset");
        require(poolLogic != _asset, "cannot add pool asset");

        if (assetPosition[_asset] == 0) {
            supportedAssets.push(_asset);
            assetPosition[_asset] = supportedAssets.length;
        }

        emit AssetAdded(address(this), manager, _asset);
    }

    function _removeAsset(address _asset) internal {
        require(assetPosition[_asset] != 0, "asset not supported");

        require(IERC20Upgradeable(_asset).balanceOf(poolLogic) == 0, "cannot remove non-empty asset");

        uint256 length = supportedAssets.length;
        address lastAsset = supportedAssets[length.sub(1)];
        uint256 index = assetPosition[_asset].sub(1);

        supportedAssets[index] = lastAsset;
        assetPosition[lastAsset] = index.add(1);
        assetPosition[_asset] = 0;

        supportedAssets.pop();

        emit AssetRemoved(address(this), manager, _asset);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

interface IAssetHandler {
    event AddedAsset(address asset, address aggregator, uint256 timeout, bool isDeposit);
    event RemovedAsset(address asset);

    struct Asset {
        address asset;
        address aggregator;
        uint256 chainlinkTimeout;
        bool isDeposit;
    }

    function addAssets(Asset[] memory assets) external;

    function removeAsset(address asset) external;

    function isDepositAsset(address asset) external view returns (bool);

    function getDepositAssets() external view returns (address[] memory);

    function priceAggregators(address asset) external view returns (address);

    function getSupportedAssets() external view returns (Asset[] memory);

    function getSupportedAssetByAsset(address asset) external view returns (Asset memory);

    function getUSDPrice(address asset) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPoolFactory {
    function getOwner() external view returns (address);

    function pancakeswapRouter() external view returns (address);

    function WBNB() external view returns (address);

    function isValidAsset(address asset) external view returns (bool);
    
    function getAssetPrice(address asset) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface ISupportedAsset {

    function getSupportedAssets() external view returns (address[] memory);

    function isSupportedAsset(address asset) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IFeeManage {
    enum FeeType {
        TYPE_FEE_PERFORMANCE,
        TYPE_FEE_MANAGEMENT,
        TYPE_FEE_ENTRY,
        TYPE_FEE_EXIT_SPECIFIC,
        TYPE_FEE_EXIT_SHARE_IN_KIND
    }

    struct Fee {
        uint256 feeType;
        uint256 feeRate;
        address recipient;
    }

    function performanceFee() external view returns (uint256);

    function availablePerformanceFee(uint256 _sharePriceLatest)
        external
        view
        returns (
            uint256 sharePriceLatest,
            uint256 managerFee,
            uint256 systemFee
        );
}

//
//        __  __    __  ________  _______    ______   ________
//       /  |/  |  /  |/        |/       \  /      \ /        |
//   ____$$ |$$ |  $$ |$$$$$$$$/ $$$$$$$  |/$$$$$$  |$$$$$$$$/
//  /    $$ |$$ |__$$ |$$ |__    $$ |  $$ |$$ | _$$/ $$ |__
// /$$$$$$$ |$$    $$ |$$    |   $$ |  $$ |$$ |/    |$$    |
// $$ |  $$ |$$$$$$$$ |$$$$$/    $$ |  $$ |$$ |$$$$ |$$$$$/
// $$ \__$$ |$$ |  $$ |$$ |_____ $$ |__$$ |$$ \__$$ |$$ |_____
// $$    $$ |$$ |  $$ |$$       |$$    $$/ $$    $$/ $$       |
//  $$$$$$$/ $$/   $$/ $$$$$$$$/ $$$$$$$/   $$$$$$/  $$$$$$$$/
//
// dHEDGE DAO - https://dhedge.org
//
// Copyright (c) 2021 dHEDGE DAO
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./InitializableUpgradeabilityProxy.sol";
import "./HasLogic.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @notice This contract is used to deploy the proxy contract.
contract ProxyFactory is OwnableUpgradeable, HasLogic {
  event ProxyCreated(address proxy);

  address private poolLogic;

  address private poolManagerLogic;

  /// @notice initialise poolLogic and poolManagerLogic
  /// @param _poolLogic address of the pool logic
  /// @param _poolManagerLogic address of the pool manager logic
  function __ProxyFactory_init(address _poolLogic, address _poolManagerLogic) internal {
    __Ownable_init();

    require(_poolLogic != address(0), "Invalid poolLogic");
    require(_poolManagerLogic != address(0), "Invalid poolManagerLogic");

    poolLogic = _poolLogic;
    poolManagerLogic = _poolManagerLogic;
  }

  /// @notice Setting logic address for both poolLogic and poolManagerLogic
  /// @param _poolLogic address of the pool logic
  /// @param _poolManagerLogic address of the pool manager logic
  function setLogic(address _poolLogic, address _poolManagerLogic) public onlyOwner {
    require(_poolLogic != address(0), "Invalid poolLogic");
    require(_poolManagerLogic != address(0), "Invalid poolManagerLogic");

    poolLogic = _poolLogic;
    poolManagerLogic = _poolManagerLogic;
  }

  /// @notice Return logic address of the pool or the pool manager logic
  function getLogic(uint8 _proxyType) public view override returns (address) {
    if (_proxyType == 1) {
      return poolManagerLogic;
    } else {
      return poolLogic;
    }
  }

  /// @notice Deploy proxy contract external call
  function deploy(bytes memory _data, uint8 _proxyType) public returns (address) {
    return _deployProxy(_data, _proxyType);
  }

  /// @notice Deploy and initialize proxy contract internal call
  function _deployProxy(bytes memory _data, uint8 _proxyType) internal returns (address) {
    InitializableUpgradeabilityProxy proxy = _createProxy();
    emit ProxyCreated(address(proxy));
    proxy.initialize(address(this), _data, _proxyType);
    return address(proxy);
  }

  /// @notice Deploy proxy contract
  function _createProxy() internal returns (InitializableUpgradeabilityProxy) {
    address payable addr;
    bytes memory code = type(InitializableUpgradeabilityProxy).creationCode;

    assembly {
      addr := create(0, add(code, 0x20), mload(code))
      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }

    return InitializableUpgradeabilityProxy(addr);
  }

  uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20ExtendedUpgradeable is
    Initializable,
    ContextUpgradeable,
    IERC20Upgradeable,
    IERC20MetadataUpgradeable,
    OwnableUpgradeable
{
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __Ownable_init();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() public view returns (address) {
        return owner();
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override onlyOwner returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override onlyOwner returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override onlyOwner returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override onlyOwner returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual onlyOwner returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual onlyOwner returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
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

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
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

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
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

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
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

    function denominationAsset() external view returns (address);

    function setPoolLogic(address _poolLogic) external;

    function totalPoolValue() external view returns (uint256);

    function getAssetValue(address asset, uint256 amount) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPoolMember {
    function listInvestor() external view returns (address payable[] memory);

    function getTotalInvestor() external view returns (uint256);

    function addMember(address _poolLogic, address _investor) external;

    function removeMember(address _poolLogic, address _investor) external;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC20Extended {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./../interfaces/IPoolMember.sol";

contract PoolMember is IPoolMember {
    using SafeMathUpgradeable for uint256;

    event InvestorAdded(address investor);
    event InvestorRemoved(address investor);

    address payable[] private investors;
    mapping(address => uint256) private indexOfInvestor; // map stores 1-based

    function initialize() external {}

    /// @dev list investor in pool
    function listInvestor() public view returns (address payable[] memory) {
        return investors;
    }

    /// @dev get total of Investor
    function getTotalInvestor() public view returns (uint256) {
        return investors.length;
    }

    /// @dev add investor
    function addMember(address _poolLogic,address _investor) public override {
        require(IERC20Upgradeable(_poolLogic).balanceOf(_investor) != 0, "no share");
        if (indexOfInvestor[_investor] == 0) {
            investors.push(payable(_investor));
            indexOfInvestor[_investor] = investors.length;

            emit InvestorAdded(_investor);
        }
    }

    /// @dev Move the last element to the deleted spot.
    /// @dev Remove the last element.
    function removeMember(address _poolLogic,address _investor) public override {
        uint256 length = investors.length;
        uint256 index = indexOfInvestor[_investor].sub(1);

        require(length > 0, "can't remove from empty array");
        require(index < length, "invalid index");
        require(IERC20Upgradeable(_poolLogic).balanceOf(_investor) == 0, "cannot remove investor");

        address lastInvestor = investors[length.sub(1)];

        investors[index] = payable(lastInvestor);
        indexOfInvestor[lastInvestor] = index.add(1);
        indexOfInvestor[_investor] = 0;

        investors.pop();
        emit InvestorRemoved(_investor);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseUpgradeabilityProxy.sol";
import "./AddressHelper.sol";

/**
 * @title InitializableUpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with an initializer for initializing
 * implementation and init data.
 */
contract InitializableUpgradeabilityProxy is BaseUpgradeabilityProxy {
  using AddressHelper for address;

  /**
   * @dev Contract initializer.
   * @param _factory Address of the factory containing the implementation.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  function initialize(
    address _factory,
    bytes memory _data,
    uint8 _proxyType
  ) public payable {
    require(_implementation() == address(0), "Impl not zero");
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
    _setImplementation(_factory);
    _setProxyType(_proxyType);
    if (_data.length > 0) {
      _implementation().tryAssemblyDelegateCall(_data);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface HasLogic {
    function getLogic(uint8 _proxyType) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Proxy.sol";
import "./Address.sol";
import "./HasLogic.sol";

/**
 * @title BaseUpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract BaseUpgradeabilityProxy is Proxy {
  /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
  event Upgraded(address indexed implementation);

  /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
   * validated in the constructor.
   */
  bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  /**
   * @dev Storing type of the proxy, 1 for managerLogic, 2 for pool.
   */
  bytes32 internal constant PROXY_TYPE = 0x1000000000000000000000000000000000000000000000000000000000000000;

  /**
   * @notice Returns the current implementation.
   * @return impl Address of the current implementation
   */
  function _implementation() internal view override returns (address) {
    address factory;
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      factory := sload(slot)
    }

    // Begin custom modification
    if (factory == address(0x0)) return address(0x0); // If factory not initialized return empty

    return HasLogic(factory).getLogic(_proxyType());
  }

  /// @notice Return the proxy type.
  /// @return proxyType Return type of the proxy.
  function _proxyType() internal view returns (uint8 proxyType) {
    bytes32 slot = PROXY_TYPE;
    assembly {
      proxyType := sload(slot)
    }
  }

  /**
   * @notice Upgrades the proxy to a new implementation.
   * @param newImplementation Address of the new implementation.
   */
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  /**
   * @notice Sets the implementation address of the proxy.
   * @param newImplementation Address of the new implementation.
   */
  function _setImplementation(address newImplementation) internal {
    require(OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set implementation to EOA");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }

  /**
   * @notice Sets type of the proxy.
   * @param proxyType Type of the proxy.
   */
  function _setProxyType(uint8 proxyType) internal {
    bytes32 slot = PROXY_TYPE;

    assembly {
      sstore(slot, proxyType)
    }
  }
}

//        __  __    __  ________  _______    ______   ________
//       /  |/  |  /  |/        |/       \  /      \ /        |
//   ____$$ |$$ |  $$ |$$$$$$$$/ $$$$$$$  |/$$$$$$  |$$$$$$$$/
//  /    $$ |$$ |__$$ |$$ |__    $$ |  $$ |$$ | _$$/ $$ |__
// /$$$$$$$ |$$    $$ |$$    |   $$ |  $$ |$$ |/    |$$    |
// $$ |  $$ |$$$$$$$$ |$$$$$/    $$ |  $$ |$$ |$$$$ |$$$$$/
// $$ \__$$ |$$ |  $$ |$$ |_____ $$ |__$$ |$$ \__$$ |$$ |_____
// $$    $$ |$$ |  $$ |$$       |$$    $$/ $$    $$/ $$       |
//  $$$$$$$/ $$/   $$/ $$$$$$$$/ $$$$$$$/   $$$$$$/  $$$$$$$$/
//
// dHEDGE DAO - https://dhedge.org
//
// Copyright (c) 2021 dHEDGE DAO
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//
// SPDX-License-Identifier: MIT

// import "./BytesLib.sol";

pragma solidity ^0.8.0;

/**
 * @title A library for Address utils.
 */
library AddressHelper {
  /**
   * @notice try a contract call via assembly
   * @param to the contract address
   * @param data the call data
   * @return success if the contract call is successful or not
   */
  function tryAssemblyCall(address to, bytes memory data) internal returns (bool success) {
    assembly {
      success := call(gas(), to, 0, add(data, 0x20), mload(data), 0, 0)
      switch iszero(success)
      case 1 {
        let size := returndatasize()
        returndatacopy(0x00, 0x00, size)
        revert(0x00, size)
      }
    }
  }

  /**
   * @notice try a contract delegatecall via assembly
   * @param to the contract address
   * @param data the call data
   * @return success if the contract call is successful or not
   */
  function tryAssemblyDelegateCall(address to, bytes memory data) internal returns (bool success) {
    assembly {
      success := delegatecall(gas(), to, add(data, 0x20), mload(data), 0, 0)
      switch iszero(success)
      case 1 {
        let size := returndatasize()
        returndatacopy(0x00, 0x00, size)
        revert(0x00, size)
      }
    }
  }

  // /**
  //  * @notice try a contract call
  //  * @param to the contract address
  //  * @param data the call data
  //  * @return success if the contract call is successful or not
  //  */
  // function tryCall(address to, bytes memory data) internal returns (bool) {
  //   (bool success, bytes memory res) = to.call(data);

  //   // Get the revert message of the call and revert with it if the call failed
  //   require(success, _getRevertMsg(res));

  //   return success;
  // }

  // /**
  //  * @dev Get the revert message from a call
  //  * @notice This is needed in order to get the human-readable revert message from a call
  //  * @param response Response of the call
  //  * @return Revert message string
  //  */
  // function _getRevertMsg(bytes memory response) internal pure returns (string memory) {
  //     // If the response length is less than 68, then the transaction failed silently (without a revert message)
  //     if (response.length < 68) return "Transaction reverted silently";
  //     bytes memory revertData = response.slice(4, response.length - 4); // Remove the selector which is the first 4 bytes
  //     return abi.decode(revertData, (string)); // All that remains is the revert string
  // }
}

//
//        __  __    __  ________  _______    ______   ________
//       /  |/  |  /  |/        |/       \  /      \ /        |
//   ____$$ |$$ |  $$ |$$$$$$$$/ $$$$$$$  |/$$$$$$  |$$$$$$$$/
//  /    $$ |$$ |__$$ |$$ |__    $$ |  $$ |$$ | _$$/ $$ |__
// /$$$$$$$ |$$    $$ |$$    |   $$ |  $$ |$$ |/    |$$    |
// $$ |  $$ |$$$$$$$$ |$$$$$/    $$ |  $$ |$$ |$$$$ |$$$$$/
// $$ \__$$ |$$ |  $$ |$$ |_____ $$ |__$$ |$$ \__$$ |$$ |_____
// $$    $$ |$$ |  $$ |$$       |$$    $$/ $$    $$/ $$       |
//  $$$$$$$/ $$/   $$/ $$$$$$$$/ $$$$$$$/   $$$$$$/  $$$$$$$$/
//
// dHEDGE DAO - https://dhedge.org
//
// Copyright (c) 2021 dHEDGE DAO
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
abstract contract Proxy {
  /**
   * @notice Fallback function.
   * Implemented entirely in `_fallback`.
   */
  fallback() external payable {
    _fallback();
  }

  /**
   * @notice Receive function.
   * Implemented entirely in `_fallback`.
   */
  receive() external payable {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal view virtual returns (address);

  /**
   * @notice Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize())

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      // Copy the returned data.
      // Warning: OVM: Using RETURNDATASIZE or RETURNDATACOPY in user asm isn't guaranteed to work
      returndatacopy(0, 0, returndatasize())

      switch result
      // delegatecall returns 0 on error.
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  /**
   * @notice Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal virtual {}

  /**
   * @notice fallback implementation.
   * Extracted to enable manual triggering.
   */
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Utility library of inline functions on addresses
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/utils/Address.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Address implementation from an openzeppelin version.
 */
library OpenZeppelinUpgradesAddress {
  /**
   * @notice Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param account address of the account to check
   * @return whether the target address is a contract
   */
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solhint-disable-next-line no-inline-assembly
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}
// SPDX-License-Identifier: CC-BY-NC-4.0
pragma solidity 0.8.12;

import "./token/ReflectiveToken.sol";

contract Equity is ReflectiveToken {
    // V2 Changelog [Polygon V1]
    //  ReflectiveToken:
    //      Replace 'ERC20' with 'ERC20Permit' - This will allow EIP-2612 permits  
    //      Fixed L04 of 'deadAddress' - Renamed to 'DEAD_ADDRESS'
    //      Fixed L04 of 'maxFee' - Renamed to 'MAX_FEE'
    //      Updated 'function getTimeLockOf(address account) external view returns (bool)' - getTimeLockOf now returns the whole TimeLock struct
    //      Added 'function addExtraTimeToTimeLockOf(address account, uint256 extraTime) external onlySharedOwners' - Method to extend the TimeLock of still locked accounts (only team & marketing wallets are locked)'
    //      Added 'tokenPairOtherTokenAddress' - Used to change the default other token address from WETH to whatever is wanted, additionally WETH is now also supported as defaultReflectionTokenAddress inside the iReflectionTracker
    //          Added 'address tokenPairOtherTokenAddress_' parameter to the constructor - If set to address(0), WETH is used by default
    //          Added 'event TokenPairOtherTokenAddressUpdated(address indexed oldTokenPairOtherTokenAddress, address indexed newTokenPairOtherTokenAddress)' - Event for any changes made to _tokenPairOtherTokenAddress
    //          Added 'function getTokenPairOtherTokenAddress() external view returns (address)' - External getter for fetching the current other token address
    //          Added 'function setTokenPairOtherTokenAddress(address tokenPairOtherTokenAddress) external onlySharedOwners' - External setter for sharedOwners to change the desired other token address
    //      Added 'IReflective' - Used for the IReflectionTracker, this will deprecate the need of the IERC20 interface as the main interface for the ReflectiveToken
    //          Added 'function getBalanceOf(address account) external view returns (uint256) - External getter for fetching the current balance of an address
    //          Added 'function getTokenPairOtherTokenAddress() external view returns (address)' - See above under tokenPairOtherTokenAddress
    //      Updated constructor - Wrapped all parameters inside a struct to bypass compiler errors
    //      Updated processAll - It now supports a force flag to process all accounts, even accounts on claim cooldown
    // V3 Changelog [Polygon V1 RC]
    //  Overall:
    //      The overall system was changed to allow the holding of tokens of different fees. The RTT share is based on the accumulated value of tokens per fee.
    constructor(address[] memory teamWallets_, address marketingWallet_, address uniswapV2Router02Address_) ReflectiveToken(
        ConstructorArguments(
            "Equity",
            "Equity",
            1000000,
            teamWallets_,
            marketingWallet_,
            12500,
            uniswapV2Router02Address_,
            address(0),
            500,
            5,
            10
        )
    ) {}
}

// SPDX-License-Identifier: CC-BY-NC-4.0
pragma solidity 0.8.12;

import "../access/SharedOwnable.sol";
import "../interfaces/IReflectionTracker.sol";
import "../interfaces/IReflective.sol";
import "../libraries/IterableMappingUint256Uint256.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract ReflectiveToken is ERC20Permit, IReflective, SharedOwnable {
    struct ConstructorArguments {
        string name;
        string symbol;
        uint256 supply;
        address[] teamWallets;
        address marketingWallet;
        uint256 teamAndMarketingWalletReflectiveShare;
        address uniswapV2Router02Address;
        address tokenPairOtherTokenAddress;
        uint256 minimumTokenBalanceForSwapAndSendReflections;
        uint256 baseFee;
        uint256 defaultFee;
    }

    struct CustomFee {
        bool set;
        uint256 value;
    }

    struct ExcludedFromFeeCollection {
        bool asSender;
        bool asRecipient;
    }

    using IterableMappingUint256Uint256 for IterableMappingUint256Uint256.Map;

    event UniswapV2Router02Updated(address indexed oldUniswapV2Router02Address, address indexed newUniswapV2Router02Address);
    event TokenPairOtherTokenAddressUpdated(address indexed oldTokenPairOtherTokenAddress, address indexed newTokenPairOtherTokenAddress);
    event IsUniswapV2PairUpdated(address indexed account, bool oldIsUniswapV2Pair, bool newIsUniswapV2Pair);
    event IsFeeCollectorUpdated(address indexed account, bool oldIsFeeCollector, bool newIsFeeCollector);
    event ReflectionTrackerUpdated(address indexed oldReflectionTrackerAddress, address indexed newReflectionTrackerAddress);
    event MinimumTokenBalanceForSwapAndSendReflectionsUpdated(uint256 oldMinimumTokenBalanceForSwapAndSendReflections, uint256 newMinimumTokenBalanceForSwapAndSendReflections);
    event RegularTransferAllowed();
    event BaseFeeUpdated(uint256 oldBaseFee, uint256 newBaseFee);
    event DefaultFeeUpdated(uint256 oldDefaultFee, uint256 newDefaultFee);
    event FeeOfUpdated(address indexed account, uint256 oldFee, uint256 newFee);
    event ExcludedFromFeeCollectionOfUpdated(address indexed account, ExcludedFromFeeCollection oldExcludedFromFeeCollection, ExcludedFromFeeCollection newExcludedFromFeeCollection);
    event ExcludedFromFeeBalancesOfUpdated(address indexed account, bool oldExcludedFromFeeBalancesOf, bool newExcludedFromFeeBalancesOf);
    event AutomatedReflectionTrackerCallsUpdated(bool oldAutomatedReflectionTrackerCalls, bool newAutomatedReflectionTrackerCalls);

    event ReflectionsSent(address tokenAddress, uint256 tokenAmount);
    event ReflectionsProcessed(uint256 gasUsed, uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool automatic, address indexed processor);

    address constant private DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 constant private UINT256_MAX_VALUE = 2 ** 256 - 1;
    uint256 constant private MAX_FEE = 25;

    address[] private _teamWallets;
    address private _marketingWallet;
    IUniswapV2Router02 private _uniswapV2Router02;
    IUniswapV2Router02 private _uniswapV2Router02WithFeeSupport;
    address private _tokenPairOtherTokenAddress;
    mapping(address => bool) private _isUniswapV2Pair;
    mapping(address => bool) private _isFeeCollector;
    uint256 private _minimumTokenBalanceForSwapAndSendReflections;
    bool private _regularTransferAllowed;
    uint256 private _baseFee;
    uint256 private _defaultFee;
    IReflectionTracker private _reflectionTracker;
    mapping(address => bool) private _transferLockOf;
    mapping(address => CustomFee) private _feeOf;
    mapping(address => ExcludedFromFeeCollection) private _excludedFromFeeCollectionOf;
    mapping(address => bool) private _excludedFromFeeBalancesOf;
    mapping(address => IterableMappingUint256Uint256.Map) private _feeBalances;
    bool private _automatedReflectionTrackerCalls;
    bool private _inTransferSubStep;

    constructor(ConstructorArguments memory constructorArguments_) ERC20Permit(constructorArguments_.name) ERC20(constructorArguments_.name, constructorArguments_.symbol) {
        _teamWallets = constructorArguments_.teamWallets;
    	_marketingWallet = constructorArguments_.marketingWallet;
        _uniswapV2Router02 = IUniswapV2Router02(constructorArguments_.uniswapV2Router02Address);
        _tokenPairOtherTokenAddress = constructorArguments_.tokenPairOtherTokenAddress == address(0) ? _uniswapV2Router02.WETH() : constructorArguments_.tokenPairOtherTokenAddress;
        _minimumTokenBalanceForSwapAndSendReflections = constructorArguments_.minimumTokenBalanceForSwapAndSendReflections * (10**decimals());
        _regularTransferAllowed = false;
        _baseFee = constructorArguments_.baseFee;
        if (_baseFee > MAX_FEE)
            revert("ReflectiveToken: max base fee exceeded");
        _defaultFee = constructorArguments_.defaultFee;
        if (_defaultFee < _baseFee)
            revert("ReflectiveToken: min default fee subceeded");
        if (_defaultFee > MAX_FEE)
            revert("ReflectiveToken: max default fee exceeded");

        address uniswapV2Pair = _getOrCreateTokenPair(_uniswapV2Router02, address(this), _tokenPairOtherTokenAddress);
        _isUniswapV2Pair[uniswapV2Pair] = true;
        _isFeeCollector[uniswapV2Pair] = true;
        _excludedFromFeeBalancesOf[uniswapV2Pair] = true;
        _excludedFromFeeCollectionOf[address(this)] = ExcludedFromFeeCollection(true, true);
        _excludedFromFeeCollectionOf[DEAD_ADDRESS] = ExcludedFromFeeCollection(true, true);
        _excludedFromFeeCollectionOf[constructorArguments_.uniswapV2Router02Address] = ExcludedFromFeeCollection(true, true);
        _excludedFromFeeBalancesOf[address(this)] = true;
        _excludedFromFeeBalancesOf[DEAD_ADDRESS] = true;
        _excludedFromFeeBalancesOf[constructorArguments_.uniswapV2Router02Address] = true;

        for (uint256 i = 0; i < _teamWallets.length; i++)
            _setDeveloperWalletOptions(_teamWallets[i]);
        _setDeveloperWalletOptions(_marketingWallet);
        _updateDeveloperWalletReflectiveShares(constructorArguments_.teamAndMarketingWalletReflectiveShare);

        _automatedReflectionTrackerCalls = true;

        _excludedFromFeeCollectionOf[msg.sender] = ExcludedFromFeeCollection(true, true);
        _excludedFromFeeBalancesOf[msg.sender] = true;
        _mint(msg.sender, constructorArguments_.supply * (10**decimals()));
    }

    modifier onlyUniswapV2Router02WithFeeSupport() {
        require(address(_uniswapV2Router02WithFeeSupport) == msg.sender, "ReflectionTrackerToken: caller is not the uniswap v2 router 02 with fee support");
        _;
    }

    receive() external payable {}

    function getMaxFee() external pure returns (uint256) {
        return MAX_FEE;
    }

    function getBalanceOf(address account) external view returns (uint256) {
        return balanceOf(account);
    }

    function getFeeBalancesOf(address account) external view returns (SimpleFeeBalanceMap memory feeBalances) {
        if (_excludedFromFeeBalancesOf[account])
            return feeBalances;

        uint256 length = _feeBalances[account].keys.length;
        feeBalances = SimpleFeeBalanceMap(length, new uint256[](length), new uint256[](length));
        for (uint256 i = 0; i < length; i++) {
            feeBalances.keys[i] = _feeBalances[account].keys[i];
            feeBalances.values[i] = _feeBalances[account].values[feeBalances.keys[i]];
        }
    }

    function getUniswapV2Router02Address() external view returns (address) {
        return address(_uniswapV2Router02);
    }

    function setUniswapV2Router02Address(address uniswapV2Router02Address) external onlySharedOwners {
        address oldUniswapV2Router02Address = address(_uniswapV2Router02);
        if (oldUniswapV2Router02Address != uniswapV2Router02Address) {
            IUniswapV2Router02 uniswapV2Router02 = IUniswapV2Router02(uniswapV2Router02Address);

            address oldUniswapV2Pair = _getOrCreateTokenPair(_uniswapV2Router02, address(this), _tokenPairOtherTokenAddress);
            address uniswapV2Pair = _getOrCreateTokenPair(uniswapV2Router02, address(this), _tokenPairOtherTokenAddress);
            if (oldUniswapV2Pair != uniswapV2Pair) {
                _setIsUniswapV2Pair(oldUniswapV2Pair, false);
                _setIsUniswapV2Pair(uniswapV2Pair, true);
            }

            _uniswapV2Router02 = uniswapV2Router02;
            emit UniswapV2Router02Updated(oldUniswapV2Router02Address, uniswapV2Router02Address);
            if (address(_reflectionTracker) != address(0))
                _reflectionTracker.setUniswapV2Router02Address(uniswapV2Router02Address);
        }
    }

    function getUniswapV2Router02WithFeeSupport() external view returns (address) {
        return address(_uniswapV2Router02WithFeeSupport);
    }

    function setUniswapV2Router02WithFeeSupport(address uniswapV2Router02WithFeeSupport) external onlySharedOwners {
        _uniswapV2Router02WithFeeSupport = IUniswapV2Router02(uniswapV2Router02WithFeeSupport);
    }

    function getTokenPairOtherTokenAddress() external view returns (address) {
        return _tokenPairOtherTokenAddress;
    }

    function setTokenPairOtherTokenAddress(address tokenPairOtherTokenAddress) external onlySharedOwners {
        if (tokenPairOtherTokenAddress == address(0))
            tokenPairOtherTokenAddress = _uniswapV2Router02.WETH();

        address oldTokenPairOtherTokenAddress = _tokenPairOtherTokenAddress;
        if (oldTokenPairOtherTokenAddress != tokenPairOtherTokenAddress) {
            IERC20 liquidityPairToken = IERC20(tokenPairOtherTokenAddress);

            liquidityPairToken.totalSupply();
            address oldUniswapV2Pair = _getOrCreateTokenPair(_uniswapV2Router02, address(this), _tokenPairOtherTokenAddress);
            address uniswapV2Pair = _getOrCreateTokenPair(_uniswapV2Router02, address(this), tokenPairOtherTokenAddress);
            if (oldUniswapV2Pair != uniswapV2Pair)
                _setIsUniswapV2Pair(uniswapV2Pair, true);

            _tokenPairOtherTokenAddress = tokenPairOtherTokenAddress;
            emit TokenPairOtherTokenAddressUpdated(oldTokenPairOtherTokenAddress, tokenPairOtherTokenAddress);
        }
    }

    function getIsUniswapV2Pair(address account) external view returns (bool) {
        return _isUniswapV2Pair[account];
    }

    function setIsUniswapV2Pair(address account, bool isUniswapV2Pair) external onlySharedOwners {
        _setIsUniswapV2Pair(account, isUniswapV2Pair);
    }

    function _setIsUniswapV2Pair(address account, bool isUniswapV2Pair) private {
        bool oldIsUniswapV2Pair = _isUniswapV2Pair[account];
        if (oldIsUniswapV2Pair != isUniswapV2Pair) {
            _isUniswapV2Pair[account] = isUniswapV2Pair;
            _setIsFeeCollector(account, isUniswapV2Pair);
            _setExcludedFromFeeCollectionOf(account, ExcludedFromFeeCollection(!isUniswapV2Pair, !isUniswapV2Pair));
            _setExcludedFromFeeBalancesOf(account, isUniswapV2Pair);
            emit IsUniswapV2PairUpdated(account, oldIsUniswapV2Pair, isUniswapV2Pair);
            if (address(_reflectionTracker) != address(0))
                _reflectionTracker.setExcludedFromReflectionsOf(account, isUniswapV2Pair);
        }
    }

    function getIsFeeCollector(address account) external view returns (bool) {
        return _isFeeCollector[account];
    }

    function setIsFeeCollector(address account, bool isFeeCollector) external onlySharedOwners {
        _setIsFeeCollector(account, isFeeCollector);
    }

    function _setIsFeeCollector(address account, bool isFeeCollector) private {
        bool oldIsFeeCollector = _isFeeCollector[account];
        if (oldIsFeeCollector != isFeeCollector) {
            _isFeeCollector[account] = isFeeCollector;
            emit IsFeeCollectorUpdated(account, oldIsFeeCollector, isFeeCollector);
        }
    }

    function getMinimumTokenBalanceForSwapAndSendReflections() external view returns (uint256) {
        return _minimumTokenBalanceForSwapAndSendReflections;
    }

    function setMinimumTokenBalanceForSwapAndSendReflections(uint256 minimumTokenBalanceForSwapAndSendReflections) external onlySharedOwners {
        minimumTokenBalanceForSwapAndSendReflections *= 10**decimals();
        uint256 oldMinimumTokenBalanceForSwapAndSendReflections = _minimumTokenBalanceForSwapAndSendReflections;
        if (oldMinimumTokenBalanceForSwapAndSendReflections != minimumTokenBalanceForSwapAndSendReflections) {
            _minimumTokenBalanceForSwapAndSendReflections = minimumTokenBalanceForSwapAndSendReflections;
            emit MinimumTokenBalanceForSwapAndSendReflectionsUpdated(oldMinimumTokenBalanceForSwapAndSendReflections, minimumTokenBalanceForSwapAndSendReflections);
        }
    }

    function isRegularTransferAllowed() external view returns (bool) {
        return _regularTransferAllowed;
    }

    function allowRegularTransfer() external onlySharedOwners {
        if (!_regularTransferAllowed) {
            _regularTransferAllowed = true;
            emit RegularTransferAllowed();
        }
    }

    function getBaseFee() external view returns (uint256) {
        return _baseFee;
    }

    function setBaseFee(uint256 baseFee) external onlySharedOwners {
        if (baseFee > MAX_FEE)
            revert("ReflectiveToken: max base fee exceeded");

        uint256 oldBaseFee = _baseFee;
        if (oldBaseFee != baseFee) {
            _baseFee = baseFee;
            emit BaseFeeUpdated(oldBaseFee, baseFee);
        }
    }

    function getDefaultFee() external view returns (uint256) {
        return _defaultFee;
    }

    function setDefaultFee(uint256 defaultFee) external onlySharedOwners {
        if (defaultFee < _baseFee)
            revert("ReflectiveToken: min default fee subceeded");
        if (defaultFee > MAX_FEE)
            revert("ReflectiveToken: max default fee exceeded");

        uint256 oldDefaultFee = _defaultFee;
        if (oldDefaultFee != defaultFee) {
            _defaultFee = defaultFee;
            emit DefaultFeeUpdated(oldDefaultFee, defaultFee);
        }
    }

    function getReflectionTrackerAddress() external view returns (address) {
        return address(_reflectionTracker);
    }

    function setReflectionTrackerAddress(address reflectionTrackerAddress) external onlySharedOwners {
        address oldReflectionTrackerAddress = address(_reflectionTracker);
        if (oldReflectionTrackerAddress != reflectionTrackerAddress) {
            IReflectionTracker reflectionTracker = IReflectionTracker(reflectionTrackerAddress);
            if (!reflectionTracker.isBoundTo(address(this)))
                revert("ReflectiveToken: reflection tracker is not bound to this contract");

            _reflectionTracker = reflectionTracker;
            emit ReflectionTrackerUpdated(oldReflectionTrackerAddress, reflectionTrackerAddress);
        }
    }

    function getFee() external view returns (uint256) {
        return _getFeeOf(msg.sender);
    }

    function getFeeOf(address account) external view returns (uint256) {
        return _getFeeOf(account);
    }

    function setFee(uint256 fee) external {
        _setFeeOf(msg.sender, fee);
    }

    function setFeeOf(address account, uint256 fee) external onlySharedOwners {
        _setFeeOf(account, fee);
    }

    function getCustomFeeOf(address account) external view returns (bool set, uint256 value) {
        set = _feeOf[account].set;
        value = _feeOf[account].value;
    }

    function setCustomFeeOf(address account, bool set, uint256 value) external onlyUniswapV2Router02WithFeeSupport {
        _feeOf[account] = CustomFee(set, value);
    }

    function getExcludedFromFeeCollectionOf(address account) external view returns (ExcludedFromFeeCollection memory) {
        return _excludedFromFeeCollectionOf[account];
    }

    function setExcludedFromFeeCollectionOf(address account, ExcludedFromFeeCollection memory excludedFromFeeCollection) external onlySharedOwners {
        return _setExcludedFromFeeCollectionOf(account, excludedFromFeeCollection);
    }

    function getExcludedFromFeeBalancesOf(address account) external view returns (bool) {
        return _excludedFromFeeBalancesOf[account];
    }

    function setExcludedFromFeeBalancesOf(address account, bool excludedFromFeeBalancesOf) external onlySharedOwners {
        return _setExcludedFromFeeBalancesOf(account, excludedFromFeeBalancesOf);
    }

    function getAutomatedReflectionTrackerCalls() external view returns (bool) {
        return _automatedReflectionTrackerCalls;
    }

    function setAutomatedReflectionTrackerCalls(bool automatedReflectionTrackerCalls) external onlySharedOwners {
        bool oldAutomatedReflectionTrackerCalls = _automatedReflectionTrackerCalls;
        if (oldAutomatedReflectionTrackerCalls != automatedReflectionTrackerCalls) {
            _automatedReflectionTrackerCalls = automatedReflectionTrackerCalls;
            emit AutomatedReflectionTrackerCallsUpdated(oldAutomatedReflectionTrackerCalls, automatedReflectionTrackerCalls);
        }
    }

    function swapAndSendReflections(uint256 amount) external onlySharedOwners {
        _swapAndSendReflections(amount);
    }

	function processAll(uint256 processingGas, bool force) external onlySharedOwners {
        if (address(_reflectionTracker) != address(0)) {
            (uint256 gasUsed, uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = _reflectionTracker.processAll(processingGas, force);
            emit ReflectionsProcessed(gasUsed, iterations, claims, lastProcessedIndex, false, tx.origin);
        }
    }

    function swapAndSendReflectionsAndProcessAll(uint256 amount, uint256 processingGas, bool force) external onlySharedOwners {
        _swapAndSendReflections(amount);
        if (address(_reflectionTracker) != address(0)) {
            (uint256 gasUsed, uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = _reflectionTracker.processAll(processingGas, force);
            emit ReflectionsProcessed(gasUsed, iterations, claims, lastProcessedIndex, false, tx.origin);
        }
    }

    function updateDeveloperWalletReflectiveShares(uint256 reflectiveShare) external onlySharedOwners {
        _updateDeveloperWalletReflectiveShares(reflectiveShare);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount, CustomFee(false, 0));
        return true;
    }

    function transferWithExactFee(address recipient, uint256 amount, uint256 fee) external returns (bool) {
        _transfer(_msgSender(), recipient, amount, CustomFee(true, fee));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount, CustomFee(false, 0));

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ReflectiveToken: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function transferFromWithExactFee(address sender, address recipient, uint256 amount, uint256 fee) external returns (bool) {
        _transfer(sender, recipient, amount, CustomFee(true, fee));

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ReflectiveToken: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount, CustomFee memory fee) private {
        require(!_transferLockOf[sender], "ReflectiveToken: transfer from a locked address");
        require(!_transferLockOf[recipient], "ReflectiveToken: transfer to a locked address");

        bool transferExcludedFromFeeCollections = _excludedFromFeeCollectionOf[sender].asSender || _excludedFromFeeCollectionOf[recipient].asRecipient;
        require(_regularTransferAllowed || transferExcludedFromFeeCollections, "ReflectiveToken: transfer with fees");

        if (_automatedReflectionTrackerCalls && !_inTransferSubStep && _isUniswapV2Pair[recipient] && balanceOf(address(this)) >= _minimumTokenBalanceForSwapAndSendReflections) {
            _inTransferSubStep = true;
            _swapAndSendReflections((_minimumTokenBalanceForSwapAndSendReflections / 100) * _getRandomNumber());
            _inTransferSubStep = false;
        }

        bool transferCollectsFees = !transferExcludedFromFeeCollections && (_isFeeCollector[sender] || _isFeeCollector[recipient]);
        if (!_excludedFromFeeBalancesOf[sender] || !_excludedFromFeeBalancesOf[recipient] || transferCollectsFees) {
            SimpleFeeBalanceMap memory feeBalances = _getSuitableFeeBalances(sender, recipient, amount, fee);
            (uint256 totalFeeValue, uint256 totalAmountAfterFees) = _applyFeeBalances(sender, recipient, transferCollectsFees, feeBalances);
            if (totalFeeValue > 0) {
                uint256 feePercentage = (totalFeeValue * 100) / amount;
                require(feePercentage <= MAX_FEE, "ReflectiveToken: max fee exceeded");

                amount -= totalFeeValue;
                _transfer(sender, address(this), totalFeeValue);
            }
            require(amount == totalAmountAfterFees, "ReflectiveToken: amount mismatch after fees");
        }

        _transfer(sender, recipient, amount);

        try _reflectionTracker.refreshBalanceOf(sender) {} catch {}
        try _reflectionTracker.refreshBalanceOf(recipient) {} catch {}

        if (_automatedReflectionTrackerCalls && !_inTransferSubStep) {
            _inTransferSubStep = true;
            try _reflectionTracker.processAll() returns (uint256 gasUsed, uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ReflectionsProcessed(gasUsed, iterations, claims, lastProcessedIndex, true, tx.origin);
            } catch {}
            _inTransferSubStep = false;
        }
    }

    function _getSuitableFeeBalances(address sender, address recipient, uint256 amount, CustomFee memory fee) private view returns (SimpleFeeBalanceMap memory feeBalances) {
        if (fee.set || _isUniswapV2Pair[sender] || _excludedFromFeeBalancesOf[sender]) {
            feeBalances = SimpleFeeBalanceMap(1, new uint256[](1), new uint256[](1));
            feeBalances.keys[0] = fee.set ? fee.value : _getFeeOf(recipient);
            feeBalances.values[0] = amount;
        } else {
            uint256[] memory keys = _feeBalances[sender].keys;
            if (keys.length < 10)
                _insertionSort(keys);
            else
                _uniqueSort(keys, keys.length);

            feeBalances = SimpleFeeBalanceMap(keys.length, new uint256[](keys.length), new uint256[](keys.length));
            uint256 missingAmount = amount;
            uint256 localFee;
            uint256 localFeeAmount;
            for (uint256 i = 0; i < feeBalances.length; i++) {
                if (missingAmount > 0) {
                    localFee = keys[i];
                    localFeeAmount = _feeBalances[sender].values[localFee];
                    if (localFeeAmount > missingAmount)
                        localFeeAmount = missingAmount;

                    feeBalances.keys[i] = localFee;
                    feeBalances.values[i] = localFeeAmount;
                    missingAmount -= localFeeAmount;
                } else {
                    feeBalances.length = i;
                    break;
                }
            }
            require(missingAmount == 0, "ReflectiveToken: transfer amount exceeds fee balance");
        }
        require(feeBalances.keys.length == feeBalances.values.length, "ReflectiveToken: array mismatch");
    }

    function _insertionSort(uint256[] memory data) private pure {
        uint256 length = data.length;
        for (uint256 i = 1; i < length; i++) {
            uint256 key = data[i];
            uint256 j = i - 1;
            while ((int(j) >= 0) && (data[j] > key)) {
                data[j + 1] = data[j];
                j = j > 0 ? j - 1 : UINT256_MAX_VALUE;
            }
            data[j == UINT256_MAX_VALUE ? 0 : j + 1] = key;
        }
    }

    function _uniqueSort(uint256[] memory data, uint256 setSize) private pure {
        uint256 length = data.length;
        bool[] memory set = new bool[](setSize);
        for (uint256 i = 0; i < length; i++) {
            set[data[i]] = true;
        }
        uint256 n = 0;
        for (uint256 i = 0; i < setSize; i++) {
            if (set[i]) {
                data[n] = i;
                if (++n >= length) break;
            }
        }
    }

    function _applyFeeBalances(address sender, address recipient, bool transferCollectsFees, SimpleFeeBalanceMap memory feeBalances) private returns (uint256 totalFeeValue, uint256 totalAmountAfterFees) {
        uint256 localFee;
        uint256 localFeeAmount;
        uint256 localNewFeeAmount;
        for (uint256 i = 0; i < feeBalances.length; i++) {
            localFee = feeBalances.keys[i];
            localFeeAmount = feeBalances.values[i];

            if (!_excludedFromFeeBalancesOf[sender]) {
                require(_feeBalances[sender].values[localFee] >= localFeeAmount, "ReflectiveToken: transfer amount exceeds fee balance");
                localNewFeeAmount = _feeBalances[sender].values[localFee] - localFeeAmount;
                if (localNewFeeAmount == 0)
                    _feeBalances[sender].remove(localFee);
                else
                    _feeBalances[sender].set(localFee, localNewFeeAmount);
            }
            
            if (transferCollectsFees) {
                totalFeeValue += (localFee * localFeeAmount) / 100;
                localFeeAmount -= (localFee * localFeeAmount) / 100;
            }

            if (!_excludedFromFeeBalancesOf[recipient]) {
                localNewFeeAmount = _feeBalances[recipient].values[localFee] + localFeeAmount;
                _feeBalances[recipient].set(localFee, localNewFeeAmount);
            }

            totalAmountAfterFees += localFeeAmount;
        }
    }

    function _getOrCreateTokenPair(IUniswapV2Router02 uniswapV2Router02, address tokenAddress, address otherTokenAddress) private returns (address) {
        address tokenPair = IUniswapV2Factory(uniswapV2Router02.factory()).getPair(tokenAddress, otherTokenAddress);
        if (tokenPair == address(0))
            tokenPair = IUniswapV2Factory(uniswapV2Router02.factory()).createPair(tokenAddress, otherTokenAddress);

        return tokenPair;
    }

    function _setDeveloperWalletOptions(address account) private {
        setSharedOwner(account);
        _excludedFromFeeCollectionOf[account] = ExcludedFromFeeCollection(true, true);
        _transferLockOf[account] = true;
    }

    function _updateDeveloperWalletReflectiveShares(uint256 reflectiveShare) private {
        reflectiveShare *= 10**decimals();

        for (uint256 i = 0; i < _teamWallets.length; i++) {
            delete _feeBalances[_teamWallets[i]];
            _feeBalances[_teamWallets[i]].set(MAX_FEE, reflectiveShare);
            if (address(_reflectionTracker) != address(0))
                try _reflectionTracker.refreshBalanceOf(_teamWallets[i]) {} catch {}
        }

        delete _feeBalances[_marketingWallet];
        _feeBalances[_marketingWallet].set(MAX_FEE, reflectiveShare * _teamWallets.length);
        if (address(_reflectionTracker) != address(0))
            try _reflectionTracker.refreshBalanceOf(_marketingWallet) {} catch {}
    }

    function _getFeeOf(address account) private view returns (uint256) {
        return _feeOf[account].set ? _feeOf[account].value : _defaultFee;
    }

    function _setFeeOf(address account, uint256 fee) private {
        if (fee < _baseFee)
            revert("ReflectiveToken: min fee subceeded");
        if (fee > MAX_FEE)
            revert("ReflectiveToken: max fee exceeded");

        bool oldSet = _feeOf[account].set;
        uint256 oldFee = oldSet ? _feeOf[account].value : _defaultFee;
        if (!oldSet || oldFee != fee) {
            _feeOf[account] = CustomFee(true, fee);
            emit FeeOfUpdated(account, oldFee, fee);
        }
    }

    function _setExcludedFromFeeCollectionOf(address account, ExcludedFromFeeCollection memory excludedFromFeeCollection) private {
        ExcludedFromFeeCollection memory oldExcludedFromFeeCollection = _excludedFromFeeCollectionOf[account];
        if (oldExcludedFromFeeCollection.asSender != excludedFromFeeCollection.asSender || oldExcludedFromFeeCollection.asRecipient != excludedFromFeeCollection.asRecipient) {
            _excludedFromFeeCollectionOf[account] = excludedFromFeeCollection;
            emit ExcludedFromFeeCollectionOfUpdated(account, oldExcludedFromFeeCollection, excludedFromFeeCollection);
        }
    }

    function _setExcludedFromFeeBalancesOf(address account, bool excludedFromFeeBalancesOf) private {
        bool oldExcludedFromFeeBalancesOf = _excludedFromFeeBalancesOf[account];
        if (oldExcludedFromFeeBalancesOf != excludedFromFeeBalancesOf) {
            _excludedFromFeeBalancesOf[account] = excludedFromFeeBalancesOf;
            emit ExcludedFromFeeBalancesOfUpdated(account, oldExcludedFromFeeBalancesOf, excludedFromFeeBalancesOf);
        }
    }

    function _swapAndSendReflections(uint256 amount) private {
        if (address(_reflectionTracker) == address(0))
            return;

        IERC20 defaultReflectionTokenContract = IERC20(_reflectionTracker.getDefaultReflectionTokenAddress());

        address[] memory path;
        if (_tokenPairOtherTokenAddress == address(defaultReflectionTokenContract)) {
            path = new address[](2);
            path[0] = address(this);
            path[1] = _tokenPairOtherTokenAddress;
        } else {
            path = new address[](3);
            path[0] = address(this);
            path[1] = _tokenPairOtherTokenAddress;
            path[2] = address(defaultReflectionTokenContract);
        }

        _approve(address(this), address(_uniswapV2Router02), amount);

        address reflectionTrackerAddress = address(_reflectionTracker);
        uint256 defaultReflectionTokenAmountBeforeSwap = defaultReflectionTokenContract.balanceOf(reflectionTrackerAddress);
        _uniswapV2Router02.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, reflectionTrackerAddress, block.timestamp);
        uint256 defaultReflectionTokenAmountAfterSwap = defaultReflectionTokenContract.balanceOf(reflectionTrackerAddress);

        if (defaultReflectionTokenAmountAfterSwap > defaultReflectionTokenAmountBeforeSwap) {
            uint256 defaultReflectionTokenAmount = defaultReflectionTokenAmountAfterSwap -defaultReflectionTokenAmountBeforeSwap;
            _reflectionTracker.transferReflections(defaultReflectionTokenAmount);
            emit ReflectionsSent(address(defaultReflectionTokenContract), defaultReflectionTokenAmount);
        }
    }
    
    function _getRandomNumber() private view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) + block.number)));
        uint256 number = (seed - ((seed / 100) * 100));
        return number == 0 ? 1 : number;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

library IterableMappingUint256Uint256 {
    struct Map {
        uint256[] keys;
        mapping(uint256 => uint256) values;
        mapping(uint256 => uint256) indexOf;
        mapping(uint256 => bool) inserted;
    }

    function set(Map storage map, uint256 key, uint256 val) internal {
        if (map.inserted[key])
            map.values[key] = val;
        else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, uint256 key) internal {
        if (!map.inserted[key])
            return;

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        uint256 lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

// SPDX-License-Identifier: CC-BY-NC-4.0
pragma solidity 0.8.12;

import "./IFeeable.sol";

interface IReflective is IFeeable {
  struct SimpleFeeBalanceMap {
    uint256 length;
    uint256[] keys;
    uint256[] values;
  }

  function getBalanceOf(address account) external view returns (uint256);
  function getFeeBalancesOf(address account) external view returns (SimpleFeeBalanceMap memory);

  function getTokenPairOtherTokenAddress() external view returns (address);
}

// SPDX-License-Identifier: CC-BY-NC-4.0
pragma solidity 0.8.12;

interface IReflectionTracker {
  struct AccountInfo {
    address account;
    int256 index;
    int256 iterationsUntilProcessed;
    uint256 withdrawableReflections;
    uint256 totalReflections;
    uint256 lastClaimTimestamp;
    uint256 nextClaimTimestamp;
    uint256 secondsUntilAutoClaimAvailable;
  }

  event UniswapV2Router02AddressUpdated(address indexed oldUniswapV2Router02Address, address indexed newUniswapV2Router02Address);
  event DefaultReflectionTokenAddressUpdated(address indexed oldDefaultReflectionTokenAddress, address indexed newDefaultReflectionTokenAddress);
  event ClaimCooldownUpdated(uint256 oldClaimCooldown, uint256 newClaimCooldown);
  event MinimumTokenBalanceForReflectionsUpdated(uint256 oldMinimumTokenBalanceForReflections, uint256 newMinimumTokenBalanceForReflections);
  event ExcludedReflectionStateOfBNBUpdated(bool oldExcludedReflectionStateOfBNB, bool newExcludedReflectionStateOfBNB);
  event ExcludedReflectionTokenStateUpdated(address indexed account, bool oldExcludedReflectionTokenState, bool newExcludedReflectionTokenState);
  event ExcludedFromReflectionsUpdated(address indexed account, bool oldExcludedFromReflections, bool newExcludedFromReflections);
  event ProcessingGasUpdated(uint256 oldProcessingGas, uint256 newProcessingGas);

  event ReflectionInBNBUpdated(address indexed account, bool oldReflectionInBNB, bool newReflectionInBNB);
  event ReflectionTokenAddressUpdated(address indexed account, address oldReflectionTokenAddress, address newReflectionTokenAddress);

  event ReflectionsTransferred(address indexed account, uint256 defaultReflectionTokenAmount);

  event ReflectionBNBClaimed(address indexed account, uint256 bnbAmount, bool automatic);
  event ReflectionTokenClaimed(address indexed account, address tokenAddress, uint256 tokenAmount, bool automatic);

  function isBoundTo(address reflectiveAddress) external view returns (bool);
  function bindTo(address reflectiveAddress) external;

  function getBalanceOf(address account) external view returns (uint256);
  function refreshBalanceOf(address account) external;
  function refreshBalance() external;

  function getUniswapV2Router02Address() external view returns (address);
  function setUniswapV2Router02Address(address uniswapV2Router02Address) external;
  function getDefaultReflectionTokenAddress() external view returns (address);
  function setDefaultReflectionTokenAddress(address defaultReflectionTokenAddress) external;
  function getClaimCooldown() external view returns (uint256);
  function setClaimCooldown(uint256 claimCooldown) external;
  function getMinimumTokenBalanceForReflections() external view returns (uint256);
  function setMinimumTokenBalanceForReflections(uint256 minimumTokenBalanceForReflections) external;
  function getExcludedReflectionStateOfBNB() external view returns (bool);
  function setExcludedReflectionStateOfBNB(bool excludedReflectionStateOfBNB) external;
  function getExcludedReflectionTokenStateOf(address account) external view returns (bool);
  function setExcludedReflectionTokenStateOf(address account, bool excludedReflectionTokenState) external;
  function getExcludedFromReflectionsOf(address account) external view returns (bool);
  function setExcludedFromReflectionsOf(address account, bool excludedFromReflections) external;
  function getProcessingGas() external view returns (uint256);
  function setProcessingGas(uint256 processingGas) external;

  function getReflectionInBNB() external view returns (bool);
  function setReflectionInBNB(bool reflectionInBNB) external;
  function getReflectionTokenAddress() external view returns (address);
  function setReflectionTokenAddress(address reflectionTokenAddress) external;

  function getNumberOfHolders() external view returns (uint256);
  function getLastProcessedIndex() external view returns (uint256);
  function getTotalReflectionsTransferred() external view returns (uint256);

  function getWithdrawnReflectionsOf(address account) external view returns (uint256);
  function getWithdrawableReflectionsOf(address account) external view returns (uint256);

  function getAccountInfoOf(address account) external view returns (AccountInfo memory);
  function getAccountInfoAtIndex(uint256 index) external view returns (AccountInfo memory);

  function transferReflections() external payable;
  function transferReflections(uint256 amount) external;

  function process() external returns (bool);
  function processAll() external returns (uint256 gasUsed, uint256 iterations, uint256 claims, uint256 lastProcessedIndex);
  function processAll(bool force) external returns (uint256 gasUsed, uint256 iterations, uint256 claims, uint256 lastProcessedIndex);
  function processAll(uint256 processingGas, bool force) external returns (uint256 gasUsed, uint256 iterations, uint256 claims, uint256 lastProcessedIndex);
}

// SPDX-License-Identifier: CC-BY-NC-4.0
pragma solidity >=0.6.2;

interface IFeeable {
  function getMaxFee() external pure returns (uint256);

  function getBaseFee() external view returns (uint256);

  function getCustomFeeOf(address account) external view returns (bool set, uint256 value);
  function setCustomFeeOf(address account, bool set, uint256 value) external;
}

// SPDX-License-Identifier: CC-BY-NC-4.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract SharedOwnable is Ownable {
    address private _creator;
    mapping(address => bool) private _sharedOwners;
    
    event SharedOwnershipAdded(address indexed sharedOwner);

    constructor() Ownable() {
        _creator = msg.sender;
        _setSharedOwner(msg.sender);
        renounceOwnership();
    }

    modifier onlySharedOwners() {
        require(_sharedOwners[msg.sender], "SharedOwnable: caller is not a shared owner");
        _;
    }

    function getCreator() external view returns (address) {
        return _creator;
    }

    function isSharedOwner(address account) external view returns (bool) {
        return _sharedOwners[account];
    }

    function setSharedOwner(address account) internal onlySharedOwners {
        _setSharedOwner(account);
    }

    function _setSharedOwner(address account) private {
        _sharedOwners[account] = true;
        emit SharedOwnershipAdded(account);
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

pragma solidity >=0.6.2;

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

pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
contract ERC20 is Context, IERC20, IERC20Metadata {
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
    constructor(string memory name_, string memory symbol_) {
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}
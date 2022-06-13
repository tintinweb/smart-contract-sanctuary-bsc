//SPDX-License-Identifier: LICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.7.0;
pragma abicoder v2;
import "./interfaces/ERC20Interface.sol";
import "./interfaces/ICard.sol";
import "./interfaces/IConverter.sol";
import "./MultiSigOwner.sol";
import "./Manager.sol";

contract MarketManager is MultiSigOwner, Manager {
    // default market , which is used when user didn't select any market for his main market
    address public defaultMarket;
    /// @notice A list of all assets
    address[] public allMarkets;
    // enable or disable for each market
    mapping(address => bool) public marketEnable;
    // store user's main asset used when user make payment.
    mapping(address => address) public userMainMarket;

    address public WETH;
    // // this is main currency for master wallet, master wallet will get always this token. normally we use USDC for this token.
    address public USDC;
    // // this is okse token address, which is used for setting of user's daily level and cashback.
    address public OKSE;
    // Set whether user can use okse as payment asset. normally it is false.
    bool public oksePaymentEnable;
    bool public emergencyStop;
    uint256 public slippage;
    address public immutable converter;
    modifier marketSupported(address market) {
        require(isMarketExist(market), "mns");
        _;
    }
    // verified
    modifier marketEnabled(address market) {
        require(marketEnable[market], "mdnd");
        _;
    }

    event MarketAdded(address market);
    event DefaultMarketChanged(address newMarket);
    event TokenAddressChanged(address okse, address usdc);
    event EmergencyStopChanged(bool emergencyStop);
    event OkseAsPaymentChanged(bool oksePaymentEnable);
    event MarketEnableChanged(address market, bool bEnable);
    event SlippageChanged(uint256 slippage);

    constructor(
        address _cardContract,
        address _WETH,
        address _usdcAddress,
        address _okseAddress,
        address _converter
    ) Manager(_cardContract) {
        WETH = _WETH;
        USDC = _usdcAddress;
        OKSE = _okseAddress;
        _addMarketInternal(WETH);
        _addMarketInternal(USDC);
        _addMarketInternal(OKSE);
        defaultMarket = WETH;
        converter = _converter;
        slippage = 1000; // 10%
    }

    //verified
    function _addMarketInternal(address assetAddr) internal {
        for (uint256 i = 0; i < allMarkets.length; i++) {
            require(allMarkets[i] != assetAddr, "maa");
        }
        allMarkets.push(assetAddr);
        marketEnable[assetAddr] = true;
        emit MarketAdded(assetAddr);
    }

    ////////////////////////// Read functions /////////////////////////////////////////////////////////////
    function isMarketExist(address market) public view returns (bool) {
        bool marketExist = false;
        for (uint256 i = 0; i < allMarkets.length; i++) {
            if (allMarkets[i] == market) {
                marketExist = true;
            }
        }
        return marketExist;
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }

    function getAllMarkets() public view returns (address[] memory) {
        return allMarkets;
    }

    function getUserMainMarket(address userAddr) public view returns (address) {
        if (userMainMarket[userAddr] == address(0)) {
            return defaultMarket; // return default market
        }
        address market = userMainMarket[userAddr];
        if (marketEnable[market] == false) {
            return defaultMarket; // return default market
        }
        return market;
    }

    function getBatchUserAssetAmount(address userAddr)
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256[] memory assets = new uint256[](allMarkets.length);
        uint256[] memory decimals = new uint256[](allMarkets.length);

        for (uint256 i = 0; i < allMarkets.length; i++) {
            assets[i] = ICard(cardContract).usersBalances(
                userAddr,
                allMarkets[i]
            );
            ERC20Interface token = ERC20Interface(allMarkets[i]);
            uint256 tokenDecimal = uint256(token.decimals());
            decimals[i] = tokenDecimal;
        }
        return (allMarkets, assets, decimals);
    }

    function getBatchUserBalanceInUsd(address userAddr)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256[] memory assets = new uint256[](allMarkets.length);

        for (uint256 i = 0; i < allMarkets.length; i++) {
            assets[i] = IConverter(converter).getUsdAmount(
                allMarkets[i],
                ICard(cardContract).usersBalances(userAddr, allMarkets[i]),
                ICard(cardContract).priceOracle()
            );
        }
        return (allMarkets, assets);
    }

    function getUserBalanceInUsd(address userAddr)
        public
        view
        returns (uint256)
    {
        address market = getUserMainMarket(userAddr);
        uint256 assetAmount = ICard(cardContract).usersBalances(
            userAddr,
            market
        );
        uint256 usdAmount = IConverter(converter).getUsdAmount(
            market,
            assetAmount,
            ICard(cardContract).priceOracle()
        );
        return usdAmount;
    }

    ///////////////// CallBack functions from card contract //////////////////////////////////////////////
    function setUserMainMakret(address userAddr, address market)
        public
        onlyFromCardContract
    {
        if (getUserMainMarket(userAddr) == market) return;
        userMainMarket[userAddr] = market;
    }

    //////////////////// Owner functions ////////////////////////////////////////////////////////////////
    // verified
    function addMarket(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "addMarket")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        address market = abi.decode(params, (address));
        _addMarketInternal(market);
    }

    function setDefaultMarket(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setDefaultMarket")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        address market = abi.decode(params, (address));
        require(isMarketExist(market), "me");
        require(marketEnable[market], "mn");
        defaultMarket = market;
        emit DefaultMarketChanged(market);
    }

    // verified
    function enableMarket(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "enableMarket")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (address market, bool bEnable) = abi.decode(params, (address, bool));
        marketEnable[market] = bEnable;
        emit MarketEnableChanged(market, bEnable);
    }

    function setParams(bytes calldata signData, bytes calldata keys)
        external
        validSignOfOwner(signData, keys, "setParams")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (address _newOkse, address _newUSDC) = abi.decode(
            params,
            (address, address)
        );
        OKSE = _newOkse;
        USDC = _newUSDC;
        emit TokenAddressChanged(OKSE, USDC);
    }

    // verified
    function setOkseAsPayment(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setOkseAsPayment")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        bool bEnable = abi.decode(params, (bool));
        oksePaymentEnable = bEnable;
        emit OkseAsPaymentChanged(oksePaymentEnable);
    }

    function setSlippage(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setSlippage")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        uint256 _value = abi.decode(params, (uint256));
        slippage = _value;
        emit SlippageChanged(slippage);
    }

    function setEmergencyStop(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setEmergencyStop")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        bool _value = abi.decode(params, (bool));
        emergencyStop = _value;
        emit EmergencyStopChanged(emergencyStop);
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

interface ERC20Interface {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;

interface ICard {
    function getUserOkseBalance(address userAddr)
        external
        view
        returns (uint256);

    function getUserAssetAmount(address userAddr, address market)
        external
        view
        returns (uint256);


    function usersBalances(address userAddr, address market)
        external
        view
        returns (uint256);

    function priceOracle() external view returns (address);

}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;

interface IConverter {
    function convertUsdAmountToAssetAmount(
        uint256 usdAmount,
        address assetAddress
    ) external view returns (uint256);

    function convertAssetAmountToUsdAmount(
        uint256 assetAmount,
        address assetAddress
    ) external view returns (uint256);

    function getUsdAmount(
        address market,
        uint256 assetAmount,
        address priceOracle
    ) external view returns (uint256 usdAmount);

    function getAssetAmount(
        address market,
        uint256 usdAmount,
        address priceOracle
    ) external view returns (uint256 assetAmount);
}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;
pragma abicoder v2;

// 2/3 Multi Sig Owner
contract MultiSigOwner {
    address[] public owners;
    mapping(uint256 => bool) public signatureId;
    bool private initialized;
    // events
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SignValidTimeChanged(uint256 newValue);
    modifier validSignOfOwner(
        bytes calldata signData,
        bytes calldata keys,
        string memory functionName
    ) {
        require(isOwner(msg.sender), "on");
        address signer = getSigner(signData, keys);
        require(
            signer != msg.sender && isOwner(signer) && signer != address(0),
            "is"
        );
        (bytes4 method, uint256 id, uint256 validTime, ) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        require(
            signatureId[id] == false &&
                method == bytes4(keccak256(bytes(functionName))),
            "sru"
        );
        require(validTime > block.timestamp, "ep");
        signatureId[id] = true;
        _;
    }

    function isOwner(address addr) public view returns (bool) {
        bool _isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == addr) {
                _isOwner = true;
            }
        }
        return _isOwner;
    }

    constructor() {}

    function initializeOwners(address[3] memory _owners) public {
        require(
            !initialized &&
                _owners[0] != address(0) &&
                _owners[1] != address(0) &&
                _owners[2] != address(0),
            "ai"
        );
        owners = [_owners[0], _owners[1], _owners[2]];
        initialized = true;
    }

    function getSigner(bytes calldata _data, bytes calldata keys)
        public
        view
        returns (address)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(
            keys,
            (uint8, bytes32, bytes32)
        );
        return
            ecrecover(
                toEthSignedMessageHash(
                    keccak256(abi.encodePacked(this, chainId, _data))
                ),
                v,
                r,
                s
            );
    }

    function encodePackedData(bytes calldata _data)
        public
        view
        returns (bytes32)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return keccak256(abi.encodePacked(this, chainId, _data));
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    // Set functions
    // verified
    function transferOwnership(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "transferOwnership")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        address newOwner = abi.decode(params, (address));
        uint256 index;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                index = i;
            }
        }
        address oldOwner = owners[index];
        owners[index] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//SPDX-License-Identifier: LICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.7.0;

contract Manager {
    address public immutable cardContract;

    constructor(address _cardContract) {
        cardContract = _cardContract;
    }

    /// modifier functions
    modifier onlyFromCardContract() {
        require(msg.sender == cardContract, "oc");
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../interfaces/IERC20.sol";
import "../../interfaces/IDAOProxy.sol";
import "../../interfaces/ICheckDotInsuranceCovers.sol";
import "../../interfaces/ICheckDotInsuranceCalculator.sol";
import "../../utils/Counters.sol";
import "../../utils/SafeMath.sol";
import "../../utils/SignedSafeMath.sol";
import "../../utils/TransferHelper.sol";
import "../../utils/Addresses.sol";

import "../../../../../CheckDot.DAOProxyContract/contracts/interfaces/IOwnedProxy.sol";

struct Object {
    mapping(string => address) a;
    mapping(string => uint256) n;
    mapping(string => string) s;
}

struct ProductInformations {
    uint256 id;
    string  name;
    string  riskType;
    string  uri;
    uint256 status;
    uint256 riskRatio;
    uint256 basePremiumInPercent;
    uint256 minCoverInDays;
    uint256 maxCoverInDays;
}

enum ProductStatus {
    NotSet,       // 0 |
    Active,       // 1 ===|
    Paused,       // 2 ===|
    Canceled      // 3 |
}

contract CheckDotInsuranceProducts {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using Counters for Counters.Counter;

    event PurchasedCover(uint256 coverId, uint256 productId, uint256 coveredAmount, uint256 premiumCost);
    event ProductCreated(uint256 id);

    string private constant INSURANCE_COVERS = "INSURANCE_COVERS";
    string private constant INSURANCE_CALCULATOR = "INSURANCE_CALCULATOR";
    string private constant CHECKDOT_TOKEN = "CHECKDOT_TOKEN";

    bool internal locked;

    // V1 DATA

    /* Map of Essentials Addresses */
    mapping(string => address) private protocolAddresses;

    struct Products {
        mapping(uint256 => Object) data;
        Counters.Counter counter;
    }

    Products private products;

    // END V1

    function initialize(bytes memory _data) external onlyOwner {
        (
            address _insuranceCoversAddress,
            address _insuranceCalculatorAddress
        ) = abi.decode(_data, (address, address));

        protocolAddresses[INSURANCE_COVERS] = _insuranceCoversAddress;
        protocolAddresses[INSURANCE_CALCULATOR] = _insuranceCalculatorAddress;
        protocolAddresses[CHECKDOT_TOKEN] = IDAOProxy(address(this)).getGovernance();
    }

    modifier onlyOwner {
        require(msg.sender == IOwnedProxy(address(this)).getOwner(), "FORBIDDEN");
        _;
    }

    modifier productExists(uint256 productId) {
        require(bytes(products.data[productId].s["name"]).length != 0, "DOESNT_EXISTS");
        _;
    }

    modifier activatedProduct(uint256 productId) {
        require(products.data[productId].n["status"] == uint256(ProductStatus.Active), "Product is paused");
        _;
    }

    modifier noContract() {
        require(!Addresses.isContract(msg.sender), "FORBIDEN_CONTRACT");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function getInsuranceCoversAddress() external view returns (address) {
        return protocolAddresses[INSURANCE_COVERS];
    }

    function getInsuranceCalculatorAddress() external view returns (address) {
        return protocolAddresses[INSURANCE_CALCULATOR];
    }
   
    function createProduct(uint256 _id, bytes memory _data) external onlyOwner {
        (
            string memory _name,
            string memory _riskType,
            string memory _uri,
            uint256 _riskRatio,
            uint256 _basePremiumInPercent,
            uint256 _minCoverInDays,
            uint256 _maxCoverInDays
        ) = abi.decode(_data, (string, string, string, uint256, uint256, uint256, uint256));
        require(_minCoverInDays > 0, "MIN_COVER_UNALLOWED");
        require(_maxCoverInDays > 0, "MAX_COVER_UNALLOWED");
        require(_id <= products.counter.current(), "NOT_VALID_PRODUCT_ID");
        uint256 id = _id;

        products.data[id].n["id"] = id;
        products.data[id].s["riskType"] = _riskType;
        products.data[id].s["uri"] = _uri;
        products.data[id].s["name"] = _name;
        products.data[id].n["riskRatio"] = _riskRatio;
        products.data[id].n["basePremiumInPercent"] = _basePremiumInPercent;
        products.data[id].n["status"] = uint256(ProductStatus.Active);
        products.data[id].n["minCoverInDays"] = _minCoverInDays;
        products.data[id].n["maxCoverInDays"] = _maxCoverInDays;
        if (id == products.counter.current()) {
            products.counter.increment();
        }
        emit ProductCreated(id);
    }

    function buyCover(uint256 _productId,
        address _coveredAddress,
        uint256 _coveredAmount,
        address _coverCurrency,
        uint256 _durationInDays,
        address _payIn) external payable noReentrant activatedProduct(_productId) noContract {
        require(isValidBuy(_productId, _coveredAddress, _coveredAmount, _coverCurrency, _durationInDays, _payIn), "UNAVAILABLE");
        
        Object storage product = products.data[_productId];

        uint256 totalCostInCoverCurrency = _payCover(_productId, _coveredAmount, _coverCurrency, _durationInDays, _payIn);
        uint256 tokenId = ICheckDotInsuranceCovers(protocolAddresses[INSURANCE_COVERS]).mintInsuranceToken(product.n["id"], _coveredAddress, _durationInDays, totalCostInCoverCurrency, _coverCurrency, _coveredAmount, product.s["uri"]);

        emit PurchasedCover(tokenId, product.n["id"], _coveredAmount, totalCostInCoverCurrency);
    }

    function isValidBuy(uint256 _productId,
        address _coveredAddress,
        uint256 _coveredAmount,
        address _coverCurrency,
        uint256 _durationInDays,
        address _payIn) public view returns (bool) {
        require(_coveredAddress != address(0), "EMPTY_COVER");
        require(products.data[_productId].n["status"] == uint256(ProductStatus.Active), "PRODUCT_IS_DISABLED");
        require(_durationInDays >= products.data[_productId].n["minCoverInDays"], "DURATION_TOO_SHORT");
        require(_durationInDays <= products.data[_productId].n["maxCoverInDays"], "DURATION_MAX_EXCEEDED");
        require(ICheckDotInsuranceCovers(protocolAddresses[INSURANCE_COVERS]).getPool(_payIn).token != address(0), "PAY_POOL_DOESNT_EXIST");
        require(_coverCurrency != protocolAddresses[CHECKDOT_TOKEN], "CDT_ISNT_COVER_CURRENCY");
        require(ICheckDotInsuranceCalculator(protocolAddresses[INSURANCE_CALCULATOR]).coverIsSolvable(products.data[_productId].n["id"], products.data[_productId].n["riskRatio"], _coverCurrency, _coveredAmount), "NOT_SOLVABLE_COVER");
        return true;
    }

    function _payCover(uint256 _productId,
        uint256 _coveredAmount,
        address _coverCurrency,
        uint256 _durationInDays,
        address _payIn) internal returns (uint256) {
        uint256 totalCostInCoverCurrency = getCoverCost(products.data[_productId].n["id"], _coverCurrency, _coveredAmount, _durationInDays);
        uint256 payCost = ICheckDotInsuranceCalculator(protocolAddresses[INSURANCE_CALCULATOR]).convertCost(totalCostInCoverCurrency, _coverCurrency, _payIn);
        uint256 fees = payCost.div(100).mul(2); // 2%

        if (_payIn == protocolAddresses[CHECKDOT_TOKEN]) {
            fees = payCost.div(2); // 50% when is paid in CDT
        }
        require(IERC20(_payIn).balanceOf(msg.sender) >= payCost, "INSUFISANT_BALANCE");
        require(IERC20(_payIn).allowance(msg.sender, address(this)) >= payCost, "INSUFISANT_ALLOWANCE");

        TransferHelper.safeTransferFrom(_payIn, msg.sender, protocolAddresses[INSURANCE_COVERS], payCost.sub(fees)); // send 98% tokens to pool
        ICheckDotInsuranceCovers(protocolAddresses[INSURANCE_COVERS]).sync(_payIn); // Synchronization of the reserve for distribution to the holders.

        TransferHelper.safeTransferFrom(_payIn, msg.sender, protocolAddresses[INSURANCE_COVERS], fees); // send fees to pool
        ICheckDotInsuranceCovers(protocolAddresses[INSURANCE_COVERS]).addInsuranceProtocolFees(_payIn, IOwnedProxy(address(this)).getOwner()); // associate the fees to the owner
        return totalCostInCoverCurrency;
    }

    //////////
    // Views
    //////////

    function getCoverCost(uint256 _productId, address _coverCurrency, uint256 _coveredAmount, uint256 _durationInDays) public view returns (uint256) {
        (
            /** Unused Parameter **/,
            uint256 cumulativePremiumInPercent,
            /** Unused Parameter **/,
            /** Unused Parameter **/
        ) = getCoverCurrencyDetails(_coverCurrency);

        uint256 premiumInPercent = products.data[_productId].n["basePremiumInPercent"].add(cumulativePremiumInPercent);
        uint256 costOnOneYear = _coveredAmount.mul(premiumInPercent).div(100 ether);
        
        return costOnOneYear.mul(_durationInDays.mul(1 ether)).div(365 ether);
    }

    function getProductLength() public view returns (uint256) {
        return products.counter.current();
    }

    function getProductDetails(uint256 _id) public view returns (ProductInformations memory) {
        ProductInformations[] memory results = new ProductInformations[](1);
        Object storage product = products.data[_id];
        
        results[0].id = product.n["id"];
        results[0].riskType = product.s["riskType"];
        results[0].name = product.s["name"];
        results[0].uri = product.s["uri"];
        results[0].status = product.n["status"];
        results[0].riskRatio = product.n["riskRatio"];
        results[0].basePremiumInPercent = product.n["basePremiumInPercent"];
        results[0].minCoverInDays = product.n["minCoverInDays"];
        results[0].maxCoverInDays = product.n["maxCoverInDays"];
        return results[0];
    }

    function getCoverCurrencyDetails(address _coverCurrency) public view returns (uint256, uint256, int256, uint256) {
        uint256 poolReserve = ICheckDotInsuranceCovers(protocolAddresses[INSURANCE_COVERS]).getPool(_coverCurrency).reserve;
        uint256 currentCoverCurrencyCoveredAmount = ICheckDotInsuranceCalculator(protocolAddresses[INSURANCE_CALCULATOR]).getTotalCoveredAmountFromCurrency(_coverCurrency);
        int256 signedCapacity = int256(poolReserve).sub(int256(currentCoverCurrencyCoveredAmount));
        uint256 capacity = signedCapacity > 0 ? uint256(signedCapacity) : 0;
        uint256 availablePercentage = signedCapacity > 0 ? uint256(100 ether).sub(uint256(capacity).mul(100 ether).div(poolReserve)) : 0;
        uint256 cumulativePremiumInPercent = availablePercentage.mul(3 ether).div(100 ether); // 3% addable
        return (currentCoverCurrencyCoveredAmount, cumulativePremiumInPercent, signedCapacity, poolReserve);
    }

    //////////
    // Update
    //////////

    function pauseProduct(uint256 _productId) external onlyOwner {
        products.data[_productId].n["status"] = uint256(ProductStatus.Paused);
    }

    function activeProduct(uint256 _productId) external onlyOwner {
        products.data[_productId].n["status"] = uint256(ProductStatus.Active);
    }

    function cancelProduct(uint256 _productId) external onlyOwner {
        products.data[_productId].n["status"] = uint256(ProductStatus.Canceled);
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SignedSafeMath.sol)
pragma solidity ^0.8.0;

library SignedSafeMath {
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)
pragma solidity ^0.8.9;

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.9;

/**
 * @dev Collection of functions related to the address type
 */
library Addresses {
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
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title IDAOProxy
 * @author Jeremy Guyet (@jguyet)
 * @dev See {UpgradableProxyDAO}.
 */
interface IDAOProxy {

    function getGovernance() external view returns (address);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

struct PoolInformations {
    address token;
    uint256 totalSupply; // LP token
    uint256 reserve;
}

struct CoverInformations {
    // cover slots
    uint256 id;
    uint256 productId;
    string  uri;
    address coveredAddress;
    uint256 utcStart;
    uint256 utcEnd;
    uint256 coveredAmount;
    address coveredCurrency;
    uint256 premiumAmount;
    uint256 status;
    // claim slots
    string  claimProperties;
    string  claimAdditionnalProperties;
    uint256 claimAmount;
    uint256 claimPayout;
    uint256 claimUtcPayoutDate;
    uint256 claimRewardsInCDT;
    uint256 claimAlreadyRewardedAmount;
    uint256 claimUtcStartVote;
    uint256 claimUtcEndVote;
    uint256 claimTotalApproved;
    uint256 claimTotalUnapproved;
    // others slots
}

struct Vote {
    address voter;
    uint256 totalApproved;
    uint256 totalUnapproved;
}

interface ICheckDotInsuranceCovers {

    function getVersion() external pure returns (uint256);
    function getInsuranceProductsAddress() external view returns (address);
    function getInsuranceCalculatorAddress() external view returns (address);

    //////////
    // Actions
    //////////

    function contribute(address _token, address _from, uint256 _amountOfTokens) external;
    function uncontribute(address _token, address _to, uint256 _amountOfliquidityTokens) external;
    function sync(address _token) external;
    function claim(uint256 _insuranceTokenId, uint256 _claimAmount, string calldata _claimProperties) external returns (uint256);
    function teamApproveClaim(uint256 _insuranceTokenId, bool _approved, string calldata _additionnalProperties) external;
    function voteForClaim(uint256 _insuranceTokenId, bool _approved) external;
    function payoutClaim(uint256 _insuranceTokenId) external;

    //////////
    // Views
    //////////

    function getClaimPrice(address _coveredCurrency, uint256 _claimAmount) external view returns (uint256);
    function getNextVoteRewards(uint256 _insuranceTokenId) external view returns (uint256);
    function getVoteOf(uint256 _insuranceTokenId, address _addr) external view returns (Vote memory);
    function getPools(int256 page, int256 pageSize) external view returns (PoolInformations[] memory);
    function getPool(address _token) external view returns (PoolInformations memory);
    function getPoolsLength() external view returns (uint256);
    function getPoolContributionInformations(address _token, address _staker) external view returns (uint256, bool, uint256, uint256);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function getCoverIdsByOwner(address _owner) external view returns (uint256[] memory);
    function getCoversByOwner(address _owner) external view returns (CoverInformations[] memory);
    function getCover(uint256 tokenId) external view returns (CoverInformations memory);
    function getLightCoverInformation(uint256 tokenId) external view returns (address, uint256, uint256);
    function getCoversCount() external view returns (uint256);

    //////////
    // onlyInsuranceProducts
    //////////

    function mintInsuranceToken(uint256 _productId, address _coveredAddress, uint256 _insuranceTermInDays, uint256 _premiumAmount, address _coveredCurrency, uint256 _coveredAmount, string calldata _uri) external returns (uint256);
    function addInsuranceProtocolFees(address _token, address _from) external;

    //////////
    // Owner Actions
    //////////

    function createPool(address _token) external;
    function initialize(bytes memory _data) external; // called from proxy

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title ICheckDotInsuranceRiskDataCalculator
 * @author Jeremy Guyet (@jguyet)
 * @dev See {CheckDotInsuranceRiskDataCalculator}.
 */
interface ICheckDotInsuranceCalculator {

    function initialize(bytes memory _data) external;

    function getTotalCoveredAmountFromCurrency(address _currency) external view returns (uint256);

    function coverIsSolvable(uint256 /*_productId*/, uint256 _productRiskRatio, address _coverCurrency, uint256 _newCoverAmount) external view returns (bool);

    function getSolvabilityRatio() external view returns (uint256);

    function getSCRPercent() external view returns (uint256);

    function getSCRSize() external view returns (uint256);

    function getSolvability() external view returns(uint256, uint256, uint256);

    function getClaimPrice(address _coveredCurrency, uint256 _claimAmount) external view returns (uint256);

    function convertCost(uint256 _costIn, address _in, address _out) external view returns (uint256);

    function getTokenPriceInUSD(address _token) external view returns (uint256);

    function getTokenPriceOut(address _in, address _out) external view returns (uint256);

    function getStoreAddress() external view returns (address);

    function getInsuranceProtocolAddress() external view returns (address);

    function getInsurancePoolFactoryAddress() external view returns (address);

    function getInsuranceTokenAddress() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IOwnedProxy
 * @author Jeremy Guyet (@jguyet)
 * @dev See {UpgradableProxyDAO}.
 */
interface IOwnedProxy {

    function getOwner() external view returns (address);

    function transferOwnership(address _newOwner) external payable;
}
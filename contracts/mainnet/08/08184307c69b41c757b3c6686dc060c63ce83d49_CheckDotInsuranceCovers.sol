// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../utils/SafeMath.sol";
import "../../utils/SignedSafeMath.sol";
import "../../utils/TransferHelper.sol";
import "../../utils/Counters.sol";
import "../../interfaces/IERC20.sol";
import "../../interfaces/IDAOProxy.sol";
import "../../interfaces/IOracle.sol";
import "../../token/ERC721.sol";

import "../../../../../CheckDot.DAOProxyContract/contracts/interfaces/IOwnedProxy.sol";

struct Object {
    mapping(string => address) a;
    mapping(string => uint256) n;
    mapping(string => string) s;
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

enum CoverStatus {
    NotSet,           // 0 |
    Active,           // 1 |
    ClaimApprobation, // 2 |
    ClaimVote,        // 3 |
    ClaimPaid,        // 4 |
    Canceled          // 5 |
}

struct PoolInformations {
    address token;
    uint256 totalSupply; // LP token
    uint256 reserve;
}

struct Vote {
    address voter;
    uint256 totalApproved;
    uint256 totalUnapproved;
}

contract CheckDotInsuranceCovers is ERC721 {
    using SafeMath for uint;
    using SignedSafeMath for int256;
    using Counters for Counters.Counter;

    event PoolCreated(address token);
    event ContributionAdded(address from, address token, uint256 amount, uint256 liquidity);
    event ContributionRemoved(address from, address token, uint256 amount, uint256 liquidity);

    event ClaimCreated(uint256 id, uint256 productId, uint256 amount);    
    event ClaimUpdated(uint256 id, uint256 productId);
    
    string private constant INSURANCE_PRODUCTS = "INSURANCE_PRODUCTS";
    string private constant INSURANCE_CALCULATOR = "INSURANCE_CALCULATOR";
    string private constant CHECKDOT_TOKEN = "CHECKDOT_TOKEN";

    bool internal locked;

    // V1 DATA

    /* Map of Essentials Addresses */
    mapping(string => address) private protocolAddresses;

    // Pools

    mapping (address => mapping(address => uint256)) private _balances;
    mapping (address => mapping(address => uint256)) private _holdTimes;

    mapping(address => Object) private pools;
    address[] private poolList;

    // Covers

    struct CoverTokens {
        mapping(uint256 => Object) data;
        Counters.Counter counter;
    }
    CoverTokens private tokens;

    // Claims

    mapping(uint256 => mapping(address => Object)) private claimsParticipators;

    // Vars

    Object private vars;

    // END V1

    function initialize(bytes memory _data) external onlyOwner {
        (
            address _insuranceProductsAddress,
            address _insuranceCalculatorAddress
        ) = abi.decode(_data, (address, address));

        protocolAddresses[INSURANCE_PRODUCTS] = _insuranceProductsAddress;
        protocolAddresses[INSURANCE_CALCULATOR] = _insuranceCalculatorAddress;
        protocolAddresses[CHECKDOT_TOKEN] = IDAOProxy(address(this)).getGovernance();

        if (pools[protocolAddresses[CHECKDOT_TOKEN]].a["token"] == address(0)) { // Creating Default CDT Pool if doesn't exists
            createPool(protocolAddresses[CHECKDOT_TOKEN]);
        }
        vars.n["LOCK_DURATION"] = uint256(1); // To be managed via DAO in the future.
        vars.n["VOTE_DURATION"] = uint256(86400).mul(2); // To be managed via DAO in the future.
    }

    modifier poolExist(address _token) {
        require(pools[_token].a["token"] != address(0), "Entity should be initialized");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == IOwnedProxy(address(this)).getOwner(), "FORBIDDEN");
        _;
    }

    modifier onlyInsuranceProducts {
        require(msg.sender == protocolAddresses[INSURANCE_PRODUCTS], "FORBIDDEN");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function getVersion() external pure returns (uint256) {
        return 1;
    }

    function getInsuranceProductsAddress() external view returns (address) {
        return protocolAddresses[INSURANCE_PRODUCTS];
    }

    function getInsuranceCalculatorAddress() external view returns (address) {
        return protocolAddresses[INSURANCE_CALCULATOR];
    }

    //////////
    // Functions
    //////////

    function createPool(address _token) public onlyOwner {
        require(_token != address(0), 'ZERO_ADDRESS');
        require(pools[_token].a["token"] == address(0), 'ALREADY_EXISTS');

        pools[_token].a["token"] = _token;
        poolList.push(_token);
        emit PoolCreated(_token);
    }

    function contribute(address _token, address _from, uint256 _amountOfTokens) external noReentrant poolExist(_token) {
        require(_amountOfTokens > 0, "INVALID_AMOUNT");
        require(IERC20(_token).balanceOf(_from) >= _amountOfTokens, "BALANCE_EXCEEDED");
        require(IERC20(_token).allowance(_from, address(this)) >= _amountOfTokens, "UNALLOWED");

        TransferHelper.safeTransferFrom(_token, _from, address(this), _amountOfTokens);
        uint256 liquidity = _contribute(_token, _from);
        emit ContributionAdded(_from, _token, _amountOfTokens, liquidity);
    }

    function uncontribute(address _token, address _to, uint256 _amountOfliquidityTokens) external noReentrant poolExist(_token) {
        require(_amountOfliquidityTokens > 0, "INVALID_AMOUNT");
        require(_holdTimes[_token][msg.sender].add(vars.n["LOCK_DURATION"]) < block.timestamp, "15_DAYS_LOCKED_CONTRIBUTION");

        uint256 amountOfLP = _amountOfliquidityTokens;
        if (_amountOfliquidityTokens > _balances[_token][msg.sender]) {
            amountOfLP = _balances[_token][msg.sender];
        }
        uint256 amount = _unContribute(_token, msg.sender, _to, amountOfLP); // remove contribution
        emit ContributionRemoved(_to, _token, amount, _amountOfliquidityTokens);
    }

    function sync(address _token) external noReentrant poolExist(_token) {
        _sync(_token);
    }

    function addInsuranceProtocolFees(address _token, address _from) external noReentrant poolExist(_token) onlyInsuranceProducts {
        _contribute(_token, _from);
    }

    function getClaimPrice(address _coveredCurrency, uint256 _claimAmount) public view returns (uint256) {
        uint256 claimFeesInCoveredCurrency = _claimAmount.div(100).mul(1); // 1% fee
        return IOracle(protocolAddresses[INSURANCE_CALCULATOR]).convertCost(claimFeesInCoveredCurrency, _coveredCurrency, protocolAddresses[CHECKDOT_TOKEN]);
    }

    function claim(uint256 _insuranceTokenId, uint256 _claimAmount, string calldata _claimProperties) external noReentrant returns (uint256) {
        require(tokens.data[_insuranceTokenId].n["status"] == uint256(CoverStatus.Active), "NOT_ACTIVE_COVER");
        require(tokens.data[_insuranceTokenId].n["utcEnd"] > block.timestamp, 'COVER_ENDED');
        Object storage cover = tokens.data[_insuranceTokenId];

        require(_claimAmount > 0 && _claimAmount <= cover.n["coveredAmount"], 'AMOUNT_UNAVAILABLE');
        uint256 claimFeesInCDT = getClaimPrice(cover.a["coveredCurrency"], _claimAmount);
        
        require(IERC20(protocolAddresses[CHECKDOT_TOKEN]).balanceOf(cover.a["coveredAddress"]) >= claimFeesInCDT, "INSUFISANT_BALANCE");
        TransferHelper.safeTransferFrom(protocolAddresses[CHECKDOT_TOKEN], cover.a["coveredAddress"], address(this), claimFeesInCDT); // send tokens to insuranceProtocol
        _sync(protocolAddresses[CHECKDOT_TOKEN]); // update reserve.

        cover.s["claimProperties"] = _claimProperties;
        cover.n["claimAmount"] = _claimAmount;
        cover.n["status"] = uint256(CoverStatus.ClaimApprobation);
        cover.n["claimRewardsInCDT"] = claimFeesInCDT;

        emit ClaimCreated(cover.n["id"], cover.n["productId"], _claimAmount);
        return cover.n["id"];
    }

    function teamApproveClaim(uint256 _insuranceTokenId, bool _approved, string calldata _additionnalProperties) external {
        Object storage cover = tokens.data[_insuranceTokenId];

        require(cover.n["status"] == uint256(CoverStatus.ClaimApprobation), "CLAIM_APPROBATION_FINISHED");
        if (_approved) {
            cover.n["status"] = uint256(CoverStatus.ClaimVote);
            cover.n["claimUtcStartVote"] = block.timestamp; // now
            cover.n["claimUtcEndVote"] = block.timestamp.add(vars.n["VOTE_DURATION"]); // in two days
        } else {
            cover.n["status"] = uint256(CoverStatus.Canceled);
        }
        cover.s["claimAdditionnalProperties"] = _additionnalProperties;
        emit ClaimUpdated(cover.n["id"], cover.n["productId"]);
    }

    function voteForClaim(uint256 _insuranceTokenId, bool _approved) external noReentrant {
        Object storage cover = tokens.data[_insuranceTokenId];

        require(claimsParticipators[_insuranceTokenId][msg.sender].a["voter"] == address(0), "ALREADY_VOTED");
        require(cover.a["coveredAddress"] != msg.sender, "ACCESS_DENIED");
        require(cover.n["status"] == uint256(CoverStatus.ClaimVote), "VOTE_FINISHED");
        require(block.timestamp < cover.n["claimUtcEndVote"], "VOTE_ENDED");

        IERC20 token = IERC20(protocolAddresses[CHECKDOT_TOKEN]);
        uint256 votes = token.balanceOf(msg.sender).div(10 ** token.decimals());
        require(votes >= 1, "Proxy: INSUFFISANT_POWER");

        if (_approved) {
            cover.n["claimTotalApproved"] = cover.n["claimTotalApproved"].add(votes);
            claimsParticipators[_insuranceTokenId][msg.sender].n["TotalApproved"] = votes;
        } else {
            cover.n["claimTotalUnapproved"] = cover.n["claimTotalUnapproved"].add(votes);
            claimsParticipators[_insuranceTokenId][msg.sender].n["totalUnapproved"] = votes;
        }
        claimsParticipators[_insuranceTokenId][msg.sender].a["voter"] = msg.sender;

        uint256 voteDuration = cover.n["claimUtcEndVote"].sub(cover.n["claimUtcStartVote"]);
        uint256 timeSinceStartVote = block.timestamp.sub(cover.n["claimUtcStartVote"]);
        uint256 rewards = timeSinceStartVote.mul(cover.n["claimRewardsInCDT"]).div(voteDuration).sub(cover.n["claimAlreadyRewardedAmount"]);

        if (token.balanceOf(address(this)) >= rewards) {
            TransferHelper.safeTransfer(protocolAddresses[CHECKDOT_TOKEN], msg.sender, rewards);
            cover.n["claimAlreadyRewardedAmount"] = cover.n["claimAlreadyRewardedAmount"].add(rewards);
            _sync(protocolAddresses[CHECKDOT_TOKEN]);
        }
        emit ClaimUpdated(cover.n["id"], cover.n["productId"]);
    }

    function getNextVoteRewards(uint256 _insuranceTokenId) public view returns (uint256) {
        Object storage cover = tokens.data[_insuranceTokenId];

        uint256 voteDuration = cover.n["claimUtcEndVote"].sub(cover.n["claimUtcStartVote"]);
        uint256 timeSinceStartVote = block.timestamp.sub(cover.n["claimUtcStartVote"]);
        uint256 rewards = timeSinceStartVote.mul(cover.n["claimRewardsInCDT"]).div(voteDuration).sub(cover.n["claimAlreadyRewardedAmount"]);

        if (IERC20(protocolAddresses[CHECKDOT_TOKEN]).balanceOf(address(this)) >= rewards) {
            return rewards;
        }
        return 0;
    }

    function payoutClaim(uint256 _insuranceTokenId) external noReentrant {
        Object storage cover = tokens.data[_insuranceTokenId];

        require(cover.n["status"] == uint256(CoverStatus.ClaimVote), "CLAIM_FINISHED");
        require(block.timestamp > cover.n["claimUtcEndVote"], "VOTE_INPROGRESS");
        require(cover.n["claimTotalApproved"] > cover.n["claimTotalUnapproved"], "CLAIM_REJECTED");
        require(pools[cover.a["coveredCurrency"]].n["reserve"] >= cover.n["claimAmount"], "UNAVAILABLE_FUNDS_AMOUNT");
        cover.n["status"] = uint256(CoverStatus.ClaimPaid);
        cover.n["claimPayout"] = cover.n["claimAmount"];
        cover.n["claimUtcPayoutDate"] = block.timestamp;
        TransferHelper.safeTransfer(cover.a["coveredCurrency"], cover.a["coveredAddress"], cover.n["claimAmount"]);
        _sync(cover.a["coveredCurrency"]); // synchronize the coverCurrency Pool with the new reserve
        emit ClaimUpdated(cover.n["id"], cover.n["productId"]);
    }

    //////////
    // Views
    //////////

    function getPools(int256 page, int256 pageSize) external view returns (PoolInformations[] memory) {
        uint256 poolLength = poolList.length;
        int256 queryStartPoolIndex = int256(poolLength).sub(pageSize.mul(page.add(1))).add(pageSize);
        require(queryStartPoolIndex >= 0, "Out of bounds");
        int256 queryEndPoolIndex = queryStartPoolIndex.sub(pageSize);
        if (queryEndPoolIndex < 0) {
            queryEndPoolIndex = 0;
        }
        int256 currentPoolIndex = queryStartPoolIndex;
        require(uint256(currentPoolIndex) <= poolLength, "Out of bounds");
        PoolInformations[] memory results = new PoolInformations[](uint256(currentPoolIndex - queryEndPoolIndex));
        uint256 index = 0;

        for (currentPoolIndex; currentPoolIndex > queryEndPoolIndex; currentPoolIndex--) {
            address token = poolList[uint256(currentPoolIndex).sub(1)];
            results[index].token = token;
            results[index].totalSupply = pools[token].n["totalSupply"];
            results[index].reserve = pools[token].n["reserve"];
            index++;
        }
        return results;
    }

    function getPool(address _token) external view returns (PoolInformations memory) {
        PoolInformations[] memory results = new PoolInformations[](1);

        results[0].token = pools[_token].a["token"];
        results[0].totalSupply = pools[_token].n["totalSupply"];
        results[0].reserve = pools[_token].n["reserve"];
        return results[0];
    }

    function getPoolsLength() external view returns (uint256) {
        return poolList.length;
    }

    function getPoolContributionInformations(address _token, address _staker) external view returns (uint256, bool, uint256, uint256) {
        uint256 lastContributionTime = _holdTimes[_token][_staker];
        bool canUnContribute = lastContributionTime.add(vars.n["LOCK_DURATION"]) < block.timestamp;
        uint256 stakerBalanceLP = _balances[_token][_staker];
        uint256 totalBalanceOfToken = IERC20(_token).balanceOf(address(this));
        uint256 totalSupply = pools[_token].n["totalSupply"];

        return (lastContributionTime, canUnContribute, stakerBalanceLP, stakerBalanceLP.mul(totalBalanceOfToken).div(totalSupply));
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     * Overloaded function to retrieve IPFS url of a tokenId.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "INVALID_TOKEN_ID");
        return _insuranceTokenURI(tokenId);
    }

    function getCoverIdsByOwner(address _owner) public view returns (uint256[] memory) {
        return balanceIdsOf(_owner);
    }

    function getCoversByOwner(address _owner) external view returns (CoverInformations[] memory) {
        uint256[] memory ids = getCoverIdsByOwner(_owner);
        CoverInformations[] memory results = new CoverInformations[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            results[i] = getCover(ids[i]);
        }
        return results;
    }

    /**
     * @dev Creates a new insurance token sent to `_coveredAddress`.
     */
    function mintInsuranceToken(uint256 _productId, address _coveredAddress, uint256 _insuranceTermInDays, uint256 _premiumAmount, address _coveredCurrency, uint256 _coveredAmount, string calldata _uri) external noReentrant onlyInsuranceProducts returns (uint256) {
        require(bytes(_uri).length > 0, "URI doesn't exists on product");
        uint256 tokenId = tokens.counter.current();

        _mint(_coveredAddress, tokenId);
        tokens.data[tokenId].n["id"] = tokenId;
        tokens.data[tokenId].n["productId"] = _productId;
        tokens.data[tokenId].s["uri"] = _uri;
        tokens.data[tokenId].a["coveredCurrency"] = _coveredCurrency;
        tokens.data[tokenId].n["coveredAmount"] = _coveredAmount;
        tokens.data[tokenId].n["premiumAmount"] = _premiumAmount;
        tokens.data[tokenId].a["coveredAddress"] = _coveredAddress;
        tokens.data[tokenId].n["utcStart"] = block.timestamp;
        tokens.data[tokenId].n["utcEnd"] = block.timestamp.add(_insuranceTermInDays.mul(86400));
        tokens.data[tokenId].n["status"] = uint256(CoverStatus.Active);
        tokens.counter.increment();
        return tokenId;
    }

    function getCover(uint256 tokenId) public view returns (CoverInformations memory) {
        CoverInformations[] memory r = new CoverInformations[](1);

        r[0].id = tokens.data[tokenId].n["id"];
        r[0].productId = tokens.data[tokenId].n["productId"];
        r[0].uri = tokens.data[tokenId].s["uri"];
        r[0].coveredAddress = tokens.data[tokenId].a["coveredAddress"];
        r[0].utcStart = tokens.data[tokenId].n["utcStart"];
        r[0].utcEnd = tokens.data[tokenId].n["utcEnd"];
        r[0].coveredAmount = tokens.data[tokenId].n["coveredAmount"];
        r[0].coveredCurrency = tokens.data[tokenId].a["coveredCurrency"];
        r[0].premiumAmount = tokens.data[tokenId].n["premiumAmount"];
        r[0].status = tokens.data[tokenId].n["status"];
        r[0].claimProperties = tokens.data[tokenId].s["claimProperties"];
        r[0].claimAdditionnalProperties = tokens.data[tokenId].s["claimAdditionnalProperties"];
        r[0].claimAmount = tokens.data[tokenId].n["claimAmount"];
        r[0].claimPayout = tokens.data[tokenId].n["claimPayout"];
        r[0].claimUtcPayoutDate = tokens.data[tokenId].n["claimUtcPayoutDate"];
        r[0].claimRewardsInCDT = tokens.data[tokenId].n["claimRewardsInCDT"];
        r[0].claimAlreadyRewardedAmount = tokens.data[tokenId].n["claimAlreadyRewardedAmount"];
        r[0].claimUtcStartVote = tokens.data[tokenId].n["claimUtcStartVote"];
        r[0].claimUtcEndVote = tokens.data[tokenId].n["claimUtcEndVote"];
        r[0].claimTotalApproved = tokens.data[tokenId].n["claimTotalApproved"];
        r[0].claimTotalUnapproved = tokens.data[tokenId].n["claimTotalUnapproved"];
        return r[0];
    }

    function getLightCoverInformation(uint256 tokenId) public view returns (address, uint256, uint256) {
        return (tokens.data[tokenId].a["coveredCurrency"], tokens.data[tokenId].n["coveredAmount"], tokens.data[tokenId].n["status"]);
    }

    function getCoversCount() public view returns (uint256) {
        return tokens.counter.current();
    }

    function getVoteOf(uint256 _insuranceTokenId, address _addr) public view returns (Vote memory) {
        return Vote(
            claimsParticipators[_insuranceTokenId][_addr].a["voter"],
            claimsParticipators[_insuranceTokenId][_addr].n["totalApproved"],
            claimsParticipators[_insuranceTokenId][_addr].n["totalUnapproved"]
        );
    }

    ////////
    // Internals
    ////////

    function _contribute(address token, address to) internal returns (uint256 liquidity) {
        uint256 _reserve = pools[token].n["reserve"]; // gas savings
        uint256 balance = IERC20(token).balanceOf(address(this));
        uint256 amount = balance.sub(_reserve);

        uint256 _totalSupply = pools[token].n["totalSupply"]; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = amount;
        } else {
            liquidity = amount.mul(_totalSupply) / _reserve;
        }
        require(liquidity > 0, 'INSUFFICIENT_LIQUIDITY_MINTED');
        pools[token].n["totalSupply"] = pools[token].n["totalSupply"].add(liquidity);
        _sync(token);
        _balances[token][to] = _balances[token][to].add(liquidity); // add lp
        _holdTimes[token][to] = block.timestamp;
    }

    function _unContribute(address token, address from, address to, uint256 liquidityAmount) internal returns (uint256 amount) {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(liquidityAmount <= _balances[token][from], 'INSUFFICIENT_LIQUIDITY_OWNED');

        uint256 _totalSupply = pools[token].n["totalSupply"]; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount = liquidityAmount.mul(balance) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount > 0, 'INSUFFICIENT_LIQUIDITY_BURNED');
        pools[token].n["totalSupply"] = pools[token].n["totalSupply"].sub(liquidityAmount);
        _balances[token][from] = _balances[token][from].sub(liquidityAmount); // burn lp
        TransferHelper.safeTransfer(token, to, amount);
        _sync(token);
    }

    function _sync(address token) internal {
        pools[token].n["reserve"] = IERC20(token).balanceOf(address(this));
    }

    function _insuranceTokenURI(uint256 tokenId) private view returns (string memory) {
        return string(abi.encodePacked("ipfs://", tokens.data[tokenId].s["uri"]));
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is ERC165, IERC721, IERC721Metadata {
    // Token name
    string private _name = "CDTInsurance";

    // Token symbol
    string private _symbol = "ICDT";

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping owner address to token ids
    mapping(address => uint256[]) private _balancesIds;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function balanceIdsOf(address owner) public view returns (uint256[] memory) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balancesIds[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            msg.sender == owner,
            "ERC721: approve caller is not token owner or approved for all"
        );
        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address /*operator*/, bool /*approved*/) public virtual override {
        // unused
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address /*owner*/, address /*operator*/) public view virtual override returns (bool) {
        return false;
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*tokenId*/
    ) public virtual override {
        // unused
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*tokenId*/
    ) public virtual override {
        // unused
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*tokenId*/,
        bytes memory /*data*/
    ) public virtual override {
        // unused
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _mint(to, tokenId);
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;
        _balancesIds[to].push(tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 /*tokenId*/) internal virtual {
        // unused
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address /*owner*/,
        address /*operator*/,
        bool /*approved*/
    ) internal virtual { /* unused */ }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title IOracle
 * @author Jeremy Guyet (@jguyet)
 * @dev Gives the price of an `_in` token against an `_out` token from Dexs
 */
interface IOracle {
    function convertCost(uint256 _costIn, address _in, address _out) external view returns (uint256);
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
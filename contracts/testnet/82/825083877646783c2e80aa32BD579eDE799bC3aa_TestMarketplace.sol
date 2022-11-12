// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PlatformOwnable.sol";
import "./TestReferralSystem.sol";
import "./IDistribution.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract TestMarketplace is EIP712, Ownable, PlatformOwnable {
    string private constant SIGNING_DOMAIN = "Marketplace_Signature";
    string private constant SIGNATURE_VERSION = "1";
    TestReferralSystem private referralSystem;

    // NFT contract address => creator address
    mapping(address => address) public creators;

    event AddCollection(address nftAddress, address creator);
    event RemoveCollection(address nftAddress);
    event BuyOrder(
        address buyer,
        address seller,
        address collection,
        uint256 tokenId
    );
    event InitialDistribution(
        address owner,
        uint256 commissionAmount,
        address creator,
        uint256 royaltyAmount,
        address master,
        uint256 masterAmount,
        address l1,
        uint256 l1Amount,
        address l2,
        uint256 l2Amount,
        address seller,
        uint256 sellerAmount
    );
    event KOLDistribution(
        address owner,
        uint256 commissionAmount,
        address creator,
        uint256 royaltyAmount,
        address master,
        uint256 masterAmount,
        address kol,
        uint256 kolAmount,
        address seller,
        uint256 sellerAmount
    );
    event SubDistribution(
        address owner,
        uint256 commissionAmount,
        address seller,
        uint256 sellerAmount
    );

    modifier validateOrder(List calldata _listing) {
        require(_listing.collection != address(0), "invalid nft address");
        require(
            creators[_listing.collection] != address(0),
            "nft not support by marketplace"
        );
        address signer = _verify(_listing);
        require(signer == _listing.owner, "signature signed by wrong owner");
        require(
            IERC721(_listing.collection).ownerOf(_listing.tokenId) == signer,
            "tokenId does not belongs to sender"
        );
        require(
            IERC721(_listing.collection).isApprovedForAll(
                _listing.owner,
                address(this)
            ),
            "owner does not approve operator"
        );
        require(
            IERC20(_listing.paymentToken).allowance(
                _msgSender(),
                address(this)
            ) >= _listing.price,
            "insufficient allowance"
        );
        require(
            IERC20(_listing.paymentToken).balanceOf(_msgSender()) >=
                _listing.price,
            "insufficient fund"
        );
        _;
    }

    struct List {
        string orderId;
        address collection;
        uint256 tokenId;
        address owner;
        uint256 price;
        address paymentToken;
        bool isKOL;
        bool isInitial;
        bytes signature;
    }

    constructor(address _platformOwner, address _referralSystem)
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
        PlatformOwnable(_platformOwner)
    {
        require(
            _referralSystem != address(0),
            "invalid referral system contract"
        );
        referralSystem = TestReferralSystem(_referralSystem);
    }

    // register NFT collection address to get supported
    function addCollection(address _nft, address _creator)
        external
        onlyPlatformOwner
    {
        require(_nft != address(0), "invalid nft address");
        require(_creator != address(0), "invalid creator address");

        creators[_nft] = _creator;

        emit AddCollection(_nft, _creator);
    }

    // runregister a NFT colelction
    function removeCollection(address _nft) external onlyPlatformOwner {
        require(_nft != address(0), "invalid nft address");

        delete creators[_nft];

        emit RemoveCollection(_nft);
    }

    // marketplace buy nft
    function buyNFT(List calldata _listing) external validateOrder(_listing) {
        // Case 1 : KOL initial
        if (_listing.isKOL) {
            _kolDistribution(_listing);
        }

        // Case 2 : Initial sale (normal buyer)
        if (_listing.isInitial && !_listing.isKOL) {
            _initialDistribution(_listing);
        }

        // Case 3 : Sub sale
        if (!_listing.isInitial) {
            _subDistribution(_listing);
        }

        // transfer NFT ownership
        IERC721(_listing.collection).safeTransferFrom(
            _listing.owner,
            _msgSender(),
            _listing.tokenId
        );

        emit BuyOrder(
            _msgSender(),
            _listing.owner,
            _listing.collection,
            _listing.tokenId
        );
    }

    function _kolDistribution(List calldata _listing) internal {
        IDistribution.KOL memory kol = referralSystem.getKolDistributions(
            creators[_listing.collection],
            _msgSender(),
            _listing.price
        );

        address token = _listing.paymentToken;

        // distribute to platform owner
        IERC20(token).transferFrom(
            _msgSender(),
            kol.owner,
            kol.commissionPayment
        );

        // distribute to creator
        IERC20(token).transferFrom(
            _msgSender(),
            kol.creator,
            kol.royaltyPayment + kol.sellerPayment
        );

        // distribute to master
        IERC20(token).transferFrom(_msgSender(), kol.master, kol.masterPayment);

        // distribute to kol
        IERC20(token).transferFrom(_msgSender(), kol.kol, kol.kolPayment);

        emit KOLDistribution(
            kol.owner,
            kol.commissionPayment,
            kol.creator,
            kol.royaltyPayment,
            kol.master,
            kol.masterPayment,
            kol.kol,
            kol.kolPayment,
            kol.seller,
            kol.sellerPayment
        );
    }

    function _initialDistribution(List calldata _listing) internal {
        IDistribution.Initial memory initial = referralSystem
            .getInitialDistributions(
                creators[_listing.collection],
                _msgSender(),
                _listing.price
            );

        address token = _listing.paymentToken;

        // distribute to platform owner
        IERC20(token).transferFrom(
            _msgSender(),
            initial.owner,
            initial.commissionPayment
        );
        // distribute to creator
        IERC20(token).transferFrom(
            _msgSender(),
            initial.creator,
            initial.royaltyPayment + initial.sellerPayment
        );

        // distribute to master
        IERC20(token).transferFrom(
            _msgSender(),
            initial.master,
            initial.masterPayment
        );

        // distribute to layer 1 referral
        if (initial.l1 != address(0) && initial.l1Payment > 0) {
            IERC20(token).transferFrom(
                _msgSender(),
                initial.l1,
                initial.l1Payment
            );
        }

        // distribute to layer 2 referral
        if (initial.l2 != address(0) && initial.l2Payment > 0) {
            IERC20(token).transferFrom(
                _msgSender(),
                initial.l2,
                initial.l2Payment
            );
        }

        emit InitialDistribution(
            initial.owner,
            initial.commissionPayment,
            initial.creator,
            initial.royaltyPayment,
            initial.master,
            initial.masterPayment,
            initial.l1,
            initial.l1Payment,
            initial.l2,
            initial.l2Payment,
            initial.seller,
            initial.sellerPayment
        );
    }

    function _subDistribution(List calldata _listing) internal {
        IDistribution.Sub memory sub = referralSystem.getSubDistributions(
            _listing.owner,
            _msgSender(),
            _listing.price
        );

        address token = _listing.paymentToken;

        // distribute to platform owner
        IERC20(token).transferFrom(
            _msgSender(),
            sub.owner,
            sub.commissionPayment
        );

        // transfer remaining to seller
        IERC20(token).transferFrom(_msgSender(), sub.seller, sub.sellerPayment);

        emit SubDistribution(
            sub.owner,
            sub.commissionPayment,
            sub.seller,
            sub.sellerPayment
        );
    }

    function _verify(List calldata _list) internal view returns (address) {
        bytes32 digest = _hash(_list);
        return ECDSA.recover(digest, _list.signature);
    }

    function _hash(List calldata _list) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "List(string orderId,address collection,uint256 tokenId,address owner,uint256 price,address paymentToken,bool isKOL,bool isInitial)"
                        ),
                        keccak256(abi.encodePacked(_list.orderId)),
                        _list.collection,
                        _list.tokenId,
                        _list.owner,
                        _list.price,
                        _list.paymentToken,
                        _list.isKOL,
                        _list.isInitial
                    )
                )
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PlatformOwnable.sol";
import "./IDistribution.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestReferralSystem is Ownable, PlatformOwnable {
    address[] private masters;
    address[] private members;
    uint256 public royaltyTax;
    uint256 public commissionTax;
    uint256 public referralTax_kol; // kol referral
    uint256 public referralTax_master; // master referral
    uint256 public referralTax_l1; // user's upline
    uint256 public referralTax_l2; // user's upper upline

    // user address => referral address
    mapping(address => address) public referrals;

    event Register(address user, address referral);
    event AddMaster(address indexed newMaster);
    event SetRoyaltyTax(uint256 previousTax, uint256 newTax);
    event SetCommissionTax(uint256 previousTax, uint256 newTax);
    event SetReferralTax(
        string referralType,
        uint256 previousTax,
        uint256 newTax
    );

    struct InitialPayments {
        uint256 commissionPayment;
        uint256 royaltyPayment;
        uint256 masterPayment;
        uint256 referralL1Payment;
        uint256 referralL2Payment;
        uint256 remaining;
    }

    struct KOLPayments {
        uint256 commissionPayment;
        uint256 royaltyPayment;
        uint256 masterPayment;
        uint256 kolPayment;
        uint256 remaining;
    }

    modifier onlyNewUser() {
        require(
            referrals[_msgSender()] == address(0),
            "sender already registered"
        );
        _;
    }
    modifier validateReferral(address _referral) {
        require(_referral != address(0), "invalid referral");
        if (!isMaster(_referral)) {
            require(referrals[_referral] != address(0), "referral not exist");
        }
        _;
    }

    constructor(
        address _platformOwner,
        uint256 _royaltyTax,
        uint256 _commissionTax,
        uint256 _referralTax_kol,
        uint256 _referralTax_master,
        uint256 _referralTax_l1,
        uint256 _referralTax_l2,
        address[] memory _masters
    ) PlatformOwnable(_platformOwner) {
        require(_royaltyTax != 0, "royalty tax must not be 0");
        require(_commissionTax != 0, "commission tax must not be 0");
        require(_referralTax_kol != 0, "referral tax (kol) must not be 0");
        require(
            _referralTax_master != 0,
            "referral tax (master) must not be 0"
        );
        require(_referralTax_l1 != 0, "referral tax (l1) must not be 0");
        require(_referralTax_l2 != 0, "referral tax (l2) must not be 0");
        for (uint256 i = 0; i < _masters.length; i++) {
            require(_masters[i] != address(0), "Invalid master address");
        }

        royaltyTax = _royaltyTax;
        commissionTax = _commissionTax;
        referralTax_kol = _referralTax_kol;
        referralTax_master = _referralTax_master;
        referralTax_l1 = _referralTax_l1;
        referralTax_l2 = _referralTax_l2;
        masters = _masters;
    }

    // register as member of marketplace
    function register(address _referral)
        external
        onlyNewUser
        validateReferral(_referral)
    {
        // register as member
        members.push(_msgSender());

        // register referral
        referrals[_msgSender()] = _referral;

        emit Register(_msgSender(), _referral);
    }

    // add kol into member list
    // Note: referral for kol must be master address
    function registerKOL(address _master, address _kol) external onlyPlatformOwner {
        require(_master != address(0), "invalid master address");
        require(_kol != address(0), "invalid kol address");
        require(isMaster(_master), "master address is not master");
        require(!isMaster(_kol), "kol address cannot be master");
        require(!isMember(_kol), "kol address is one of the member");

        // register as member
        members.push(_kol);

        // register referral
        referrals[_kol] = _master;

        emit Register(_kol, _master);
    }

    // add new master referral
    function addMaster(address _master) external onlyPlatformOwner {
        require(_master != address(0), "invalid master address");
        require(!isMaster(_master), "master address exist");
        require(!isMember(_master), "this address is one of the member");

        masters.push(_master);
        emit AddMaster(_master);
    }

    function setRoyaltyTax(uint256 _newRoyaltyTax) external onlyPlatformOwner {
        require(_newRoyaltyTax > 0, "invalid royalty tax");

        uint256 previous = royaltyTax;
        royaltyTax = _newRoyaltyTax;
        emit SetRoyaltyTax(previous, _newRoyaltyTax);
    }

    function setCommissionTax(uint256 _newCommissionTax)
        external
        onlyPlatformOwner
    {
        require(_newCommissionTax > 0, "invalid commission tax");

        uint256 previous = commissionTax;
        commissionTax = _newCommissionTax;
        emit SetCommissionTax(previous, _newCommissionTax);
    }

    function setReferralTax(
        uint256 _kol,
        uint256 _master,
        uint256 _l1,
        uint256 _l2
    ) external onlyPlatformOwner {
        require(_kol > 0, "invalid kol referral tax");
        require(_master > 0, "invalid master referral tax");
        require(_l1 > 0, "invalid l1 referral tax");
        require(_l2 > 0, "invalid l2 referral tax");

        uint256 previous = referralTax_kol;
        referralTax_kol = _kol;
        emit SetReferralTax("kol", previous, _kol);

        previous = referralTax_master;
        referralTax_master = _master;
        emit SetReferralTax("master", previous, _master);

        previous = referralTax_l1;
        referralTax_l1 = _l1;
        emit SetReferralTax("l1", previous, _l1);

        previous = referralTax_l2;
        referralTax_l2 = _l2;
        emit SetReferralTax("l2", previous, _l2);
    }

    /**
     * calculate distributions for all the addresses (sub sales)
     *
     * Addresses involved:
     *    1. platform owner
     *    2. seller
     */
    function getSubDistributions(
        address _owner,
        address _buyer,
        uint256 _total
    ) external view returns (IDistribution.Sub memory) {
        require(_owner != address(0), "invalid owner address");
        require(_buyer != address(0), "invalid buyer address");
        require(_total > 0, "total value cannot be 0");

        uint256 commissionPayment = (_total * commissionTax) / 100;
        uint256 remaining = _total - commissionPayment;

        return
            IDistribution.Sub(
                platformOwner(),
                commissionPayment,
                _owner,
                remaining
            );
    }

    /**
     * calculate distributions for all the addresses (initial sales)
     *
     * Addresses involved:
     *    1. platform owner
     *    2. creator
     *    3. master referral
     *    4. layer 1 referral
     *    5. layer 2 referral
     *    6. seller
     */
    function getInitialDistributions(
        address _creator,
        address _buyer,
        uint256 _total
    ) external view returns (IDistribution.Initial memory) {
        require(_creator != address(0), "invalid creator address");
        require(_buyer != address(0), "invalid buyer address");
        require(_total > 0, "total value cannot be 0");

        (address master, uint256 level) = _getMaster(_buyer);
        InitialPayments memory payments = _calculateInitial(_total);
        address l1;
        address l2;

        // special cases if upline is master referral
        // case: level=0, msg.sender is the master
        // l1 & l2 = creator
        if (level == 0) {
            l1 = _creator;
            l2 = _creator;
        }
        // case: level=1, msg.sender's upline is master
        // l1 = master
        // l2 = creator
        if (level == 1) {
            l1 = master;
            l2 = _creator;
        }
        // case: level=2, msg.sender's upper upline is master
        // l2 = master
        if (level == 2) {
            l1 = referrals[_buyer];
            l2 = master;
        }
        // case: level > 2
        if (level > 2) {
            l1 = referrals[_buyer];
            l2 = referrals[l1];
        }

        return
            IDistribution.Initial(
                platformOwner(),
                payments.commissionPayment,
                _creator,
                payments.royaltyPayment,
                master,
                payments.masterPayment,
                l1,
                payments.referralL1Payment,
                l2,
                payments.referralL2Payment,
                _creator, // only creator receive the final amount
                payments.remaining
            );
    }

    /**
     * calculate distributions for KOL related addresses (initial sales)
     *
     * Addresses involved:
     *    1. platform owner
     *    2. creator
     *    3. master referral
     *    4. kol
     *    5. seller
     */
    function getKolDistributions(
        address _creator,
        address _buyer,
        uint256 _total
    ) external view returns (IDistribution.KOL memory) {
        require(_creator != address(0), "invalid creator address");
        require(_buyer != address(0), "invalid buyer address");
        require(_total > 0, "total value cannot be 0");

        (address master, uint256 level) = _getMaster(_buyer);
        require(level == 2, "unauthorized kol referral");

        KOLPayments memory payments = _calculateKOL(_total);

        return
            IDistribution.KOL(
                platformOwner(),
                payments.commissionPayment,
                _creator,
                payments.royaltyPayment,
                master,
                payments.masterPayment,
                referrals[_buyer],
                payments.kolPayment,
                _creator,
                payments.remaining
            );
    }

    function getMasters() external view returns (address[] memory) {
        return masters;
    }

    // check if address is in master addresses list
    function isMaster(address _addr) public view returns (bool) {
        if (_addr == address(0)) {
            return false;
        }

        bool master = false;
        for (uint256 i = 0; i < masters.length; i++) {
            if (masters[i] == _addr) {
                master = true;
                break;
            }
        }
        return master;
    }

    // check if address is already a member
    function isMember(address _addr) public view returns (bool) {
        if (_addr == address(0)) {
            return false;
        }

        bool member = false;
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == _addr) {
                member = true;
                break;
            }
        }
        return member;
    }

    function _getMaster(address _currentUser)
        internal
        view
        returns (address, uint256)
    {
        address current = _currentUser;
        uint256 index = 0;
        while (!isMaster(current) && current != address(0)) {
            index = index + 1;
            current = referrals[current];
        }

        return (current, index);
    }

    function _calculateInitial(uint256 _total)
        internal
        view
        returns (InitialPayments memory)
    {
        uint256 commissionPayment = (_total * commissionTax) / 100;
        uint256 royaltyPayment = (_total * royaltyTax) / 100;
        uint256 masterPayment = (_total * referralTax_master) / 100;
        uint256 referralL1Payment = (_total * referralTax_l1) / 100;
        uint256 referralL2Payment = (_total * referralTax_l2) / 100;
        uint256 remaining = _total -
            commissionPayment -
            royaltyPayment -
            masterPayment -
            referralL1Payment -
            referralL2Payment;

        return
            InitialPayments(
                commissionPayment,
                royaltyPayment,
                masterPayment,
                referralL1Payment,
                referralL2Payment,
                remaining
            );
    }

    function _calculateKOL(uint256 _total)
        internal
        view
        returns (KOLPayments memory)
    {
        uint256 commissionPayment = (_total * commissionTax) / 100;
        uint256 royaltyPayment = (_total * royaltyTax) / 100;
        uint256 masterPayment = (_total * referralTax_master) / 100;
        uint256 kolPayment = (_total * referralTax_kol) / 100;
        uint256 remaining = _total -
            commissionPayment -
            royaltyPayment -
            masterPayment -
            kolPayment;

        return
            KOLPayments(
                commissionPayment,
                royaltyPayment,
                masterPayment,
                kolPayment,
                remaining
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract PlatformOwnable is Context {
    address private _platformOwner; // address that incharge of updating state

    constructor(address owner) {
        require(owner != address(0), "invalid address");
        _platformOwner = owner;
    }

    event SetPlatformOwner(address previousOwner, address newOwner);

    modifier onlyPlatformOwner() {
        require(_msgSender() == platformOwner(), "unauthorize access");
        _;
    }

    function platformOwner() public view virtual returns (address) {
        return _platformOwner;
    }

    function transferPlatformOwner(address owner) external onlyPlatformOwner {
        require(owner != address(0), "invalid address");

        address previous = _platformOwner;
        _platformOwner = owner;

        emit SetPlatformOwner(previous, owner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDistribution {
    struct Initial {
        address owner;
        uint256 commissionPayment;
        address creator;
        uint256 royaltyPayment;
        address master;
        uint256 masterPayment;
        address l1;
        uint256 l1Payment;
        address l2;
        uint256 l2Payment;
        address seller;
        uint256 sellerPayment;
    }

    struct Sub {
        address owner;
        uint256 commissionPayment;
        address seller;
        uint256 sellerPayment;
    }

    struct KOL {
        address owner;
        uint256 commissionPayment;
        address creator;
        uint256 royaltyPayment;
        address master;
        uint256 masterPayment;
        address kol;
        uint256 kolPayment;
        address seller;
        uint256 sellerPayment;
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
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

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
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
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
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
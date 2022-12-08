// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../libs/SafeMath.sol";
import "../interfaces/INFTicket.sol";
import "../interfaces/INFTicketProcessor.sol";
import "../interfaces/INFTServiceTypes.sol";
import "../interfaces/INFTServiceProvider.sol";
import "./interfaces/IDemoServiceContract.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title Service contract for the NFTicket demo
 * @author Lukas Reinarz | bloXmove
 */
contract NFTicketDemoServiceContract is IDemoServiceContract, AccessControl {
    using SafeMath for uint256;

    // NFTicket contract
    INFTicket NFTicketContract;

    // NFTicket contract
    INFTicketProcessor NFTicketProcessorContract;

    // ERC20 token to be distributed to consumers
    IERC20 ERC20Contract;

    // Number of credits on newly minted ticket
    uint256 public numCredits;

    // Number of BLXM tokens (in Wei) to give to a consumer
    uint256 public numErc20PerConsumer;

    // Service descriptors for IS_TICKET and CASH_VOUCHER
    uint32 public ticketServiceDescriptor = 0x08000200;
    uint32 public cashVoucherServiceDescriptor = 0x0A000200;

    // Mapping containing wallets who have already been added ERC20 to their NFTickets
    address[] alreadyClaimed;

    //===================================Initializer===================================//
    constructor(
        address _NFTicketAddress,
        address _NFTicketProcessorAddress,
        address _ERC20Address,
        uint256 _numCredits,
        uint256 _numErc20PerConsumer
    ) {
        NFTicketContract = INFTicket(_NFTicketAddress);
        NFTicketProcessorContract = INFTicketProcessor(
            _NFTicketProcessorAddress
        );
        ERC20Contract = IERC20(_ERC20Address);
        numCredits = _numCredits;
        numErc20PerConsumer = _numErc20PerConsumer;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    //===================================Modifiers===================================//
    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Only admin can do this"
        );
        _;
    }

    modifier onlyTicketOwner(uint256 _ticketId) {
        require(
            IERC721(address(NFTicketContract)).ownerOf(_ticketId) ==
                _msgSender(),
            "Only ticket owner can do this"
        );
        _;
    }

    modifier onlyRedeemed(uint256 _ticketId) {
        Ticket memory ticket = NFTicketContract.getTicketData(_ticketId);
        require(ticket.credits == 0, "Not yet redeemed");
        _;
    }

    modifier onlyCashVoucher(uint256 _ticketId) {
        Ticket memory ticket = NFTicketContract.getTicketData(_ticketId);
        require(
            ticket.serviceDescriptor == cashVoucherServiceDescriptor,
            "Not a cash voucher"
        );
        _;
    }

    //===================================Public functions===================================//
    /**
     * @notice Mints an NFTicket with one credit
     *
     * @param _URI - A URI saved on the ticket; can point to some IPFS resource, for example.
     *
     * @dev Emits a TicketMinted(uint256 newTicketId, address userAddress) event, both parameters indexed
     */
    function mintNfticket(string calldata _URI) public override {
        address user = _msgSender();

        Ticket memory ticket = getTicketParams(user, _URI);

        Ticket memory newTicket = NFTicketContract.mintNFTicket(user, ticket);

        emit TicketMinted(newTicket.tokenID, user);
    }

    /**
     * @notice Reduced the number of credits on a newly minted ticket to zero and
     *         converts the ticket to a cash voucher
     *
     * @param _ticketId - The Id of the ticket to redeem
     *
     * @dev Emits a CreditRedeemed(uint256 ticketId, address presenterAddress) event,
     *      both parameters indexed
     */
    function redeemNfticket(uint256 _ticketId) public override {
        address presenter = _msgSender();

        // NFTicket contract checks credits on ticket and reduces credits if appropriate
        NFTicketProcessorContract.presentTicket(
            _ticketId,
            presenter,
            address(this),
            numCredits
        );

        // NFticket contract changes the service descriptor of the ticket
        // to a cash voucher
        NFTicketContract.updateServiceType(
            _ticketId,
            cashVoucherServiceDescriptor
        );

        emit CreditRedeemed(_ticketId, presenter);
    }

    /**
     * @notice Adds a certain amount of an ERC20 token to the ticket which can be withdrawn later
     *
     * @param _ticketId - The Id of the ticket to add the ERC20 tokens to
     *
     * @dev Emits a BalanceAdded(uint256 ticketId, address userAddress, uint256 numErc20) with
     *      all parameters indexed.
     */
    function addBalanceToTicket(uint256 _ticketId)
        public
        override
        onlyTicketOwner(_ticketId)
        onlyRedeemed(_ticketId)
        onlyCashVoucher(_ticketId)
    {
        // Only tickets that have never gotten ERC20 tokens before can now get them
        address consumer = _msgSender();
        require(!hasGottenERC20(consumer), "Not a new wallet");

        // Contract balance must be sufficient
        uint256 currentContractBalance = ERC20Contract.balanceOf(address(this));
        require(
            currentContractBalance > numErc20PerConsumer,
            "Not enough BLXM left in contract"
        );

        // Add wallet to a blacklist so that it won't get ERC20 in the future
        alreadyClaimed.push(consumer);

        // Approve NFTicket contract to withdraw tokens from this contract
        address NFTicketAddress = address(NFTicketContract);
        uint256 currentAllowance = ERC20Contract.allowance(
            address(this),
            NFTicketAddress
        );
        ERC20Contract.approve(
            NFTicketAddress,
            currentAllowance.add(numErc20PerConsumer)
        );

        // Update the ticket BLXM balance
        uint256 creditsAffordable;
        uint256 chargedErc20;
        (creditsAffordable, chargedErc20) = NFTicketContract.topUpTicket(
            _ticketId,
            0, // number of credits to top up
            address(ERC20Contract),
            numErc20PerConsumer
        );

        emit BalanceAdded(_ticketId, consumer, numErc20PerConsumer);
    }

    /**
     * @notice Transfers the ERC20 on a ticket to the owner's wallet
     *
     * @param _ticketId - The Id of the ticket to withdraw the tokens from
     *
     * @dev Emits a Erc20Withdrawn(uint256 ticketId, address userAddress, uint256 numErc20) with
     *      all parameters indexed.
     */
    function getErc20(uint256 _ticketId)
        external
        override
        onlyTicketOwner(_ticketId)
        onlyRedeemed(_ticketId)
        onlyCashVoucher(_ticketId)
    {
        uint256 ticketBalance = NFTicketContract.getTicketBalance(_ticketId);
        require(
            ticketBalance == numErc20PerConsumer,
            "Not enough balance on ticket"
        );

        address consumer = _msgSender();
        NFTicketContract.withDrawERC20(
            _ticketId,
            address(ERC20Contract),
            ticketBalance,
            consumer
        );

        emit Erc20Withdrawn(_ticketId, consumer, numErc20PerConsumer);
    }

    function setNumCredits(uint256 _credits) external override onlyAdmin {
        numCredits = _credits;
    }

    function setNumErc20PerConsumer(uint256 _num) external override onlyAdmin {
        numErc20PerConsumer = _num;
    }

    function setTicketServiceDescriptor(uint32 _newDescriptor)
        external
        override
        onlyAdmin
    {
        ticketServiceDescriptor = _newDescriptor;
    }

    function setCashVoucherServiceDescriptor(uint32 _newDescriptor)
        external
        override
        onlyAdmin
    {
        cashVoucherServiceDescriptor = _newDescriptor;
    }

    function withdrawRemainingErc20() external override onlyAdmin {
        uint256 currentBalance = ERC20Contract.balanceOf(address(this));
        ERC20Contract.transfer(_msgSender(), currentBalance);
    }

    //===================================Private functions===================================//
    /**
     * @dev The mintNFTicket() function in NFTicket.sol requires two parameters one of which
     * is a Ticket struct. This Ticket struct is assembled here.
     */
    function getTicketParams(address _recipient, string calldata _URI)
        internal
        view
        returns (Ticket memory ticket)
    {
        ticket.tokenID = 0; // This Id will be assigned correctly in the NFTicket contract
        ticket.serviceProvider = address(this);
        ticket.serviceDescriptor = ticketServiceDescriptor;
        ticket.issuedTo = _recipient;
        ticket.certValue = 0;
        ticket.certValidFrom = 0;
        ticket.price = 0;
        ticket.credits = numCredits;
        ticket.pricePerCredit = 0;
        ticket.serviceFee = 900 * 1 ether;
        ticket.resellerFee = 100 * 1 ether;
        ticket.transactionFee = 0 * 1 ether;
        ticket.tokenURI = _URI;
    }

    function hasGottenERC20(address _address) internal view returns (bool) {
        uint256 numAddresses = alreadyClaimed.length;

        for (uint256 i = 0; i < numAddresses; i++) {
            if (alreadyClaimed[i] == _address) {
                return true;
            }
        }

        return false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
     *
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./INFTServiceTypes.sol";   
/**
 * Interface of NFTicket
 */

 
interface INFTicket {
    function mintNFTicket(address recipient, Ticket memory ticket)
        external
        payable 
        returns (Ticket memory);

    function updateServiceType(uint256 ticketID, uint32 serviceDescriptor)
        external
        returns(uint256 _sD);
    
    function withDrawCredits(uint256 ticketID, address erc20Contract, uint256 credits, address sendTo)
        external;
        
    function withDrawERC20(uint256 ticketID, address erc20Contract, uint256 amountERC20Tokens, address sendTo)
        external;
    function topUpTicket(uint256 ticketID, uint256 creditsAdded, address erc20Contract, uint256 amountERC20Tokens)
        external returns(uint256 creditsAffordable, uint256 chargedERC20);

    function registerServiceProvider(address serviceProvider, uint32 serviceDescriptor, address serviceProviderWallet) 
        external returns(uint16 status);
    function registerResellerServiceProvider(address serviceProvider, address reseller, address resellerWallet)
        external returns(uint16 status); 

    /*
    function consumeCredits(address serviceProvider, uint256 ticketID, uint256 credits)
        external 
        returns(uint256 creditsConsumed, uint256 creditsRemain);
    */

    function getTransactionPoolSize() external view returns (uint256);

    function getServiceProviderPoolSize(address serviceProvider)
        external
        view
        returns (uint256 poolSize);

    function getTotalTicketPoolSize() 
        external 
        view 
        returns (uint256); 

    function getTicketData(uint256 ticketID)
        external
        view
        returns (Ticket memory);

    function getTicketBalance(uint256 ticketID) 
        external 
        view 
        returns (uint256); 

    function getTreasuryOwner()
        external
        returns(address);
    
    function getTicketProcessor()
        external
        returns(address);
    
    
    event IncomingERC20(
        uint256 indexed ticketID,
        address indexed erc20Contract,
        uint256 amountERC20Tokens,
        address sender,
        address owner,
        uint32  indexed serviceDescriptor
    );

    event IncomingFunding(
        uint256 indexed ticketID,
        address indexed erc20Contract,
        address sender,
        address owner,
        uint256 creditsAdded,
        uint256 tokensAdded,
        uint32  indexed serviceDescriptor
    );

    event WithDrawCredits(
        uint256 indexed ticketID,
        address indexed erc20Contract,
        uint256 amountCredits,
        address indexed from,
        address to 
    );
    event WithDrawERC20(
        uint256 indexed ticketID,
        address indexed erc20Contract,
        uint256 amountERC20Tokens,
        address indexed from,
        address to 
    );

    event TicketSubmitted(
        address indexed _contract,
        uint256 indexed ticketID,
        uint256 indexed serviceType,
        uint256 deductedFee
    );

    event TopUpTicket(
        uint256 indexed ticketID, 
        uint256 creditsAdded, 
        address indexed erc20Contract, 
        uint256 amountERC20Tokens, 
        uint256 creditsAffordable, 
        uint256 chargedERC20);

    event SplitRevenue(
        uint256 indexed newTicketID,
        uint256 value,
        uint256 serviceFee,
        uint256 resellerFee,
        uint256 transactionFee
    );
    event SchemaRegistered(string name, DataSchema schema);
    event ConsumedCredits(
        uint256 indexed _tID,
        uint256 creditsConsumed,
        uint256 creditsRemain
    );
    event RegisterServiceProvider(
        address indexed serviceProvideContract,
        uint32 indexed serviceDescriptor,
        uint16 status
    );
    event WrongSender(
        address sender,
        address expectedSender,
        string message
    );
    event InsufficientPayment(
        uint256 value,
        uint256 credits,
        uint256 pricePerCredit
    );

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./INFTServiceTypes.sol";

interface INFTicketProcessor {

    function presentTicket(
        uint256 ticketID,
        address presenter,
        address _serviceProvider,
        uint256 credits
    ) external returns (Ticket memory);

    function presentTicket(
        uint256 ticketID,
        address presenter,
        address _serviceProvider,
        uint256 credits,
        address ticketReceiver
    ) external returns (Ticket memory ticket);

    function topUpTicket(uint256 ticketID, uint32 serviceDescriptor, uint256 creditsAdded, address erc20Token, uint256 numberERC20Tokens) 
        external
        returns (uint256 credits); 

    event TicketPresented(
        uint256 indexed ticketID, 
        address indexed from, 
        address indexed to, 
        uint256 creditsPresented
    );

    event CreditsToService(
        uint256 indexed ticketID,
        uint256 credits,
        uint256 value,
        address indexed payer,
        address indexed payee
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// First byte is Processing Mode: from here we derive the caluclation and account booking logic
// basic differentiator being Ticket or Certificate (of ownership)
// all tickets need lowest bit of first semi-byte set
// all certificates need lowest bit of first semi-byte set
// all checkin-checkout tickets need second-lowest bit of first-semi-byte set --> 0x03000000
// high bits for each byte or half.byte are categories, low bits are instances
uint32 constant IS_CERTIFICATE =    0x40000000; // 2nd highest bit of CERTT-half-byte = 1 - cannot use highest bit?
uint32 constant IS_TICKET =         0x08000000; // highest bit of ticket-halfbyte = 1
uint32 constant CHECKOUT_TICKET =   0x09000000; // highest bit of ticket-halfbyte = 1 AND lowest bit = 1
uint32 constant CASH_VOUCHER =      0x0A000000; // highest bit of ticket-halfbyte = 1 AND 2nd bit = 1

// company identifiers last 10 bbits, e.g. 1023 companies
uint32 constant BLOXMOVE = 0x00000200; // top of 10 bits for company identifiers
uint32 constant NRVERSE = 0x00000001;
uint32 constant MITTWEIDA = 0x00000002;
uint32 constant EQUOTA = 0x00000003;

// Industrial Category - byte2
uint32 constant THG = 0x80800000; //  CERTIFICATE & highest bit of category half-byte = 1
uint32 constant REC = 0x80400000; //  CERTIFICATE & 2nd highest bit of category half-byte = 1

// Last byte is company identifier 1-255
uint32 constant NRVERSE_REC = 0x80800001; // CERTIFICATE & REC & 0x00000001
uint32 constant eQUOTA_THG = 0x80400003; // CERTIFICATE & THG & 0x00000003
uint32 constant MITTWEIDA_M4A = 0x09000002; // CHECKOUT_TICKET & MITTWEIDA
uint32 constant BLOXMOVE_CO = 0x09000200;
uint32 constant BLOXMOVE_CV = 0x0A000200;
uint32 constant BLOXMOVE_CI = 0x08000200;
uint32 constant BLOXMOVE_NG = 0x09000201;
uint32 constant DutchMaaS = 0x09000003;
uint32 constant TIER_MW = 0x09000004;

/***********************************************
 *
 * generic schematizable data payload
 * allows for customization between reseller and
 * service operator while keeping NFTicket agnostic
 *
 ***********************************************/

enum eDataType {
    _UNDEF,
    _UINT,
    _UINT256,
    _USTRING
}

struct TicketInfo {
    uint256 ticketFee;
    bool ticketUsed;
}

/*
* TODO reconcile overlaps between Payload, BuyNFTicketParams and Ticket
*/
struct Ticket {
    uint256 tokenID;
    address serviceProvider; // the index to the map where we keep info about serviceProviders
    uint32 serviceDescriptor;
    address issuedTo;
    uint256 certValue;
    uint certValidFrom; // value can be redeemedn after this time
    uint256 price;
    uint256 credits; // [7]
    uint256 pricePerCredit;
    uint256 serviceFee;
    uint256 resellerFee;
    uint256 transactionFee;
    string tokenURI;
}

struct Payload {
    address recipient;
    string tokenURI;
    DataSchema schema;
    string[] data;
    string[] serializedTicket;
    uint256 certValue;
    string uuid;
    uint256 credits;
    uint256 pricePerCredit;
    uint256 price;
    uint256 timestamp;
}

/**** END TODO overlap */

struct DataSchema {
    string name;
    uint32 size;
    string[] keys;
    uint8[] keyTypes;
}

struct DataRecords {
    DataSchema _schema;
    string[] _data; // a one-dimensional array of length [_schema.size * <number of records> ]
}

struct ConsumedRecord {
    uint certId;
    string energyType;
    string location;
    uint amount;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./INFTServiceTypes.sol";

/**
 * Interface of NFTServiceProvider  
 */

interface INFTServiceProvider {
   function consumeCredits(Ticket memory ticket, uint256 creditsBefore)
        external returns (uint256 creditsConsumed);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../../interfaces/INFTServiceTypes.sol";

interface IDemoServiceContract {
    event TicketMinted(uint256 indexed ticketId, address indexed consumer);
    event CreditRedeemed(uint256 indexed ticketId, address indexed consumer);
    event BalanceAdded(
        uint256 indexed ticketId,
        address indexed consumer,
        uint256 indexed amount
    );
    event Erc20Withdrawn(
        uint256 indexed ticketId,
        address indexed consumer,
        uint256 indexed amount
    );

    function mintNfticket(string calldata URI) external;

    function redeemNfticket(uint256 ticketId) external;

    function addBalanceToTicket(uint256 ticketId) external;

    function getErc20(uint256 ticketId) external;

    function setNumCredits(uint256 newNumOfCredits) external;

    function setNumErc20PerConsumer(uint256 number) external;

    function setTicketServiceDescriptor(uint32 serviceDescriptor) external;

    function setCashVoucherServiceDescriptor(uint32 serviceDescriptor) external;

    function withdrawRemainingErc20() external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
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

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
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
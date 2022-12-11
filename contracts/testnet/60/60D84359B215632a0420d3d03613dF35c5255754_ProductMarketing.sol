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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract ProductMarketing is Ownable {
    struct Settings {
        string name;
        uint levels;
        uint registerfee;
        uint referralfee;
        uint levelcommission;
        uint ownercommission;
        address[] partners;
    }

    struct User {
        uint id;
        string nicname;
        address wallet;
        uint parentid;
        uint registerdate;
        uint lastreferrer;
    }

    event RegisterUser(address indexed user, uint indexed referralId);

    mapping(uint => User) public users;
    mapping(address => uint) public usersId;
    mapping(uint => address) public usersAddress;
    mapping(uint => uint[]) public referrers;
    mapping(uint => mapping(uint => uint)) public levelsCount;
    mapping(uint => mapping(uint => uint)) public levelsIncome;

    uint public lastUserId;
    uint public ownerId;
    uint public userCount;

    Settings public configs;
    IERC20Metadata stablecoincontract;

    constructor() {
        configs.name = "Product A";
        configs.levels = 15;
        configs.registerfee = 250;
        configs.referralfee = 50;
        configs.levelcommission = 10;
        configs.ownercommission = 10;
        configs.partners = [
            address(0xa364Cc60Be2a7384C9234a2A5d7efd4FF04dA7d4),
            address(0xBD09e333E5c51B492cd743d10b93FB453CbA8715)
        ];
        // set Tether USD contract
        setStableCoinContract(
            address(0x7cD653C92D060505A892d120A19fFABbB322698C)
        );

        lastUserId = 10000;
        ownerId = lastUserId;

        // create owner account
        users[ownerId].wallet = owner();
        users[ownerId].id = ownerId;
        users[ownerId].registerdate = block.timestamp;
        usersId[owner()] = ownerId;
        usersAddress[ownerId] = owner();

        userCount = 0;
    }

    /** Interaction Functions **/

    function registerUser(uint referralId) public returns (bool) {
        address userAddress = address(msg.sender);

        require(usersId[userAddress] == 0, "User already registered!");
        require(users[referralId].id != 0, "Parent address not found!");

        uint registerprice = configs.registerfee *
            10 ** stablecoincontract.decimals();

        require(
            stablecoincontract.balanceOf(userAddress) >= registerprice,
            "Insufficient stablecoin balance!"
        );
        require(
            stablecoincontract.allowance(userAddress, address(this)) >=
                registerprice,
            "Insufficient stablecoin allowancement!"
        );

        bool transfer = stablecoincontract.transferFrom(
            userAddress,
            address(this),
            registerprice
        );

        require(
            transfer &&
                stablecoincontract.balanceOf(address(this)) >= registerprice,
            "Transfer stablecoin failed!"
        );

        // find referral user
        User storage referraluser = _getUserById(referralId);
        // incrise user id
        lastUserId++;
        // create new user
        User storage registeredUser = users[lastUserId];
        registeredUser.id = lastUserId;
        registeredUser.wallet = userAddress;
        registeredUser.parentid = referraluser.id;
        registeredUser.registerdate = block.timestamp;
        referraluser.lastreferrer = block.timestamp;
        usersId[userAddress] = registeredUser.id;
        usersAddress[registeredUser.id] = userAddress;
        referrers[referraluser.id].push(registeredUser.id);
        // incrise user count
        userCount++;
        // direct commission transfer
        stablecoincontract.transfer(referraluser.wallet, configs.referralfee);
        levelsCount[referraluser.id][0]++;
        levelsIncome[referraluser.id][0] += configs.referralfee;
        // owner commission transfer
        stablecoincontract.transfer(
            users[ownerId].wallet,
            configs.ownercommission
        );
        // levels commission transfer
        User storage parentuser = referraluser;
        uint levelexists = 0;
        uint comssion = configs.levelcommission;
        for (uint lv = 1; lv <= configs.levels; lv++) {
            if (comssion == 0) continue;
            if (parentuser.id == 0) break;

            User storage _prnt = parentuser;
            uint level = lv;

            stablecoincontract.transfer(_prnt.wallet, comssion);

            levelsCount[_prnt.id][level]++;
            levelsIncome[_prnt.id][level] += comssion;

            parentuser = _getUserById(parentuser.parentid);
            levelexists++;
        }

        // partners commission transfer
        uint remainigvalue = configs.registerfee -
            configs.referralfee -
            configs.ownercommission -
            (levelexists * comssion);

        uint partnercommission = remainigvalue / configs.partners.length;

        for (uint pt = 1; pt <= configs.partners.length; pt++) {
            stablecoincontract.transfer(
                configs.partners[pt],
                partnercommission
            );
        }

        emit RegisterUser(userAddress, referralId);

        return true;
    }

    function updateNicname(string memory nicname) public returns (bool) {
        address userAddress = address(msg.sender);
        require(usersId[userAddress] > 0, "Not found user!");
        require(bytes(nicname).length > 0, "Nicname not correct!");

        User storage user = _getUserByAddress(userAddress);

        user.nicname = nicname;

        return true;
    }

    /** View Functions **/

    function getConfigs() public view returns (Settings memory) {
        return configs;
    }

    function getRegisterUserCount() public view returns (uint) {
        return userCount;
    }

    function getStableCoinContract() public view returns (address) {
        return address(stablecoincontract);
    }

    function getUserById(uint _id) public view returns (User memory) {
        return _getUserById(_id);
    }

    function getUserByAddress(
        address _address
    ) public view returns (User memory) {
        return _getUserByAddress(_address);
    }

    function getAddressByUserId(uint _userid) public view returns (address) {
        return usersAddress[_userid];
    }

    function getReferralsByUserId(
        uint _userid
    ) public view returns (uint[] memory) {
        return referrers[_userid];
    }

    function getLevelsCount(uint _userid) public view returns (uint[] memory) {
        uint[] memory result = new uint[](configs.levels + 1);
        for (uint lv = 1; lv <= configs.levels; lv++) {
            result[lv] = (levelsCount[_userid][lv]);
        }
        return result;
    }

    function getLevelsIncome(uint _userid) public view returns (uint[] memory) {
        uint[] memory result = new uint[](configs.levels + 1);
        for (uint lv = 1; lv <= configs.levels; lv++) {
            result[lv] = (levelsIncome[_userid][lv]);
        }
        return result;
    }

    function getReferralsCountByUserId(
        uint _userid
    ) public view returns (uint) {
        return referrers[_userid].length;
    }

    /** Private Functions **/

    function _getUserByAddress(
        address _address
    ) internal view returns (User storage) {
        User storage user = users[usersId[_address]];
        return user;
    }

    function _getUserById(uint _id) internal view returns (User storage) {
        User storage user = users[_id];
        return user;
    }

    /** Owner Functions **/

    function transferOwnership(address newOwner) public override onlyOwner {
        address lastowner = owner();
        _transferOwnership(newOwner);
        users[ownerId].wallet = owner();
        usersId[owner()] = ownerId;
        usersAddress[ownerId] = owner();
        delete usersId[lastowner];
    }

    function setStableCoinContract(
        address _address
    ) public onlyOwner returns (bool) {
        stablecoincontract = IERC20Metadata(_address);
        return true;
    }

    function settlementToken() public onlyOwner returns (bool) {
        require(
            stablecoincontract.balanceOf(address(this)) > 0,
            "Insufficient stablecoin balance!"
        );

        stablecoincontract.transfer(
            owner(),
            stablecoincontract.balanceOf(address(this))
        );
        return true;
    }

    function withdraw() public onlyOwner returns (bool) {
        require(address(this).balance > 0, "Insufficient balance!");

        payable(owner()).transfer(address(this).balance);
        return true;
    }
}
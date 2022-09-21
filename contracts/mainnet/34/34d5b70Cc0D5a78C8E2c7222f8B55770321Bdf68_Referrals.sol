// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/*
 * GelatoCream 
 * App:             https://gelatocream.io
 * Twitter:         https://twitter.com/gelatocreambsc
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IHelp {
    function Bytecode_2_1_7() external view returns (bool);
}

interface IPackages {
    function withdraw(address _user) external;
    function infoUser(address _user) external view returns(uint256, uint256, uint256, uint256);
    function totalStaked() external view returns(uint256);
    function totalStakedProject() external view returns(uint256);
    function totalPoolClaim() external view returns(uint256);
    function totalRecompound() external view returns(uint256);
    function totalWithdraws() external view returns(uint256);
    function pendingReward(address _user) external view returns (uint256);
    function getPackage() external view returns(uint, uint, uint, uint, uint);
    function getRefPercent() external view returns(uint, uint, uint, uint, uint);
    function getBalance() external view returns(uint256);
    function devFee() external view returns(uint256);
}

contract Referrals is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // Info of each members.
    struct MemberStruct {
        bool isExist;
        uint256 id;
        uint256 referrerID;
        uint256 referredUsers;
        uint256 earn;
        uint256 time;
    }
    // Membership structure
    mapping(address => MemberStruct) public members;
    // Member listing by id
    mapping(uint256 => address) public membersList;
    // List of referrals by user
    mapping(uint256 => mapping(uint256 => address)) public memberChild;
    // Moderators list
    mapping(address => bool) public moderators;
    // ID of the last registered member
    uint256 public lastMember;
    // Total earn referrals
    uint256 public totalEarnReferrals;
    // Total moderators
    uint256 public totalModerators;
    // Status moderators
    bool public statusModerators;
    

    constructor(address _dev) {
        addMember(_dev, address(this));
    }

    receive() external payable {}

    // Add or remove moderator
    function actionModerator(address _mod, bool _check) external onlyOwner {
        require(!statusModerators, "!statusModerators");
        moderators[_mod] = _check;
        totalModerators = totalModerators.add(1);
        if(totalModerators == 1) {
            statusModerators = true;
        }
    }

    modifier isModOrOwner() {
        require(owner() == msg.sender || moderators[msg.sender] , "!isModOrOwner");
        _;
    }

    modifier isModerator() {
        require(moderators[msg.sender] , "!isModOrOwner");
        _;
    }  
    
    // Only owner can register new users
    function addMember(address _member, address _parent) public isModOrOwner {
        if (lastMember > 0) {
            require(members[_parent].isExist, "Sponsor not exist");
        }
        MemberStruct memory memberStruct;
        memberStruct = MemberStruct({
            isExist: true,
            id: lastMember,
            referrerID: members[_parent].id,
            referredUsers: 0,
            earn: 0,
            time: block.timestamp
        });
        members[_member] = memberStruct;
        membersList[lastMember] = _member;
        memberChild[members[_parent].id][members[_parent].referredUsers] = _member;
        members[_parent].referredUsers++;
        lastMember++;
        emit eventNewUser(msg.sender, _member, _parent);
    }

    // Only owner can update the balance of referrals
    function updateEarn(address _member, uint256 _amount) public isModOrOwner {
        require(isMember(_member), "!member");
        members[_member].earn = members[_member].earn.add(_amount);
        totalEarnReferrals = totalEarnReferrals.add(_amount);
    }

    // function that registers members
    function registerUser(address _member, address _sponsor) public isModOrOwner {
        if(isMember(_member) == false){
            if(isMember(_sponsor) == false){
                _sponsor = this.membersList(0);
            }
            addMember(_member, _sponsor);
        }
    }

    // Returns the total number of referrals in the levels
    function countReferrals(address _member) public view returns (uint256[] memory){
        uint256[] memory counts = new uint256[](5);
       
        counts[0] = members[_member].referredUsers;

        address[] memory r_1 = getListReferrals(_member);

        for (uint256 i_1 = 0; i_1 < r_1.length; i_1++) {
            counts[1] += members[r_1[i_1]].referredUsers;

            address[] memory r_2 = getListReferrals(r_1[i_1]);
            for (uint256 i_2 = 0; i_2 < r_2.length; i_2++) {
                counts[2] += members[r_2[i_2]].referredUsers;

                address[] memory r_3 = getListReferrals(r_2[i_2]);
                for (uint256 i_3 = 0; i_3 < r_3.length; i_3++) {
                    counts[3] += members[r_3[i_3]].referredUsers;

                    address[] memory r_4 = getListReferrals(r_3[i_3]);
                    for (uint256 i_4 = 0; i_4 < r_4.length; i_4++) {
                        counts[4] += members[r_4[i_4]].referredUsers;
                    }

                }

            }

        }

        return counts;
    }

    // Returns the list of referrals
    function getListReferrals(address _member) public view returns (address[] memory){
        address[] memory referrals = new address[](members[_member].referredUsers);
        if(members[_member].referredUsers > 0){
            for (uint256 i = 0; i < members[_member].referredUsers; i++) {
                if(memberChild[members[_member].id][i] != address(0)){
                    if(memberChild[members[_member].id][i] != _member){
                        referrals[i] = memberChild[members[_member].id][i];
                    }
                } else {
                    break;
                }
            }
        }
        return referrals;
    }

    // Returns the address of the sponsor of an account
    function getSponsor(address account) public view returns (address) {
        return membersList[members[account].referrerID];
    }

    // Check if an address is registered
    function isMember(address _user) public view returns (bool) {
        return members[_user].isExist;
    }

    // Harvest all packages
    function harvest(address _user, address _p_1, address _p_2, address _p_3) external nonReentrant {
        if( _p_1 != address(0) ) {
            IPackages(_p_1).withdraw(_user);
        }
        if( _p_2 != address(0) ) {
            IPackages(_p_2).withdraw(_user);
        }
        if( _p_3 != address(0) ) {
            IPackages(_p_3).withdraw(_user);
        }
    }

    // transfer the ether to the user
    function transfer(address _user, uint256 _amount) external isModerator {
        if(_amount > 0 && address(this).balance > 0){
            payable(_user).transfer(_amount);
        }
    }

    // Returns value staked packages
    function stakeds(address _user, address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            (values[0],,,) = IPackages(_p_1).infoUser(_user);
        }
        if( _p_2 != address(0) ) {
            (values[1],,,) = IPackages(_p_2).infoUser(_user);
        }
        if( _p_3 != address(0) ) {
            (values[2],,,) = IPackages(_p_3).infoUser(_user);
        }
        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value profits packages
    function profits(address _user, address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            (,,values[0],) = IPackages(_p_1).infoUser(_user);
        }
        if( _p_2 != address(0) ) {
            (,,values[1],) = IPackages(_p_2).infoUser(_user);
        }
        if( _p_3 != address(0) ) {
            (,,values[2],) = IPackages(_p_3).infoUser(_user);
        }
        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value withdraws packages
    function withdraws(address _user, address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            (,,,values[0]) = IPackages(_p_1).infoUser(_user);
        }
        if( _p_2 != address(0) ) {
            (,,,values[1]) = IPackages(_p_2).infoUser(_user);
        }
        if( _p_3 != address(0) ) {
            (,,,values[2]) = IPackages(_p_3).infoUser(_user);
        }
        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value totalStaked packages
    function totalStaked(address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            values[0] = IPackages(_p_1).totalStaked();
        }
        if( _p_2 != address(0) ) {
            values[1] = IPackages(_p_2).totalStaked();
        }
        if( _p_3 != address(0) ) {
            values[2] = IPackages(_p_3).totalStaked();
        }

        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value totalStakedProject packages
    function totalStakedProject(address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            values[0] = IPackages(_p_1).totalStakedProject();
        }
        if( _p_2 != address(0) ) {
            values[1] = IPackages(_p_2).totalStakedProject();
        }
        if( _p_3 != address(0) ) {
            values[2] = IPackages(_p_3).totalStakedProject();
        }

        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value totalPoolClaim packages
    function totalPoolClaim(address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            values[0] = IPackages(_p_1).totalPoolClaim();
        }
        if( _p_2 != address(0) ) {
            values[1] = IPackages(_p_2).totalPoolClaim();
        }
        if( _p_3 != address(0) ) {
            values[2] = IPackages(_p_3).totalPoolClaim();
        }

        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value totalRecompound packages
    function totalRecompound(address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            values[0] = IPackages(_p_1).totalRecompound();
        }
        if( _p_2 != address(0) ) {
            values[1] = IPackages(_p_2).totalRecompound();
        }
        if( _p_3 != address(0) ) {
            values[2] = IPackages(_p_3).totalRecompound();
        }

        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value totalWithdraws packages
    function totalWithdraws(address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            values[0] = IPackages(_p_1).totalWithdraws();
        }
        if( _p_2 != address(0) ) {
            values[1] = IPackages(_p_2).totalWithdraws();
        }
        if( _p_3 != address(0) ) {
            values[2] = IPackages(_p_3).totalWithdraws();
        }

        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value pendingReward packages
    function pendingReward(address _user, address _p_1, address _p_2, address _p_3) external view returns(uint256[] memory) {
        uint256[] memory values = new uint256[](4);

        if( _p_1 != address(0) ) {
            values[0] = IPackages(_p_1).pendingReward(_user);
        }
        if( _p_2 != address(0) ) {
            values[1] = IPackages(_p_2).pendingReward(_user);
        }
        if( _p_3 != address(0) ) {
            values[2] = IPackages(_p_3).pendingReward(_user);
        }

        values[3] = values[0].add(values[1]).add(values[2]);

        return values;
    }

    // Returns value getPackage packages
    function getPackage(address _p_1) external view returns(uint256[] memory) {
        uint256[] memory _d = new uint256[](5);

        if( _p_1 != address(0) ) {
            (_d[0],_d[1],_d[2],_d[3],_d[4]) = IPackages(_p_1).getPackage();
        }

        return _d;
    }

    // Returns value getRefPercent packages
    function getRefPercent(address _p_1) external view returns(uint256[] memory) {
        uint256[] memory _d = new uint256[](5);

        if( _p_1 != address(0) ) {
            (_d[0],_d[1],_d[2],_d[3],_d[4]) = IPackages(_p_1).getRefPercent();
        }

        return _d;
    }

    // Helper functions
    function getEthBalance(address addr) external view returns (uint256 balance) {
        balance = addr.balance;
    }

    // returns balance contract
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    // returns balance contract package
    function getBalance(address _p_1) external view returns(uint256) {
        return IPackages(_p_1).getBalance();
    }

    // block mining for platform development
    function minningBlocks() external {}
    
    event eventNewUser(address _mod, address _member, address _parent);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
library SafeMath {
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
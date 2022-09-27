// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ClaimTeamAndMarketingBzai is Ownable, ReentrancyGuard {

    IERC20 public BZAI;
    uint256 public assigned;
    uint256 constant _blockEvery = 2; // block every 2 seconds on polygon mainnet

    constructor(address _BZAI){
        BZAI = IERC20(_BZAI);
    }

    event Claimed(address indexed user, string vestingType, uint256 amount);

    uint256 public tgeUnlockedBlock;

    mapping(address => uint256[6]) _teamVestingAmount;
    mapping(address => uint256[6]) _marketingVestingAmount;

    uint256[6] _teamVestingBlock;
    uint256[6] _marketingVestingBlock;

    function getAddressAllocs(address _user) external view returns(uint256[6] memory teamVesting,uint256[6] memory marketingVesting){
        return (_teamVestingAmount[_user],_marketingVestingAmount[_user]);
    }

    function resetAlloc(address _user) external onlyOwner {
        uint256 toReset;
        for(uint256 i = 0; i < 6 ;){
            toReset += _teamVestingAmount[_user][i];
            toReset += _marketingVestingAmount[_user][i];
            unchecked {++ i;}
        }
        delete _teamVestingAmount[_user];
        delete _marketingVestingAmount[_user];
        assigned -= toReset;
    }

    function setTgeBlock(uint256 _block) external onlyOwner {
        require(tgeUnlockedBlock == 0 || tgeUnlockedBlock > block.number,"Can't set after TGE block");
        require(_block > block.number,"TGE can't be in past time");

        tgeUnlockedBlock = _block;
        uint256 toAdd = 86400 * 30 / _blockEvery; 

        _marketingVestingBlock[0] = _block + toAdd; 
        _teamVestingBlock[0] = _block + (toAdd * 6); 


        for(uint256 i = 1 ; i < 6 ;){
            _marketingVestingBlock[i] = _marketingVestingBlock[0] + (i * toAdd);
            _teamVestingBlock[i] = _teamVestingBlock[0] + (i * toAdd);
            unchecked {++i ;}
        }

    }

    function setTeamVesting(address _user, uint256 _amount) external onlyOwner {
        require(BZAI.balanceOf(address(this)) >= assigned + _amount, "To much assigned");
        assigned += _amount;

        for(uint256 i = 0 ; i < 6 ; ){
            if(_teamVestingAmount[_user][i] > 0){
                assigned -= _teamVestingAmount[_user][i];
                _teamVestingAmount[_user][i] = 0;
            }
            unchecked { ++i ;}
        }

        uint256 claimablePart = _amount / 6;
        uint256 modulo = _amount % 6;

        for(uint256 i = 0 ; i < 6 ; ){
            _teamVestingAmount[_user][i] = claimablePart;
            if(i == 5){
                _teamVestingAmount[_user][i] += modulo;
            }
            unchecked { ++i ;}
        }
    }

    function setMarketingVesting(address _user, uint256 _amount) external onlyOwner {
        require(BZAI.balanceOf(address(this)) - assigned - _amount > 0, "To much assigned");

        for(uint256 i = 0 ; i < 6 ; ){
            if(_marketingVestingAmount[_user][i] > 0){
                assigned -= _marketingVestingAmount[_user][i];
                _marketingVestingAmount[_user][i] = 0;
            }
            unchecked { ++i ;}
        }
        assigned += _amount;

        uint256 claimablePart = _amount / 6;
        uint256 modulo = _amount % 6;

        for(uint256 i = 0 ; i < 6 ; ){
            _marketingVestingAmount[_user][i] = claimablePart;
            if(i == 5){
                _marketingVestingAmount[_user][i] += modulo;
            }
            unchecked { ++i ;}
        }
    }

    function getMarketingClaimable(address _user) external view returns(uint256){
        return _getMarketingClaimable(_user);
    }

    function _getMarketingClaimable(address _user) internal view returns(uint256){
        uint256 _claimable;
        for (uint256 i = 0 ; i < 6 ; ){
            if(block.number >= _marketingVestingBlock[i]){
                _claimable += _marketingVestingAmount[_user][i];
            }else{
                break;
            }
            unchecked {++ i; }
        }
        return _claimable;
    }

    function getTeamClaimable(address _user) external view returns(uint256){
        return _getTeamClaimable(_user);
    }

    function _getTeamClaimable(address _user) internal view returns(uint256){
        uint256 _claimable;
        for (uint256 i = 0 ; i < 6 ; ){
            if(block.number >= _teamVestingBlock[i]){
                _claimable += _teamVestingAmount[_user][i];
            }else{
                break;
            }
            unchecked {++ i; }
        }
        return _claimable;
    }

    function _cleanMarketingClaimable(address _user) internal returns(uint256){
        uint256 _cleaned;
        for (uint256 i = 0 ; i < 6 ; ){
            if(block.number >= _marketingVestingBlock[i]){
                _cleaned += _marketingVestingAmount[_user][i];
                _marketingVestingAmount[_user][i] = 0;
            }else{
                break;
            }
            unchecked {++ i; }
        }
        emit Claimed(_user, "marketing", _cleaned);

        return _cleaned;
    }

    function _cleanTeamClaimable(address _user) internal returns(uint256){
        uint256 _cleaned;
        for (uint256 i = 0 ; i < 6 ; ){
            if(block.number >= _teamVestingBlock[i]){
                _cleaned += _teamVestingAmount[_user][i];
                _teamVestingAmount[_user][i] = 0;
            }else{
                break;
            }
            unchecked {++ i; }
        }
        emit Claimed(_user, "team", _cleaned);

        return _cleaned;
    }

    function claimMarketingBZAIs() external nonReentrant{
        require(tgeUnlockedBlock != 0,"tge not set");
        require(block.number >= tgeUnlockedBlock,"Too soon !");

        uint256 _claimable = _getMarketingClaimable(msg.sender);
        uint256 _cleaned = _cleanMarketingClaimable(msg.sender);
        require(_claimable == _cleaned, "Something wrong in claimable process");
        assigned -= _cleaned;

        require(BZAI.transfer(msg.sender, _cleaned));
        require(assigned <= BZAI.balanceOf(address(this)));
    }

    function claimTeamBZAIs() external nonReentrant{
        require(tgeUnlockedBlock != 0,"tge not set");
        require(block.number >= tgeUnlockedBlock,"Too soon !");

        uint256 _claimable = _getTeamClaimable(msg.sender);
        uint256 _cleaned = _cleanTeamClaimable(msg.sender);
        require(_claimable == _cleaned, "Something wrong in claimable process");
        assigned -= _cleaned;

        require(BZAI.transfer(msg.sender, _cleaned));
        require(assigned <= BZAI.balanceOf(address(this)));
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
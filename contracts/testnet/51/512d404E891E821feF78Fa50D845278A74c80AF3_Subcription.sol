// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Subcription is Ownable {

    address public feeSystemAddress;
    address public token2Buy = 0x018f908aCE994E1fb39026AE2654e63a00361766;
    address public signer;
    struct Package{
        string packageId;
        string name;
        uint256 price;
        uint256 timePeriod;
        bool enable;
        address owner;
    }
    struct User{
        string[] pakageIDs;
        mapping(string => uint) expiredTime; // pakage id => expired timestamp
    }
    Package[] public packageList;
    mapping(address => User) users;
    mapping(string => Package) public packages;
    mapping(uint => bool) public requests;

    function getMessageHash(address _user, string memory _packageId, uint _requestId, uint _feeSystem) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_user, _packageId, _requestId, _feeSystem));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
    function permit(address _user, string memory _packageId, uint _requestId, uint _feeSystem, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        return ecrecover(getEthSignedMessageHash(getMessageHash(_user, _packageId, _requestId, _feeSystem)), v, r, s) == signer;
    }
    constructor(address _signer, address _feeSystemAddress) {
        signer = _signer;
        feeSystemAddress = _feeSystemAddress;

    }
    function getUserPakages(address _user) external view returns(string[] memory _pakages) {
        return users[_user].pakageIDs;
    }
    function getUserPakages(address _user, string memory _pakageId) external view returns(uint expiredTime) {
        return users[_user].expiredTime[_pakageId];
    }
    function _updatePakageExpiredTime(string memory _packageId) internal {
        User storage _user = users[_msgSender()];
        uint remainTime = _user.expiredTime[_packageId] > 0 && _user.expiredTime[_packageId] > block.timestamp ? _user.expiredTime[_packageId] - block.timestamp : 0;
        uint  newTime = remainTime + packages[_packageId].timePeriod;
        bool exited;
        for(uint i = 0; i < _user.pakageIDs.length; i ++) {
            if(keccak256(bytes(_packageId)) == keccak256(bytes(_user.pakageIDs[i]))) exited = true;
        }
        if(!exited) _user.pakageIDs.push(_packageId);
        _user.expiredTime[_packageId] = block.timestamp + newTime;
    }
    function buyByBTCZ(string memory _packageId, uint _requestId, uint _feeSystem, uint8 v, bytes32 r, bytes32 s) external {
        require(permit(_msgSender(), _packageId, _requestId, _feeSystem, v, r, s), "Refferal: Invalid signature");
        require(!requests[_requestId], 'requested');
        require(packages[_packageId].enable, 'package disabled');
        IERC20(token2Buy).transferFrom(_msgSender(), address(this), packages[_packageId].price);
        IERC20(token2Buy).transfer(packages[_packageId].owner, packages[_packageId].price - _feeSystem);
        IERC20(token2Buy).transfer(feeSystemAddress, _feeSystem);
        _updatePakageExpiredTime(_packageId);
        requests[_requestId] = true;
    }
    function updatePakage(string memory _packageId, uint256 _price, uint256 _timePeriod, bool _enable) external {
        require(packages[_packageId].owner == _msgSender(), 'not owner');
        packages[_packageId].price = _price;
        packages[_packageId].timePeriod = _timePeriod;
        packages[_packageId].enable = _enable;

    }
    function registerSubcription(string memory _packageId, string memory _name, uint256 _price, uint256 _timePeriod) external {
        require(packages[_packageId].owner == address(0), "existed package");
        packageList.push(Package(_packageId, _name, _price, _timePeriod, true, _msgSender()));
        packages[_packageId] = packageList[packageList.length-1];

    }
    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


library TransferHelper {
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

interface IBEP20 {
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
        address[] addressList;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.addressList.push(account);
        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        for(uint256 index = 0; index < role.addressList.length; index++) {
            if(role.addressList[index] == account) {
                role.addressList[index] = role.addressList[role.addressList.length - 1];
                role.addressList.pop();
                break;
            }
        }
        role.bearer[account] = false;
    }

    function getAddressList(Role storage role) internal view returns(address[] memory) {
        return role.addressList;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account)
    internal
    view
    returns (bool)
    {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function minters() public view returns (address[] memory) {
        return _minters.getAddressList();
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ClaimReward is Context, MinterRole, Ownable {
    event Claim(address indexed user, uint256 claimId, address[] tokens, uint256[] amounts, uint256 atTime);

    address public signer = 0x7a7f38737BFCD8a1301Dd262a226780350980eA3;

    mapping(address => uint256) public currentSignedTime;
    mapping(address => mapping(uint256 => bool)) public isPaid;

    modifier onlySigner() {
        require(signer == _msgSender(), "Signer: caller is not the signer");
        _;
    }

    function getMessageHash(uint256 claimId, uint256 timestamp, address user, address[] memory tokens, uint256[] memory amounts) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(claimId, timestamp, user, tokens, amounts));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function allowClaim(
        uint256 claimId,
        uint256 timestamp,
        address user,
        address[] memory tokens, 
        uint256[] memory amounts,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        return ecrecover(getEthSignedMessageHash(getMessageHash(claimId, timestamp, user, tokens, amounts)), v, r, s) == signer;
    }

    function claim(uint256 claimId, uint256 timestamp, address[] memory tokens, uint256[] memory amounts, uint8 v, bytes32 r, bytes32 s) public {
        require(!isPaid[msg.sender][claimId], "Shares: Already paid!");
        require(currentSignedTime[msg.sender] < timestamp, "Shares: Invalid timestamp");
        require(allowClaim(claimId, timestamp, msg.sender, tokens, amounts, v, r, s), "Shares: Invalid signal");
        isPaid[msg.sender][claimId] = true;
        currentSignedTime[msg.sender] = timestamp;
        uint256 length = tokens.length;
        for (uint256 i = 0; i < length; i++) {
            if (tokens[i] == address(0)) {
                TransferHelper.safeTransferETH(msg.sender, amounts[i]);
            } else {
                IBEP20(tokens[i]).transfer(msg.sender, amounts[i]);
            }
                
        }
        emit Claim(msg.sender, claimId, tokens, amounts, timestamp);
    }

    function configSigner(address _signer) public onlySigner {
        signer = _signer;
    }
}
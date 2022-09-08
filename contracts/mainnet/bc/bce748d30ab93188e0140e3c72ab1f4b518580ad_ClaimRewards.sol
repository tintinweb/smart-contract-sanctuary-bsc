/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


library TransferHelper {
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

contract Signer is Context {
    event SignerTransferred(address indexed previousSigner, address indexed newSigner);
    
    address private _signer;

    mapping(address => uint256) public currentSignedTime;

    modifier onlySigner() {
        require(_signer == _msgSender(), "Signer: caller is not the signer");
        _;
    }

    function signer() public view returns (address) {
        return _signer;
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function permit(
        bytes32 messageHash,
        uint256 timestamp, 
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        require(timestamp > block.timestamp, "Signer: expired signature");
        require(currentSignedTime[msg.sender] < timestamp, "Signer: Invalid timestamp");
        return ecrecover(getEthSignedMessageHash(messageHash), v, r, s) == signer();
    }

    function configSigner(address newSigner) public onlySigner {
        _configSigner(newSigner);
    }

    function _configSigner(address newSigner) internal {
        require(newSigner != address(0), "Signer: new signer is the zero address");
        emit SignerTransferred(_signer, newSigner);
        _signer = newSigner;
    }

    function _setCurrentSignedTime(uint256 timestamp) internal {
        currentSignedTime[msg.sender] = timestamp;
    }
}

contract ClaimRewards is Context, Ownable, Signer {
    event Claim(address indexed user, address[] tokens, uint256[] amounts, uint256 expiredTimestamp);
    event ConfigAffiliate(address user, uint256 percent);

    fallback() external payable {}
    
    using SafeMath for uint256;

    address payable public affiliateAddress;
    uint256 public affiliatePercent;
    uint256 public maxPercent = 10000;

    bool private hasJoined;

    modifier joined() {
        require(!hasJoined, "Locked!");
        hasJoined = true;
        _;
        hasJoined = false;
    }

    constructor() {
        _configAffiliate(payable(0xC8d124633A540d6FeD2fBFacfAc4792B08749413), 300);
        _configSigner(0x1c2c72d0542279A475bB80729e031Ae062ACf2b5);
    }

    function getMessageHash(uint256 expiredTimestamp, address user, address[] memory tokens, uint256[] memory amounts) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(expiredTimestamp, user, tokens, amounts));
    }

    function claim(uint256 expiredTimestamp, address[] memory tokens, uint256[] memory amounts, uint8 v, bytes32 r, bytes32 s) external joined {
        require(tokens.length == amounts.length, "ClaimReward: Length mismatch");
        require(permit(getMessageHash(expiredTimestamp, msg.sender, tokens, amounts), expiredTimestamp, v, r, s), "ClaimReward: Invalid signal");
        _setCurrentSignedTime(expiredTimestamp);
        
        uint256 length = tokens.length;
        address msgSender = _msgSender();
        for (uint256 i = 0; i < length; i++) {
            uint256 affiliateAmount = amounts[i].mul(affiliatePercent).div(maxPercent);
            uint256 remainingAmount = amounts[i].sub(affiliateAmount);
            _transferToken(affiliateAddress, tokens[i], affiliateAmount);
            _transferToken(msgSender, tokens[i], remainingAmount);
        }

        emit Claim(msg.sender, tokens, amounts, expiredTimestamp);
    }

    function configAffiliate(address payable account, uint256 percent) external onlyOwner {
        require(percent <= maxPercent, "Claim: Invalid percent");
        _configAffiliate(account, percent);
    }

    function _configAffiliate(address payable account, uint256 percent) private {
        affiliateAddress = account;
        affiliatePercent = percent;
        emit ConfigAffiliate(account, percent);
    }

    function setMaxPercent(uint256 percent) external onlyOwner {
        require(percent >= 1000, "Claim: Invalid percent");
        maxPercent = percent;
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        address msgSender = _msgSender();
        _transferToken(msgSender, token, amount);
    }

    function _transferToken(address account, address token, uint256 amount) private {
        if (token == address(0)) {
            TransferHelper.safeTransferETH(account, amount);
        } else {
            IBEP20(token).transfer(account, amount);
        }
    }
}
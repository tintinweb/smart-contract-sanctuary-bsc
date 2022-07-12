/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Whitelist is Ownable {

    mapping(address => bool) public whitelist;
    
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted');
        _;
    }

    function addAddressToWhitelist(address addr) public onlyOwner returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] calldata addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract WoolFactory is Pausable, Whitelist, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Data of NFT items watched by this contract
    struct ItemData {
        uint256 price;
        address collection;
    }

    // Data of users who claim WOOL from this contract
    struct UserData {
        uint256 claimed;   // Total Claimed by Address
        uint256 xClaimed;  // Total Claims by Address
        uint256 heartbeat; // Last Claim Time of Address

        mapping(uint256 => uint256) itemCount; // Tier ID to quantity of items held
    }

    // Contract interfaces
    IERC20 public rewardsToken; // Rewards token

    uint256 public mintedSupply;
    uint256 public availableRewards;

    mapping(address => UserData) internal _users;
    mapping(uint256 => ItemData) internal _items;

    event onSetItem(address indexed caller, uint256 tier, address contractAddress, uint256 timestamp);

    constructor () {
        _items[1].price = 2e18;
        _items[2].price = 4e18;
        _items[3].price = 8e18;
        _items[4].price = 16e18;
        _items[5].price = 32e18;
        _items[6].price = 64e18;
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Find claimed amount of rewards by an address
    function claimedOf(address _user) external view returns (uint256) {
        return (_users[_user].claimed);
    }

    // Find how times an address has claimed rewards
    function claimsOf(address _user) external view returns (uint256) {
        return (_users[_user].xClaimed);
    }

    // Rewards available for the user to claim
    function claimableOf(address _user) public view returns (uint256) {

        // Get the last time of action, calculate the difference between then and now.
        uint256 _lastClaim = heartbeatOf(_user);
        uint256 _timeDifference = ((block.timestamp).sub(_lastClaim));
        
        // Find the 'tokens per second' and multiply by the time difference
        uint256 _rate = earningRateOf(_user);
        uint256 _mintable = ((_rate).mul(_timeDifference));

        return _mintable;
    }

    // Rewards per Second of an address
    function earningRateOf(address _user) public view returns (uint256) {
        (uint256 _tier1, uint256 _tier2, uint256 _tier3, uint256 _tier4, uint256 _tier5, uint256 _tier6) = itemsPerTierOf(_user);

        uint256 _totalTokens = (
            (_tier1 * priceOf(1)) + 
            (_tier2 * priceOf(2)) + 
            (_tier3 * priceOf(3)) + 
            (_tier4 * priceOf(4)) + 
            (_tier5 * priceOf(5)) + 
            (_tier6 * priceOf(6))
        );

        uint256 _tokensPerDay = (_totalTokens.div(365));
        uint256 _tokensPerSec = (_tokensPerDay.div(86400));

        return (_tokensPerSec);
    }

    // Last Claim Time of an address
    function heartbeatOf(address _user) public view returns (uint256) {

        // If the user has not claimed even once, their first claim time is yet untracked
        // For this, we keep their timestamp at the latest one of the block.
        if (_users[_user].xClaimed == 0) {
            return block.timestamp;
        }
        return (_users[_user].heartbeat);
    }

    // Get item count of a single tier for one _user
    function itemsTierTotalOf(address _user, uint256 _tierId) public view returns (uint256) {
        return (_users[_user].itemCount[_tierId]);
    }

    // Get item counts from all tiers for one _user
    function itemsPerTierOf(address _user) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 _tier1 = itemsTierTotalOf(_user, 1);
        uint256 _tier2 = itemsTierTotalOf(_user, 2);
        uint256 _tier3 = itemsTierTotalOf(_user, 3);
        uint256 _tier4 = itemsTierTotalOf(_user, 4);
        uint256 _tier5 = itemsTierTotalOf(_user, 5);
        uint256 _tier6 = itemsTierTotalOf(_user, 6);

        return (_tier1, _tier2, _tier3, _tier4, _tier5, _tier6);
    }

    // Find a count of all NFTs from all tiers for an address (stored numbers)
    function itemsOf(address _user) external view returns (uint256) {
        uint256 _tier1 = itemsTierTotalOf(_user, 1);
        uint256 _tier2 = itemsTierTotalOf(_user, 2);
        uint256 _tier3 = itemsTierTotalOf(_user, 3);
        uint256 _tier4 = itemsTierTotalOf(_user, 4);
        uint256 _tier5 = itemsTierTotalOf(_user, 5);
        uint256 _tier6 = itemsTierTotalOf(_user, 6);

        return (_tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6);
    }

    // Get the price of one of the NFTs (by Tier ID)
    function priceOf(uint256 _tier) public view returns (uint256) {
        return _items[_tier].price;
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Store numbers of NFTs to calculate earnings from (stops buy-claim exploit)
    function countItemsOf(address _user) external whenNotPaused() onlyWhitelisted() nonReentrant() {
        _users[_user].itemCount[1] = IERC721(_items[1].collection).balanceOf(_user);
        _users[_user].itemCount[2] = IERC721(_items[2].collection).balanceOf(_user);
        _users[_user].itemCount[3] = IERC721(_items[3].collection).balanceOf(_user);
        _users[_user].itemCount[4] = IERC721(_items[4].collection).balanceOf(_user);
        _users[_user].itemCount[5] = IERC721(_items[5].collection).balanceOf(_user);
        _users[_user].itemCount[6] = IERC721(_items[6].collection).balanceOf(_user);
    }

    // Claim Tokens
    function claimTokens(address _user) whenNotPaused() onlyWhitelisted() nonReentrant() external returns (uint256) {
        
        // Find the current earnings of a user
        uint256 claimable = claimableOf(_user);

        // If there's only some mintable remaining, give that to the user
        // (this is most likely to happen when the claimed rewards from this contract is near 1M)
        if (claimable > availableRewards) {
            claimable = availableRewards;
        }

        // If there's actually something to mint...
        if (claimable > 0) {

            // Credit tokens to the user
            rewardsToken.safeTransfer(_user, claimable);
        }

        // Update stats
        _users[_user].heartbeat = block.timestamp;
        _users[_user].claimed += claimable;
        _users[_user].xClaimed += 1;

        // Update minted and mintable totals
        mintedSupply += claimable;
        availableRewards = rewardsToken.balanceOf(address(this));

        // Return the amount minted
        return claimable;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // Add an item to the array of watched contracts
    function setItem(uint256 _tier, address _item) external whenPaused() onlyOwner() {
        require(_item != address(0), "INVALID_ADDRESS");
        
        _items[_tier].collection = _item;

        emit onSetItem(msg.sender, _tier, _item, block.timestamp);
    }

    // Set the Rewards Token Address
    function setRewardsToken(address _newToken) public whenPaused() onlyOwner() {
        rewardsToken = IERC20(_newToken);
        availableRewards = rewardsToken.balanceOf(address(this));
    }

    // Pause main contract functions
    function pause() public onlyOwner() returns (bool _success) {
        _pause();

        return true;
    }

    // Unpause main contract functions
    function unpause() public onlyOwner() returns (bool _success) {
        _unpause();

        return true;
    }
}
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
    bool active = true;

    mapping(address => bool) public whitelist;
    
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    modifier onlyWhitelisted() {
        if(active){
            require(whitelist[msg.sender], 'not whitelisted');
        }
        _;
    }

    function addAddressToWhitelist(address addr) public onlyOwner returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }
    function activateDeactivateWhitelist() public onlyOwner {
        active = !active;
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

contract WoolFactory is Pausable, Whitelist {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 claimed;  // How many tokens claimed?
        uint256 xClaimed; // How many claims total?

        uint256 lastClaimTime; // When was the last claim time?

        // Tier ID to quantity of items held
        mapping(uint256 => uint256) itemCount;
    }

    // Contract interfaces
    IERC20 public rewardsToken;   // WOOL token

    mapping(uint256 => address) watchedContracts;
    mapping(address => UserInfo) internal _users;

    constructor (address _WOOL) {
        rewardsToken = IERC20(_WOOL);
        addAddressToWhitelist(msg.sender);
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Find claimed amount of WOOL by an address
    function claimedOf(address _user) external view returns (uint256) {
        return (_users[_user].claimed);
    }

    // Find how many claims total an address has made
    function claimsOf(address _user) external view returns (uint256) {
        return (_users[_user].xClaimed);
    }

    // How much WOOL is available for the user to mint
    function availableWoolOf(address _user) public view returns (uint256) {

        // Get the last time of action, calculate the difference between then and now.
        uint256 _lastClaim = lastClaimTimeOf(_user);
        uint256 _timeDiff = ((block.timestamp).sub(_lastClaim));
        
        // Find the 'tokens per second' and multiply by the time difference
        uint256 _wps = woolPerSecondOf(_user);
        uint256 _toMint = ((_wps).mul(_timeDiff));

        return _toMint;
    }

    // WOOL per Second of an address
    function woolPerSecondOf(address _user) public view returns (uint256) {
        (uint256 _tier1, uint256 _tier2, uint256 _tier3, uint256 _tier4, uint256 _tier5, uint256 _tier6) = viewItems(_user);

        uint256 _tokensPerYear = (
            (_tier1 * getMintPriceOf(1)) + 
            (_tier2 * getMintPriceOf(2)) + 
            (_tier3 * getMintPriceOf(3)) + 
            (_tier4 * getMintPriceOf(4)) + 
            (_tier5 * getMintPriceOf(5)) + 
            (_tier6 * getMintPriceOf(6))
        );

        uint256 _tokensPerDay = (_tokensPerYear.div(365));
        uint256 _tokensPerSec = (_tokensPerDay.div(86400));

        return (_tokensPerSec);
    }

    // Last Claim Time of an address
    function lastClaimTimeOf(address _user) public view returns (uint256) {

        // If the user has not claimed even once, their first claim time is yet untracked
        // For this, we keep their timestamp at the latest one of the block.
        if (_users[_user].xClaimed == 0) {
            return block.timestamp;
        }
        return (_users[_user].lastClaimTime);
    }

    // Get item count of a single tier for one _user
    function totalItemsOfTier(address _user, uint256 _tierId) public view returns (uint256) {
        return (_users[_user].itemCount[_tierId]);
    }

    // Get item counts from all tiers for one _user
    function viewItems(address _user) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 _tier1 = _users[_user].itemCount[1];
        uint256 _tier2 = _users[_user].itemCount[2];
        uint256 _tier3 = _users[_user].itemCount[3];
        uint256 _tier4 = _users[_user].itemCount[4];
        uint256 _tier5 = _users[_user].itemCount[5];
        uint256 _tier6 = _users[_user].itemCount[6];

        return (_tier1, _tier2, _tier3, _tier4, _tier5, _tier6);
    }

    // Find a count of all NFTs from all tiers for an address (stored numbers)
    function totalItemsOf(address _user) external view returns (uint256) {
        uint256 _tier1 = _users[_user].itemCount[1];
        uint256 _tier2 = _users[_user].itemCount[2];
        uint256 _tier3 = _users[_user].itemCount[3];
        uint256 _tier4 = _users[_user].itemCount[4];
        uint256 _tier5 = _users[_user].itemCount[5];
        uint256 _tier6 = _users[_user].itemCount[6];

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Get the price of one of the NFTs (by Tier ID)
    function getMintPriceOf(uint256 _tier) public pure returns (uint256) {

        if (_tier == 1) {return 2e18;}
        if (_tier == 2) {return 4e18;}
        if (_tier == 3) {return 8e18;}
        if (_tier == 4) {return 16e18;}
        if (_tier == 5) {return 32e18;}
        if (_tier == 6) {return 64e18;}

        return 0;
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Add an address to the watched items index
    function addItem(uint256 _tier, address _item) external onlyWhitelisted() {
        require(_item != address(0), "INVALID_ADDRESS");
        
        watchedContracts[_tier] = _item;
    }

    // Store numbers of NFTs to calculate earnings from (stops buy-claim exploit)
    function updateItems(address _user) external onlyWhitelisted() {
        _users[_user].itemCount[1] = IERC721(watchedContracts[1]).balanceOf(_user);
        _users[_user].itemCount[2] = IERC721(watchedContracts[2]).balanceOf(_user);
        _users[_user].itemCount[3] = IERC721(watchedContracts[3]).balanceOf(_user);
        _users[_user].itemCount[4] = IERC721(watchedContracts[4]).balanceOf(_user);
        _users[_user].itemCount[5] = IERC721(watchedContracts[5]).balanceOf(_user);
        _users[_user].itemCount[6] = IERC721(watchedContracts[6]).balanceOf(_user);
    }

    // Claim Tokens
    function claimTokens(address _user) onlyWhitelisted() external returns (uint256) {

        uint256 _rewards = rewardsToken.balanceOf(address(this));

        // Find the current earnings of a user
        uint256 _toMint = availableWoolOf(_user);

        if (_toMint > 0) {
            // Mint the appropriate tokens
            // Note: This finds the minimum - user entitlement or available rewards
            rewardsToken.safeTransfer(_user, SafeMath.min(_rewards, _toMint));
        }

        // Update stats
        _users[_user].lastClaimTime = block.timestamp;
        _users[_user].claimed += _toMint;
        _users[_user].xClaimed += 1;

        // Return the amount minted
        return _toMint;
    }

    // Set the Rewards Token Address
    function setRewardsToken(address _addr) public onlyOwner() {
        require(Address.isContract(_addr) && _addr != address(0), "INVALID_ADDRESS");
        rewardsToken = IERC20(_addr);
    }
}
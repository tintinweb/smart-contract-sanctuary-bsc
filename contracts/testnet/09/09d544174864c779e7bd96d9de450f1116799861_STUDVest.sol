// SPDX-License-Identifier: MIT
// Studyum Labs Contracts

pragma solidity ^0.8.0;

import "./Pausable.sol";
import "./IBEP20.sol";
import "./SafeMath.sol";

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract STUDVest is Pausable {

    struct VestingItem {
        uint256 timestamp;
        uint256 amount;
        bool claimed;
    }

    struct Vesting {
        VestingItem[] vestingItems;
        uint256 vestingStart;
        string description;
    }

    using SafeMath for uint256;

    IBEP20 private _token;
    address[] private _beneficiaries;
    mapping(address => Vesting) private _vestings;
    mapping(address=>bool) private _blacklist;

    /**
     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
     * beneficiaries.
     * @param token Address of the token which will be vested.
     * @param token Address of the contract owner 
     */
    constructor (address token, address payable owner) {
        require(token != address(0), "STUDVest: Token is the zero address.");
        require(owner != address(0), "STUDVest: Owner is the zero address.");

        _token = IBEP20(token);
        transferOwnership(owner);
    }

    /**
     * @dev Adds an address to a vesting.
     * @param _beneficiary Address to be vested.
     * @param _description Description of a vested address.
     * @param _vestingItems An array of vesting items. Refer to struct: VestingItem
     */
    function vest(address _beneficiary, string memory _description, VestingItem[] memory _vestingItems) external onlyOwner returns (bool) {
        Vesting storage vesting = _vestings[_beneficiary];

        require(vesting.vestingStart == 0, "STUDVest: Address is already vested.");
        require(_beneficiary != address(0), "STUDVest: Beneficiary is the zero address.");
        require(_vestingItems.length > 0, "STUDVest: Vesting items should be provided.");

        // check if timestamps are ordered correctly
        _checkAcsendingOrder(_vestingItems);

        // we are sure vesting for this address doesn't exist at this point
        // we are creating it indirectly
        _vestings[_beneficiary].description = _description;
        _vestings[_beneficiary].vestingStart = block.timestamp; 
        for (uint256 i = 0; i < _vestingItems.length; i++) {
            _vestings[_beneficiary].vestingItems.push(_vestingItems[i]);  
        }
        
        // once we created a veting, we are storing the beneficiary address as well
        _beneficiaries.push(_beneficiary);
        
        emit TokensVested(_beneficiary, _description, block.timestamp);

        return true;
    }

    function _checkAcsendingOrder (VestingItem[] memory _vestingItems) internal pure {
        uint256 length = _vestingItems.length;
        for (uint256 i = 0; i < length - 1; i++) {
            VestingItem memory older = _vestingItems[i];
            VestingItem memory newer = _vestingItems[i+1];
            require(older.timestamp < newer.timestamp, "STUDVest: Vesting start dates should be in acsending order.");
        }
    }

    /**
     * @dev Claims the tokens from the contract if they are claimable. If the msgSender() has its
     *  address vested and if the period has passed, tokens can be claimed.
     */
    function claim() external whenNotPaused returns (bool) {
        require(!_blacklist[_msgSender()], "STUDVest: User is blacklisted");
        require(_vestings[_msgSender()].vestingStart > 0, "STUDVest: Address is not vested.");

        uint256 claimableAmount = _claimable(_msgSender());

        require(claimableAmount > 0, "STUDVest: Claimable amount has to be greater than zero.");

        for (uint256 i = 0; i < _vestings[_msgSender()].vestingItems.length; i++) {
            if (_vestings[_msgSender()].vestingItems[i].timestamp < block.timestamp) {
                _vestings[_msgSender()].vestingItems[i].claimed = true;
            }
        }

        emit TokensClaimed(_msgSender(), claimableAmount);

        require(_token.transfer(_msgSender(), claimableAmount));

        return true;
    }
   
    /**
     * @dev Checks if the given address is blacklisted..
     * @param _beneficiary User address.
     */
    function isBlacklisted(address _beneficiary) external view returns (bool) {
        return _blacklist[_beneficiary];
    }
    
    /**
     * @dev Returns addresses that have their tokens vested.
     */
    function beneficiaries() external view returns (address[] memory) {
        return _beneficiaries;
    }


    /**
     * @dev Returns the information about vested tokens for a given address.
     * @param _vestingAddress Vesting address.
     */
    function getVesting(address _vestingAddress) external view returns (Vesting memory) {
        return _vestings[_vestingAddress];
    }

    /**
     * @dev Returns the amount of tokens that can be claimable by vesting address..
     * @param _beneficiary Address of a beneficiary.
     */
    function getClaimableAmount(address _beneficiary) external view returns (uint256) {
        return _claimable(_beneficiary);
    }

    /**
     * @dev Calculates an amount of tokens that can be claimable by a beneficiary address.
     * @param _beneficiary Address of a beneficiary.
     */
    function _claimable(address _beneficiary) internal view returns (uint256) {
        Vesting storage vesting = _vestings[_beneficiary];
        uint256 sum = 0;
        uint256 length = vesting.vestingItems.length;
        if (length == 0) return 0;
        for (uint256 i = 0; i < length; i++) {
            VestingItem memory vestingItem = vesting.vestingItems[i];
            if (!vestingItem.claimed && vestingItem.timestamp < block.timestamp) {
                sum = SafeMath.add(sum, vestingItem.amount);
            }
        }
        return sum;
    }

    /**
     * @dev Extract mistakenly sent tokens to the contract.
     */
    function extractMistakenlySentTokens(address _tokenAddress) external onlyOwner {
        if (_tokenAddress == address(0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }

        IBEP20 bep20Token = IBEP20(_tokenAddress);
        uint256 balance = bep20Token.balanceOf(address(this));
        emit ExtractedTokens(_tokenAddress, owner(), balance);
        (bool sent) = _token.transfer(owner(), balance);
        require(sent, "STUDVest: Tokens not transferred.");
    }

    /**
     * @dev Blackclist an address in case of bad behavriour.
     * @param _beneficiary)  Address to be blacklisted.
     */
    function blacklist(address _beneficiary) external onlyOwner {
        require(!_blacklist[_beneficiary], "STUDVest: User already blacklisted");
        _blacklist[_beneficiary] = true;
        
        emit UserBlackListed(_beneficiary);
    }
    
    /**
     * @dev Removes an address from a blacklist.
     * @param _beneficiary Address to be whiteliste.
     */
    function unblacklist(address _beneficiary) external onlyOwner {
        require(_blacklist[_beneficiary], "STUDVest: User already whitelisted");
        _blacklist[_beneficiary] = false;
        
        emit UserWhiteListed(_beneficiary);
    }

    /**
     * @dev Emitted when the tokens are withdrawn from contract.
     */
    event TokensVested(address beneficiary, string description, uint256 vestingStart);
    /**
     * @dev Emitted when the mistakenly sent tokens are claimed.
     */
    event TokensClaimed(address _owner, uint256 _amount);
    /**
     * @dev Emitted when user is removed from blacklist.
     */
    event UserWhiteListed(address _user);
    /**
     * @dev Emitted when user is blacklisted.
     */
    event UserBlackListed(address _user);
    /**
     * @dev Emitted when mistakenly sent tokens are extracted.
     */
    event ExtractedTokens(address _token, address _owner, uint256 amount);
}
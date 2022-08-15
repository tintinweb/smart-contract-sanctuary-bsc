//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface I_HashGame {
    function resetUserMvcrBurstCount(address) external;
    function getUserMvcrBurstCount(address) external view returns(uint256); 
    function isUserMvcrGameActive(address _userAddress) external view returns(bool);
}

contract Jackpot is ReentrancyGuard {
    IERC20 public MVCC;
    I_HashGame public IHashGame;

    struct UserInfo {
        uint256 gameMode;
        bool jpActive;      
        bool gjpActive;
        uint256 jpPurchaseTimestamp;
        uint256 gjpPurchaseTimestamp;
        uint256 jpClaimTimestamp;
        uint256 gjpClaimTimestamp;
    }

    mapping (address => UserInfo) private userInfo;
    mapping (address => bool) private operator;

    uint256 public constant DENOM = 1000;
    uint256[] public jackpotAllocation = [0, 2, 3, 4, 5];
    uint256[] public grandJackpotAllocation = [0, 200, 300, 400, 500];

    bool private inDistribution;
    uint256 private jackpotFee = 1 * (10**18); 
    uint256 private grandJackpotFee = 50 * (10**18); 

    modifier lockTheJackpot {
        inDistribution = true;
        _;
        inDistribution = false;
    }

    modifier onlyOperator {
        require(isOperator(msg.sender), "Only operator can perform this action");
        _;
    }

    constructor(address _mvcc, address _hashGame) {
        MVCC = IERC20(_mvcc);
        IHashGame = I_HashGame(_hashGame);
        
        operator[_hashGame] = true;
        operator[msg.sender] = true;
    }

    function purchaseJackpot(uint256 _gid, address _userAddress) external onlyOperator {
        UserInfo storage _userInfo = userInfo[_userAddress];

        require(_gid != 0, "Invalid game ID");
        require(!_userInfo.jpActive, "Jackpot active, cannot purchase again");
        require(MVCC.balanceOf(_userAddress) >= jackpotFee, "Insufficient MVCC");

        // Check allowance
        uint256 _allowance = MVCC.allowance(_userAddress, address(this));
        require(_allowance >= jackpotFee, "Insufficient allowance");

        bool _status = MVCC.transferFrom(_userAddress, address(this), jackpotFee);
        require(_status, "Faled to transfer fund");

        // Reset user consecutive burst count
        if(IHashGame.getUserMvcrBurstCount(_userAddress) > 0)
            IHashGame.resetUserMvcrBurstCount(_userAddress);

        _userInfo.gameMode = _gid;
        _userInfo.jpActive = true;
        _userInfo.jpPurchaseTimestamp = block.timestamp;

        emit PurchaseJackpot(_gid, _userAddress);
    }

    function purchaseGrandJackpot() external {
        UserInfo storage _userInfo = userInfo[msg.sender];

        require(_userInfo.gameMode != 0, "Invalid game ID");
        require(_userInfo.jpActive, "No active jackpot");
        require(!_userInfo.gjpActive, "Grand jackpot active, cannot purchase again");

        // Check user current Mvcr game status
        bool _gameActive = IHashGame.isUserMvcrGameActive(msg.sender);
        require(!_gameActive, "Cannot purchase grand jackpot after game started");

        // Check user consecutive burst count 
        uint256 _burstCount = IHashGame.getUserMvcrBurstCount(msg.sender);
        require(_burstCount == 1, "Consecutive burst count must be 1");

        // Check allowance
        uint256 _allowance = MVCC.allowance(msg.sender, address(this));
        require(_allowance >= grandJackpotFee, "Insufficient allowance");

        require(MVCC.balanceOf(msg.sender) >= grandJackpotFee, "Insufficient MVCC");
        bool _status = MVCC.transferFrom(msg.sender, address(this), grandJackpotFee);
        require(_status, "Faled to transfer fund");

        _userInfo.gjpActive = true;
        _userInfo.gjpPurchaseTimestamp = block.timestamp;

        emit PurchaseGrandJackpot(_userInfo.gameMode, msg.sender);
    }

    function claimJackpot() external nonReentrant lockTheJackpot {
        UserInfo storage _userInfo = userInfo[msg.sender];

        require(!wonGrandJackpot(msg.sender), "Grand jackpot rewards found");
        require(wonJackpot(msg.sender), "No jackpot rewards found");

        uint256 _rewardAmount = getCurrentJackpotReward(_userInfo.gameMode);
        require(MVCC.balanceOf(address(this)) >= _rewardAmount, "Insufficient MVCC in contract");

        _userInfo.jpActive = false;
        _userInfo.jpPurchaseTimestamp = 0;
        _userInfo.jpClaimTimestamp = block.timestamp;

        // Reset user consecutive burst count
        IHashGame.resetUserMvcrBurstCount(msg.sender);

        // Transfer rewards to user
        MVCC.transfer(msg.sender, _rewardAmount);

        emit ClaimJackpot(_userInfo.gameMode, msg.sender, _rewardAmount);
    }

    function claimGrandJackpot() external nonReentrant lockTheJackpot {
        UserInfo storage _userInfo = userInfo[msg.sender];

        require(wonGrandJackpot(msg.sender), "No grand jackpot rewards found");

        uint256 _rewardAmount = getCurrentGrandJackpotReward(_userInfo.gameMode);
        require(MVCC.balanceOf(address(this)) >= _rewardAmount, "Insufficient MVCC in contract");

        _userInfo.jpActive = false;
        _userInfo.gjpActive = false;
        _userInfo.jpPurchaseTimestamp = 0;
        _userInfo.jpClaimTimestamp = block.timestamp;
        _userInfo.gjpPurchaseTimestamp = 0;
        _userInfo.gjpClaimTimestamp = block.timestamp;

        // Reset user consecutive burst count
        IHashGame.resetUserMvcrBurstCount(msg.sender);

        // Transfer rewards to user
        MVCC.transfer(msg.sender, _rewardAmount);

        emit ClaimGrandJackpot(_userInfo.gameMode, msg.sender, _rewardAmount);
    }

    function rescueToken(address _token, address _to) external onlyOperator {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, _contractBalance);

        emit RescueToken(_token, _to);
    }

    // ===================================================================
    // GETTERS
    // ===================================================================
    
    function isOperator(address _userAddress) public view returns(bool) {
        return operator[_userAddress];
    }
    
    function wonJackpot(address _userAddress) public view returns(bool) {
        UserInfo storage _userInfo = userInfo[_userAddress];
        uint256 _burstCount = IHashGame.getUserMvcrBurstCount(_userAddress);

        if(_userInfo.jpActive && _burstCount == 1) {
            return true;
        } 
        return false;
    }

    function wonGrandJackpot(address _userAddress) public view returns(bool) {
        UserInfo storage _userInfo = userInfo[_userAddress];
        uint256 _burstCount = IHashGame.getUserMvcrBurstCount(_userAddress);

        if(_userInfo.gjpActive && _burstCount == 2) {
            return true;
        } 
        return false;
    }

    function getUserInfo(address _userAddress) external view returns(UserInfo memory) {
        return userInfo[_userAddress];
    }

    function getCurrentJackpotReward(uint256 _gid) public view returns(uint256) {
        uint256 _contractBalance = MVCC.balanceOf(address(this));
        if(_contractBalance == 0) return 0;

        uint256 rewardAmount = _contractBalance * jackpotAllocation[_gid] / DENOM;
        return rewardAmount;
    }

    function getCurrentGrandJackpotReward(uint256 _gid) public view returns(uint256) {
        uint256 _contractBalance = MVCC.balanceOf(address(this));
        if(_contractBalance == 0) return 0;

        uint256 rewardAmount = _contractBalance * grandJackpotAllocation[_gid] / DENOM;
        return rewardAmount;
    }

    function getPurchaseGrandJackpotFlag(address _userAddress) external view returns(bool) {
        UserInfo storage _userInfo = userInfo[_userAddress];
        bool _gameActive = IHashGame.isUserMvcrGameActive(_userAddress);
        uint256 _burstCount = IHashGame.getUserMvcrBurstCount(_userAddress);

        if(_userInfo.jpActive && !_userInfo.gjpActive && !_gameActive && _burstCount == 1)
            return true;
        else
            return false;
    } 

    // ===================================================================
    // SETTERS
    // ===================================================================
    function setOperator(address _userAddress, bool _bool) external onlyOperator {
        require(_userAddress != address(0), "Address zero");
        operator[_userAddress] = _bool;

        emit SetOperator(_userAddress, _bool);
    }

    function setJackpotFee(uint256 _fee) external onlyOperator {
        require(_fee != 0, "value zero");
        jackpotFee = _fee;

        emit SetJackpotFee(_fee);
    }

    function setGrandJackpotFee(uint256 _fee) external onlyOperator {
        require(_fee != 0, "value zero");
        grandJackpotFee = _fee;

        emit SetGrandJackpotFee(_fee);
    }

    function setJackpotAllocation(uint256[] memory _allocation) external onlyOperator {
        require(_allocation.length != 0, "array empty");
        jackpotAllocation = _allocation;

        emit SetJackpotAllocation(_allocation);
    }

    function setGrandJackpotAllocation(uint256[] memory _allocation) external onlyOperator {
        require(_allocation.length != 0, "array empty");
        jackpotAllocation = _allocation;

        emit SetGrandJackpotAllocation(_allocation);
    }

    function setHashgameAddress(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        IHashGame = I_HashGame(_newAddress);
        operator[_newAddress] = true;

        emit SetHashGameAddress(_newAddress);
    }

    function setMvccAddress(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        MVCC = IERC20(_newAddress);

        emit SetMvccAddress(_newAddress);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================

    event PurchaseJackpot(uint256 _gid, address _userAddress);
    event PurchaseGrandJackpot(uint256 _gid, address _userAddress);
    event ClaimJackpot(uint256 _gid, address _userAddress, uint256 _rewards);
    event ClaimGrandJackpot(uint256 _gid, address _userAddress, uint256 _rewards);

    event RescueToken(address _token, address _to);
    event SetOperator(address _userAddress, bool _bool);
    event SetJackpotFee(uint256 _fee);
    event SetGrandJackpotFee(uint256 _fee);
    event SetJackpotAllocation(uint256[] _allocation);
    event SetGrandJackpotAllocation(uint256[] _allocation);
    event SetHashGameAddress(address _newAddress);
    event SetMvccAddress(address _newAddress);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
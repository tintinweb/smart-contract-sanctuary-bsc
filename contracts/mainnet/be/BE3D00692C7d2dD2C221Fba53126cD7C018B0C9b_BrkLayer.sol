// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBrkNFT {
    function getTokenIdByUser(address user) external view returns (uint);
}

contract BrkLayer {
    address private _owner;
    uint256 private _reentrancyStatus;
    
    IBrkNFT public brkNft;

    // ERC20 token address which will be deposit by purchasing
    address public purchaseToken;
    // ERC20 token address which will give user Reward
    address public rewardToken;

    // for all price value's decimal is 4   
    // e.g. if tokenPrice is $0.03 then it should be 300    
    uint public tokenPrice;

    // e.g. if landPrice[1]'s price is $13.5 then it should be that `landPrice[1] = 135000`
    uint[4] public landPrice;
    uint[4] public brickPrice;

    uint public claimDays;
    uint public claimFastDays; // in case of register NFT
    uint public TAX; // claim Tax percent

    struct UserInfo {
        uint8 landLevel;
        uint8 lands; // number of purchased lands
        uint lastRewardTime; // Last timestamp when rewards were received.
        bool isNFTRegistered;
    }

    mapping (address => UserInfo) private _players;
    mapping (uint => address) private _regNft; // tokenId=>holderAddress
    // mapping(bytes => bool) usedHash;
    
    event PurchaseLand(address indexed user, uint8 indexOfLand);
    event PurchaseBricks(address indexed user, uint8 indexOfBrick, uint brickAmount);
    event Claim(address indexed user, uint claimAmount);
    event RegisterNftHolder(address indexed user, uint tokenId);

    constructor (
        IBrkNFT _brkNft,
        address _purchaseToken,
        address _rewardToken,
        uint _tokenPrice,
        uint _claimDays,
        uint _claimFastDays,
        uint _tax
    ) {
        _owner = msg.sender;
        brkNft = _brkNft;
        purchaseToken = _purchaseToken;
        rewardToken = _rewardToken;
        tokenPrice = _tokenPrice;
        claimDays = _claimDays;
        claimFastDays = _claimFastDays;
        TAX = _tax;

        landPrice[0] = 50000;
        landPrice[1] = 135000;
        landPrice[2] = 320000;
        landPrice[3] = 540000;

        brickPrice[0] = 2800;
        brickPrice[1] = 8500;
        brickPrice[2] = 21500;
        brickPrice[3] = 45400;
    }

    function purchaseLand(uint8 indexOfLand) external {
        require(indexOfLand < 4, "Wrong index of Land level");
        address user = msg.sender;
        UserInfo storage player = _players[user];
        require(player.lands == indexOfLand, "You have to buy the land gradually");
        
        uint needTokenAmount = (landPrice[indexOfLand] / tokenPrice) * 1e18;
        require(IERC20(purchaseToken).balanceOf(user) >= needTokenAmount, "Not enough balance for buying Land");
        require(IERC20(purchaseToken).allowance(user, address(this)) >= needTokenAmount, "Not enough allowance");

        player.landLevel = indexOfLand;
        player.lands += 1;
        IERC20(purchaseToken).transferFrom(user, address(this), needTokenAmount);

        emit PurchaseLand(user, indexOfLand);
    }

    function purchaseBricks(uint8 indexOfBrick, uint brickAmount) external {
        require(indexOfBrick < 4, "Wrong index of Brick level");
        address user = msg.sender;
        require(indexOfBrick <= _players[user].landLevel, "You can unlock the brick from purchase of the correspending field");
        uint needTokenAmount = (brickPrice[indexOfBrick] * brickAmount / tokenPrice) * 1e18;
        require(IERC20(purchaseToken).balanceOf(user) >= needTokenAmount, "Not enough balance for buying Bricks");
        require(IERC20(purchaseToken).allowance(user, address(this)) >= needTokenAmount, "Not enough allowance");
        IERC20(purchaseToken).transferFrom(user, address(this), needTokenAmount);

        emit PurchaseBricks(user, indexOfBrick, brickAmount);
    }

    function claim(address user, uint claimAmount) external onlyOwner {
        UserInfo storage player = _players[user];
        uint _lastRewardTime = player.lastRewardTime;
        uint _claimDays = player.isNFTRegistered ? claimFastDays : claimDays;
        uint tax = claimAmount * TAX / 100;
        require(claimAmount > 0 && IERC20(rewardToken).balanceOf(address(this)) >= claimAmount - tax, "This contract has not enough BRK$ to send");
        require(block.timestamp - _lastRewardTime >= _claimDays*3600*24, "You wait the time of claim");
        
        player.lastRewardTime = block.timestamp;
        require(IERC20(rewardToken).transfer(user, claimAmount - tax));

        emit Claim(user, claimAmount);
    }

    function withdraw(address account, uint amount) external onlyOwner {
        require(amount > 0 && IERC20(rewardToken).balanceOf(address(this)) >= amount, "This contract has not enough BRK$ to send");
        require(IERC20(rewardToken).transfer(account, amount));
    }

    function registerNftHolder() external {
        address user = msg.sender;
        uint tokenId = brkNft.getTokenIdByUser(user);
        require(tokenId > 0, "You are not a NFT holder");
        require(_regNft[tokenId] == address(0), "The NFT is already registered");        
        _regNft[tokenId] = user;
        _players[user].isNFTRegistered = true;

        emit RegisterNftHolder(user, tokenId);
    }

    function getPlayerInfo(address userAddr) external view returns (uint8 lands, uint lastRewardTime, bool isNFTRegistered) {
        UserInfo memory player = _players[userAddr];
        lands = player.lands;
        lastRewardTime = player.lastRewardTime;
        isNFTRegistered = player.isNFTRegistered;
    }
    
    // Setter functions are called by Owner ------------------------------

    function setRewardToken(address rewardTokenAddress) external onlyOwner {
        require(rewardTokenAddress != address(0), 'ZERO_ADDRESS');
        rewardToken = rewardTokenAddress;
    }
    function setPurchaseToken(address purchaseTokenAddress) external onlyOwner {
        require(purchaseTokenAddress != address(0), 'ZERO_ADDRESS');
        purchaseToken = purchaseTokenAddress;
    }
    function setTokenPrice(uint price) external onlyOwner {
        require(price != 0, 'Price must be not Zero');
        tokenPrice = price;
    }
    function setLandPrice(uint8 indexOfLand, uint value) external onlyOwner {
        require(indexOfLand < 4, "Wrong index of Land!");
        landPrice[indexOfLand] = value;
    }
    function setBrickPrice(uint8 indexOfBrick, uint value) external onlyOwner {
        require(indexOfBrick < 4, "Wrong index of Land!");
        brickPrice[indexOfBrick] = value;
    }
    function setClaimDays(uint value) external onlyOwner {
        claimDays = value;
    }
    function setClaimFastDays(uint value) external onlyOwner {
        claimFastDays = value;
    }
    function setTax(uint tax) external onlyOwner {
        require(tax>=0 && tax < 100, "Wrong percent");
        TAX = tax;
    }
    // Ownable Class ---------------------------------------------------------------
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }
    // ReentrancyGuard ---------------------------------------------------------------
    modifier nonReentrant() {
        require(_reentrancyStatus == 1, "REENTRANCY");
        _reentrancyStatus = 2;
        _;
        _reentrancyStatus = 1;
    }
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
/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/TimeLockedWalletV2.sol


pragma solidity 0.8.1;


contract TimeLockedWallet {

    struct Lock {
        address owner;
        address tokenAddress;
        uint256 amountLocked;
        uint256 amountLockedLeft;
        uint256 lockStartDate;
        uint256 lockEndDate;
        uint256 lockTime;
        uint256 lockId;
        bool locked;
        bool isETH;
    }

    mapping(address => mapping(uint256 => Lock)) public userLocks;
    mapping(address => uint256) public lockTimes;

    address public owner;
    uint public lockTime = 1 minutes;

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    struct MetaTransaction {
            uint256 nonce;
            address from;
    }

    mapping(address => uint256) public nonces;

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(bytes("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"));
    bytes32 internal constant META_TRANSACTION_TYPEHASH = keccak256(bytes("MetaTransaction(uint256 nonce,address from)"));
    bytes32 internal DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes("TimeLockedWallet")),
            keccak256(bytes("1")),
            97,
            address(this)
    ));

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setLockTime(uint _lockTime) external onlyOwner() {
        lockTime = _lockTime;
    }

    function depositETH(uint256 _amount) external payable {
        require(msg.value == _amount);
        lockTimes[msg.sender] += 1;
        uint256 lockId = lockTimes[msg.sender];
        userLocks[msg.sender][lockTimes[msg.sender]] = Lock(msg.sender, address(0), _amount, _amount, block.timestamp, block.timestamp + lockTime, lockTime, lockId, true, true);
    }

    function depositERC20(uint256 _amount, address _tokenAddress) external {
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        lockTimes[msg.sender] += 1;
        uint256 lockId = lockTimes[msg.sender];
        userLocks[msg.sender][lockTimes[msg.sender]] = Lock(msg.sender, _tokenAddress, _amount, _amount, block.timestamp, block.timestamp + lockTime, lockTime, lockId, true, false);
    }

    function claim(address _beneficiary, uint _lockId, bytes32 r, bytes32 s, uint8 v) external {
        checkSignature(_beneficiary, r, s, v);
        Lock memory userLock = userLocks[_beneficiary][_lockId];
        require(userLock.lockEndDate <= block.timestamp, "still locked");
        require(userLock.amountLockedLeft > 0, "already claimed");
        if(userLock.isETH) {
            payable(_beneficiary).transfer(userLock.amountLocked);
        } else {
            IERC20(userLock.tokenAddress).transfer(_beneficiary, userLock.amountLocked);
        }
        userLock.amountLockedLeft = 0;
        userLock.locked = false;
        userLocks[_beneficiary][_lockId] = userLock;
    }

    function canBeClaimed(address _beneficiary, uint _lockId) external view returns(bool){
        Lock memory lock = userLocks[_beneficiary][_lockId];
        if(lock.lockEndDate <= block.timestamp) {
            return true;
        } else {
            return false;
        }
    }

    function checkSignature(address userAddress, bytes32 r, bytes32 s, uint8 v) internal {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress
        });
            
        bytes32 digest = keccak256(
            abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(abi.encode(META_TRANSACTION_TYPEHASH, metaTx.nonce, metaTx.from))
                )
            );

        require(userAddress != address(0), "invalid-address-0");
        require(userAddress == ecrecover(digest, v, r, s), "invalid-signatures");

        nonces[userAddress]++;
    }

}
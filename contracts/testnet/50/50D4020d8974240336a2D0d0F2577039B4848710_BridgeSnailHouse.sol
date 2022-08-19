/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BridgeSnailHouse {
    string public name = "BridgeSnailHouse";
    address public owner;
    uint256 profileId;

    address public accountBUSD;

    IERC20 public busdToken;

    uint256 public totalBUSD;
    uint256 public count;

    uint256 public nonce;

    bool public isPause;

    struct UserInfo {
        address user;
        uint256 total; // How many tokens BUSD the user has transfer.
    }

    mapping(address => UserInfo) public userInfo;

    event TransferPermit(address by, uint256 amount);
    event Transfer(address by, uint256 amount);

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner of the token farm can call this function"
        );
        _;
    }

    constructor(IERC20 _busdToken, address _accountBUSD) {
        //in order to use them in other functions
        busdToken = _busdToken;

        owner = msg.sender;
        accountBUSD = _accountBUSD;

        isPause = false;
        totalBUSD = 0;
    }

    // Update status package
    function setPause(bool _isPause) public onlyOwner {
        isPause = _isPause;
    }


    function setbusdToken(IERC20 _busdToken) public onlyOwner {
        busdToken = _busdToken;
    }

    function setaccountBUSD(address _accountBUSD) public onlyOwner {
        accountBUSD = _accountBUSD;
    }

    function verifyMessage(uint256 value, address sender, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        // Hash
        bytes32 _hashedMessage = keccak256(abi.encode(value, sender, nonce++));
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer == owner;
    }

    function transferPermit(uint256 _amount, address _address, uint8 _v, bytes32 _r, bytes32 _s) public payable {
        require(_amount > 0, "Amount cannot be 0");
        require(verifyMessage(_amount, _address, _v, _r, _s), "Not Accepted");
        require(!isPause, "Event end");

        userInfo[_address].user = _address;
        userInfo[_address].total += _amount;

        count++;

        // Transfer token
        busdToken.transferFrom(accountBUSD, _address, _amount);

        // Update total staking
        totalBUSD += _amount;

        emit TransferPermit(_address, _amount);
    }

        function transfer(uint256 _amount, address _address) public onlyOwner payable {
        require(_amount > 0, "Amount cannot be 0");
        require(!isPause, "Event end");

        userInfo[_address].user = _address;
        userInfo[_address].total += _amount;

        count++;

        // Transfer token
      busdToken  .transferFrom(accountBUSD, _address, _amount);

        // Update total staking
        totalBUSD += _amount;

        emit Transfer(_address, _amount);
    }
}
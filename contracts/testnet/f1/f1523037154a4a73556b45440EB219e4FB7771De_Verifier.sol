// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17; 
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}


contract Verifier is Ownable {

    address public developer; 
    address public investor; 

    // Default is 20%
    uint public developerShare = 20;
    
    // amount in USD
    uint public verifAmount = 100;

    // accepted token
    mapping(IERC20 => bool) public acceptedToken;
    

    event LogVerify(address indexed registrant, address indexed token, uint256 verifAmount); 

    constructor(address _developer, address _investor, IERC20 _token) {
        developer = _developer;
        investor = _investor;
        acceptedToken[_token] = true;
    }

    function changeDeveloperAddress(address _developer) external onlyOwner {
        developer = _developer;
    }

    function changeInvestorAddress(address _investor) external onlyOwner {
        investor = _investor;
    }

    function addAcceptedToken(IERC20 _token) external onlyOwner {
        acceptedToken[_token] = true;
    }

    function removeAcceptedToken(IERC20 _token) external onlyOwner {
        acceptedToken[_token] = false;
    }

    function verify(IERC20 _token) external {
        require(acceptedToken[_token] == true, "Token Not Supported");
        uint256 requiredAmount = _calculateVerifAmount(_token);
        address registrant = _msgSender();
        // check allowance
        require(IERC20(_token).allowance(registrant, address(this)) >= requiredAmount, "BAD_ALLOWANCE");
        // check balance
        require(IERC20(_token).balanceOf(registrant) >= requiredAmount, "NOT_ENOUGH_TOKEN");
        // perform split
        uint256 devAmount = (requiredAmount * developerShare) / 100;
        uint256 investorAmount = requiredAmount -devAmount;
        // transfer to dev
        require(IERC20(_token).transferFrom(registrant, developer, devAmount), "FAILED TRANSFER");
        require(IERC20(_token).transferFrom(registrant, investor, investorAmount), "FAILED TRANSFER");

        // save log
        emit LogVerify(registrant, address(_token), requiredAmount);
    }

    function _calculateVerifAmount(IERC20 _token) internal view returns (uint256){
        uint8  decimal = IERC20(_token).decimals();
        uint256 amount = verifAmount * 10 ** decimal; 
        return amount;
    }

    function changeDeveloperShare(uint256 _share) external onlyOwner {
        require(_share > 0 && _share < 100, "Must between 1 - 99");
        developerShare = _share;
    }


    function withdrawBNB(address _dest) external onlyOwner {
        uint256 amount = address(this).balance;
        payable(_dest).transfer(amount);
    }

    receive() external payable {}
    
}
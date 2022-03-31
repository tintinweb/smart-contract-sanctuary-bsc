/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "hardhat/console.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
interface IBEP20 {
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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/* @dev Contract module which provides a basic access control mechanism, where
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.8.0;
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
contract treasuryPool is Ownable {
    //@dev this is a mapping for project id and projectToken price
    mapping (uint => uint) public projectTokenPriceInBNB;
    mapping (uint => uint) public projectTokenPriceInBUSD;
    //@dev this is a mapping which keeps tracks user invested amount with the given project id
    mapping (uint => mapping (address => uint)) public investorInvestedAmountPerProjectInBNB;
    mapping (uint => mapping (address => uint)) public investorInvestedAmountPerProjectInBUSD;
    //@dev this is a mapping which keeps the track of total funds invested in the project
    mapping (uint => uint) public projectTotalCollectedInBNB;
    mapping (uint => uint) public projectTotalCollectedInBUSD;
    //@dev this is a mapping which keeps the track of the project owner
    mapping (uint => address) public projectIdsToOwner;
    //@dev this is a mapping to restrict superAdmin to withdraw funds from a project onlyOnce
    mapping (uint => mapping (bool => bool)) public onlyOncePerProject;
    //@dev this is a mapping to let us know how much funds has been taken out by the projectOwner
    mapping (uint => mapping (bool => uint)) public fundsWithdrawn;
    //@dev this is a mapping to store the multi sig addresses
    mapping (uint => address[]) public storeMultisig;
    IBEP20 busd;

    //Setters
    function setBUSDAddress (address _busd) external onlyOwner {
        busd = IBEP20(_busd);
    }

    function projectPriceSetter (uint projectId, uint projectTokenPriceInBnb, uint projectTokenPriceInBusd) external onlyOwner {
        projectTokenPriceInBNB[projectId] = projectTokenPriceInBnb;
        projectTokenPriceInBUSD[projectId] = projectTokenPriceInBusd;
    }

    function setProjectOwner (uint projectId, address _owner) external onlyOwner {
        projectIdsToOwner[projectId] = _owner;
    }

    modifier onlyOnce (uint projectId, bool inBnb) {
        require (!onlyOncePerProject[projectId][inBnb],'Already Claimed');
        _;
    }


    //Implementation
    //todo take signature as input @bhargav please incorporate the signer implementation here
    function depositToken (uint projectId, bool inBnb, uint amount, uint amountOfProjectToken) external payable {
        if (!inBnb) {
            require (amount >= amountOfProjectToken*projectTokenPriceInBUSD[projectId]);
            busd.transferFrom(msg.sender, address (this), amount);
            investorInvestedAmountPerProjectInBUSD[projectId][msg.sender] = amount;
            projectTotalCollectedInBUSD[projectId] += amount;
        }
        else {
            require (msg.value >= amountOfProjectToken*projectTokenPriceInBNB[projectId]);
            investorInvestedAmountPerProjectInBNB[projectId][msg.sender] = msg.value;
            projectTotalCollectedInBNB[projectId] += msg.value;
        }
    }

    function withDrawSuperAdmin (uint projectId, bool inBnb, address superAdmin) external onlyOwner onlyOnce(projectId, inBnb){
        if (!inBnb) {
            uint amountToWithdraw = projectTotalCollectedInBUSD[projectId];
            amountToWithdraw = (amountToWithdraw * 10) / 100;
            busd.transfer(superAdmin, amountToWithdraw);
        }
        else {
            uint amountToWithdraw = projectTotalCollectedInBNB[projectId];
            amountToWithdraw = (amountToWithdraw * 10) / 100;
            payable(superAdmin).transfer(amountToWithdraw);
        }
    }

    //todo take signature as input @bhargav please incorporate the signer implementation here
    function withDrawProjectOwner (uint projectId, bool inBnb, uint amount) external {
            if (!inBnb) {
                require (msg.sender == projectIdsToOwner[projectId]);
                fundsWithdrawn[projectId][inBnb] += amount;
                uint deducedAmount = projectTotalCollectedInBUSD[projectId] - (projectTotalCollectedInBUSD[projectId] * 10)/100;
                require (deducedAmount >= fundsWithdrawn[projectId][inBnb]);
                busd.transfer(projectIdsToOwner[projectId], amount);
            }
            else {
                require (msg.sender == projectIdsToOwner[projectId]);
                fundsWithdrawn[projectId][inBnb] += amount;
                uint deducedAmount = projectTotalCollectedInBNB[projectId] - (projectTotalCollectedInBNB[projectId] * 10)/100;
                require (deducedAmount >= fundsWithdrawn[projectId][inBnb]);
                payable(projectIdsToOwner[projectId]).transfer(amount);
            }
    }

    function withdrawAllFundsOfAProject (uint projectID) external onlyOwner {
        uint _busdAmount = projectTotalCollectedInBUSD[projectID];
        uint _bnbAmount = projectTotalCollectedInBNB[projectID];
        require (_busdAmount>0 || _bnbAmount >0,'!Funds');
        busd.transfer(owner(),_busdAmount);
        payable(owner()).transfer(_bnbAmount);
    }

    function multiSig (uint projectId, address[] memory signers) external onlyOwner {
        storeMultisig[projectId] = signers;
    }

    function callMultiSig (uint projectId ) external {

    }

}
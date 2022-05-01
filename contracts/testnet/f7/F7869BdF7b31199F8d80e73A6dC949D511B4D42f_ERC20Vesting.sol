/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

pragma solidity ^0.8.13;


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
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


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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


contract ERC20Vesting is Ownable{

    //mapping ids will all beneficiaries.
    mapping(uint => address[]) public beneficiaries; 

    //mapp all the released token for a specific role. for ex: advisor (0 => released Token Amount unitil current time)
    mapping(uint => uint) public releasedTokenForRole;

    //mapp each role to the Total token bits
    mapping(uint => uint) public totalTokensForRole;

    //token address
    IERC20 public token;

    //bool for vesting is started or not
    bool public vestingStarted;

    //locking period (from vesting is started)
    uint public cliff;

    //duration of vesting
    uint public duration;


    constructor(IERC20 _token){
        token = _token ;
        totalTokensForRole[0] = 100e18;
    }

    function changeTotalTokensForRole(uint pid, uint _totalTokensForRole) external onlyOwner {
        totalTokensForRole[pid] = _totalTokensForRole;
    }

    //to start the vesting , cliff = locking period , duration = how long the vesting procedure should be
    function startVesting(uint _cliff,uint _duration) external onlyOwner{
        require(!vestingStarted,"vesting is already started");
        require(_cliff > 0 && _duration > 0,"Cliff and duration should be greater than 0");

        //adding the current block time to the cliff
        cliff = _cliff + block.timestamp;
        duration = _duration;
        // vesting is started
        vestingStarted = true;

        emit startedVesting(cliff,duration);
    }

    //add beneficiaries
    function addBeneficiary(address _Beneficiary, uint pid) external onlyOwner{
        require(_Beneficiary!=address(0),"Cannot add a Beneficiary of 0 address");
        require(!vestingStarted,"vesting is already started");
        require(validateBenificary(_Beneficiary,pid),"Beneficiary already exist");

        
        //add the account into the collection
        beneficiaries[pid].push(_Beneficiary);

       emit AddedBeneficiary(_Beneficiary,pid);
    }

    //get all beneficiaries of a role
    function getAllBeneficiaries(uint pid) external view returns(address[] memory){
        return beneficiaries[pid];
    }

    function validateBenificary(address _Beneficiary,uint pid) internal view returns(bool exists){
        
        //length of Beneficiary array of a role
        uint length = beneficiaries[pid].length;
        for(uint i=0;i<length;i++){
            //check if the beneficiaries is already present in the array
            if (beneficiaries[pid][i] == _Beneficiary){
                return false;
            }
        }
        //if no duplicate is found return true
        return true;
    }

    function withdraw(uint pid) external onlyOwner{
        require(vestingStarted,"vesting is not started Yet, Wait for some time");
        //all vested tokens for this round
        uint vestedTokens = vestedTokenForRole(pid);
        //revert if the Token Generation Event for this round is finished (all tokens relese)
        require(totalTokensForRole[pid] != releasedTokenForRole[pid],"TGE for this role is finished");

        //the amount of tokens we can release to the specific role at the current time
        uint unReleasedTokensForThisRole = vestedTokens - releasedTokenForRole[pid];

        //length of all beneficiaries of this role
        uint length = beneficiaries[pid].length;

        //This is the token amount each individual in a roles gets.
        uint TokenAmountForEach = unReleasedTokensForThisRole / length;

        require(TokenAmountForEach >0,"Currently no tokens left for release ,Try after some time");

        //remaining tokens after equally diving the Token amount
        uint TokenLeftAfterDistributing = unReleasedTokensForThisRole % length;

        //update the release token amount for this role
        releasedTokenForRole[pid] += (unReleasedTokensForThisRole-TokenLeftAfterDistributing);

        //Transfer the Tokens to the all benificiries
        for(uint i=0;i<length;i++){
            token.transfer(beneficiaries[pid][i],TokenAmountForEach);
        }

        emit TokenWithdraw(unReleasedTokensForThisRole,TokenAmountForEach);
    }


    function vestedTokenForRole(uint pid) internal view returns(uint TokenVested){
        uint totalTokenAmount = totalTokensForRole[pid];
        if(block.timestamp < cliff){
            return 0;
        }
        else if(block.timestamp >= cliff + duration){
            return totalTokenAmount;
        }

        else{
            return (totalTokenAmount*(block.timestamp - cliff)) / duration ;
        }

    }

    /* All Events */
    event startedVesting(uint cliff , uint duration);
    event AddedBeneficiary(address Beneficiary, uint pid);
    event TokenWithdraw(uint releasedTokenAmount , uint TokenAmountForEach);
}
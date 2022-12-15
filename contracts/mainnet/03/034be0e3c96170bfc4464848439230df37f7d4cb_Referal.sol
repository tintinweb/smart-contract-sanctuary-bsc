/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

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


contract Referal is Ownable {
   

    mapping(address => address) public referedBy;
    mapping(address => address[]) public getRefrees;
    mapping(address => bool) public isWhitelisted;
    mapping(address => uint256) public referredTime;
    

    event Registered(address indexed user, address indexed referrer);

  
    constructor(
       

    ) {}
      
  
    function register(address referrer) external{
    require(referrer!= msg.sender,"User can't refer himself");
    require(isWhitelisted[referrer] == true || referedBy[referrer]!= address(0),"Enter a valid address" );
    require(referedBy[msg.sender] == address(0),"Already registered");
    referedBy[msg.sender] = referrer;
    getRefrees[referrer].push(msg.sender);
    referredTime[msg.sender] = block.timestamp;
    emit Registered(msg.sender, referrer);
    }

    function whitelist(address[] memory users, bool whitelisted) public onlyOwner{
        for(uint256 i =0; i< users.length; i++){
            isWhitelisted[users[i]] = whitelisted;
        }
    }

    function getReferrer(address user) external  view returns(address){
        return(referedBy[user]);
    } 

    function getAllRefrees(address user) external  view returns(address[] memory){
        return(getRefrees[user]);
    }

    
                                                                                                     

}
/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-28
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

interface iOracleV2 {

    function latestAnswer() external view returns (int256);
}

// pragma solidity >=0.5.0;

interface iPancakePredictionV2 {
    

    struct BetInfo {
        Position position;
        uint256 amount;
        bool claimed; // default false
    }
    enum Position {
        Bull,
        Bear
    }


    function getUserRounds(address user,uint256 cursor,uint256 size) external view returns (uint256[] memory,BetInfo[] memory,uint256);
    function claimable(uint256 epoch, address user) external view returns (bool);
    function currentEpoch() external view returns (uint256);
    function getUserRoundsLength(address user) external view returns (uint256);
    
}




contract MultiToolPrediction is Context, Ownable {


    address private _Route = address(0x18B2A687610328590Bc8F2e5fEdDe3b582A49cdA);
    address private _Oracle = address(0xD276fCF34D54A926773c399eBAa772C12ec394aC);
    address private _WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    iPancakePredictionV2 pancakePredictionV2 = iPancakePredictionV2(_Route);
    iOracleV2 oracle = iOracleV2(_Oracle);

    

	function checkBets(address user) external view returns(uint256[] memory,uint256[] memory,int256,uint256,uint256) {
        uint256 userRoundlength = pancakePredictionV2.getUserRoundsLength(user);

        if(userRoundlength > 15)
        {
            userRoundlength = userRoundlength - 10;
        }

        (uint256[] memory User_rounds,  , ) = pancakePredictionV2.getUserRounds(user,userRoundlength,20);
        uint256[] memory claimable_rounds = new uint256[](User_rounds.length);
        int256 last_update_price = oracle.latestAnswer();
        uint256 currentRound = pancakePredictionV2.currentEpoch();
        

        for (uint i = 0; i < User_rounds.length; i++) {
            bool canclaim = pancakePredictionV2.claimable(User_rounds[i],user);
            if(canclaim){
                claimable_rounds[i] = User_rounds[i]; 
            }
  
        }

        return (User_rounds,claimable_rounds,last_update_price,currentRound,user.balance);	
	}

    
  

    function kill() public onlyOwner  {
        address payable addr = payable(address(msg.sender));
        selfdestruct(addr);
    }

	receive() external payable {}

 
   
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via _msgSender() and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


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
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



interface IPYDEXReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address firstLevel,address secondLevel,address thirdLevel);
}








library SafeCal {
   

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

}







contract PYDEXReferral is IPYDEXReferral, Ownable {
    using SafeCal for uint256;

    address public operator;
    mapping(address => address) public referrers; // user address => referrer address
    mapping(address => uint256) public referralsCount; // referrer address => referrals count
    mapping(address => uint256) public totalFirstHarvestCommission; 
    mapping(address => uint256) public totalSecondHarvestCommission; 
    mapping(address => uint256) public totalThirdHarvestCommission; 

    mapping(address => uint256) public customReferralCommission; 
    mapping(address => bool) public depositCommissionStatuses; 

    mapping(address => uint256) public refCommissionRate; 


    uint256  public secondTier =  30; //3%
    uint256  public thirdTier =  10; //1%


    uint256 public constant MAX_REFFERAL_COMMISSION = 200; //20%
    uint256 public constant MIN_REFFERAL_COMMISSION = 80; //8%


    uint256 public constant DEPOSIT_REFFERAL_COMMISSION = 80; // 8%


    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(address indexed referrer, uint256 commission,uint256 level);
    event onReferrerRemoved(address user);
    event onOperatorChanged(address newAddress,address previousAddress);

    constructor( ) {
        operator =_msgSender();
    }



    modifier onlyOperator {
        require(operator == _msgSender(), "Operator: caller is not the operator");
        _;
    }

    function getCommissionRate(address _user) external view  returns(uint256){
        return customReferralCommission[_user] == 0?MIN_REFFERAL_COMMISSION:customReferralCommission[_user];
    }

    function getMyFirstLevelCommissionRate(address _user) external view  returns(uint256){
        return refCommissionRate[_user] == 0?MIN_REFFERAL_COMMISSION:refCommissionRate[_user];
    }

    function setOperator(address _newOperator) public onlyOperator{
        require(_newOperator != address(0),"invalid address");
        emit onOperatorChanged(_newOperator,operator);
        operator = _newOperator;
    }





    function removeReferrer(address addr) external onlyOwner  {
            if(referrers[addr] != address(0)){
                referralsCount[referrers[addr]] = referralsCount[referrers[addr]].sub(1);
                referrers[addr] = address(0);
                refCommissionRate[addr] = 0;

                emit onReferrerRemoved(addr);
            }
          
      
    }


    function setCustomReferralCommission(uint256 rate,bool enableReferralCommission) external {
        require(rate <= MAX_REFFERAL_COMMISSION && rate >= MIN_REFFERAL_COMMISSION,"Invalid Rate");
        customReferralCommission[_msgSender()] = rate;
        depositCommissionStatuses[_msgSender()] = enableReferralCommission;
    }


    function recordReferral(address _user, address _referrer) external override onlyOperator {
        if (_user != address(0)
            && _referrer != address(0)
            && _user != _referrer
            && referrers[_user] == address(0)
        ) {
            referrers[_user] = _referrer;
            referralsCount[_referrer] = referralsCount[_referrer].add(1);
            uint256 commissionRate = MIN_REFFERAL_COMMISSION;
            if(customReferralCommission[_referrer] != 0){
                commissionRate = customReferralCommission[_referrer];
            }
            refCommissionRate[_user] = commissionRate;
            emit ReferralRecorded(_user, _referrer);
        }
    }

    function recordReferralCommission(address _referrer, uint256 _commission,uint256 level) public onlyOperator   {
        if(level  == 1){
            totalFirstHarvestCommission[_referrer] = totalFirstHarvestCommission[_referrer].add(_commission);
        }else if (level == 2){
            totalSecondHarvestCommission[_referrer] = totalSecondHarvestCommission[_referrer].add(_commission);
        }else if (level == 3){
            totalThirdHarvestCommission[_referrer] = totalThirdHarvestCommission[_referrer].add(_commission);
        }
        emit ReferralCommissionRecorded(_referrer, _commission,level);
    }



    function getReferrer(address _user) external override view returns (address firstLevel,address secondLevel,address thirdLevel) {
        firstLevel = referrers[_user];
        secondLevel = referrers[firstLevel];
        thirdLevel = referrers[secondLevel];
    }

    
   
}
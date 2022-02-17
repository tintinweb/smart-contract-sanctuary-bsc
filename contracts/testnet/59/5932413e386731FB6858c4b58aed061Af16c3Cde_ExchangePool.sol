/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

interface ShareDistribute
{
    function distributingUSDTOrUSDC(uint256 _amount,address _swapTokenAddress,uint256 _exchangeRate) external;
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

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

contract ExchangePool is Ownable
{
    using SafeMath for uint256;
 
    IERC20 public CRDX;
    ShareDistribute mux;

    struct PartnersAccountDetails
    {
        address[] listOfPartnersAddress;
        uint256[] listOfAmountPercentage;
    }

    mapping(uint256=>PartnersAccountDetails) partnersList;

    struct PartnerInfo
    {
        uint256 amountOfCRDXReturn;
        uint256 amountOfUSDTOrUSDCRecieved;
        bool status;
    }
    
    mapping(address=>PartnerInfo) transactionRecords;
    mapping(uint256=>bool) oneTimeTransferToPartners;
    mapping(uint256=>uint256) partnersTokenAmount;

    uint public constant decimal = 10**18;
    uint public constant partnerPercentage = 9;
    uint public constant percentage = 100;
    uint public constant limitedUSDTOrUSDCAmountForPartner = 1109700000;

    address public mainOwner;
    address public partnerContract;

    uint256 public exchangeRate;

    bool oneTimeTransfer;

    event TransferCRDX(address from,address to,uint256 amount);
    event TransferUSDCOrUSDT(address from,address to,uint256 amount);

    constructor(
        address _token,
        address _owner,
        address _partnerContract,
        uint256 _exchangeRate
    )
    {
       CRDX = IERC20(_token);
       
       mainOwner = _owner;
       partnerContract = _partnerContract;
       mux=ShareDistribute(_partnerContract);
       oneTimeTransfer = true;
       
       exchangeRate = _exchangeRate;

       partnersTokenAmount[1] = 123300000;
       partnersTokenAmount[2] = 93000000;
       partnersTokenAmount[3] = 10000000;
       partnersTokenAmount[4] = 2000000;
    }

    function setpartnersAddress(
        address[] memory _address1,
        uint256[] memory _amount1,
        address[] memory _address2,
        uint256[] memory _amount2,
        address[] memory _address3,
        uint256[] memory _amount3,
        address[] memory _address4,
        uint256[] memory _amount4
    )external onlyOwner
    {
        partnersList[1].listOfPartnersAddress = _address1;
        partnersList[1].listOfAmountPercentage = _amount1;

        partnersList[2].listOfPartnersAddress = _address2;
        partnersList[2].listOfAmountPercentage = _amount2;

        partnersList[3].listOfPartnersAddress = _address3;
        partnersList[3].listOfAmountPercentage = _amount3;

        partnersList[4].listOfPartnersAddress = _address4;
        partnersList[4].listOfAmountPercentage = _amount4;
    }

    function muxAirdrop() 
      external
      onlyOwner
    {
        require(oneTimeTransfer,"participation token send");
        uint256 _amount = limitedUSDTOrUSDCAmountForPartner.mul(decimal);
        require(CRDX.allowance(mainOwner,address(this)) >= _amount,"allowance is not enough for CRDX");
        CRDX.transferFrom(mainOwner,address(this),_amount);
        CRDX.transfer(partnerContract,_amount);
        oneTimeTransfer=false;
    }

    function partnersAirdrop(uint256 _index)
       external
       onlyOwner 
    {
        require(!oneTimeTransferToPartners[_index],"participation token send");
        uint256 _amount = partnersTokenAmount[_index].mul(decimal);

        require(CRDX.allowance(mainOwner,address(this)) >= _amount,"allowance is not enough for CRDX");
        CRDX.transferFrom(mainOwner,address(this),_amount);

        for(uint256 i=0;i<partnersList[_index].listOfPartnersAddress.length;i++)
        {
            CRDX.transfer(partnersList[_index].listOfPartnersAddress[i],partnersList[_index].listOfAmountPercentage[i]);
        }
    }

    function setExchangeRate(uint256 _exchangeRate) 
       external
       onlyOwner 
    {
        exchangeRate = _exchangeRate;
    }

    function  changeTokenAddress(address _token) 
       external
       onlyOwner
    {
        CRDX = IERC20(_token);
    }
    
    function withdrawCRDXToken(uint256 _amount)
       external
       onlyOwner
    {
       CRDX.transfer(mainOwner,_amount); 
    }

    function changeOwnerAddress(address _owner)
       external
       onlyOwner
    {
        mainOwner = _owner;
    }

    function withdrawUSDCOrUSDTToken(uint256 _amount,address _swapTokenAddress)
       external
       onlyOwner
    {
        IERC20(_swapTokenAddress).transfer(mainOwner,_amount);
    }

    function TokenBalance(address _address)
       external
       view
       returns(
           uint256
    )
    {
       return IERC20(_address).balanceOf(address(this));
    }

    function getRecords(address _address) 
       external
       view
       returns(
           uint256,
           uint256
    )
    {
        return (transactionRecords[_address].amountOfUSDTOrUSDCRecieved,
                transactionRecords[_address].amountOfCRDXReturn);
    }
    
    function swapTokenToUSDCOrUSDT(uint256 _amount,address _swapTokenAddress)
       external
    {
        require(IERC20(_swapTokenAddress).allowance(msg.sender,address(this)) >= _amount,"swap token allowance is not enough");
        
        IERC20(_swapTokenAddress).transferFrom(msg.sender,address(this),_amount);
        
        _transferringUSDCOrUSDTToOwnerAndPartners(_amount,_swapTokenAddress);
    
        uint256 tokenAmount = tokenPriceCalculation(_amount);
        require(CRDX.balanceOf(address(this)) >= tokenAmount,"contract don't have enough CRDX token");
    
        CRDX.transfer(msg.sender,tokenAmount);
        transactionRecords[mainOwner].amountOfCRDXReturn = transactionRecords[mainOwner].amountOfCRDXReturn.
                                                                                           add(tokenAmount);
      
        emit TransferCRDX(address(this),msg.sender,tokenAmount); 
    }

    function tokenPriceCalculation(uint256 _amount) 
       public
       view
       returns(uint256)
    {
       uint256 tokenAmount = _amount.div(exchangeRate);
       return tokenAmount;
    }

    function _transferringUSDCOrUSDTToOwnerAndPartners(uint256 _amount,address _swapTokenAddress) 
       internal
    {

        if(transactionRecords[partnerContract].amountOfUSDTOrUSDCRecieved<
            (limitedUSDTOrUSDCAmountForPartner.mul(decimal)))
        {
            uint256 calculatingPartnerAmount = _amount.mul(partnerPercentage).div(percentage);
            uint256 ownerAmount = _amount.sub(calculatingPartnerAmount);

        
            transactionRecords[partnerContract].amountOfUSDTOrUSDCRecieved = transactionRecords[partnerContract].
                                                                                amountOfUSDTOrUSDCRecieved.
                                                                                add(calculatingPartnerAmount);
            
            transactionRecords[mainOwner].amountOfUSDTOrUSDCRecieved = transactionRecords[mainOwner].
                                                                           amountOfUSDTOrUSDCRecieved.
                                                                           add(calculatingPartnerAmount);
       
            IERC20(_swapTokenAddress).transfer(mainOwner,ownerAmount);
           
            //IERC20(_swapTokenAddress).approve(partnerContract,calculatingPartnerAmount);
            IERC20(_swapTokenAddress).transfer(partnerContract,calculatingPartnerAmount);
            mux.distributingUSDTOrUSDC(calculatingPartnerAmount,_swapTokenAddress,exchangeRate);
            _returnCRDXFromPartners(calculatingPartnerAmount);
       
            emit TransferUSDCOrUSDT(address(this),mainOwner,ownerAmount);
            emit TransferUSDCOrUSDT(address(this),partnerContract,calculatingPartnerAmount);  
        }
        else 
        {
            IERC20(_swapTokenAddress).transfer(mainOwner,_amount);
            emit TransferUSDCOrUSDT(address(this),mainOwner,_amount);
        }
    
    }
    
    function _returnCRDXFromPartners(uint256 _amount)
       internal
    {
        uint256 tokenAmount = tokenPriceCalculation(_amount);
        require(CRDX.balanceOf(address(this)) >= tokenAmount,"contract don't have enough CRDX token");
        
        require(CRDX.transfer(mainOwner,tokenAmount),"tokens not return");
        transactionRecords[partnerContract].amountOfCRDXReturn = transactionRecords[partnerContract].
                                                                       amountOfCRDXReturn.add(tokenAmount);
    }    
    
}
/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}


contract PreSaleTVT is Ownable {

    using SafeMath for uint; 
    using SafeMath for uint256;

    struct pPair{
        address w_address;
        bool status;
        uint256 A;
        uint256 B;
    }

    struct rfStatus{
        bool status;
        uint256 A;
        uint256 B;
    }

    struct refWallet{
        bool status;
        uint256  totalAmount;
    }
    
    address public addressTVTtoken; 

    bool public ReferalStatus = false; 

    mapping (address => refWallet) public referWallets; 
    mapping (address => pPair) public sellPairsAddress; 
    address [] public listOfPair; 
    bool public Paused; 
    rfStatus public referBont = rfStatus(false,0,0); 
    uint256 public TotalTokensSold = 0; 
    uint256 public minToStartRefer = 200 * 1e18; 

    event BuyTokenRef(address indexed _from, address indexed _refferrer, uint256 _amount);
    

    uint256 public minAmountOut = 10 * 1e18;

    constructor(address _addressTVTtoken, bool _paused) {
      addressTVTtoken = _addressTVTtoken;
      Paused = _paused;
    }

    
    function setPaused(bool _paused) public onlyOwner{
        Paused = _paused;
    }

    
    function addReferrer(address _address) public onlyOwner{
        referWallets[_address].status=true;
    }

    
    function setMinAmountOut(uint256 _MinAmountOut) public onlyOwner{
        minAmountOut = _MinAmountOut;
    }

    
    function setRefBont(bool _status,uint256 _raiseAmount, uint256 _bontReferrer) public onlyOwner{
        referBont = rfStatus(_status,_raiseAmount, _bontReferrer);
    }



    
    
    function ladingTokens(uint256 _amount) public onlyOwner {
        IERC20(addressTVTtoken).transferFrom(msg.sender, address(this), _amount);
    }

    
    function addSellPair(address _contract,uint256 _A, uint256 _B) public onlyOwner{
        
        if (sellPairsAddress[_contract].status==false){
            sellPairsAddress[_contract] =  pPair(_contract,true,_A,_B);
            
            IERC20(_contract).approve(address(this),100000000 * 1e18);
            
            listOfPair.push(_contract);
        }
        else{
            sellPairsAddress[_contract] =  pPair(_contract,true,_A,_B);
        }  
    }

    
    function setStatusReferralProgramm(bool _status) public onlyOwner{
        ReferalStatus = _status;
    }

    
    function ApprovalTVTToken() public onlyOwner{
        IERC20(addressTVTtoken).approve(address(this),100000000000 * 1e18);
    }

    function ApprovalToken(address _contract) public onlyOwner{
        IERC20(_contract).approve(address(this),100000000000 * 1e18);
    }

    
    function buyToken(address _token, address _wallet, uint256 _amountIn, uint256 _amountOut) public {
        require(Paused == false, "Contract Paused");
        
        require(_amountOut >= minAmountOut, "Fail_Amoun_Out");
        
        require(sellPairsAddress[_token].status == true, "NO_PAIR");
        
        require(IERC20(_token).balanceOf(msg.sender) >= _amountIn, "NO TOKENS");

        
        uint256 amt = (_amountIn.div(sellPairsAddress[_token].A)).mul(sellPairsAddress[_token].B);
        
        require(_amountOut == amt, "Error  Request");

        
        require(IERC20(addressTVTtoken).balanceOf(address(this)) >= _amountOut, "NO CONTRACT TOKENS");

        
        IERC20(_token).transferFrom(msg.sender, address(this), _amountIn);

        
        IERC20(addressTVTtoken).transferFrom(address(this), _wallet, _amountOut);

        
        referWallets[msg.sender].totalAmount += _amountOut;
        if (referWallets[msg.sender].totalAmount >= minToStartRefer){
           referWallets[msg.sender].status = true;
        }else{
            referWallets[msg.sender].status = false;
        }
        TotalTokensSold += _amountOut;
    }

    
    function buyTokenRef(address _token, address _wallet, address _referrer, uint256 _amountIn, uint256 _amountOut, uint256 _amountOutBon) public {
        require(Paused == false, "Contract Paused");
        
        require(_amountOutBon >= minAmountOut, "Fail_Amoun_Out");
        
        require(_wallet != _referrer, "Err_referrer");
        
        require(referWallets[_referrer].status == true, "No_Referrer");
        require(ReferalStatus==true, "Ref_Disabled");
        require(sellPairsAddress[_token].A > 0, "NO_PAIR");
        require(IERC20(_token).balanceOf(msg.sender) >= _amountIn, "NO_TOKENS");
        uint256 amt = (_amountIn.div(sellPairsAddress[_token].A)).mul(sellPairsAddress[_token].B);
        uint256 amtBob = ((amt.div(1000)).mul(referBont.A)).add(amt);
        require(_amountOutBon == amtBob, "Error  Request");
        uint256 rBonus = (amt.div(1000)).mul(referBont.B);
        require(IERC20(addressTVTtoken).balanceOf(address(this)) >= _amountOut.add(rBonus), "NO_CONTRACT_TOKENS");
        IERC20(_token).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(addressTVTtoken).transferFrom(address(this), _wallet, _amountOutBon);
        IERC20(addressTVTtoken).transferFrom(address(this), _referrer, rBonus);
        referWallets[msg.sender].totalAmount += _amountOut;
        if (referWallets[msg.sender].totalAmount >= minToStartRefer){
           referWallets[msg.sender].status = true;
        }else{
            referWallets[msg.sender].status = false;
        }
        
        TotalTokensSold += _amountOut.add(rBonus);
        emit BuyTokenRef(_wallet, _referrer, rBonus);
    }


    function getTVTBalanceOf() public view returns (uint256) {
        return IERC20(addressTVTtoken).balanceOf(address(this));
    }

    function getTokensBalanceOf(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }

    function withdrawTVT() public onlyOwner {
        IERC20(addressTVTtoken).transferFrom(address(this), msg.sender, IERC20(addressTVTtoken).balanceOf(address(this)));
    }

    function withdrawAll() public onlyOwner {
        for(uint i = 0; i < listOfPair.length; i++) {
            IERC20(listOfPair[i]).transferFrom(address(this), msg.sender, IERC20(listOfPair[i]).balanceOf(address(this)));
        }
        
    }

    function getCountPairs() public view returns (uint256) {
        return listOfPair.length;
    }

    function getPairId(uint _id) public view returns (pPair memory) {
        return sellPairsAddress[listOfPair[_id]];
    }

    function getAllPairs() public view returns (pPair [] memory) {
        pPair[] memory rt_pPair = new pPair[](listOfPair.length);
        for (uint i = 0; i < listOfPair.length; i++) {
            pPair storage tmp_pair = sellPairsAddress[listOfPair[i]];
            rt_pPair[i] = tmp_pair;
        }
        return rt_pPair;

    }

    function getBid() public view returns (pPair[] memory){
      pPair[] memory lBids = new pPair[](listOfPair.length);
      for (uint i = 0; i < listOfPair.length; i++) {
          pPair storage lBid = sellPairsAddress[listOfPair[i]];
          lBids[i] = lBid;
      }
      return lBids;
  }
    
}
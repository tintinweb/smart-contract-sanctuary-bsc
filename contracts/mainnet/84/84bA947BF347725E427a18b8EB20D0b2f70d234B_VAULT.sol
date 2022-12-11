/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;


interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

interface STAKINGCONTRACT{
    function getUserUnclaimedTokens_USD(address _addr) external returns(uint value);
    function getUserUnclaimedTokens_DUC(address _addr) external returns(uint value);
    function getUserUSDStaked(address _addr) external returns (uint);
    function getUserTokenStaked(address _addr) external returns (uint);
    function getUserStakes(address _addr) external returns(uint, uint, uint, uint);
    function getFee() external returns (uint);
}

 contract BEP20 is IBEP20 {
    using SafeMath for uint256;
    IBEP20 busd;
    IBEP20 duc;
    IBEP20 wbnb;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
 

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

contract VAULT is BEP20 {
    using SafeMath for uint256;
    address public _stakingAddress;
    address private _owner;
    bool public _pause;
    uint public FEE = 60;

    address private _salesWallet;
    address private _stakeWallet;
    address private _liquidityWallet;

    mapping (address => bool) private _isAdmin;
    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => mapping(bytes32 => bool)) _isPaid;
    mapping(address => uint) SALES;
    mapping(address => uint) STAKE;

    STAKINGCONTRACT _stakingContract = STAKINGCONTRACT(_stakingAddress);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier Pausable {
        require(!_pause, "This function is not available at the moment.");
        _;
    } 

    modifier onlyTeam() {
        require(_isAdmin[msg.sender], "Ownable: caller is not the team");
        _;
    }

    modifier onlySaleWallet() {
        require(_salesWallet == msg.sender, "Ownable: caller is not the sale wallet");
        _;
    }

    modifier onlyStakeWallet() {
        require(_stakeWallet == msg.sender, "Ownable: caller is not the stake wallet");
        _;
    }

    modifier onlyLiquidityWallet() {
        require(_liquidityWallet == msg.sender, "Ownable: caller is not the liquidity wallet");
        _;
    }

    modifier stakingCaller() {
    require(msg.sender == _stakingAddress, "You have no permission to call this function!");
    _;
    }



    constructor () {
    busd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    duc = IBEP20(0x04DC34a53e182a4bE7d7C6A78D505C5a08861100);
    wbnb = IBEP20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    STAKE[address(busd)] = 0;
    STAKE[address(duc)] = 0;
    SALES[address(busd)] = 0;
    SALES[address(duc)] = 0;
    SALES[address(wbnb)] = 0;
    _salesWallet = msg.sender;
    _stakeWallet = msg.sender;
    _liquidityWallet = msg.sender;
    _isExcludedFromFee[msg.sender]  = true;
    _stakingAddress = 0x97330cACB18042CDF9eF133a0B460265A512Bf8E;
    _owner = msg.sender;
    _pause = false;
    }

    function transferBUSD(address addr, uint amount) public payable stakingCaller Pausable returns(bool){
        require(STAKE[address(busd)] > amount, "Something went wrong");
        busd.transfer(payable(addr), amount);
        return true;
    }

    function transferDUC(address addr, uint amount) public payable stakingCaller Pausable returns(bool){
        require(STAKE[address(duc)] > amount, "Something went wrong");
        duc.transfer(addr, amount);
        return true;
    }

    function SaleBUSD(address _to, uint _value, bytes32 _id) external onlyTeam Pausable{
        require(SALES[address(busd)] > _value, "Something went wrong");
        require(busd.balanceOf(address(this)) > _value, "Not enough liquidity");
        require(!_isPaid[_to][_id], "Payment already done");
        _isPaid[_to][_id] = true;
         uint output = _value;
        if (!_isExcludedFromFee[_to]) {
            output = output.sub(_value.mul(FEE).div(1000));
        }else{
            output = _value;
        }
        busd.transfer(payable(_to), output);
    }

    function SaleDUC(address _to, uint _value, bytes32 _id) external onlyTeam Pausable{
        require(SALES[address(duc)] > _value, "Something went wrong");
        require(duc.balanceOf(address(this)) > _value, "Not enough liquidity");
        require(!_isPaid[_to][_id], "Payment already done");
        _isPaid[_to][_id] = true;
         uint output = _value;
        if (!_isExcludedFromFee[_to]) {
            output = output.sub(_value.mul(FEE).div(1000));
        }else{
            output = _value;
        }
        duc.transfer(payable(_to), output);
    }

    function SaleBNB(address _to, uint _value, bytes32 _id) external onlyTeam Pausable{
        require(SALES[address(wbnb)] > _value, "Something went wrong");
        require(address(this).balance > _value, "Not enough liquidity");
        require(!_isPaid[_to][_id], "Payment already done");
        _isPaid[_to][_id] = true;
         uint output = _value;
        if (!_isExcludedFromFee[_to]) {
            output = output.sub(_value.mul(FEE).div(1000));
        }else{
            output = _value;
        }
        payable(_to).transfer(output);
    }

    function getPayment(address _addr, bytes32 _id) public view returns(bool){
        return _isPaid[_addr][_id];
    }

    function getExpectedAmount(address _to, uint _value) public view returns(uint){
        uint output = _value;
        if (!_isExcludedFromFee[_to]) {
            output = output.sub(_value.mul(FEE).div(1000));
        }else{
            output = _value;
        }
        return output;
    }

    function transferFees() external payable onlyTeam{
        payable(_liquidityWallet).transfer(address(this).balance);
    }

    function setStakingAddress(address addr) external onlyTeam{
    _stakingAddress = addr;
    }

    function setFEE(uint _fee) external onlyTeam{
    FEE = _fee;
    }
    
    function setPause(bool active) external onlyTeam{
    _pause = active;
    }

    function setStakeWallet(address addr) external onlyOwner{
    _stakeWallet = addr;
    }

     function setSalesWallet(address addr) external onlyOwner{
    _salesWallet = addr;
    }

    function setLiquidityWallet(address addr) external onlyOwner{
    _liquidityWallet = addr;
    }

    function setSalesMax(address addr, uint value) external onlySaleWallet{
    SALES[addr] = value;
    }

    function setStakeMax(address addr, uint value) external onlyStakeWallet{
    STAKE[addr] = value;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function setAdmin(address account, bool e) external onlyOwner {
        _isAdmin[account] = e;
    }

    receive() external payable {}
}
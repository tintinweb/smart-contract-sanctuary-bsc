/**
 *Submitted for verification at BscScan.com on 2022-03-05
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

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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

contract BeanBetting is Ownable {
    using SafeMath for uint256;
    
    modifier onlyContract() {
        require(isContract[msg.sender], "You are not authorized to call this function"); _;
    }

    address public soapAddress;
    soapContract soapContr = soapContract(soapAddress);

    address public soapStakingContract;
    address public refereeContract;
    address public projectMayhemWallet;
    bool public betsOpen = false;
    bool public failsafe;
    mapping(address => bool) public isContract;

    mapping(uint256 => mapping (address => uint256)) public amountUserPutIn;
    mapping(uint256 => mapping (address => uint256)) public teamUserBettedOn;
    mapping(address => uint256) public roundUserBettedOn;
    mapping(uint256 => mapping (uint256 => bool)) public isWinner;
    mapping(uint256 => mapping (address => bool)) public winningsWithdrawn;
    mapping(uint256 => uint256) public totalBets;
    mapping(uint256 => mapping (uint256 => uint256)) public totalBetOnTeam;
    mapping(uint256 => mapping (address => bool)) public changedBet;
    uint256 public devFee = 5;
    uint256 public stakersFee = 5;
    uint256 public totalFees = 10;
    uint256 public feeRemainder = 90;
    uint256 public potOfFees;
    uint256 public stakingPot;
    uint256 public currentRound = 1;
    mapping(address => bool) public isReferee;
    mapping(uint256 => uint256) public roundWinner;
    mapping(uint256 => bool) winnerDeclared;


    
    uint256 public distributedAmount;
    uint256 MULTIPLIER = 1000000000000000000;

    modifier onlyReferee() {
        require(isReferee[msg.sender] == true, "Caller is not the referee");
        _;
    }
    

    constructor() {
        isReferee[msg.sender] = true;
        isContract[address(this)] = true;
    }
        
    receive() external payable {
        distribute();
    }
    
     
    function distribute() public payable {
        require(totalBets[currentRound] > 0);
        distributedAmount = distributedAmount.add(msg.value.mul(MULTIPLIER).div(totalBets[currentRound]));
    }

    function calculateWinnings(address user, uint256 team, uint256 round) public view returns(uint256) {
        uint256 winnings = amountUserPutIn[round][user].mul(totalBets[round]).div(totalBetOnTeam[round][team]);
        return winnings;
    }

    function placeBet(uint256 teamToBetOn) public payable {  
        require(betsOpen == true, "you have to wait for bets to be open");  
        require(msg.value > 0, "you must set an amount to bet");    
        uint256 amountToBet = msg.value;
        // Make sure the user is not changing who he is placing his bet on, or has to pay a fee when he withdraws his winnings
        if (roundUserBettedOn[msg.sender] == currentRound) {
            if (teamToBetOn != teamUserBettedOn[currentRound][msg.sender]) {
                changedBet[currentRound][msg.sender] = true;
                uint256 previousAmount = amountUserPutIn[currentRound][msg.sender];
                totalBetOnTeam[currentRound][teamBettedOn(msg.sender)] = totalBetOnTeam[currentRound][teamBettedOn(msg.sender)].sub(previousAmount);
                totalBetOnTeam[currentRound][teamToBetOn] = totalBetOnTeam[currentRound][teamToBetOn].add(previousAmount);
            }
        }
        // Set all the data correctly
        potOfFees = potOfFees.add(amountToBet.mul(devFee).div(100));
        stakingPot = potOfFees.add(amountToBet.mul(stakersFee).div(100));
        amountToBet = amountToBet.mul(feeRemainder).div(100);
        teamUserBettedOn[currentRound][msg.sender] = teamToBetOn;
        totalBets[currentRound] = totalBets[currentRound].add(amountToBet);
        amountUserPutIn[currentRound][msg.sender] = amountUserPutIn[currentRound][msg.sender].add(amountToBet);
        totalBetOnTeam[currentRound][teamToBetOn] = totalBetOnTeam[currentRound][teamToBetOn].add(amountToBet);
        roundUserBettedOn[msg.sender] = currentRound;
        winningsWithdrawn[currentRound][msg.sender] = false;
    }

    function takeOutBet(uint256 amount) public payable{
        require (betsOpen == true, "you cannot take out your bet while bets are closed");
        require (roundUserBettedOn[msg.sender] == currentRound, "you did not bet in this round");
        amount = amount.mul(MULTIPLIER);
        uint256 amountToTakeOut = amount.mul(90).div(100);
        uint256 welchersFee = amount.mul(10).div(100);
        getPayment(projectMayhemWallet, welchersFee);
        getPayment(msg.sender, amountToTakeOut);
        amountUserPutIn[currentRound][msg.sender] = amountUserPutIn[currentRound][msg.sender].sub(amount);
        totalBetOnTeam[currentRound][teamUserBettedOn[currentRound][msg.sender]] = totalBetOnTeam[currentRound][teamUserBettedOn[currentRound][msg.sender]].sub(amount);
        totalBets[currentRound] = totalBets[currentRound].sub(amount);
        if (amountUserPutIn[currentRound][msg.sender] == 0) {
            roundUserBettedOn[msg.sender] = 0;
        }
    }

    function pullBetWithFailsafe() public payable{
        require (failsafe == true, "this is a failsafe for if something happens and users have to pull their bets");
        require (amountUserPutIn[currentRound][msg.sender] > 0, "You did not bet on this round");
        uint256 amount = amountUserPutIn[currentRound][msg.sender];
        getPayment(msg.sender, amount);
        totalBetOnTeam[currentRound][teamUserBettedOn[currentRound][msg.sender]] == totalBetOnTeam[currentRound][teamUserBettedOn[currentRound][msg.sender]].sub(amountUserPutIn[currentRound][msg.sender]);
        totalBets[currentRound] = totalBets[currentRound].sub(amountUserPutIn[currentRound][msg.sender]);
        amountUserPutIn[currentRound][msg.sender] = 0;
    }

    function declareWinner(uint256 winningTeam) public onlyReferee() {
        isWinner[currentRound][winningTeam] = true;
        roundWinner[currentRound] = winningTeam;
        winnerDeclared[currentRound] = true;
    }

    function withdrawWinnings(uint256 round) public payable {
        // Calculate winnings and take out value from pot.
        require(amountUserPutIn[round][msg.sender] > 0, "You did not bet on this round");
        require(winningsWithdrawn[round][msg.sender] == false);
        require(winnerDeclared[round] == true, "Winner has not been declared yet");
        require(isWinner[round][teamUserBettedOn[round][msg.sender]] == true, "You did not win the bet");
        uint256 winnings = calculateWinnings(msg.sender, teamUserBettedOn[round][msg.sender], round);
        if(changedBet[round][msg.sender] == true) {
                uint256 changingFee = winnings.mul(10).div(100);
                winnings = winnings.mul(90).div(100);
                getPayment(projectMayhemWallet, changingFee);
        }
        if(winnings > 0) {
            getPayment(msg.sender, winnings);
        }
        winningsWithdrawn[round][msg.sender] = true;
    }

    function getTotalBetOnTeam(uint256 team, uint256 round) public view returns (uint256) {
        return totalBetOnTeam[round][team];
    }

    function getAmountUserPutIn(address user, uint256 round) public view returns (uint256) {
        return amountUserPutIn[round][user];
    }

    function teamBettedOn(address user) public view returns (uint256) {
        return teamUserBettedOn[currentRound][user];
    }

    function getTotalBets(uint256 round) public view returns (uint256) {
        return totalBets[round];
    }

    function betsState() public view returns (bool) {
        return betsOpen;
    }    

    function getCurrentRound() public view returns (uint256) {
        return currentRound;
    }

    function getDevFee() public view returns (uint256) {
        return devFee;
    }

    function changeSoapAddress(address _newAddress) public onlyOwner() {
        soapAddress = _newAddress;
    }

    function getStakingFee() public view returns (uint256) {
        return stakersFee;
    }

    function getTotalFee() public view returns (uint256) {
        return totalFees;
    }

    function getRoundWinner(uint256 round) public view returns (uint256) {
        return roundWinner[round];
    }

    function setBetsState(bool areBetsOpen) public onlyReferee() {
        betsOpen = areBetsOpen;
        payToSoapStakingContract;
    }

    function setFailsafe(bool isFailsafeOn) public onlyOwner() {
        failsafe = isFailsafeOn;
    }

    function closeRound() public onlyReferee() {
        currentRound++;
    }

    function checkStakingPot() public view returns (uint256) {
        return stakingPot;
    }

    function checkPotOfFees() public view returns (uint256) {
        return potOfFees;
    }

    function setIsReferee(address user, bool _isReferee) public onlyOwner() {
        isReferee[user] = _isReferee;
    }

    function setFees(uint256 newStakersFee, uint256 newDevFee ) public onlyOwner() {
        stakersFee = newStakersFee;
        devFee = newDevFee;
        totalFees = stakersFee.add(devFee);
        feeRemainder = 100 - totalFees;
    }

    function setStakingContract(address _newContract) public onlyOwner() {
        soapStakingContract = _newContract;
    }

    function setProjectWallet(address _newWallet) public onlyOwner() {
        projectMayhemWallet = _newWallet;
    }
    
    function getPayment(address _address, uint256 amount) private {
	    (bool success,) = payable(_address).call{value : amount}("");
        require(success);
    }

    function payToSoapStakingContract() public{
        if(stakingPot >= 0.1 ether){
            uint256 amount = stakingPot;
            stakingPot = 0;
            getPayment(soapStakingContract, amount);
        }
    }

    function payToDevWallet() public{
        if(potOfFees >= 0.1 ether) {
            uint256 amount = potOfFees;
            potOfFees = 0;
            getPayment(projectMayhemWallet, amount);
        }
    }
  
}
contract soapContract {
    mapping (address => uint256) public _balances;
    function approveMax(address spender) external returns (bool) {}
    function transfer(address recipient, uint256 amount) public returns (bool) {}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function feelessTransfer(address sender, address recipient, uint256 amount) public returns (bool) {}
}
/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

// import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
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
abstract contract Auth {
    address internal raffleOwner;
    address internal raffleAdmin;
    mapping (address => bool) internal authorizations;

    constructor(address _raffleOwner, address _raffleAdmin) {
        raffleOwner = _raffleOwner;
        raffleAdmin = _raffleAdmin;
        authorizations[_raffleOwner] = true;
        authorizations[_raffleAdmin] = true;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "not RaffleAdmin"); _;
    }
    modifier withRaffleOwner {
        require(isAdmin(msg.sender)||isRaffleOwner(msg.sender),"neither Admin nor RaffleOwner"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyAdmin {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyAdmin {
        authorizations[adr] = false;
    }

    function isAdmin(address account) public view returns (bool) {
        return account == raffleAdmin;
    }

    function isRaffleOwner(address account) public view returns (bool) {
        return account == raffleOwner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnershipToAdmin(address payable adr) public onlyAdmin {
        raffleAdmin = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    function getAdminAddress() public view returns(address){
        return raffleAdmin;
    }

    function getRaffleOwnerAddress() public view returns(address){
        return raffleOwner;
    }

    event OwnershipTransferred(address owner);
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
contract Raffle is Auth {
    using SafeMath for uint256;

    IERC20 RafToken = IERC20(0x050Da123F86A355E0e7F9072D230ebc2707FE25D); //bsctestNet
    IERC20 WBNBToken  = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); //mainNet WBNB

    uint256 public startTime;
    uint256 public endTime;
    bool public isLimitableRaffle;
    uint256 public limitedRaffleNum = 0;
    uint256 public spotNum;
    uint256 public ticketPrice;
    uint256 public guranteeFee;
    uint256 public returnFeeRate;
    uint256 public holdingBNB;
    // uint256 private raffleOwnerFee;
    // uint256 private teamFee;
    address adminAddress;

    uint256 public dominator = 100;

    mapping(uint256 => address) public ticketAddress; //key -> address
    mapping(address => bool) public isWinner;
    address[] public winnerList;
    address[] public playerList;
    mapping(address => uint256) public player; //address -> ticketNum
    mapping(uint256 => uint256) randomBox;
    uint256 public ticketIndex = 0; 
    uint256 private randomBoxIndex = 0; 
    uint256 private playerNumber = 0;

    bool isRaffleClosed = false;
    bool isRaffled = false;
    bool isApprovedRaffle = false;

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        bool _isLimitableRaffle,
        uint256 _limitedRaffleNum,
        uint256 _spotNum,
        uint256 _ticketPrice, 
        uint256 _guranteeFee, 
        uint256 _returnFeeRate,
        uint256 _holdingBNB, 
        address _adminAddress
        ) Auth(msg.sender, _adminAddress) payable {
            require(msg.value == _guranteeFee, "msg.value !== guranteeFee");
            require(_startTime > block.timestamp, "The startTime should be later than now.");
            require(_startTime < _endTime, "The startTime must be before the endTime");
            require(_isLimitableRaffle? _limitedRaffleNum != 0 : _limitedRaffleNum == 0,"Check out the raffleNum constraint.");
            startTime = _startTime;
            endTime = _endTime;
            raffleAdmin = _adminAddress;
            isLimitableRaffle = _isLimitableRaffle;
            limitedRaffleNum = _limitedRaffleNum;
            spotNum = _spotNum;
            ticketPrice = _ticketPrice;
            guranteeFee = _guranteeFee; 
            returnFeeRate = _returnFeeRate;
            holdingBNB = _holdingBNB; 
            raffleOwner = msg.sender;
            emit RaffleCreated(
                _startTime, 
                _endTime, 
                _isLimitableRaffle, 
                _limitedRaffleNum, 
                _spotNum, 
                _ticketPrice, 
                _guranteeFee, 
                _returnFeeRate, 
                _holdingBNB, 
                _adminAddress,
                address(this));
    }

    receive() external payable {}

    event RaffleCreated(
        uint256 startTime, 
        uint256 endTime, 
        bool isLimitableRaffle, 
        uint256 limitedRaffleNum, 
        uint256 spotNum, 
        uint256 ticketPrice, 
        uint256 guranteeFee, 
        uint256 returnFeeRate,
        uint256 holdingBNB,
        address adminAddress,
        address contractAddress);
    event SetProjectName(string projectName);
    event SetStartTime(uint256 startTime);
    event SetEndTime(uint256 endTime);
    event SetIsLimitableRaffle(bool IsLimitableRaffle, uint256 limitedRaffleNum);
    event SetLimitedRaffleNum(uint256 limitedRaffleNum);
    event SetSpotNum(uint256 spotNum);
    event SetTicketPrice(uint256 ticketPrice);
    event SetReturnFeeRate(uint256 returnFeeRate);
    event JoinRaffle(address joinAddress, uint256 ticketNumber);
    event EmergencyEnd(bool emergencyEnd);
    event RaffleClose(bool close);
    event SetApproveRaffe(bool approvedRaffle);

    //--------------------joinRaffle function------------------------------

    function joinRaffle(uint256 ticketNum) external payable {
        // uint256 RafAmount = ticketPrice.mul(ticketNum);
        require(startTime <= block.timestamp && block.timestamp <= endTime, "Raffle is not in progress");
        require(!isRaffleClosed, "Already raffle closed.");
        // require(RafAmount <= getRafTokenBalance(),"Token balance is low.");
        // require(holdingBNB <= getBNBBalance(), "BNB balance is too low");
        require(((isLimitableRaffle && player[msg.sender].add(ticketNum) <= limitedRaffleNum)) || !isLimitableRaffle, "The number of raffle has been exceeded."); //Limited number of raffles
        // require(RafAllownce >= RafAmount, "Check the token allowance"); // Check in front?
        // if(RafAmount > 0) RafToken.transferFrom(msg.sender, address(this), RafAmount);
        if(player[msg.sender]==0){
            playerNumber++;
            playerList.push(msg.sender);
        }
        for(uint i=0; i<ticketNum; i++){
            ticketAddress[ticketIndex] = msg.sender;
            ticketIndex++;
        }
        player[msg.sender]+=ticketNum;
        randomBox[randomBoxIndex] = getRandomNumber();
        randomBoxIndex++;
        emit JoinRaffle(msg.sender, ticketNum);
    }

    function raffle() external onlyAdmin{
        require(!isRaffled,"already reffled");
        require(block.timestamp > endTime || isRaffleClosed, "The Raffle must be after the endTime");
        if(spotNum < playerNumber){
            for(uint i=0; i<spotNum; i++){
                uint256 randomNumber = randomBox[i] % (ticketIndex);
                if(!isWinner[ticketAddress[randomNumber]]){
                    isWinner[ticketAddress[randomNumber]]=true;
                    winnerList.push(ticketAddress[randomNumber]);
                } else {
                    while(isWinner[ticketAddress[randomNumber]]){
                        if(randomNumber+1 != ticketIndex){
                                randomNumber++;
                            } else randomNumber = 0;
                        if(!isWinner[ticketAddress[randomNumber]]){
                            isWinner[ticketAddress[randomNumber]]=true;
                            winnerList.push(ticketAddress[randomNumber]);
                            break;
                        }
                    }
                }
            }
        } else {
            winnerList = playerList;
        }
        
    }

    function getRandomNumber() internal view returns(uint256){
        return  uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, ticketIndex)));
    }

    function getPlayerTicketNum() public view returns(uint256) {
        return player[msg.sender];
    }

    function getRafTokenBalance() internal view returns(uint256) {
        return RafToken.balanceOf(msg.sender);
    }

    function getBNBBalance() internal view returns(uint256) {
        return WBNBToken.balanceOf(msg.sender).add(msg.sender.balance); // BNB + WBNB balance
    }

    //--------------------about Ticket & guranteeFee-------------------

    function refundRafToPlayer() external onlyAdmin{}

    function refundRafNomarly() external onlyAdmin{}

    function refundBNB() external onlyAdmin{}

    function withrawStuckBalance() external onlyAdmin{}

    function getRafBalanceCA() public view returns(uint256){
        return RafToken.balanceOf(address(this));
    }

    function getBNBBalanceCA() public view returns(uint256){
        return address(this).balance;
    }

    function getMyTicketCount(address adr) public view returns(uint256){
        // return msg.sender.balance;
    }

    function getWinnerlist() public view returns(address[] memory){
        return winnerList;
    }

    //---------------------set raffle info----------------------------

    function setStartTime(uint256 time) external withRaffleOwner{
        require(time > block.timestamp, "The startTime should be later than now.");
        require(time < endTime, "The startTime must be before the endTime");
        startTime = time;
        emit SetStartTime(time);
    }

    function setEndTime(uint256 time) external withRaffleOwner{
        require(time > block.timestamp, "The endTime should be later than now.");
        require(time > startTime, "The Time must be before the endTime");
        require(!isRaffleClosed, "The endTime should be before raffle close");
        endTime = time;
        emit SetEndTime(time);
    }
    
    function setIsLimitableRaffle(bool boolean, uint number) external onlyAdmin{
        require(block.timestamp < startTime, "It cannot be set after startTime");
        if(!isLimitableRaffle && limitedRaffleNum == 0) {
            require(number !=0,"The number must be greater than 0.");
            this.setLimitedRaffleNum(number);
        }
        if(isLimitableRaffle && limitedRaffleNum != 0) {
            require(number ==0, "The number must be 0");
            this.setLimitedRaffleNum(number);
        }
        isLimitableRaffle = boolean;
        emit SetIsLimitableRaffle(boolean, limitedRaffleNum);
    }

    function setLimitedRaffleNum(uint256 num) external onlyAdmin{
        require(block.timestamp < startTime, "It cannot be set after startTime");
        limitedRaffleNum = num;
        emit SetLimitedRaffleNum(num);
    }
    
    function setSpotNum(uint256 num) external onlyAdmin{
        require(block.timestamp < startTime, "It cannot be set after startTime");
        spotNum = num;
        emit SetSpotNum(num);
    }

    function setTicketPrice(uint256 price) external onlyAdmin{
        require(block.timestamp < startTime, "It cannot be set after startTime");
        ticketPrice = price;
        emit SetTicketPrice(price);
    }

    function setReturnFeeRate(uint256 rate) external onlyAdmin{
        returnFeeRate = rate;
        emit SetReturnFeeRate(rate);
    }
    

    function setEmergencyEnd(bool _bool) external onlyAdmin{
        require(startTime <= block.timestamp || block.timestamp <= endTime, "Raffle is not in progress");
        // require();
        if(!isRaffleClosed) {
            isRaffleClosed = _bool;
            emit EmergencyEnd(_bool);
        }
    }

    function raffleClose(bool _bool) external onlyAdmin{
        require(endTime < block.timestamp);
        if(!isRaffleClosed) {
            isRaffleClosed = _bool;
            emit RaffleClose(_bool);
        }
    }

    function setApproveRaffle(bool _bool) external onlyAdmin{
        require(!isApprovedRaffle, "already approved");
        isApprovedRaffle = _bool;
        emit SetApproveRaffe(_bool);
    }
}

 contract RaffleFactory {
    using SafeMath for uint256;
    address[]public raffleList;
    address adminAddress;
    constructor(address _adminAddress) {
        adminAddress = _adminAddress;
    }
    event RaffleCreate(address contractAddress, address raffleCreateAddress, string projectId);
    function createRaffle(
        string memory _projectId,
        uint256 _startTime,
        uint256 _endTime,
        bool _isLimitableRaffle,
        uint256 _limitedRaffleNum,
        uint256 _spotNum,
        uint256 _ticketPrice,
        uint256 _guranteeFee,
        uint256 _returnFeeRate,
        uint256 _holdingBNB) external{
            Raffle createdRaffle = new Raffle(
                _startTime,
                _endTime,
                _isLimitableRaffle,
                _limitedRaffleNum,
                _spotNum,
                _ticketPrice,
                _guranteeFee,
                _returnFeeRate,
                _holdingBNB,
                adminAddress
                // uint256 _raffleOwnerFee, // 8% -> input 8
                // uint256 _teamFee // 8% -> input 8);
            );
            raffleList.push(address(createdRaffle));
            emit RaffleCreate(address(createdRaffle), msg.sender, _projectId);
        }
}
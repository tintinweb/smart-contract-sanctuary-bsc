/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;


library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

pragma solidity ^0.8.0;

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

pragma solidity ^0.8.0;
pragma abicoder v2;


contract DegenNumbers is  ReentrancyGuard {
    using SafeERC20 for IERC20;

    AggregatorV3Interface public oracle;

    bool public genesisLockOnce = false;
    bool public genesisStartOnce = false;

    address public adminAddress; // address of the admin
    address public operatorAddress; // address of the operator

    uint80 public totalRounds = 0;

    uint256 public tierPercentage; // percentage of each tier

    uint256 public bufferSeconds; // number of seconds for valid execution of a prediction round
    uint256 public intervalSeconds; // interval in seconds between two prediction rounds

    uint256 public minBetAmount; // minimum betting amount (denominated in wei)
    uint256 public treasuryFee = 0; // treasury rate (e.g. 2 = 2%, 1 = 1%)
    uint256 public NFTfee;

    uint256 public treasuryAmount; // treasury amount that was not claimed
    uint256 public NFTbear;
    uint256 public NFTbull;
    int256 public borderAmount = 20;
    bool public isPaused = false;

    uint256 public roundId = 0;

    address public owner = address(0x0);
    address public admin = address(0x0);


    uint256 public currentEpoch; // current epoch for prediction round

    uint256 public oracleLatestRoundId; // converted from uint80 (Chainlink)

    uint256 public constant MAX_TREASURY_FEE = 100; // 10%

    mapping(uint256 => mapping(address => BetInfo)) public ledger;
    mapping(uint256 => Round) public rounds;
    mapping(address => uint256[]) public userRounds;
    mapping (address=>uint256) totalWon;

    enum Position {
        Bull1,
        Bear1,
        Bull2,
        Bear2,
        Bull3,
        Bear3,
        Null
    }

    struct Round {
        uint256 startTimestamp;
        uint256 closeTimestamp;
        int256 closePrice;
        AmountInfo AmountInfo;
    }

    struct AmountInfo{
        uint256 totalAmount1;
        uint256 bullAmount1;
        uint256 bearAmount1;
        uint256 totalAmount2;
        uint256 bullAmount2;
        uint256 bearAmount2;
        uint256 totalAmount3;
        uint256 bullAmount3;
        uint256 bearAmount3;
    }

    struct BetInfo {
        Position[3] position;
        uint256[3] amount;
        bool[3] bet;
        bool claimed; // default false
    }

    event BetBear(address indexed sender, uint256 indexed epoch, uint256 amount);
    event BetBull(address indexed sender, uint256 indexed epoch, uint256 amount);
    event Claim(address indexed sender, uint256 indexed epoch, uint256 amount);
    event EndRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);
    event LockRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);

    event NewAdminAddress(address admin);
    event NewBufferAndIntervalSeconds(uint256 bufferSeconds, uint256 intervalSeconds);
    event NewMinBetAmount(uint256 indexed epoch, uint256 minBetAmount);
    event NewTreasuryFee(uint256 indexed epoch, uint256 treasuryFee);
    event NewOperatorAddress(address operator);
    event NewOracle(address oracle);
    event NewOracleUpdateAllowance(uint256 oracleUpdateAllowance);

    event Pause(uint256 indexed epoch);
    event RewardsCalculated(
        uint256 indexed epoch,
        uint256 rewardBaseCalAmount,
        uint256 rewardAmount,
        uint256 treasuryAmount
    );

    event StartRound(uint256 indexed epoch);
    event TokenRecovery(address indexed token, uint256 amount);
    event TreasuryClaim(uint256 amount);
    event Unpause(uint256 indexed epoch);

    constructor(uint256 interval){
        intervalSeconds = interval;
        owner = msg.sender;
        admin = msg.sender;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    function checkOraclePrice() public pure returns (int256)
    {
        return 100;
    }
    

    function setAdmin(address _admin) public{
        require (msg.sender == owner,"Not authorized.");
        admin = _admin;
    }

    function pauseRound() public{
        require(msg.sender == admin);
        isPaused = true;
        genesisStartOnce = false;
    }

    function unpauseRound() public{
        require(msg.sender == owner);
        isPaused = false;
    }

    function startRound() public{
        rounds[roundId+1].startTimestamp = block.timestamp;
        roundId = roundId + 1;
        genesisStartOnce = true;
    }

    function executeRound(int256 price) public {
        require(rounds[roundId].startTimestamp + intervalSeconds <= block.timestamp, "Appropriate interval hasn't passed.");
        require(msg.sender == admin,"Not authorized.");
        require(isPaused == false, "Round is paused.");
        require(genesisStartOnce == true,"Genesis not started.");
        //int256 price = checkOraclePrice();

        rounds[roundId].closeTimestamp = block.timestamp;
        rounds[roundId].closePrice = price;
        rounds[roundId+1].startTimestamp = block.timestamp;
        roundId = roundId + 1;
    }

    function endRoundAndPause(int256 price) public{
        require(msg.sender == admin,"Not authorized.");
        genesisStartOnce = false;
        isPaused = true;
        rounds[roundId].closeTimestamp = block.timestamp;
        rounds[roundId].closePrice = price;
    }

    function isBettable() public view returns(bool){
        if (rounds[roundId].startTimestamp != 0  && block.timestamp > rounds[roundId].startTimestamp && block.timestamp < rounds[roundId].startTimestamp + intervalSeconds)
            return true;
        return false;
    }

    function claim(uint256 epoch) public nonReentrant notContract {
        require( ledger[epoch][msg.sender].claimed == false, "You already claimed.");

        uint256 amount = claimableForRound(epoch, msg.sender);

        _safeTransferMatic(msg.sender, amount);

        ledger[epoch][msg.sender].claimed = true;
    }

    function betBull(uint256 betType) public payable nonReentrant notContract{
        uint256 epoch = roundId;
        require (isBettable() == true, "Round not bettable");
        require(msg.value > minBetAmount,"Bet Amount too low");
        require(ledger[epoch][msg.sender].bet[betType] == false, "You already placed a bet for this number.");
        require(betType<3,"Invalid bet type.");
        uint256 betAmount = msg.value;

        if (betType == 0){
            rounds[epoch].AmountInfo.totalAmount1 += betAmount;
            rounds[epoch].AmountInfo.bullAmount1 += betAmount;
            ledger[epoch][msg.sender].position[betType] = Position.Bull1;
        }

        if (betType == 1){
            rounds[epoch].AmountInfo.totalAmount2 += betAmount;
            rounds[epoch].AmountInfo.bullAmount2 += betAmount;
            ledger[epoch][msg.sender].position[betType] = Position.Bull2;
        }
        
        if(betType == 2){
            rounds[epoch].AmountInfo.totalAmount3 += betAmount;
            rounds[epoch].AmountInfo.bullAmount3 += betAmount;
            ledger[epoch][msg.sender].position[betType] = Position.Bull3;
        }

        ledger[epoch][msg.sender].amount[betType] = betAmount;
        ledger[epoch][msg.sender].bet[betType] = true;
        userRounds[msg.sender].push(epoch);
    }

    function betBear(uint256 betType) public payable nonReentrant notContract{
        uint256 epoch = roundId;
        require (isBettable() == true, "Round not bettable");
        require(msg.value > minBetAmount,"Bet Amount too low");
        require(ledger[epoch][msg.sender].bet[betType] == false, "You already placed a bet for this number.");
        require(betType<3,"Invalid bet type.");
        uint256 betAmount = msg.value;

        if (betType == 0){
            rounds[epoch].AmountInfo.totalAmount1 += betAmount;
            rounds[epoch].AmountInfo.bearAmount1 += betAmount;
            ledger[epoch][msg.sender].position[betType] = Position.Bear1;
        }

        if (betType == 1){
            rounds[epoch].AmountInfo.totalAmount2 += betAmount;
            rounds[epoch].AmountInfo.bearAmount2 += betAmount;
            ledger[epoch][msg.sender].position[betType] = Position.Bear2;
        }
        
        if(betType == 2){
            rounds[epoch].AmountInfo.totalAmount3 += betAmount;
            rounds[epoch].AmountInfo.bearAmount3 += betAmount;
            ledger[epoch][msg.sender].position[betType] = Position.Bear3;
        }

        ledger[epoch][msg.sender].amount[betType] = betAmount;
        ledger[epoch][msg.sender].bet[betType] = true;
    }

    function claimableForRound(uint256 epoch, address user) public view returns(uint256) {
        uint256 total;
        Position winner1 = getWinner(epoch,0);
        Position winner2 = getWinner(epoch,1);
        Position winner3 = getWinner(epoch,2);


        if (winner1 == ledger[epoch][user].position[0]){
            if(winner1 == Position.Bull1){
                total = total +  ledger[epoch][user].amount[0] * rounds[epoch].AmountInfo.totalAmount1 / rounds[epoch].AmountInfo.bullAmount1 ;
            }

            if (winner1 == Position.Bear1){
                total = total +  ledger[epoch][user].amount[0] * rounds[epoch].AmountInfo.totalAmount1 / rounds[epoch].AmountInfo.bearAmount1 ;
            }
        }

        if (winner2 == ledger[epoch][user].position[1]){
            if(winner2 == Position.Bull2){
                total = total +  ledger[epoch][user].amount[1] * rounds[epoch].AmountInfo.totalAmount2 / rounds[epoch].AmountInfo.bullAmount2 ;
            }

            if (winner2 == Position.Bear2){
                total = total + ledger[epoch][user].amount[1] * rounds[epoch].AmountInfo.totalAmount2 / rounds[epoch].AmountInfo.bearAmount2 ;
            }
        }

        if (winner3 == ledger[epoch][user].position[2]){
            if(winner3 == Position.Bull3){
                total = total + ledger[epoch][user].amount[2] * rounds[epoch].AmountInfo.totalAmount3 / rounds[epoch].AmountInfo.bullAmount3 ;
            }

            if (winner3 == Position.Bear3){
                total = total + ledger[epoch][user].amount[2] * rounds[epoch].AmountInfo.totalAmount3 / rounds[epoch].AmountInfo.bearAmount3 ;
            }
        }

        return total;
    }

    function getWinner (uint256 epoch, uint256 betType) public view returns (Position){
        int256 num;
        if (rounds[epoch].closePrice == 0)
            return (Position.Null);
        
        if (betType == 0){
            num = (rounds[epoch].closePrice % 1000);
            if ( num < 500){
                return Position.Bear1;
            }
            else{
                return Position.Bull1;
            }
        }

        if (betType == 1){
            num = (rounds[epoch].closePrice % 100);
            if ( num < 50){
                return Position.Bear2;
            }
            else{
                return Position.Bull2;
            }
        }

        if (betType == 2){
            num = (rounds[epoch].closePrice % 10);
            if ( num < 5){
                return Position.Bear3;
            }
            else{
                return Position.Bull3;
            }
        }

        return (Position.Null);
    }



    function claimTreasury () public{
        require(msg.sender ==owner, "Not authorized");
        payable(owner).transfer(treasuryAmount);
        treasuryAmount = 0;
    }

    function setTreasuryFee(uint256 _treasuryFee) public{
        require(msg.sender ==owner, "Not authorized");
        treasuryFee = _treasuryFee;
    }

    function withdrawStuckWei(uint256 _balance) public{
        require(msg.sender == owner, "Not authorized");
        payable(owner).transfer(_balance);
    }

    function withdrawAllWei() public{
        require(msg.sender == owner, "Not authorized");
        payable(owner).transfer(address(this).balance);
    }

    function getDataPosition(uint256 round, uint256 betType) public view returns (uint256){
        return ledger[round][msg.sender].amount[betType];
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _safeTransferMatic(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: MATIC_TRANSFER_FAILED");
    }

    function recoverToken(address _token, uint256 _amount) external  {
        require(msg.sender == owner,"Not authorized");
        IERC20(_token).safeTransfer(address(msg.sender), _amount);
        emit TokenRecovery(_token, _amount);
    }

    receive() external payable {}
}
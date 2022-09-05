/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

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
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
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
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract SDTokenJackpot{
    using SafeERC20 for IERC20;
    IERC20 public immutable token;

    address public owner;
    address [] public players;
    address [] public winners;
    address private dead = 0x000000000000000000000000000000000000dEaD;

    uint public tokenDecimals;
    uint public depositAmount;
    uint public maxParticipants;
    uint public totalBurnt = 0;
    uint public counter = 0;
    uint public gameCount = 0;
    uint public winnerRate = 80;

    bool public gameStatus = false;
    
    constructor(address _token, uint _decimals, uint _depositAmount, uint _maxParticipants){
        //Set Owner
        owner = msg.sender;
        //Token Info
        token = IERC20(_token);
        tokenDecimals = _decimals;
        //deposit amount is a multiplier of 1 SD. If you input _depositAmount as 1, the deposit amount is going to be 1 SD.
        depositAmount = _depositAmount * 10**tokenDecimals;
        maxParticipants = _maxParticipants;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"Only owner can call this function.");
        _;
    }
    //This function sets how much % the winner will receive
    function setWinnerRate(uint _rateInPercentage) public onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you set the winnerRate.");
        winnerRate = _rateInPercentage;
    }
    //This function resets the game, turns the game into initial state
    function resetGame() public onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you reset the game.");
        players = new address [](0);
        counter = 0;
    }
    //This function can stop/start the lottery
    function gameToggle() public onlyOwner{
        gameStatus = !gameStatus;
    }
    //This function changes how many participants are allowed to join the game
    function setMaxParticipants(uint _newMaxParticipants) public onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you change maxParticipants.");
        maxParticipants = _newMaxParticipants;
    }
    //deposit amount is a multiplier of 1 SD. If you input _depositAmount as 1, the deposit amount is going to be 1 SD.
    //This function changes the deposit amount
     function changeDepositAmount(uint _newDepositAmount) public onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you change depositAmount.");
        depositAmount = _newDepositAmount * 10**tokenDecimals;
    }
    //This function rescues if any SD gets stuck in the contract somehow
    function rescueStuckBalance() public onlyOwner{
        require(gameStatus == false,"You must stop the game using gameToggle before you rescue $SD.");
        uint balance = token.balanceOf(address(this));
        token.safeTransfer(owner, balance);
    }
    //This function displays token balance of the contract
    function getBalance() public view returns (uint){
        uint balance = token.balanceOf(address(this));
        return balance;
    }
    //This function gets players address list
    function getPlayers() public view returns (address [] memory){
        return players;
    }
    //This function gets winners address list
    function getWinners() public view returns (address [] memory){
        return winners;
    }
    //This function makes you enter the Jackpot
    function enter() external{
        //To enter the Jackpot, game must be running
        require(gameStatus == true,"The Jackpot has been stopped, please wait until it is started again.");
        //Receive SD from the participant if user has enough SD tokens.
        require(token.balanceOf(msg.sender) >= depositAmount, "You don't have enough $SD to participate!");
        token.safeTransferFrom(msg.sender, address(this), depositAmount);
        //Save address of player entering the Jackpot
        players.push(msg.sender);
        //increase player count
        counter += 1;
        //if there are maximum amount of participants, pick the winner and send balances
        if(counter == maxParticipants){
            pickWinner();
        }
    }
    //This function generates a random number
    function getRandomNumber() internal view returns (uint){
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }
    //This function picks the winner
    function pickWinner() internal{
        //Select winner based on randomly generated number
        uint index = getRandomNumber() % players.length;
        //Set and send the prize
        uint256 prize = token.balanceOf(address(this))*winnerRate/100;
        token.safeTransfer(players[index], prize);
        //Set and send the performanceFee
        uint256 performanceFee = token.balanceOf(address(this))/2;
        token.safeTransfer(owner, performanceFee);
        //Set and send the burnFee
        uint256 burnFee = token.balanceOf(address(this));
        token.safeTransfer(dead, burnFee);
        //Save winner of the current game
        winners.push(players[index]);
        //reset the state of the Jackpot, count the game and save burnt SD
        players = new address [](0);
        counter = 0;
        gameCount += 1;
        totalBurnt += burnFee;
    }
}
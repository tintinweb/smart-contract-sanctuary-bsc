/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

//In active development, not yet debugged.
//SPDX-License-Identifier: UNLICENSED


pragma solidity =0.8.13;

//import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function burn(uint256 amount) external returns (bool);
    function burnFrom(address account, uint256 amount) external returns (bool);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
/*
//valid for different network
contract RandomNumberConsumer is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    
    
     // Constructor inherits VRFConsumerBase
      
     // Network: Kovan
     // Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     // LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     // Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     
    constructor() 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        )
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.2 * 10 ** 18; // 0.1 LINK (Varies by network)
    }
    
     
     // Requests randomness 
     
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK, send more to the contract");
        return requestRandomness(keyHash, fee);
    }

    
     // Callback function used by VRF Coordinator
     
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
*/

contract Ownable is Context {
    address private _teamWallet;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _teamWallet = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _teamWallet;
    }

    modifier onlyOwner() {
        require(_teamWallet == _msgSender(), "Ownable: caller is not the owner/team wallet");
        _;
    }

    function transferOwnership(address newTeamWallet) external virtual onlyOwner {
		//don't allow burning except 0xdead
        require(newTeamWallet != address(0), "Ownable: new teamWallet is the zero address");
        emit OwnershipTransferred(_teamWallet, newTeamWallet);
        _teamWallet = newTeamWallet;
    }
}


contract P2E is Context, Ownable {

    using Address for address;

    mapping (address => uint256) private betPending;
    mapping (address => uint256) private betTimestamp;
    mapping (address => bool) private betNumbers;
    mapping (uint256 => bool) private betSize;
    string constant messageNoWrapper="Call from a wrapper contract not allowed";
    string constant messageNoBet="No active bet";
    string constant messageNoSameBlock="No frontrunning";
    string constant messageIncorrectAmount="Bet is not 0.05 or 0.1 or 0.2 or 0.5";
    string constant messageAlreadyDeposited="Active bet already pending, execute or withdraw first";


    constructor ()  {
        betSize[1e15] = true; //for testing, remove in production
        betSize[5e16] = true;
        betSize[1e17] = true;
        betSize[2e17] = true;
        betSize[5e17] = true;


    }

//Payable function to deposit BNB and prepare a call
    function betAgainstPool(bool upperHalf) external payable  {
        require(msg.sender==tx.origin,messageNoWrapper);
        require(betSize[msg.value],messageIncorrectAmount);
        require(betPending[msg.sender] == 0,messageAlreadyDeposited);
        //also check token balance worth, to be added
        betPending[msg.sender] = msg.value;
        betNumbers[msg.sender] = upperHalf;
        betTimestamp[msg.sender] = block.timestamp;
    }

    function cancelBetFromPool() external returns (bool)  {
        require(msg.sender==tx.origin,messageNoWrapper);
        require(betPending[msg.sender] > 0,messageNoBet);
        uint256 toPay = betPending[msg.sender];
        betPending[msg.sender] = 0;
        return payable(msg.sender).send(toPay);
    }

   function executeBet() external returns (uint) {
        require(msg.sender==tx.origin,messageNoWrapper);
        require(betPending[msg.sender] > 0,messageNoBet);
        require(betTimestamp[msg.sender] < block.timestamp,messageNoSameBlock);
        uint256 amount1 = betPending[msg.sender];
        uint256 amount2 = amount1/2;
        bool won = false;
        uint diceIn = rollDice();
        uint diceOut = diceIn;
        if (diceIn > 6) diceOut = diceIn - (betNumbers[msg.sender]?6:3);
        betPending[msg.sender] = 0;
        if (diceOut <= 3 && betNumbers[msg.sender] == true) won = false;
        if (diceOut <= 3 && betNumbers[msg.sender] == false) won = true;
        if (diceOut >= 4 && betNumbers[msg.sender] == true) won = true;
        if (diceOut >= 4 && betNumbers[msg.sender] == false) won = false;
        if (won)
        payable(msg.sender).transfer(amount1);
        else 
        payable(owner()).call{value: amount2}("");
        
        return diceOut;

   }


//Temporary implementation. Will need to switch to Chainling VRF
    function rollDice() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, tx.origin,betPending[msg.sender] )))%9+1;
    }
}
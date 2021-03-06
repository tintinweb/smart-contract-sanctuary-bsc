/**
 *Submitted for verification at BscScan.com on 2021-10-20
*/

/** 
	    	 __    _____ _____ _____ _____ _____ __ __ 
	    	|  |  |     |_   _|_   _|   __| __  |  |  |
	    	|  |__|  |  | | |   | | |   __|    -|_   _|
	    	|_____|_____| |_|   |_| |_____|__|__| |_| 


         888888888          888888888          888888888     
       88:::::::::88      88:::::::::88      88:::::::::88   
     88:::::::::::::88  88:::::::::::::88  88:::::::::::::88 
    8::::::88888::::::88::::::88888::::::88::::::88888::::::8
    8:::::8     8:::::88:::::8     8:::::88:::::8     8:::::8
    8:::::8     8:::::88:::::8     8:::::88:::::8     8:::::8
     8:::::88888:::::8  8:::::88888:::::8  8:::::88888:::::8 
      8:::::::::::::8    8:::::::::::::8    8:::::::::::::8  
     8:::::88888:::::8  8:::::88888:::::8  8:::::88888:::::8 
    8:::::8     8:::::88:::::8     8:::::88:::::8     8:::::8
    8:::::8     8:::::88:::::8     8:::::88:::::8     8:::::8
    8:::::8     8:::::88:::::8     8:::::88:::::8     8:::::8
    8::::::88888::::::88::::::88888::::::88::::::88888::::::8
     88:::::::::::::88  88:::::::::::::88  88:::::::::::::88 
       88:::::::::88      88:::::::::88      88:::::::::88   
         888888888          888888888          888888888     
         
                                                               
                  *****************************
                                                        
                          LOTTERY 888 v1
     
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface LinkTokenInterface {

  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );

  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );

  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );

  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );

  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;

  function name()
    external
    view
    returns (
      string memory tokenName
    );

  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );

  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );

  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );
}

contract VRFRequestIDBase {

  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

abstract contract VRFConsumerBase is VRFRequestIDBase {

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function burn(uint256 amount) external returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');
        return c;
    }
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }
    function sub( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }
    function mod(uint256 a,uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// Test net
// LINK	0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
// VRF Coordinator	0xa555fC018435bef5A13C6c6870a9d4C11DEC329C
// Key Hash	0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186
// Fee	0.1 LINK

// Main net
// LINK 0x404460C6A5EdE2D891e8297795264fDe62ADBB75
// VRF Coordinator	0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31
// Key Hash	0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c
// Fee	0.2 LINK

// 								VRFConsumerBase (VRFCoordinator, LINK)
contract Lottery888 is Ownable, VRFConsumerBase (0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31, 0x404460C6A5EdE2D891e8297795264fDe62ADBB75) { 
	using SafeMath for uint256; 
	using SafeBEP20 for IBEP20;
	
	IBEP20 public ticketToken; 
	IBEP20 public rewardToken; 
	
	bytes32 internal keyHash;
    uint256 internal fee;
	
	uint256 public roundNumber; 
	bytes32 public randomRequestId;
	uint256 public roundStartTime;   
	uint256 public roundNextStartTime;
	uint256 public roundNextStartTimeDelay;
	uint256 public roundDuration;  
	uint256 public numberOfWinnerPlaces;   
	uint256 public roundWinFunds; 
	
	bool public roundFinished;
	uint256 public randomResult;
	bool public winnersCalculated;
	
	address[] public participants;

	struct RoundResult {
        address account;     
        uint256 idx; 
        uint256 amount;
    }
	
	mapping (address => uint256) public winnerBalances;
	mapping (address => mapping (uint256 => uint256)) public playerEntrances;
	mapping (address => mapping (uint256 => uint256[])) public playerNumbers;
	mapping (uint256 => uint256) public roundEntrances;
	mapping (uint256 => RoundResult[]) public roundsResults;

	mapping (address => bool) public operatorsList;
	modifier onlyOperator() {
        require(operatorsList[_msgSender()] || _owner == _msgSender(), 'TORII: caller is not the operator/owner');
        _;
    }
	
    event Start(uint256 roundNumber, uint256 roundStartTime, uint256 durationOfRound, uint256 rewardAmount, uint256 winnerPlacesNumber);
    event Participate(uint256 roundNumber, address player, uint256 ticketsAmount);
    event Finish(uint256 roundFinishTime, uint256 numberOfParticants);
    event Randomness(bytes32 requestId, uint256 randomness);
    event Winner(uint256 roundNumber, address winnerAccount, uint256 winNumber, uint256 winAmount);
    event ClaimWin(address winner, uint256 amount);
    
	constructor(){	    
        ticketToken = IBEP20(0x9bfBF2a241A1E10A2f5d821A5b1a43573CE4B30f); // 888  
		rewardToken = IBEP20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d); // USDC  	
		
		keyHash = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c;
        fee = 0.2 * 1e18; 
        
        roundNextStartTimeDelay = 60;
        
		_owner = 0x1d3354FB678086Aa367FBb2BD30c05FADf558c9c; //_msgSender();		
   	}
  	
  	function finish() public onlyOperator {
	    require(roundEndTime() <= blockTimestamp(), 'Lottery888: Round time not passed');
	    require(!roundFinished, 'Lottery888: Round already finished');
        
        roundFinished = true;
        
        if (balanceOfTicketsTokens() != 0) {
            burnTicketTokens();
        }
        
        emit Finish(blockTimestamp(), participants.length);
        if (numberOfTickets() != 0) {
            require(LINK.balanceOf(address(this)) >= fee, "Lottery888: Not enough LINK supply contract first");
            requestRandomness(keyHash, fee);
        } else {
            randomResult = 1;
            calculateWinners();
        }
	}
	
	function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
	    require(roundFinished, 'Lottery888: Round not finished');
        randomResult = randomness;
        randomRequestId = requestId;
    }
    
    function calculateWinners() public { 
        require(roundFinished, 'Lottery888: Round not finished');
        require(randomResult != 0, 'Lottery888: Random number not recieved');
        
        require(!winnersCalculated, 'Lottery888: Already calculated');
        winnersCalculated = true;
		
		roundNextStartTime = blockTimestamp() + roundNextStartTimeDelay;
		
		if (numberOfTickets() != 0) {
            uint256 numOfPlaces = numberOfWinnerPlaces;
            if (numberOfTickets() <= numberOfWinnerPlaces ){
                numOfPlaces = numberOfTickets();
            } 
                
            uint256 winAmount = roundWinFunds.div(numOfPlaces);
            
            for (uint256 i = 0; i < numOfPlaces; i++) {
                uint256 winNumber;
                if (numberOfTickets() == numOfPlaces){
                   winNumber = i; 
                } else {
                   winNumber = uint256(keccak256(abi.encode(randomResult, i))).mod(numberOfTickets());
                }
    		    
    		    address winnerAccount = participants[winNumber];
    		    
    		    roundsResults[roundNumber].push(RoundResult({
    		        account: winnerAccount,
    		        idx: winNumber,
    		        amount: winAmount
    		    }));
    		    
    		    winnerBalances[winnerAccount] = winnerBalances[winnerAccount].add(winAmount);
    		    
    		    emit Winner(roundNumber, winnerAccount, winNumber, winAmount);
    		}
	    }
    }
    
    function getData() public view returns (
        uint256, // roundNumber
        bool, // winnersCalculated
        bool, // roundFinished
        uint256, // randomResult
        uint256, // roundEntrances
        uint256, // roundStartTime
        uint256, // roundNextStartTime
        uint256, // roundNextStartTimeDelay
        uint256, // roundDuration
        uint256, // numberOfWinnerPlaces
        uint256, // roundWinFunds
        uint256, // numberOfTickets()
        uint256, //, // balanceOfTicketsTokens()
        RoundResult[] memory
        ){
		return ( 
		    roundNumber,  
		    winnersCalculated,  
		    roundFinished, 
		    randomResult,
		    roundEntrances[roundNumber], 
		    roundStartTime, 
		    roundNextStartTime,  
		    roundNextStartTimeDelay, 
		    roundDuration, 
		    numberOfWinnerPlaces, 
		    roundWinFunds, 
		    participants.length,  
		    (roundStartTime + roundDuration), 
		    roundsResults[roundNumber] 
		);
    }
    function getUserData(address account) public view returns (        
        uint256, // playerEntrances[account][roundNumber]
        uint256, // winnerBalances[account]
        uint256[] memory, // playerNumbers[account][roundNumber]
		uint256, // ticketToken.balanceOf(account)
		uint256, // ticketToken.allowance(account, address(this))
		uint256  // rewardToken.balanceOf(account)
        ){
		return ( 
		    playerEntrances[account][roundNumber], 
		    winnerBalances[account], 
		    playerNumbers[account][roundNumber],
			ticketToken.balanceOf(account),
		    ticketToken.allowance(account, address(this)),
		    rewardToken.balanceOf(account)
		);
    }
    
    function getWinners() public view returns (RoundResult[] memory){ 
        require(winnersCalculated, 'Lottery888: Round winners not calculated');
		return roundsResults[roundNumber];
    }

	function getPastRoundWinners(uint256 numberOfRound) public view returns (RoundResult[] memory){ 
        require(numberOfRound != 0 && numberOfRound < roundNumber, 'Lottery888: Round not found');
		return roundsResults[numberOfRound];
    }
	
	function participate(uint256 ticketsNumber) public {
		require(roundEndTime() > blockTimestamp(), 'Lottery888: You can`t participate now');
		require(!roundFinished, 'Lottery888: Round finished');
		
		uint256 amount = ticketsNumber * 1e18; 
		require(ticketToken.balanceOf(_msgSender()) >= amount, 'Lottery888: Not enough 888 for participate');
		               
        ticketToken.safeTransferFrom(_msgSender(), address(this), amount); 
        
		for (uint256 index = 0; index < ticketsNumber; index++) {
			participants.push(_msgSender());
			playerNumbers[_msgSender()][roundNumber].push(participants.length - 1);
		} 
		uint256 playerCurrentEntrances = playerEntrances[_msgSender()][roundNumber];
		
		if (playerCurrentEntrances == 0) {
		    roundEntrances[roundNumber] ++;
		}
		
		playerEntrances[_msgSender()][roundNumber] = playerCurrentEntrances + ticketsNumber;
		
		
		emit Participate(roundNumber, _msgSender(), ticketsNumber);
    }

	function start(uint256 durationOfRound, uint256 rewardAmount, uint256 winnerPlacesNumber) public onlyOwner {  
		require(roundStartTime == 0 || winnersCalculated, 'Lottery888: Cann`t start now');
		roundStartTime = blockTimestamp();
		
		require(LINK.balanceOf(address(this)) >= fee, "Lottery888: Not enough LINK supply contract first");
		
		require(roundNextStartTime <= blockTimestamp(), 'Lottery888: Round start delayed');
		
		uint256 prevRewardBalance = rewardTokenBalance();
		require(rewardToken.balanceOf(_msgSender()) >= rewardAmount, 'Lottery888: Not enough reward tokens for start');
		rewardToken.safeTransferFrom(_msgSender(), address(this), rewardAmount);  
		roundWinFunds = rewardTokenBalance().sub(prevRewardBalance);
		
		require(durationOfRound != 0, 'Lottery888: Too low duration');
		roundDuration = durationOfRound;
		
		require(winnerPlacesNumber != 0 && winnerPlacesNumber <= 100, 'Lottery888: Too low win places');
		numberOfWinnerPlaces = winnerPlacesNumber;

		roundNumber++;
		randomResult = 0;
		roundFinished = false;
		winnersCalculated = false;
		
		delete participants;
	
		emit Start(roundNumber, roundStartTime, durationOfRound, roundWinFunds, winnerPlacesNumber);
    }

    function claim() public {  
		uint256 winnerBalance = winnerBalances[msg.sender];
        require(winnerBalance != 0, "Lottery888: nothing to claim");
        
        uint256 amount = winnerBalances[msg.sender];
        if (winnerBalance > rewardTokenBalance()) {
            amount = rewardTokenBalance();
        }
        winnerBalances[msg.sender] = 0;
        rewardToken.safeTransfer(msg.sender, amount);
        emit ClaimWin(msg.sender, amount);
    }
    
    function setRewardToken(address newRewardToken) external onlyOwner {
        require(roundStartTime == 0, "Lottery888: can't change while round started");
        rewardToken = IBEP20(newRewardToken); 
    }
    
    function setRoundNextStartTimeDelay(uint256 newDelay) external onlyOwner {
        roundNextStartTimeDelay = newDelay; 
    }
    
    function setTicketToken(address newTicketToken) external onlyOwner {
        require(roundStartTime == 0, "Lottery888: can't change while round started");
        ticketToken = IBEP20(newTicketToken); 
    }
    
    function burnTicketTokens() public onlyOwner {
        require(balanceOfTicketsTokens() != 0, "Lottery888: nothing to burn");
        ticketToken.burn(balanceOfTicketsTokens()); 
    }

	function numberOfTickets() public view returns (uint256) {
        return participants.length;
    }
    
    function balanceOfTicketsTokens() public view returns (uint256) {
        return ticketToken.balanceOf(address(this));
    }
    
    function rewardTokenBalance() public view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }
    
	function blockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

	function roundEndTime() public view returns (uint256) {
	    if (roundStartTime == 0) return 0;
        return roundStartTime + roundDuration;
    }
		   	
	function recoverTokens(address token, uint256 amount) external onlyOwner {
        IBEP20(token).safeTransfer(_msgSender(), amount);        
    }
   
	function recoverLinkTokens() public onlyOwner {
        LINK.transfer(_msgSender(), LINK.balanceOf(address(this)));        
    }	
   	
   	function balanceOfLinkTokens() public view returns (uint256) {
        return LINK.balanceOf(address(this));        
    }

	function toggleOperatorsList(address account) external onlyOwner {
		operatorsList[account] = !operatorsList[account];		
	}
}
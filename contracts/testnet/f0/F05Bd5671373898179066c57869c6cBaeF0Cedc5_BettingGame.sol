/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

library SafeMathChainlink {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);
  function approve(address spender, uint256 value) external returns (bool success);
  function balanceOf(address owner) external view returns (uint256 balance);
  function decimals() external view returns (uint8 decimalPlaces);
  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);
  function increaseApproval(address spender, uint256 subtractedValue) external;
  function name() external view returns (string memory tokenName);
  function symbol() external view returns (string memory tokenSymbol);
  function totalSupply() external view returns (uint256 totalTokensIssued);
  function transfer(address to, uint256 value) external returns (bool success);
  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}

contract VRFRequestIDBase {
  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed,
    address _requester, uint256 _nonce)
    internal pure returns (uint256)
  {
    return  uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

abstract contract VRFConsumerBase is VRFRequestIDBase {

  using SafeMathChainlink for uint256;

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(bytes32 _keyHash, uint256 _fee, uint256 _seed)
    internal returns (bytes32 requestId)
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, _seed));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, _seed, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash].add(1);
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
  constructor(address _vrfCoordinator, address _link) public {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

contract BettingGame is VRFConsumerBase {
    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.01 ether;
    uint256 public constant MAX_DEPOSIT_AMOUNT = 0.08 ether;

    uint256 private rewardFee = 3;
    uint256 private bettingFee = 5;

    address public adminWallet;
    
    uint256 internal fee;
    uint256 public randomResult;
  
    //Network: Rinkeby
    address constant VFRC_address = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f; // VRF Coordinator
    address constant LINK_address = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06; // LINK token
  
    //declaring 50% chance, (0.5*(uint256+1))
    uint256 constant half = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  
    //keyHash - one of the component from which will be generated final random value by Chainlink VFRC.
    bytes32 constant internal keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
  
    uint256 public gameId;
    uint256 public lastGameId;
    mapping(uint256 => Game) public games;
    mapping(address => bool) public managers;
    bool private _managerSet = false;

    struct Game{
        uint256 id;
        uint256 bet;
        uint256 seed;
        uint256 amount;
        uint256 winAmount;
        uint256 time;
        address payable player;
    }

    modifier onlyManager() {
        require(managers[msg.sender] == true, 'caller is not the manager');
        _;
    }

    modifier onlyVFRC() {
        require(msg.sender == VFRC_address, 'only VFRC can call this function');
        _;
    }
    
    event Withdraw(address manager, uint256 amount);
    event Received(address indexed sender, uint256 amount);
    event Result(uint256 id, uint256 bet, uint256 randomSeed, uint256 amount, address player, uint256 winAmount, uint256 randomResult, uint256 time);
    
    /**
    * Constructor inherits VRFConsumerBase.
    */
    constructor(address _admin) VRFConsumerBase(VFRC_address, LINK_address) public {
        fee = 0.005 * 10 ** 18; // 0.005 LINK
        managers[msg.sender] = true;
        adminWallet = _admin;
    }
    
    /* Allows this contract to receive payments */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function addManager(address _addr) external {
        require(managers[msg.sender] == true, 'Error, You are not allowed!');
        managers[_addr] = true;
    }

    function removeManager(address _addr) external {
        require(managers[msg.sender] == true, 'Error, You are not allowed!');
        managers[_addr] = false;
    }

    function initManager(address _addr) external {
        require(_managerSet == false, 'Error');
        managers[_addr] = true;
        _managerSet = true;
    }

    function fund() external payable {}
    
    /**
    * Taking bets function.
    * By winning, user 2x his betAmount.
    * Chances to win and lose are the same.
    */
    function game(uint256 bet, uint256 seed) public payable returns (bool) {
        require(msg.value>=MIN_DEPOSIT_AMOUNT, 'Error, msg.value must be >= 0.01 ether');
        require(msg.value<=MAX_DEPOSIT_AMOUNT, 'Error, msg.value must be <= 0.08 ether');
        
        //bet=0 is grey
        //bet=1 is orange
        require(bet<=1, 'Error, accept only 0 and 1');

        //vault balance must be at least equal to msg.value
        require(address(this).balance>=msg.value, 'Error, insufficent vault balance');
        
        //each bet has unique id
        games[gameId] = Game(gameId, bet, seed, msg.value, 0, 0, payable(msg.sender));
        
        //increase gameId for the next bet
        gameId = gameId+1;

        //seed is auto-generated by DApp
        getRandomNumber(seed);
        
        return true;
    }
    
    /** 
    * Request for randomness.
    */
    function getRandomNumber(uint256 userProvidedSeed) internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Error, not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
    * Callback function used by VRF Coordinator.
    */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;

        //send final random value to the verdict();
        verdict(randomResult);
    }
    
    /**
    * Send rewards to the winners.
    */
    function verdict(uint256 random) public payable onlyVFRC {
        //check bets from latest betting round, one by one
        for(uint256 i=lastGameId; i<gameId; i++){
            //reset winAmount for current user
            uint256 winAmount = 0;
            
            // send fee to the adminWallet 3%
            uint256 rewardFeeAmount = getRewardFee(games[i].amount);
            payable(adminWallet).transfer(rewardFeeAmount);

            //if user wins, then receives 2x of their betting amount
            if((random>=half && games[i].bet==1) || (random<half && games[i].bet==0)){
                uint256 bettingFeeAmount = getBettingFee(games[i].amount);
                winAmount = (games[i].amount - bettingFeeAmount) * 2;
                games[i].player.transfer(winAmount);
            }

            games[i].winAmount = winAmount;
            games[i].time = block.timestamp;
            emit Result(games[i].id, games[i].bet, games[i].seed, games[i].amount, games[i].player, games[i].winAmount, random, games[i].time);
        }
        //save current gameId to lastGameId for the next betting round
        lastGameId = gameId;
    }
    
    /**
    * Withdraw LINK from this contract (admin option).
    */
    function withdrawLink(uint256 amount) external onlyManager {
        require(LINK.transfer(msg.sender, amount), "Error, unable to transfer");
    }
    
    /**
    * Withdraw Ether from this contract (admin option).
    */
    function withdrawEther(uint256 amount) external payable onlyManager {
        require(address(this).balance>=amount, 'Error, contract has insufficent balance');
        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, amount);
    }

    function getRewardFee(uint256 amount) private view returns(uint256) {
        return amount * rewardFee / 100; 
    }

    function getBettingFee(uint256 amount) private view returns(uint256) {
        return amount * bettingFee / 100;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

    function changeUnlockBalance(
        address _address,
        uint _amount,
        uint _oldStep,
        uint _newStep
    ) external;

    function balanceOfUnlocks(address _addrress, uint _unlock) external view returns(uint);
    function burnExternal(uint256 amount, address _address) external;
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}



// AutomationCompatible.sol imports the functions from both ./AutomationBase.sol and
// ./interfaces/AutomationCompatibleInterface.sol
interface AutomationCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

contract Destribution is AutomationCompatibleInterface { 

    IERC20 public realToken;
    IERC20 public temporaryToken;
    
    address public owner;
    address public manager;
    uint public totalAllocation = 1000000000000000000000;
    
    struct Unlock {
        uint allocation;
        uint fee;
        bool deposited;
    }
    mapping(uint => Unlock) public unlocks; 

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // Chainlink
    uint public timeTrigger;
    uint public amoutnTrigger;
    uint public currentUnlock = 0; 
    mapping(address => bool) public autoReward;
    mapping(address => uint) public rewardListId;
    address[] public rewardListAddresses;

    //Functions for settings autorewards
    function addInAutoRewardList() public {
        rewardListAddresses.push(msg.sender);
        rewardListId[msg.sender] = rewardListAddresses.length - 1;
        autoReward[msg.sender] = true;
    }

    function removeInAutoRewardList() public {

        uint _index = rewardListId[msg.sender];

        require(_index < rewardListAddresses.length);
        rewardListAddresses[_index] = rewardListAddresses[rewardListAddresses.length-1];
        rewardListAddresses.pop();

        autoReward[msg.sender] = false;
    }

    //Functions for investors
    function getRealToken(uint _unlock) public {
        //Gets the part of real tokens
        uint _myPart = checkAllocation(msg.sender, _unlock);
        //Changes balances for an unlocks
        temporaryToken.changeUnlockBalance(msg.sender, _myPart,  _unlock, _unlock+1);
        //Burns temporary tokens
        temporaryToken.burnExternal(_myPart, msg.sender);
        //Sends the real tokens to an investor
        realToken.transfer(msg.sender, _myPart);
    }

    function checkAllocation(address _address, uint _unlock) public view returns(uint) {
        //Gets the allocation without fee SAWA
        uint _allocation = unlocks[_unlock].allocation - unlocks[_unlock].fee;
        //Gets the percent allocation in curent unlock  
        uint _perecentUnlockAllocation = _allocation / (totalAllocation/100);
        //Gets balance temporary tokens
        uint _balanceTemporaryToken = temporaryToken.balanceOfUnlocks(_address, _unlock);
        //Gets one percent temporary tokens and multiplies by a percentage 
        return  _balanceTemporaryToken/100 * _perecentUnlockAllocation;
    }

    //Chainlink functions
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        uint _count;
        upkeepNeeded = false;

        if(realToken.balanceOf(address(this)) > amoutnTrigger && unlocks[currentUnlock].deposited == false) {
            _count++;
        }

        uint[] memory indexes = new uint[](_count);
        uint indexCurrent;

        if(realToken.balanceOf(address(this)) > amoutnTrigger && unlocks[currentUnlock].deposited == false) {
            upkeepNeeded = true;
        } else {
            for (uint i = 0; i < rewardListAddresses.length; i++) {
                uint _allocation = checkAllocation(rewardListAddresses[i], currentUnlock);
                if(_allocation > 0) {
                    indexes[indexCurrent] = i;
                    indexCurrent++;
                    upkeepNeeded = true;
                }
            }

        }
        
        performData = abi.encode(indexes);
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata  performData ) external override {
        
        (uint[] memory indexes) = abi.decode(performData, (uint[]));

        if(unlocks[currentUnlock].deposited == false) {
            unlocks[currentUnlock].allocation = realToken.balanceOf(address(this));
            unlocks[currentUnlock].deposited = true;
        }

        if(indexes[0] != 0) {
            for (uint i = 0; i < indexes.length; i++) {
                address _address = rewardListAddresses[indexes[i]];
                //Gets the part of real tokens
                uint _myPart = checkAllocation(_address, currentUnlock);
                //Changes balances for an unlocks
                temporaryToken.changeUnlockBalance(_address, _myPart,  currentUnlock, currentUnlock+1);
                //Burns temporary tokens
                temporaryToken.burnExternal(_myPart, _address);
                //Sends the real tokens to an investor
                realToken.transfer(_address, _myPart);

            }
        }
    }

    //Admin Funstions
    function setAllocation(uint _amount, uint _unlock) public onlyOwner {
         unlocks[_unlock].allocation = _amount;
    }

    function setRealToken(IERC20 _address) public onlyOwner {
        realToken = _address;
    }

    function setTemporaryToken(IERC20 _address) public onlyOwner {
       temporaryToken = _address;
    }

    function setManager(address _address) public onlyOwner {
       manager = _address;
    }

    function setNamberWaitingUnclock(uint _number) public onlyOwner {
       currentUnlock = _number;
    }

    function setTotalAllocation(uint _amount) public onlyOwner {
       totalAllocation = _amount;
    }  

    function setAmoutnTrigger(uint _amount) public onlyOwner {
       amoutnTrigger = _amount;
    }  
    
    //Manager Funstions
    function setSawaFee(uint _fee, uint _unlock) public {
        require(msg.sender == manager);
        unlocks[_unlock].fee = _fee;
    }
}
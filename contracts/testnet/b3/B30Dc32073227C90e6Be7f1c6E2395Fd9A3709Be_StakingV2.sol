// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/IBEP20.sol";

/*
* @title Staking Contract
* @author lileddie.eth / Enefte Studio
*/
contract StakingV2 is Initializable {

    uint256 public stakeId;
    uint256 public totalStake;
    uint256 public MIN_STAKE_PERIOD;
    uint256 public MIN_STAKE_AMOUNT;
    bool public stakingOpen;
    address public tokenAddress;

    mapping(uint256 => Stake) public stakes;
    mapping(address => uint256[]) public ownersStakes;  
    uint256[] public stakeIDs;
    
    mapping(address => bool) private _dev;  
    address private _owner;

    struct Stake {
        address owner;
        uint256 value;
        uint256 time;
    }

    function createStake(uint256 _amount) external  {
        require(stakingOpen, "Staking not yet open");
        require(_amount >= MIN_STAKE_AMOUNT, "Stake too small");
        require(IBEP20(tokenAddress).balanceOf(msg.sender) >= _amount, "not enough funds");
        
        IBEP20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

        stakes[stakeId] = Stake(msg.sender, _amount, block.timestamp);
        ownersStakes[msg.sender].push(stakeId);
        stakeIDs.push(stakeId);
        totalStake += _amount;
        stakeId +=1;
    }

    function withdrawStake(uint256 _stakeID) external {
        require(stakes[_stakeID].value > 0, "No stake exists");
        require(stakes[_stakeID].owner == msg.sender, "Not your stake");

        uint256 _amount = stakes[_stakeID].value;
        IBEP20(tokenAddress).transfer(msg.sender, _amount);
        
        totalStake -= _amount;

        //Delete stake data
        delete stakes[_stakeID];
        
        // Delete the stake reference.
        for(uint256 i = 0;i<ownersStakes[msg.sender].length;i++){
            if(ownersStakes[msg.sender][i] == _stakeID){
                delete ownersStakes[msg.sender][i];
            }
        }
        for(uint256 i = 0;i<stakeIDs.length;i++){
            if(stakeIDs[i] == _stakeID){
                delete stakeIDs[i];
            }
        }

    }


    function toggleStaking() external onlyDevOrOwner {
        stakingOpen = !stakingOpen;
    }

    function setMinStakePeriod(uint256 _seconds) external onlyDevOrOwner {
        MIN_STAKE_PERIOD = _seconds;
    }

    function setMinStakeAmount(uint256 _amount) external onlyDevOrOwner {
        MIN_STAKE_AMOUNT = _amount;
    }

    function getStakes(address _ofWho) public view returns (Stake[] memory) {
        Stake[] memory myStakes = new Stake[](ownersStakes[_ofWho].length);
        for(uint256 i = 0;i<ownersStakes[_ofWho].length;i++){
            myStakes[i] = stakes[ownersStakes[_ofWho][i]];
        }
        return myStakes;
    }
    
    function distributeRewards() external payable onlyOwner {
        uint256 totalPayableStakes = 0;

        for(uint256 i = 0;i<stakeIDs.length;i++){ //for each stakeID
            if(stakes[stakeIDs[i]].value > 0){ //check the stake exists
            require(stakes[stakeIDs[i]].time - block.timestamp >= MIN_STAKE_PERIOD, "not staked long enough");
               /// if(stakes[stakeIDs[i]].time - block.timestamp >= MIN_STAKE_PERIOD){ //check the duration of stake is long enough
               ///     totalPayableStakes += stakes[stakeIDs[i]].value; //add to total payable stake sum
               /// }
            }
        }

       //uint256 perToken = address(this).balance / totalPayableStakes;

       //for(uint256 i = 0;i<stakeIDs.length;i++){ //for each stakeID
       //    if(stakes[stakeIDs[i]].value > 0){ //check the stake exists
       //        if(stakes[stakeIDs[i]].time - block.timestamp >= MIN_STAKE_PERIOD){ //check the duration of stake is long enough
       //            uint256 payableAmount = stakes[stakeIDs[i]].value * perToken; //calculate what the stake has earned
       //            payable(stakes[stakeIDs[i]].owner).transfer(payableAmount); //send the reward
       //        }
       //    }
       //}

    }
    

    /**
     * @dev notice if called by any account other than the dev or owner.
     */
    modifier onlyDevOrOwner() {
        require(owner() == msg.sender || _dev[msg.sender], "Ownable: caller is not the owner or dev");
        _;
    }  

    /**
     * @notice Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @notice Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @notice Adds a new dev role user
     */
    function addDev(address _newDev) external onlyOwner {
        _dev[_newDev] = true;
    }

    /**
     * @notice Removes address from dev role
     */
    function removeDev(address _removeDev) external onlyOwner {
        delete _dev[_removeDev];
    }

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }


    /**
    * @notice Initialize the contract and it's inherited contracts, data is then stored on the proxy for future use/changes
    *
    */
    function initialize() public initializer {  
        _owner = msg.sender;
        stakingOpen = true;
        stakeId = 1;
        MIN_STAKE_PERIOD = 300; //1209600;
        MIN_STAKE_AMOUNT = 1 ether; //10000 ether;
        tokenAddress = address(0xecE6953538E7D6A1E6fF334485416c16552ABF5F);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/Clones.sol)

pragma solidity ^0.8.0;

interface IBEP20 {

    /**  
     * @dev Returns the total tokens supply  
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}
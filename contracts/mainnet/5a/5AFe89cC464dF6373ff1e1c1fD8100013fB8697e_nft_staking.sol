//SPDX-License-Identifier: MIT
 /* solhint-disable */
pragma solidity 0.8.7;

// implementation of the abstract staking contract, adapted for NFT tokens (ERC721)

// the stake accounting contract
import "./abstract_staking.sol";

// NFT and token interfaces
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// OpenZeppelin access control
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// OpenZepelin pausable
import "@openzeppelin/contracts/security/Pausable.sol";

contract nft_staking is AccessControl, BaseStaking, Pausable{
    // Access control
    bytes32 public constant PAUSE_ROLE = keccak256("PAUSE_ROLE");   // Can pause the contract
    bytes32 public constant RATES_ROLE = keccak256("RATES_ROLE");   // Can update the rewards rate
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");   // Can update the rewards rate
    bytes32 public constant UPDATE_ROLE = keccak256("UPDATE_ROLE");   // Can update the rewards rate

    // the Nftstake object
    struct NftStake{
        address owner;          // The owner of the token
        uint256 lock;           // the time left before the token could be unstaked
        uint256 value;          // The number of stakes associated with this stake
    }

    struct NftStakePointer{
        address nft_contract;   //The contract of the nft
        uint256 tokenId;        // The tokenId of the staked token
    }

    // mapping between nft contract addr and token id to the staking data
    mapping (address => mapping (uint256 => NftStake)) public nft_stakes;

    // mapping between stakeholder addr, and an array containing its stakes
    mapping (address => NftStakePointer[]) public stakeholder_nft_stakes;

    // mapping between each nft kind and its stake value
    mapping (address => uint256) public nft_reward_rate;

    // NFT lock time
    uint256 public minimum_lock_period_time;

    // The address of the token used as settlement currency
    IERC20 public settlement_token;

    constructor(){
        // Setup the roles, and grant them to the contract creator
        _setupRole(PAUSE_ROLE, msg.sender);
        _setupRole(RATES_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(UPDATE_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // nft stakes value

        // Set the default nft lock time to 7 days
        minimum_lock_period_time = 7 days;

        // The ERC20 token used to pay the rewards. JRSC in this case.
        settlement_token = IERC20(0x3310e43dC1104D3CF5ABf81c9c2D08415AD9b092);

        // Make sure the contract starts paused
        _pause();
    }

    ///////////////////////
    //      Getters      //
    //////////////////////
    function get_last_checkpoint_index()
    public view
    returns (uint256)
    {
        return _get_last_checkpoint_index();
    }

    function get_unclaimed_rewards(address stakeholder)
    public view
    returns(uint256)
    {
        return _get_unclaimed_rewards(stakeholder);
    }

    function get_uncommitted_rewards(address stakeholder)
    public view
    returns(uint256, uint256)
    {
        (uint256 rewards, uint256 index) = _get_uncommitted_rewards(stakeholder);
        return (rewards, index);
    }

    function get_stakeholder_nft_stakes(address stakeholder)
    public view
    returns(NftStakePointer[] memory)
    {
        return stakeholder_nft_stakes[stakeholder];
    }

    ///////////////////////
    //      SETTERS      //
    //////////////////////
    function stake_nft(address contract_addr, uint256 TokenId)
    public whenNotPaused
    {
        // get the rewards rate from said nft, and if its 0, reject the stake
        uint256 value = nft_reward_rate[contract_addr];
        require(value != 0, "This NFT is not suitable for staking");

        // Get the token contract, and make it callable
        IERC721 nft_contract = IERC721(contract_addr);

        // try to transfer the nft from the user
        nft_contract.transferFrom(msg.sender, address(this), TokenId);

        // update the stakeholder stakes
        _stake(msg.sender, value);

        // Record this NFT on the nft_stakes registry, so we can keep track of it
        nft_stakes[contract_addr][TokenId].owner = msg.sender;
        nft_stakes[contract_addr][TokenId].lock = block.timestamp + minimum_lock_period_time;
        nft_stakes[contract_addr][TokenId].value = value;

        // Record this NFT in its owner nft_stake list, so the owner can keep track of its staked nft
        stakeholder_nft_stakes[msg.sender].push();
        uint256 index = stakeholder_nft_stakes[msg.sender].length - 1;

        // store the nft data
        stakeholder_nft_stakes[msg.sender][index].nft_contract = contract_addr;
        stakeholder_nft_stakes[msg.sender][index].tokenId = TokenId;
    }

    function unstake_nft(address contract_addr, uint256 TokenId)
    public whenNotPaused
    {
        NftStake memory nft_stake = nft_stakes[contract_addr][TokenId];

        // Sanity check, don't try to unstake tokens that are not staked
        require(nft_stake.owner != address(0), "This NFT is not staked");

        // Check the caller performing the unstake is the nft owner
        require(nft_stake.owner == msg.sender, "You are not the owner of this staked NFT");

        // check if the time lock has passed
        require(nft_stake.lock <= block.timestamp, "The staking lock has not expired yet");

        // perform the unstake
        _unstake_nft(contract_addr, TokenId, payable(msg.sender), false);
    }

    function safe_unstake_nft(address contract_addr, uint256 TokenId)
    public whenNotPaused
    {
        NftStake memory nft_stake = nft_stakes[contract_addr][TokenId];

        // Sanity check, don't try to unstake tokens that are not staked
        require(nft_stake.owner != address(0), "This NFT is not staked");

        // Check the caller performing the unstake is the nft owner
        require(nft_stake.owner == msg.sender, "You are not the owner of this staked NFT");

        // check if the time lock has passed
        require(nft_stake.lock <= block.timestamp, "The staking lock has not expired yet");

        // perform the unstake
        _unstake_nft(contract_addr, TokenId, payable(msg.sender), true);
    }

    function claim_reward(address stakeholder)
    public whenNotPaused
    {
        uint256 rewards =  _claim_reward(stakeholder);
        require(settlement_token.transfer(stakeholder, rewards), "ERC20 transfer failed while paying the rewards");
    }

    ///////////////////////
    //       HELPERS     //
    ///////////////////////
    function _unstake_nft(address contract_addr, uint256 TokenId, address payable _to, bool safe)
    private
   {
       NftStake memory nft_stake = nft_stakes[contract_addr][TokenId];

       // Sanity check, don't try to unstake tokens that are not staked
        assert(nft_stake.owner != address (0));

        // Get the token contract, and make it callable
        IERC721 nft_contract = IERC721(contract_addr);

        // remove the stakeholder's stakes, so they stop generating rewards rights
        _unstake(nft_stake.owner, nft_stake.value);

        // remove the stake entry from the global stake mapping
        delete nft_stakes[contract_addr][TokenId];
        // remove the stake from the stakeholder stakes array
        _remove_stakeholder_stake(nft_stake.owner, contract_addr, TokenId);

        // and lastly, transfer the nft to its destination
        // Nft generate a failing assertion if the transfer fails, so no need to check for return values
        if(safe == true){
            nft_contract.safeTransferFrom(address(this), _to, TokenId);
        }else{
            nft_contract.transferFrom(address(this), _to, TokenId);
        }
    }

    function _remove_stakeholder_stake(address stakeholder, address nft_contract, uint256 tokenId)
    private
    {
        uint256 length = stakeholder_nft_stakes[stakeholder].length;
        NftStakePointer[] memory result = new NftStakePointer[](length-1);

        uint256 k;
        uint256 i;
        for(; i < length; i++)
        {
            // Check if the current nft is the target nft;
            if(stakeholder_nft_stakes[stakeholder][i].nft_contract == nft_contract &&
                stakeholder_nft_stakes[stakeholder][i].tokenId == tokenId){
                // this is the entry we want to skip
            }else{
                result[k] = stakeholder_nft_stakes[stakeholder][i];
                k++;
            }
        }
        // Remove one item from the array
        stakeholder_nft_stakes[stakeholder].pop();

        for(i=0; i < length - 1; i++){
            stakeholder_nft_stakes[stakeholder][i] = result[i];
        }
    }

    function commit_stakeholder_rewards(address stakeholder)
    public whenNotPaused
    {
        _commit_stakeholder_rewards(stakeholder);
    }

    function create_new_checkpoint()
    public whenNotPaused
    returns(uint256)
    {
        return _create_new_checkpoint();
    }

    ///////////////////////
    //   ADMIN FUNCTIONS //
    ///////////////////////
    // Economy adjustments
    function update_reward_pool_per_block (uint256 new_reward_pool_per_block)
    public
    {
        // Check caller role
        require(hasRole(RATES_ROLE, msg.sender), "Caller does no have RATES_ROLE");

        _update_reward_pool_per_block (new_reward_pool_per_block);
    }

    function update_min_distance_between_checkpoints (uint256 new_distance)
    public
    {
        // Check caller role
        require(hasRole(RATES_ROLE, msg.sender), "Caller does no have RATES_ROLE");

        _update_min_distance_between_checkpoints (new_distance);
    }

    function change_nft_reward_rate(address nft_contract, uint256 rate)
    public
    {
        // Check caller role
        require(hasRole(RATES_ROLE, msg.sender), "Caller does no have RATES_ROLE");
        nft_reward_rate[nft_contract] = rate;
    }

    function change_minimum_lock_period_blocks(uint256 _minimum_lock_period_time)
    public
    {
        // Check caller role
        require(hasRole(RATES_ROLE, msg.sender), "Caller does no have RATES_ROLE");
        minimum_lock_period_time = _minimum_lock_period_time;
    }

    // Pause / unpause functions
    function pause()
    public
    {
        // Check caller role
        require(hasRole(PAUSE_ROLE, msg.sender), "Caller does no have PAUSE_ROLE");
        _pause();
    }

    function unpause()
    public
    {
        // Check caller role
        require(hasRole(PAUSE_ROLE, msg.sender), "Caller does no have PAUSE_ROLE");
        _unpause();
    }

    // Last resort functions to recover assets from this contract
    // Change the timelock of a staked nft
    function change_nft_stake_timelock(address contract_addr, uint256 TokenId, uint256 new_lock)
    public
    {
        // Check caller role
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");

        // Set the new timelock
        nft_stakes[contract_addr][TokenId].lock = new_lock;
    }

    // Unstake an ERC721 (NFT) token, skipping the time lock and owner check
    function admin_nft_unstake(address contract_addr, uint256 TokenId, address payable _to, bool safe)
    public
    {
        // Check caller role
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");

        // Sanity check, don't try to unstake tokens that are not staked
        require(nft_stakes[contract_addr][TokenId].lock != 0,
            "NFT is NOT staked. Use admin_nft_withdrawal");

        // perform the actual unstake
        _unstake_nft(contract_addr, TokenId, _to, safe);
    }

    // Transfer ERC721 (NFT) tokens from this contract.
    // DO NOT USE IT FOR STAKED TOKENS, use admin_nft_unstake instead. You can skip this check using force=true
    function admin_nft_withdrawal(address contract_addr, uint256 TokenId, address payable _to, bool force, bool safe)
    public
    {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");

        // Get the token contract, and make it callable
        IERC721 nft_contract = IERC721(contract_addr);

        // if force mode is not enable, check is the nft being trasferend is staked. In that case, revert.
        if (force == false)
        {
            require(nft_stakes[contract_addr][TokenId].owner == address(0),
                "NFT is staked. Use admin_nft_unstake, or force withdrawal");
        }

        if(safe == true){
            nft_contract.safeTransferFrom(address(this), _to, TokenId);
        }else{
            nft_contract.transferFrom(address(this), _to, TokenId);
        }
    }

    // Transfer ERC20 tokens from this contract
    function admin_token_withdrawal(address contract_addr, uint256 amount, address payable _to)
    public
    {
        // Check caller role
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");

        // Get the token contract, and make it callable
        IERC20 token_contract = IERC20(contract_addr);

        require(token_contract.transfer(_to, amount), "ERC20 transfer failed");
    }

    // update functions
    // Updates a stakeholder's record
    function admin_update_stakeholder(address[] calldata stakeholder, uint64[] calldata stake_amount,
        uint64[] calldata last_commit_checkpoint, uint128[] calldata committed_rewards)
    public
    {
        // Check caller role
        require(hasRole(UPDATE_ROLE, msg.sender), "Caller is not an updater");

        require (stakeholder.length == stake_amount.length, "length mismatch 1");
        require (stake_amount.length == last_commit_checkpoint.length, "length mismatch 2");
        require (last_commit_checkpoint.length == committed_rewards.length, "length mismatch 3");

        for (uint256 i; i < stakeholder.length; i++)
        {
            _admin_update_stakeholder( stakeholder[i],  stake_amount[i],  committed_rewards[i], last_commit_checkpoint[i]);
        }
    }

    // updates an existing checkpoint record. Use push for appending a new empity record, and pop for removing the last
    function admin_checkpoint_update(uint index, uint block_number, uint total_stakes, uint rewards_per_stake_block)
    public
    {
        // Check caller role
        require(hasRole(UPDATE_ROLE, msg.sender), "Caller is not an updater");

        _admin_checkpoint_update(index, block_number, total_stakes, rewards_per_stake_block);
    }

    // Ads a new empty record
    function admin_checkpoint_push(uint times)
    public
    {
        // Check caller role
        require(hasRole(UPDATE_ROLE, msg.sender), "Caller is not an updater");

        _admin_checkpoint_push(times);
    }

    // Removes the last record of checkpoints
    function admin_checkpoint_pop(uint times)
    public
    {
        // Check caller role
        require(hasRole(UPDATE_ROLE, msg.sender), "Caller is not an updater");

        _admin_checkpoint_pop(times);
    }

    // update the nft staking mapping, and the stakeholder's nft array
    function admin_add_nft_stakes(address[] calldata owner, address[] calldata nft_contract, uint256[] calldata tokenId,
        uint256 lock, uint256 value)
    external
    {
        // Check caller role
        require(hasRole(UPDATE_ROLE, msg.sender), "Caller is not an updater");

        require (owner.length == nft_contract.length, "length mismatch 1");
        require (nft_contract.length == tokenId.length, "length mismatch 2");

        for (uint256 i; i < owner.length; i++)
        {
            nft_stakes[nft_contract[i]][tokenId[i]].owner = owner[i];
            nft_stakes[nft_contract[i]][tokenId[i]].lock = lock;
            nft_stakes[nft_contract[i]][tokenId[i]].value = value;

            NftStakePointer memory tmp;
            tmp.nft_contract = nft_contract[i];
            tmp.tokenId = tokenId[i];
            stakeholder_nft_stakes[owner[i]].push() = tmp;
        }
    }
}

//SPDX-License-Identifier: MIT
 /* solhint-disable */
pragma solidity ^0.8.4;

// This abstract contract implements the accounting mechanism for an staking contract, using the reward pool method.
// This method distributes the totality of the reward pool, between all the stakeholders participating during the period
// each one receiving a reward directly proportional to its share.
//
// Is the job of the implementation contract the conversion between the value of the staked assets (and its custody)
// and the virtual proxy currency used for accounting, the number of stakes. Those stakes NOT not backed by any ERC20 token
//
// The rewards are also calculated in a proxy currency, as is the job of the implementation currency the conversion
// between this virtual currency, and the settlement currency (or currencies), and the transferring of said currency.
//
// Just to make it clear, this contract doesn't hold any assets, that is the work of the implementing contract
abstract contract BaseStaking {
    // Struct accounting each stakeholder stakes and rewards
    struct _Stake {
        uint256 stake_amount;             // The number of stakes this user has in the rewards pool
        uint256 committed_rewards;  // Committed  rewards, not yet reclaimed
        uint256 last_commit_checkpoint;     // The block of the latest computed reward
    }

    // struct containing the data of each checkpoint
    struct _Checkpoint {
        uint256 block_number;            // The block at which the checkpoint is
        uint256 total_stakes;            // The total amount of stakes participating of the reward pool
        uint256 rewards_per_stake_block; // The reward each stake gets each block
    }

    // Accounting storage
    // record of the stake of each stakeholder
    mapping (address => _Stake) public _stakeholders;
    // Checkpoint records changes on the reward distributions. Can not be created before an epoch elapses
    _Checkpoint[] public _pool_checkpoints;

    // Prevent the creation of a new checkpoint if this time has not passed since last checkpoint
    uint256 public _min_distance_between_checkpoints;
    // The reward pool to be distributed each block
    uint256 public _reward_pool_per_block;

    constructor() {
        // Populate the first checkpoint with the current block number, so evaluation doesn't continue up to genesis
        _pool_checkpoints.push();
        _pool_checkpoints[0].block_number = block.number;
    }

    ///////////////////////
    //      Getters      //
    //////////////////////
    function _get_last_checkpoint_index()
    internal view
    returns (uint256)
    {
        return _pool_checkpoints.length - 1;
    }

    function _get_unclaimed_rewards(address stakeholder)
    internal view
    returns(uint256)
    {
        return _stakeholders[stakeholder].committed_rewards;
    }

    function _get_uncommitted_rewards(address stakeholder)
    internal view
    returns(uint256, uint256)
    {
        // 0 - move data to memory
        _Stake memory stakeholder_data = _stakeholders[stakeholder];
        uint256 checkpoint_length = _pool_checkpoints.length;

        // 1 - Shortcirtuit, return if certain conditions are met.
        // If stakeholder has no active stakes, then no rewards will be generated, ShortCircuit!
        // This also trigger when a user hasn't made a stake yet
        if (stakeholder_data.stake_amount == 0){
            // Check if the latest checkpoint is old enough to allow a new checkpoint to be created
            if (_pool_checkpoints[checkpoint_length - 1].block_number + _min_distance_between_checkpoints >= block.number)
            {
                // No new checkpoint could be created, return the current checkpoint
                return (0, checkpoint_length - 1);
            }
            else
            {
                // The latest checkpoint is too old, return the index of the next one
                return (0, checkpoint_length);
            }
        }

        // If the latest commit of stakeholder is current checkpoint, and that checkpoint is not old enough to have
        // a newer checkpoint, then this stakeholder don't have any uncommitted rewards
        if (stakeholder_data.last_commit_checkpoint == checkpoint_length - 1 &&
            _pool_checkpoints[checkpoint_length - 1].block_number + _min_distance_between_checkpoints >= block.number) {
            // the last checkpoint of the user is the current checkpoint, and no new checkpoint could be created
            return (0, checkpoint_length - 1);
        }

        // Start calculation the unconsolidated rewards
        uint256 pending_rewards;                                // The reward amount that hasn't been committed yet
        uint256 i = stakeholder_data.last_commit_checkpoint;    // checkpoint iterator
        uint256 distance;                                       // distance between checkpoints.

        // Iterate from the last stakeholder commited checkpoint, to the current checkpoint
        while(i < checkpoint_length - 1){
            // Calculate the rewards generated during this period
            distance = _pool_checkpoints[i+1].block_number - _pool_checkpoints[i].block_number;
            pending_rewards += stakeholder_data.stake_amount * distance * _pool_checkpoints[i].rewards_per_stake_block;

            // advance to the next checkpoint
            i++;
        }
        // To this point, we have computed rewards until the last checkpoint

        // Check if the last checkpoint is old enought to have a checkpoint after it
        if(_pool_checkpoints[i].block_number + _min_distance_between_checkpoints < block.number)
        {
            // The last checkpoint is too old, and a new checkpoint can be created. Compute rewards untill current
            // Block number, where a new checkpoint will be placed if rewards were to be claimed
            distance = block.number - _pool_checkpoints[i].block_number;
            pending_rewards += stakeholder_data.stake_amount * distance * _pool_checkpoints[i].rewards_per_stake_block;

            // return the result, and the index of the next checkpoint, as it should be created
            return(pending_rewards, i + 1);
        }
        // The latest block is not old enough to have a checkpoint behind it
        return(pending_rewards, i);
    }

    ///////////////////////
    //      SETTERS      //
    //////////////////////
    // Add stakes to a stakeholder's balance, and the pool
    // Creates a checkpoint and commits pending rewards
    function _stake(address stakeholder, uint256 amount)
    internal
    {
        // 0 - Sanity checks
        // Sanity check, make sure we are not adding 0 stakes
        require(amount > 0, "You can not stake 0 stakes");

        // 1 - Create a new checkpoint if needed, or get the index of the latest
        uint256 index = _create_new_checkpoint();

        // 2 - Commit the rewards of the stakeholder
        _commit_stakeholder_rewards(stakeholder);

        // 3 - update the stakeholder record
        // Increase the stakeholder's stake by its index.
        _stakeholders[stakeholder].stake_amount += amount;

        // 4 - update the pool state
        // Update the pool size
        _pool_checkpoints[index].total_stakes += amount;
        // Calculate the new rate
        _pool_checkpoints[index].rewards_per_stake_block = _reward_pool_per_block / _pool_checkpoints[index].total_stakes;

        // Sanity check, enforce contract invariants
        assert(_stakeholders[stakeholder].last_commit_checkpoint == _pool_checkpoints.length - 1);
    }

    // Removes stakes to a stakeholder's balance, and the pool
    // Creates a checkpoint and commits pending rewards
    function _unstake(address stakeholder, uint256 amount)
    internal
    {
        // 0 - Sanity checks
        // Make sure the unstake amount is greater than 0
        require(amount > 0, "You can not unstake 0 stakes");
        // Prevent unstaking more stakes than the user has
        require(_stakeholders[stakeholder].stake_amount >= amount,
            "You can not unstake more than your stake");

        // 1 - Create a new checkpoint if needed, or get the index of the latest
        uint256 index = _create_new_checkpoint();

        // 2 - Commit the rewards of the stakeholder
        _commit_stakeholder_rewards(stakeholder);

        // 3 - update the stakeholder record
        // Decrease the stakeholder's stake by its index.
        _stakeholders[stakeholder].stake_amount -= amount;

        // 4 - Update the pool status
        // Update the pool size
        _pool_checkpoints[index].total_stakes -= amount;
        // Calculate the new reward rate
        // if the pool is empity, prevent division by 0
        if(_pool_checkpoints[index].total_stakes == 0){
            _pool_checkpoints[index].rewards_per_stake_block = 0;
        }else{
            _pool_checkpoints[index].rewards_per_stake_block = _reward_pool_per_block / _pool_checkpoints[index].total_stakes;
        }

        // Sanity check, enforce contract invariants
        assert(_stakeholders[stakeholder].last_commit_checkpoint == _pool_checkpoints.length - 1);
    }

    function _claim_reward(address stakeholder)
    internal
    returns(uint256)
    {
        // 0 - Sanity checks

        // 1 - Create a new checkpoint if needed, or get the index of the latest
        _create_new_checkpoint();

        // 2 - Commit the stakeholder rewards
        _commit_stakeholder_rewards(stakeholder);

        // 3 - gets stakeholders rewards, and reset them back to 0
        uint256 rewards = _stakeholders[stakeholder].committed_rewards;
        _stakeholders[stakeholder].committed_rewards = 0;

        // 4 - Sanity check, enforce contract invariants
        assert(rewards > 0);
        assert(_stakeholders[stakeholder].last_commit_checkpoint == _pool_checkpoints.length - 1);

        // 5 - return the reward amount to the calling fn, which is in charge of actually paying the rewards.
        return rewards;
    }

    ///////////////////////
    //       HELPERS     //
    ///////////////////////
    // Creates a new checkpoint at the current block, and copies fields from previous checkpoints
    function _create_new_checkpoint()
    internal
    returns(uint256)
    {
        uint256 last_checkpoint_index = _pool_checkpoints.length - 1;
        // If latest checkpoint is newer than min_distance_between_checkpoints, don't create a new checkpoint
        // returns the index of the last checkpoint index
        if (_pool_checkpoints[last_checkpoint_index].block_number + _min_distance_between_checkpoints >= block.number){
            return last_checkpoint_index;
        }

        // Copy values from last checkpoint, with the exception of block number
        _pool_checkpoints.push();

        _pool_checkpoints[last_checkpoint_index + 1].block_number = block.number;
        _pool_checkpoints[last_checkpoint_index + 1].total_stakes = _pool_checkpoints[last_checkpoint_index].total_stakes;
        _pool_checkpoints[last_checkpoint_index + 1].rewards_per_stake_block = _pool_checkpoints[last_checkpoint_index].rewards_per_stake_block;

        // Return the index of the newly created checkpoint
        return last_checkpoint_index + 1;
    }

    function _commit_stakeholder_rewards(address stakeholder)
    internal
    {
        // get the uncommitted rewards amount
        (uint256 pending, uint256 checkpoint) = _get_uncommitted_rewards(stakeholder);

        // update stakeholder's data
        _stakeholders[stakeholder].committed_rewards += pending;
        _stakeholders[stakeholder].last_commit_checkpoint = checkpoint;
    }

    ///////////////////////
    //   ADMIN FUNCTIONS //
    ///////////////////////
    function _update_reward_pool_per_block (uint256 new_reward_pool_per_block)
    internal
    {
        // Get last checkpoint index or create a new one
        uint256 index = _create_new_checkpoint();

        // store the new rate
        _reward_pool_per_block = new_reward_pool_per_block;

        // Calculate the new reward rate, prevent division by 0 when the pool empties
        uint256 total_stakes = _pool_checkpoints[index].total_stakes;
        if(total_stakes > 0){
            _pool_checkpoints[index].rewards_per_stake_block = _reward_pool_per_block / total_stakes;
        }else{
            _pool_checkpoints[index].rewards_per_stake_block = 0;
        }
    }

    //_min_distance_between_checkpoints
    function _update_min_distance_between_checkpoints (uint256 new_distance)
    internal
    {
        _min_distance_between_checkpoints = new_distance;
    }

    /////////////////////////
    // Migration functions //
    ////////////////////////
    function _admin_update_stakeholder(address stakeholder, uint256 stake_amount, uint256 committed_rewards,
        uint256 last_commit_checkpoint)
    internal
    {
        _stakeholders[stakeholder].stake_amount = stake_amount;
        _stakeholders[stakeholder].committed_rewards = committed_rewards;
        _stakeholders[stakeholder].last_commit_checkpoint = last_commit_checkpoint;
    }

    function _admin_checkpoint_update(uint index, uint block_number, uint total_stakes, uint rewards_per_stake_block)
    internal
    {
        _pool_checkpoints[index].block_number = block_number;
        _pool_checkpoints[index].total_stakes = total_stakes;
        _pool_checkpoints[index].rewards_per_stake_block = rewards_per_stake_block;
    }

    function _admin_checkpoint_push(uint times)
    internal
    returns(uint256)
    {
        for(uint i; i < times; i++){
            _pool_checkpoints.push();
        }

        return _pool_checkpoints.length;
    }

    function _admin_checkpoint_pop(uint times)
    internal
    returns(uint256)
    {
        for(uint i; i < times; i++){
            _pool_checkpoints.pop();
        }

        return _pool_checkpoints.length;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: --🌲--

pragma solidity ^0.8.0;

// Get a link to treedefi collectibles BEP721
interface NFT {
  // `Tree` keeps information realted to specific tree    
  struct Tree {
    uint256 treeId;
    uint256 treeName;
    uint256 longitude;
    uint256 latitude;
    uint256 carbonDioxideOffset;
  }

  // returns `Tree` data for given id
  function _treeData(
    uint256 tokenId
  ) external view returns (Tree memory treeData);

  // transfer tree
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

}

// Get a link to Green Bond BEP20 smart contract
interface IGreenBond {
    
    // Mint new tokens
    function mintGreenBond(
        address user,
        uint256 amount
    ) external returns (bool success);
    
    // Burn existing tokens
    function burnGreenBond(
        address user,
        uint256 amount
    ) external returns (bool success);
    
}

/**
   * @title Treedefi collectibles Staking Version 1.0
   *
   * @author treedefi
  */
contract NftreeStaking {

  // Address of treedefi owner
  address public owner;
  
  // Address of TCO2 token
  address public immutable tco2;
  
  // Link to treedefi collectibles
  address public immutable nftContract;
  
  // Fee for green bond registration
  uint256 public greenBondFee;
  
  // Harvest fee
  uint256 public harvestFee;

  // Total carbon credits generated
  uint256 public totalCarbonCredits;

  // `Stake` records stake data
  struct Stake {
    uint256 tokenId;
    uint32 stakedOn;
    uint256 claimedGeneration;
  }
  
  // Mapping from address to userStakes
  mapping (address => Stake[]) public userStakes;

  // Mapping from treeId to tokenIndex
  mapping (uint256 => uint256) public tokenIndex;

  // Mapping from treeId to greenbond supply generated from co2 offset
  mapping(uint256 => uint256) public treeSupply;

  // `Conversion` records data of green bond to carbon credit conversion
  struct Conversion {
    uint256 treeId;  
    uint256 amount;
    uint256 time;
  }

  // Mapping from address to `Conversion` data
  mapping(address => Conversion[]) public carbonCreditConverted;
  
  /**
	   * @dev Fired in transferOwnership() when ownership is transferred
	   *
	   * @param _previousOwner an address of previous owner
	   * @param _newOwner an address of new owner
	  */
  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

  /**
	   * @dev Fired in stake() and unstake()
	   *
	   * @param _by an address of staker
	   * @param _tokenId Id of token that is staked/unstaked
     * @param _isStaked (true = staked, false = unstaked)
	  */
  event Staked(address indexed _by, uint256 _tokenId, bool _isStaked);

  /**
	   * @dev Fired in harvest()
	   *
	   * @param _by an address of harvestor
	   * @param _tokenId Id of token for which tco2 are being harvested
     * @param _amount haevested token amount
	  */
  event Harvested(address indexed _by, uint256 _tokenId, uint256 _amount);

  /**
	   * @dev Creates/deploys treedefi collectibles Staking Version 1.0
	   *
	   * @param nftree_ address of treedefi collectibles
	   * @param tco2_ address of tco2 token
     * @param owner_ address of owner
	  */
  constructor(address nftree_, address tco2_, address owner_) 
  { 
	  // setup smart contract internal state
    nftContract = nftree_;
    tco2 = tco2_;
    owner = owner_;
  }

  /**
	   * @dev Transfer ownership to given address
	   *
	   * @notice restricted function, should be called by owner only
	   * @param newOwner_ address of new owner
	  */
  function transferOwnership(address newOwner_) external {
    
    require(msg.sender == owner, "Only owner can transfer ownership");

    // Update owner address
    owner = newOwner_;
    
    // Emits an event
    emit OwnershipTransferred(msg.sender, newOwner_);
    
  }
  
  /** 
     * @dev Sets fee for green bond generation
     *
     * @notice restricted access function 
     * @param fee_ unsigned integer defines fee
    */
  function setGreenBondFee(
     uint256 fee_
  ) 
    external 
  {
      
    require(
      msg.sender == owner,
      "Treedefi: Only Owner can set fee"
    );
      
    greenBondFee = fee_;
     
  }
  
  /** 
     * @dev Sets harvest fee for green bond generation
     *
     * @notice restricted access function 
     * @param fee_ unsigned integer defines fee
    */
  function setHarvestFee(
     uint256 fee_
  ) 
    external 
  {
      
    require(
      msg.sender == owner,
      "Treedefi: Only Owner can set fee"
    );
      
    harvestFee = fee_;
     
  }

  /** 
     * @dev Stake trees
     *
     * @param tokenId_ token Id of given trees
    */
  function stakeBatch(uint256[] memory tokenId_) external {

    for(uint i; i < tokenId_.length; i++) {
      stake(tokenId_[i]);
    }

  }

  /** 
     * @dev Stake tree
     *
     * @param tokenId_ token Id of given tree
    */
  function stake(uint256 tokenId_) public {
    
    // Transfer tree to staking contract
    NFT(nftContract).transferFrom(msg.sender, address(this), tokenId_);

    // Get index to be assigned
    uint256 _index = userStakes[msg.sender].length;

    // Assign index to given tokenId
    tokenIndex[tokenId_] = _index;

    // Record user stakedata
    userStakes[msg.sender].push(Stake(tokenId_, uint32(block.timestamp), 0));

    // Emits an event
    emit Staked(msg.sender, tokenId_, true);
  } 

  /** 
     * @dev Unstake trees
     *
     * @param tokenId_ token Id of given trees
    */
  function unstakeBatch(uint256[] memory tokenId_) external payable {

    for(uint i; i < tokenId_.length; i++) {
      unstake(tokenId_[i]);
    }

  }

  /** 
     * @dev Unstake tree
     *
     * @param tokenId_ token Id of given tree
    */
  function unstake(uint256 tokenId_) public payable {

    // Get index of given token
    uint256 _index = tokenIndex[tokenId_];

    require(userStakes[msg.sender][_index].tokenId == tokenId_, "Access denied");

    // Transfer tree from staking contract to user
    NFT(nftContract).transferFrom(address(this), msg.sender, tokenId_);

    // Harvest pending rewards
    harvest(_index);

    // Get last index
    uint256 _lastIndex = userStakes[msg.sender].length - 1;

    // Get last token Id
    uint256 _lastTokenId = userStakes[msg.sender][_lastIndex].tokenId;

    // Assign new index to last tokenId
    tokenIndex[_lastTokenId] = _index;

    // Delete index of unstake tokenId 
    delete tokenIndex[tokenId_];

    // Update stake data
    userStakes[msg.sender][_index] = userStakes[msg.sender][_lastIndex];

    // Remove element from stake data
    userStakes[msg.sender].pop();

    // Emits an event
    emit Staked(msg.sender, tokenId_, false);
  }

  /** 
     * @dev Returns number of stakes for given address
     *
     * @param staker_ address of staker
    */
  function getStakeLength(address staker_) external view returns(uint256) {
    return userStakes[staker_].length; 
  }

  /** 
     * @dev Harvest tco2 tokens
    */
  function harvestAll() external payable {
    
    uint256 _length = userStakes[msg.sender].length;

    for(uint i; i < _length; i++) {
      harvest(i);
    }

  }

  /** 
     * @dev Harvest tco2 tokens for given range
     *
     * @param from_ range starting index
     * @param to_ range ending index
    */
  function harvestRange(uint256 from_, uint256 to_) external payable {
    
    for(uint i = from_; i <= to_; i++) {
      harvest(i);
    }

  }

  /** 
     * @dev Harvest tco2 tokens
     *
     * @param index_ staking index for which tokens are going to be harvested
    */
  function harvest(uint256 index_) public payable {

    // Calculate unclaimed generation
    uint256 _unclaimed = unclaimedGeneration(msg.sender, index_);
    
    // Calculate tco2 amount
    uint256 _tco2Amount = _unclaimed * 1e15;

    // Calculate fee
    uint256 _fee = (greenBondFee * _tco2Amount) / 1e18;

    // Tansfer fee to owner
    payable(owner).transfer(_fee);

    // Deduct harvest fee
    _tco2Amount = (_tco2Amount * harvestFee) / 100;

    // Transfer harvested amount to user
    IGreenBond(tco2).mintGreenBond(msg.sender, _tco2Amount);

    // Update stake data
    userStakes[msg.sender][index_].claimedGeneration += _unclaimed;

    // Add minted amount to given tree
    treeSupply[userStakes[msg.sender][index_].tokenId] += _tco2Amount;

    // Emits an event
    emit Harvested(msg.sender, userStakes[msg.sender][index_].tokenId, _tco2Amount);

  }

  /** 
     * @dev Calculates carbon offset generated for given index
     *
     * @param staker_ address of staker
     * @param index_ staking index
    */
  function calculateGeneration(
    address staker_,
    uint256 index_
  )
    public
    view
    returns (uint256)
  {

    uint256 _treeId = userStakes[staker_][index_].tokenId;

    return ((block.timestamp - userStakes[staker_][index_].stakedOn) * NFT(nftContract)._treeData(_treeId).carbonDioxideOffset) / 31536000;
  
  }

  /** 
     * @dev Calculates unclaimed carbon offset for given index
     *
     * @param staker_ address of staker
     * @param index_ staking index
    */
  function unclaimedGeneration(address staker_, uint256 index_) public view returns(uint256) {
    return calculateGeneration(staker_, index_) - userStakes[staker_][index_].claimedGeneration;
  }
  
  /** 
     * @dev Calculates additional harvest fee for given index
     *
     * @notice Buffer time of 600 seconds is added for calculating real-time generation
     *
     * @param staker_ address of staker
     * @param index_ staking index
    */
  function calculateHarvestFee(
    address staker_,
    uint256 index_
  )
    external
    view
    returns (uint256)
  {
    // Get tree Id
    uint256 _treeId = userStakes[staker_][index_].tokenId;
    
    // Calculate real time generation with 600 seconds buffer added
    uint256 _generation = (((block.timestamp + 600) - userStakes[staker_][index_].stakedOn) * NFT(nftContract)._treeData(_treeId).carbonDioxideOffset) / 31536000;

    // Calculate unclaimed amount
    uint256 _unclaimed = _generation - userStakes[staker_][index_].claimedGeneration;

    // Calculate and return additional harvest fee
    return (_unclaimed * 1e15 * greenBondFee) / 1e18;
  }

  /** 
     * @dev Returns carbon credit conversion count of given address 
     *
     * @param converter_ address of converter
    */
  function getConversionLength(address converter_) external view returns(uint256) {
    return carbonCreditConverted[converter_].length; 
  }

  /** 
     * @dev Burn Green Bond and assign Carbon Credit to user, decreasing the total supply
     * 
     * @param amount_ array defines amount of green bonds are going to be converted
     * @param treeId_ array defines tokenId of tree from which carbon credits are going to be generated  
     * @return success_ bool defines status of function execution  
     */
  function convertGreenBondToCarbonCreditBatch(
    uint256[] memory amount_,
    uint256[] memory treeId_
  ) 
    public
    returns(bool success_)
  {
  
    require(
        amount_.length == treeId_.length,
        "Treedefi: Invalid input data"
    );
    
    uint256 _length = amount_.length;
    
    for(uint i; i < _length; i++){
        // Burn green bonds and generate carbon credits
        convertGreenBondToCarbonCredit(
            amount_[i],
            treeId_[i]
        );    
    }
    
    return true;
    
  }
  
  /** 
     * @dev Burn Green Bond and assign Carbon Credit to user
     * 
     * @param amount_ defines amount of green bonds are going to be converted
     * @param treeId_ defines tokenId of tree from which carbon credits are going to be generated  
    */
  function convertGreenBondToCarbonCredit(
    uint256 amount_,
    uint256 treeId_
  ) 
    public 
  {
      
     require(
       amount_ > 0,
       " Treedefi: Please provide valid amount"
     );
     
     require(
       amount_ <= treeSupply[treeId_],
       " Treedefi: Provided value exceeds green bond supply of given tree "
     );
     
     // Burn green bonds of given address
     IGreenBond(tco2).burnGreenBond(msg.sender, amount_);

     // Remove burned amount from given tree
     treeSupply[treeId_] -= amount_;
     
     // Increment carbon credits conversion counter
     totalCarbonCredits += amount_;
     
     // Read `Conversion`
     Conversion memory _conversion = Conversion(treeId_, amount_, block.timestamp);
     
     // Record `Conversion` for given address
     carbonCreditConverted[msg.sender].push(_conversion);
  }

}
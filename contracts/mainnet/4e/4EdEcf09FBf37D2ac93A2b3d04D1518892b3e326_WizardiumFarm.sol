/**
 *Submitted for verification at BscScan.com on 2022-01-02
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-31
*/

//SPDX-License-Identifier: GPLv3

pragma solidity >=0.7.0;

/*
$$\      $$\ $$\                                    $$\ $$\                         
$$ | $\  $$ |\__|                                   $$ |\__|                        
$$ |$$$\ $$ |$$\ $$$$$$$$\ $$$$$$\   $$$$$$\   $$$$$$$ |$$\ $$\   $$\ $$$$$$\$$$$\  
$$ $$ $$\$$ |$$ |\____$$  |\____$$\ $$  __$$\ $$  __$$ |$$ |$$ |  $$ |$$  _$$  _$$\ 
$$$$  _$$$$ |$$ |  $$$$ _/ $$$$$$$ |$$ |  \__|$$ /  $$ |$$ |$$ |  $$ |$$ / $$ / $$ |
$$$  / \$$$ |$$ | $$  _/  $$  __$$ |$$ |      $$ |  $$ |$$ |$$ |  $$ |$$ | $$ | $$ |
$$  /   \$$ |$$ |$$$$$$$$\\$$$$$$$ |$$ |      \$$$$$$$ |$$ |\$$$$$$  |$$ | $$ | $$ |
\__/     \__|\__|\________|\_______|\__|       \_______|\__| \______/ \__| \__| \__|
                                                                                    
                                                                                    
                                                                                    
                   $$$$$$\   $$$$$$\  $$\      $$\ $$$$$$$$\                        
                  $$  __$$\ $$  __$$\ $$$\    $$$ |$$  _____|                       
                  $$ /  \__|$$ /  $$ |$$$$\  $$$$ |$$ |                             
                  $$ |$$$$\ $$$$$$$$ |$$\$$\$$ $$ |$$$$$\                           
                  $$ |\_$$ |$$  __$$ |$$ \$$$  $$ |$$  __|                          
                  $$ |  $$ |$$ |  $$ |$$ |\$  /$$ |$$ |                             
                  \$$$$$$  |$$ |  $$ |$$ | \_/ $$ |$$$$$$$$\                        
                   \______/ \__|  \__|\__|     \__|\________|                       
                                                                                    
                                                                                    
                                                                                   
*/

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
  ) internal pure returns (uint256) {
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
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
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

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface WizzERC20 {
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);    
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface WizzERC721 {
    function ownerOf(uint256 _tokenID) external returns(address);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function WalletOfOwner(address _owner) external view returns(uint256[] memory allWalletHeros);
}

interface WizzFVesting {
    function farmerWithdraw(address farmer) external;
    function checkFarmingReturns(address farmer) external view returns(uint256 total, uint256 totalWithdrawable, uint256 nextClaimTime);
    function addVestment(address farmer, uint256 _totalAmount, uint256[] memory _timestamps, uint256[] memory _percentages) external;
}

library WizzHelper {
    function findHeroBase(uint256 _mintIdx) public pure returns (uint256){
        if (_mintIdx < 2500){
            return 0;
        }else if (_mintIdx < 5000){
            return 0;
        }else if (_mintIdx < 7500){
            return 0;
        }else if (_mintIdx < 10000){
            return 0;
        }else if (_mintIdx < 11500){
            return 1;
        }else if (_mintIdx < 13000){
            return 1;
        }else if (_mintIdx < 14500){
            return 1;
        }else if (_mintIdx < 15250){
            return 2;
        }else if (_mintIdx < 16000){
            return 2;
        }else{
            return 10;
        }
    }

    function getNth(uint256 number, uint256 nth) public pure returns (uint256, uint256) { 
        uint256 _divsor = 10**nth; 
        uint256 cnt = 0;
        while (number >= _divsor*10) {
            number /= 10;
            cnt+=1;
        }
        uint256 _bSub = number;
        number /= 10;
        return ((_bSub - (number*10)), (cnt+nth));
    }
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

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
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
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

contract WizardiumFarm is Ownable, VRFConsumerBase {

    event FarmHarvested(address indexed owner, uint256 heroID, uint256 worldID, bool expeditionSucess, uint256 tokenReward, uint256 levelReward);
    event FarmingStart(address indexed owner, uint256 heroID, uint256 worldID, uint256 timestamp);

    // Wizardium addresses
    address WIZZY = 0x9E327B55D5791bd1b08222F7886d7a82EB11aCEE;
    address VESTING = 0xC0806893CC86e54D204e09cE16476c773c70074C;
    address NFT = 0xE125e9abE7Fc62e484C5694b39B4a19ef88BE641;

    struct World {
        uint256 entryPrice;
        uint256 minLevel;
        uint256 chance;
        uint256 lockTime;
        mapping(uint256 => uint256) requirements;
        bool active;
    }
    mapping(uint256 => World) private worlds;
    uint256[] private allWorlds;
    uint256 internal worldTracker = 1;

    struct Hero {
        uint256 lockTS;
        uint256 worldRef;
        uint256 farmingTimes;
        uint256 level;
        address owner;
        mapping(uint256 => uint256) props;
        bool initiated;
    }
    mapping(uint256 => Hero) heros;
    uint256[] private allHeros;

    struct Potion {
        string name;
        uint256 refilBy;
        uint256 maxFill;
        uint256 price;
        uint256[] baseFill;
    }
    mapping(uint256 => Potion) private potions;
    uint256[] private allPotions;
    uint256 internal potionTracker;

    struct Reward {
        bool isSucessfull;
        uint256 tokensReward;
        uint256 levelReward;
    }

    uint256 priceBasis = 1 ether;
    uint256 private mainRandomness;
    uint256 private randomCallerCounter;
    uint256 private randomTracker;
    uint256 private currentRandomLimit = 30;
    uint256 private randomFrequency = 40;

    uint256[] private farmingTimestamps;
    uint256[] private farmingPercentages;

    bytes32 internal keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    uint256 internal fee = 0.2 * 10 ** 18; // 0.1 LINK (Varies by network)

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // VRF Coordinator, LINK token, 
    constructor()VRFConsumerBase(0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31,0x404460C6A5EdE2D891e8297795264fDe62ADBB75){
            uint256[] memory dist = new uint256[](3);
            dist[0] = 80;
            dist[1] = 100;
            dist[2] = 120;
            createPotion("Luck",25,200,15,dist);
            createPotion("Energy",35,10000,20,dist);
            createPotion("Health",20,500,30,dist);
            dist[0] = 25;
            dist[1] = 25;
            dist[2] = 25;
            createWorld(10,0,5,360,dist);
        }

    function setRandomFrequency(uint256 _newRandomFrequency) external onlyOwner {
        randomFrequency = _newRandomFrequency;
    }


    

    function altFarmingTS() internal view returns(uint256[] memory){
        uint256[] memory _newFarmingTimestamps = new uint256[](farmingTimestamps.length);
        for(uint256 i=0; i<farmingTimestamps.length; i++){
            _newFarmingTimestamps[i] = block.timestamp + farmingTimestamps[i];
        }  
        return _newFarmingTimestamps;
    }

    function onERC721Received(address , address , uint256 , bytes calldata ) public pure returns(bytes4){

        return(IERC721Receiver.onERC721Received.selector);
    }

    // function returns true if hero has been initiated
    function checkHeroInitiation(uint256 heroID) public view returns(bool){

        return(heros[heroID].initiated);
    }

    function getEntryPrice(uint256 world) public view returns(uint256 _entryPrice){

        _entryPrice = worlds[world].entryPrice;
    }


    function getToken20(address sender, uint256 amount) internal returns(bool) {
        amount = (amount*99)/100;
        require(WizzERC20(WIZZY).allowance(sender, address(this)) >= amount, "Need to approve us for WIZZY to farm");
        require(WizzERC20(WIZZY).transferFrom(sender, address(this), amount), "Need to pay us WIZZY to go farming");
        return true;
    }

    function getToken721(address sender, uint256 tokenID) internal returns(bool) {
        require(WizzERC721(NFT).ownerOf(tokenID) == sender, "Cannot go farming with a hero that is not yours.");
        require(WizzERC721(NFT).getApproved(tokenID) == address(this), "You need to approve us to farm your NFT");
        WizzERC721(NFT).safeTransferFrom(sender, address(this), tokenID);
        return true;
    }

    function sendToken721(address reciever, uint256 tokenID) internal returns(bool) {
        require(WizzERC721(NFT).ownerOf(tokenID) == address(this), "This hero is not farming");
        WizzERC721(NFT).safeTransferFrom(address(this), reciever, tokenID);
        return true;
    }

    function initiateHero(uint256 heroID) internal {
        uint256 heroBase = WizzHelper.findHeroBase(heroID);
        for(uint256 i=0; i<allPotions.length; i++){
            heros[heroID].props[allPotions[i]] = potions[allPotions[i]].baseFill[heroBase];
        }
        heros[heroID].initiated = true;
        heros[heroID].level = 0;
        heros[heroID].farmingTimes = 0;
    }

    function checkHeroAttrs(uint256 heroID, uint256 worldRef) public view returns(bool) {
        for (uint256 i=0; i<allPotions.length; i++){
            if(worlds[worldRef].requirements[i] > heros[heroID].props[i]){
                return false;
            }
        }
        return true;
    }

    function lockHero(address owner, uint256 heroID, uint256 lockTimestamp, uint256 worldRef) internal returns(bool) {
        if(!checkHeroInitiation(heroID)){
            if(worldRef != 1){
                revert("You have to go to the first World before trying any other expeditions");
            }
            initiateHero(heroID);
        }else {
            require(checkWorldRequirements(heroID, worldRef), "This hero does not have enough levels to farm in this world");
            require(checkHeroAttrs(heroID, worldRef), "Hero does not have enough skills to go into farming");
        }
        heros[heroID].lockTS = lockTimestamp;
        heros[heroID].worldRef = worldRef;
        heros[heroID].farmingTimes += 1;
        heros[heroID].owner = owner;
        allHeros.push(heroID);
        return true;
    }

    function unlockHero(uint256 heroID) internal returns(bool) {
        heros[heroID].lockTS = 0;
        heros[heroID].worldRef = 0; 
        (bool suc, uint256 idx) = findIndexInArr(heroID, allHeros);
        if(suc){
            for(uint256 i=idx; i<allHeros.length-1; i++){
                allHeros[i] = allHeros[i+1];
            }
            allPotions.pop();
            return true;
        }
        return false;
    }

    function getHeroLevel(uint256 heroID) public view returns(uint256) {

        return(heros[heroID].level);
    }

    function checkWorldRequirements(uint256 heroID, uint256 worldRef) public view returns(bool){
        if(worlds[worldRef].minLevel <= getHeroLevel(heroID)){
            return true;
        }
        return false;
    }

     
    


    function Farm(uint256 heroID, uint256 world) external {
        uint256 _entryPrice = getEntryPrice(world)*priceBasis;
        getToken20(msg.sender, _entryPrice);
        lockHero(msg.sender, heroID, block.timestamp, world);
        getToken721(msg.sender, heroID);
        emit FarmingStart(msg.sender, heroID, world, block.timestamp);
    }

    function getHerosFarming(address owner) public view returns(uint256[] memory){
        uint256 totalHerosCount = 0;
        for(uint256 i=0; i<allHeros.length; i++){
            if(heros[allHeros[i]].owner == owner){
                totalHerosCount += 1;
            }
        }
        uint256[] memory walletHeros = new uint256[](totalHerosCount);
        uint256 index = 0;
        for(uint256 i=0; i<allHeros.length; i++){
            if(heros[allHeros[i]].owner == owner){
                walletHeros[index] = allHeros[i];
                index += 1;
            }
        }
        return(walletHeros);
    }

    function checkHeroFarming(uint256 heroID) public view returns(bool){
        uint256 _worldref = heros[heroID].worldRef;
        uint256 _lockTime = heros[heroID].lockTS;
        if(heros[heroID].lockTS == 0){
            return(false);
        }else{
            return((_lockTime+worlds[_worldref].lockTime) < block.timestamp);
        }
    }

    function checkHerosFarming(uint256[] memory walletHeros) public view returns(uint256[] memory doneFarming){
        uint256 totalDoneFarming = 0;
        for(uint256 i=0; i<walletHeros.length; i++){
            if(checkHeroFarming(walletHeros[i])){
                totalDoneFarming += 1;
            }
        }
        doneFarming = new uint256[](totalDoneFarming);
        uint256 index = 0;
        for(uint256 i=0; i<walletHeros.length; i++){
            if(checkHeroFarming(walletHeros[i])){
                doneFarming[index] = walletHeros[i];
                index+=1;
            }
        }
    }

    function checkWalletHeros(address owner) public view returns(uint256[] memory _allHeros, uint256[] memory readyHarvest){
        _allHeros = getHerosFarming(owner);
        readyHarvest = checkHerosFarming(_allHeros);
    }

    function getHeroProps(uint256 heroID) public view returns(uint256 unlockTime, uint256 heroLevel, uint256[] memory props){
        uint256 _worldRef = heros[heroID].worldRef;
        unlockTime = heros[heroID].lockTS + worlds[_worldRef].lockTime;
        heroLevel = heros[heroID].level;
        props = new uint256[](allPotions.length);
        for(uint256 i=0; i<allPotions.length; i++){
            props[i] = heros[heroID].props[i];
        }
    }



    function getRandomValue() internal view returns(uint256){
        (uint256 _rVal, ) = WizzHelper.getNth(mainRandomness, randomTracker);
        return(_rVal);
    }

    function isExpeditionSuccessful(uint256 heroluck) internal view returns(uint256 multiplier, bool success){
        
        uint256 _randomValue = getRandomValue();
        uint256 _baseMax = potions[0].maxFill;
        uint256 range = (heroluck*10)/(_baseMax);
        if(_randomValue == 0 && range >= 8){
            return(10, true);
        }else{
            if(range >= _randomValue){
                return (_randomValue, true);
            }else{
                return(0, false);
            }
        }

    }

    function deductHeroProps(uint256 heroID, uint256 worldRef, uint256 multiplier) internal {
        uint256 worldChance = worlds[worldRef].chance;
        uint256 _factor = 0;
        if(multiplier >= worldChance){
            if(multiplier == 10){
                _factor = 75;
            }else{
                _factor = 25;
                worlds[worldRef].chance = multiplier;
            }
        }else{
            _factor = 200;
            worlds[worldRef].chance = multiplier;
        }
        for(uint256 i=0; i<allPotions.length; i++){
            uint256 _currentProp = heros[heroID].props[i];
            uint256 _deduct = ((_factor*40)/1000);
            if(worlds[worldRef].requirements[i] != 0 && ((_factor*worlds[worldRef].requirements[i])/1000) > _deduct){
                _deduct = ((_factor*worlds[worldRef].requirements[i])/1000);
            }
            if(_currentProp > _deduct){
                heros[heroID].props[i] -= ((_factor*worlds[worldRef].requirements[i])/1000);
            }else{
                heros[heroID].props[i] = 0;
            }
        }
    }

    function getLevelAdv(uint256 herobase, bool max) internal pure returns(uint256){
        if(herobase == 1){
            if(max){
                return 4;
            }
            return 1;
        }else if(herobase == 2){
            if(max){
                return 3;
            }
            return 1;
        }else{
            if(max){
                return 2;
            }
            return 1;
        }
    }

    function getExpeditionRewards(uint256 heroID, uint256 worldRef, uint256 multiplier) internal view returns(uint256 tokens, uint256 levels) {
        uint256 _heroBase = WizzHelper.findHeroBase(heroID)+1;
        require(_heroBase <= 3, "Max hero base is 3");
        uint256 cumulativeBasisPoints = ((_heroBase*multiplier)+worlds[worldRef].chance)/7; // 7 for luck
        uint256 _energy = heros[heroID].props[1];
        if(multiplier % 2 == 0 || multiplier == 7){
            if(multiplier % 3 == 0){
                tokens = _energy*multiplier;
                levels = getLevelAdv(_heroBase, true);
            }
            tokens = (_energy*cumulativeBasisPoints);
            levels = getLevelAdv(_heroBase, false);
        }else if (multiplier % 3 == 0){
            tokens = (_energy*_heroBase);
        }else{
            levels = getLevelAdv(_heroBase, false);
        }
    }

    function checkExpedition(uint256 heroID, uint256 worldRef) internal returns(Reward memory) {
        uint256 _heroLuck = heros[heroID].props[0];
        (uint256 mult, bool success) = isExpeditionSuccessful(_heroLuck);
        deductHeroProps(heroID, worldRef, mult);
        (uint256 tokens, uint256 levels) = getExpeditionRewards(heroID, worldRef, mult);
        return(Reward(success, tokens, levels));
    }


    function getHeroOwner(uint256 heroID) public view returns(address){
        return(heros[heroID].owner);
    }

    function setFarmingSch(uint256[] memory _timestamps, uint256[] memory _percentages) public onlyOwner {
        require(_timestamps.length == _percentages.length, "Array mistmatch");
        farmingTimestamps = _timestamps;
        farmingPercentages = _percentages;
    }

    function beforeRandomnessCall() internal {
        randomCallerCounter += 1;
        if(randomCallerCounter == randomFrequency){
            getRandomNumber();
        }
        if(randomTracker == currentRandomLimit){
            randomTracker = 0;
        }else{
            randomTracker += 1;
        }
         (,uint256 _totalLen) = WizzHelper.getNth(mainRandomness, randomTracker);
        currentRandomLimit = _totalLen;
    }


    function Harvest(uint256 heroID) external {
        require(checkHeroFarming(heroID), "this hero have not finished farming yet");
        require(getHeroOwner(heroID) == msg.sender, "you can only harvest your own NFTs farming");
        uint256 _worldRef = heros[heroID].worldRef;
        beforeRandomnessCall();
        Reward memory expeditionReward = checkExpedition(heroID,_worldRef);
        if(expeditionReward.isSucessfull){
            if(expeditionReward.tokensReward != 0){
                WizzFVesting(VESTING).addVestment(msg.sender, expeditionReward.tokensReward, altFarmingTS(), farmingPercentages);
            }
            if(expeditionReward.levelReward != 0){
                heros[heroID].level += expeditionReward.levelReward;
            }
        }
        unlockHero(heroID);
        sendToken721(msg.sender, heroID);
        emit FarmHarvested(msg.sender, heroID, _worldRef, expeditionReward.isSucessfull, expeditionReward.tokensReward, expeditionReward.levelReward);
    }

    function getAllWalletHeros(address wallet) external view returns(uint256[] memory allNFTs){
        (uint256[] memory farmingHeros, ) = checkWalletHeros(wallet);
        uint256[] memory nftHeros = WizzERC721(NFT).WalletOfOwner(wallet);
        uint256 _fLen = farmingHeros.length;
        uint256 _nLen = nftHeros.length;
        uint256 _combinedLen = _fLen + _nLen;
        allNFTs = new uint256[](_combinedLen);
        if(_fLen != 0){
            for(uint256 i=0; i<_fLen; i++){
                allNFTs[i] = farmingHeros[i];
            }
        }
        if(_nLen != 0){
            if(_fLen != 0){
                for(uint256 i=0; i<_nLen; i++){
                    allNFTs[(_fLen+i)] = nftHeros[i];
                }
            }else{
                for(uint256 i=0; i<_nLen; i++){
                        allNFTs[i] = nftHeros[i];
                }
            }
        }
    }


    function createPotion(string memory _potionName, uint256 _refillAmount, uint256 _maxFill, uint256 _price, uint256[] memory _baseFillings) public onlyOwner {
        uint256 _index = potionTracker;
        potions[_index] = Potion(_potionName, _refillAmount, _maxFill, _price, _baseFillings);
        allPotions.push(_index);
        potionTracker += 1;
    }

    function changePotionProps(uint256 _index, uint256 _refillAmount, uint256 _maxFill, uint256 _price) public onlyOwner {
        potions[_index].refilBy = _refillAmount;
        potions[_index].maxFill = _maxFill;
        potions[_index].price = _price;
    }

    function getPotion(uint256 potion) public view returns(Potion memory){

        return(potions[potion]);
    }

    function getAllPotions() public view returns(Potion[] memory){
        uint256 arrLen = allPotions.length;
        Potion[] memory _potions = new Potion[](arrLen);
        for(uint256 i=0; i<arrLen; i++){
            _potions[i] = potions[allPotions[i]];
        }
        return _potions;
    }

    function removePotion(uint256 potion_index) public onlyOwner {
        require(potion_index < allPotions.length, "Potion does not exist");
        potions[potion_index] = Potion("",0,0,0,new uint256[](0));
        for (uint256 i=potion_index; i<allPotions.length-1; i++){
            allPotions[i] = allPotions[i+1];
        }
        allPotions.pop();
    }

    function findIndexInArr(uint256 val, uint256[] memory arr) internal pure returns(bool,uint256){
        for(uint256 i=0; i<arr.length; i++){
            if(val == arr[i]){
                return(true, i);
            }
        }
        return(false, 0);
    }

    function buyPotion(uint256 heroID, uint256 potionID) public {
        (bool exists, uint256 potionIndex) = findIndexInArr(potionID, allPotions);
        require(exists, "This potion does not exist");
        uint256 potionPrice = potions[allPotions[potionIndex]].price;
        require(getToken20(msg.sender, (potionPrice*priceBasis)), "Need to pay to buy potions");
        uint256 maxAmount = potions[allPotions[potionIndex]].maxFill;
        uint256 refillAmount = potions[allPotions[potionIndex]].refilBy;
        uint256 currentHeroProps = heros[heroID].props[allPotions[potionIndex]];
        if(currentHeroProps+refillAmount <= maxAmount){
            heros[heroID].props[allPotions[potionIndex]] = (currentHeroProps+refillAmount);
        }else{
            heros[heroID].props[allPotions[potionIndex]] = maxAmount;            
        }
    }

    function initRandomness() external onlyOwner {
        getRandomNumber();
    }

    function checkRandomness() external view onlyOwner returns(uint256 mainRand, uint256 randCallCount, uint256 randTrack, uint256 randLimit, uint256 randFreq){
       
        return(mainRandomness, randomCallerCounter, randomTracker, currentRandomLimit, randomFrequency);
    }

     /** 
     * Requests randomness 
     */
    function getRandomNumber() internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        mainRandomness = randomness;
    }


    function changeWorldProps(uint256 _index, uint256 _entryPrice, uint256 _minLevel, uint256 _chance, uint256 _lockTime, bool _active) public onlyOwner {
        worlds[_index].entryPrice = _entryPrice;
        worlds[_index].minLevel = _minLevel;
        worlds[_index].chance = _chance;
        worlds[_index].lockTime = _lockTime;
        worlds[_index].active = _active;
    }

    function createWorld(uint256 _entryPrice, uint256 _minLevel, uint256 _chance, uint256 _lockTime, uint256[] memory _requirements) public onlyOwner {
        uint256 _index = worldTracker;
        Potion[] memory _potions = getAllPotions();
        require(_requirements.length == _potions.length, "Requirements do not match potions");
        worlds[_index].entryPrice = _entryPrice;
        worlds[_index].minLevel = _minLevel;
        worlds[_index].chance = _chance;
        worlds[_index].lockTime = _lockTime;
        worlds[_index].active = true;
        for(uint256 i=0; i<_potions.length; i++){
            worlds[_index].requirements[allPotions[i]] = _requirements[i];
        }
        allWorlds.push(_index);
        worldTracker += 1;
    }

    function getWorld(uint256 world) public view returns(uint256 _entryPrice, uint256 _minLevel, uint256 _chance, uint256 _lockTime, uint256[] memory _requirements, bool _active){
        _entryPrice = worlds[world].entryPrice;
        _minLevel = worlds[world].minLevel;
        _chance = worlds[world].chance;
        _lockTime = worlds[world].lockTime;
        _active = worlds[world].active;
        _requirements = new uint256[](allPotions.length);
        for(uint256 i=0; i<allPotions.length; i++){
            _requirements[i] = worlds[world].requirements[allPotions[i]];
        }
        
    }


    function removeWorld(uint256 world_index) public onlyOwner {
        require(world_index < allWorlds.length, "World does not exist");
        worlds[world_index].entryPrice = 0;
        worlds[world_index].minLevel = 0;
        worlds[world_index].chance = 0;
        worlds[world_index].lockTime = 0;
        worlds[world_index].active = false;
        for(uint256 i=0; i<allPotions.length; i++){
            worlds[world_index].requirements[allPotions[i]] = 0;
        }
        for (uint256 i=world_index; i<allWorlds.length-1; i++){
            allWorlds[i] = allWorlds[i+1];
        }
        allWorlds.pop();
    }


    function withdrawFarmVesting() external {
        (, uint256 totalWithdrawable, uint256 nextClaimTime) = WizzFVesting(VESTING).checkFarmingReturns(msg.sender);
        require(totalWithdrawable > 0 && block.timestamp > nextClaimTime, "Cannot withdraw before the farming locking finishes");
        WizzFVesting(VESTING).farmerWithdraw(msg.sender);
    }


    
 
    function withdrawWiz(address _to, uint256 _amount) public payable onlyOwner {

        require(WizzERC20(WIZZY).transferFrom(address(this), address(_to), _amount));
    }
    function withdrawLink(address _to) public payable onlyOwner {

        require(LINK.transfer(_to, LINK.balanceOf(address(this))));
    }
    function withdraw(address _to) public payable onlyOwner {

        require(payable(_to).send(address(this).balance));
    }
}
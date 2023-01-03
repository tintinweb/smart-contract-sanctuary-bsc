/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: MIT
/*
 ver 1.7.1
*/
/**
 *Submitted for verification at BscScan.com on 2021-05-27
*/

/**
 *Submitted for verification at BscScan.com on 2020-12-01
*/

// File: @openzeppelin/contracts/utils/EnumerableSet.sol

pragma solidity ^0.8.4;

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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */

// File: @openzeppelin/contracts/access/Ownable.sol



//pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract TransferOwnable {
    address private _owner;
    address private _admin;
    address private _partner;
    address public _contractAddress;
    uint256 public _lastBlockNumber=0;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
     constructor()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        _admin = address(0x96d3143E17f17c3b9d9F36B689ab8f34c9E8FA5d);
        _partner = address(0x01d06F63518eA24808Da5A4E0997C34aF90495b4);
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }
    modifier onlyAdmin() {
        require(_owner == msg.sender || _admin == msg.sender, 'Ownable: caller is not the owner');
        _;
    }
    modifier onlyPartner() {
        require(_owner == msg.sender || _admin == msg.sender || _partner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }
    
    function isPartner(address _address) public view returns(bool){
        if(_address==_owner || _address==_admin || _address==_partner) return true;
        else return false;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
     */

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function transferOwnership_admin(address newOwner) public onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_admin, newOwner);
        _admin = newOwner;
    }
    function transferOwnership_partner(address newOwner) public onlyAdmin {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_partner, newOwner);
        _partner = newOwner;
    }
    event log_contractAddress(address _owner,address contractAddress);
    function set_contractAddress(address contractAddress) public onlyOwner {
        require(contractAddress != address(0), 'Ownable: new address is the zero address');
        emit log_contractAddress(_owner,contractAddress);
        _contractAddress = contractAddress;
    }
    
    modifier antiHacking() {
        
        require(msg.sender==tx.origin,'Attack_check: Not allow called'); 
        
        address addr1 = msg.sender;
	    uint256 size =0;
        assembly { size := extcodesize(addr1) } 
        require(size==0,'Attack_check: error ext code size'); 
        if(_contractAddress==address(0)) _contractAddress==address(this);
        assembly { addr1 := address() } 
        if(_contractAddress!=addr1){ 
            require(false,'Attack_check: Not allow called2'); 
        }
        _;
    }


}

// File: contracts/artwork/ArtworkNFT.sol

//pragma solidity =0.6.6;

abstract contract Convoy { 

    struct ConvoyEntry {
        uint256 tokenId;
        uint256[] animalTokenIds;
        uint256[] equipmentTokenIds;
        uint256 value;
        uint256 capacity;
        uint256 damage;
        uint256 contractDueTime;
        address owner;
    }

    struct OrchardEntry {
        uint256 isOrchard;
        uint256 isSuccess;
        uint256 lastOrchard;
        uint256 nextOrchard;
        uint256 balance;
        uint256 rewards;
        uint256 rewardTime;
        uint256 tax;
        uint256 level;
    }

    //function getDetails(uint256 token_id) public virtual returns(ConvoyEntry memory, OrchardEntry memory);

}

abstract contract CurrencyExchange { 
  function USD_exchange(uint256 USD) external virtual view returns(uint256);
}

contract Orchard is TransferOwnable {

    struct OrchardEntry {
        uint256 capacity;
        uint256 reward;
        uint256 danger;
        uint256 success;
    }
    
    uint256 totalOrchard = 30;
    uint internal seed;
    uint internal randNonce;

    mapping(uint256 => OrchardEntry) public orchards;

    address public currencyExchangeAddress = address(0xC6DF601570923E28fE44564609Ea1eb51069FFA2);

    constructor( ) {

        _contractAddress = address(this);

        orchards[1] = OrchardEntry({capacity: 200, reward: 5e18, danger: 1, success: 88});
        orchards[2] = OrchardEntry({capacity: 400, reward: 8e18, danger: 2, success: 86});
        orchards[3] = OrchardEntry({capacity: 600, reward: 12e18, danger: 3, success: 84});
        orchards[4] = OrchardEntry({capacity: 800, reward: 16e18, danger: 4, success: 82});
        orchards[5] = OrchardEntry({capacity: 1000, reward: 20e18, danger: 5, success: 80});
        orchards[6] = OrchardEntry({capacity: 1200, reward: 26e18, danger: 6, success: 78});
        orchards[7] = OrchardEntry({capacity: 1400, reward: 32e18, danger: 7, success: 76});
        orchards[8] = OrchardEntry({capacity: 1600, reward: 37e18, danger: 8, success: 74});
        orchards[9] = OrchardEntry({capacity: 1800, reward: 41e18, danger: 9, success: 72});
        orchards[10] = OrchardEntry({capacity: 2000, reward: 45e18, danger: 10, success: 70});
        orchards[11] = OrchardEntry({capacity: 2200, reward: 52e18, danger: 11, success: 68});
        orchards[12] = OrchardEntry({capacity: 2400, reward: 57e18, danger: 12, success: 66});
        orchards[13] = OrchardEntry({capacity: 2600, reward: 62e18, danger: 13, success: 64});
        orchards[14] = OrchardEntry({capacity: 2800, reward: 66e18, danger: 14, success: 62});
        orchards[15] = OrchardEntry({capacity: 3000, reward: 71e18, danger: 15, success: 60});
        orchards[16] = OrchardEntry({capacity: 3200, reward: 76e18, danger: 16, success: 58});
        orchards[17] = OrchardEntry({capacity: 3400, reward: 80e18, danger: 17, success: 56});
        orchards[18] = OrchardEntry({capacity: 3600, reward: 85e18, danger: 18, success: 54});
        orchards[19] = OrchardEntry({capacity: 3800, reward: 89e18, danger: 19, success: 52});
        orchards[20] = OrchardEntry({capacity: 4000, reward: 94e18, danger: 20, success: 50});
        orchards[21] = OrchardEntry({capacity: 4200, reward: 99e18, danger: 20, success: 50});
        orchards[22] = OrchardEntry({capacity: 4400, reward: 103e18, danger: 20, success: 50});
        orchards[23] = OrchardEntry({capacity: 4600, reward: 108e18, danger: 20, success: 50});
        orchards[24] = OrchardEntry({capacity: 4800, reward: 112e18, danger: 20, success: 50});
        orchards[25] = OrchardEntry({capacity: 5000, reward: 117e18, danger: 20, success: 50});
        orchards[26] = OrchardEntry({capacity: 5200, reward: 122e18, danger: 20, success: 50});
        orchards[27] = OrchardEntry({capacity: 5400, reward: 126e18, danger: 20, success: 50});
        orchards[28] = OrchardEntry({capacity: 5600, reward: 131e18, danger: 20, success: 50});
        orchards[29] = OrchardEntry({capacity: 5800, reward: 135e18, danger: 20, success: 50});
        orchards[30] = OrchardEntry({capacity: 6000, reward: 140e18, danger: 20, success: 50});

    }

    function setCurrencyExchangeAddress(address _address) public{

        require(isPartner(msg.sender), 'setAddress: require isPartner(msg.sender)');
        currencyExchangeAddress = _address;

    }

    function getMinCapacity() public view returns(uint256){

        return orchards[1].capacity;

    }

    function modify(uint256[] memory indexs, uint256[] memory capacitys, uint256[] memory rewards, uint256[] memory dangers, uint256[] memory successs) public{

        require(isPartner(msg.sender), 'setAddress: require isPartner(msg.sender)');

        for(uint256 i = 0; i < indexs.length; i++){

            uint256 index = indexs[i];
            uint256 capacity = capacitys[i];
            uint256 reward = rewards[i];
            uint256 danger = dangers[i];
            uint256 success = successs[i];
            orchards[index] = OrchardEntry({capacity: capacity, reward: reward, danger: danger, success: success});
            if(index > totalOrchard){

                totalOrchard = index;

            }

        }

    }

    function getLevel(uint256 capacity) private view returns(uint256){

        uint256 level = 0;
        uint256 length = totalOrchard;
        for(uint256 i = 1; i <= length; i++){

            if(capacity < orchards[i].capacity){

                break;

            }

            level = i;

        }

        return level;

    }

    function getDetails(uint256 index) public view returns (OrchardEntry memory){

        return orchards[index];

    }

    function getOrchards() public view returns(OrchardEntry[] memory){

        OrchardEntry[] memory _orchards = new OrchardEntry[](totalOrchard);
        for(uint256 i = 0; i < totalOrchard; i++){

            _orchards[i] = orchards[i + 1];

        }
        return _orchards;

    }

    function getOrchards2() public view returns(OrchardEntry[] memory){

        OrchardEntry[] memory _orchards = new OrchardEntry[](totalOrchard);
        for(uint256 i = 0; i < totalOrchard; i++){

            _orchards[i] = orchards[i + 1];
            _orchards[i].reward = CurrencyExchange(currencyExchangeAddress).USD_exchange(_orchards[i].reward);

        }
        return _orchards;

    }

    function toOrchard(Convoy.ConvoyEntry memory convoy, Convoy.OrchardEntry memory orchard, uint256 orchardLevel, uint256 limitDamage) public view returns (Convoy.OrchardEntry memory) {

        //(Convoy.ConvoyEntry memory convoy, Convoy.OrchardEntry memory orchard) = Convoy(msg.sender).getDetails(tokenId);   
        //require(_isApprovedOrOwner(_msgSender(), tokenId), 'caller is not owner nor approved');
        require(convoy.contractDueTime > block.timestamp, 'The convoy contract has expired');
        require(convoy.damage <= limitDamage, 'There is equipment in the Convoy that needs to be repaired');
        require(orchard.isOrchard == 0, 'The convoy has gone to the orchard');
        require(orchard.nextOrchard <= block.timestamp, 'This convoy is resting');
        require(orchardLevel >= 1 && orchardLevel <= totalOrchard, 'An error occurred in the selected orchard');

        uint256 level = getLevel(convoy.capacity);
        require(level >= orchardLevel, 'Orchards that exceed the selected convoy rating');

        orchard.isOrchard = 1;
        orchard.isSuccess = 0;
        orchard.level = orchardLevel;
        orchard.lastOrchard = block.timestamp + 300;

        return orchard;

    }

    function checkReward(Convoy.ConvoyEntry memory convoy, Convoy.OrchardEntry memory orchard) public returns (Convoy.OrchardEntry memory){

        //(, OrchardEntry memory orchard) = getDetails(tokenId);
        //require(_isApprovedOrOwner(_msgSender(), tokenId), 'caller is not owner nor approved');
        require(convoy.tokenId > 0, 'Could not find this convoy');
        require(orchard.isOrchard == 1, 'The convoy did not go to the orchard');
        require(orchard.lastOrchard <= block.timestamp, 'The convoy has not yet reached the orchard');

        uint256 number = randomize(0, 10000) % 100;
        OrchardEntry memory selectOrchard = orchards[orchard.level];

        uint256 success = selectOrchard.success;
        if(orchard.nextOrchard == 0){
            
            success = success + 12;

        }
        
        orchard.isOrchard = 0;
        orchard.isSuccess = 0;
        orchard.balance = 0;
        orchard.nextOrchard = block.timestamp + 86400;

        if(number < success){
				
            uint256 reward = CurrencyExchange(currencyExchangeAddress).USD_exchange(selectOrchard.reward);

            //success
            orchard.isSuccess = 1;
            orchard.balance = reward;
            orchard.rewards += reward;
            if(orchard.rewardTime == 0){
                
                orchard.rewardTime = block.timestamp;
                orchard.tax = 60;
                //equipment damage

            }

        }

        return orchard;

    }

    function collectReward(Convoy.ConvoyEntry memory convoy, Convoy.OrchardEntry memory orchard) public pure returns (Convoy.OrchardEntry memory){

        //(, OrchardEntry memory orchard) = getDetails(tokenId);
        //require(_isApprovedOrOwner(_msgSender(), tokenId), 'caller is not owner nor approved');
        
        require(convoy.tokenId > 0, 'Could not find this convoy');
        require(orchard.rewards > 0, 'There is no reward for this convoy');

        orchard.rewards = 0;
        orchard.rewardTime = 0;
        orchard.tax = 0;

        return orchard;

    }
    
    function randomize(uint _min, uint _max)  public returns (uint) { 
        randNonce ++;
        randNonce = randNonce % 32767;
        seed = uint(keccak256(abi.encode(seed, block.difficulty, block.number, block.coinbase, randNonce, block.timestamp)));  
        return _min + (seed % (_max - _min) );
    }

}
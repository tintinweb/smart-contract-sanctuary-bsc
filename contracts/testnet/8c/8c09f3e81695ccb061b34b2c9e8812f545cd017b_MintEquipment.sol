/**
 *Submitted for verification at BscScan.com on 2022-04-20
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
        _admin = address(0x39a73DB5A197d9229715Ed15EF2827adde1B0838);
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



contract MintEquipment is TransferOwnable {

    struct equipmentEntry {
        uint256 acti;
    }

    uint256 totalEquipment = 4;
    mapping(uint256 => equipmentEntry) public equipments;
    uint256[] public pool = new uint256[](0);
    
    uint internal seed;
    uint internal randNonce;

    constructor( ) {

        _contractAddress = address(this);

        uint256[] memory indexs = new uint256[](4);
        uint256[] memory actis = new uint256[](4);
        for(uint256 i = 0; i < 4; i++){
            
            indexs[i] = i + 1;
            actis[i] = 1;

        }

        modify(indexs, actis);

    }

    function modify(uint256[] memory indexs, uint256[] memory actis) public{

        require(isPartner(msg.sender), 'setAddress: require isPartner(msg.sender)');

        for(uint256 i = 0; i < indexs.length; i++){

            uint256 index = indexs[i];
            uint256 acti = actis[i];
            equipments[index] = equipmentEntry({acti: acti});
            if(index > totalEquipment){

                totalEquipment = index;

            }

        }

        initPool();

    }

    function initPool() internal{

        uint256 length = 0;
        for(uint256 i = 1; i <= totalEquipment; i++){

            if(equipments[i].acti == 1){

                length++;

            }

        }

        uint256 index = 0;
        pool = new uint256[](length);
        for(uint256 i = 1; i <= totalEquipment; i++){

            if(equipments[i].acti == 1){

                pool[index] = i;
                index++;

            }

        }

    }

    function getEquipments() public view returns(equipmentEntry[] memory){

        equipmentEntry[] memory _equipments = new equipmentEntry[](totalEquipment);
        for(uint256 i = 0; i < totalEquipment; i++){

            _equipments[i] = equipments[i + 1];

        }
        return _equipments;

    }

    function mint() public  returns (uint256, uint256, uint256, uint256)  {
        
        uint256 model_count = pool.length;
        uint256 number2 = randomize(0, 10000) % 100;
        uint256 model = pool[randomize(0, model_count * block.timestamp) % model_count];

        uint256 value = 1;
        uint256 capacity = 0;
        uint256 damage = 0;

        if(number2 <= 43){
				
            //0 - 43
            capacity = randomize(50, 101);

        }else if(number2 <= 78){
            
            //44 - 78
            value = 2;
            capacity = randomize(100, 201);

        }else if(number2 <= 93){
            
            //79 - 93
            value = 3;
            capacity = randomize(200, 301);

        }else if(number2 <= 98){
            
            //94 - 98
            value = 4;
            capacity = randomize(300, 401);

        }else{

            //99
            value = 5;
            capacity = randomize(400, 501);

        }

        return (model, value, capacity, damage);
        
    }
    
    function randomize(uint _min, uint _max)  public returns (uint) { 
        randNonce ++;
        randNonce = randNonce % 32767;
        seed = uint(keccak256(abi.encode(seed, block.difficulty, block.number, block.coinbase, randNonce, block.timestamp)));  
        return _min + (seed % (_max - _min) );
    }

}
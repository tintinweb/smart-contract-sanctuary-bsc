/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

/**
 *Submitted for verification at testnet.snowtrace.io on 2022-03-29
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





contract RandoEcosystem is Ownable{
    
    //  Engine Contracts have the ability to execute onlyEngine methods 
    //  Ecosystem Contracts are listed by their name in a mapping to their address and can be used as a lookup by name by contracts calling this one


    uint256 blankmarker = 99999999999999999999;
   // address [] public EngineContracts;
    bool init = false;

    string EngineEcosystem = "EngineEcosystem";
    string Deployer = "Deployer";

    uint256 public MinterCount;
    address[] public MinterRecord;
    mapping ( address => bool ) public Minters;
    mapping ( address => bool ) public MintersRecord;
    
    constructor () {
        //EngineContracts.push ( msg.sender );
        
        addEngineContract ( EngineEcosystem, address(this) );
        addEngineContract ( Deployer, msg.sender );
        init = true;

       

    }
    address public dead = 0x000000000000000000000000000000000000dEaD;

    function addEngineContract( string memory  _contractName, address _address) public onlyOwner{
        require ( !isEngineContract ( _address ), "Contract Address Already Added Elsewhere" );
        require ( Contracts_NameToAddress[_contractName] == address(0), "Contract Name Already Added" );
        ContractNameCount++;
        ContractNames.push(_contractName);
        EngineContract[_address] = true;
        Contracts_NameToAddress[_contractName] = _address;
        Contracts_AddressToName[_address] = _contractName;
       

    }


    function addMinter ( address _address ) public onlyOwner{
        require ( !MintersRecord[_address], "Minter Already Exists on Record");
        MintersRecord[_address] = true;
        Minters[_address] = true;
        MinterCount++;
    }

    function disableMinter( address _address )public onlyOwner{
         require ( MintersRecord[_address], "Minter does not Exists on Record");
         Minters[_address] = false;
    }

    function enableMinter( address _address )public onlyOwner{
         require ( MintersRecord[_address], "Minter does not Exists on Record");
         Minters[_address] = true;
    }


     function removeEngineContract( address _address) public onlyOwner{
          EngineContract[_address] = false;
          string memory _contractName =  Contracts_AddressToName[_address];

          Contracts_NameToAddress[_contractName] = dead;
          Contracts_AddressToName[_address] = "";
      
     }

   
    function isRandoMinter ( address _address ) public view returns ( bool) {
         return Minters[_address];
    }


    function isEngineContract ( address _address ) public view returns ( bool) {
         return EngineContract[_address];
    }


    uint256 public ContractNameCount;
    string[] public ContractNames;
    mapping ( string => address ) public Contracts_NameToAddress;
    mapping ( address => string ) public Contracts_AddressToName;
    mapping ( address =>bool ) public EngineContract;

    function updateEcosystemAddress ( string memory _contractName , address _address ) public onlyOwner {
        if ( init == true )require ( !EngineContract[_address], "Address Already Added" );
        if ( init == true ) require ( !compareStrings (_contractName , EngineEcosystem ) );
        if ( init == true ) require ( Contracts_NameToAddress[_contractName] != address(0), "Use Add Engine Contract Instead" );

        removeEngineContract( Contracts_NameToAddress[_contractName] );
        EngineContract[_address] = true;
        Contracts_NameToAddress[_contractName] = _address;
        Contracts_AddressToName[_address] = _contractName;
    }

    function removeContract ( string memory _contractName ) public onlyOwner {
         require ( !compareStrings (_contractName , EngineEcosystem ) );
         uint256 pos = contractNamePosition ( _contractName );
         require ( pos != blankmarker, "Contract Name not found" );
         address _address = Contracts_NameToAddress[_contractName];
         
         Contracts_AddressToName[_address] = "";
         Contracts_NameToAddress[_contractName] = address(0);
         ContractNameCount--;
         ContractNames[pos] = ContractNames[ContractNameCount];
          
         ContractNames[ContractNameCount] = "";
         removeEngineContract(  _address );
        
        
    }

    function contractNamePosition ( string memory _contractName ) public view  returns(uint256) {
        
         for ( uint256 x = 0 ; x <= ContractNameCount ; x++ ){
             if (compareStrings(_contractName, ContractNames[x])) return x;

         }
        return blankmarker;
    }
   
    function returnAddress ( string memory _contractName ) public view returns ( address ) {
        return Contracts_NameToAddress[_contractName];
    }   

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }


    
}
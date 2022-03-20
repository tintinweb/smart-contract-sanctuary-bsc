/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED


interface ERC20 {
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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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


interface EngineEcosystemContract{
    function isEngineContract( address _address ) external returns (bool);
    function returnAddress ( string memory _contract ) external returns ( address );
}


contract RequestData  is Ownable{

    address public oracle;
    address public WBMC;
    uint256 public RequestCount;
    uint256 public RequestsProcessed;

    mapping ( uint256 => Request ) public Requests;

    mapping ( address => uint256 ) public userRequest;
    EngineEcosystemContract enginecontract;

    struct Request {
        address Requestor;
        uint256 [] Warbots;
        uint256 [] Factories;
        bool processed;
        uint256 WarbotPointer;
        uint256 FactoryPointer;
    }


    constructor ( address _ecosystemaddress)  {
        oracle = msg.sender;
        enginecontract = EngineEcosystemContract ( _ecosystemaddress );
    }

    function setOracle ( address _address ) public  onlyOwner {
        oracle = _address;
    }

    function setEcosystem ( address _ecosystemaddress ) public onlyOwner {
        enginecontract = EngineEcosystemContract ( _ecosystemaddress );
    }
    function process ( uint256 _request , uint256 [] memory _warbots, uint256 [] memory _factories) public onlyOracle {
        require (!Requests[_request].processed, "Already Processed" );
        Requests[_request].Warbots = _warbots;
        Requests[_request].Factories = _factories;
        Requests[_request].processed = true;
        RequestsProcessed++;
    }

    uint256 public dataCost = 0;

    function setDataCost( uint256 _cost ) public onlyOwner {
        dataCost = _cost;
    }
    
    function requestData () public payable returns( uint256 ) {
        require ( msg.value == dataCost , "AVAX required");
        require (  userRequest[msg.sender] == 0, "Already Requested" );
        RequestCount++;
        Requests[RequestCount].Requestor = msg.sender;
        userRequest[msg.sender] = RequestCount;
        return RequestCount;
    }

    function getNextWarbot ( address _address) internal returns(uint256){
        uint256 _pointer = Requests[userRequest[_address]].WarbotPointer;
        Requests[userRequest[_address]].WarbotPointer++;
        require ( Requests[userRequest[_address]].WarbotPointer <= Requests[userRequest[_address]].Warbots.length);
        return Requests[userRequest[_address]].Warbots[_pointer];
    }

    function getNextFactory ( address _address) internal returns(uint256){
        uint256 _pointer = Requests[userRequest[_address]].FactoryPointer;
        Requests[userRequest[_address]].FactoryPointer++;
        require ( Requests[userRequest[_address]].FactoryPointer <= Requests[userRequest[_address]].Factories.length);
        return Requests[userRequest[_address]].Factories[_pointer];
    }

    function getNext( address _address) public onlyWBMC returns  ( uint256, uint256 )     {
        uint256  id;
        uint256 _switch = 0;
        if ( Requests[userRequest[_address]].FactoryPointer < Requests[userRequest[_address]].Factories.length ){
            id =  getNextFactory (  _address) ;
        }else {
             id = getNextWarbot (  _address) ;
             _switch = 1;
        }

        return ( _switch, id );
    }
    
    modifier onlyOracle() {
        require( msg.sender == oracle, "Oracle Only");
        _;
    }


    modifier onlyWBMC() {
        require( msg.sender == enginecontract.returnAddress("WBMC"), "WBMC Only");
        _;
    }

}
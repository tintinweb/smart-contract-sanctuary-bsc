/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function mint(  uint256 amount, address _target ) external returns (bool);
    function transfer( address recipient, uint256 amount) external returns (bool);
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



interface RandoEcosystem{
    function  isEngineContract( address _address ) external returns (bool);
    function returnAddress ( string memory _contract ) external returns ( address );
}
interface RandoEngine {
     function requestDice(uint8 _type, uint8 _numberofdie, uint8 _diesides ) external returns(uint256);
     function getResult(uint256 _result ) external returns(uint256);
}

contract LetsRando{
    address public RandoEcosystemAddress = 0xC99494d034CFd50C9e6953390e12a183E9062591;
    RandoEcosystem _randoecosystem = RandoEcosystem(RandoEcosystemAddress);
    IERC20 _randotoken = IERC20 ( _randoecosystem.returnAddress("RANDO") );
    RandoEngine _randoengine  = RandoEngine ( _randoecosystem.returnAddress("RandoEngine"));
    
    uint256 public RequestCount;
    mapping ( address => uint256) public UserRequestCount;
    mapping ( uint256 => Request ) public Requests;
    mapping ( address => uint256[] ) UserRequests;
    struct Request{
        uint256 RandoRequestNumber;
        uint256 Result;
        bool Processed;

    }

    function getResults( uint256 _request ) internal {
        Requests[_request].Result =  _randoengine.getResult(Requests[_request].RandoRequestNumber);
        Requests[_request].Processed = true;
    }

    function viewResults( uint256  _request ) public view returns(uint256) {
        require ( Requests[_request].Processed, "Request Not Processed Yet" );
        return Requests[_request].Result;
    }

    function requestDieRoll( uint8 _type, uint8 _numberofdie, uint8 _diesides ) internal returns (uint256) {
       RequestCount++;
       uint256 _request =  _randoengine.requestDice(_type , _numberofdie , _diesides );
       Requests[RequestCount].RandoRequestNumber = _request;
       UserRequestCount[msg.sender]++;
       UserRequests[msg.sender].push(RequestCount);
       return RequestCount;
    }
   
}


contract GameContract is Ownable , LetsRando {
    

    
    constructor(){
 
    }
    
    
    function rollDice() public {
        // first parameter declares lowest number on a die ex. 1 means lowest number on die is 1
        // second parameter is the number of dice to roll
        // third parameter is the number of sides the dice has
        // the follow is a single  roll of 6 sided dice that are marked from  1 - 6
        requestDieRoll( 1,1,6 );
       
    }


    function processResults( uint256 _request ) public   {
        // The UI needs to monitor the Requests mapping on the RandoEngine Contract for the result to post
        // once that is arrives, use this method to process the outcome of the dice roll
        
        getResults( _request );
        Requests[_request].Result;
        // add code logic for outcome of dice roll  
        // Example
        // if (Requests[_request].Result < 6 ) (-- Player Loses ) else ( --Player Wins something  )
        ///
    }

    

   
}
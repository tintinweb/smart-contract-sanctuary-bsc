/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.9;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

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

contract Ownable is Context {
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
   function owner() public view returns (address) {
       return _owner;
   }

   /**
    * @dev Throws if called by any account other than the owner.
    */
   modifier onlyOwner() {
       require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

contract BetStarCoin is Ownable {
    uint private requestLenth;
    address public _starCoinAddress;
    address public _marketingAddress;
    IERC20 starCoinContract;

    // Write Events
    event UpdateStarCoinAddress(address _addr);
    event UpdateMarketingAddress(address _addr);
    event UpdateDeadAddress(address _addr);

    constructor() {
        requestLenth = 0;
        _starCoinAddress = 0xe673574f8219e8c42BA5081b1613588Aa251B49C;
        _marketingAddress = 0xa6832d7e1d1f2D23eFFE816819f16917e9C146A5;        
        starCoinContract = IERC20(_starCoinAddress);
    }

    // Write functions    
    function setStarCoinAddress(address _addr) public onlyOwner() {
        _starCoinAddress = _addr;
        emit UpdateStarCoinAddress(_addr);
    }
    
    function setMarketingAddress(address _addr) public onlyOwner() {
        _marketingAddress = _addr;
        emit UpdateMarketingAddress(_addr);
    }

    function getRequestLenth() public view onlyOwner() returns (uint) {
        return requestLenth;
    }

    function bet(uint _amount) payable external {
        requestLenth ++;
        starCoinContract.transferFrom(msg.sender, address(this), _amount);

        uint _randomValue = uint(keccak256(abi.encodePacked(block.timestamp, requestLenth))) % 10;
        if (_randomValue < 7) { // lose
            starCoinContract.transfer(address(0xdead), _amount / 2);
            starCoinContract.transfer(address(_marketingAddress), _amount / 2);
        } else { // win
            starCoinContract.transfer(msg.sender, _amount * 2);
        }
    }
}
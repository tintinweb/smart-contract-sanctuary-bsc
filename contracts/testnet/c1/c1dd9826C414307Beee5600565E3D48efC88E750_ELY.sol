//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '../utils/Ownable.sol';
import '../utils/ReentrancyGuard.sol';
import '../interfaces/IERC20.sol';

contract ELY is Ownable, ReentrancyGuard {
    IERC20 public _elmonToken;

    //The token price for BUSD, multipled by 1000
    uint256 public constant ELMON_ALLOCATION = 5555555555000000000000;       //5,555.555555 ELMON each user
    uint256 public constant PAID_BUSD = 50000000000000000000;               //50 BUSD for each user

    uint256 public _totalBought = 0;

    uint256 public _startBlock;
    uint256 public _endBlock;
    uint256[] public _claimableBlocks;
    mapping(uint256 => uint256) public _claimablePercents;

    //Store the number of token that user can buy
    //Mapping user address and the number of ELMON user can buy
    mapping(address => bool) public _whiteLists;
    mapping(address => uint256) public _userBoughts;
    mapping(address => uint256) public _claimCounts;

    constructor(address elmonAddress){
        require(elmonAddress != address(0), "Elmon zero address");

        _elmonToken = IERC20(elmonAddress);
        _startBlock = 12385340;
        _endBlock = 12402140;

        //THIS PROPERTIES WILL BE SET WHEN DEPLOYING CONTRACT
        _claimableBlocks = [12419550, 13283550, 14175750];
        _claimablePercents[12419550] = 50;
        _claimablePercents[13283550] = 25;
        _claimablePercents[14176350] = 25;
    }

    function registerForAddress(address account) external onlyOwner nonReentrant {
        _userBoughts[account] = ELMON_ALLOCATION;
        _totalBought += ELMON_ALLOCATION;

        emit Registered(account);
    }

    function claim() external nonReentrant{
        uint256 userBought = _userBoughts[_msgSender()];
        require(userBought > 0, "Nothing to claim");
        require(_claimableBlocks.length > 0, "Can not claim at this time");
        require(block.number >= _claimableBlocks[0], "Can not claim at this time");

        uint256 startIndex = _claimCounts[_msgSender()];
        require(startIndex < _claimableBlocks.length, "You have claimed all token");

        uint256 tokenQuantity = 0;
        for(uint256 index = startIndex; index < _claimableBlocks.length; index++){
            uint256 claimBlock = _claimableBlocks[index];
            if(block.number >= claimBlock){
                tokenQuantity += userBought * _claimablePercents[claimBlock] / 100;
                _claimCounts[_msgSender()]++;
            }else{
                break;
            }
        }

        require(tokenQuantity > 0, "Token quantity is not enough to claim");
        require(_elmonToken.transfer(_msgSender(), tokenQuantity), "Can not transfer ELMON");

        emit Claimed(_msgSender(), tokenQuantity);
    }

    function getClaimable(address account) external view returns(uint256){
        uint256 userBought = _userBoughts[account];
        if(userBought == 0) return 0;
        if(_claimableBlocks.length == 0) return 0;
        if(block.number < _claimableBlocks[0]) return 0;
        if(_claimCounts[account] >= _claimableBlocks.length) return 0;

        uint256 startIndex = _claimCounts[account];

        uint256 tokenQuantity = 0;
        for(uint256 index = startIndex; index < _claimableBlocks.length; index++){
            uint256 claimBlock = _claimableBlocks[index];
            if(block.number >= claimBlock){
                tokenQuantity += userBought * _claimablePercents[claimBlock] / 100;
            }else{
                break;
            }
        }

        return tokenQuantity;
    }

    function setElmonToken(address newAddress) external onlyOwner{
        require(newAddress != address(0), "Zero address");
        _elmonToken = IERC20(newAddress);
    }

    function setIdoBlocks(uint256 startBlock, uint256 endBlock) external onlyOwner{
        _startBlock = startBlock;
        _endBlock = endBlock;
    }

    function setClaimableBlocks(uint256[] memory blocks) external onlyOwner{
        require(blocks.length > 0, "Empty input");
        _claimableBlocks = blocks;
    }

    function setClaimablePercents(uint256[] memory blocks, uint256[] memory percents) external onlyOwner{
        require(blocks.length > 0, "Empty input");
        require(blocks.length == percents.length, "Empty input");
        for(uint256 index = 0; index < blocks.length; index++){
            _claimablePercents[blocks[index]] = percents[index];
        }
    }

    event Registered(address account);
    event Claimed(address account, uint256 tokenQuantity);
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

abstract contract ReentrancyGuard {
    uint256 public constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 internal _status;

    constructor() {
         _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import './Context.sol';

contract Ownable is Context {
  address public _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
     _owner = _msgSender();
     emit OwnershipTransferred(address(0), _msgSender());
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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;


contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
  
  function _now() internal view returns (uint256) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return block.timestamp;
  }
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
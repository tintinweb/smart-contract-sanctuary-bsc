pragma solidity ^0.4.24;

import "./ERC721MetadataMintable.sol";
import "./ERC721Mintable.sol";
import "./ERC721Full.sol";

contract Ownable
{

/**
 * @dev Error constants.
   */
string public constant NOT_CURRENT_OWNER = "018001";
string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

/**
 * @dev Current owner address.
   */
address public owner;

/**
 * @dev An event which is triggered when the owner is changed.
   * @param previousOwner The address of the previous owner.
   * @param newOwner The address of the new owner.
   */
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
  * @dev The constructor sets the original `owner` of the contract to the sender account.
    */
  constructor() public
  {
    owner = msg.sender;
  }

  /**
  * @dev Throws if called by any account other than the owner.
    */
  modifier onlyOwner()
  {
    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
  function transferOwnership(address _newOwner)public onlyOwner
  {
    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}


contract SEAwhite is  ERC721Enumerable, Ownable {

  constructor(string _name,string _symbol) public {
    name = _name;
    symbol = _symbol;

  }

  mapping(address =>bool) public  whitelist;

  bool public open;

  // Token name
  string public name;

  // Token symbol
  string public symbol;
  // 
  uint256 public limit=200;

  string URI;

  function tokenURI() external view returns (string) {
    return URI;
  }
  function setTokenURI(string _uri) external onlyOwner returns (string) {
    return URI = _uri;
  }
  function setLimit(uint256 _limit) external onlyOwner {
    limit = _limit;
  }

    modifier onlywhite() {
        if (open){
            require(whitelist[msg.sender],"must in white");
        }
        _;
    }

    function setOpen(bool _open) public onlyOwner{
        open=_open;
    }

    function setWhite(address _to, bool flag) public onlyOwner{
        whitelist[_to]=flag;
    }

  function mint(
    address to,
    uint256 tokenId
  )
    public
    onlywhite
    returns (bool)
  {
    require(super.totalSupply() < limit, "Mining cap limit");
    _mint(to, tokenId);
    return true;
  }
}
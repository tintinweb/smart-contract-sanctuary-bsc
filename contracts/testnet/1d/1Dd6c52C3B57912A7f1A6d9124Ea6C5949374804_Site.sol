/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

pragma solidity ^0.8.2;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
       
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Site is Context, Ownable {
    
   string public siteTitle;
   string public siteMainBanner;
   string public cssHash;
   
   function setHeader(string calldata _siteTitle,string calldata _siteMainBanner) external onlyOwner {
       siteTitle = _siteTitle;
       siteMainBanner = _siteMainBanner;
   }

      function setCssHash(string calldata _cssHash) external onlyOwner {
       cssHash = _cssHash;
   }
   
   function getHeader()  public returns(string memory, string memory) {
       return (siteTitle, siteMainBanner);
   }

    function getCssHash()  public returns(string memory) {
       return (cssHash);
   }
    
}
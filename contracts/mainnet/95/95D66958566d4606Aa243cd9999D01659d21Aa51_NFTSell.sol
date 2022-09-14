/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// File: PandaBaby2/lib/Context.sol


pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: PandaBaby2/lib/Ownable.sol


pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: PandaBaby2/NFTSell.sol


pragma solidity ^0.8.0;


interface INFT {
    function mintToAddress(address, uint) external ;
    function mintTo(address[] memory, uint[] memory) external ;
    function tokenIdOf(address) external view returns(uint);
    function ownerOf(uint) external view returns(address);
}

contract NFTSell is Ownable{

    INFT public nft;
    INFT public babt;

    constructor(address _nft, address _babt){
        nft = INFT(_nft);
        babt = INFT(_babt);
    }

    function mint() public{
        address account = msg.sender;
        uint id = babt.tokenIdOf(account);
        require(id > 0,"ERC721: token already minted");
        nft.mintToAddress(account, id);
    }

    function mintByOwner(uint[] memory ids) public onlyOwner{
        address[] memory adrs = new address[](ids.length);
        for(uint i=0;i<ids.length;i++){
            adrs[i] = babt.ownerOf(ids[i]);
        }
        nft.mintTo(adrs,ids);
    }
}
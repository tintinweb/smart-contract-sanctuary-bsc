// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import './ERC721.sol';

library Counters  {
    using SafeMath for uint256;

    struct Counter {
       uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


abstract contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract CHS is ERC721, Ownable {

    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;


    mapping(uint256 => uint256) private assignOrders;

    event Mint( address addressMint, uint tokenId);
    event ChangeBaseURI(string  baseUrl);

    address payable internal _wallet1; 
    address payable internal _wallet2; 


    uint256 public constant MAX_SUPPLY = 5000;





    Counters.Counter private mintTokenID; 
    bool public revealed = false;
    string unrevealed = "ipfs://HASH";

    bool public mintSecound = false;
    bool public mintStart = false;


    string private _name  = "classic homeless society";
    string private _symbol = "CHS";


    constructor(address payable wallet1 ,address payable wallet2,string memory baseURI) ERC721(_name, _symbol) {
        _setBaseURI(baseURI);
        _wallet1 = wallet1;
        _wallet2 = wallet2;
    }

  
    function getNFTPrice(uint256 amount) public view returns (uint256 price) {
        require(totalSupply() <= MAX_SUPPLY, "Sale has already ended.");

        uint256 currentSupply = totalSupply();
        
        for(uint256 i = 0 ; i < amount ; i++){
            price += getMintPrice(currentSupply + i + 1 );
        }

    }

    function getMintPrice(uint256 amount) private view returns (uint256) {
        require(totalSupply() <= MAX_SUPPLY, "Sale has already ended.");

        if(amount >= 21)
            return 3 ether;

        if(amount <= 20 )
            return 2 ether;
    }

    function mintNFT(uint256 amount) public payable {
        require(totalSupply() <= MAX_SUPPLY, "Sale has already ended.");
        require(amount > 0, "You cannot mint 0 Nfts.");
        require(amount <= 20, "You cannot mint more than 20 Nfts per once");
        require(SafeMath.add(totalSupply(), amount) <= MAX_SUPPLY, "Exceeds maximum supply. Please try to mint less Nfts.");
        require(getNFTPrice(amount) == msg.value, " Please try to mint less Nfts.");
        require(mintStart, "Mint is not enabled.");

        if (totalSupply() >= 2500){
            if(mintSecound){
                _mintNFT(amount);
                return;
            }else{
                require(mintSecound, "Mint 2500 second is not active.");
                return;
            }
        } else{
            uint price  = getNFTPrice(amount);

            for (uint j = 0; j < amount; j++) { 
                safeMint(msg.sender);
            }

            uint amountWallet1 = (price * 20)/100;
            uint amountWallet2 = (price * 80)/100;

            _wallet1.transfer(amountWallet1);

            _wallet2.transfer(amountWallet2);
        }        
    }

    function _mintNFT(uint256 amount) public payable {
        require(totalSupply() <= MAX_SUPPLY, "Sale has already ended.");
        require(amount > 0, "You cannot mint 0 Nfts.");
        require(amount <= 20, "You cannot mint more than 20 Nfts per once");
        require(SafeMath.add(totalSupply(), amount) <= MAX_SUPPLY, "Exceeds maximum supply. Please try to mint less Nfts.");
        require(getNFTPrice(amount) == msg.value, " Please try to mint less Nfts.");
        require(mintStart, "Mint is not enabled.");
        require(mintSecound, "mintSecound is not enabled.");

        uint price  = getNFTPrice(amount);
    
        for (uint i = 0; i < amount; i++) { 
            safeMint(msg.sender);
        }

        uint amountWallet1 = (price * 20)/100;
        uint amountWallet2 = (price * 80)/100;

        _wallet1.transfer(amountWallet1);

        _wallet2.transfer(amountWallet2);
        
    }

    function safeMint(address to) private {
        uint256 tokenId = mintTokenID.current();
        mintTokenID.increment();
        _safeMint(to , tokenId);
        emit Mint(to , tokenId);
    }

    function changeBaseURI(string memory baseURI ) onlyOwner public {
       _setBaseURI(baseURI);
       emit ChangeBaseURI(baseURI);
    }

    function changeUnrevealedURI(string memory unrevealedUri) onlyOwner public{
        unrevealed = unrevealedUri;
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if(revealed){
            return string(abi.encodePacked(baseURI(), tokenId.toString(),'.json'));
        }else{
            return string(abi.encodePacked(unrevealed));
        }
    }   




    // Change BOOL

    function startSecondLaunchMinting() onlyOwner public {
        mintSecound = true;
    }

    function startFirstLaunchMinting() onlyOwner public {
        mintStart = true;
    }

    function changeUnrevealed(bool reveal) onlyOwner public {
        revealed = reveal;
    }

}
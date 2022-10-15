//SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;
import "./ERC721.sol";
import "./Counters.sol";
import "./Ownable.sol";
import "./ERC721Burnable.sol";
contract BOSSNFT is ERC721, ERC721Burnable, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter public _tokenIds;
  mapping(address => bool) public whitelist;
    event WhitelistUpdate(address indexed _address, bool statusBefore, bool status);



  constructor() public ERC721("BOSSNFT2000", "BOSSNFT2000")
  {
    _tokenIds.increment();
  }
  event Minted(address indexed owner, uint256 indexed id);


  function setBaseUri(string memory _uri) public onlyOwner {
	    _setBaseURI(_uri);
  }





    function mintBatch(address recipient, uint256 num,string memory uri) public onlyOwner  returns (bool) {

        uint256 newItemId = _tokenIds.current();

        for (uint i = 0; i < num; i++) {
            _safeMint(recipient, newItemId);
            _setTokenURI(newItemId, uri);
            _tokenIds.increment();
            newItemId = _tokenIds.current();
        }


        return true;
    }
    function mint(address recipient, string memory uri) external
    returns (uint256)
  {

        require(whitelist[msg.sender], "Not Whitelist");
        uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, uri);
        _tokenIds.increment();
        emit Minted(recipient, newItemId);
        return newItemId;
  }


    function setWhitelist(address _address,bool status) public onlyOwner {
        bool statusBefore = whitelist[_address];
        whitelist[_address] = status;
        emit WhitelistUpdate(_address,statusBefore, status);
    }

    function tranBatch(address from_,address to_, uint256 start_, uint256 nums_) public onlyOwner {

        uint256 nftid = start_;
         for (uint i = 0; i < nums_; i++) {
             safeTransferFrom(from_, to_, nftid.add(1));
        }


    }



}
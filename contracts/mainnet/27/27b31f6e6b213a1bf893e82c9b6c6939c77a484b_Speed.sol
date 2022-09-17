// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Burnable.sol";
import "./Ownable.sol";
import "./Counters.sol";

contract Speed is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Speed", "SPE") {}

    struct Car{
        address owner;
        uint token;         //nftid
    }

  

    mapping(address=>Car[])  ownerCars;
    Car[] cars;

    function _baseURI() internal pure override returns (string memory) {
        return "https://speedfi.oss-cn-shenzhen.aliyuncs.com/";
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    event CreateCarLog(address,uint256);

    function CreateCar(address _to,string memory _uri)  public onlyOwner returns (uint256){
        Car memory c;
        _tokenIdCounter.increment();
        uint256 _tokenId = _tokenIdCounter.current();
        c.token = _tokenId;
        c.owner = _to;
        ownerCars[_to].push(c);
        cars.push(c);
        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _uri);
        emit CreateCarLog(_to,_tokenId);
        return (_tokenId);
    }


    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }


    function getByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](balanceOf(_owner));
        uint counter = 0;
        for (uint i = 1; i <= _tokenIdCounter.current(); i++) {
            if (ownerOf(i) == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function getCar(address _owener,uint nftId ) external view returns (uint256 token, string memory uri){
        Car[] memory  cs = ownerCars[_owener];
        require(cs.length > 0, "Did not own cars");
        uri = tokenURI(nftId);
        for (uint i=0;i<cs.length;i++){
            Car memory tmpCar = cars[i];
            if (tmpCar.token == nftId){    
                return (tmpCar.token,uri);
            }
        }
        revert("Did not own cars!");
    }
   
}
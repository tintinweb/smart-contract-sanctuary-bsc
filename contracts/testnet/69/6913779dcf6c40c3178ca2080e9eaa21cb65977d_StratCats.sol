// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";


/*


   ______           __  _____     __    
  / __/ /________ _/ /_/ ___/__ _/ /____
 _\ \/ __/ __/ _ `/ __/ /__/ _ `/ __(_-<
/___/\__/_/  \_,_/\__/\___/\_,_/\__/___/
                                        
        https://catnfts.io

*/

contract StratCats is ERC721Enumerable, Ownable {

    using Strings for uint256;

    string _baseTokenURI;
    address addr_1 = 0x8F6d5bFb584bf1DfcebE44A38CEDC6fFBa08105d;
    uint256 private _reserved = 10;
    uint256 private _price = 0.3 ether;
    bool public _paused = true;

    constructor(string memory baseURI) ERC721("StratCats", "STRATCAT")  {
        setBaseURI(baseURI);

        //pre-minted
        uint256 premint = 3;
        for(uint256 i; i < premint; i++){
            _safeMint( addr_1, i );
        }

    }

    function purchase(uint256 num) public payable {
        uint256 supply = totalSupply();
        require( !_paused,                                "Sale paused" );
        require( num < 21,                              "You can purchase a maximum of 20 NFTs" );
        require( supply + num < 10000 - _reserved,      "Exceeds maximum NFTs supply" );
        require( msg.value >= _price * num,             "Ether sent is not correct" );

        for(uint256 i; i < num; i++){
            _safeMint( msg.sender, supply + i );
        }
    }

    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function setPrice(uint256 _newPrice) public onlyOwner() {
        _price = _newPrice;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getPrice() public view returns (uint256){
        return _price;
    }

    function giveAway(address _to, uint256 _amount) external onlyOwner() {
        require( _amount <= _reserved, "Exceeds reserved NFTs supply" );

        uint256 supply = totalSupply();
        for(uint256 i; i < _amount; i++){
            _safeMint( _to, supply + i );
        }

        _reserved -= _amount;
    }


    function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId) internal virtual override(ERC721Enumerable) {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    function pause(bool val) public onlyOwner {
        _paused = val;
    }

    function withdrawAll() public payable onlyOwner {
        uint256 _all = address(this).balance;
        require(payable(addr_1).send(_all));
    }
}
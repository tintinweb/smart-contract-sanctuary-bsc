//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./IERC20.sol";

contract KLingNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;
    IERC20 token = IERC20(0xDdDe0ab3838b8A0E4AdF54f8f67040f406Ef091F);  // Test token bsc testnet

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.0 ether;
    uint256 public presaleCost = 0.03 ether;
    uint256 public presaleTokenCost = 10 * 10**18; // 10 tokens 
    uint256 public maxSupply = 1000;
    uint256 public maxMintAmount = 0;
    address public feeAddress;
    bool public paused = false;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public presaleWallets;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        feeAddress = msg.sender;
        // mint(msg.sender, 1);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(address _to, uint256 tokenId, uint _tokenAmount) public {
        require(!paused);
        require(tokenId > 0);
        require(tokenId <= maxSupply);
        require(_tokenAmount >= presaleTokenCost, "Price is higher");
        require(token.allowance(msg.sender, address(this)) >= _tokenAmount, "Insufficient allowance");

        // if (msg.sender != owner()) {
        //     if (whitelisted[msg.sender] != true) {
        //         if (presaleWallets[msg.sender] != true) {
        //             //general public
        //             require(msg.value >= cost * _mintAmount);
        //         } else {
        //             //presale
        //             require(msg.value >= presaleCost * _mintAmount);
        //         }
        //     }
        // }
        token.transferFrom(msg.sender, feeAddress, _tokenAmount);
        _safeMint(_to, tokenId);
        // for (uint256 i = 1; i <= _mintAmount; i++) {
        //     _safeMint(_to, supply + i);
        // }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setPresaleCost(uint256 _newCost) public onlyOwner {
        presaleCost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function whitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function addPresaleUser(address _user) public onlyOwner {
        presaleWallets[_user] = true;
    }

    function add100PresaleUsers(address[100] memory _users) public onlyOwner {
        for (uint256 i = 0; i < 2; i++) {
            presaleWallets[_users[i]] = true;
        }
    }

    function removePresaleUser(address _user) public onlyOwner {
        presaleWallets[_user] = false;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}
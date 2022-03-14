pragma solidity 0.8.12;
// SPDX-License-Identifier: MIT
import "./BEP721Enumerable.sol";
import "./Ownable.sol";

contract NFT_Contract is BEP721Enumerable, Ownable {
    using Strings for uint256;
    mapping(address => uint256) public whitelistClaimed;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public publicCost = 0.002 ether;
    bool public paused = false;
    uint256 public maxPublic = 10;
    uint256 public AntiWhale = 1;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) BEP721(_name, _symbol) {
        setBaseURI(_initBaseURI);
    }

    function mint(uint256 quantity) external payable {
        uint256 supply = totalSupply();
        require(!paused, "The contract is paused!");
        require(quantity > 0, "Quantity Must Be Higher Than Zero");

        if (msg.sender != owner()) {
            require(
                quantity <= maxPublic,
                "You're Not Allowed To Mint more than maxMint Amount"
            );
            require(
                quantity + balanceOf(msg.sender) <= AntiWhale,
                "Amount is Bigger Than What You Can Mint"
            );
            require(msg.value >= publicCost * quantity, "Insufficient Funds");
        }
        for (uint256 i = 1; i <= quantity; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function airdrop(uint256 quantity, address[] memory _addresses)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            for (uint256 y = 0; y < quantity; y++) {
                _safeMint(_addresses[i], totalSupply() + 1);
            }
        }
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
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
            "BEP721Metadata: URI query for nonexistent token"
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

    function setCost(uint256 _publicCost) public onlyOwner {
        publicCost = _publicCost;
    }

    function setMaxAndAntiWhale(uint256 _public, uint256 _AntiWhale)
        public
        onlyOwner
    {
        maxPublic = _public;
        AntiWhale = _AntiWhale;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
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

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}
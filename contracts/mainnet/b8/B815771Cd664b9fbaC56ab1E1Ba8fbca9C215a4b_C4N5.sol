// File contracts/C4N5.sol

pragma solidity >=0.8.0 <0.9.0;

//SPDX-License-Identifier: MIT

import "./content.sol";

contract C4N5 is
    ERC721,
    ERC721Enumerable,
    ERC2981ContractWideRoyalties,
    Ownable
{
    using Strings for uint256;
    bool public saleIsActive = false;
    bool public revealed = false;
    address public rewardminerWallet;
    uint256 public maxTokenSupply;
    uint256 public pricePerToken = 300 ether;

    string public baseURI;
    string private _preRevealUri;
    string private _contractUri;

    address public ERC20Currency;

    event C4N5Activated(address owner, uint256 mintedId);

    constructor(
        uint256 _maxTokens,
        address _rewardMinerWallet,
        string memory contractUri,
        uint256 royaltyFee,
        string memory preRevealURI,
        address _busdAddress,
        address _owner
    ) ERC721("C4N5", "C4N5") {
        maxTokenSupply = _maxTokens;
        rewardminerWallet = _rewardMinerWallet;
        _contractUri = contractUri;
        _setRoyalties(_rewardMinerWallet, royaltyFee);
        _preRevealUri = preRevealURI;
        ERC20Currency = _busdAddress;
        transferOwnership(_owner);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        string memory __baseURI = baseURI;
        return __baseURI;
    }

    function contractURI() public view returns (string memory) {
        return _contractUri;
    }

    function _preRevealURI() internal view returns (string memory) {
        return _preRevealUri;
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

        if (revealed == false) {
            return _preRevealURI();
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        ".json"
                    )
                )
                : "";
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable, ERC2981Base)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mintToken(uint256 mintId) public payable returns (uint256) {
        require(
            saleIsActive == true,
            "Sale is not active. Cannot mint until it is activated."
        );
        require(mintId <= maxTokenSupply, "Cannot mint more than supply");
        require(!_exists(mintId), "Token has already been purchased");
        require(
            totalSupply() + 1 <= maxTokenSupply,
            "Cannot mint more than the token supply."
        );

        _safeMint(msg.sender, mintId);

        require(
            IERC20(ERC20Currency).transferFrom(
                msg.sender,
                rewardminerWallet,
                pricePerToken
            ),
            "ERC20: Transfer could not be completed."
        );

        emit C4N5Activated(msg.sender, mintId);
        return mintId;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function fundsReadyForWithdrawl() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(payable(rewardminerWallet).send(balance));
    }

    function setRewardMinerWallet(address _wallet) public onlyOwner {
        rewardminerWallet = _wallet;
    }

    function setContractURI(string memory newContractUri)
        public
        onlyOwner
        returns (string memory)
    {
        _contractUri = newContractUri;
        return _contractUri;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setPreRevealURI(string memory preRevealURI) public onlyOwner {
        _preRevealUri = preRevealURI;
    }

    function setPurchasePrice(uint256 newPrice) public onlyOwner {
        require(newPrice != pricePerToken, "Proposed price is already set");
        pricePerToken = newPrice;
    }

    function setTokenSupply(uint256 newSupply) public onlyOwner {
        require(newSupply != maxTokenSupply, "Proposed supply is already set");
        require(newSupply > maxTokenSupply, "Supply can only be increased");
        maxTokenSupply = newSupply;
    }

    function setPurchasingCurrency(address newCurrency) public onlyOwner {
        require(newCurrency != ERC20Currency, "already set");
        require(newCurrency != address(0));
        require(newCurrency != address(this));
        ERC20Currency = newCurrency;
    }

    function setRoyalties(address recipient, uint256 value) public onlyOwner {
        require(
            value >= 0 && value <= 10000,
            "Royalty value cannot be b/w 0 and 10000. Value is in bps"
        );
        require(
            recipient != address(this),
            "Recipient cannot be the current contract"
        );
        _setRoyalties(recipient, value);
    }
}
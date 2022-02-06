//SPDX-License-Identifier: MIT

import "./libs...ERC721.sol";
import "./libs...Counters.sol";
import "./libs...Context.sol";
import "./libs...IERC20.sol";
import "./libs...Strings.sol";
// import "./IBEP20.sol";
import "./IPancakePair.sol";
import "./IPancakeswapV2Factory.sol";
import "./IPancakeswapV2Router02.sol";
import "./Ref.sol";

pragma solidity ^0.8.0;

contract Temp is ERC721, Ownable {
    using Counters for Counters.Counter;

    struct ReferrerEntity {
        uint256 creationTime;
        address account;
        string referrerCode;
        uint256 rewardAmount;
        bool isReferred;
        bool isOutDeadline;
    }

    mapping(address => string[]) private _subRefOfUser;
    mapping(string => ReferrerEntity) private _refInfoOfUser;
    mapping(address => string) private _userOfAccount;

    Counters.Counter private _tokenIds;
    mapping (uint256 => string) private _tokenURIs;

    RefToken public token;
    IPancakeswapV2Router02 public pancakeswapV2Router;

    address public tokenAddress = 0xc39ed113b8cf23f8370C9DC127D44c1D06E232D4;

    uint256 public refFee = 33;
    uint256 public escowFee = 33;
    uint256 public primaryFee = 75;

    address public primaryDevAddress = 0xCE048999dCa1e5895496E12b2458e02d137e1be2;
    address public secondaryDevAddress = 0xf31B2199C6322d6275a6f36bC4d338e15637C56A;

    uint256 public referralDeadline = 100 * 60;
    uint256 public mintingPrice = 100;
    uint256 public mintingPriceWithRef = 75;
    string public baseTokenURI;

    constructor() ERC721("tokenName", "symbol") {
        token = RefToken(tokenAddress);
        // Test Net
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //Mian Net
        // IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeswapV2Router = _pancakeswapV2Router;
        
    }

    function getTokenPrice(address token1, uint256 amount) public view returns(uint256)
    {
        IpancakeswapV2Pair pair = IpancakeswapV2Pair(0xe0e92035077c39594793e61802a350347c320cf2);
        (uint256 Res0, uint256 Res1,) = pair.getReserves();

        uint256 res0 = Res0*(10**9);
        uint256 BNBPrice = res0/Res1;

        address pairAddress = getPairAddress(token1);
        pair = IpancakeswapV2Pair(pairAddress);
        (Res0, Res1,) = pair.getReserves();

        // decimals
        res0 = Res0*(10**9);
        uint256 tokenAmountInBNB =res0/Res1; 

        return (amount * (10**24))/(BNBPrice * tokenAmountInBNB);
    }

   function getPairAddress(address token1) public view returns(address) {
       address pancakeswapV2Pair = IPancakeswapV2Factory(pancakeswapV2Router.factory()).getPair(token1, pancakeswapV2Router.WETH());
       return pancakeswapV2Pair;
   }
    
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(from == address(0), "You can't transfer this NFT.");
        
        super._transfer(from, to, tokenId);
    }

    function mintNFT(address owner, string memory metadataURI) public returns (uint256)
    {
        _tokenIds.increment();

        uint256 id = _tokenIds.current();
        _safeMint(owner, id);
        _setTokenURI(id, metadataURI);
        return id;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // If there is no base URI, return the token URI.
        if (bytes(baseTokenURI).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(baseTokenURI, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId)));
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function getReferrerEntity(string memory usercode) public view returns (uint256) {
        return _refInfoOfUser[usercode].creationTime;
    }

    function createAvatarWithoutReferrer(string memory usercode, string memory metadataURI) public returns (uint256) {
        require(_msgSender() != address(0), "Zero address couldn't create avatar");
        payToMintWithoutReferrer(_msgSender(), usercode);
        uint256 id = mintNFT(_msgSender(), metadataURI);
        return id;
    }

    function createAvatarWithReferrer(string memory usercode, string memory referrerCode, string memory metadataURI) public returns (uint256) {
        require(_msgSender() != address(0), "Zero address couldn't create avatar");
        payToMintWithReferrer(_msgSender(), usercode, referrerCode);
        uint256 id = mintNFT(_msgSender(), metadataURI);
        return id;
    }

    function createAvatarWithReferrer(string memory usercode, address referrerAddress, string memory metadataURI) public returns (uint256) {
        require(_msgSender() != address(0), "Zero address couldn't create avatar");
        payToMintWithReferrer(_msgSender(), usercode, _userOfAccount[referrerAddress]);
        uint256 id = mintNFT(_msgSender(), metadataURI);
        return id;
    }

    function payToMintWithoutReferrer(address creator, string memory usercode) public returns (bool) {
        require(bytes(_userOfAccount[creator]).length < 2, "Account has already minted an NFT.");
        require(bytes(usercode).length > 2, "ERROR:  user code shouldn't be empty");
        require(creator != address(0), "CSHT:  creation from the zero address");
        require(_refInfoOfUser[usercode].account == address(0), "usercode is already used");

        _refInfoOfUser[usercode] = ReferrerEntity({
            creationTime: block.timestamp,
            account: creator,
            referrerCode: "",
            rewardAmount: 0,
            isReferred: false,
            isOutDeadline: false
        });
        _userOfAccount[creator] = usercode;

        uint256 tokenAmount = getTokenPrice(tokenAddress, mintingPrice);
        uint256 primaryAmount = (tokenAmount * primaryFee) / 100;
        uint256 secondaryAmount = tokenAmount - primaryAmount;
        
        // token.pay(creator, primaryDevAddress, primaryAmount * 10**12);
        // token.pay(creator, secondaryDevAddress, secondaryAmount * 10**12);

        token.transferFrom(creator, address(this), tokenAmount);
        token.transfer(secondaryDevAddress, secondaryAmount * 10**12);
        token.transfer(primaryDevAddress, primaryAmount * 10**12);

        return true;
    }

    function payToMintWithReferrer(address creator, string memory usercode, string memory referrerCode) public returns (bool) {
        // require(keccak256(bytes(usercode)) != keccak256(bytes("")), "ERROR:  user code shouldn't be empty");
        require(bytes(_userOfAccount[creator]).length < 2, "Account has already minted an NFT.");
        require(bytes(usercode).length > 2, "ERROR:  user code shouldn't be empty");
        require(bytes(referrerCode).length > 2, "ERROR:  referrer code shouldn't be empty");
        require(creator != address(0), "CSHT:  creation from the zero address");
        require(_refInfoOfUser[referrerCode].account != address(0), "usercode is already used");
        require(_refInfoOfUser[referrerCode].account != creator, "creator couldn't be same as referrer");

        uint256 tokenAmount = getTokenPrice(tokenAddress, mintingPriceWithRef);
        uint256 escrowAmount = (tokenAmount * escowFee) / 100;
        uint256 refAmount = (tokenAmount * refFee) / 100;
        uint256 devAmount = tokenAmount - escrowAmount - refAmount;

        ReferrerEntity memory _ref = _refInfoOfUser[referrerCode];
        _subRefOfUser[_ref.account].push(usercode);

        if (_ref.isOutDeadline != true && bytes(_ref.referrerCode).length > 2)
        {
            ReferrerEntity memory _parentRef = _refInfoOfUser[_ref.referrerCode];
            ReferrerEntity storage _refT = _refInfoOfUser[referrerCode];
            if (block.timestamp - _ref.creationTime < referralDeadline) {
                token.pay(secondaryDevAddress, _parentRef.account, _ref.rewardAmount * 10**12);    
                _refT.isReferred = true;
            } else {
                _refT.isReferred = false;
            }
            _refT.isOutDeadline = true;
        }

        // token.pay(creator, _ref.account, refAmount * 10**12);
        // token.pay(creator, secondaryDevAddress, escrowAmount * 10**12);
        // token.pay(creator, primaryDevAddress, devAmount * 10**12);

        token.transferFrom(creator, address(this), tokenAmount);
        token.transfer( _ref.account, refAmount * 10**12);
        token.transfer(secondaryDevAddress, escrowAmount * 10**12);
        token.transfer(primaryDevAddress, devAmount * 10**12);

        // transfer(creator, this)
        // transfer(primary, 75)
        // transfer( secondary, 25)

        _refInfoOfUser[usercode] = ReferrerEntity({
            creationTime: block.timestamp,
            account: creator,
            referrerCode: referrerCode,
            rewardAmount: escrowAmount,
            isReferred: false,
            isOutDeadline: false
        });
        _userOfAccount[creator] = usercode;

        return true;
    }

    function getSubReferral(address account) external view returns (string memory) {
        require(_subRefOfUser[account].length > 0, "GET SUB REFERRERS: NO SUB REFERRER");
        string[] memory subRefs = _subRefOfUser[account];
        ReferrerEntity memory _ref;
        string memory refsStr = "";
        string memory separator = "#";
        
        for (uint256 i=0; i<subRefs.length; i++) {
            _ref = _refInfoOfUser[subRefs[i]];
            refsStr = string(abi.encodePacked(
                refsStr, 
                separator, _userOfAccount[_ref.account], 
                separator, toAsciiString(_ref.account), 
                separator, Strings.toString(_ref.creationTime), 
                separator, Strings.toString(_ref.rewardAmount)
            ));

            if (_ref.isReferred == true) {
                string[] memory childRefStrs = _subRefOfUser[_ref.account];
                ReferrerEntity memory _childRef = _refInfoOfUser[childRefStrs[0]];
                refsStr = string(abi.encodePacked(refsStr, separator, "1", separator, Strings.toString(_childRef.creationTime)));
            } else {
                refsStr = string(abi.encodePacked(refsStr, separator, "0", separator, "0"));
            }
            if (_ref.isOutDeadline == true) {
                refsStr = string(abi.encodePacked(refsStr, separator, "1"));
            } else {
                refsStr = string(abi.encodePacked(refsStr, separator, "0"));
            }
        }

        return refsStr;
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function setBaseToken(address newAddress) external onlyOwner {
        require(newAddress!=tokenAddress, "New token address is same as old one");
        tokenAddress = newAddress;
        token = RefToken(newAddress);
    }

    function getbalanceOf(address account) public view returns (uint256) {
        return token.balanceOf(account);
    }

    function getUsercode() external view returns (string memory) {
        return _userOfAccount[_msgSender()];
    }

    function getMintPrice() external view returns (uint256) {
        return mintingPrice;
    }

    function setMintingPrice(uint256 newMintingPrice) external onlyOwner {
        mintingPrice = newMintingPrice;
    }

    function getMintPriceWithRef() external view returns (uint256) {
        return mintingPriceWithRef;
    }

    function setMintingPriceWithRef(uint256 newMintingPriceWithRef) external onlyOwner {
        mintingPriceWithRef = newMintingPriceWithRef;
    }

    function getDevAddresses() external view returns (address, address) {
        return (primaryDevAddress, secondaryDevAddress);
    }

    function setPrimaryDevAddress(address newAddress) external onlyOwner {
        require(newAddress!=primaryDevAddress, "New primary dev address is same as old one");
        primaryDevAddress = newAddress;
    }

    function setSecondaryDevAddress(address newAddress) external onlyOwner {
        require(newAddress!=secondaryDevAddress, "New secondary dev address is same as old one");
        secondaryDevAddress = newAddress;
    }

    function getReferreralDeadline() external view returns (uint256) {
        return referralDeadline;
    }
    
    function changeReferreralDeadline(uint256 newDeadline) public onlyOwner {
        referralDeadline = newDeadline;
    }

    function changeRefFee(uint256 value) external onlyOwner {
        refFee = value;
    }

    function changeEscowFee(uint256 value) external onlyOwner {
        escowFee = value;
    }

    function changePrimaryFee(uint256 value) external onlyOwner {
        primaryFee = value;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }
}
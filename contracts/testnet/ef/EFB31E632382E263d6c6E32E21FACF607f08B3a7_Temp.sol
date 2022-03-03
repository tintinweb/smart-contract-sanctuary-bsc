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
        bool isUSDC;
    }

    mapping(address => string[]) private _subRefOfUser;
    mapping(string => ReferrerEntity) private _refInfoOfUser;
    mapping(address => string) private _userOfAccount;
    mapping(address => uint256) private _ownerOfId;
    mapping(address => bool) public _isWhitelisted;

    Counters.Counter private _tokenIds;
    mapping (uint256 => string) private _tokenURIs;

    RefToken public token;
    IPancakeswapV2Router02 public pancakeswapV2Router;

    address public tokenAddress = 0xe941BA500FEa83e44493FB9CA14434B451C51B7c;
    address public stableCoinAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    uint256 public refFee = 33;
    uint256 public escowFee = 33;
    uint256 public primaryFee = 75;

    address public primaryDevAddress = 0x7d3ce4545b08438e4FBb90d20254727e2abc5F5C;
    address public secondaryDevAddress = 0x74Da1434992Cc098c11B6359A7ddBCa9D97A0af5;
    address public secondaryDevAddressForToken = 0xcaA5b83953B9330b1Bd4ecFFF8B83a8645b5E328;

    uint256 public referralDeadline = 100 * 60;
    uint256 public mintingPrice = 10;
    uint256 public mintingPriceWithRef = 8;
    string public baseTokenURI;
    bool public isUSDCForNoRef = false;
    bool public isUSDCForRef = true;

    constructor() ERC721("tokenName", "symbol") {
        token = RefToken(tokenAddress);
        // Test Net
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //Mian Net
        // IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeswapV2Router = _pancakeswapV2Router;
        
    }
    
    function swapTokensForUSDC(uint256 tokenAmount, address to) public {
        // generate the pancakeswap pair path of token -> busd
        address[] memory path = new address[](3);
        path[0] = tokenAddress;
        path[1] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        path[2] = stableCoinAddress;

        IERC20(tokenAddress).approve(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3, tokenAmount);

        // make the swap
        pancakeswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );
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
        _ownerOfId[_msgSender()] = id;
        return id;
    }

    function createAvatarWithReferrer(string memory usercode, string memory referrerCode, string memory metadataURI) public returns (uint256) {
        require(_msgSender() != address(0), "Zero address couldn't create avatar");
        payToMintWithReferrer(_msgSender(), usercode, referrerCode);
        uint256 id = mintNFT(_msgSender(), metadataURI);
        _ownerOfId[_msgSender()] = id;
        return id;
    }

    function payToMintWithoutReferrer(address creator, string memory usercode) public returns (bool) {
        require(bytes(_userOfAccount[creator]).length < 2, "Account has already minted an NFT.");
        require(bytes(usercode).length > 1 && bytes(usercode).length < 16, "ERROR:  user code shouldn't be empty");
        require(creator != address(0), "CSHT:  creation from the zero address");
        require(_refInfoOfUser[usercode].account == address(0), "usercode is already used");

        _refInfoOfUser[usercode] = ReferrerEntity({
            creationTime: block.timestamp,
            account: creator,
            referrerCode: "",
            rewardAmount: 0,
            isReferred: false,
            isOutDeadline: false,
            isUSDC: isUSDCForNoRef
        });
        _userOfAccount[creator] = usercode;

        if (isWhitelisted(creator)) return true;
        uint256 tokenAmount = getTokenPrice(tokenAddress, mintingPrice);
        uint256 primaryAmount = (tokenAmount * primaryFee) / 100;
        uint256 secondaryAmount = tokenAmount - primaryAmount;
        
        // token.pay(creator, primaryDevAddress, primaryAmount * 10**12);
        // token.pay(creator, secondaryDevAddress, secondaryAmount * 10**12);

        token.transferFrom(creator, address(this), tokenAmount * 10**12);

        if (isUSDCForNoRef) {
            swapTokensForUSDC(secondaryAmount* 10**12, secondaryDevAddress);
            swapTokensForUSDC(primaryAmount* 10**12, primaryDevAddress);
        } else {
            token.transfer(secondaryDevAddress, secondaryAmount * 10**12);
            token.transfer(primaryDevAddress, primaryAmount * 10**12);
        }
        return true;
    }

    function payToMintWithReferrer(address creator, string memory usercode, string memory referrerCode) public returns (bool) {
        // require(keccak256(bytes(usercode)) != keccak256(bytes("")), "ERROR:  user code shouldn't be empty");
        require(bytes(_userOfAccount[creator]).length < 2, "Account has already minted an NFT.");
        require(bytes(usercode).length > 1 && bytes(usercode).length < 16, "ERROR:  user code shouldn't be empty");
        require(_refInfoOfUser[usercode].account == address(0), "usercode is already used");
        require(bytes(referrerCode).length > 1 && bytes(referrerCode).length < 16, "ERROR:  referrer code shouldn't be empty");
        require(creator != address(0), "CSHT:  creation from the zero address");
        require(_refInfoOfUser[referrerCode].account != address(0), "usercode is already used");
        require(_refInfoOfUser[referrerCode].account != creator, "creator couldn't be same as referrer");

        uint256 tokenAmount = getTokenPrice(tokenAddress, mintingPriceWithRef);
        uint256 escrowAmount = (tokenAmount * escowFee) / 100;
        uint256 refAmount = (tokenAmount * refFee) / 100;
        uint256 devAmount = tokenAmount - escrowAmount - refAmount;

        ReferrerEntity memory _ref = _refInfoOfUser[referrerCode];
        _subRefOfUser[_ref.account].push(usercode);

        if (_ref.isOutDeadline != true && bytes(_ref.referrerCode).length > 1)
        {
            ReferrerEntity memory _parentRef = _refInfoOfUser[_ref.referrerCode];
            ReferrerEntity storage _refT = _refInfoOfUser[referrerCode];
            if (block.timestamp - _ref.creationTime < referralDeadline) {
                // token.pay(secondaryDevAddress, _parentRef.account, _ref.rewardAmount * 10**12);
                if(_ref.isUSDC) {
                    IERC20(stableCoinAddress).transferFrom(secondaryDevAddress, address(this), _ref.rewardAmount);
                    IERC20(stableCoinAddress).transfer(_parentRef.account, _ref.rewardAmount);
                } else {
                    token.transferFrom(secondaryDevAddress, address(this), _ref.rewardAmount);
                    token.transfer(_parentRef.account, _ref.rewardAmount);
                }
                _refT.isReferred = true;
            } else {
                _refT.isReferred = false;
            }
            _refT.isOutDeadline = true;
        }

        // token.pay(creator, _ref.account, refAmount * 10**12);
        // token.pay(creator, secondaryDevAddress, escrowAmount * 10**12);
        // token.pay(creator, primaryDevAddress, devAmount * 10**12);
        token.transferFrom(creator, address(this), tokenAmount * 10 ** 12);

        if (!isUSDCForRef) {
            token.transfer(secondaryDevAddress, escrowAmount * 10**12);
            token.transfer(primaryDevAddress, devAmount * 10**12);
        } else {
            swapTokensForUSDC( refAmount * 10**12, _ref.account );
            uint256 _balanceOfStableCoin = IERC20(stableCoinAddress).balanceOf(secondaryDevAddress);
            swapTokensForUSDC( escrowAmount * 10**12, secondaryDevAddress );
            uint256 balanceOfStableCoin_ = IERC20(stableCoinAddress).balanceOf(secondaryDevAddress);
            token.transfer(secondaryDevAddressForToken, devAmount * 10**12);
            escrowAmount = balanceOfStableCoin_ -  _balanceOfStableCoin;
        }

        _refInfoOfUser[usercode] = ReferrerEntity({
            creationTime: block.timestamp,
            account: creator,
            referrerCode: referrerCode,
            rewardAmount: escrowAmount,
            isReferred: false,
            isOutDeadline: false,
            isUSDC: isUSDCForRef
        });
        _userOfAccount[creator] = usercode;

        return true;
    }

    // function isCodeAvailable(string memory code) public view returns(bool) {
    //     return ( 
    //         _refInfoOfUser[code].creationTime==0 && 
    //         bytes(code).length > 1 && 
    //         bytes(code).length < 16
    //     );              
    // }

    function whitelist(address account, bool value)
        external
        onlyOwner
    {
        _isWhitelisted[account] = value;
    }

    function isWhitelisted(address account)
        public
        view
        returns(bool)
    {
        return _isWhitelisted[account];
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

    function getIdOfUser(address account) public view returns (uint256) {
        require(account != address(0), "address CAN'T BE ZERO");
        return _ownerOfId[account];
    }

    function getUsercode(address account) external view returns (string memory) {
        return _userOfAccount[account];
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

    function setSecondaryDevAddressForToken(address newAddress) external onlyOwner {
        require(newAddress!=secondaryDevAddressForToken, "New secondary dev address for token is same as old one");
        secondaryDevAddressForToken = newAddress;
    }

    function setIsUSDCForNoRef(bool _value) external onlyOwner {
        require(_value!=isUSDCForNoRef, "New value is same as old one");
        isUSDCForNoRef = _value;
    }

    function setIsUSDCForRef(bool _value) external onlyOwner {
        require(_value!=isUSDCForRef, "New value is same as old one");
        isUSDCForRef = _value;
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
//SPDX-License-Identifier: MIT

import "./ERC721Upgradeable.sol";
import "./Counters.sol";
import "./IBEP20.sol";
import "./StringsUpgradeable.sol";
import "./IPancakePair.sol";
import "./IPancakeswapV2Factory.sol";
import "./IPancakeswapV2Router02.sol";
import "./Initializable.sol";
import "./OwnableUpgradabl.sol";
import "./ContextUpgradeable.sol";

pragma solidity ^0.8.0;

contract ChadInuVIPLogic is Initializable, OwnableUpgradeable, ERC721Upgradeable {
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
    mapping(address => uint256) private _ownerOfId;
    mapping(address => bool) public _isWhitelisted;

    Counters.Counter private _tokenIds;
    mapping (uint256 => string) private _tokenURIs;

    IBEP20 public token;
    IPancakeswapV2Router02 public pancakeswapV2Router;

    address public tokenAddress;
    address public stableCoinAddress;

    uint256 public refFee;
    uint256 public escowFee;
    uint256 public primaryFee;

    address public secondaryDevAddress;
    address public escrowDevAddress;
    address public gateKeeper;

    uint256 public referralDeadline;
    uint256 public mintingPrice;
    uint256 public mintingPriceWithRef;
    string public baseTokenURI;
    bool public isUSDCForNoRef;
    bool public isUSDCForRef;
    
    event NFTMinted (
        uint256 tokenId,
        address account,
        string usercode,
        string referrerCode,
        string metadataUri
    );
 
    function initialize()  public initializer {
        tokenAddress = 0xB470d90C43fF0Ca0A65ef56fAffA027a537B2FAF;
        
        __ERC721_init_unchained("Chadinu VIP Card", "VIP Card");
        __Ownable_init_unchained();
        token = IBEP20(tokenAddress);
        gateKeeper = msg.sender;
        
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeswapV2Router = _pancakeswapV2Router;
        
        stableCoinAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

        refFee = 33;
        escowFee = 33;
        primaryFee = 75;

        secondaryDevAddress = 0xC040e348fC48Ecd2ab355499211BF208B3891837;
        escrowDevAddress = 0xd1fF3d44Ee616b9D21e6AddF2fC347daDd25a550;

        referralDeadline = 86400 * 14;
        mintingPrice = 2 * 10**18;
        mintingPriceWithRef = 1 * 10**18;
        isUSDCForNoRef = false;
        isUSDCForRef = false;
    }

    modifier onlySentry() {
        require(msg.sender == tokenAddress || msg.sender == owner(), "Access Denied");
        _;
    }
    
    function swapTokensForUSDC(uint256 tokenAmount, address to) private {
        // generate the pancakeswap pair path of token -> busd
        address[] memory path = new address[](3);
        path[0] = tokenAddress;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // address of wbnb
        path[2] = stableCoinAddress;

        IBEP20(tokenAddress).approve(address(pancakeswapV2Router), tokenAmount);

        // make the swap
        pancakeswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );
    }

    function getTokenPrice(address token1, uint256 amount) public view returns(uint256)
    {
        address _pancakeSwapV2Pair = getPairAddress(stableCoinAddress);
        IpancakeswapV2Pair pair = IpancakeswapV2Pair(_pancakeSwapV2Pair);
        (uint256 Res0, uint256 Res1,) = pair.getReserves();
        
        uint256 res1 = Res1*(10**9);
        uint256 BNBPrice = res1/Res0;

        address pairAddress = getPairAddress(token1);
        pair = IpancakeswapV2Pair(pairAddress);
        (Res0, Res1,) = pair.getReserves();

        uint256 tokenAmountInBNB;
        if (address(this) > pancakeswapV2Router.WETH()) {
            res1 = Res1*(10**9);
            tokenAmountInBNB = res1/Res0;
        } else {
            uint256 res0 = Res0*(10**9);
            tokenAmountInBNB = res0/Res1; 
        }
        
        return (amount * BNBPrice)/tokenAmountInBNB;
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

    function mintNFT(address owner, string memory metadataURI) internal returns (uint256)
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
        return string(abi.encodePacked(baseTokenURI, StringsUpgradeable.toString(tokenId)));
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function MintVIPCard(string memory usercode, string memory metadataURI) external returns (uint256) {
        require(_msgSender() != address(0), "Zero address couldn't create avatar");
        payToMintWithoutReferrer(_msgSender(), usercode);
        uint256 id = mintNFT(_msgSender(), metadataURI);
        _ownerOfId[_msgSender()] = id;
        emit NFTMinted(id, _msgSender(), usercode, "", metadataURI);
        return id;
    }

    function MintVIPCardWithReferreral(string memory usercode, string memory referrerCode, string memory metadataURI) external returns (uint256) {
        require(_msgSender() != address(0), "Zero address couldn't create avatar");
        payToMintWithReferrer(_msgSender(), usercode, referrerCode);
        uint256 id = mintNFT(_msgSender(), metadataURI);
        _ownerOfId[_msgSender()] = id;
        emit NFTMinted(id, _msgSender(), usercode, referrerCode, metadataURI);
        return id;
    }

    function payToMintWithoutReferrer(address creator, string memory usercode) internal returns (bool) {
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
            isOutDeadline: false
        });
        _userOfAccount[creator] = usercode;

        if (_checkWhitelisted(creator)) return true;
        uint256 tokenPrice = getTokenPrice(tokenAddress, 10**18);
        uint256 tokenAmount = (mintingPrice*10**18)/tokenPrice;
        
        if (isUSDCForNoRef) {
            token.transferFrom(creator, address(this), tokenAmount);
            swapTokensForUSDC(tokenAmount, secondaryDevAddress);
        } else {
            token.transferFrom(creator, secondaryDevAddress, tokenAmount);
        }
        return true;
    }

    function payToMintWithReferrer(address creator, string memory usercode, string memory referrerCode) internal returns (bool) {
        require(bytes(_userOfAccount[creator]).length < 2, "Account has already minted an NFT.");
        require(bytes(usercode).length > 1 && bytes(usercode).length < 16, "ERROR:  user code shouldn't be empty");
        require(_refInfoOfUser[usercode].account == address(0), "usercode is already used");
        require(bytes(referrerCode).length > 1 && bytes(referrerCode).length < 16, "ERROR:  referrer code shouldn't be empty");
        require(creator != address(0), "CSHT:  creation from the zero address");
        require(_refInfoOfUser[referrerCode].account != address(0), "referrer code is not exisiting");
        require(_refInfoOfUser[referrerCode].account != creator, "creator couldn't be same as referrer");

        uint256 tokenPrice = getTokenPrice(tokenAddress, 10**18);
        uint256 tokenAmount = (mintingPriceWithRef*10**18)/tokenPrice;
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
                IBEP20(stableCoinAddress).transferFrom(escrowDevAddress, _parentRef.account, _ref.rewardAmount);
                _refT.isReferred = true;
            } else {
                _refT.isReferred = false;
            }
            _refT.isOutDeadline = true;
        }

        token.transferFrom(creator, address(this), tokenAmount);
        swapTokensForUSDC( refAmount, _ref.account );
        uint256 _balanceOfStableCoin = IBEP20(stableCoinAddress).balanceOf(escrowDevAddress);
        swapTokensForUSDC( escrowAmount, escrowDevAddress );
        uint256 balanceOfStableCoin_ = IBEP20(stableCoinAddress).balanceOf(escrowDevAddress);
        uint256 rewardAmount = balanceOfStableCoin_ -  _balanceOfStableCoin;

        if (!isUSDCForRef) {
            token.transfer(secondaryDevAddress, devAmount);
        } else {
            swapTokensForUSDC( devAmount, secondaryDevAddress);
        }

        _refInfoOfUser[usercode] = ReferrerEntity({
            creationTime: block.timestamp,
            account: creator,
            referrerCode: referrerCode,
            rewardAmount: rewardAmount,
            isReferred: false,
            isOutDeadline: false
        });
        _userOfAccount[creator] = usercode;

        return true;
    }

    function isCodeAvailable(string memory code) external view returns(bool) {
        return ( 
            _refInfoOfUser[code].creationTime==0 && 
            bytes(code).length > 1 && 
            bytes(code).length < 16
        );              
    }

    function whitelist(address account, bool value)
        external
        onlySentry()
    {
        _isWhitelisted[account] = value;
    }

    function addWhitelistByToken(address account, bool value)
        external
    {
        require(msg.sender == tokenAddress || msg.sender == owner(), "Access Denied");
        _isWhitelisted[account] = value;
    }

    function _checkWhitelisted(address account)
        public
        view
        returns(bool)
    {
        return _isWhitelisted[account];
    }

    function checkWhitelisted(address account)
        external
        view
        returns(bool)
    {
        return _checkWhitelisted(account);
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
                separator, StringsUpgradeable.toString(_ref.creationTime), 
                separator, StringsUpgradeable.toString(_ref.rewardAmount)
            ));

            if (_ref.isReferred == true) {
                string[] memory childRefStrs = _subRefOfUser[_ref.account];
                ReferrerEntity memory _childRef = _refInfoOfUser[childRefStrs[0]];
                refsStr = string(abi.encodePacked(refsStr, separator, "1", separator, StringsUpgradeable.toString(_childRef.creationTime)));
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

    receive() external payable {}

    function setBaseToken(address newAddress) external onlyOwner {
        require(newAddress!=tokenAddress, "New token address is same as old one");
        tokenAddress = newAddress;
        token = IBEP20(newAddress);
    }

    function changePancakeswapRouter(address newRouter) external onlyOwner {
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(newRouter);
        pancakeswapV2Router = _pancakeswapV2Router;
    }

    function getbalanceOf(address account) external view returns (uint256) {
        return token.balanceOf(account);
    }

    function getIdOfUser(address account) external view returns (uint256) {
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
        return (secondaryDevAddress, escrowDevAddress);
    }


    function setSecondaryDevAddress(address newAddress) external onlyOwner {
        require(newAddress!=secondaryDevAddress, "New secondary dev address is same as old one");
        secondaryDevAddress = newAddress;
    }

    function setEscrowDevAddress(address newAddress) external onlyOwner {
        require(newAddress!=escrowDevAddress, "New escrow dev address is same as old one");
        escrowDevAddress = newAddress;
    }

    function setStableCoinAddress(address _stableCoinAddress) external onlyOwner {
        stableCoinAddress = _stableCoinAddress;
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
    
    function changeReferreralDeadline(uint256 newDeadline) external onlyOwner {
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

    function setBaseURI(string memory baseURI) external onlyOwner {
        baseTokenURI = baseURI;
    }
}
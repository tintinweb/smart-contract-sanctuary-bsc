// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "./IDexGoNFT.sol";
import 'base64-sol/base64.sol';
import "./IDexGoRentAndKm.sol";


contract DexGoStorage is Ownable {
    AggregatorV3Interface internal priceFeed;
    using SafeMath for uint256;

    address public accountTeam1 = address(0xC98834f2De2Eb9c97FFbdF2E4952535D2D4bC1A1);
    address public accountTeam2 = address(0x1cea85b1148bEAD4D40316BC4D5270f70425B79C);
    function getAccountTeam1() public view returns (address) {
        return accountTeam1;
    }
    function setAccountTeam1(address _accountTeam1) public onlyOwner {
        accountTeam1 = _accountTeam1;
    }
    function getAccountTeam2() public view returns (address) {
        return accountTeam2;
    }
    function setAccountTeam2(address _accountTeam2) public onlyOwner {
        accountTeam2 = _accountTeam2;
    }

    address public usdt;
    function getUSDT() public view returns (address) {
        return usdt;
    }
    function setUSDT(address _usdt) public onlyOwner {
        usdt = _usdt;
    }

    address public rentAndKm;
    function setRentAndKm(address _rentAndKm) public onlyOwner {
        rentAndKm = _rentAndKm;
    }
    function getRentAndKm() public view returns (address) {
        return rentAndKm;
    }

    uint256 public minimalFeeInUSD;
    uint256 public priceMainCoinUSD;
    function getPriceMainCoinUSD() public view returns (uint256) {
        return priceMainCoinUSD;
    }
    function setPriceMainCoinUSD(uint256 price) public onlyOwner {
        priceMainCoinUSD = price;
    }

    function getLatestPrice() public view returns (uint256, uint8) {
        if (priceMainCoinUSD > 0) return (priceMainCoinUSD, 18);

        (,int256 price,,,) = priceFeed.latestRoundData();
        uint8 decimals = priceFeed.decimals();
        return (uint256(price), decimals);
    }

    function valueInMainCoin(uint8 typeNft) public view returns (uint256) {
        uint256 priceMainToUSDreturned;
        uint8 decimals;
        (priceMainToUSDreturned,decimals) = getLatestPrice();
        uint256 valueToCompare = priceForType[typeNft].mul(10 ** decimals).div(priceMainToUSDreturned);
        return valueToCompare;
    }

    mapping(address => uint256) latestPurchaseTime;
    function getLatestPurchaseTime(address wallet) public view returns (uint256) {
        return latestPurchaseTime[wallet];
    }
    function setLatestPurchaseTime(address wallet, uint timestamp) public  {
        require(msg.sender == nftContract || msg.sender == gameServer || msg.sender == owner() || msg.sender == rentAndKm,'ADM');
        latestPurchaseTime[wallet] = timestamp;
    }

    mapping(uint8 => string) nameForType;
    function setNameForType(string memory _nameForType, uint8 typeNft) public onlyOwner {
        nameForType[typeNft] = _nameForType;
    }
    function getNameForType(uint8 typeNft) public view returns (string memory)  {
        return nameForType[typeNft] ;
    }

    mapping(uint8 => string) descriptionForType;
    function setDescriptionForType(string memory _descriptionForType, uint8 typeNft) public onlyOwner {
        descriptionForType[typeNft] = _descriptionForType;
    }
    function getDescriptionForType(uint8 typeNft) public view returns (string memory)  {
        return descriptionForType[typeNft] ;
    }

    mapping(uint8 => string) imageForTypeMaxKm;
    function setImageForTypeMaxKm(string memory _imageForType, uint8 typeNft) public onlyOwner {
        imageForTypeMaxKm[typeNft] = _imageForType;
    }
    function getImageForTypeMaxKm(uint8 typeNft) public view returns (string memory)  {
        return imageForTypeMaxKm[typeNft] ;
    }

    mapping(uint8 => string) imageForType75PercentKm;
    function setImageForType75PercentKm(string memory _imageForType, uint8 typeNft) public onlyOwner {
        imageForType75PercentKm[typeNft] = _imageForType;
    }
    function getImageForType75PercentKm(uint8 typeNft) public view returns (string memory)  {
        return imageForType75PercentKm[typeNft] ;
    }

    mapping(uint8 => string) imageForType50PercentKm;
    function setImageForType50PercentKm(string memory _imageForType, uint8 typeNft) public onlyOwner {
        imageForType50PercentKm[typeNft] = _imageForType;
    }
    function getImageForType50PercentKm(uint8 typeNft) public view returns (string memory)  {
        return imageForType50PercentKm[typeNft] ;
    }

    mapping(uint8 => string) imageForType25PercentKm;
    function setImageForType25PercentKm(string memory _imageForType, uint8 typeNft) public onlyOwner {
        imageForType25PercentKm[typeNft] = _imageForType;
    }
    function getImageForType25PercentKm(uint8 typeNft) public view returns (string memory)  {
        return imageForType25PercentKm[typeNft] ;
    }

    mapping(uint8 => uint256) counterForType;
    function getCounterForType(uint8 typeNft) public view returns (uint256) {
        return counterForType[typeNft];
    }
    function increaseCounterForType(uint8 typeNft) public {
        require(msg.sender == owner() || msg.sender == nftContract, "ORC");
        counterForType[typeNft] = counterForType[typeNft] + 1;
        if (limitForType[typeNft] > 0) require(counterForType[typeNft] < limitForType[typeNft], "EOL");
    }

    mapping(uint8 => uint256) limitForType;
    function setLimitForType(uint256 limit, uint8 typeNft) public onlyOwner {
        limitForType[typeNft] = limit;
    }
    function getLimitForType(uint8 typeNft) public view returns (uint256) {
        return limitForType[typeNft];
    }

    mapping(uint8 => uint256) priceForType;
    function setPriceForType(uint256 price, uint8 typeNft) public {
        require(msg.sender == owner() || msg.sender == nftContract, "ORC");
        priceForType[typeNft] = price;
    }
    function getPriceForType(uint8 typeNft) public view returns (uint256) {
        return priceForType[typeNft];
    }
    mapping(uint8 => uint256) priceInitialForType;
    function setPriceInitialForType(uint256 price, uint8 typeNft) public onlyOwner {
        priceInitialForType[typeNft] = price;
    }
    function getPriceInitialForType(uint8 typeNft) public view returns (uint256) {
        return priceInitialForType[typeNft];
    }

    mapping(uint256 => uint8) typeForId;
    function getTypeForId(uint256 tokenId) public view returns (uint8) {
        return typeForId[tokenId];
    }
    function setTypeForId(uint256 tokenId, uint8 typeNft) public {
        require(msg.sender == owner() || msg.sender == nftContract, "ORC");
        typeForId[tokenId] = typeNft;
    }

    mapping(uint => string) inAppPurchaseInfo;
    function setInAppPurchaseData(string memory _inAppPurchaseInfo, uint tokenId) public  {
        require(msg.sender == owner() || msg.sender == nftContract, "ORC");
        inAppPurchaseInfo[tokenId] = _inAppPurchaseInfo;
        if (bytes(_inAppPurchaseInfo).length > 0) setInAppPurchaseBlackListTokenId(tokenId, true);
    }
    function getInAppPurchaseData(uint tokenId) public view returns(string memory) {
        return inAppPurchaseInfo[tokenId];
    }
    mapping(uint256 => bool) inAppPurchaseBlackListTokenId;
    function setInAppPurchaseBlackListTokenId(uint256 tokenId, bool isBlackListed) public onlyOwner {
        inAppPurchaseBlackListTokenId[tokenId] = isBlackListed;
    }
    function getInAppPurchaseBlackListTokenId(uint256 tokenId) public view returns(bool) {
        return inAppPurchaseBlackListTokenId[tokenId];
    }
    mapping(address => bool) inAppPurchaseBlackListWallet;
    function setInAppPurchaseBlackListWallet(address wallet, bool isBlackListed) public onlyOwner {
        inAppPurchaseBlackListWallet[wallet] = isBlackListed;
    }
    function getInAppPurchaseBlackListWallet(address wallet) public view returns(bool) {
        return inAppPurchaseBlackListWallet[wallet];
    }

    uint public valueDecrease = 100000000000000000;
    function setValueDecrease(uint _valueDecrease) public onlyOwner {
        valueDecrease = _valueDecrease;
    }
    function getValueDecrease() public view returns(uint) {
        return valueDecrease;
    }

    function setupType(
        uint8 _type,
        uint256 _price,
        uint256 _limit,
        string memory _name,
        string memory _description,
        string memory _image
    ) private {
        priceForType[_type] = _price;
        priceInitialForType[_type] = _price;
        limitForType[_type] = _limit;
        nameForType[_type] = _name;
        descriptionForType[_type] = _description;
        imageForTypeMaxKm[_type] = _image;
        imageForType75PercentKm[_type] = _image;
        imageForType50PercentKm[_type] = _image;
        imageForType25PercentKm[_type] = _image;
    }

    constructor(uint256 networkId, address _nftContract) {
        nftContract =_nftContract;
        if (networkId == 1)  priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // ETH mainnet
        if (networkId == 4) priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);// ETH rinkeby
        if (networkId == 42) priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);// ETH kovan
        if (networkId == 56) priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);// BCS mainnet
        if (networkId == 97) priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);// BCS testnet
        if (networkId == 80001) priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);// Matic testnet
        if (networkId == 137) priceFeed = AggregatorV3Interface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);// Matic mainnet
        if (networkId == 1001) {
            priceMainCoinUSD = 283500000000000000;// klaytn testnet
        }
        minimalFeeInUSD = 500000000000000000; // $0.5

        uint startPrice = 0.01 ether;
        if (networkId == 137) startPrice = 10 ether;
        if (networkId == 97) valueDecrease = 1000000;

        setupType(SHOES0, startPrice, 0, "Downtrodden nerds",
            "Downtrodden Nerds are those favorite sneakers with which you went through fire, water and copper pipes. Joint memories do not allow you to replace them with a new couple. A budget model for the start, with which you will definitely overcome 10 km per day. Shoes are easy to repair and go with them on a new trip. Walk confidently, take care of your health and know that coins are already jingling on your account.\nDexGo is a move to earn project that has made a splash in the NFT games market. Now the usual routine of maintaining an active lifestyle is turning into a full-fledged process of moneymaking and interactive interaction with space in augmented reality technology. Unlike standard games of this type, DexGo opens familiar city locations from new, completely unexpected sides.",
            "Shoes1.gif");
        setupType(SHOES1, startPrice + 1 * startPrice / 10, 0, "Inconspicuous walkers",
            "Fans of classic sneakers will definitely fall in love with this pair. Sleek silhouette, practical materials and running comfort are the formula for the success of the inconspicuous walkers. This pair is an ideal partner in daily steps, mastering new routes and effectively replenishing the crypto piggy bank. You can easily overcome 11 km non-stop with it. After a hike, sneakers can be restored for further walks.\nDiscover new facets of augmented reality NFT games with the DexGo project. Let your daily activity turn into an exciting quest with valuable rewards. DexGo is a care for the physical form and an opportunity to discover new facets of the familiar reality.",
            "Shoes2.gif");
        setupType(SHOES2, startPrice + 2 * startPrice / 10, 0, "High runners",
            "Faster, higher, stronger - this is the only way you will complete routes in futuristic high runners. This model is a real find for lovers of tourism. Fast lacing, a tread that prevents trips, slips and falls, and an innovative foam platform to cover long distances of 12 km without repair - that's what makes these stylish beauties so popular.\nLet your love of long walking bear fruit. DexGo is a project with which hiking becomes brighter and turns into money. Walk, earn cryptocurrency and master new routes within the framework of the project for the benefit of the body and soul.",
            "Shoes3.gif");
        setupType(SHOES3, startPrice + 3 * startPrice / 10, 0, "Pink walkers",
            "Pink Walkers - NFT-candy, with which it has become even easier to lose weight and keep fit. Universal handsome men will add zest to your moneymaker arsenal. Walking 13 km? It's easy if you have these caramels on! After overcoming the 13-kilometer distance, the shoes must be restored. And then - you can conquer new horizons of your favorite city.\nDexGo is a game that wins the hearts of fans of interactive NFT projects in the move to earn style by leaps and bounds. It is chosen for its interactivity and the ability to film your trip, addictive gameplay and fair cash payments, the size of which depends only on you. This is the only project that takes care of your activity and leisure. Support for daily steps, exciting adventures on the routes - DexGo has something to surprise you.",
            "Shoes4.gif");
        setupType(SHOES4, startPrice + 4 * startPrice / 10, 0, "White boosters",
            "White Boosters are sneakers that will definitely take you back to the future. Futuristic high-ankle sneakers protect against injuries during the route, help to collect the maximum of bonuses and rewards, and cover up to 14 kilometers without recovery. Stylish, spectacular, profitable - this is the motto of the owners of this snow-white couple.\nDexGo is a new era in the blockchain space. Thanks to the project, you will be able to charge yourself with a cocktail of vivacity, explore interesting routes and replenish your pocket with crypto!",
            "Shoes5.gif");
        setupType(SHOES5, startPrice + 5 * startPrice / 10, 0, "Rushing forward",
            "Elegant Jordans in an expensive and spectacular gray-crimson shade - that's the key to success! Rushing Forward are the shoes of real champions, who are not ready for half measures in matters of money making. Shoes will easily help to overcome 15 km without restoration and repair. Be sure that in these sneakers you are not afraid of extra pounds and poor health.\nDiscover new unexplored locations on the DexGo travel maps and go on a journey of the future with us. The NFT game will change your idea of earning money, investing and a profitable hobby. You just need to take a step, and after him another ...",
            "Shoes6.gif");
        setupType(SHOES6, startPrice + 6 * startPrice / 10, 0, "Elegant Winners",
            "From premium leather and stylish lacing to a lightweight sole and perforated surface, everything is perfect. Elegant winners are a couple created for success, discovery and long 16 km walks in the fresh air. To be restored after passing its distance. Walk confidently, meet other users on the route and discover familiar locations from a new, unknown side.\nDexGo is a fresh take on the beloved move to lose weight and earn money game. The project not only provides walking with 100% liquidity, but also opens up promising locations for an exciting game. Open the portal from the NFT universe to reality in a beautiful, spectacular and profitable way!",
            "Shoes7.gif");
        setupType(SHOES7, startPrice + 7 * startPrice / 10, 0, "Robots",
            "Robots are a design of the future. Every step in them is like soaring on the clouds. The bold and slightly aggressive visual of robots literally screams to its future owner - We will conquer this world!. Toe protection, comfortable tread, no fuss with lacing - this pair is made for true winners. Robot rovers are not afraid of ultra-long distances and can easily cover 17 km with you. After undergoing repairs, they are ready to conquer new peaks of the routes.\nTurn, walking into cryptocurrency gold with DexGo. Earn blockchain assets quickly, confidently and for the benefit of your well-being! The game allows you to fatten up your wallet by burning your calories while exploring city routes at the same time.",
            "Shoes8.gif");
        setupType(SHOES8, startPrice + 8 * startPrice / 10, 0, "Hidden pioneers",
            "Hidden Pioneers is the very case when space potential is hidden behind a laconic pair of sneakers. Handsome men with a bold and memorable design are just waiting for their opportunity to walk with you without repairing an 18-kilometer marathon along interesting routes developed.\nAllow yourself the luxury of wellness walks around the city and start making money doing what you love with DexGo. Turn your steps into real money and enjoy the activity with the sound of coins.",
            "Shoes9.gif");
        setupType(SHOES9, startPrice + 9 * startPrice / 10, 0, "Top Talkers",
            "TikTok fans will squeal with delight when they try on these sneakers - because finally you can earn money yourself from the audience and videos. Signature leather tone and lacing, reliable Velcro that fixes the pair on the ankles, will help you overcome the 19-kilometer distance in one go without stopping for repairs. Top Talkers will inspire you to record an exciting video of the route, for which the owner receives a decent cash. At the same time, shoes will not leave a single hope for long distances to doubt their strength and reliability. Top Talkers are a unique DexGo product that reveals the routes of popularity.\nThe profitable DexGo project contains all the delights of the project's capabilities within walking distance: interesting routes of your favorite city, video filming of a walk, interactive and, of course, a decent reward for active participation. Turn your movement into real money and a stellar adventure!",
            "Shoes10.gif");
        setupType(MAGIC_BOX, startPrice + 3 * startPrice / 10, 0, "Magic Box",
            "The most unpredictable character. The Magic Box is the ultimate opportunity to own a pair of DexGo shoes for just $11. What kind of sneakers will be in your chest - is decided randomly after opening it. It is quite possible that it is you who will be lucky enough to become the owner of ultra-hardy Top Talkers at a price half that of the market price. Trust fate and catch luck by the tail.\nDexGo is a project about movement, willpower training and unexplored routes of light earnings. The game was created for pumping a healthy lifestyle for a decent income. Take care of your body, recharge your emotions and discover new city locations.",
            "MagicBox.gif");
    }

    // shoes:
    uint8 public constant SHOES0 = 0;
    uint8 public constant SHOES1 = 1;
    uint8 public constant SHOES2 = 2;
    uint8 public constant SHOES3 = 3;
    uint8 public constant SHOES4 = 4;
    uint8 public constant SHOES5 = 5;
    uint8 public constant SHOES6 = 6;
    uint8 public constant SHOES7 = 7;
    uint8 public constant SHOES8 = 8;
    uint8 public constant SHOES9 = 9;
    uint8 public constant MAGIC_BOX = 10;

    uint8 public constant PATH = 100;
    uint8 public constant MOVIE = 200;

    uint256 balanceOf;
//    mapping(uint256 => address) public pathsOwners;

    address public nftContract;
    function _setNftContract(address _nftContract) public onlyOwner {
        nftContract =_nftContract;
    }
    function getNftContract() public view returns (address) {
        return nftContract;
    }
    address public dexGo;
    function getDexGo() public view returns (address) {
        return dexGo;
    }
    function setDexGo(address _dexGo) public onlyOwner {
        dexGo = _dexGo;
    }

    address public handshakeLevels;
    function setHandshakeLevels(address _handshakeLevels) public onlyOwner {
        handshakeLevels = _handshakeLevels;
    }
    function getHandshakeLevels() public view returns (address) {
        return handshakeLevels;
    }

    address public gameServer;
    function setGameServer(address _gameServer) public onlyOwner {
        gameServer = _gameServer;
    }
    function getGameServer() public view returns (address) {
        return gameServer;
    }

    string public ipfsRoot = "https://openbisea.mypinata.cloud/ipfs/QmVY4T92soWYtjx57hJnEoLv7efPgZtyQBaQTwArswdXBr/";// "https://openbisea.mypinata.cloud/ipfs/QmVww6AoULsNxeMfQeyXfk6EN7syspR285MbiqqMdU1Vob/" - old
    function setIpfsRoot(string memory _ipfsRoot) public onlyOwner {
        ipfsRoot = _ipfsRoot;
    }
    function getIpfsRoot() public view returns (string memory)  {
        return ipfsRoot;
    }

    uint public nameChangeFee = 0.001 ether;
    function setNameChangeFee(uint _nameChangeFee) public onlyOwner {
        nameChangeFee = _nameChangeFee;
    }
    mapping(uint => string) public namesChangedForNFT;
    function getNamesChangedForNFT(uint _tokenId) public view returns (string memory)  {
        return namesChangedForNFT[_tokenId];
    }
    function setNameForNFT(uint256 _tokenId, string memory _name) public payable {
        require(IDexGoNFT(nftContract).isApprovedOrOwner(msg.sender, _tokenId), "NO");
        require(msg.value == nameChangeFee, "IA");
        Address.sendValue(payable(nftContract), nameChangeFee);
        IDexGoNFT(nftContract).distributeMoney(msg.sender, nameChangeFee);
        namesChangedForNFT[_tokenId] = _name;
    }

    address [] pastContracts;
    function setPastContracts(address [] memory _pastContracts) public onlyOwner {
        pastContracts = _pastContracts;
    }
    function getPastContracts() public view returns (address [] memory) {
        return pastContracts;
    }

    function tokenURIForType(uint8 typeNft, string memory nameReplaced, uint256 tokenId)
    public
    view
    returns (string memory)
    {
        string memory image = getImageForTypeMaxKm(typeNft);
        if (getKmLeavesForId(tokenId) * 100 / getPriceInitialForType(typeNft) < 25) image = getImageForType25PercentKm(typeNft);
        if (getKmLeavesForId(tokenId) * 100 / getPriceInitialForType(typeNft) < 50) image = getImageForType50PercentKm(typeNft);
        if (getKmLeavesForId(tokenId) * 100 / getPriceInitialForType(typeNft) < 75) image = getImageForType75PercentKm(typeNft);

        if (bytes(nameReplaced).length == 0) nameReplaced = getNameForType(typeNft);
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            nameReplaced,
                            '", "description":"',
                            getDescriptionForType(typeNft),
                            '", "image": "',
                            string(abi.encodePacked(getIpfsRoot(),image)),
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function tokenURI(uint256 tokenId)
    public
    view returns (string memory) {
        return tokenURIForType(getTypeForId(tokenId), getNamesChangedForNFT(tokenId), tokenId);
    }

    uint256 public fixedAmountOwner = 0.001 ether;
    function setFixedAmountOwner(uint _fixedAmountOwner) public onlyOwner {
        fixedAmountOwner = _fixedAmountOwner;
    }
    function getFixedAmountOwner() public view returns (uint256) {
        return fixedAmountOwner;
    }

    uint256 public fixedAmountProject = 0.001 ether;
    function setFixedAmountProject(uint _fixedAmountProject) public onlyOwner {
        fixedAmountProject = _fixedAmountProject;
    }
    function getFixedAmountProject() public view returns (uint256) {
        return fixedAmountProject;
    }

    uint public minRentalTimeInSeconds = 120;
    function setMinRentalTimeInSeconds(uint _minRentalTimeInSeconds) public onlyOwner {
        minRentalTimeInSeconds = _minRentalTimeInSeconds;
    }
    function getMinRentalTimeInSeconds() public view returns (uint) {
        return minRentalTimeInSeconds;
    }

    mapping(uint256 => uint256) kmLeavesForId;
    function setKmForId(uint256 tokenId, uint256 km) public {
        require(msg.sender == getDexGo() || msg.sender == getNftContract() || msg.sender == getGameServer() || msg.sender == owner() || msg.sender == rentAndKm,'only admin accounts can change km');
        kmLeavesForId[tokenId] = km;
    }
    function getKmLeavesForId(uint256 tokenId) public view returns (uint256) {
        return kmLeavesForId[tokenId];
    }

    uint256 public fixedRepairAmountProject = 0.001 ether;
    function setFixedRepairAmountProject(uint _fixedRepairAmountProject) public onlyOwner {
        fixedRepairAmountProject = _fixedRepairAmountProject;
    }
    function getFixedRepairAmountProject() public view returns (uint256) {
        return fixedRepairAmountProject;
    }

    mapping(uint256 => uint256) public repairFinishTime;
    function getRepairFinishTime(uint tokenId) public view returns (uint) {
        return repairFinishTime[tokenId];
    }
    function setRepairFinishTime(uint tokenId, uint timestamp) public  {
        require(msg.sender == getNftContract() || msg.sender == getGameServer() || msg.sender == owner() || msg.sender == rentAndKm,'only admin accounts can change');
        repairFinishTime[tokenId] = timestamp;
    }

    mapping(uint256 => uint256) public repairCount;
    function getRepairCount(uint tokenId) public view returns (uint) {
        return repairCount[tokenId];
    }
    function setRepairCount(uint tokenId, uint count) public {
        require(msg.sender == getNftContract() || msg.sender == getGameServer() || msg.sender == owner() || msg.sender == rentAndKm,'only admin accounts can change ');
        repairCount[tokenId] = count;
    }

    uint256 public fixedApprovalAmount = 0.001 ether;
    function setFixedApprovalAmount(uint _fixedApprovalAmount) public onlyOwner {
        fixedApprovalAmount = _fixedApprovalAmount;
    }
    function getFixedApprovalAmount() public view returns (uint256) {
        return fixedApprovalAmount;
    }

    uint256 public fixedPathApprovalAmount = 0.001 ether; // $50
    function setFixedPathApprovalAmount(uint _fixedPathApprovalAmount) public onlyOwner {
        fixedPathApprovalAmount = _fixedPathApprovalAmount;
    }
    function getFixedPathApprovalAmount() public view returns (uint256) {
        return fixedPathApprovalAmount;
    }

    mapping(uint256 => uint) public kmForPath;
    function getKmForPath(uint _tokenId) public view returns (uint)  {
        return kmForPath[_tokenId];
    }
    function setKmForPath(uint256 _tokenId, uint km) public {
        require(msg.sender == getDexGo() ||msg.sender == getNftContract() || msg.sender == getGameServer() || msg.sender == owner() || msg.sender == rentAndKm,'only admin accounts can change ');
        kmForPath[_tokenId] = km;
    }



}

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;
interface IDexGoRentAndKm {
  //  function getKmLeavesForId(uint256 tokenId) external view returns (uint256);
//    function setKmForId(uint256 tokenId, uint256 km) external;
    function rentParameters(uint _tokenId) external view returns (bool, uint, address);
}

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code

pragma solidity ^0.8.2;
interface IDexGoNFT {
//    function getTypeForId(uint256 tokenId) external view returns (uint8);
//    function getKmLeavesForId(uint256 tokenId) external view returns (uint256);
//    function getPriceForType(uint8 typeNft) external view returns (uint256);
//    function getGameServer() external returns (address);
//    function getApprovedPathOrMovie(uint tokenId) external view returns (bool);
//    function getInAppPurchaseBlackListWallet(address wallet) external view returns(bool);
//    function getInAppPurchaseBlackListTokenId(uint tokenId) external view returns(bool);
    function isApprovedOrOwner(address sender, uint256 tokenId) external view returns(bool);
    function distributeMoney(address sender, uint value) external;
    function getTokenIdCounterCurrent() external view returns (uint);
//    function getPriceInitialForType(uint8 typeNft) external view returns (uint256);
//    function setLatestPurchaseTime(address wallet, uint timestamp) external;
    function approveMainContract(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
//    function ownerOf(uint256 tokenId) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/// @title Base64
/// @author Brecht Devos - <[email protected]>
/// @notice Provides functions for encoding/decoding base64
library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}
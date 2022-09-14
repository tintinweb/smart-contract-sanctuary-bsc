//SPDX-License-Identifier: Copyright Grobat
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Burnable.sol";
import "./ERC721Pausable.sol";
import "./ERC721URIStorage.sol";
import "./AccessControlEnumerable.sol";
import "./Context.sol";
import "./Strings.sol";
import "./Counters.sol";



interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IDividendDistributor {
    function addShare(address shareholder) external payable;
    function deposit() external payable;
    function process(uint256 gas) external;
    function getUnpaidEarnings(address autostakingcontract) external view returns (uint256);
    function distributeToken() external;
    function setContractInitial(address contadmin) external payable;
    function setMintedOut(address mintedOutContract)external;
}

interface IAutostakingContract {
    function getMaxSupply() external view returns (uint max);
    function getMinted() external view returns (uint minted);
    function getStoragePrice() external view  returns (uint storagePrice);
    function getMintPrice() external view returns (uint mintPrice);
    function getPayableToken() external view returns (address tokenAddress);
    function addTokenToBuy(IBEP20 TokenToAdd, uint percent) external;
    function setFeeReciever(address reciever)external;
    function excludeFromrewardMultiple(address[] calldata Adds) external;
    function getReflectionBalances() external view returns(uint256);
    function claimRewards() external;
    function recoverStuckToken (IBEP20 token) external;
    function claimTokens () external;
    function mintMany(uint256 quantity) external payable;
    function setMintingEnabled(bool Allowed) external;
    function claimRewardsInToken() external;
}


/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - token ID and URI autogenerationA
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract autostaking is Context, AccessControlEnumerable, ERC721Enumerable, ERC721URIStorage, IAutostakingContract{
  using Counters for Counters.Counter;

  struct  buyableTokens{
    IBEP20 buyableToken;
    uint256 percentage;
  }
  
  
  Counters.Counter public _tokenIdTracker;

  string private _baseTokenURI;
  string public _contractMeta;
  uint private _tokenPrice = 25 * 10**18;
  uint private _price = 1 * 10**16; 
  uint public maxSupply = 10000;
  address private _admin;
  address private _feeReciever;
  IDEXRouter public router;
  IDividendDistributor public distributor;
  bool public canMint = false;
  uint public mintPercentage;
  IBEP20 public payableToken;
  uint256 public totalReflectionVolume;
  uint256 public totalCollected;
  uint256 public artistPercent = 2;
  bool public isAutostaking = true;
  address WBNB;
  address deadAddress = 0x000000000000000000000000000000000000dEaD;
  address public artistFeeReciever;
  
  buyableTokens[] public tokensToBuy;
  
  uint256 public reflectionBalance;
  uint256 public totalDividend;

  mapping(uint256 => uint256) lastDividendAt;
  mapping (uint256 => address ) public creator;
  mapping (address => bool) public excludedFromRewards; 

  uint256 private mintAMount = 100;
  uint256 public totalrewards = 0;



  constructor(string memory name, string memory symbol, uint mintPrice, uint storagePrice, uint mintReflect, uint max, address admin, IDividendDistributor dist) ERC721(name, symbol) {
      _tokenPrice = mintPrice;
      maxSupply = max;
      _admin = admin;
      _price = storagePrice;
      mintPercentage = mintReflect;
      router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet
      _setupRole(DEFAULT_ADMIN_ROLE, admin);
      _setupRole(DEFAULT_ADMIN_ROLE, address(dist));
      distributor = dist;
      WBNB = address(router.WETH());
  }

  receive () external payable {
     //payable(_admin).transfer(msg.value); 
     reflectDividend(msg.value);
  }

  function setPayableToken(IBEP20 token)external{
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "autostaking: must have admin role to set payable token");
    payableToken = token;
  }

  function contractURI() public view returns (string memory) {
        return _contractMeta;
  }

  function SetcontractURI(string calldata URI) external {
        require(msg.sender == address(_admin), "autostaking: only the distributor can add this meta");
        _contractMeta = URI;
  }

  function getMinted() external view override returns (uint minted){
    return _tokenIdTracker.current();
  }

  function getMaxSupply() external view override returns (uint max){
    return maxSupply;
  }

  function getPayableToken() external view override returns (address tokenAddress){
    return address(payableToken);
  }

  function getStoragePrice() external view override returns (uint storagePrice){
    return _price;
  }

  function getMintPrice() external view override returns (uint mintPrice){
    return _tokenPrice;
  }

  function setAdditionalAdmin(address newAdmin) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "autostaking: must have admin role to add admins");
    _setupRole(DEFAULT_ADMIN_ROLE, newAdmin);
  } 


  function excludeFromrewardMultiple(address[] calldata Adds) external override {
    require(msg.sender == address(_admin), "autostaking: must have admin role to add exclusions");
    for(uint i = 0; i< Adds.length; i++){
      excludedFromRewards[Adds[i]] = true;
    }
  } 

  function _baseURI() internal view virtual override returns (string memory) {
      return _baseTokenURI;
  }

   function setFeeReciever(address reciever)public override {
    require(msg.sender == address(_admin), "autostaking: must have admin role to change fee reciever_admin");
    _feeReciever = reciever;
  }

  function setBaseURI(string memory baseURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "autostaking: must have admin role to change base URI");
    _baseTokenURI = baseURI;
  }

  function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "autostaking: must have admin role to change token URI");
    _setTokenURI(tokenId, _tokenURI);
  }

  function setMintingEnabled(bool Allowed) external override {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "autostaking: must have admin role to change minting ability");
    canMint = Allowed;
  }


  function getServiceFee() external view returns(uint256){
    return _price;
  }
 

  function mintMany(uint256 quantity) external payable override {
    require(canMint, "autostaking: minting currently disabled");
    require (quantity < 11, "autostaking: minting more than 10 is prohibited");
    require(msg.value >= (quantity * _price), "autostaking: must send correct price");
    require((_tokenIdTracker.current() + quantity) < maxSupply, "autostaking: all autostaking have been minted");
    require(payableToken.allowance(msg.sender, address(this)) >= _tokenPrice * quantity, "Autostaking: You must approve BUSD spend first" );
    IBEP20(payableToken).transferFrom(msg.sender, address(this), _tokenPrice * quantity);
    for(uint i = 0; i < quantity; i++){
      _mint(msg.sender, _tokenIdTracker.current());
      creator[_tokenIdTracker.current()] = msg.sender;
      lastDividendAt[_tokenIdTracker.current()] = totalDividend;
      _setTokenURI(_tokenIdTracker.current(), string(abi.encodePacked(Strings.toString(_tokenIdTracker.current()), ".json")));
      _tokenIdTracker.increment();
    }
    if(_tokenIdTracker.current() == maxSupply){
        distributor.setMintedOut(address(this));
    }
    splitBalance(quantity);
  }
  
  function mintMultiples(address[] calldata recipients)public {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "autostaking: must have admin role to initial mint");
        for (uint256 i = 0; i < recipients.length; i++){
      _mint(recipients[i], _tokenIdTracker.current());
      creator[_tokenIdTracker.current()] = recipients[i];
      lastDividendAt[_tokenIdTracker.current()] = totalDividend;
      _setTokenURI(_tokenIdTracker.current(), string(abi.encodePacked(Strings.toString(_tokenIdTracker.current()), ".json")));
      _tokenIdTracker.increment();
    }
  }

  function NftCreator(uint256 tokenId) public view returns(address){
    return creator[tokenId];
  }

  function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
    return ERC721URIStorage._burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return ERC721URIStorage.tokenURI(tokenId);
  }
  
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
    if (totalSupply() > tokenId) claimReward(tokenId);
    super._beforeTokenTransfer(from, to, tokenId);
  }

  /**
    * @dev See {IERC165-supportsInterface}.
    */
  function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function currentRate() public view returns (uint256){
      if(totalSupply() == 0) return 0;
      return reflectionBalance/totalSupply();
  }

  function claimRewards() public override{
    uint count = balanceOf(msg.sender);
    uint256 total = 0;
    for(uint i=0; i < count; i++){
        uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
        //claimReward(tokenId);
        total += getReflectionBalance(tokenId);
        lastDividendAt[tokenId] = totalDividend;
    }
    if(total > 0){
        payable(msg.sender).transfer(total);
        reflectionBalance -= total;
    }
  }

  function claimRewardsInToken() external override{
    uint count = balanceOf(msg.sender);
    uint256 total = 0;
    for(uint i=0; i < count; i++){
        uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
        //claimReward(tokenId);
        total += getReflectionBalance(tokenId);
        lastDividendAt[tokenId] = totalDividend;
    }
    if(total > 0){
        address[] memory path = new address[](2);
            path[1] = router.WETH();
            path[0] = address(payableToken);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: total}(
          0,
          path,
          msg.sender,
          block.timestamp + 20
        );
        reflectionBalance -= total;
    }
  }


  function claimReward(uint tokenId) internal {
    uint256 total = getReflectionBalance(tokenId);
    if(total > 0){
      reflectionBalance -= total;
      if(!excludedFromRewards[ownerOf(tokenId)]){
         payable(ownerOf(tokenId)).transfer(total);
      }else{
        reflectDividend(total);
      }
     
      lastDividendAt[tokenId] = totalDividend;
    }
  }

  function getReflectionBalances() public view override returns(uint256) {
    uint count = balanceOf(msg.sender);
    uint256 total = 0;
    for(uint i=0; i < count; i++){
        uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
        total += getReflectionBalance(tokenId);
    }
    return total;
  }

  function claimTokens () external override {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "autostaking: must have admin role to claim the balance");
    // make sure we capture all BNB that may or may not be sent to this contract
    payable(_admin).transfer(address(this).balance - reflectionBalance);
  }

  function recoverStuckToken (IBEP20 token) external override{
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "autostaking: must have admin role to claim the balance");
    // make sure we capture all BNB that may or may not be sent to this contract
    token.transfer(msg.sender, token.balanceOf(address(this)));
  }

  function getReflectionBalance(uint256 tokenId) public view returns (uint256){
      return totalDividend - lastDividendAt[tokenId];
  }

  function addTokenToBuy(IBEP20 TokenToAdd, uint percent) external override{
    require(msg.sender == address(_admin), "autostaking: only the distributor can add a token");
    buyableTokens memory token;
    token.buyableToken = TokenToAdd;
    token.percentage = percent;
    tokensToBuy.push(token);
  }

  function splitBalance(uint256 amount) private {
      uint tokenAmount = amount * _tokenPrice; // get the total token price to sell for reflection purchases
      uint storageFee = amount * _price; // get the storage fee for IPFS fees
      payable(_feeReciever).transfer(storageFee);
      uint balanceBefore = address(this).balance;
      address[] memory path = new address[](2);
      uint deadline = block.timestamp;
      uint totaltoDistribute;
      if(payableToken != IBEP20(WBNB)){
          payableToken.approve(address(router), payableToken.balanceOf(address(this)));
            path[0] = address(payableToken);
            path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            payableToken.balanceOf(address(this)),
            0,
            path,
            address(this),
            deadline
        );
        totaltoDistribute = address(this).balance - balanceBefore; // we have our balance
      }else{
          totaltoDistribute = tokenAmount;
      }
      uint removed = 0;
      /*
        now we create a loop to buy each token with a percentage of totalTo distribute
        struct  buyableTokens{
          IBEP20 buyableToken;
          uint256 percentage;
        }
      */
      for(uint i = 0; i < tokensToBuy.length; i++){
        path[0] = router.WETH();
        path[1] = address(tokensToBuy[i].buyableToken);
        uint amounttobuy = totaltoDistribute * tokensToBuy[i].percentage / 100;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amounttobuy}(
          0,
          path,
          address(deadAddress),
          deadline
        );
        removed += amounttobuy;
      }

      payable(_admin).transfer(totaltoDistribute - removed);
  }

  function reflectDividend(uint256 amount) private {
    reflectionBalance  = reflectionBalance + amount;
    totalDividend = totalDividend + (amount/totalSupply());
    totalCollected += amount;
    totalReflectionVolume += amount;
  } 
}
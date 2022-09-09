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
contract legitcryptoNFT is Context, AccessControlEnumerable, ERC721Enumerable, ERC721URIStorage{
  using Counters for Counters.Counter;

  struct  buyableTokens{
    IBEP20 buyableToken;
    uint256 percentage;
  }
  
  
  Counters.Counter public _tokenIdTracker;

  string private _baseTokenURI;
  string public _contractMeta;
  uint private _tokenPrice = 25 * 10**18;
  uint public maxSupply = 10000;
  address private _admin;
  address public _feeReciever;
  IDEXRouter public router;
  bool public canMint = false;
  uint public mintPercentage;
  IBEP20 public payableToken;
  uint256 public totalReflectionVolume;
  uint256 public totalCollected;
  uint256 public artistPercent = 2;
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

  event RewardPaid(address indexed paidAddress, uint256 value);


  constructor(string memory name, string memory symbol, uint mintPrice, uint max, address admin) ERC721(name, symbol) {
      _tokenPrice = mintPrice;
      maxSupply = max;
      _admin = admin;
      
      router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet
      _setupRole(DEFAULT_ADMIN_ROLE, admin);
      WBNB = address(router.WETH());
  }

  receive () external payable {

     
  }

  function wenmint() public view returns(string memory wen){
    return "fuck off";
  }

  function setPayableToken(IBEP20 token)external{
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to set payable token");
    payableToken = token;
  }

  function contractURI() public view returns (string memory) {
        return _contractMeta;
  }

  function SetcontractURI(string calldata URI) external {
        require(msg.sender == address(_admin), "legitcrypto: only the distributor can add this meta");
        _contractMeta = URI;
  }

  function getMinted() external view  returns (uint minted){
    return _tokenIdTracker.current();
  }

  function getMaxSupply() external view  returns (uint max){
    return maxSupply;
  }

  function getPayableToken() external view returns (address tokenAddress){
    return address(payableToken);
  }

    function setPrice(uint price) external {
      require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to change price");
      _tokenPrice == price * 10 ** 18;

  }


  function getMintPrice() external view returns (uint mintPrice){
    return _tokenPrice;
  }

  function setAdditionalAdmin(address newAdmin) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to add admins");
    _setupRole(DEFAULT_ADMIN_ROLE, newAdmin);
  } 

  function _baseURI() internal view virtual override returns (string memory) {
      return _baseTokenURI;
  }

   function setFeeReciever(address reciever)public {
    require(msg.sender == address(_admin), "legitcrypto: must have admin role to change fee reciever_admin");
    _feeReciever = reciever;
  }

  function setBaseURI(string memory baseURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to change base URI");
    _baseTokenURI = baseURI;
  }

  function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to change token URI");
    _setTokenURI(tokenId, _tokenURI);
  }

  function setMintingEnabled(bool Allowed) external  {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to change minting ability");
    canMint = Allowed;
  }

  function mintMany(uint256 quantity) external {
    require(canMint, "legitcrypto: minting currently disabled");
    require (quantity < 11, "legitcrypto: minting more than 10 is prohibited");
    require((_tokenIdTracker.current() + quantity) < maxSupply, "legitcrypto: all legitcrypto have been minted");
    require(payableToken.allowance(msg.sender, address(this)) >= _tokenPrice * quantity, "legitcrypto: You must approve BUSD spend first" );
    payableToken.transferFrom(msg.sender, address(this), _tokenPrice * quantity);
    for(uint i = 0; i < quantity; i++){
      _mint(msg.sender, _tokenIdTracker.current());
      creator[_tokenIdTracker.current()] = msg.sender;
      lastDividendAt[_tokenIdTracker.current()] = totalDividend;
      _setTokenURI(_tokenIdTracker.current(), string(abi.encodePacked(Strings.toString(_tokenIdTracker.current()), ".json")));
      _tokenIdTracker.increment();
    }
    splitBalance(quantity);
    
  }
  
  function mintMultiples(address[] calldata recipients)public {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to initial mint");
        for (uint256 i = 0; i < recipients.length; i++){
      _mint(recipients[i], _tokenIdTracker.current());
      creator[_tokenIdTracker.current()] = recipients[i];
      lastDividendAt[_tokenIdTracker.current()] = totalDividend;
      _setTokenURI(_tokenIdTracker.current(), string(abi.encodePacked(Strings.toString(_tokenIdTracker.current()), ".json")));
      _tokenIdTracker.increment();
    }
  }

  function mintOneTo(address recipient)public {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to initial mint");

      _mint(recipient, _tokenIdTracker.current());
      creator[_tokenIdTracker.current()] = recipient;
      lastDividendAt[_tokenIdTracker.current()] = totalDividend;
      _setTokenURI(_tokenIdTracker.current(), string(abi.encodePacked(Strings.toString(_tokenIdTracker.current()), ".json")));
      _tokenIdTracker.increment();
    
  }

  function NftCreator(uint256 tokenId) public view returns(address){
    return creator[tokenId];
  }

  function _burn(uint256 tokenId) internal virtual override (ERC721, ERC721URIStorage) {
    return ERC721URIStorage._burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override (ERC721, ERC721URIStorage) returns (string memory) {
    return ERC721URIStorage.tokenURI(tokenId);
  }
  
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override (ERC721, ERC721Enumerable) {

    super._beforeTokenTransfer(from, to, tokenId);
  }

  function getRandomNumber(uint nonce, uint modulo) public view returns (uint256) {
        uint randomData = 0;
        uint newseed = (nonce + randomData + block.timestamp + block.difficulty) % modulo;
        return newseed;
    }


    function rewards(uint amount, address tokenToReward)public payable {
      address[] memory path = new address[](2);
      path[0] = address(router.WETH());
      path[1] = tokenToReward;

      uint deadline = block.timestamp + 1000;
      
      for(uint i = 0; i < amount; i++){
        uint token = getRandomNumber(i, _tokenIdTracker.current());
        address recipient = ownerOf(token);
         router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value/amount}(
          0,
          path,
          address(this),
          deadline
        );
        emit RewardPaid(recipient, msg.value/amount);
      }
    }

  /**
    * @dev See {IERC165-supportsInterface}.
    */
  function supportsInterface(bytes4 interfaceId) public view virtual override (AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function claimTokens () external  {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to claim the balance");
    // make sure we capture all BNB that may or may not be sent to this contract
    payable(_feeReciever).transfer(address(this).balance);
  }

  function recoverStuckToken (IBEP20 token) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "legitcrypto: must have admin role to claim the balance");
    // make sure we capture all BNB that may or may not be sent to this contract
    token.transfer(msg.sender, token.balanceOf(address(this)));
  }

  function splitBalance(uint256 amount) private {
      uint tokenAmount = amount * _tokenPrice; // get the total token price to sell for reflection purchases;
      if(payableToken != IBEP20(WBNB)){
          payableToken.transfer(_feeReciever, tokenAmount);
      }else{
         payable(_feeReciever).transfer(address(this).balance);
      }
  }


  function reflectDividend(uint256 amount) private {
    
  } 
}
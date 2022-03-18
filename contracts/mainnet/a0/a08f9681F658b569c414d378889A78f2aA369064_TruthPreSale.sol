pragma solidity 0.8.0;

import "./nf-token-metadata.sol";
import "./ownable.sol";
/**
 * @dev This is an example contract implementation of NFToken with metadata extension.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}
contract TruthPreSale is NFTokenMetadata, Ownable {
  uint256  public sum_tokenId  = 1;
  IERC20 truth = IERC20(0xffD3dD4B28836f799c70A1C9347e9F4A216225e0);
 
  IERC20 meta = IERC20(0x55d398326f99059fF775485246999027B3197955);

  bool public open_claim = false;
  bool public open_sale = false;
  mapping(address => uint) public myTime ;

  address public admin = 0xe1894dB6F0c76246ce44D68665B75ED59c71F629;
  address public admin222 = msg.sender;
  mapping(address => bool) public hei;
  mapping(address => uint) public js;

//   string  _uri = "https://ipfs.io/ipfs/QmPcjirjNEVpyae4AEbt9V6ogVVfn4uD6sFzuHVw7M4xmP";
  constructor() payable{
    nftName = "TRUTH DAO NFT";
    nftSymbol = "TRUTH DAO";
  }
  modifier isAdmin{
        require(admin == msg.sender); 
        _;  //
    }
  modifier isAdmin222{
        require(admin222 == msg.sender); 
        _;  //
    }  
   function usdt_allow() view public returns(uint){
       return meta.allowance(msg.sender,address(this));
    } 
  function mint(address _to) private {
    require(sum_tokenId<4200,'>4200');  
    super._mint(_to,sum_tokenId);
    sum_tokenId++;
    // super._setTokenUri(sum_tokenId, _uri);
  }
  function isClaim()external returns(bool) {
      if(js[msg.sender] >9000 || block.timestamp < myTime[msg.sender] + 30 days){
          return false;
      }else{
          return true;
      }
  }
  function howDays()public view returns(uint) {
      return (block.timestamp - myTime[msg.sender]) /30 days ;  
  }
  function Claim()external{
      require(js[msg.sender] <10000 && js[msg.sender] > 0,'over');
      require(block.timestamp > myTime[msg.sender] + 30 days,'<30 days');  
      uint howday = howDays();
      js[msg.sender] += howday*1000;
      myTime[msg.sender] += howday*30 days ;  
      truth.transfer(msg.sender,howday*1000*1e18);
  }
  function setClaim()isAdmin222 external{
     open_claim ? open_claim = false :open_claim = true;
  }
  function setSale()isAdmin222 external{
     open_sale ? open_sale = false :open_sale = true;
  }
    fallback() external {
       

        
  }
  function sale() external{
        require(open_sale == true," open is false");
        require(js[msg.sender] == 0,'js != 0'); 
        uint amount = 200*1e18;
        require(meta.balanceOf(msg.sender) >= amount,"error,balance");
        require(meta.allowance(msg.sender,address(this)) >= amount,"error,allowce");
        meta.transferFrom(msg.sender,address(this),amount);
        truth.transfer(msg.sender,2000*1e18);
        js[msg.sender] = 2000;
        mint(msg.sender);
        myTime[msg.sender] = block.timestamp;
  }
    function transferout() external isAdmin{
        payable(msg.sender).transfer(address(this).balance);
        }
    
    function recoverERC20(IERC20 token) external isAdmin{
        token.transfer(
            owner,
            token.balanceOf(address(this))
        );
    }
    
}
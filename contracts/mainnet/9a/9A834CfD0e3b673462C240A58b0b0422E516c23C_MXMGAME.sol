/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

pragma solidity >=0.6.8;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface MXMNFTToken{
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _value)external;
    function mint(address toAddress)external;
    function balanceOf(address _owner) external view returns (uint256);
    function tokenNextId()external view returns (uint256);
    function burn(address _owner, uint256 _tokenId) external;
}
interface IRouter {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
        //USDT[0x158d41854b4F6A0f55051989EA5e27705C277180,0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,0x55d398326f99059fF775485246999027B3197955]
    //100U等于多少MXM
    //[0x55d398326f99059fF775485246999027B3197955,0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,0x158d41854b4F6A0f55051989EA5e27705C277180]
    function getAmountsOut(uint amountIn, address[] memory path)
        external
        view
        returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract MXMGAME is Ownable {
  using Address for address;
  using SafeMath for uint256;
  address public warrior;
  address public Archer;
  address public master;
  address public MXMToken;
  address public USDTToken;
  address public WBNBToken;
  address public Router;
  uint256 public randoms;
  address public GameMXN;
  uint256 public startTime;
  uint256 public Quantity;
  mapping(address=>uint256)public isNFT;
  mapping(uint256=>address)public tokens;
    constructor () public {
        warrior=0xf146F57be9fD14E522A59188e70220E4B3B4aEb7;
        Archer=0x555904b730E1fd835DB3De0638724A6539343c3e;
        master=0x892980B5E583AbbDD63426C792C1731C3C52b30E;
        MXMToken=0x158d41854b4F6A0f55051989EA5e27705C277180;
        Router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
        USDTToken=0x55d398326f99059fF775485246999027B3197955;
        WBNBToken=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        GameMXN=address(this);
        startTime=1657540800;
        Quantity=500;
        ERC20(MXMToken).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E,2 ** 256 - 1);
    }
    function buyNFT(uint256 _mxm)public{
      require(Quantity > 0,"Rush purchase completed");
      require(block.timestamp > startTime,"Not yet");
      uint256 value=getMXM(102 ether);
      require(_mxm >= value,"Insufficient MXM!");
      ERC20(MXMToken).transferFrom(_msgSender(),address(this),value);
      randoms++;
      uint mnu=randomMXM(randoms);
      if(mnu >=80){
          MXMNFTToken(tokens[1]).mint(_msgSender());
          isNFT[_msgSender()]=1;
      }else if(mnu >=70){
          MXMNFTToken(tokens[2]).mint(_msgSender());
          isNFT[_msgSender()]=2;
      }else{
          MXMNFTToken(tokens[3]).mint(_msgSender());
          isNFT[_msgSender()]=3;
      }
      Quantity--;
    }
    function getIsNFT(address addr)public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256){
        uint a=MXMNFTToken(tokens[1]).balanceOf(addr);
        uint b=MXMNFTToken(tokens[2]).balanceOf(addr);
        uint c=MXMNFTToken(tokens[3]).balanceOf(addr);
        uint256 mxm=getMXM(103 ether);
       return (isNFT[addr],a,b,c,mxm,startTime,Quantity);
    }
    function setDayBuyNFT(uint256 _time,uint256 _Quantity)public onlyOwner{
        startTime=_time;
        Quantity=_Quantity;
    }
    function setTokens(address addr,uint256 a)public onlyOwner{
        tokens[a]=addr;
    }
    function setGameMXN(address addr)public onlyOwner{
        GameMXN=addr;
    }
    function getMXM(uint256 _usdt)public view returns(uint256){
        address[] memory path = new address[](3);
        path[0]=USDTToken;
        path[1]=WBNBToken;
        path[2]=MXMToken;
        uint256 [] memory amount;
        amount=IRouter(Router).getAmountsOut(_usdt,path);
         return amount[2];
    }
    function setToEX(uint _mxm)public onlyOwner{
        uint value=_mxm *10**18;
        address[] memory path = new address[](3);
        path[0]=MXMToken;
        path[1]=WBNBToken;
        path[2]=USDTToken;
        IRouter(Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(value,0,path,GameMXN,block.timestamp+600);
    }
    function randomMXM(uint256 _id) private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty +
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                    block.gaslimit +
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                    block.number
                )
            )
        );
        uint256 randomNum = seed%_id;
        if(randomNum<=1){
             randomNum=0;
         }
         if(randomNum>100){
            randomNum=100; 
         }      
         return randomNum;
    }
    function withdrawBNB(address payable addr,uint256 _bnb)public onlyOwner{
       addr.transfer(_bnb);
    }
  function withdrawToken(address token,address payable addr,uint256 value)public onlyOwner{
     ERC20(token).transfer(addr,value);
    }
    receive() external payable{
    }
}
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable to, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");(bool success, ) = to.call{ value: amount }("");
        require(success, "Address: unable to send value, to may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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
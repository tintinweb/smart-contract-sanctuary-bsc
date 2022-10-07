/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// File: Proxiable.sol



pragma solidity ^0.8.1;

contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }

    function proxiableUUID() public pure returns (bytes32) {
        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
} 
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: OBHV_Controller.sol


pragma solidity ^0.8.2;



interface proxyContract{
    function callNFT(address UsrAddress) external  returns(uint256);
    function transferNFT(uint256 tokenId, address from, address to) external returns(bool);
    function burnNFT(uint256 tokenId) external;
    function ownerTokenIDs(address owner) external view returns(uint256[] memory);
    function Claim_Reward(address receiver,uint256 amount) external returns (bool);
}

  
contract Vcontroller is Ownable ,Proxiable{
  bool public initalized = false;

  function initialize() public {
      require(!initalized, "Already initalized");
      initalized = true;
  }

  mapping(address => bool) public whitelist;
  mapping(address => bool) userAddress;

  uint256 public openingTime;
  uint256 public closingTime;
  
  
  address mcontract = 0x18fecc20b1fEfe9aDD0ba37A83380A5199099541;
  address acontract = 0x6fc9067C2efA7983ae28eC4b1daBa372e011a433;
  address jcontract = 0x9fd2297387Ea8970e8630D782F766EA37fA13BCb;
  address solcontract = 0x046801984C6355cE3676201ebe7bcE2fF69E8E35;
  address tokenLiquidity = 0x6abcd7e689408df0650a4Eca64e3da61118F0F25;
  uint256 mntPriceRandom = 20 wei;

  address private _contractAddr = 0xb646E291e2bcE24d2A41774f2AfB55501aED0A5f;
  
  constructor() {
    userAddress[owner()] = true;
  }

  function _mntFee(uint256 _newPrice) public onlyOwner returns(uint256){
    mntPriceRandom = _newPrice;
    return mntPriceRandom;
  }

  enum Stage {locked, presale, publicsale}

  function crowdPresaleTime(uint256 _openingTime, uint256 _closingTime) public onlyOwner {
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);
    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  function whattimeisit() public view onlyOwner returns (uint256){
    return  block.timestamp;
  }

  function checkStage() public view returns (Stage stage){
    if(block.timestamp < openingTime) {
      stage = Stage.locked;
      return stage;
    }
    else if(block.timestamp >= openingTime && block.timestamp <= closingTime) {
      stage = Stage.presale;
      return stage;
    }
    else if(block.timestamp >= closingTime) {
      stage = Stage.publicsale;
      return stage;
      }
  }

  modifier isPresale {
    require(checkStage() == Stage.presale);
    _;
  }

  function iswhitelisted(address xyz) public view isPresale returns (bool) {
    if(whitelist[xyz]) return true;
    else return false;
  }

  modifier buffer(address BAddress) {
    require(openingTime != 0);
    require(checkStage() != Stage.locked);
    require((checkStage() == Stage.publicsale || iswhitelisted(BAddress)));
    _;
  }

  function addManyToWhitelist(address[] memory _beneficiaries) public onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

  function _mintthrow(uint256 _sVal, address _ref, address _secondlvl, address _thirdlvl) internal {
    payable(_ref).transfer((_sVal / 100) * 10);
    payable(_secondlvl).transfer((_sVal / 100) * 3);
    payable(_thirdlvl).transfer((_sVal / 100) * 2);

    payable(mcontract).transfer((_sVal / 100) * 1);
    payable(acontract).transfer((_sVal / 100) * 2);
    payable(jcontract).transfer((_sVal / 100) * 2);
    payable(solcontract).transfer((_sVal / 100) * 5);
    payable(tokenLiquidity).transfer(address(this).balance);
  } 

  function randomMint(address UsrAddress, address ref, address secondlvl, address thirdlvl) payable external returns(uint256) {
    require(msg.value >= mntPriceRandom , "Not enough BNB sent; to support mint and gas"); 
    require(userAddress[ref] == true || ref == owner(), "Invalid referral Address.");
    require(userAddress[secondlvl] == true || secondlvl == owner(), "Invalid referral Address(2).");
    require(userAddress[thirdlvl] == true || thirdlvl == owner(), "Invalid referral Address(3).");
    userAddress[UsrAddress] = true;
    _mintthrow(msg.value,ref,secondlvl,thirdlvl);
    proxyContract TF =  proxyContract(_contractAddr);
    return TF.callNFT(UsrAddress);
  } 
  
  function transferNFT(uint256 tokenId, address from, address to) external returns(bool) {
    proxyContract TF =  proxyContract(_contractAddr); 
    return TF.transferNFT(tokenId,from, to);
  }

  function burnNFT(uint256 tokenId) external  {
    proxyContract TF =  proxyContract(_contractAddr); 
    return TF.burnNFT(tokenId);
  }

  function addToWhitelist(address _beneficiary) public onlyOwner {
    whitelist[_beneficiary] = true;
  }

  function bank() public onlyOwner view returns (uint256) {
    return address(this).balance;
  }
  

  function withdraw() public onlyOwner {
      require(address(this).balance > 0, "Insufficient Balance.");
      payable(owner()).transfer(address(this).balance);
  }

  function ownerTokenIDs(address owner) external view returns(uint256[] memory)
  {
    proxyContract TF =  proxyContract(_contractAddr); 
    return TF.ownerTokenIDs(owner);
  }

  function Claim_Token(address receiver,uint256 amount) external returns (bool)
  {
    proxyContract T20 =  proxyContract(_contractAddr); 
    return T20.Claim_Reward(receiver, amount);
  }
  
  function updateCode(address newCode) onlyOwner public {
      updateCodeAddress(newCode);
  }

  event fallbackmoney(address _from, uint256 _value, string message);
  
  fallback() external payable {
      emit fallbackmoney(msg.sender, msg.value, "call me maybe");
      payable(tokenLiquidity).transfer(address(this).balance);
  }

  event receivemoney(address _from, uint256 _value);

  receive() external payable {
        emit receivemoney(msg.sender, msg.value);
        payable(tokenLiquidity).transfer(address(this).balance);
    }

}
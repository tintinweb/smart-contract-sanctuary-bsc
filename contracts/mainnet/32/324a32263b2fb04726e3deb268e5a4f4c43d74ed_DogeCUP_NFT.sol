/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT

/*

    https://app.dogecup.com/
    https://dogecup.com/
    https://t.me/dogecupofficial
    https://t.me/dogecupnews


*/

pragma solidity ^0.8.0;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
*/


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Is impossible to renounce the ownership of the contract");
        require(newOwner != address(0xdead), "Is impossible to renounce the ownership of the contract");

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}



interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (uint256);    

    function transfer(address to, uint256 amount) external returns (bool);
}



interface IWrapperDaoDCUP {
    function depositFor_AdressProject(address account, uint256 amount) external;

    function withdrawTo_AdressProject(address account, uint256 amount) external;

}


library SafeMath {

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

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
}

/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 */

library sha256_libary {

  /**
   * @dev Recover signer address from a message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param signature bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes memory signature) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (signature.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := byte(0, mload(add(signature, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}


contract DogeCUP_NFT is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    uint256 public timeDeployContract;
    uint256 public timeOpenNFTcontract;

    uint256 public feesClaim = 1500000000000000;
    uint256 public priceNFT = 2500 * 10 ** 18;
    uint256 public priceSoccerCoach = 50 * 10 ** 18;

    uint256 public amountNFTsold;
    uint256 public amountBuyedSoccerCoach;
    uint256 public amountDogeCUPClaimed;

    address public   addressDogeCUP =       0xcEf365B5932558c7E3212053f99634F3D9e078bA;
    address public   addressDaoWrapper =    0x30e408fbA789d384003e436ccFEA14811571dDD9;
    address internal addressBUSD =    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal addressPCVS2 =   0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal addressWBNB =    0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public   burnWallet = 0xFa9ed83e12b651c987DF7201A4A4f6ee8B1185D7;

    address public authAddress = payable(0xc1C797a2332CA275eeb5E38F5F06D389C16175DE);

    mapping(address => bool) public mappingAuth;

    mapping(address => uint256) public nonces;
    mapping(bytes => bool) private signatureUsed;
    mapping(bytes => infosBuy) private getInfosBySignatureMapping;

    struct infosBuy {
        address buyer;
        uint256 amount;
        uint256 wichToken;
        address smartContract;
        uint256 nonce;
        bytes signature;
        bytes32 hash;
    }

    receive() external payable { }

    constructor() {
        timeDeployContract = block.timestamp;
        mappingAuth[authAddress] = true;
    }

    modifier onlyAuthorized() {
        require(_msgSender() == owner() || mappingAuth[_msgSender()], "No hack here!");
        _;
    }

    function getDaysPassed() public view returns (uint256){
        return (block.timestamp - timeDeployContract).div(1 days); 
    }

    function getInfosBySignature(bytes memory signature) external view returns (infosBuy memory){
        require(_msgSender() == owner() || mappingAuth[_msgSender()] == true, "No consultation allowed");
        return getInfosBySignatureMapping[signature]; 
    }

    function bytesLength(bytes memory signature) public pure returns (uint256) {
        return signature.length;
    }

    function hashReturn(bytes memory hash) public pure returns (bytes32,bytes32) {
        return (keccak256(abi.encodePacked(hash)),keccak256(hash));
    }

    function ckeckSignatureCrypto(
        address buyer,
        uint256 amount,
        address smartContract,
        uint256 nonce, 
        bytes memory signature) private {
        require(getInfosBySignatureMapping[signature].buyer == address(0x0), "Signature has already been used");

        require(address(this) == smartContract, "Invalid contract");
        require(signature.length == 65, "Signature length not approved");
        require(smartContract == address(this), "It's not the contract");
        require(keccak256(abi.encodePacked(signature)) != 
                keccak256(abi.encodePacked("0x19457468657265756d205369676e6564204d6573736167653a0a3332")), 
                "Exploit attempt");

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(abi.encodePacked(prefix, 
                keccak256(abi.encodePacked(smartContract,buyer,nonce,amount))));

        address recoveredAddress = sha256_libary.recover(hash, signature);
        
        require(recoveredAddress == authAddress, "Subscription not authorized");
        require(nonces[recoveredAddress]++ == nonce, "Nonce already used");
    }

    function decodeSignature(
        address buyer,
        uint256 amount,
        address smartContract,
        uint256 nonce, 
        bytes memory signature) public pure returns 
        (address,uint256,uint256,bytes memory,bytes32,address) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(
            abi.encodePacked(prefix, keccak256(
                abi.encodePacked(smartContract,buyer,nonce,amount))));
        address recoveredAddress = sha256_libary.recover(hash, signature);

        return (buyer,amount,nonce,signature,hash,recoveredAddress);
    }

    function buyNFT(
        address buyer,
        uint256 amount, 
        address smartContract, 
        uint256 nonce, 
        bytes memory signature) 
        external 
        nonReentrant() whenNotPaused() {

        require(IERC20(addressDogeCUP).balanceOf(msg.sender) >= amount, "You don't have enough tokens");
        require(amount % priceNFT == 0, "Invalid purchase amount");

        IERC20(addressDogeCUP).transferFrom(msg.sender, address(this), amount * 80 / 100);
        IERC20(addressDogeCUP).transferFrom(msg.sender, burnWallet, amount * 20 / 100);

        IWrapperDaoDCUP(addressDaoWrapper).depositFor_AdressProject(msg.sender,amount);

        ckeckSignatureCrypto(
            buyer,
            amount,
            smartContract, 
            nonce, 
            signature);

        getInfosBySignatureMapping[signature].buyer = msg.sender; 
        getInfosBySignatureMapping[signature].amount = amount; 
        getInfosBySignatureMapping[signature].smartContract = smartContract; 
        getInfosBySignatureMapping[signature].nonce = nonce; 
        getInfosBySignatureMapping[signature].signature = signature; 

        amountNFTsold += amount;

    }

    function buySoccerCoach(
        address buyer,
        address smartContract, 
        uint256 nonce, 
        bytes memory signature) 
        external 
        nonReentrant() whenNotPaused() {

        IERC20(addressDogeCUP).transferFrom(msg.sender, burnWallet, priceSoccerCoach);
        IWrapperDaoDCUP(addressDaoWrapper).depositFor_AdressProject(msg.sender,priceSoccerCoach);

        ckeckSignatureCrypto(
            buyer,
            priceSoccerCoach,
            smartContract, 
            nonce, 
            signature);

        getInfosBySignatureMapping[signature].buyer = msg.sender; 
        getInfosBySignatureMapping[signature].amount = priceSoccerCoach; 
        getInfosBySignatureMapping[signature].smartContract = smartContract; 
        getInfosBySignatureMapping[signature].nonce = nonce; 
        getInfosBySignatureMapping[signature].signature = signature; 

        amountBuyedSoccerCoach += priceSoccerCoach;
    }


    function claimRewards(
        address buyer,
        uint256 amount) external onlyAuthorized nonReentrant() whenNotPaused() {

        IERC20(addressDogeCUP).transfer(buyer, amount);

        amountDogeCUPClaimed += priceSoccerCoach;
    }


    function requestClaim(
        address buyer) external payable nonReentrant() whenNotPaused() {

        require(msg.value == feesClaim, "Invalid value transferred");
        (bool success,) = authAddress.call{value: feesClaim}("");
        require(success, "Failed to send BNB");
    }

    function uncheckedI (uint256 i) public pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function claimManyRewards (address[] memory buyer, uint256[] memory amount) 
    external 
    onlyOwner {

        uint256 buyerLength = buyer.length;
        for (uint256 i = 0; i < buyerLength; i = uncheckedI(i)) {  
            IERC20(addressDogeCUP).transfer(buyer[i], amount[i]);
        }
    }

    function withdraw(address account, uint256 amount) public onlyOwner {
        IERC20(addressDogeCUP).transfer(account, amount);
    }

    function managerBNB () external onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function managerERC20 (address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function setPricesAndFees 
    (uint256 _feesClaim, uint256 _priceNFT, uint256 _priceSoccerCoach) external onlyOwner {
        feesClaim = _feesClaim;
        priceNFT = _priceNFT;
        priceSoccerCoach = _priceSoccerCoach;
    }

    function setMappingAuth(address account, bool boolean) external onlyOwner {
        mappingAuth[account] = boolean;
    }

    function setDogeCUPAddressContract (address _addressDogeCUP, address _addressDaoWrapper) external onlyOwner {
        addressDogeCUP = _addressDogeCUP;
        addressDaoWrapper = _addressDaoWrapper;
    }

}
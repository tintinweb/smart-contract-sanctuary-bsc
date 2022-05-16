/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    
    constructor()  {}

    function _msgSender() internal view returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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


contract Pausable is Context {
    
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        require(!_paused,"already Paused");
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        require(_paused,"already Paused");
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract LudoGame is Ownable, Pausable, ReentrancyGuard {
    
    IBEP20 public PRBToken;
    address public signer;
    address public feeWallet;
    uint256 public feeAmount = 1e15;

    struct UserInfo{
        address user;
        uint256 depositAmount;
        uint256 lastDepositTime;
        uint256 claimAmount;
        uint256 lastClaimTime;
    }

    mapping (address => UserInfo) public userDetails;
    mapping (bytes32 => bool) public hashVerify;

    event UpdateSigner(address indexed owner, address indexed newSigner);
    event DepositToken (address indexed user, uint256 TokenAmount, uint256 depositTime);
    event WithdrawTokens (address indexed user, uint256 TokenAmount, uint256 blockTime);
    event Emergency(address indexed tokenAddres, address receiver, uint256 tokenAmount);
    event SetFeeWallet(address indexed owner, address indexed newWallet);
    event SetFeeAmount(address indexed owner, uint256 newFee);

    constructor( address _PRBToken, address _signer, address _feeWallet) {
        PRBToken = IBEP20(_PRBToken);
        signer = _signer;
        feeWallet = _feeWallet;
    }

    function pause() external onlyOwner{
        _pause();
    }

    function unPause() external onlyOwner{
        _unpause();
    }

    function deposit(uint256 _tokenAmount) external payable whenNotPaused nonReentrant {
        require(msg.value >= feeAmount,"Incorrect feeAmount");
        UserInfo storage user = userDetails[_msgSender()];
        user.user = _msgSender();
        user.depositAmount += _tokenAmount;
        user.lastDepositTime = block.timestamp;

        PRBToken.transferFrom(_msgSender(), address(this), _tokenAmount);
        require(payable(feeWallet).send(msg.value),"Fee transaction failed");
        emit DepositToken(_msgSender(), _tokenAmount, block.timestamp);
    }

    function withdraw(uint256 _tokenAmount, uint256 _blockTime, uint8 v, bytes32 r, bytes32 s) external payable whenNotPaused nonReentrant {
        require(msg.value >= feeAmount,"Incorrect feeAmount");
        require(_blockTime >= block.timestamp,"Time Expired");
        bytes32 msgHash = toSigEthMsg(msg.sender, _tokenAmount, _blockTime);
        require(!hashVerify[msgHash],"Claim :: signature already used");
        require(verifySignature(msgHash, v,r,s) == signer,"Claim :: not a signer address");
        hashVerify[msgHash] = true;

        userDetails[_msgSender()].claimAmount += _tokenAmount;
        userDetails[_msgSender()].lastClaimTime = block.timestamp;

        PRBToken.transfer(msg.sender, _tokenAmount);
        require(payable(feeWallet).send(msg.value),"Fee transaction failed");
        emit WithdrawTokens(msg.sender, _tokenAmount, block.timestamp);
    }

    function setFeeWallet(address _newFeeWallet) external onlyOwner {
        require(_newFeeWallet != address(0x0),"wallet address must not zero address");
        feeWallet = _newFeeWallet;
        emit SetFeeWallet(msg.sender, _newFeeWallet);
    }

    function setFee(uint256 _newFee) external onlyOwner {
        feeAmount = _newFee;
        emit SetFeeAmount(msg.sender, _newFee);
    }

    function setSigner(address _signer)external onlyOwner{
        require(_signer != address(0),"signer address not Zero address");
        signer = _signer;
        
        emit UpdateSigner(msg.sender, signer);
    }
    
    function verifySignature(bytes32 msgHash, uint8 v,bytes32 r, bytes32 s)public pure returns(address signerAdd){
        signerAdd = ecrecover(msgHash, v, r, s);
    }
    
    function toSigEthMsg(address user, uint256 _tokenAmount, uint256 _blockTime)internal view returns(bytes32){
        bytes32 hash = keccak256(abi.encodePacked(abi.encodePacked(user, _tokenAmount, _blockTime),address(this)));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function getHash(address user, uint256 _tokenAmount, uint256 _blockTime)public view returns(bytes32){
        return keccak256(abi.encodePacked(abi.encodePacked(user, _tokenAmount, _blockTime),address(this)));
    }
    
    function emergency(address _tokenAddress, address _to, uint256 _tokenAmount) external onlyOwner {
        if(_tokenAddress == address(0x0)){
            require(payable(_to).send(_tokenAmount),"transaction failed");
        } else {
            IBEP20(_tokenAddress).transfer(_to, _tokenAmount);
        }

        emit Emergency(_tokenAddress, _to, _tokenAmount);
    }



}
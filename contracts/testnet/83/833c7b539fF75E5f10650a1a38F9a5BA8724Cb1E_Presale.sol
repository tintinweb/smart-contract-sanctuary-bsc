/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract Presale is Ownable, Pausable {

    IBEP20 public Mabrook;
    address public treasuryAddress;
    address public signer;
    uint256 public startingTime;
    uint256 public endingTime;

    mapping (address => uint256) public isApproved;
    mapping (bytes32 => bool) public hashVerify;

    event BuyToken(address indexed caller, uint256 BNBValue, uint256 tokenValue);    
    event Emergency(address indexed tokenAddres, address receiver, uint256 tokenAmount);
    event Claim(address indexed caller, uint256 tokenAmount, uint256 claimTime);

    constructor( address _token, address _treasuryAddress, uint256 _startingTime, uint256 _endingTime, uint256 _tokenPerBNB, address _BUSD, uint256 _tokenPerBUSD ) {
        Mabrook = IBEP20(_token); 
        treasuryAddress = _treasuryAddress;
        startingTime= _startingTime;
        endingTime = _endingTime;

        isApproved[address(0x0)] = _tokenPerBNB;
        isApproved[_BUSD] = _tokenPerBUSD;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }

    function tokenApproved(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        isApproved[_tokenAddress] = _tokenAmount;
    }

    function buyTokens( uint256 _tokenAmount, address _tokenAddress) external payable whenNotPaused  {
        require(startingTime <= block.timestamp && endingTime >= block.timestamp,"Not Time to buy");
        require( isApproved[_tokenAddress] > 0, "Invalid token to buy");
        uint256 transferToken;
        if(address(0x0) == _tokenAddress){
            require(_tokenAmount == 0, "invalid flag amount");
            transferToken = msg.value * isApproved[address(0x0)] / 1e18;
            require(payable(treasuryAddress).send(msg.value),"Transaction failed");

            emit BuyToken(_msgSender(), msg.value, transferToken);
        } else {
            require(msg.value == 0, "invalid flag amount");
            uint256 denominator = 10 ** uint256(IBEP20(_tokenAddress).decimals());
            transferToken = _tokenAmount * isApproved[_tokenAddress] / denominator;
            IBEP20(_tokenAddress).transferFrom(_msgSender(), treasuryAddress, _tokenAmount);

            emit BuyToken(_msgSender(), _tokenAmount, transferToken);
        }

        Mabrook.transfer(_msgSender(), transferToken);
        
    }

    function updateTreasuryAddress(address _newWallet) external onlyOwner {
        treasuryAddress = _newWallet;
    }

    function balanceSaleToken() external view returns(uint256 saleTokens){
        return Mabrook.balanceOf(address(this));
    }

    function updateToken(address _newToken) external onlyOwner {
        Mabrook = IBEP20(_newToken);
    }

    function updateTime(uint256 _startTime, uint256 _endTime) external onlyOwner {
        startingTime = _startTime;
        endingTime = _endTime;
    }

    function claimRewards(uint256 _amount, uint256 _time, uint8 _V, bytes32 _R, bytes32 _S) external whenNotPaused {
        require(_time >= block.timestamp,"Time Expired");
        bytes32 msgHash = toSigEthMsg(msg.sender, _amount, _time);
        require(!hashVerify[msgHash],"Claim :: signature already used");
        require(verifySignature(msgHash, _V, _R, _S) == signer,"Claim :: not a signer address");
        hashVerify[msgHash] = true;

        Mabrook.transfer(msg.sender, _amount);

        emit Claim(_msgSender(), _amount, block.timestamp);

    }

    function verifySignature(bytes32 msgHash, uint8 v,bytes32 r, bytes32 s)public pure returns(address signerAdd){
        signerAdd = ecrecover(msgHash, v, r, s);
    }
    
    function toSigEthMsg(address user, uint256 _tokenAmount, uint256 _blockTime)internal view returns(bytes32){
        bytes32 hash = keccak256(abi.encodePacked(abi.encodePacked(user, _tokenAmount, _blockTime),address(this)));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function getHash(address _user, uint256 _tokenAmount, uint256 _blockTime)public view returns(bytes32){
        return keccak256(abi.encodePacked(abi.encodePacked(_user, _tokenAmount, _blockTime),address(this)));
    }

    function setSigner(address _signer)external onlyOwner{
        require(_signer != address(0) && signer != _signer,"signer address not Zero address");
        signer = _signer;
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
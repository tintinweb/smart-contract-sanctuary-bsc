/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner =  _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract RNK_RAKET_Bridge is Ownable {
    using SafeMath for uint256;
    address public _RNK_TOKEN;
    address public _RAKET_TOKEN;
    uint256 public firstUnlockTime;
    uint256 public secondUnlockTime;
    
    
    mapping(address => uint256) public lockedRaketAmount;

    struct WhitelistUsers {
        address user;
        bool isWhitelist;
    }
    WhitelistUsers[] private _whitelist;


    IERC20 RNK_TOKEN = IERC20(_RNK_TOKEN);
    IERC20 RAKET_TOKEN = IERC20(_RAKET_TOKEN);
    


    constructor(IERC20 RAKET, IERC20 RNK,  uint256 _firstUnlockTime, uint256 _secondUnlockTime) {
            RAKET_TOKEN = RAKET;
            RNK_TOKEN = RNK;
            firstUnlockTime = _firstUnlockTime;
            secondUnlockTime = _secondUnlockTime;
    }

    function currentTime() view public returns(uint256){
        return block.timestamp;
    }

    function AirdropRaketToken(uint56 raket) onlyOwner public {        
        require(getTokenForAirdrop() >= raket, "Insufficient tokens for airdrop");
        require(raket <= RAKET_TOKEN.allowance(msg.sender, address(this)),"Insufficient allowance for transfer token");
        RAKET_TOKEN.transferFrom(msg.sender, address(this), raket);

         for (uint256 i = 0; i < _whitelist.length; i++) {
            if(_whitelist[i].isWhitelist){
                lockedRaketAmount[_whitelist[i].user] = RNK_TOKEN.balanceOf(_whitelist[i].user);
            }
        }

    }

    function claimRaketToken() public {
        uint256 amount = getUnlockedToken(msg.sender);
        require(getUnlockedToken(msg.sender) > 0, "Token not available for claim");
        RAKET_TOKEN.transfer(msg.sender, amount);
        lockedRaketAmount[msg.sender] = lockedRaketAmount[msg.sender].sub(amount);
    }
    function getUnlockedToken(address _addr) public view returns(uint256 unlockedToken) {
        if(secondUnlockTime <= block.timestamp ){
            unlockedToken = lockedRaketAmount[_addr];
        }else if(firstUnlockTime <= block.timestamp ){
            unlockedToken = lockedRaketAmount[_addr].mul(50).div(100);
        }
    }

    function getTokenForAirdrop() view public returns(uint256 totalToken) {
        totalToken = 0;
        for (uint256 i = 0; i < _whitelist.length; i++) {
            if(_whitelist[i].isWhitelist){
               totalToken = totalToken + RNK_TOKEN.balanceOf(_whitelist[i].user);
            }
        }
    }
    
    function addAddressToWhitelist(address addr) onlyOwner public  {
        ( , bool isFind) = findeWhitelistAddressIndex(addr);
        if(!isFind){
            _whitelist.push(WhitelistUsers(addr,true));
        }        
    }

    function addMultiAddressToWhitelist(address[] memory addr) onlyOwner public  {
        for(uint i=0; i<addr.length;i++){
            ( , bool isFind) = findeWhitelistAddressIndex(addr[i]);
            if(!isFind){
                _whitelist.push(WhitelistUsers(addr[i],true));
            }        
        }
    }

    function removeAddressFromWhitelist(address addr) onlyOwner public  {
        (uint index , bool isFind) = findeWhitelistAddressIndex(addr);
        if(isFind){
             _whitelist[index] =_whitelist[_whitelist.length-1] ;
             _whitelist.pop();
        }        
    }


    function findeWhitelistAddressIndex(address addr) view private returns(uint findIndex, bool isFind){
        findIndex = 0;
        isFind=false;
        for(uint i=0; i<_whitelist.length;i++){
            if(address(_whitelist[i].user) == address(addr)){
                findIndex =  i;
                isFind = true;
            }
        }
    }

    function totalWhitelisted() view public returns(uint256){
        return _whitelist.length;
    }

    function setRNKtokenAddress(IERC20 _contract) public onlyOwner{
        RNK_TOKEN = _contract;
    }

    function setRAKETtokenAddress(IERC20 _contract) public onlyOwner{
        RAKET_TOKEN = _contract;
    }

    function setFirstUnlockTime(uint256 time) public onlyOwner{
        firstUnlockTime = time;
    }
    
    function setSecondUnlockTime(uint256 time) public onlyOwner{
        secondUnlockTime = time;
    }
    

    function withdrawRaketByOnwer(uint256 token) public onlyOwner {
        RAKET_TOKEN.transfer(msg.sender, token);
    }

}
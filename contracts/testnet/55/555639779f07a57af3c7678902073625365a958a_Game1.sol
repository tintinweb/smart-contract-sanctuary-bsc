/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract Ownable {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface NFT {
    function getRarityOfTokenId(uint256 _tokenId) external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Game1  is Ownable  {
    using SafeMath for uint256;

    IERC20 private tokenAddress = IERC20(0xC78F9aAFb890d51d5cB72431028Bc7393130c1cC);
    NFT private nftAddress = NFT(0xA16Ea6CCd1ae1841F3Bd320e2097878B135FA1F8);
    
    //=================GAME==================
    // variable
    uint256 public poolGame;
    uint256[] private dayRefund;
    mapping(uint256 => uint256) public turnOfToken;
    mapping(uint256 => uint256) public timeOfToken;
    uint256 private _tokenByEth = 100000*10**9;
    uint256 private _turnInDay = 6;

    constructor(){
        dayRefund = [0,7,6,5,4,3];
    }

    modifier ownerNft(uint256 _tokenId) {
        require(nftAddress.ownerOf(_tokenId) == _msgSender(), "GAME: You do not own this NFT");
        if(block.timestamp - timeOfToken[_tokenId] >= 10 minutes && turnOfToken[_tokenId] == 0){
            turnOfToken[_tokenId] = 6;
            timeOfToken[_tokenId] = block.timestamp;
        }
        require(turnOfToken[_tokenId] != 0, "GAME: Your turn is over");
        _;
    }

    // config onlyOwner
    function depositPoolGame(uint256 _amount) external onlyOwner{
        tokenAddress.transferFrom(_msgSender(), address(this), _amount);
    }
    function setTokenByEth(uint256 _amount) external onlyOwner {
        _tokenByEth = _amount;
    }

    // core game
    function smallAttack(uint256 _tokenId) external ownerNft(_tokenId) returns(uint256) {
        uint256 rarityOfToken = nftAddress.getRarityOfTokenId(_tokenId);
        uint256 profit = _profit(rarityOfToken, 6);
        bool status = _random(0,101, _tokenId) > 80;

        _transferToken(_msgSender(), profit);
        turnOfToken[_tokenId]-=1;
        if(status){
            return 1;
        }else{
        return 100;
        }

    }

    function _transferToken(address _address, uint256 _amount) private {
        tokenAddress.transfer(_address, _amount);   
    }

    function mediumAttack(uint256 _tokenId) external ownerNft(_tokenId) returns(uint256) {
        require(turnOfToken[_tokenId] >=2, "GAME: Your turn do not enough");
        uint256 rarityOfToken = nftAddress.getRarityOfTokenId(_tokenId);
        uint256 profit = _profit(rarityOfToken, 3);
        bool status = _random(0,101, _tokenId) > 80;

        _transferToken(_msgSender(), profit);
        turnOfToken[_tokenId]-=1;
        if(status){
            return 1;
        }else{
        return 100;
        }
    }

    function largeAttack(uint256 _tokenId) external ownerNft(_tokenId) returns(uint256) {
        require(turnOfToken[_tokenId] >=3, "GAME: Your turn do not enough");
        uint256 rarityOfToken = nftAddress.getRarityOfTokenId(_tokenId);
        uint256 profit = _profit(rarityOfToken, 2);
        bool status = _random(0,101, _tokenId) > 80;

        _transferToken(_msgSender(), profit);
        turnOfToken[_tokenId]-=1;
        if(status){
            return 1;
        }else{
        return 100;
        }
    }
    
    function _profit (uint256 _rarityOfToken, uint256 _turnAttack) private view returns(uint256) {
        uint256 calculate = _tokenByEth/(dayRefund[_rarityOfToken]*_turnAttack);
        return calculate;
    }
    function _random(uint8 _min, uint8 _max, uint256 index) private view returns (uint8) {
        return
            uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, index))) % (_max - _min)) + _min;
    }

    mapping(address => uint256[]) public myTokens;

    function setArray(uint256 _amount) external {
        myTokens[msg.sender].push(_amount);
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC721 {
    function safeTransferFrom(address from_, address to_, uint256 tokenId_) external;
    function getHashrateByTokenId(uint256 tokenId_) external view returns(uint256);
    function feedFBXOnlyPrice() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function getDegreeByTokenId(uint256 tokenId) external view returns(uint256);
    function burnNFT(uint256 tokenId) external returns (uint256);
}


contract ReentrancyGuard {
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
interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) view external returns (bytes4);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract TowerNFTUpdata is Ownable, ReentrancyGuard,IERC721Receiver {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    string private _name = "TowerNFTUpdata";
    string private _symbol = "TowerNFTUpdata";

    IERC721 public ERC721Token;
    IERC20 public fbxToken;
    uint256[5] public _updataPrice = [
        1000* 10**18,
        1000* 10**18,
        1000* 10**18,
        1000* 10**18,
        1000* 10**18];
    address public fundAdress;
    address[5] public _updataTokenAdress = [
        0x03EF9129284815650529E2b3aDeE04CB20947fb9,
        0x25954B1bdF26c3ffD5fa9a0f204eD89675825dd1,
        0xde975E4a5C4820Fa4C323E1520dCBAfaC8a42ef8,
        0x1aEF244cE1907a78D19Ed4930931cA7a54BEF837,
        0xaeb265e7069Ab1a491Be7efC37aC99137a98cEa7];

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;
    bool private _bStart = false;
    event UpdataToken(address indexed user, uint256 tokenId1,uint256 tokenId2);

    constructor(){
        ERC721Token = IERC721(0x52C2b76C30fB7D1581DdCfa20e07d1ae789FF912);
        fbxToken = IERC20(0xFD57aC98aA8E445C99bc2C41B23997573fAdf795);
        fundAdress = 0x52D6d4144F1E964844f95415B3210f2aCcf3F6Ee;
    }
    
    /* ========== VIEWS ========== */
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function onERC721Received(address,address,uint256,bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    //read info    
    function isWhiteContract(address account) public view returns (bool) {
        if(!account.isContract()) return true;
        return _Is_WhiteContractArr[account];
    }
    function getWhiteAccountNum() public view returns (uint256){
        return _WhiteContractArr.length;
    }
    function lastTokenNum() public view returns (uint256[] memory){
        uint256[] memory tPropertyArr = new uint256[](5);
        for(uint256 i=0; i < _updataTokenAdress.length ; i++) {
            tPropertyArr[i] = ERC721Token.balanceOf(_updataTokenAdress[i]);
        }
        return tPropertyArr;
    }
    function getWhiteAccountIth(uint256 ith) public view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "TowerNFTUpdata: not in White Adress");
        return _WhiteContractArr[ith];
    }
    //---write---//
    function updataToken(uint256 tokenId1,uint256 tokenId2) external nonReentrant{
        require(_bStart, "TowerNFTUpdata:not start!");
        require(tokenId1 != tokenId2, "TowerNFTUpdata:tokenId1 equal tokenId2!");
        require(isWhiteContract(_msgSender()), "TowerNFTUpdata: Contract not in white list!");

        uint256 degree1 = ERC721Token.getDegreeByTokenId(tokenId1);
        uint256 degree2 = ERC721Token.getDegreeByTokenId(tokenId2);

        require(degree1 == degree2, "TowerNFTUpdata:tokenId1 degree not equal tokenId2 degree!");
        require(degree1 != 6, "TowerNFTUpdata:tokenId1 degree equal 6!");
        require( ERC721Token.balanceOf(_updataTokenAdress[degree1-1]) >0, "TowerNFTUpdata:last none!");

        ERC721Token.safeTransferFrom(_msgSender(),address(this),tokenId1);
        ERC721Token.burnNFT(tokenId1);
        ERC721Token.safeTransferFrom(_msgSender(),address(this),tokenId2);
        ERC721Token.burnNFT(tokenId2);

        uint256 price0 = _updataPrice[degree1-1];
        fbxToken.safeTransferFrom(_msgSender(), fundAdress, price0.mul(10).div(100));
        fbxToken.safeTransferFrom(_msgSender(), address(0), price0.mul(90).div(100));
        
        uint256 giftId = ERC721Token.tokenOfOwnerByIndex(_updataTokenAdress[degree1-1],0);
        ERC721Token.safeTransferFrom(_updataTokenAdress[degree1-1],_msgSender(),giftId);
       
        emit UpdataToken(msg.sender, tokenId1, tokenId2);
    }

    //---write onlyOwner---//
    function setStart(bool bStart) external onlyOwner{
        _bStart = bStart;
    }
    function setTokens(address tTowerToken,address tFbxToken) external onlyOwner{
       ERC721Token = IERC721(tTowerToken);
       fbxToken = IERC20(tFbxToken);
    }
    function setAdressPrice(address[] calldata adressArr,uint256[] calldata updataPriceArr) external onlyOwner{
       require(adressArr.length == 5 , "TowerNFTUpdata: adressArr length not equal 6!");
       require(updataPriceArr.length == 5 , "TowerNFTUpdata: updataPriceArr length not equal 6!");
        
        for(uint256 i=0; i < adressArr.length ; i++) {
            _updataPrice[i] =updataPriceArr[i];
            _updataTokenAdress[i] =adressArr[i];
        }
    }

    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "TowerNFTUpdata:Account is already White list");
        require(account.isContract(), "TowerNFTUpdata: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "TowerNFTUpdata:Account is already out White list");
        for (uint256 i = 0; i < _WhiteContractArr.length; i++){
            if (_WhiteContractArr[i] == account){
                _WhiteContractArr[i] = _WhiteContractArr[_WhiteContractArr.length - 1];
                _WhiteContractArr.pop();
                _Is_WhiteContractArr[account] = false;
                break;
            }
        }
    }



    
}
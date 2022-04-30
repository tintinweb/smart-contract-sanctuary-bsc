/**
 *Submitted for verification at BscScan.com on 2022-04-30
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

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
    function safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external;
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

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

// Inheritancea
interface IStakingRewards {
    // Views
    function getRewardForDuration() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    // Mutative
    function stake(uint256 num) external;
    function exit() external;

    // EVENTS
    event Exit(address indexed user);
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
}

interface IERC721 {
    function safeTransferFrom(address from_, address to_, uint256 tokenId_) external;
    function getHashrateByTokenId(uint256 tokenId_) external view returns(uint256);
    function feedFBXOnlyPrice() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function mintNFTTo(uint256 degree,address to) external;
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


contract ForthBoxErc1155_StakingRewards is ERC165,IStakingRewards, Ownable, ReentrancyGuard,IERC1155Receiver {
    using SafeMath for uint256;
    using Address for address;

    string private _name = "ForthBoxErc1155 DeFi";
    string private _symbol = "Erc1155 DeFi";

    IERC1155 public stakingToken;
    IERC721 public rewardsTokenNFT;

    uint256 public rewardsDuration = 30 days;
    uint256 public lastUpdateTime;

    struct sStakeProperty {
        uint256 _Num;
        uint256 _UpdataTime;
    }

    mapping(address => sStakeProperty) private _stakePropertys;
    mapping(address => uint256) private _balances;

    uint256 private _totalSupply=0;
    uint256 public stakePrice = 3000e18;
    uint256 public totalNum = 2300;
    uint256 public maxStakeNumPerAdress = 1;
    uint256 public alreadyStakeNum = 0;
    bool public start = false;   

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;

    constructor() {
        rewardsTokenNFT = IERC721(0x95cbF549f2b03a7cbB8825c92645891165B41D7D);
        stakingToken = IERC1155(0x1d64E85a41a711a6aeF17792A660b3E69a7dA758);
    }

    /* ========== VIEWS ========== */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    function stakeTime(address account) external view returns (uint256) {
        return _stakePropertys[account]._UpdataTime;
    }
    function getRewardForDuration() external view returns (uint256) {
        return totalNum;
    }
    function stakeNum(address account) external view returns (uint256) {
        return _stakePropertys[account]._Num;
    }

    function onERC1155Received(address,address,uint256,uint256,bytes calldata
    ) external pure returns (bytes4)
    {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address,address,uint256[] calldata,uint256[] calldata,bytes calldata
    ) external pure returns (bytes4){
        return this.onERC1155BatchReceived.selector;
    }

    function isWhiteContract(address account) public view returns (bool) {
        if(!account.isContract()) return true;
        return _Is_WhiteContractArr[account];
    }
    function getWhiteAccountNum() public view returns (uint256){
        return _WhiteContractArr.length;
    }
    function getWhiteAccountIth(uint256 ith) public view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "Defi: not in White Adress");
        return _WhiteContractArr[ith];
    }
    function getParameters(address account) public view returns (uint256[] memory){
        uint256[] memory paraList = new uint256[](uint256(12));
        paraList[0]= alreadyStakeNum;
        paraList[1]= totalNum;
        paraList[2]= _balances[account];
        paraList[3]= _totalSupply;
        paraList[4]= stakePrice;
        paraList[5]= _stakePropertys[account]._Num;
        paraList[6]= _stakePropertys[account]._UpdataTime;

        paraList[7]= maxTokenNum[0]-minTokenNum[0];
        paraList[8]= maxTokenNum[1]-minTokenNum[1];
        paraList[9]= maxTokenNum[2]-minTokenNum[2];
        paraList[10]= maxTokenNum[3]-minTokenNum[3];
        paraList[11]= maxTokenNum[4]-minTokenNum[4];
        return paraList;
    }

    //---write---//
    uint256 public erc1155TokenId = 1;
    uint256[5] public maxTokenNum =[1000,600,400,200,100];
    uint256[5] public minTokenNum =[0,0,0,0,0];
    uint256[5] public tokenDegree =[9,10,11,12,0];
    uint256[5] public tokenCost =[15,20,30,45,100];
    function stake(uint256 tType) external nonReentrant {
        require(tType > 0, "Defi:buy type wrong");
        require(tType <=5, "Defi:Cannot stake 0");
        require(start, "Defi:not start");
        require(minTokenNum[tType-1].add(1) <= maxTokenNum[tType-1], "Defi:stake num exceed max number");
        require(_stakePropertys[_msgSender()]._Num.add(1) <= maxStakeNumPerAdress, "Defi:stake num exceed max number");
        require(isWhiteContract(_msgSender()), "Defi: Contract not in white list!");

        stakingToken.safeTransferFrom(msg.sender, address(this),erc1155TokenId, tokenCost[tType-1],"");

        _balances[msg.sender] = _balances[msg.sender].add(tokenCost[tType-1]);
        _totalSupply = _totalSupply.add(tokenCost[tType-1]);
        
        _stakePropertys[_msgSender()]._Num = _stakePropertys[_msgSender()]._Num.add(1);
        _stakePropertys[_msgSender()]._UpdataTime = block.timestamp;
        minTokenNum[tType-1] = minTokenNum[tType-1].add(1); 

        alreadyStakeNum = alreadyStakeNum.add(1); 
        if(tType<=4){
            rewardsTokenNFT.mintNFTTo(tokenDegree[tType-1], _msgSender());
        }
        else{
            for(uint256 i=0; i<4; ++i) {
                rewardsTokenNFT.mintNFTTo(tokenDegree[i], _msgSender());
            }
        }

        emit Staked(msg.sender, tType);
    }
   //取出代币和奖励
    function exit() external nonReentrant {
        require(block.timestamp >= _stakePropertys[_msgSender()]._UpdataTime + rewardsDuration,"Defi: can only exit exceed rewards Duration!");
        require(_balances[msg.sender] > 0, "Defi: not stake");
        require(start, "Defi:not start");
        require(isWhiteContract(_msgSender()), "Defi: Contract not in white list!");
   
        uint256 stakeAmount = _balances[msg.sender];
        _totalSupply = _totalSupply.sub(_balances[msg.sender] );
        _balances[msg.sender] = 0;
        _stakePropertys[_msgSender()]._Num=0;
        if(stakeAmount>0)  stakingToken.safeTransferFrom(address(this),msg.sender,erc1155TokenId, stakeAmount,"");
        emit Exit(_msgSender());
    }

    //---write onlyOwner---//
    function setTokens(address _rewardNFTsToken,address _stakingToken,uint256 _rewardsDuration) external onlyOwner {
        rewardsTokenNFT = IERC721(_rewardNFTsToken);
        stakingToken = IERC1155(_stakingToken);
        rewardsDuration = _rewardsDuration;
    }

    function notifyRewardAmount(uint256 tMaxStakeNumPerAdress,uint256 tErc1155TokenId,bool tStart) external onlyOwner{
        maxStakeNumPerAdress = tMaxStakeNumPerAdress;
        start = tStart;
        erc1155TokenId = tErc1155TokenId;
        lastUpdateTime = block.timestamp;
    }
    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "Defi:Account is already White list");
        require(account.isContract(), "Defi: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "Defi:Account is already out White list");
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
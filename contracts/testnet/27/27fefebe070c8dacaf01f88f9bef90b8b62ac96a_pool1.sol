/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

//LemonDAO Genesis NFT
//Official website: https://lemondao.top/
//Official Twitter: https://twitter.com/LemonBSC
//Official Telegram: https://t.me/LemonDAO
//YouTube channel: https://www.youtube.com/channel/UC29k1jKtH-fBypxFjiUPFIA

//  ##      #####  ##   ##    ###    ##   ##  //
//  ##     ##      ### ###  ##   ##  ###  ##  //
//  ##     #####   ## # ##  ##   ##  ## # ##  //
//  ##     ##      ##   ##  ##   ##  ##  ###  //
//  #####   #####  ##   ##    ###    ##   ##  //

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        _owner = _owner;
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

abstract contract ILemonDAO_NFT {
    function totalSupply() public view virtual returns (uint256);
    function ownerOf(uint256 tokenId) public view virtual returns (address);
}

contract pool1 is Ownable {
    IERC721 public stakingToken;
    IERC20 public rewardsToken;
    ILemonDAO_NFT public nft;
    mapping(address => uint256) public users;  // user address => tokenID
    mapping(address => uint256) public startTS;  // user address => start timestamp
    mapping(address => uint256) public endTS;  // user address => end timestamp

    mapping(address => uint) public rewards;
    uint256 s = 230000;
    uint256 ends = 365 days;

    constructor(){
        address nft_addr = 0x01A81CF4024191625e055d9a50aE8c91c2b1A652;
        address reward_addr = 0x33Fd6b968ba529Ee462F7fb1E808A123d86C6b5E;
        nft = ILemonDAO_NFT(nft_addr);
        stakingToken = IERC721(nft_addr);
        rewardsToken = IERC20(reward_addr);
    }

    function getUserTokenId(address account) public view returns(uint256){
        return users[account];
    }

    function getOwnerOfNFT(address account) public view returns(uint256){
        for (uint256 i = 1; i < nft.totalSupply(); i++) {
            address a = nft.ownerOf(i);
            if(a == account){
                return i;
            }
        }
        return 0;
    }

    function stake() public {
        require(users[msg.sender] > 0, "staked...");
        uint256 tokenId = getOwnerOfNFT(msg.sender);
        require(tokenId > 0, "tokenId = 0");
        address nft_owner = stakingToken.getApproved(tokenId);
        if(nft_owner != address(this)){
            stakingToken.approve(address(this), tokenId);
        }        
        stakingToken.transferFrom(msg.sender, address(this), tokenId);
        users[msg.sender] = tokenId;
        startTS[msg.sender] = block.timestamp;
        endTS[msg.sender] = startTS[msg.sender] + ends;
    }

    function withdraw() public {
        uint256 tokenId = users[msg.sender];
        require(tokenId > 0, "tokenId = 0");
        getReward();
        stakingToken.transferFrom(address(this), msg.sender, tokenId);
        stakingToken.approve(0x0000000000000000000000000000000000000000, users[msg.sender]);
        users[msg.sender] = 0;
        startTS[msg.sender] = 0;
        endTS[msg.sender] = 0;        
    }

    function earned(address _account) public view returns (uint) {
        if(startTS[_account] > 0) return 0;
        uint256 e = endTS[_account] - startTS[_account];
        return e * s;
    }

    function getReward() public {
        startTS[msg.sender] = block.timestamp;
        uint256 e = endTS[msg.sender] - startTS[msg.sender];
        uint reward = e * s;
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }


}
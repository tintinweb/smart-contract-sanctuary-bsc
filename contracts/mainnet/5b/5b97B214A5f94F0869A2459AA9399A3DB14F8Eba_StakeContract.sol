/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC721 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    function totalSupply() external view returns (uint256 totalSupply);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeMint(address to, uint256 tokenId) external;
}

contract StakeContract is Ownable {
    address public _rewardToken = 0x527728dD39B2cDeCE33d9E73a76B2501D5D6844e;//子币合约
    address public _stakeToken = 0x81C70b1e2E81e2440A4F633483D6B4057F2aF48A;//质押合约
    address public _stakeToAddr = 0xeEb9D69099b730b29e4f7a4d7857D1DA24C25ed0;//质押到地址
    address public _nftAddr = 0xac62C1e17774329246568124216BC006B8ffe1B5;

    uint256 public stakeMinTime = 1 days; // 最短质押市场
    uint256 public _1uLP = 769639144600; //价值1u的lp数量
    uint256 public _stake1pure = 29 * 10 ** IERC20(_rewardToken).decimals() / 100 / stakeMinTime; //1u 1天产出0.58 每秒可获得

    bool public isStakeStart = true;//是否开始质押
    bool public isClaimStart = true;//是否开始领取收益

    mapping (address => address) public inviteMap; //邀请映射
    mapping (address => uint256) public rewardMap; //邀请分红计算
    mapping (address => uint256) public userInviteAmount; //邀请总LP数量
    mapping (address => uint256) public userInviteMember; //邀请总人数
    uint256 public _fatherReward = 6; //第一代直推奖励
    uint256 public _sonReward = 4; //第二代间推奖励
    mapping (address => bool) public wasMintNFT; //是否已经mint
    uint256 public _nftMintRule = _1uLP * 5000;

    mapping(address => uint256) public _userStake; //用户质押数量
    mapping(address => uint256) public _userStakeStartTime;//用户开始质押时间
    mapping(address => uint256) public _userLastClaimTime;

    mapping(address => bool) public _userBlacklist;//黑名单
    uint256 public totalStake; //总共质押
    uint256 public totalUser; //质押人数

    event Stake(address user, uint256 amount, uint256 startTime);
    event unStake(address user);
    event claimStakeReward(address user, uint256 amount);

    //设置1uLP的数量
    function set1uLP(uint256 amount) public onlyOwner {
        _1uLP = amount;
    }

    //设置挖矿计算方式
    function setStakePure(uint256 amount) public onlyOwner {
        _stake1pure = amount;
    }

    //设置最短质押
    function setMinStakeTime(uint256 amount) public onlyOwner {
        stakeMinTime = amount;
    }

    //设置子币合约
    function setRewardToken(address token) public onlyOwner {
        _rewardToken = token;
    }

    //设置质押合约
    function setStakeToken(address token) public onlyOwner {
        _stakeToken = token;
    }

    //设置质押到地址
    function setStakeToAddr(address addr) public onlyOwner {
        _stakeToAddr = addr;
    }

    //设置分代奖励
    function setFatherAndSonReward(uint256 fa, uint256 son) public onlyOwner {
        _fatherReward = fa;
        _sonReward = son;
    }

    //分红
    function processReward(address main, uint256 amount) internal {
        if (inviteMap[main] != address(0)) {
            rewardMap[inviteMap[main]] += amount / 100 * 6;
            IERC20(_rewardToken).transferFrom(_stakeToAddr, inviteMap[main], amount / 100 * 6);
        }
        if (inviteMap[inviteMap[main]] != address(0)) {
            rewardMap[inviteMap[inviteMap[main]]] += amount / 100 * 4;
            IERC20(_rewardToken).transferFrom(_stakeToAddr, inviteMap[inviteMap[main]], amount / 100 * 4);
        }
        
    }

    //设置开关
    function setStatus(bool stakeStart, bool claimStart) public onlyOwner {
        isStakeStart = stakeStart;
        isClaimStart = claimStart;
    }

    //质押
    function stake(uint256 amount, address invite) public {
        require(isStakeStart, "not start");
        require(_userStake[msg.sender] == 0, "already stake");
        require(amount > 0, "zero stake");
        if (invite != owner() && invite != _stakeToAddr) {
            require(_userStake[invite] > 0, "inviter not stake");
        }
        IERC20(_stakeToken).transferFrom(msg.sender, _stakeToAddr, amount);
        _userStake[msg.sender] = amount;
        _userStakeStartTime[msg.sender] = block.timestamp;
        inviteMap[msg.sender] = invite;
        userInviteAmount[invite] += amount;
        userInviteMember[invite] += 1;
        totalStake += amount;
        totalUser += 1;
        emit Stake(msg.sender, amount, block.timestamp);
    }

    //设置nft邀请门槛
    function setNftMintRule(uint256 amount) public onlyOwner {
        _nftMintRule = amount;
    }

    //取消质押
    function cancalStack() public {
        require(block.timestamp - _userStakeStartTime[msg.sender] >= stakeMinTime, "still stake time");
        require(_userStake[msg.sender] > 0, "no stake");
        IERC20(_stakeToken).transferFrom(_stakeToAddr, msg.sender, _userStake[msg.sender]);
        totalStake -= _userStake[msg.sender];
        totalUser -= 1;
        _userStake[msg.sender] = 0;
        _userStakeStartTime[msg.sender] = 0;
        _userLastClaimTime[msg.sender] = 0;
        inviteMap[msg.sender] = address(0);
        emit unStake(msg.sender);
    }

    //领取质押收益
    function claimReward() public {
        require(isClaimStart, "not start");
        require(_userStake[msg.sender] > 0, "not stake");
        require(!_userBlacklist[msg.sender], "user is in blacklist");
        uint256 amount = pureAmount(msg.sender);
        IERC20(_rewardToken).transferFrom(_stakeToAddr, msg.sender, amount);
        processReward(msg.sender, amount);
        _userLastClaimTime[msg.sender] = block.timestamp;
        emit claimStakeReward(msg.sender, amount);
    }

    //计算质押收益
    function pureAmount(address user) view public returns(uint256 amount) {
        if (_userStakeStartTime[user] > 0 && _userLastClaimTime[user] == 0 && _userStake[user] > 0) {
            amount = (block.timestamp - _userStakeStartTime[user]) * _stake1pure * (_userStake[user] / _1uLP);
        } else if (_userStakeStartTime[user] > 0 && _userLastClaimTime[user] != 0 && _userStake[user] > 0) {
            amount = (block.timestamp - _userLastClaimTime[user]) * _stake1pure * (_userStake[user] / _1uLP);
        } else {
            amount = 0;
        }
    }

    //管理员取回代币
    function ownerClaimToken(address token, address recipient, uint256 amount) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    //管理员设置用户状态
    function ownerSetUser(address user, uint256 amount, uint256 stakeStartTime) public onlyOwner {
        _userStake[user] = amount;
        _userStakeStartTime[user] = stakeStartTime;
    }

    //管理员设置用户邀请状态
    function ownerSetUserInvite(address user, uint256 reAmount, uint256 reMember) public onlyOwner {
        userInviteAmount[user] = reAmount;
        userInviteMember[user] = reMember;
    }

    //管理员设置用户是否领了nft
    function ownerSetUserNFT(address user, bool isClaim) public onlyOwner {
        wasMintNFT[user] = isClaim;
    }

    //获取区块当前时间
    function getBlockNow() view public returns(uint256) {
        return block.timestamp;
    }

    //MintNFT
    function claimNFT() public {
        require(userInviteAmount[msg.sender] >= _nftMintRule, "nft: no enough invite amount");
        require(!wasMintNFT[msg.sender], "nft: already minted");
        require(_userStake[msg.sender] > 0, "nft: not stake");
        IERC721(_nftAddr).safeMint(msg.sender, IERC721(_nftAddr).totalSupply());
        wasMintNFT[msg.sender] = true;
    }

}
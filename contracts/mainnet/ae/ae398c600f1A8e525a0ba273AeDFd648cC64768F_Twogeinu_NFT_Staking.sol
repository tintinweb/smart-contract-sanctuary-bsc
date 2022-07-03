/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier:MIT
interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

interface IBEP721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Twogeinu_NFT_Staking is Ownable {
    using SafeMath for uint256;
    IBEP20 public token;
    IBEP721 public nft;

    uint256 public totalStakedToken;
    uint256 public totalUnStakedToken;
    uint256 public totalWithdrawan;
    uint256 public totalClaimedReward;
    uint256 public totalStakers;
    uint256 public percentDivider;

    uint256[5] public Duration = [7 days, 14 days, 21 days, 30 days, 60 days];
    uint256[5] public Bonus = [42e9, 90e9, 140e9, 200e9, 500e9];
    uint256[5] public totalStakedPerPlan;
    uint256[5] public totalStakersPerPlan;

    struct Stake {
        uint256 plan;
        uint256[] ids;
        uint256 withdrawtime;
        uint256 staketime;
        uint256 reward;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        bool alreadyExists;
        uint256 totalStaked;
        uint256 totalWithdrawan;
        uint256 totalUnStaked;
        uint256 totalClaimedReward;
        uint256 stakeCount;
    }

    mapping(address => User) public Stakers;
    mapping(uint256 => address) public StakersID;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;
    mapping(address => mapping(uint256 => uint256)) public userStakedPerPlan;

    event STAKE(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    constructor(
        address _owner,
        address _nft,
        address _token
    ) Ownable(_owner) {
        nft = IBEP721(_nft);
        token = IBEP20(_token);
        percentDivider = 10000;
    }

    function stake(uint256[] memory nftIds, uint256 planIndex) public {
        require(planIndex >= 0 && planIndex <= 4, "Invalid Time Period");

        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            StakersID[totalStakers] = msg.sender;
            totalStakers++;
        }

        uint256 index = Stakers[msg.sender].stakeCount;
        Stake storage stakeData = stakersRecord[msg.sender][index];
        for (uint256 i; i < nftIds.length; i++) {
            nft.transferFrom(msg.sender, address(this), nftIds[i]);
            stakeData.ids.push(nftIds[i]);
        }
        stakeData.plan = planIndex;
        stakeData.staketime = block.timestamp;
        stakeData.withdrawtime = block.timestamp.add(Duration[planIndex]);
        stakeData.reward = nftIds.length.mul(Bonus[planIndex]).div(
            percentDivider
        );
        Stakers[msg.sender].stakeCount++;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].add(nftIds.length);
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].add(
            nftIds.length
        );
        totalStakersPerPlan[planIndex]++;
        Stakers[msg.sender].totalStaked = Stakers[msg.sender].totalStaked.add(
            nftIds.length
        );
        totalStakedToken = totalStakedToken.add(nftIds.length);

        emit STAKE(msg.sender, nftIds.length);
    }

    function unstake(uint256 index) public {
        Stake storage stakeData = stakersRecord[msg.sender][index];
        require(!stakeData.withdrawan, "already withdrawan");
        require(!stakeData.unstaked, "already unstaked");
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");

        for (uint256 i; i < stakeData.ids.length; i++) {
            nft.transferFrom(address(this), msg.sender, stakeData.ids[i]);
        }
        stakeData.unstaked = true;
        totalUnStakedToken = totalUnStakedToken.add(stakeData.ids.length);
        Stakers[msg.sender].totalUnStaked = Stakers[msg.sender]
            .totalUnStaked
            .add(stakeData.ids.length);
        uint256 planIndex = stakeData.plan;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].sub(stakeData.ids.length, "user stake");
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub(
            stakeData.ids.length,
            "total stake"
        );
        totalStakersPerPlan[planIndex]--;

        emit UNSTAKE(msg.sender, stakeData.ids.length);
    }

    function withdraw(uint256 index) public {
        Stake storage stakeData = stakersRecord[msg.sender][index];
        require(!stakeData.withdrawan, "already withdrawan");
        require(!stakeData.unstaked, "already unstaked");
        require(
            stakeData.withdrawtime < block.timestamp,
            "cannot withdraw before stake duration"
        );
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");

        stakeData.withdrawan = true;
        for (uint256 i; i < stakeData.ids.length; i++) {
            nft.transferFrom(address(this), msg.sender, stakeData.ids[i]);
        }
        token.transferFrom(owner(), msg.sender, stakeData.reward);
        totalWithdrawan = totalWithdrawan.add(stakeData.ids.length);
        totalClaimedReward = totalClaimedReward.add(stakeData.reward);
        Stakers[msg.sender].totalWithdrawan = Stakers[msg.sender]
            .totalWithdrawan
            .add(stakeData.ids.length);
        Stakers[msg.sender].totalClaimedReward = Stakers[msg.sender]
            .totalClaimedReward
            .add(stakeData.reward);
        uint256 planIndex = stakeData.plan;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].sub(stakeData.ids.length, "user stake");
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub(
            stakeData.ids.length,
            "total stake"
        );
        totalStakersPerPlan[planIndex]--;

        emit WITHDRAW(msg.sender, stakeData.reward.add(stakeData.ids.length));
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyOwner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
        Duration[4] = fifth;
    }

    function SetStakeBonus(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyOwner {
        Bonus[0] = first;
        Bonus[1] = second;
        Bonus[2] = third;
        Bonus[3] = fourth;
        Bonus[4] = fifth;
    }

    function SetDivider(uint256 percent) external onlyOwner {
        percentDivider = percent;
    }

    function changeToken(address _new) external onlyOwner {
        token = IBEP20(_new);
    }

    function changeNFT(address _new) external onlyOwner {
        nft = IBEP721(_new);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
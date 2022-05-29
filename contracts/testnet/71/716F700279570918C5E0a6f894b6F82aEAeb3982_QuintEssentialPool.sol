/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

interface IERC721 {
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

    function safeMint(address to, string memory uri1) external returns (uint256);
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

    constructor(address payable owner_) {
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

contract QuintEssentialPool is Ownable {
    using SafeMath for uint256;
    address payable public distributor;
    // IERC20 public token = IERC20(0x64619f611248256F7F4b72fE83872F89d5d60d64); // Main
    IERC20 public token = IERC20(0xA63a11721792915Fe0acEf709293f95e483d7d23); // Test
    // IERC721 public nft1 = IERC721(); // Main
    IERC721 public nft1 = IERC721(0xCdf9B90D687c5C4e478cb62CC1090b4e32FAB0D4); // Test
    // IERC721 public nft2 = IERC721(); // Main
    IERC721 public nft2 = IERC721(0x85489Cc8f97782e6c601A3495343C11Ef9B0bA93); // Test

    uint256 public poolDuration = 14 days;
    uint256 public tokenReward = 904;
    uint256 public rewardDivider = 1_000_000;
    uint256 public minToken = 5000 ether;
    uint256 public totalDeposit;
    uint256 public totalWithdrawn;
    uint256 public uniqueUsers;
    string public uri1 = "https://gateway.pinata.cloud/ipfs/Qma32oPPcgmLNzg2RjgW9MLTPwn2jaVzLHvYbkrT2KUzte";
    string public uri2 = "https://gateway.pinata.cloud/ipfs/QmcuLQWoYxiU7r3SbQiSetM9of1CEbXoGCHjwxdJdvQKGo";

    struct User {
        uint256 amount;
        uint256 reward;
        uint256 nft1Id;
        uint256 nft2Id;
        uint256 startTime;
        bool isWithdrawn;
    }

    mapping(address => User) users;

    event DEPOSIT(address DEPOSITr, uint256 amount);
    event WITHDRAW(address DEPOSITr, uint256 amount);

    constructor(address payable _owner, address payable _distributor)
        Ownable(_owner)
    {
        distributor = _distributor;
    }

    function deposit(uint256 _amount) public {
        require(_amount >= minToken, "Less than min amount");

        User storage user = users[msg.sender];
        require(user.amount == 0, "Already invested");

        token.transferFrom(msg.sender, address(this), _amount);

        uint256 reward = calculateTokenReward(_amount);
        user.amount = _amount;
        user.reward = reward;
        user.startTime = block.timestamp;
        user.nft1Id = nft1.safeMint(msg.sender, uri1);
        user.nft2Id = nft2.safeMint(msg.sender, uri2);
        totalDeposit = totalDeposit.add(_amount);
        uniqueUsers++;

        emit DEPOSIT(msg.sender, _amount);
    }

    function withdraw() public {
        User storage user = users[msg.sender];
        require(block.timestamp >= user.startTime.add(poolDuration), "Wait for end time");
        require(!user.isWithdrawn, "Already withdrawn");
        uint256 amount = user.amount.add(user.reward);
        token.transfer(msg.sender, user.amount);
        token.transferFrom(distributor, msg.sender, user.reward);
        user.isWithdrawn = true;
        totalWithdrawn = totalWithdrawn.add(amount);

        emit WITHDRAW(msg.sender, amount);
    }

    function calculateTokenReward(uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 _day = 24 hours;
        uint256 _duration = poolDuration.div(_day);
        uint256 _reward;
        for (uint256 i = 0 ; i < _duration ; i++){
            _reward = _amount.mul(tokenReward).div(rewardDivider);
            _amount = _amount.add(_reward);
        }
        return _reward;
    }

    function realTimeReward(address _user)
        public
        view
        returns (uint256 _reward)
    {
        User storage user = users[_user];
        uint256 _rewardPerSec = user.reward.div(poolDuration);
        _reward = _rewardPerSec.mul(block.timestamp.sub(user.startTime));
    }

    function getUserInfo(address _user)
        public
        view
        returns (
            uint256 _amount,
            uint256 _reward,
            uint256 _nft1Id,
            uint256 _nft2Id,
            uint256 _startTime,
            bool _isWithdrawn
        )
    {
        User storage user = users[_user];
        _amount = user.amount;
        _reward = user.reward;
        _nft1Id = user.nft1Id;
        _nft2Id = user.nft2Id;
        _startTime = user.startTime;
        _isWithdrawn = user.isWithdrawn;
    }

    function SetPoolsReward(uint256 _token, uint256 _divider)
        external
        onlyOwner
    {
        tokenReward = _token;
        rewardDivider = _divider;
    }

    function SetMinAmount(uint256 _token) external onlyOwner {
        minToken = _token;
    }

    function SetDurations(uint256 _time) external onlyOwner {
        poolDuration = _time;
    }

    function SetNft1(address _nft1, string memory _uri1) external onlyOwner {
        nft1 = IERC721(_nft1);
        uri1 = _uri1;
    }

    function SetNft2(address _nft2, string memory _uri2) external onlyOwner {
        nft2 = IERC721(_nft2);
        uri2 = _uri2;
    }

    function ChangeDistributor(address payable _distributor)
        external
        onlyOwner
    {
        distributor = _distributor;
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
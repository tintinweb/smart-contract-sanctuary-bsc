// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./SafeMath.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IERC721.sol";
import "./SafeERC20.sol";
import "./IERC721Receiver.sol";

contract DividendNFT is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    struct UserInfo {
        uint256 amount; // The NFT value user deposited.
        uint256 startTime; // The timestamp user deposited last.
        uint256 rewardTotal; // Total reward token amount. (update when user deposit/withdraw/takeReward)
        uint256 rewardTaked; // Taked reward token amount. (update when user takeReward)
        uint256 rewardDebt; // Debt reward token amount. (update when user deposit/withdraw/takeReward)
    }

    struct PoolInfo {
        uint256 amount; // The NFT value all users deposited.
        uint256 rewardTotal; // Total token reward amount. (update every day)
        uint256 rewardLast; // Last time token reward amount. (update every day)
        uint256 rewardRateLast; // Last time token reward amount per 1e18 deposit token. (update every day)
        uint256 accPerShare; // Accumulated token reward per share, times 1e12.
    }

    bool private _paused;
    mapping(address => bool) public operators;

    IERC721 public depositNFT; // Deposit this NFT to get reward.
    IERC20 public rewardToken; // Distribute reward token from transfer tax.
    uint256 public rewardPending; // Pending reward token amount.
    uint256 public rewardDispersed; // Dispersed reward token amount.

    PoolInfo private _pool; // The pool info.
    mapping(uint256 => address) private _nftUsers; // All deposited NFTs. (nft token id => deposited user)
    mapping(uint256 => bool) private _depositedNFTs; // All deposited NFTs. (nft token id => is deposited)
    mapping(address => UserInfo) private _users; // All users info. (user address => pool index => user info)


    mapping(address => uint256[]) public _userNftsArr; //用户未成交订单列表
    mapping(address =>mapping(uint256 => uint256)) private _userNftsIndexMap;//用户未成交订单id在订单列表的位置


    address[] private _depositedUsers; // All users address who has deposited.
    mapping(address => bool) private _depositedUserAdded; // All users address who has deposited.

    event Deposit(address indexed user, uint256 indexed tokenId, uint256 amount);
    event TakeReward(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed tokenId, uint256 amount);

    event addRewardInfoEvent(uint256 indexed amount);

    constructor() {
        _paused = false;
        operators[msg.sender] = true;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    //////////////////////////////////////////
    ///////////// admin functions ////////////
    //////////////////////////////////////////

    function setPaused(bool paused_) public onlyOwner {
        _paused = paused_;
    }

    function setOperator(address _operator, bool _enabled) public onlyOwner {
        operators[_operator] = _enabled;
    }

    function setTokenAddress(IERC721 _depositNFT, IERC20 _rewardToken) public onlyOwner {
        depositNFT = _depositNFT;
        rewardToken = _rewardToken;
    }

    function setPool(
        uint256 _rewardTotal,
        uint256 _rewardLast,
        uint256 _rewardRateLast
    ) public onlyOwner {
        _pool.rewardTotal = _rewardTotal;
        _pool.rewardLast = _rewardLast;
        _pool.rewardRateLast = _rewardRateLast;
    }

    // Callback this function when someone transfer main token
    // function onTransfer(
    //     address _from,
    //     address _to,
    //     uint256 _amount,
    //     uint256 _transferType
    // ) public override {
    //     if (_paused) {
    //         return;
    //     }
    // }

    // Call this function after transfer reward to this contract
    function addReward(uint256 _rewardAmount) public onlyOperator {
        if (_paused) {
            return;
        }

        rewardPending = rewardPending.add(_rewardAmount);
    }

    // Call this function after transfer reward to this contract
    function addRewardInfo( uint256 _rewardAmount ) public  onlyOperator {
        addReward(_rewardAmount);
        disperseReward();

        emit addRewardInfoEvent(_rewardAmount);
    }

    function disperseReward() public onlyOperator {
        if (rewardPending == 0 || _pool.amount == 0) {
            return;
        }

        _pool.rewardRateLast = rewardPending.mul(1e18).div(_pool.amount);
        _pool.rewardLast = _pool.rewardRateLast.mul(_pool.amount).div(1e18);
        _pool.rewardTotal = _pool.rewardTotal.add(_pool.rewardLast);
        _pool.accPerShare = _pool.accPerShare.add(_pool.rewardLast.mul(1e12).div(_pool.amount));

        rewardPending = 0;
        rewardDispersed = rewardDispersed.add(rewardPending);
    }

    // deposit for _to but use msg.sender's balance.
    function _deposit(uint256 _tokenId, address _to) internal {
        require(!_depositedNFTs[_tokenId], "Farm: NFT has been deposited");

        uint256 _amount = 1;
        if (_amount <= 0) {
            return;
        }

        UserInfo storage _user = _users[_to];

        depositNFT.safeTransferFrom(msg.sender, address(this), _tokenId);

        // settle rewards for previously amount
        _user.rewardTotal = _user.rewardTotal.add(_user.amount.mul(_pool.accPerShare).div(1e12).sub(_user.rewardDebt));

        _pool.amount = _pool.amount.add(_amount);
        _user.amount = _user.amount.add(_amount);
        _user.startTime = block.timestamp;
        _user.rewardDebt = _user.amount.mul(_pool.accPerShare).div(1e12);

        if (!_depositedUserAdded[_to]) {
            _depositedUsers.push(_to);
            _depositedUserAdded[_to] = true;
        }

        _nftUsers[_tokenId] = _to;
        _depositedNFTs[_tokenId] = true;
        _addTouserNftsEnumeration(_to,_tokenId);

        emit Deposit(_to, _tokenId, _amount);
    }

    function rescue(
        address _token,
        address payable _to,
        uint256 _amount
    ) public onlyOwner {
        if (_token == address(0)) {
            (bool success, ) = _to.call{ gas: 23000, value: _amount }("");
            require(success, "transferETH failed");
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }
    }

    function getMyRewardTokenBalanceOf() public view returns (uint256) {
        return IERC20(rewardToken).balanceOf(address(this));
    }



    //////////////////////////////////////////
    //////////////////long//////////////////
    //////////////////////////////////////////
    function _addTouserNftsEnumeration(address to,uint256 _tokenId) private {
        _userNftsIndexMap[to][_tokenId] = _userNftsArr[to].length;
        _userNftsArr[to].push(_tokenId);
    }
    function _removeuserNftsEnumeration(address from,uint256 _tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastOrderIndex = _userNftsArr[from].length - 1;
        uint256 orderIndex = _userNftsIndexMap[from][_tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary.
        if (orderIndex != lastOrderIndex) {
            uint256 last_tokenId = _userNftsArr[from][lastOrderIndex];

            _userNftsArr[from][orderIndex] = last_tokenId; // Move the last token to the slot of the to-delete token
            _userNftsIndexMap[from][last_tokenId] = orderIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _userNftsIndexMap[from][_tokenId];
        _userNftsArr[from].pop();
    }

    function userNftsLists(address to) public view returns (uint256[] memory) {
        return _userNftsArr[to];
    }


    //////////////////////////////////////////
    ///////////// user functions /////////////
    //////////////////////////////////////////

    function deposit(uint256 _tokenId) public whenNotPaused {
        _deposit(_tokenId, msg.sender);
    }

    function takeReward() public whenNotPaused {
        UserInfo storage _user = _users[msg.sender];

        uint256 _rewardDebt = _user.amount.mul(_pool.accPerShare).div(1e12);
        _user.rewardTotal = _user.rewardTotal.add(_rewardDebt.sub(_user.rewardDebt));
        _user.rewardDebt = _rewardDebt;

        uint256 _reward = _user.rewardTotal.sub(_user.rewardTaked);

        if (_reward == 0) {
            return;
        }

        rewardToken.safeTransfer(msg.sender, _reward);
        _user.rewardTaked = _user.rewardTaked.add(_reward);

        emit TakeReward(msg.sender, _reward);
    }

    function withdraw(uint256 _tokenId) public whenNotPaused {
        require(_nftUsers[_tokenId] == msg.sender, "Farm: NFT user not match");
        require(_depositedNFTs[_tokenId], "Farm: NFT has not been deposited");

        uint256 _amount = 1;
        if (_amount <= 0) {
            return;
        }

        UserInfo storage _user = _users[msg.sender];

        // settle rewards for previously amount
        _user.rewardTotal = _user.rewardTotal.add(_user.amount.mul(_pool.accPerShare).div(1e12).sub(_user.rewardDebt));

        _pool.amount = _pool.amount.sub(_amount);
        _user.amount = _user.amount.sub(_amount);
        _user.rewardDebt = _user.amount.mul(_pool.accPerShare).div(1e12);


        _removeuserNftsEnumeration(msg.sender,_tokenId);

        depositNFT.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit Withdraw(msg.sender, _tokenId, _amount);

        if (_user.amount == 0) {
            takeReward();
        }
    }

    function getPoolInfo() public view returns (PoolInfo memory) {
        return _pool;
    }

    function countUsers() public view returns (uint256) {
        return _depositedUsers.length;
    }

    function users(uint256 _startIndex, uint256 _endIndex) public view returns (address[] memory) {
        if (_depositedUsers.length == 0) {
            return new address[](0);
        }

        if (_endIndex == 0) {
            _endIndex = _depositedUsers.length - 1;
        }

        address[] memory users_ = new address[](_endIndex - _startIndex + 1);

        for (uint256 index = _startIndex; index <= _endIndex; index++) {
            users_[index - _startIndex] = _depositedUsers[index];
        }

        return users_;
    }

    function getUserInfo(address _user) public view returns (UserInfo memory) {
        UserInfo memory user_ = _users[_user];

        uint256 _rewardDebt = user_.amount.mul(_pool.accPerShare).div(1e12);
        user_.rewardTotal = user_.rewardTotal.add(_rewardDebt.sub(user_.rewardDebt));
        user_.rewardDebt = _rewardDebt;

        return user_;
    }

    function getDepositAmount() public view returns (uint256) {
        return _pool.amount;
    }

    function getUserDepositAmount(address _user) public view returns (uint256) {
        return _users[_user].amount;
    }



    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) external pure returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }
}